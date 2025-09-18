.. Date: Jun 22 2022
.. Author: cdesiniotis

.. headings (h1/h2/h3/h4/h5/h6) are # * = - ^ "

.. _gpu-operator-kubevirt:

GPU Operator with KubeVirt
**************************

.. _gpu-operator-kubevirt-introduction:

About the Operator with KubeVirt
================================

`KubeVirt <https://kubevirt.io/>`_ is a virtual machine management add-on to Kubernetes that allows you to run and manage virtual machines in a Kubernetes cluster. 
It eliminates the need to manage separate clusters for virtual machine and container workloads because both can now coexist in a single Kubernetes cluster.

In addition to the GPU Operator being able to provision worker nodes for running GPU-accelerated containers, the GPU Operator can also be used to provision worker nodes for running GPU-accelerated virtual machines with KubeVirt.

There are some different prerequisites required when running virtual machines with GPUs compared to running containers with GPUs.
The primary difference is the drivers required. 
For example, the datacenter driver is needed for containers, the vfio-pci driver is needed for GPU passthrough, and the `NVIDIA vGPU Manager <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#installing-configuring-grid-vgpu>`_ is needed for creating vGPU devices.

.. _configure-worker-nodes-for-gpu-operator-components:

Configure Worker Nodes for GPU Operator components
---------------------------------------------------

The GPU Operator can now be configured to deploy different software components on worker nodes depending on what GPU workload is configured to run on those nodes.
This is configured by adding a ``nvidia.com/gpu.workload.config`` label to the worker node with the value of ``container``, ``vm-passthrough``, or ``vm-vgpu`` depending on if you are planning to use vGPU or not.
The GPU Operator will use the label to determine which software components to deploy on the worker nodes.

Given the following node configuration:

* Node A is configured with the label ``nvidia.com/gpu.workload.config=container`` and configured to run containers.
* Node B is configured with the label ``nvidia.com/gpu.workload.config=vm-passthrough`` and configured to run virtual machines with Passthrough GPU.
* Node C is configured with the label ``nvidia.com/gpu.workload.config=vm-vgpu`` and configured to run virtual machines with vGPU.

The GPU Operator will deploy the following software components on each node:

* Node A receives the following software components:
   * ``NVIDIA Datacenter Driver`` - to install the driver
   * ``NVIDIA Container Toolkit`` - to ensure containers can properly access GPUs
   * ``NVIDIA Kubernetes Device Plugin`` - to discover and advertise GPU resources to kubelet
   * ``NVIDIA DCGM and DCGM Exporter`` - to monitor the GPU(s)

* Node B receives the following software components:
   * ``VFIO Manager`` - to load `vfio-pci` and bind it to all GPUs on the node
   * ``Sandbox Device Plugin`` - to discover and advertise the passthrough GPUs to kubelet

* Node C receives the following software components:
   * ``NVIDIA vGPU Manager`` - to install the driver
   * ``NVIDIA vGPU Device Manager`` - to create vGPU devices on the node
   * ``Sandbox Device Plugin`` - to discover and advertise the vGPU devices to kubelet

If the node label ``nvidia.com/gpu.workload.config`` does not exist on the node, the GPU Operator will assume the default GPU workload configuration, ``container``, and will deploy the software components needed to support this workload type.
To override the default GPU workload configuration, set the following value in ``ClusterPolicy``: ``sandboxWorkloads.defaultWorkload=<config>``.

.. _gpu-operator-kubevirt-limitations:

Assumptions, constraints, and dependencies
------------------------------------------

* A GPU worker node can run GPU workloads of a particular type, such as containers, virtual machines with GPU Passthrough, or virtual machines with vGPU, but not a combination of any of them.

* The cluster admin or developer has knowledge about their cluster ahead of time and can properly label nodes to indicate what types of GPU workloads they will run.

* Worker nodes running GPU accelerated virtual machines (with GPU passthrough or vGPU) are assumed to be bare metal.

* The GPU Operator will not automate the installation of NVIDIA drivers inside KubeVirt virtual machines with GPUs/vGPUs attached.

* Users must manually add all passthrough GPU and vGPU resources to the ``permittedDevices`` list in the KubeVirt CR before assigning them to KubeVirt virtual machines. Refer to the `KubeVirt documentation <https://kubevirt.io/user-guide/virtual_machines/host-devices/#listing-permitted-devices>`_ for more information.

* MIG-backed vGPUs are not supported.

Prerequisites
=============

Before using KubeVirt with the GPU Operator, ensure the following prerequisites are configured on your cluster and nodes:

* The virtualization and IOMMU extensions (Intel VT-d or AMD IOMMU) are enabled in the BIOS.

* The host is booted with ``intel_iommu=on`` or ``amd_iommu=on`` on the kernel command line.

* If planning to use NVIDIA vGPU, SR-IOV must be enabled in the BIOS if your GPUs are based on the NVIDIA Ampere architecture or later. Refer to the `NVIDIA vGPU Documentation <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#prereqs-vgpu>`_ to ensure you have met all the prerequisites for using NVIDIA vGPU.

* KubeVirt is installed in the cluster.

* Starting with KubeVirt v0.58.2 and v0.59.1, set the ``DisableMDEVConfiguration`` feature gate:

  .. code-block:: console

     $ kubectl patch kubevirt -n kubevirt kubevirt  --type='json' \
         -p='[{"op": "add", "path": "/spec/configuration/developerConfiguration/featureGates/-", "value": "DisableMDEVConfiguration" }]'

  *Example Output*

  .. code-block:: output

     kubevirt.kubevirt.io/kubevirt patched


Configure KubeVirt with the GPU Operator
========================================

After configuring the :ref:`prerequisites<prerequisites>`, the high level workflow for using the GPU Operator with KubeVirt is as follows:

* :ref:`Label worker nodes <label-worker-nodes>` based on the GPU workloads they will run.
* :ref:`Install the GPU Operator <install-the-gpu-operator>` and set ``sandboxWorkloads.enabled=true``

If you are planning to deploy VMs with vGPU, the workflow is as follows:

* :ref:`Build the NVIDIA vGPU Manager image <build-vgpu-manager-image>`
* :ref:`Label the node for the vGPU configuration <vgpu-device-configuration>`
* :ref:`Add vGPU resources to KubeVirt CR <add-vgpu-resources-to-kubevirt-cr>`
* :ref:`Create a virtual machine with vGPU <create-a-virtual-machine-with-gpu>`

If you are planning to deploy VMs with GPU passthrough, the workflow is as follows:

* :ref:`Add GPU passthrough resources to KubeVirt CR <add-gpu-passthrough-resources-to-kubevirt-cr>`
* :ref:`Create a virtual machine with GPU passthrough <create-a-virtual-machine-with-gpu>`

.. _label-worker-nodes:

Label worker nodes
----------------------

The GPU Operator uses the value of the ``nvidia.com/gpu.workload.config`` label to determine which operands to deploy on your worker node.

#. Add a ``nvidia.com/gpu.workload.config`` label to a worker node:

   .. code-block:: console

      $ kubectl label node <node-name> --overwrite nvidia.com/gpu.workload.config=vm-vgpu


   You can assign the following values to the label:

   * ``container``
   * ``vm-passthrough``
   * ``vm-vgpu``

   Refer to the :ref:`Configure Worker Nodes for GPU Operator components<configure-worker-nodes-for-gpu-operator-components>` section for more information on the different configurations options.

.. _install-the-gpu-operator:

Install the GPU Operator
---------------------------

Follow one of the below subsections for installing the GPU Operator, depending on whether you plan to use NVIDIA vGPU or not.

.. note::

   The following commands set the ``sandboxWorkloads.enabled`` flag. 
   This ``ClusterPolicy`` flag controls whether the GPU Operator can provision GPU worker nodes for virtual machine workloads, in addition to container workloads. 
   This flag is disabled by default, meaning all nodes get provisioned with the same software to enable container workloads, and the ``nvidia.com/gpu.workload.config`` node label is not used. 

   The term *sandboxing* refers to running software in a separate isolated environment, typically for added security (that is, a virtual machine). 
   We use the term ``sandbox workloads`` to signify workloads that run in a virtual machine, irrespective of the virtualization technology used.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Install the GPU Operator without NVIDIA vGPU
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Install the GPU Operator, enabling ``sandboxWorkloads``:

.. code-block:: console

   $ helm install --wait --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --version=${version} \
         --set sandboxWorkloads.enabled=true

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Install the GPU Operator with NVIDIA vGPU
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Before installing the GPU Operator with NVIDIA vGPU, you must build a private NVIDIA vGPU Manager container image and push to a private registry.
Follow the steps provided in :ref:`this section<build-vgpu-manager-image>`.

#. Create a namespace for GPU Operator:

   .. code-block:: console

      $ kubectl create namespace gpu-operator

#. Create an ImagePullSecret for accessing the NVIDIA vGPU Manager image:

   .. code-block:: console

      $ kubectl create secret docker-registry ${REGISTRY_SECRET_NAME} \
         --docker-server=${PRIVATE_REGISTRY} --docker-username=<username> \
         --docker-password=<password> \
         --docker-email=<email-id> -n gpu-operator

#. Install the GPU Operator with ``sandboxWorkloads`` and ``vgpuManager`` enabled and specify the NVIDIA vGPU Manager image built previously:

   .. code-block:: console

      $ helm install --wait --generate-name \
            -n gpu-operator --create-namespace \
            nvidia/gpu-operator \
            --version=${version} \
            --set sandboxWorkloads.enabled=true \
            --set vgpuManager.enabled=true \
            --set vgpuManager.repository=<path to private repository> \
            --set vgpuManager.image=vgpu-manager \
            --set vgpuManager.version=<driver version> \
            --set vgpuManager.imagePullSecrets={${REGISTRY_SECRET_NAME}}

The vGPU Device Manager, deployed by the GPU Operator, automatically creates vGPU devices that can be assigned to KubeVirt virtual machines.
Without additional configuration, the GPU Operator creates a default set of devices on all GPUs.
To learn more about the vGPU Device Manager and configure which types of vGPU devices get created in your cluster, refer to :ref:`vGPU Device Configuration<vgpu-device-configuration>`.

Add GPU resources to KubeVirt CR
-------------------------------------
Follow one of the below subsections for adding GPU resources to the KubeVirt CR, depending on whether you plan to use NVIDIA vGPU or not.

.. _add-vgpu-resources-to-kubevirt-cr:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Add vGPU resources to KubeVirt CR
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Update the KubeVirt custom resource so that all vGPU devices in your cluster are permitted and can be assigned to virtual machines.

The following example shows how to permit the A10-12Q vGPU device, the device names for the GPUs on your cluster will likely be different.

#. Determine the resource names for the GPU devices:

   .. code-block:: console

      $ kubectl get node cnt-server-2 -o json | jq '.status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'

   *Example Output*

   .. code-block:: output

      {
        "nvidia.com/NVIDIA_A10-12Q": "4"
      }

#. Determine the PCI device IDs for the GPUs.

   * You can search by device name in the `PCI IDs database <https://pci-ids.ucw.cz/v2.2/pci.ids>`_.

   * If you have host access to the node, you can list the NVIDIA GPU devices with a command like the following example:

     .. code-block:: console

        $ lspci -nnk -d 10de:

     *Example Output*

     .. code-block:: output
        :emphasize-lines: 1

        65:00.0 3D controller [0302]: NVIDIA Corporation GA102GL [A10] [10de:2236] (rev a1)
                Subsystem: NVIDIA Corporation GA102GL [A10] [10de:1482]
                Kernel modules: nvidiafb, nouveau

#. Modify the ``KubeVirt`` custom resource like the following partial example. 

   .. code-block:: yaml

      ...
      spec:
        configuration:
          developerConfiguration:
            featureGates:
            - GPU
            - DisableMDEVConfiguration
          permittedHostDevices: # Defines VM devices to import.
            mediatedDevices: # Include for vGPU 
            - externalResourceProvider: true
              mdevNameSelector: NVIDIA A10-12Q
              resourceName: nvidia.com/NVIDIA_A10-12Q
      ...

   Replace the values in the YAML as follows:

   * ``mdevNameSelector`` and ``resourceName`` under ``mediatedDevices`` to correspond to your vGPU type.

   * Set ``externalResourceProvider=true`` to indicate that this resource is provided by an external device plugin, in this case the ``sandbox-device-plugin`` that is deployed by the GPU Operator.

Refer to the `KubeVirt user guide <https://kubevirt.io/user-guide/virtual_machines/host-devices/#listing-permitted-devices>`_ for more information on the configuration options.

.. _add-gpu-passthrough-resources-to-kubevirt-cr:

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Add GPU passthrough resources to KubeVirt CR
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Update the KubeVirt custom resource so that all GPU passthrough devices in your cluster are permitted and can be assigned to virtual machines.

The following example shows how to permit the A10 GPU device, the device names for the GPUs on your cluster will likely be different.

#. Determine the resource names for the GPU devices:

   .. code-block:: console

      $ kubectl get node cnt-server-2 -o json | jq '.status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'

   *Example Output*

   .. code-block:: output

      {
         "nvidia.com/GA102GL_A10": "1"
      }

#. Determine the PCI device IDs for the GPUs.

   * You can search by device name in the `PCI IDs database <https://pci-ids.ucw.cz/v2.2/pci.ids>`_.

   * If you have host access to the node, you can list the NVIDIA GPU devices with a command like the following example:

     .. code-block:: console

        $ lspci -nnk -d 10de:

     *Example Output*

     .. code-block:: output
        :emphasize-lines: 1

        65:00.0 3D controller [0302]: NVIDIA Corporation GA102GL [A10] [10de:2236] (rev a1)
                Subsystem: NVIDIA Corporation GA102GL [A10] [10de:1482]
                Kernel modules: nvidiafb, nouveau

#. Modify the ``KubeVirt`` custom resource like the following partial example. 

   .. code-block:: yaml

      ...
      spec:
        configuration:
          developerConfiguration:
            featureGates:
            - GPU
            - DisableMDEVConfiguration
          permittedHostDevices: # Defines VM devices to import.
            pciHostDevices: # Include for GPU passthrough
            - externalResourceProvider: true
              pciVendorSelector: 10DE:2236
              resourceName: nvidia.com/GA102GL_A10
      ...

   Replace the values in the YAML as follows:

   * ``pciVendorSelector`` and ``resourceName`` under ``pciHostDevices`` to correspond to your GPU model.

   * Set ``externalResourceProvider=true`` to indicate that this resource is provided by an external device plugin, in this case the ``sandbox-device-plugin`` that is deployed by the GPU Operator.

Refer to the `KubeVirt user guide <https://kubevirt.io/user-guide/virtual_machines/host-devices/#listing-permitted-devices>`_ for more information on the configuration options.


.. _create-a-virtual-machine-with-gpu:

Create a virtual machine with GPU
------------------------------------

After the ``sandbox-device-plugin`` pod is running on your worker nodes and the GPU resources have been added to the
KubeVirt allowlist, you can assign a GPU to a virtual machine by editing the ``spec.domain.devices.gpus`` field
in the ``VirtualMachineInstance`` manifest.

Example for GPU passthrough:

.. code-block:: yaml

   apiVersion: kubevirt.io/v1alpha3
   kind: VirtualMachineInstance
   ...
   spec:
     domain:
       devices:
         gpus:
         - deviceName: nvidia.com/GA102GL_A10
           name: gpu1
   ...

Example for vGPU:

.. code-block:: yaml

   apiVersion: kubevirt.io/v1alpha3
   kind: VirtualMachineInstance
   ...
   spec:
     domain:
       devices:
         gpus:
         - deviceName: nvidia.com/NVIDIA_A10-12Q
           name: gpu1
   ...

* ``deviceName`` is the resource name representing the device.

* ``name`` is a name to identify the device in the virtual machine

.. _vgpu-device-configuration:

vGPU Device Configuration
=========================

The vGPU Device Manager assists in creating vGPU devices on GPU worker nodes.
The vGPU Device Manager allows administrators to declaratively define a set of possible vGPU device configurations they would like applied to GPUs on a node.
At runtime, adminstrators then point the vGPU Device Manager at one of these configurations, and vGPU Device Manager takes care of applying it.

The configuration file is created as a ConfigMap, and is shared across all worker nodes.
At runtime, a node label, ``nvidia.com/vgpu.config``, can be used to decide which of these configurations to actually apply to a node at any given time.
If the node is not labeled, then the ``default`` configuration will be used.
For more information on this component and how it is configured, refer to the `NVIDIA vGPU Device Manager README <https://github.com/NVIDIA/vgpu-device-manager>`_.

By default, the GPU Operator deploys a ConfigMap for the vGPU Device Manager, containing named configurations for all `vGPU types supported by NVIDIA vGPU <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#supported-gpus-grid-vgpu>`_.
Users can select a specific configuration for a worker node by applying the ``nvidia.com/vgpu.config`` node label.
For example, labeling a node with ``nvidia.com/vgpu.config=A10-8Q`` would create three vGPU devices of type **A10-8Q** on all **A10** GPUs on the node. Note that three is the maximum number of **A10-8Q** devices that can be created per GPU.
If the node is not labeled, the ``default`` configuration will be applied.
The ``default`` configuration will create Q-series vGPU devices on all GPUs, where the amount of framebuffer memory per vGPU device is half the total GPU memory.
For example, the ``default`` configuration will create two **A10-12Q** devices on all **A10** GPUs, two **V100-8Q** devices on all **V100** GPUs, and two **T4-8Q** devices on all **T4** GPUs.

You can also create different vGPU Q profiles on the same GPU using vGPU Device Manager configuration.
For example, you can create a **A10-4Q** and a **A10-6Q** device on same GPU by creating a vGPU Device Manager configuration with the following content:

.. code-block:: yaml

    version: v1
    vgpu-configs:
      custom-A10-config:
        - devices: all
           vgpu-devices:
             "A10-4Q": 3
             "A10-6Q": 2

If custom vGPU device configuration is desired, more than the default config map provides, you can create your own config map:

.. code-block:: console

    $ kubectl create configmap custom-vgpu-config -n gpu-operator --from-file=config.yaml=/path/to/file

And then configure the GPU Operator to use it by setting ``vgpuDeviceManager.config.name=custom-vgpu-config``.


Apply a New vGPU Device Configuration
--------------------------------------

You can apply a specific vGPU device configuration on a per-node basis by setting the ``nvidia.com/vgpu.config`` node label. 
It is recommended to set this node label prior to installing the GPU Operator if you do not want the default configuration applied.

Switching vGPU device configuration after one has been successfully applied assumes that no virtual machines with vGPU are currently running on the node. 
Any existing virtual machines should be shutdown/migrated before you apply the new configuration.

To apply a new configuration after GPU Operator install, update the ``nvidia.com/vgpu.config`` node label. 

The following example shows how to apply a new configuration on a system with two **A10** GPUs.

.. code-block:: console

   $ nvidia-smi -L
   GPU 0: NVIDIA A10 (UUID: GPU-ebd34bdf-1083-eaac-2aff-4b71a022f9bd)
   GPU 1: NVIDIA A10 (UUID: GPU-1795e88b-3395-b27b-dad8-0488474eec0c)

In this example, the GPU Operator has been installed and the ``nvidia.com/vgpu.config`` was not added to worker nodes, meaning the ``default`` vGPU config got applied. 
This resulted in the creation of four **A10-12Q** devices (two per GPU):

.. code-block:: console

   $ kubectl get node cnt-server-2 -o json | jq '.status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'
   {
     "nvidia.com/NVIDIA_A10-12Q": "4"
   }

Now if you wanted to create **A10-4Q** devices, add the ``nvidia.com/vgpu.config`` label to the node:

.. code-block:: console

   $ kubectl label node <node-name> --overwrite nvidia.com/vgpu.config=A10-4Q

After the vGPU Device Manager finishes applying the new configuration, all GPU Operator pods should return to the Running state.

.. code-block:: console

   $ kubectl get pods -n gpu-operator
   NAME                                                          READY   STATUS    RESTARTS   AGE
   ...
   nvidia-sandbox-device-plugin-daemonset-brtb6                  1/1     Running   0          10s
   nvidia-sandbox-validator-ljnwg                                1/1     Running   0          10s
   nvidia-vgpu-device-manager-8mgg8                              1/1     Running   0          30m
   nvidia-vgpu-manager-daemonset-fpplc                           1/1     Running   0          31m

You can now see 12 **A10-4Q** devices on the node, as six **A10-4Q** devices can be created per **A10** GPU.

.. code-block:: console

   $ kubectl get node cnt-server-2 -o json | jq '.status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'
   {
     "nvidia.com/NVIDIA_A10-4Q": "12"
   }


.. _build-vgpu-manager-image:

Building the NVIDIA vGPU Manager image
======================================

.. note::

   Building the NVIDIA vGPU Manager image is only required if you are planning to use NVIDIA vGPU.
   If only planning to use PCI passthrough, skip this section.

This section covers building the NVIDIA vGPU Manager container image and pushing it to a private registry.

Download the vGPU Software from the `NVIDIA Licensing Portal <https://nvid.nvidia.com/dashboard/#/dashboard>`_.

* Login to the NVIDIA Licensing Portal and navigate to the **Software Downloads** section.
* The NVIDIA vGPU Software is located in the **Software Downloads** section of the NVIDIA Licensing Portal.
* The vGPU Software bundle is packaged as a zip file. Download and unzip the bundle to obtain the NVIDIA vGPU Manager for Linux file, ``NVIDIA-Linux-x86_64-<version>-vgpu-kvm.run``.

  .. start-nvaie-run-file

  .. note::

     NVIDIA AI Enterprise customers must use the ``aie`` .run file for building the NVIDIA vGPU Manager image.
     Download the ``NVIDIA-Linux-x86_64-<version>-vgpu-kvm-aie.run`` file instead, and rename it to
     ``NVIDIA-Linux-x86_64-<version>-vgpu-kvm.run`` before proceeding with the rest of the procedure.
     Refer to the **Infrastructure Support Matrix** section under the `NVIDIA AI Enterprise Infrastructure Release Branches <https://docs.nvidia.com/ai-enterprise/index.html#infrastructure-software>`_ for details on supported version number to use. 
  .. end-nvaie-run-file

Next, clone the driver container repository and build the driver image with the following steps.

Open a terminal and clone the driver container image repository.

.. code-block:: console

   $ git clone https://gitlab.com/nvidia/container-images/driver
   $ cd driver

Change to the vgpu-manager directory for your OS. We use Ubuntu 20.04 as an example.

.. code-block:: console

   $ cd vgpu-manager/ubuntu20.04

.. note::

   For Red Hat OpenShift, run ``cd vgpu-manager/rhel8`` to use the ``rhel8`` folder instead.

Copy the NVIDIA vGPU Manager from your extracted zip file

.. code-block:: console

   $ cp <local-driver-download-directory>/*-vgpu-kvm.run ./

| Set the following environment variables:
| ``PRIVATE_REGISTRY`` - name of private registry used to store driver image
| ``VERSION`` - NVIDIA vGPU Manager version downloaded from NVIDIA Software Portal
| ``OS_TAG`` - this must match the Guest OS version. In the following example ``ubuntu20.04`` is used. For Red Hat OpenShift this should be set to ``rhcos4.x`` where x is the supported minor OCP version.
| ``CUDA_VERSION`` - CUDA base image version to build the driver image with.

.. code-block:: console

   $ export PRIVATE_REGISTRY=my/private/registry VERSION=510.73.06 OS_TAG=ubuntu20.04 CUDA_VERSION=11.7.1

Build the NVIDIA vGPU Manager image.

.. code-block:: console

   $ docker build \
       --build-arg DRIVER_VERSION=${VERSION} \
       --build-arg CUDA_VERSION=${CUDA_VERSION} \
       -t ${PRIVATE_REGISTRY}/vgpu-manager:${VERSION}-${OS_TAG} .

Push NVIDIA vGPU Manager image to your private registry.

.. code-block:: console

   $ docker push ${PRIVATE_REGISTRY}/vgpu-manager:${VERSION}-${OS_TAG}
