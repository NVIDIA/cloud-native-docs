.. Date: Aug 4 2021
.. Author: pramarao

.. headings (h1/h2/h3/h4/h5) are # * = -

.. _operator-rdma-1.11.1:

#######################
GPUDirect RDMA
#######################

`GPUDirect RDMA <https://docs.nvidia.com/cuda/gpudirect-rdma/index.html>`_ is a technology in NVIDIA GPUs that enables direct 
data exchange between GPUs and a third-party peer device using PCI Express. The third-party devices could be network interfaces 
such as NVIDIA ConnectX SmartNICs or BlueField DPUs, storage adapters (for `GPUDirect Storage <https://docs.nvidia.com/gpudirect-storage/overview-guide/index.html>`_) 
or video acquisition adapters.

To support GPUDirect RDMA, a userspace CUDA APIs and kernel mode drivers are required. Starting with 
`CUDA 11.4 and R470 drivers <https://docs.nvidia.com/cuda/gpudirect-rdma/index.html#new-in-cuda-114>`_, a 
new kernel module ``nvidia-peermem`` is included in the standard NVIDIA driver installers (e.g. ``.run``). The 
kernel module provides Mellanox Infiniband-based HCAs direct peer-to-peer read and write access to the GPU's memory. 

In conjunction with the `Network Operator <https://github.com/Mellanox/network-operator>`_, the GPU Operator can be used to 
set up the networking related components such as Mellanox drivers, ``nvidia-peermem`` and Kubernetes device plugins to enable 
workloads to take advantage of GPUDirect RDMA. Refer to the Network Operator `documentation <https://docs.mellanox.com/display/COKAN10>`_ 
on installing the Network Operator. 

*********************
Using nvidia-peermem
*********************

Supported Platforms
===================

For platforms supported, see :ref:`here <gpudirect_rdma_support>`

Prerequisites
===============

Make sure that `MOFED <https://github.com/Mellanox/ofed-docker>`_ drivers are installed either through `Network Operator <https://github.com/Mellanox/network-operator>`_ or directly on the host.

Installation
==============

The following section is applicable to the following configurations and describe how to deploy the GPU Operator using the Helm Chart:

* Kubernetes on bare metal and on vSphere VMs with GPU passthrough and vGPU.
* VMware vSphere with Tanzu.

For Red Hat Openshift on bare metal and on vSphere VMs with GPU passthrough and vGPU configurations, please follow this procedure :ref:`NVIDIA AI Enterprise with OpenShift <nvaie-ocp-1.11.1-1.11.1>`.

Starting with v1.8, the GPU Operator provides an option to load the ``nvidia-peermem`` kernel module during the bootstrap of the NVIDIA driver daemonset.
Please refer to below install commands based on if Mellanox OFED (MOFED) drivers are installed through Network-Operator or on the host.
GPU Operator v1.9 added support for GPUDirect RDMA with MOFED drivers installed on the host.

MOFED drivers installed with Network-Operator:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set driver.rdma.enabled=true

MOFED drivers installed directly on host:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set driver.rdma.enabled=true --set driver.rdma.useHostMofed=true

Verification
==============

During the installation, an `initContainer` is used with the driver daemonset to wait on the Mellanox OFED (MOFED) drivers to be ready.
This initContainer checks for Mellanox NICs on the node and ensures that the necessary kernel symbols are exported MOFED kernel drivers.
Once everything is in place, the container nvidia-peermem-ctr will be instantiated inside the driver daemonset.

.. code-block:: console

   $ kubectl describe pod -n <Operator Namespace> nvidia-driver-daemonset-xxxx
   <snip>
    Init Containers:
     mofed-validation:
     Container ID:  containerd://5a36c66b43f676df616e25ba7ae0c81aeaa517308f28ec44e474b2f699218de3
     Image:         nvcr.io/nvidia/cloud-native/gpu-operator-validator:v1.8.1
     Image ID:      nvcr.io/nvidia/cloud-native/gpu-operator-validator@sha256:7a70e95fd19c3425cd4394f4b47bbf2119a70bd22d67d72e485b4d730853262c
     
    <snip>
    Containers:
     nvidia-driver-ctr:
     Container ID:  containerd://199a760946c55c3d7254fa0ebe6a6557dd231179057d4909e26c0e6aec49ab0f
     Image:         nvcr.io/nvaie/vgpu-guest-driver:470.63.01-ubuntu20.04
     Image ID:      nvcr.io/nvaie/vgpu-guest-driver@sha256:a1b7d2c8e1bad9bb72d257ddfc5cec341e790901e7574ba2c32acaddaaa94625
     
     <snip>
     nvidia-peermem-ctr:
     Container ID:  containerd://0742d86f6017bf0c304b549ebd8caad58084a4185a1225b2c9a7f5c4a171054d
     Image:         nvcr.io/nvaie/vgpu-guest-driver:470.63.01-ubuntu20.04
     Image ID:      nvcr.io/nvaie/vgpu-guest-driver@sha256:a1b7d2c8e1bad9bb72d257ddfc5cec341e790901e7574ba2c32acaddaaa94625
     
    <snip>


To validate that nvidia-peermem-ctr has successfully loaded the nvidia-peermem module, you can use the following command:

.. code-block:: console

  $ kubectl logs -n gpu-operator nvidia-driver-daemonset-xxx -c nvidia-peermem-ctr
  waiting for mellanox ofed and nvidia drivers to be installed
  waiting for mellanox ofed and nvidia drivers to be installed
  successfully loaded nvidia-peermem module


For more information on ``nvidia-peermem``, refer to the `documentation <https://docs.nvidia.com/cuda/gpudirect-rdma/index.html#nvidia-peermem>`_.

*****************
Further Reading
*****************

Refer to the following resources for more information:

  * GPUDirect RDMA: https://docs.nvidia.com/cuda/gpudirect-rdma/index.html

  * NVIDIA Network Operator: https://github.com/Mellanox/network-operator

  * Blog post on deploying the Network Operator: https://developer.nvidia.com/blog/deploying-gpudirect-rdma-on-egx-stack-with-the-network-operator/
