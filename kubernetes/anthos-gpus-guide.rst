.. Date: November 13 2020
.. Author: pramarao

.. _anthos-gpus-guide:

####################################################
NVIDIA GPUs with Google Cloud Anthos
####################################################

**********
Changelog
**********

* 11/25/2020 (author: PR): 
   * Migrated docs to new format
* 8/14/2020 (author: PR): 
   * Initial Version

***************
Introduction
***************

Google Cloud Anthos is a modern application management platform that lets users 
build, deploy, and manage applications anywhere in a secure, consistent manner. 
The platform provides a consistent development and operations experience across 
deployments while reducing operational overhead and improving developer productivity. 
Anthos runs in hybrid and multi-cloud environments that spans `Google Cloud <https://cloud.google.com/kubernetes-engine>`_, 
`on-premise <https://cloud.google.com/anthos/docs/gke/on-prem>`_, and is generally 
available on `Amazon Web Services (AWS) <https://cloud.google.com/anthos/docs/gke/aws>`_. 
Support for Anthos on Microsoft Azure is in preview. For more information on Anthos, 
see the `product overview <https://cloud.google.com/anthos>`_.

Kubernetes provides access to special hardware resources such as NVIDIA GPUs, NICs, 
Infiniband adapters and other devices through the `device plugin framework <https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/>`_. 
However, configuring and managing nodes with these hardware resources requires 
configuration of multiple software components such as drivers, container runtimes 
or other libraries which are difficult and prone to errors. The `NVIDIA GPU Operator <https://github.com/NVIDIA/gpu-operator>`_
uses the operator framework within Kubernetes to automate the management of all NVIDIA 
software components needed to provision GPUs.

Anthos uses the NVIDIA GPU Operator to configure GPU nodes in the Kubernetes cluster 
so that the nodes can be used to schedule CUDA applications. The GPU Operator itself is 
deployed using Helm. The purpose of this document is to provide users with steps on getting 
started with using NVIDIA GPUs with Anthos.

*********************
Prerequisites
*********************

Anthos running on-premise has requirements for which vSphere versions are supported along with network and storage requirements. 
Please see the Anthos version compatibility matrix for more information: 
`https://cloud.google.com/anthos/gke/docs/on-prem/versioning-and-upgrades#version_compatibility_matrix <https://cloud.google.com/anthos/gke/docs/on-prem/versioning-and-upgrades#version_compatibility_matrix.>`_.

This guide assumes that the user already has an installed Anthos on-premise cluster in a vSphere environment. Please see 
`https://cloud.google.com/anthos/gke/docs/on-prem/how-to/install-overview-basic <https://cloud.google.com/anthos/gke/docs/on-prem/how-to/install-overview-basic>`_ 
for detailed instructions for installing Anthos in an on-premise environment.

*******************************
Configuring PCIe Passthrough
*******************************

For the GPU to be accessible to the VM, first you must enable `PCI Passthrough <https://kb.vmware.com/s/article/1010789>`_ 
on the ESXi host. This can be done from the vSphere client. This will require a reboot 
of the ESXi host to complete the process and therefore the host should be put into 
maintenance mode and any VMs running on the ESXi host evacuated to another. 
If you only have a single ESXi host, then the VMs will need to be restarted after the reboot.

From the vSphere client, select an ESXi host from the Inventory of VMware vSphere Client. 
In the Configure tab, click Hardware > PCI Devices. This will show you the 
passthrough-enabled devices (you will most likely find none at this time).

.. image:: graphics/anthos/virt/image01.png
   :width: 800

Click CONFIGURE PASSTHROUGH to launch the Edit PCI Device Availability window. Look for the GPU device and 
select the checkbox next to it (the GPU device will be recognizable as having NVIDIA Corporation in the Vendor Name view). 
Select the GPU devices (you may have more than one) and click OK.

.. image:: graphics/anthos/virt/image02.png
   :width: 800

At this point, the GPU(s) will appear as Available (pending). You will need to select Reboot This Host and complete the reboot before proceeding to the next step.

.. image:: graphics/anthos/virt/image03.png
   :width: 800

It is a VMware best practice to reboot an ESXi host only when it is in maintenance mode and after all the VMs have been migrated to other hosts. 
If you have only 1 ESXi host, then you can reboot without migrating the VMs, though shutting them down gracefully first is always a good idea.

.. image:: graphics/anthos/virt/image04.png
   :width: 400

Once the server has rebooted. Make sure to remove maintenance mode (if it was used) or restart the VMs that needed to be stopped (when only a single ESXi host is used).

*******************************
Adding GPUs to a Node
*******************************

Creating a Node Pool for the GPU Node
=======================================

.. note::
   This is an optional step.

Node Pools are a good way to specify pools of Kubernetes worker nodes which may have different or unique attributes. In this case, we have the opportunity to 
create a node pool which contains workers that manually have a GPU assigned to it. See `here <https://cloud.google.com/anthos/gke/docs/on-prem/how-to/managing-node-pools?hl=en>`_ 
for more information regarding node pools with Anthos on-premise.

First, edit your user cluster config.yaml file on the admin workstation and add an additional node pool:

.. code-block:: console

   - name: user-cluster1-gpu
     cpus: 4
     memoryMB: 8192
     replicas: 1
     labels:
       hardware: gpu

After adding the node pool to your configuration, use the ``gkectl`` update command push the change:

.. code-block:: console

   $ gkectl update cluster --kubeconfig [ADMIN_CLUSTER_KUBECONFIG] \
      --config [USER_CLUSTER_KUBECONFIG]

.. code-block:: console

   Reading config with version "v1"
   Update summary for cluster user-cluster1-bundledlb:
      Node pool(s) to be created: [user-cluster1-gpu]
   Do you want to continue? [Y/n]: Y
   Updating cluster "user-cluster1-bundledlb"...
   Creating node MachineDeployment(s) in user cluster...  DONE
   Done updating the user cluster

Add GPUs to Nodes in vSphere
=============================

Select an existing user-cluster node to add a GPU to (if you created a node pool 
with the previous step then you would choose a node from that pool). Make sure that 
this VM is on the host with the GPU (if you have vMotion enabled this could be as 
simple as right clicking on the VM and selecting **Migrate**).

To configure a PCI device on a virtual machine, from the Inventory in vSphere Client, 
right-click the virtual machine and select **Power->Power Off**.

.. image:: graphics/anthos/virt/image05.png
   :width: 800

After the VM is powered off, right-click the virtual machine and click **Edit Settings**.

.. image:: graphics/anthos/virt/image06.png
   :width: 400

Within the Edit Settings window, click **ADD NEW DEVICE**.

.. image:: graphics/anthos/virt/image07.png
   :width: 800

Choose PCI Device from the dropdown.

.. image:: graphics/anthos/virt/image08.png
   :width: 400

You may need to select the GPU or if it’s the only device available it may be automatically 
selected for you. If you don’t see the GPU, it’s possible your VM is not currently on the 
ESXi host with the passthrough device configured.

.. image:: graphics/anthos/virt/image09.png
   :width: 800

Expand the **Memory** section and make sure to select the option for Reserve all **Guest Memory (All locked)**.

.. image:: graphics/anthos/virt/image10.png
   :width: 800

Click **OK**.

Before the VM can be started, the VM/Host Rule for VM anti-affinity must be deleted. 
(Note that this step may not be necessary if your cluster’s ``config.yaml`` contains ``antiAffinityGroups.enabled: False``). 
From the vSphere Inventory list, click on the cluster then the **Configure** tab and then 
under **Configuration** select **VM/Host Rules**. Select the rule containing your node and delete it.

.. image:: graphics/anthos/virt/image11.png
   :width: 800

Now you can power on the VM, right click on the VM and select **Power>Power On**.

.. image:: graphics/anthos/virt/image12.png
   :width: 800

If vSphere presents you with **Power On Recommendations** then select **OK**.

.. image:: graphics/anthos/virt/image13.png
   :width: 800

The following steps should be performed from your Admin Workstation or other Linux system which has the ability to use ``kubectl`` to work with the cluster.

.. Shared content for setting up the Operator

.. include:: ../gpu-operator/install-gpu-operator.rst

Running GPU Applications
==========================

Jupyter Notebooks
------------------

This section of the guide walks through how to run a sample Jupyter notebook on the Kubernetes cluster.

#. Create a yaml file for the pod and service for the notebook:

   .. code-block:: console

      $ LOADBALANCERIP=<ip address to be used to expose the service>

   .. code-block:: console

      $ cat << EOF | kubectl create -f -
      apiVersion: v1
      kind: Service
      metadata:
        name: tf-notebook
        labels:
          app: tf-notebook
      spec:
        type: LoadBalancer
        loadBalancerIP: $LOADBALANCERIP
        ports:
        - port: 80
          name: http
          targetPort: 8888
          nodePort: 30001
        selector:
          app: tf-notebook
      ---
      apiVersion: v1
      kind: Pod
      metadata:
        name: tf-notebook
        labels:
          app: tf-notebook
      spec:
        securityContext:
          fsGroup: 0
        containers:
        - name: tf-notebook
          image: tensorflow/tensorflow:latest-gpu-jupyter
          resources:
            limits:
              nvidia.com/gpu: 1
          ports:
          - containerPort: 8888
            name: notebook
      EOF

#. View the logs of the tf-notebook pod to obtain the token:

   .. code-block:: console

      $ kubectl logs tf-notebook

   .. code-block:: console

      [I 19:07:43.061 NotebookApp] Writing notebook server cookie secret to /root/.local/share/jupyter/runtime/notebook_cookie_secret
      [I 19:07:43.423 NotebookApp] Serving notebooks from local directory: /tf
      [I 19:07:43.423 NotebookApp] The Jupyter Notebook is running at:
      [I 19:07:43.423 NotebookApp] http://tf-notebook:8888/?token=fc5d8b9d6f29d5ddad62e8c731f83fc8e90a2d817588d772
      [I 19:07:43.423 NotebookApp]  or http://127.0.0.1:8888/?token=fc5d8b9d6f29d5ddad62e8c731f83fc8e90a2d817588d772
      [I 19:07:43.423 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
      [C 19:07:43.429 NotebookApp] 
         
         To access the notebook, open this file in a browser:
            file:///root/.local/share/jupyter/runtime/nbserver-1-open.html
         Or copy and paste one of these URLs:
            http://tf-notebook:8888/?token=fc5d8b9d6f29d5ddad62e8c731f83fc8e90a2d817588d772
         or http://127.0.0.1:8888/?token=fc5d8b9d6f29d5ddad62e8c731f83fc8e90a2d817588d772
      [I 19:08:24.180 NotebookApp] 302 GET / (172.16.20.30) 0.61ms
      [I 19:08:24.182 NotebookApp] 302 GET /tree? (172.16.20.30) 0.57ms

#. From a web browser, navigate to ``http://<LOADBALANCERIP>`` and enter the token where prompted to login: 
   Depending on your environment you may not have web browser access to the exposed service. You may be able to use 
   `SSH Port Forwarding/Tunneling <https://www.ssh.com/ssh/tunneling/example>`_ to achieve this.

   .. image:: graphics/anthos/virt/image14.png
      :width: 800

#. Once logged in, navigate click on the tenserflow-tutorials folder and then on the first file, **classification.ipynb**:

   .. image:: graphics/anthos/virt/image15.png
      :width: 800

#. This will launch a new tab with the Notebook loaded. You can now run through the Notebook by clicking on the **Run** 
   button. The notebook will step through each section and execute the code as you go. Continue pressing **Run** until you 
   reach the end of the notebook and observe the execution of the classification program.

   .. image:: graphics/anthos/virt/image16.png
      :width: 800

#. Once the notebook is complete you can check the logs of the ``tf-notebook`` pod to confirm it was using the GPU:

   .. code-block:: console

      =========snip===============
      [I 19:17:58.116 NotebookApp] Saving file at /tensorflow-tutorials/classification.ipynb
      2020-05-21 19:21:01.422482: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcuda.so.1
      2020-05-21 19:21:01.436767: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:981] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
      2020-05-21 19:21:01.437469: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1561] Found device 0 with properties: 
      pciBusID: 0000:13:00.0 name: Tesla P4 computeCapability: 6.1
      coreClock: 1.1135GHz coreCount: 20 deviceMemorySize: 7.43GiB deviceMemoryBandwidth: 178.99GiB/s
      2020-05-21 19:21:01.438477: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcudart.so.10.1
      2020-05-21 19:21:01.462370: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcublas.so.10
      2020-05-21 19:21:01.475269: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcufft.so.10
      2020-05-21 19:21:01.478104: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcurand.so.10
      2020-05-21 19:21:01.501057: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcusolver.so.10
      2020-05-21 19:21:01.503901: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcusparse.so.10
      2020-05-21 19:21:01.544763: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcudnn.so.7
      2020-05-21 19:21:01.545022: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:981] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
      2020-05-21 19:21:01.545746: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:981] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
      2020-05-21 19:21:01.546356: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1703] Adding visible gpu devices: 0
      2020-05-21 19:21:01.546705: I tensorflow/core/platform/cpu_feature_guard.cc:143] Your CPU supports instructions that this TensorFlow binary was not compiled to use: AVX2 AVX512F FMA
      2020-05-21 19:21:01.558283: I tensorflow/core/platform/profile_utils/cpu_utils.cc:102] CPU Frequency: 2194840000 Hz
      2020-05-21 19:21:01.558919: I tensorflow/compiler/xla/service/service.cc:168] XLA service 0x7f6f2c000b20 initialized for platform Host (this does not guarantee that XLA will be used). Devices:
      2020-05-21 19:21:01.558982: I tensorflow/compiler/xla/service/service.cc:176]   StreamExecutor device (0): Host, Default Version
      2020-05-21 19:21:01.645786: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:981] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
      2020-05-21 19:21:01.646387: I tensorflow/compiler/xla/service/service.cc:168] XLA service 0x53ab350 initialized for platform CUDA (this does not guarantee that XLA will be used). Devices:
      2020-05-21 19:21:01.646430: I tensorflow/compiler/xla/service/service.cc:176]   StreamExecutor device (0): Tesla P4, Compute Capability 6.1
      2020-05-21 19:21:01.647005: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:981] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
      2020-05-21 19:21:01.647444: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1561] Found device 0 with properties: 
      pciBusID: 0000:13:00.0 name: Tesla P4 computeCapability: 6.1
      coreClock: 1.1135GHz coreCount: 20 deviceMemorySize: 7.43GiB deviceMemoryBandwidth: 178.99GiB/s
      2020-05-21 19:21:01.647523: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcudart.so.10.1
      2020-05-21 19:21:01.647570: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcublas.so.10
      2020-05-21 19:21:01.647611: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcufft.so.10
      2020-05-21 19:21:01.647647: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcurand.so.10
      2020-05-21 19:21:01.647683: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcusolver.so.10
      2020-05-21 19:21:01.647722: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcusparse.so.10
      2020-05-21 19:21:01.647758: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcudnn.so.7
      2020-05-21 19:21:01.647847: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:981] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
      2020-05-21 19:21:01.648311: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:981] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
      2020-05-21 19:21:01.648720: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1703] Adding visible gpu devices: 0
      2020-05-21 19:21:01.649158: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcudart.so.10.1
      2020-05-21 19:21:01.650302: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1102] Device interconnect StreamExecutor with strength 1 edge matrix:
      2020-05-21 19:21:01.650362: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1108]      0 
      2020-05-21 19:21:01.650392: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1121] 0:   N 
      2020-05-21 19:21:01.650860: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:981] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
      2020-05-21 19:21:01.651341: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:981] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
      2020-05-21 19:21:01.651773: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1247] Created TensorFlow device (/job:localhost/replica:0/task:0/device:GPU:0 with 7048 MB memory) -> physical GPU (device: 0, name: Tesla P4, pci bus id: 0000:13:00.0, compute capability: 6.1)
      2020-05-21 19:21:03.601093: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcublas.so.10
      [I 19:21:58.132 NotebookApp] Saving file at /tensorflow-tutorials/classification.ipynb
 
Uninstall and Cleanup
==========================

You can remove the ``tf-notebook`` and service with the following commands:

.. code-block:: console

   $ kubectl delete pod tf-notebook

.. code-block:: console

   $ kubectl delete svc tf-notebook

You can remove the GPU operator with the command:

.. code-block:: console

   $ helm uninstall $(helm list | grep gpu-operator | awk '{print $1}')

.. code-block:: console

   release "gpu-operator-1590086955" uninstalled

You can now stop the VM, remove the PCI device, remove the memory reservation, and restart the VM.

You do not need to remove the PCI passthrough device from the host.

Known Issues
==============

This section outlines some known issues with using Google Cloud Anthos with NVIDIA GPUs.

#. Attaching a GPU to a Anthos on-prem worker node requires manually editing the VM from vSphere. 
   These changes will not survive an Anthos on-prem upgrade process. When the node with the GPU is 
   deleted as part of the update process, the new VM replacing it will not have the GPU added. 
   The GPU must be added back to a new VM manually again. While the NVIDIA GPU seems to be able to 
   handle that event gracefully, the workload backed by the GPU may need to be initiated again manually.

#. Attaching a VM to the GPU means that the VM can no longer be migrated to another ESXi host. The VM 
   will essentially be pinned to the ESXi host which hosts the GPU. vMotion and VMware HA features cannot be used.

#. VMs that use a PCI Passthrough device require that their full memory allocation be locked. This will cause a 
   **Virtual machine memory usage** alarm on the VM which can safely be ignored.

   .. image:: graphics/anthos/virt/image17.png
      :width: 800

Getting Support
================

For support issues related to using GPUs with Anthos, please `open a ticket <https://github.com/NVIDIA/gpu-operator/issues/new>`_ 
on the NVIDIA GPU Operator GitHub project. Your feedback is appreciated.
