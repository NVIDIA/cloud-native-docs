.. _confidential-containers-deploy:

******************************
Deploy Confidential Containers
******************************

The page describes deploying the NVIDIA Confidential Container Reference Architecture on Kubernetes using Kata Containers and the NVIDIA GPU Operator.

Before you begin, refer to the :doc:`Confidential Containers Reference Architecture <overview>` for details on the reference architecture and the :doc:`Supported Platforms <supported-platforms>` page for the supported platforms.

Overview
========

The high-level workflow for configuring Confidential Containers is as follows:

#. Configure the :ref:`Prerequisites <coco-prerequisites>`.

#. :ref:`Label Nodes <coco-label-nodes>` that you want to use with Confidential Containers.

#. Install the :ref:`latest Kata Containers Helm chart <coco-install-kata-chart>`. 
   This installs the Kata Containers runtime binaries, UVM images and kernels, and TEE-specific shims (such as ``kata-qemu-nvidia-gpu-snp`` or ``kata-qemu-nvidia-gpu-tdx``) onto the cluster's worker nodes.

#. Install the :ref:`NVIDIA GPU Operator configured for Confidential Containers <coco-install-gpu-operator>`. 
   This installs the NVIDIA GPU Operator components that are required to deploy Confidential Containers workloads.

After installation, you can change the :ref:`confidential computing mode <managing-confidential-computing-mode>` and :ref:`run a sample GPU workload <coco-run-sample-workload>` in a confidential container.

This guide will configure your cluster to deploy Confidential Containers workloads.
Once configured, you can schedule workloads that request GPU resources and use the ``kata-qemu-nvidia-gpu-tdx`` or ``kata-qemu-nvidia-gpu-snp`` runtime classes for secure deployment.

.. _coco-prerequisites:

Prerequisites
=============

* Use a supported platform for Confidential Containers.
  For more information, refer to :doc:`Supported Platforms <supported-platforms>`.

  For additional information on node configuration, refer to the *Confidential Computing Deployment Guide* at the `Confidential Computing <https://docs.nvidia.com/confidential-computing>`_ website for information about supported NVIDIA GPUs, such as the NVIDIA Hopper H100.
  Specifically refer to the `CC deployment guide for SEV-SNP <https://docs.nvidia.com/cc-deployment-guide-snp.pdf>`_ for setup specific to AMD SEV-SNP machines.

  The following topics in the deployment guide apply to a cloud-native environment:

  * Hardware selection and initial hardware configuration, such as BIOS settings.
  * Host operating system selection, initial configuration, and validation.

  When following the cloud-native sections in the deployment guide linked above, use Ubuntu 25.10 as the host OS with its default kernel version and configuration.

* Ensure hosts are configured to enable hardware virtualization and Access Control Services (ACS).
  With some AMD CPUs and BIOSes, ACS might be grouped under Advanced Error Reporting (AER).
  Enabling these features is typically performed by configuring the host BIOS.
* Configured hosts to support IOMMU.

  * If the output from running ``ls /sys/kernel/iommu_groups`` includes 0, 1, and so on, then your host is configured for IOMMU.
  * If the host is not configured or if you are unsure, add the ``amd_iommu=on`` Linux kernel command-line argument. For most Linux distributions, add the argument to the ``/etc/default/grub`` file, for instance::

       ...
       GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on modprobe.blacklist=nouveau"
       ...

    Run ``sudo update-grub`` after making the change to configure the bootloader. Reboot the host after configuring the bootloader.

* A Kubernetes cluster with cluster administrator privileges.

* It is recommended that you configure your cluster's ``runtimeRequestTimeout`` in your `kubelet configuration <https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/>`_ with a higher timeout value than the two minute default.
  You could set this value to 20 minutes to match the default values for the NVIDIA shim configurations in Kata Containers ``create_container_timeout`` and the agent's ``image_pull_timeout``.
 
  Using the guest-pull mechanism, pulling large images may take a significant amount of time and may delay container start.
  This can lead to Kubelet de-allocating your pod before it transitions from the container creating to the container running state. 
  
  The NVIDIA shim configurations in Kata Containers use a default ``create_container_timeout`` of 1200 seconds (20 minutes). 
  This controls the time the shim allows for a container to remain in container creating state. 
 
  If you need a timeout of more than 1200 seconds, you will also need to adjust the agent's ``image_pull_timeout`` value which controls the agent-side timeout for guest-image pull. 
  To do this, add the ``agent.image_pull_timeout`` kernel parameter to your shim configuration, or pass an explicit value in a pod annotation in the ``io.katacontainers.config.hypervisor.kernel_params="..."`` annotation.  

* Enable ``KubeletPodResourcesGet`` on your cluster.
  The NVIDIA GPU runtime classes use VFIO cold-plug, which requires the Kata runtime to query Kubelet's Pod Resources API to discover allocated GPU devices during sandbox creation.

  * For Kubernetes versions older than 1.34, explicitly enable the ``KubeletPodResourcesGet`` feature gate in your Kubelet configuration.
  * For Kubernetes 1.34 and later, this feature is enabled by default.

  Refer to the `Kata runtime (VFIO cold-plug) <https://github.com/kata-containers/kata-containers/blob/main/docs/use-cases/NVIDIA-GPU-passthrough-and-Kata-QEMU.md#kata-runtime>`_ section in the upstream NVIDIA GPU passthrough guide for more information.

.. _installation-and-configuration:

Installation and Configuration
===============================

.. _coco-label-nodes:

Label Nodes
-----------

#. Label the nodes that you want to use with Confidential Containers:

   .. code-block:: console

      $ kubectl label node <node-name> nvidia.com/gpu.workload.config=vm-passthrough

The GPU Operator uses this label to determine what software components to deploy to a node.
The ``nvidia.com/gpu.workload.config=vm-passthrough`` label specifies that the node should receive the software components to run Confidential Containers.
You can use this label on nodes for Confidential Containers workloads, and run traditional container workloads with GPU on other nodes in your cluster.

.. tip::

   Skip this section if you plan to use all nodes in your cluster to run Confidential Containers and instead set ``sandboxWorkloads.defaultWorkload=vm-passthrough`` when installing the GPU Operator.

To check whether the node label has been added, run the following command:

.. code-block:: console

   $ kubectl describe node <node-name> | grep nvidia.com/gpu.workload.config

Example output:

.. code-block:: output

   nvidia.com/gpu.workload.config: vm-passthrough

.. _coco-install-kata-chart:

Install the Kata Containers Helm Chart
--------------------------------------

Install the ``kata-deploy`` Helm chart.
The ``kata-deploy`` chart installs all required components from the Kata Containers project including the Kata Containers runtime binary, runtime configuration, UVM kernel and initrd that NVIDIA uses for Confidential Containers and native Kata containers.

The minimum required version is 3.29.0.

#. Get the latest version of the ``kata-deploy`` Helm chart:

   .. code-block:: console

      $ export VERSION="3.29.0"
      $ export CHART="oci://ghcr.io/kata-containers/kata-deploy-charts/kata-deploy"


#. Install the kata-deploy Helm chart:

   .. code-block:: console

     $ helm install kata-deploy "${CHART}" \
       --namespace kata-system --create-namespace \
       --set nfd.enabled=false \
       --wait --timeout 10m \
       --version "${VERSION}"

   *Example Output*

   .. code-block:: output

      LAST DEPLOYED: Wed Apr  1 17:03:00 2026
      NAMESPACE: kata-system
      STATUS: deployed
      REVISION: 1
      DESCRIPTION: Install complete
      TEST SUITE: None

#. Optional: Verify that the kata-deploy pod is running:

   .. code-block:: console

      $ kubectl get pods -n kata-system | grep kata-deploy

   *Example Output*

   .. code-block:: output

      NAME                    READY   STATUS    RESTARTS      AGE
      kata-deploy-b2lzs       1/1     Running   0             6m37s

#. Optional: View the pod in the kata-system namespace and ensure it is running:

   .. code-block:: console

      $ kubectl get pod,svc -n kata-system

   *Example Output*:

   .. code-block:: output

      NAME                    READY   STATUS    RESTARTS   AGE
      pod/kata-deploy-4f658   1/1     Running   0          21s

   Wait a few minutes for kata-deploy to create the base runtime classes.

#. Verify that the ``kata-qemu-nvidia-gpu``, ``kata-qemu-nvidia-gpu-snp``, and ``kata-qemu-nvidia-gpu-tdx`` runtime classes are available:

   .. code-block:: console

      $  kubectl get runtimeclass | grep kata-qemu-nvidia-gpu

   *Example Output*

   .. code-block:: output

      NAME                       HANDLER                    AGE
      kata-qemu-nvidia-gpu       kata-qemu-nvidia-gpu       40s
      kata-qemu-nvidia-gpu-snp   kata-qemu-nvidia-gpu-snp   40s
      kata-qemu-nvidia-gpu-tdx   kata-qemu-nvidia-gpu-tdx   40s

   Several runtimes are installed by the ``kata-deploy`` chart.
   The ``kata-qemu-nvidia-gpu`` runtime class is used with Kata Containers, in a non-Confidential Containers scenario.
   The ``kata-qemu-nvidia-gpu-snp`` and ``kata-qemu-nvidia-gpu-tdx`` runtime classes are used to deploy Confidential Containers workloads.


.. _coco-install-gpu-operator:

Install the NVIDIA GPU Operator
--------------------------------

Configure the GPU Operator to deploy Confidential Container components.

#. Add and update the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
         && helm repo update

#. Install the GPU Operator.
   The following configures the GPU Operator to deploy the operands that are required for Confidential Containers.


   .. code-block:: console

      $ helm install --wait --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --set sandboxWorkloads.enabled=true \
         --set sandboxWorkloads.mode=kata \
         --set nfd.enabled=true \
         --set nfd.nodefeaturerules=true \
         --version=v26.3.0

   .. tip::

      Add ``--set sandboxWorkloads.defaultWorkload=vm-passthrough`` if every worker node should deploy Confidential Containers by default.

   Refer to the :ref:`Confidential Containers Configuration Settings <coco-configuration-settings>` section on this page for more details on the Confidential Containers configuration options you can specify when installing the GPU Operator.

   Refer to the :ref:`Common chart customization options <gpuop:gpu-operator-helm-chart-options>` in :doc:`Installing the NVIDIA GPU Operator <gpuop:getting-started>` for more details on the additional general configuration options you can specify when installing the GPU Operator.

   *Example Output*

   .. code-block:: output

      NAME: gpu-operator
      LAST DEPLOYED: Tue Mar 10 17:58:12 2026
      NAMESPACE: gpu-operator
      STATUS: deployed
      REVISION: 1
      TEST SUITE: None

#. Verify that all GPU Operator pods, especially the Confidential Computing Manager, Sandbox Device Plugin and VFIO Manager operands, are running:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator

   *Example Output*:

   .. code-block:: output

      NAME                                                              READY   STATUS    RESTARTS   AGE
      gpu-operator-1766001809-node-feature-discovery-gc-75776475sxzkp   1/1     Running   0          86s
      gpu-operator-1766001809-node-feature-discovery-master-6869lxq2g   1/1     Running   0          86s
      gpu-operator-1766001809-node-feature-discovery-worker-mh4cv       1/1     Running   0          86s
      gpu-operator-f48fd66b-vtfrl                                       1/1     Running   0          86s
      nvidia-cc-manager-7z74t                                           1/1     Running   0          61s
      nvidia-kata-sandbox-device-plugin-daemonset-d5rvg                      1/1     Running   0          30s
      nvidia-sandbox-validator-6xnzc                                    1/1     Running   1          30s
      nvidia-vfio-manager-h229x                                         1/1     Running   0          62s


#. Optional: If you have host access to the worker node, you can perform the following validation steps:

   a. Confirm that the host uses the vfio-pci device driver for GPUs::

         $ lspci -nnk -d 10de:

      *Example Output*:

      .. code-block:: output

         65:00.0 3D controller [0302]: NVIDIA Corporation xxxxxxx [xxx] [10de:xxxx] (rev xx)
                 Subsystem: NVIDIA Corporation xxxxxxx [xxx] [10de:xxxx]
                 Kernel driver in use: vfio-pci
                 Kernel modules: nvidiafb, nouveau


.. _coco-configuration-settings:

Confidential Containers Configuration Settings
----------------------------------------------

The following are the available GPU Operator configuration settings to enable Confidential Containers:

.. list-table::
   :widths: 20 50 30
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``sandboxWorkloads.enabled``
     - Enables sandbox workload management in the GPU Operator for virtual
       machine-style workloads and related operands.
     - ``false``

   * - ``sandboxWorkloads.defaultWorkload``
     - Specifies the default type of workload for the cluster, one of ``container``, ``vm-passthrough``, or ``vm-vgpu``.

       Setting ``vm-passthrough`` or ``vm-vgpu`` can be helpful if you plan to run all or mostly virtual machines in your cluster.
     - ``container``
  
   * - ``sandboxWorkloads.mode``
     - Specifies the sandbox mode to use when deploying sandbox workloads.
       Accepted values are ``kubevirt`` (default) and ``kata``.
     - ``kubevirt``

   * - ``sandboxDevicePlugin.env``
     - Optional list of environment variables passed to the NVIDIA Sandbox
       Device Plugin pod. Each list item is an ``EnvVar`` object with required
       ``name`` and optional ``value`` fields.
     - ``[]`` (empty list)

.. _coco-configuration-heterogeneous-clusters:

Configuration for Heterogeneous Clusters
----------------------------------------

For heterogeneous clusters with different GPU types, you can specify an empty
``P_GPU_ALIAS`` environment variable for the sandbox device plugin by including
the following in your GPU Operator installation:
``--set sandboxDevicePlugin.env[0].name=P_GPU_ALIAS`` and
``--set sandboxDevicePlugin.env[0].value=""``.

This causes the sandbox device plugin to create GPU model-specific resource
types, for example ``nvidia.com/GH100_H100L_94GB``. This is used instead of the
default ``pgpu`` type, which usually results in advertising a resource of type
``nvidia.com/pgpu``.
Use the exposed device resource types in pod specs by specifying respective resource limits.

Similarly, NVSwitches are exposed as resources of type
``nvidia.com/nvswitch`` by default. You can use the ``NVSWITCH_ALIAS``
environment variable to configure advertising behavior similar to
``P_GPU_ALIAS``.

.. _coco-run-sample-workload:

Run a Sample Workload
=====================

A pod manifest for a confidential container GPU workload requires the following:

1. Create a file, such as the following cuda-vectoradd-kata.yaml sample, specifying the kata-qemu-nvidia-gpu-snp runtime class:

   .. code-block:: yaml

      apiVersion: v1
      kind: Pod
      metadata:
        name: cuda-vectoradd-kata
        namespace: default
        annotations:
          io.katacontainers.config.hypervisor.kernel_params: "nvrc.smi.srs=1"
      spec:
        runtimeClassName: kata-qemu-nvidia-gpu-snp
        restartPolicy: Never
        containers:
          - name: cuda-vectoradd
            image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0-ubuntu22.04"
            resources:
              limits:
                nvidia.com/pgpu: "1"
                memory: 16Gi

   Use the runtime class to specify that your workload should run in a
   Confidential Container.
   Specify either the ``kata-qemu-nvidia-gpu-snp`` for SEV-SNP or ``kata-qemu-nvidia-gpu-tdx`` for TDX, depending on your available nodes.
   Refer to the :doc:`Supported Platforms <supported-platforms>` page for more information on the supported platforms.

   In the sample above ``nvidia.com/pgpu`` is the default resource type for GPUs.
   If you are deploying on a heterogeneous cluster, you may want to update the default behavior by specifying the ``P_GPU_ALIAS`` environment variable for the sandbox device plugin.
   Refer to the :ref:`Configuration for Heterogeneous Clusters <coco-configuration-heterogeneous-clusters>` section on this page for more details.

2. Create the pod:

   .. code-block:: console

      $ kubectl apply -f cuda-vectoradd-kata.yaml

3. View the logs from pod after the container was started:

   .. code-block:: console

      $ kubectl logs -n default cuda-vectoradd-kata

   *Example Output*

   .. code-block:: output

      [Vector addition of 50000 elements]
      Copy input data from the host memory to the CUDA device
      CUDA kernel launch with 196 blocks of 256 threads
      Copy output data from the CUDA device to the host memory
      Test PASSED
      Done

4. Delete the pod:

   .. code-block:: console

      $ kubectl delete -f cuda-vectoradd-kata.yaml

.. _managing-confidential-computing-mode:

Managing the Confidential Computing Mode
=========================================

You can set the default confidential computing mode of the NVIDIA GPUs by setting the ``ccManager.defaultMode=<on|off|ppcie|devtools>`` option. 
The default value of ccManager.defaultMode is ``on``. 
You can set this option when you install NVIDIA GPU Operator or afterward by modifying the cluster-policy instance of the ClusterPolicy object.

When you change the mode, the manager performs the following actions:

* Evicts the other GPU Operator operands from the node.

  However, the manager does not drain user workloads. You must make sure that no user workloads are running on the node before you change the mode.

* Unbinds the GPU from the VFIO PCI device driver.
* Changes the mode and resets the GPU.
* Reschedules the other GPU Operator operands.

The supported modes are:

* ``on`` -- Enable Confidential Containers.
* ``off`` -- Disable Confidential Containers.
* ``ppcie`` -- Enable Confidential Containers with multi-node passthrough on HGX or DGX GPUs. 
  On the NVIDIA Hopper architecture multi-GPU passthrough uses protected PCIe (PPCIE) which claims exclusive use of the nvswitches for a single CVM. In this case, transition your relevant node(s) GPU mode to ``ppcie`` mode. The NVIDIA Blackwell architecture uses NVLink encryption which places the switches outside of the Trusted Computing Base (TCB) and so does not require a separate switch setting.
* ``devtools`` -- Development mode for software development and debugging.

You can set a cluster-wide default mode and you can set the mode on individual nodes. 
The mode that you set on a node has higher precedence than the cluster-wide default mode.

Setting a Cluster-Wide Default Mode
------------------------------------

To set a cluster-wide mode, specify the ccManager.defaultMode field like the following example::

   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
         --type=merge \
         -p '{"spec": {"ccManager": {"defaultMode": "on"}}}'

Setting a Node-Level Mode
--------------------------

To set a node-level mode, apply the ``nvidia.com/cc.mode=<on|off|ppcie|devtools>`` label like the following example::

   $ kubectl label node <node-name> nvidia.com/cc.mode=on --overwrite

The mode that you set on a node has higher precedence than the cluster-wide default mode.

Verifying a Mode Change
------------------------

To verify that changing the mode was successful, a cluster-wide or node-level change, view the nvidia.com/cc.mode and nvidia.com/cc.mode.state node labels::

   $ kubectl get node <node-name> -o json | \
       jq '.metadata.labels | with_entries(select(.key | startswith("nvidia.com/cc.mode")))'

Example output when CC mode is disabled:

.. code-block:: json

   {
     "nvidia.com/cc.mode": "off",
     "nvidia.com/cc.mode.state": "on"
   }

Example output when CC mode is enabled:

.. code-block:: json

   {
     "nvidia.com/cc.mode": "on",
     "nvidia.com/cc.mode.state": "on"
   }

The "nvidia.com/cc.mode.state" variable is either "off" or "on", with "off" meaning that mode state transition is still ongoing and "on" meaning mode state transition completed.

.. _additional-resources:


Next Steps
==========

* Refer to the :doc:`Attestation <attestation>` page for more information on configuringattestation.
* Additional NVIDIA Confidential Computing documentation is available at https://docs.nvidia.com/confidential-computing.
* Licensing information is available on the :doc:`Licensing <licensing>` page.