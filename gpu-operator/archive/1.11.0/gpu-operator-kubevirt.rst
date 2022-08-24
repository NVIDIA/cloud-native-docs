.. Date: Jun 22 2022
.. Author: cdesiniotis

.. headings (h1/h2/h3/h4/h5/h6) are # * = - ^ "

.. _gpu-operator-kubevirt-1.11.0:

Running KubeVirt VMs with the GPU Operator
******************************************

.. _gpu-operator-kubevirt-1.11.0-introduction:

Introduction
============

.. note::

   This feature is introduced as a technical preview with the GPU Operator 1.11.0 release. This is not ready for production use. Please submit feedback and bug reports `here <https://github.com/NVIDIA/gpu-operator/issues>`_. We encourage contributions in our `Gitlab repository <https://gitlab.com/nvidia/kubernetes/gpu-operator>`_.

`KubeVirt <https://kubevirt.io/>`_ is a virtual machine management add-on to Kubernetes that allows you to run and manage VMs in a Kubernetes cluster. It eliminates the need to manage separate clusters for VM and container workloads, as both can now coexist in a single Kubernetes cluster.

Up until this point, the GPU Operator only provisioned worker nodes for running GPU-accelerated containers. Now, the GPU Operator can also be used to provision worker nodes for running GPU-accelerated VMs.

The prerequisites needed for running containers and VMs with GPU(s) differs, with the primary difference being the drivers required. For example, the datacenter driver is needed for containers, the vfio-pci driver is needed for GPU passthrough, and the `NVIDIA vGPU Manager <https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#installing-configuring-grid-vgpu>`_ is needed for creating vGPU devices.

The GPU Operator can now be configured to deploy different software components on worker nodes depending on what GPU workload is configured to run on those nodes. Consider the following example.

| Node A is configured to run containers.
| Node B is configured to run VMs with Passthrough GPU.
| Node C is configured to run VMs with vGPU.


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

.. _gpu-operator-kubevirt-1.11.0-limitations:

Limitations
===========

* This feature is a Technical Preview and is not ready for production use.

* Trying out this feature requires a fresh install of GPU Operator 1.11 with necessary fields set in ClusterPolicy as detailed in this document. The instructions in this document are not valid if upgrading from 1.10 to 1.11.

* Enabling / disabling this feature post-install is not supported.

* MIG-backed vGPUs are not supported.

* A GPU worker node can run GPU workloads of a particular type - containers, VMs with GPU Passthrough, and VMs with vGPU - but not a combination of any of them.

Install the GPU Operator
========================

To enable this functionality, install the GPU Operator and set the following parameter in ``ClusterPolicy``: ``sandboxWorkloads.enabled=true``.

.. note::

   The term ``sandboxing`` refers to running software in a separate isolated environment, typically for added security (i.e. a virtual machine). We use the term ``sandbox workloads`` to signify workloads that run in a virtual machine, irrespective of the virtualization technology used.

Partition Cluster based the GPU Workload
========================================

When sandbox workloads are enabled (``sandboxWorkloads.enabled=true``), a worker node can run GPU workloads of a particular type – containers, VMs with GPU passthrough, or VMs with vGPU –  but not a combination of any of them. As illustrated in the :ref:`Introduction <gpu-operator-kubevirt-1.11.0-introduction>`, the GPU Operator will deploy a specific set of operands on a worker node depending on the workload type configured. For example, a node which is configured to run containers will receive the ``NVIDIA Datacenter Driver``, while a node which is configured to run VMs with vGPU will receive the ``NVIDIA vGPU Manager``.

To set the GPU workload configuration for a worker node, apply the node label ``nvidia.com/gpu.workload.config=<config>``, where the valid config values are ``container``, ``vm-passthrough``, and ``vm-vgpu``.

If the node label ``nvidia.com/gpu.workload.config`` does not exist on the node, the GPU Operator will assume the default GPU workload configuration, ``container``. To override the default GPU workload configuration, set the following value in ``ClusterPolicy`` during install: ``sandboxWorkloads.defaultWorkload=<config>``.

Consider the following example:

GPU Operator is installed with the following options: ``sandboxWorkloads.enabled=true sandboxWorkloads.defaultWorkload=container``

| Node A is `not` labeled with ``nvidia.com/gpu.workload.config``.
| Node B is labeled with ``nvidia.com/gpu.workload.config=vm-passthrough``.
| Node C is labeled with ``nvidia.com/gpu.workload.config=vm-vgpu``.


| Node A gets provisioned for containers.
| Node B gets provisioned for GPU Passthrough.
| Node C gets provisioned for vGPU.

Deployment Scenarios
====================

Running VMs with GPU Passthrough
--------------------------------

This section runs through the deployment scenario of running VMs with GPU Passthrough. We will first deploy the GPU Operator, such that our worker node will be provisioned for GPU Passthrough, then we will deploy a KubeVirt VM which requests a GPU.

By default, to provision GPU Passthrough, the GPU Operator will deploy the following components:

* ``VFIO Manager`` - to load ``vfio-pci`` and bind it to all GPUs on the node
* ``Sandbox Device Plugin`` - to discover and advertise the passthrough GPUs to kubelet
* ``Sandbox Validator`` - to validate the other operands

Install the GPU Operator
^^^^^^^^^^^^^^^^^^^^^^^^

Follow the below steps.

Label the worker node explicitly for GPU passthrough workloads:

.. code-block:: console

   $ kubectl label node <node-name> --overwrite nvidia.com/gpu.workload.config=vm-passthrough

Install the GPU Operator with sandbox workloads enabled:

.. code-block:: console

   $ helm install gpu-operator nvidia/gpu-operator -n gpu-operator \
       –set sandboxWorkloads.enabled=true

The following operands get deployed. Ensure all pods are in a running state and all validations succeed with the ``sandbox-validator`` component:

.. code-block:: console

   $ kubectl get pods -n gpu-operator
   NAME                                                          READY   STATUS    RESTARTS   AGE
   ...
   nvidia-sandbox-device-plugin-daemonset-4mxsc                  1/1     Running   0          40s
   nvidia-sandbox-validator-vxj7t                                1/1     Running   0          40s
   nvidia-vfio-manager-thfwf                                     1/1     Running   0          78s

The vfio-manager pod will bind all GPUs on the node to the vfio-pci driver:

.. code-block:: console

   $ lspci --nnk -d 10de:
   3b:00.0 3D controller [0302]: NVIDIA Corporation Device [10de:2236] (rev a1)
          Subsystem: NVIDIA Corporation Device [10de:1482]
          Kernel driver in use: vfio-pci
          Kernel modules: nvidiafb, nouveau
   86:00.0 3D controller [0302]: NVIDIA Corporation Device [10de:2236] (rev a1)
          Subsystem: NVIDIA Corporation Device [10de:1482]
          Kernel driver in use: vfio-pci
          Kernel modules: nvidiafb, nouveau

The sandbox-device-plugin will discover and advertise these resources to kubelet. In this example, we have two A10 GPUs:

.. code-block:: console

   $ kubectl describe node <node-name>
   ...
   Capacity:
     ...
     nvidia.com/GA102GL_A10:         2
     ...
   Allocatable:
     ...
     nvidia.com/GA102GL_A10:         2
   ...

.. note::

   The resource name is currently constructed by joining the `device` and `device_name` columns from the `PCI IDs database <https://pci-ids.ucw.cz/v2.2/pci.ids>`_. For example, the entry for A10 in the database reads ``2236  GA102GL [A10]``, which results in a resource name ``nvidia.com/GA102GL_A10``.

Update the KubeVirt CR
^^^^^^^^^^^^^^^^^^^^^^

Next, we will update the KubeVirt Custom Resource, as documented in the `KubeVirt user guide <https://kubevirt.io/user-guide/virtual_machines/host-devices/#listing-permitted-devices>`_, so that the passthrough GPUs are permitted and can be requested by a KubeVirt VM. Note, replace the values for ``pciVendorSelector`` and ``resourceName`` to correspond to your GPU model. We set ``externalResourceProvider=true`` to indicate that this resource is being provided by an external device plugin, in this case the ``sandbox-device-plugin`` which is deployed by the Operator.

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
     ...


Create a VM
^^^^^^^^^^^

We are now ready to create a VM. Let’s create a sample VM using a simple VMI spec which requests a nvidia.com/GA102GL_A10 resource:

.. code-block:: console

   ---
   apiVersion: kubevirt.io/v1alpha3
   kind: VirtualMachineInstance
   metadata:
     labels:
       special: vmi-gpu
     name: vmi-gpu
   spec:
     domain:
       devices:
         disks:
         - disk:
             bus: virtio
           name: containerdisk
         - disk:
             bus: virtio
           name: cloudinitdisk
         gpus:
         - deviceName: nvidia.com/GA102GL_A10
           name: gpu1
         rng: {}
       machine:
         type: ""
       resources:
         requests:
           memory: 1024M
     terminationGracePeriodSeconds: 0
     volumes:
     - containerDisk:
         image: docker.io/kubevirt/fedora-cloud-container-disk-demo:devel
       name: containerdisk
     - cloudInitNoCloud:
         userData: |-
           #cloud-config
           password: fedora
           chpasswd: { expire: False }
       name: cloudinitdisk

.. code-block:: console

   $ kubectl apply -f vmi-gpu.yaml
   virtualmachineinstance.kubevirt.io/vmi-gpu created

   $ kubectl get vmis
   NAME      AGE   PHASE     IP               NODENAME       READY
   vmi-gpu   13s   Running   192.168.47.210   cnt-server-2   True

Let's console into the VM and verify we have a GPU. Refer `here <https://kubevirt.io/user-guide/operations/virtctl_client_tool/>`_ for installing virtctl.

.. code-block:: console

   $ ./virtctl console vmi-gpu
   Successfully connected to vmi-gpu console. The escape sequence is ^]

   vmi-gpu login: fedora
   Password:
   [fedora@vmi-gpu ~]$ sudo yum install -y -q pciutils
   [fedora@vmi-gpu ~]$ lspci -nnk -d 10de:
   06:00.0 3D controller [0302]: NVIDIA Corporation GA102GL [A10] [10de:2236] (rev a1)
          Subsystem: NVIDIA Corporation Device [10de:1482]

Running VMs with vGPU
---------------------

This section runs through the deployment scenario of running VMs with vGPU. We will first deploy the GPU Operator, such that our worker node will be provisioned for vGPU, then we will deploy a KubeVirt VM which requests a vGPU.

By default, to provision vGPU, the GPU Operator will deploy the following components:

* ``NVIDIA vGPU Manager`` - installs vGPU Manager on the node
* ``NVIDIA vGPU Device Manager`` - creates vGPU devices on the node after vGPU Manager is installed
* ``Sandbox Device Plugin`` - to discover and advertise the vGPU devices to kubelet
* ``Sandbox Validator`` - to validate the other operands

Build the vGPU Manager Image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Building the vGPU Manager container and pushing it to a private registry is a prerequisite. To fulfill this prerequisite, follow the below steps.

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

   For RedHat OpenShift, run ``cd vgpu-manager/rhel`` to use the ``rhel`` folder instead.

Copy the NVIDIA vGPU Manager from your extracted zip file

.. code-block:: console

   $ cp <local-driver-download-directory>/*-vgpu-kvm.run ./

| Set the following environment variables:
| ``PRIVATE_REGISTRY`` - name of private registry used to store driver image
| ``VERSION`` - NVIDIA vGPU Manager version downloaded from NVIDIA Software Portal
| ``OS_TAG`` - this must match the Guest OS version. In the below example ``ubuntu20.04`` is used. For RedHat OpenShift this should be set to ``rhcos4.x`` where x is the supported minor OCP version.

.. code-block:: console

   $ export PRIVATE_REGISTRY=my/private/registry VERSION=510.73.06 OS_TAG=ubuntu20.04

Build the NVIDIA vGPU Manager image.

.. code-block:: console

   $ docker build \
       –build-arg DRIVER_VERSION=${VERSION} \
       -t ${PRIVATE_REGISTRY}/vgpu-manager:${VERSION}-${OS_TAG} .

Push NVIDIA vGPU Manager image to your private registry.

.. code-block:: console

   $ docker push ${PRIVATE_REGISTRY}/vgpu-manager:${VERSION}-${OS_TAG}

Install the GPU Operator
^^^^^^^^^^^^^^^^^^^^^^^^

Follow the below steps.

Label the worker node explicitly for vGPU workloads:

.. code-block:: console

   $ kubectl label node <node-name> --overwrite nvidia.com/gpu.workload.config=vm-vgpu

Create a configuration file named ``config.yaml`` for the vGPU Device Manager.  This file contains a list of vGPU device configurations. Each named configuration contains a list of desired vGPU types. The vGPU Device Manager reads the configuration file and applies a specific named configuration when creating vGPU devices on the node. Download the comprehensive example file as a starting point, and modify as needed:

.. code-block:: console

   $ wget -O config.yaml https://raw.githubusercontent.com/NVIDIA/vgpu-device-manager/main/examples/config-example.yaml

Optionally, label the worker node explicitly with a vGPU devices config. More information on vGPU devices config is detailed in :ref:`this section <apply-new-vgpu-device-config-1.11.0>` below.

.. code-block:: console

   $ kubectl label node <node-name> --overwrite nvidia.com/vgpu.config=<config-name>

Create a namespace for GPU Operator:

.. code-block:: console

   $ kubectl create namespace gpu-operator

Create a ConfigMap for the vGPU devices config:

.. code-block:: console

   $ kubectl create cm vgpu-devices-config -n gpu-operator –from-file=config.yaml

Install the GPU Operator with sandbox workloads enabled and specify the vGPU Manager image built previously:

.. code-block:: console

   $ helm install gpu-operator nvidia/gpu-operator -n gpu-operator \
       –set sandboxWorkloads.enabled=true \
       –set vgpuManager.repository=<path to private repository>
       –set vgpuManager.image=vgpu-manager
       –set vgpuManager.version=<driver version>

The following operands get deployed. Ensure all pods are in a running state and all validations succeed with the ``sandbox-validator`` component.

.. code-block:: console

   $ kubectl get pods -n gpu-operator
   NAME                                                          READY   STATUS    RESTARTS   AGE
   ...
   nvidia-sandbox-device-plugin-daemonset-kkdt9                  1/1     Running   0          9s
   nvidia-sandbox-validator-jcpgw                                1/1     Running   0          9s
   nvidia-vgpu-device-manager-8mgg8                              1/1     Running   0          89s
   nvidia-vgpu-manager-daemonset-fpplc                           1/1     Running   0          2m41s

This worker node has two A10 GPUs. Assuming the node has not been labeled explicitly with ``nvidia.com/vgpu.config=<config-name>``, the ``default`` configuration will be used. And since the ``default`` configuration in the vgpu-devices-config only lists the **A10-24C** vGPU type for the A10 GPU, the vgpu-device-manager should only create vGPU devices on this type.

**A10-24C** is the largest vGPU type supported on the A10 GPU, and only one vGPU device can be created per physical GPU. We should see two vGPU devices created:

.. code-block:: console

   $ ls -l /sys/bus/mdev/devices
   total 0
   lrwxrwxrwx 1 root root 0 Jun  7 00:18 9adc60ea-98a7-41b6-b17b-9b3e0d210c7a -> ../../../devices/pci0000:85/0000:85:02.0/0000:86:00.4/9adc60ea-98a7-41b6-b17b-9b3e0d210c7a
   lrwxrwxrwx 1 root root 0 Jun  7 00:18 f9033b86-ccee-454b-8b20-dd7912d95bfd -> ../../../devices/pci0000:3a/0000:3a:00.0/0000:3b:00.4/f9033b86-ccee-454b-8b20-dd7912d95bfd

The sandbox-device-plugin will discover and advertise these resources to kubelet. In this example, we have two A10 GPUs and therefore two **A10-24C** vGPU devices.

.. code-block:: console

   $ kubectl describe node
   ...
   Capacity:
     ...
     nvidia.com/NVIDIA_A10-24C:      2
     ...
   Allocatable:
     ...
     nvidia.com/NVIDIA_A10-24C:      2
   ...

Update the KubeVirt CR
^^^^^^^^^^^^^^^^^^^^^^

Next, we will update the KubeVirt Custom Resource, as documented in the `KubeVirt user guide <https://kubevirt.io/user-guide/virtual_machines/host-devices/#listing-permitted-devices>`_, so that these vGPU devices are permitted and can be requested by a KubeVirt VM. Note, replace the values for ``mdevNameSelector`` and ``resourceName`` to correspond to your vGPU type. We set ``externalResourceProvider=true`` to indicate that this resource is being provided by an external device plugin, in this case the sandbox-device-plugin which is deployed by the Operator.

.. code-block:: console

   $ kubectl edit kubevirt -n kubevirt
   ...
   spec:
     certificateRotateStrategy: {}
     configuration:
       developerConfiguration:
         featureGates:
         - GPU
       permittedHostDevices:
         mediatedDevices:
         - externalResourceProvider: true
           mdevNameSelector: NVIDIA A10-24C
           resourceName: nvidia.com/NVIDIA_A10-24C
   ...

We are now ready to create a VM. Let’s create a sample VM using a simple VMI spec which requests a ``nvidia.com/NVIDIA_A10-24C`` resource:

.. code-block:: console

   $ cat vmi-vgpu.yaml
   ---
   apiVersion: kubevirt.io/v1alpha3
   kind: VirtualMachineInstance
   metadata:
     labels:
       special: vmi-vgpu
     name: vmi-vgpu
   spec:
     domain:
       devices:
         disks:
         - disk:
             bus: virtio
           name: containerdisk
         - disk:
             bus: virtio
           name: cloudinitdisk
         gpus:
         - deviceName: nvidia.com/NVIDIA_A10-24C
           name: vgpu1
         rng: {}
       machine:
         type: ""
       resources:
         requests:
           memory: 1024M
     terminationGracePeriodSeconds: 0
     volumes:
     - containerDisk:
         image: docker.io/kubevirt/fedora-cloud-container-disk-demo:devel
       name: containerdisk
     - cloudInitNoCloud:
         userData: |-
           #cloud-config
           password: fedora
           chpasswd: { expire: False }
       name: cloudinitdisk

.. code-block:: console

   $ kubectl apply -f vmi-vgpu.yaml
   virtualmachineinstance.kubevirt.io/vmi-vgpu created

   $ kubectl get vmis
   NAME       AGE   PHASE     IP               NODENAME       READY
   vmi-vgpu   10s   Running   192.168.47.205   cnt-server-2   True

Let’s console into the VM and verify we have a GPU. Refer `here <https://docs.google.com/document/d/1mH08JNe8nj5SRKzg8llttzMJbJbDbDaLji07BG6P1c4/edit#heading=h.hwxorb7idly9>`_ for installing virtctl.

.. code-block:: console

   $ ./virtctl console vmi-vgpu
   Successfully connected to vmi-vgpu console. The escape sequence is ^]

   vmi-vgpu login: fedora
   Password:
   [fedora@vmi-vgpu ~]$ sudo yum install -y -q pciutils
   [fedora@vmi-vgpu ~]$ lspci -nnk -d 10de:
   06:00.0 3D controller [0302]: NVIDIA Corporation GA102GL [A10] [10de:2236] (rev a1)
          Subsystem: NVIDIA Corporation Device [10de:14d4]

.. _apply-new-vgpu-device-config-1.11.0:

Apply a New vGPU Device Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We can apply a specific vGPU device configuration on a per-node basis by setting the ``nvidia.com/vgpu.config`` node label. It is recommended to set this node label prior to installing the GPU Operator if you do not want the default configuration applied.

Switching vGPU device configuration assumes that no VMs with vGPU are currently running on the node. Any existing VMs will have to be shutdown/migrated first.

To apply a new configuration after GPU Operator install, simply update the node label:

.. code-block:: console

   $ kubectl label node <node-name> --overwrite nvidia.com/vgpu.config=A10-4C

After the vGPU Device Manager finishes applying the new configuration, all pods should return to the Running state.

.. code-block:: console

   $ kubectl get pods -n gpu-operator
   NAME                                                          READY   STATUS    RESTARTS   AGE
   ...
   nvidia-sandbox-device-plugin-daemonset-brtb6                  1/1     Running   0          10s
   nvidia-sandbox-validator-ljnwg                                1/1     Running   0          10s
   nvidia-vgpu-device-manager-8mgg8                              1/1     Running   0          30m
   nvidia-vgpu-manager-daemonset-fpplc                           1/1     Running   0          31m

We now see 12 vGPU devices on the node, as 6 **A10-4C** devices can be created per A10 GPU.

.. code-block:: console

   $ ls -ltr /sys/bus/mdev/devices
   total 0
   lrwxrwxrwx 1 root root 0 Jun  7 00:47 87401d9a-545b-4506-b1be-d4d30f6f4a4b -> ../../../devices/pci0000:3a/0000:3a:00.0/0000:3b:00.5/87401d9a-545b-4506-b1be-d4d30f6f4a4b
   lrwxrwxrwx 1 root root 0 Jun  7 00:47 78597b11-282f-496c-a4d0-19220310039c -> ../../../devices/pci0000:3a/0000:3a:00.0/0000:3b:00.4/78597b11-282f-496c-a4d0-19220310039c
   lrwxrwxrwx 1 root root 0 Jun  7 00:47 0d093db4-2c57-40ce-a1f0-ef4d410c6db8 -> ../../../devices/pci0000:3a/0000:3a:00.0/0000:3b:00.6/0d093db4-2c57-40ce-a1f0-ef4d410c6db8
   lrwxrwxrwx 1 root root 0 Jun  7 00:47 f830dbb1-0eb5-4294-af32-c68028e2ae35 -> ../../../devices/pci0000:3a/0000:3a:00.0/0000:3b:00.7/f830dbb1-0eb5-4294-af32-c68028e2ae35
   lrwxrwxrwx 1 root root 0 Jun  7 00:47 a5a11713-e683-4372-bebf-82219c58ce24 -> ../../../devices/pci0000:3a/0000:3a:00.0/0000:3b:01.1/a5a11713-e683-4372-bebf-82219c58ce24
   lrwxrwxrwx 1 root root 0 Jun  7 00:47 1a48c902-07f1-4a19-b3b0-b89ce35ad025 -> ../../../devices/pci0000:3a/0000:3a:00.0/0000:3b:01.0/1a48c902-07f1-4a19-b3b0-b89ce35ad025
   lrwxrwxrwx 1 root root 0 Jun  7 00:47 b8de2bbe-a41a-440e-9276-f7b56dc35138 -> ../../../devices/pci0000:85/0000:85:02.0/0000:86:01.1/b8de2bbe-a41a-440e-9276-f7b56dc35138
   lrwxrwxrwx 1 root root 0 Jun  7 00:47 afd7a4bb-d638-4489-bb41-6e03fc5c75b5 -> ../../../devices/pci0000:85/0000:85:02.0/0000:86:01.0/afd7a4bb-d638-4489-bb41-6e03fc5c75b5
   lrwxrwxrwx 1 root root 0 Jun  7 00:47 98175f96-707b-4167-ada5-869110ead3ab -> ../../../devices/pci0000:85/0000:85:02.0/0000:86:00.5/98175f96-707b-4167-ada5-869110ead3ab
   lrwxrwxrwx 1 root root 0 Jun  7 00:47 6e93ea61-9068-4096-b20c-ea30a72c1238 -> ../../../devices/pci0000:85/0000:85:02.0/0000:86:00.7/6e93ea61-9068-4096-b20c-ea30a72c1238
   lrwxrwxrwx 1 root root 0 Jun  7 00:47 537ce645-32cc-46d0-b7f0-f90ead840957 -> ../../../devices/pci0000:85/0000:85:02.0/0000:86:00.6/537ce645-32cc-46d0-b7f0-f90ead840957
   lrwxrwxrwx 1 root root 0 Jun  7 00:47 4eb167bc-0e15-43f3-a218-d74cc9d162ff -> ../../../devices/pci0000:85/0000:85:02.0/0000:86:00.4/4eb167bc-0e15-43f3-a218-d74cc9d162ff

Check the new vGPU resources are advertised to kubelet:

.. code-block:: console

   $ kubectl describe node
   ...
   Capacity:
     ...
     nvidia.com/NVIDIA_A10-4C:       12
     ...
   Allocatable:
     ...
     nvidia.com/NVIDIA_A10-4C:       12
   ...

Following previous instructions, we can now create a VM with an **A10-4C** vGPU attached.
