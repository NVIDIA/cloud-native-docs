.. Date: Jun 22 2022
.. Author: cdesiniotis

.. headings (h1/h2/h3/h4/h5/h6) are # * = - ^ "

.. _gpu-operator-kubevirt-22.9.2:

GPU Operator with KubeVirt
**************************

.. _gpu-operator-kubevirt-22.9.2-introduction:

Introduction
============

`KubeVirt <https://kubevirt.io/>`_ is a virtual machine management add-on to Kubernetes that allows you to run and manage virtual machines in a Kubernetes cluster. It eliminates the need to manage separate clusters for virtual machine and container workloads, as both can now coexist in a single Kubernetes cluster.

Up until this point, the GPU Operator only provisioned worker nodes for running GPU-accelerated containers. Now, the GPU Operator can also be used to provision worker nodes for running GPU-accelerated virtual machines.

The prerequisites needed for running containers and virtual machines with GPU(s) differs, with the primary difference being the drivers required. For example, the datacenter driver is needed for containers, the vfio-pci driver is needed for GPU passthrough, and the `NVIDIA vGPU Manager <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#installing-configuring-grid-vgpu>`_ is needed for creating vGPU devices.

The GPU Operator can now be configured to deploy different software components on worker nodes depending on what GPU workload is configured to run on those nodes. Consider the following example.

| Node A is configured to run containers.
| Node B is configured to run virtual machines with Passthrough GPU.
| Node C is configured to run virtual machines with vGPU.

Node A receives the following software components:

* ``NVIDIA Datacenter Driver`` - to install the driver
* ``NVIDIA Container Toolkit`` - to ensure containers can properly access GPUs
* ``NVIDIA Kubernetes Device Plugin`` - to discover and advertise GPU resources to kubelet
* ``NVIDIA DCGM and DCGM Exporter`` - to monitor the GPU(s)

Node B receives the following software components:

* ``VFIO Manager`` - to load `vfio-pci` and bind it to all GPUs on the node
* ``Sandbox Device Plugin`` - to discover and advertise the passthrough GPUs to kubelet

Node C receives the following software components:

* ``NVIDIA vGPU Manager`` - to install the driver
* ``NVIDIA vGPU Device Manager`` - to create vGPU devices on the node
* ``Sandbox Device Plugin`` - to discover and advertise the vGPU devices to kubelet

.. _gpu-operator-kubevirt-22.9.2-limitations:

Assumptions, constraints, and dependencies
==========================================

* A GPU worker node can run GPU workloads of a particular type - containers, virtual machines with GPU Passthrough, or virtual machines with vGPU - but not a combination of any of them.

* The cluster admin or developer has knowledge about their cluster ahead of time, and can properly label nodes to indicate what types of GPU workloads they will run.

* Worker nodes running GPU accelerated virtual machines (with pGPU or vGPU) are assumed to be bare metal.

* The GPU Operator will not automate the installation of NVIDIA drivers inside KubeVirt virtual machines with GPUs/vGPUs attached.

* Users must manually add all passthrough GPU and vGPU resources to the ``permittedDevices`` list in the KubeVirt CR before assigning them to KubeVirt virtual machines. See the `KubeVirt documentation <https://kubevirt.io/user-guide/virtual_machines/host-devices/#listing-permitted-devices>`_ for more information.

* MIG-backed vGPUs are not supported.


Prerequisites
=============

* The virtualization and IOMMU extensions (Intel VT-d or AMD IOMMU) are enabled in the BIOS.

* The host is booted with ``intel_iommu=on`` or ``amd_iommu=on`` on the kernel command line.

* If planning to use NVIDIA vGPU, SR-IOV must be enabled in the BIOS if your GPUs are based on the NVIDIA Ampere architecture or later. Refer to the `NVIDIA vGPU Documentation <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#prereqs-vgpu>`_ to ensure you have met all of the prerequisites for using NVIDIA vGPU.

* KubeVirt is installed in the cluster.


Getting Started
===============

The high-level workflow for using the GPU Operator with KubeVirt is as follows:

1. Label worker nodes based on the GPU workloads they will run.
2. Install the GPU Operator and set ``sandboxWorkloads.enabled=true``

There are additional steps required if using NVIDIA vGPU, which will be covered in subsequent sections

Labeling worker nodes
---------------------

Use the following command to add a label to a worker node:

.. code-block:: console

   $ kubectl label node <node-name> --overwrite nvidia.com/gpu.workload.config=vm-vgpu

You can assign the following values to the label - ``container``, ``vm-passthrough``, and ``vm-vgpu``. The GPU Operator uses the value of this label when determining which operands to deploy on each worker node.

If the node label ``nvidia.com/gpu.workload.config`` does not exist on the node, the GPU Operator will assume the default GPU workload configuration, ``container``, and will deploy the software components needed to support this workload type.
To override the default GPU workload configuration, set the following value in ``ClusterPolicy``: ``sandboxWorkloads.defaultWorkload=<config>``.

Install the GPU Operator
------------------------

Follow one of the below subsections for installing the GPU Operator, depending on whether you plan to use NVIDIA vGPU or not.

In general, the flag ``sandboxWorkloads.enabled`` in ``ClusterPolicy`` controls whether the GPU Operator can provision GPU worker nodes
for virtual machine workloads, in addition to container workloads. This flag is disabled by default, meaning all nodes get provisioned with the same
software which enable container workloads, and the ``nvidia.com/gpu.workload.config`` node label is not used.

.. note::

   The term ``sandboxing`` refers to running software in a separate isolated environment, typically for added security (i.e. a virtual machine). We use the term ``sandbox workloads`` to signify workloads that run in a virtual machine, irrespective of the virtualization technology used.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Install the GPU Operator (without NVIDIA vGPU)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Install the GPU Operator, enabling ``sandboxWorkloads``:

.. code-block:: console

   $ helm install --wait --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --set sandboxWorkloads.enabled=true

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Install the GPU Operator (with NVIDIA vGPU)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Build a private NVIDIA vGPU Manager container image and push to a private registry.
Follow the steps provided in :ref:`this section<build-vgpu-manager-image-22.9.2>`.

Create a namespace for GPU Operator:

.. code-block:: console

   $ kubectl create namespace gpu-operator

Create an ImagePullSecret for accessing the NVIDIA vGPU Manager image:

.. code-block:: console

    $ kubectl create secret docker-registry ${REGISTRY_SECRET_NAME} \
      --docker-server=${PRIVATE_REGISTRY} --docker-username=<username> \
      --docker-password=<password> \
      --docker-email=<email-id> -n gpu-operator

Install the GPU Operator with ``sandboxWorkloads`` and ``vgpuManager`` enabled and specify the NVIDIA vGPU Manager image built previously:

.. code-block:: console

   $ helm install --wait --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --set sandboxWorkloads.enabled=true \
         --set vgpuManager.enabled=true \
         --set vgpuManager.repository=<path to private repository> \
         --set vgpuManager.image=vgpu-manager \
         --set vgpuManager.version=<driver version> \
         --set vgpuManager.imagePullSecrets={${REGISTRY_SECRET_NAME}}

The vGPU Device Manager, deployed by the GPU Operator, automatically creates vGPU devices which can be assigned to KubeVirt virtual machines.
Without additional configuration, the GPU Operator creates a default set of devices on all GPUs.
To learn more about how the vGPU Device Manager and configure which types of vGPU devices get created in your cluster, refer to :ref:`vGPU Device Configuration<vgpu-device-configuration-22.9.2-22.9.2>`.

Add GPU resources to KubeVirt CR
--------------------------------

Next, update the KubeVirt Custom Resource, as documented in the `KubeVirt user guide <https://kubevirt.io/user-guide/virtual_machines/host-devices/#listing-permitted-devices>`_, so that all GPU/vGPU devices in your cluster are permitted and can be assigned to KubeVirt virtual machines.
In the below example, we are permitting the **A10** GPU device and **A10-24Q** vGPU device.
Replace the values for ``pciVendorSelector`` and ``resourceName`` to correspond to your GPU model, and replace ``mdevNameSelector`` and ``resourceName`` to correspond to your vGPU type.
We set ``externalResourceProvider=true`` to indicate that this resource is being provided by an external device plugin, in this case the ``sandbox-device-plugin`` which is deployed by the GPU Operator.
Refer to the `KubeVirt user guide <https://kubevirt.io/user-guide/virtual_machines/host-devices/#listing-permitted-devices>`_ for more information on the configuration options.

.. note::

   To find the device ID for a particular GPU, search by device name in the `PCI IDs database <https://pci-ids.ucw.cz/v2.2/pci.ids>`_.

.. code-block:: console

   $ kubectl edit kubevirt -n kubevirt
     ...
     spec:
       configuration:
       developerConfiguration:
         featureGates:
         - GPU
       permittedHostDevices:
         pciHostDevices:
         - externalResourceProvider: true
           pciVendorSelector: 10DE:2236
           resourceName: nvidia.com/GA102GL_A10
         mediatedDevices:
         - externalResourceProvider: true
           mdevNameSelector: NVIDIA A10-24Q
           resourceName: nvidia.com/NVIDIA_A10-24Q
     ...

Create a virtual machine with GPU
--------------------

Assuming the GPU Operator has finished provisioning worker nodes and the GPU resources have been added to the
KubeVirt allowlist, you can assign a GPU to a KubeVirt virtual machine by editing the ``spec.domain.devices.gpus`` stanza
in the ``VirtualMachineInstance`` manifest.

.. code-block:: yaml

   apiVersion: kubevirt.io/v1alpha3
   kind: VirtualMachineInstance
   . . . snip . . .
   spec:
     domain:
       devices:
         gpus:
         - deviceName: nvidia.com/GA102GL_A10
           name: gpu1
   . . . snip . . .

* ``deviceName`` is the resource name representing the device.

* ``name`` is a name to identify the device in the virtual machine

.. _vgpu-device-configuration-22.9.2-22.9.2:

vGPU Device Configuration
=========================

The vGPU Device Manager assists in creating vGPU devices on GPU worker nodes.
The vGPU Device Manager allows administrators to declaratively define a set of possible vGPU device configurations they would like applied to GPUs on a node.
At runtime, they then point the vGPU Device Manager at one of these configurations, and vGPU Device Manager takes care of applying it.
The configuration file is created as a ConfigMap, and is shared across all worker nodes.
At runtime, a node label, ``nvidia.com/vgpu.config``, can be used to decide which of these configurations to actually apply to a node at any given time.
If the node is not labeled, then the ``default`` configuration will be used.
For more information on this component and how it is configured, refer to the project `README <https://github.com/NVIDIA/vgpu-device-manager>`_.

By default, the GPU Operator deploys a ConfigMap for the vGPU Device Manager, containing named configurations for all `vGPU types <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#supported-gpus-grid-vgpu>`_ supported by NVIDIA vGPU.
Users can select a specific configuration for a worker node by applying the ``nvidia.com/vgpu.config`` node label.
For example, labeling a node with ``nvidia.com/vgpu.config=A10-8Q`` would create 3 vGPU devices of type **A10-8Q** on all **A10** GPUs on the node (note: 3 is the maximum number of **A10-8Q** devices that can be created per GPU).
If the node is not labeled, the ``default`` configuration will be applied.
The ``default`` configuration will create Q-series vGPU devices on all GPUs, where the amount of framebuffer memory per vGPU device
is half the total GPU memory.
For example, the ``default`` configuration will create two **A10-12Q** devices on all **A10** GPUs, two **V100-8Q** devices  on all **V100** GPUs, and two **T4-8Q** devices on all **T4** GPUs.

If custom vGPU device configuration is desired, more than the default ConfigMap provides, you can create your own ConfigMap:

.. code-block:: console

    $ kubectl create configmap custom-vgpu-config -n gpu-operator --from-file=config.yaml=/path/to/file

And then configure the GPU Operator to use it by setting ``vgpuDeviceManager.config.name=custom-vgpu-config``.


Apply a New vGPU Device Configuration
--------------------------------------

We can apply a specific vGPU device configuration on a per-node basis by setting the ``nvidia.com/vgpu.config`` node label. It is recommended to set this node label prior to installing the GPU Operator if you do not want the default configuration applied.

Switching vGPU device configuration after one has been successfully applied assumes that no virtual machines with vGPU are currently running on the node. Any existing virtual machines will have to be shutdown/migrated first.

To apply a new configuration after GPU Operator install, simply update the ``nvidia.com/vgpu.config`` node label. Let's run through an example on a system with two **A10** GPUs.

.. code-block:: console

   $ nvidia-smi -L
   GPU 0: NVIDIA A10 (UUID: GPU-ebd34bdf-1083-eaac-2aff-4b71a022f9bd)
   GPU 1: NVIDIA A10 (UUID: GPU-1795e88b-3395-b27b-dad8-0488474eec0c)

After installing the GPU Operator as detailed in the previous sections and without labeling the node with ``nvidia.com/vgpu.config``, the ``default`` vGPU config get applied -- four **A10-12Q** devices get created (two per GPU):

.. code-block:: console

   $ kubectl get node cnt-server-2 -o json | jq '.status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'
   {
     "nvidia.com/NVIDIA_A10-12Q": "4"
   }

If instead we wish to create **A10-4Q** devices, we can label the node like such:

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

We now see 12 **A10-4Q** devices on the node, as 6 **A10-4Q** devices can be created per **A10** GPU.

.. code-block:: console

   $ kubectl get node cnt-server-2 -o json | jq '.status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'
   {
     "nvidia.com/NVIDIA_A10-4Q": "12"
   }


.. _build-vgpu-manager-image-22.9.2:

Building the NVIDIA vGPU Manager image
======================================

.. note::

   Building the NVIDIA vGPU Manager image is only required if you are planning to use NVIDIA vGPU.
   If only planning to use PCI passthrough, skip this section.

This section covers building the NVIDIA vGPU Manager container image and pushing it to a private registry.

Download the vGPU Software from the `NVIDIA Licensing Portal <https://nvid.nvidia.com/dashboard/#/dashboard>`_.

* Login to the NVIDIA Licensing Portal and navigate to the `Software Downloads` section.
* The NVIDIA vGPU Software is located in the Software Downloads section of the NVIDIA Licensing Portal.
* The vGPU Software bundle is packaged as a zip file. Download and unzip the bundle to obtain the NVIDIA vGPU Manager for Linux (``NVIDIA-Linux-x86_64-<version>-vgpu-kvm.run`` file)

Next, clone the driver container repository and build the driver image with the following steps.

Open a terminal and clone the driver container image repository.

.. code-block:: console

   $ git clone https://gitlab.com/nvidia/container-images/driver
   $ cd driver

Change to the vgpu-manager directory for your OS. We use Ubuntu 20.04 as an example.

.. code-block:: console

   $ cd vgpu-manager/ubuntu20.04

.. note::

   For RedHat OpenShift, run ``cd vgpu-manager/rhel8`` to use the ``rhel8`` folder instead.

Copy the NVIDIA vGPU Manager from your extracted zip file

.. code-block:: console

   $ cp <local-driver-download-directory>/*-vgpu-kvm.run ./

| Set the following environment variables:
| ``PRIVATE_REGISTRY`` - name of private registry used to store driver image
| ``VERSION`` - NVIDIA vGPU Manager version downloaded from NVIDIA Software Portal
| ``OS_TAG`` - this must match the Guest OS version. In the below example ``ubuntu20.04`` is used. For RedHat OpenShift this should be set to ``rhcos4.x`` where x is the supported minor OCP version.
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
