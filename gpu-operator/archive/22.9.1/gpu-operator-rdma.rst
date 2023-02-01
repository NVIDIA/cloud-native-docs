.. Date: Aug 4 2021
.. Author: pramarao

.. headings (h1/h2/h3/h4/h5) are # * = -

.. _operator-rdma-22.9.1:

####################################
GPUDirect RDMA and GPUDirect Storage
####################################

`GPUDirect RDMA <https://docs.nvidia.com/cuda/gpudirect-rdma/index.html>`_ is a technology in NVIDIA GPUs that enables direct 
data exchange between GPUs and a third-party peer device using PCI Express. The third-party devices could be network interfaces 
such as NVIDIA ConnectX SmartNICs or BlueField DPUs, or video acquisition adapters.

GPUDirect Storage (`GDS <https://docs.nvidia.com/gpudirect-storage/overview-guide/index.html>`_) enables a direct data path between local or remote storage, like NFS server or NVMe/NVMe over Fabric (NVMe-oF), and GPU memory.
GDS leverages direct memory access (DMA) transfers between GPU memory and storage, which avoids a bounce buffer through the CPU. This direct path increases system bandwidth and decreases the latency and utilization load on the CPU.

To support GPUDirect RDMA, a userspace CUDA APIs and kernel mode drivers are required. Starting with 
`CUDA 11.4 and R470 drivers <https://docs.nvidia.com/cuda/gpudirect-rdma/index.html#new-in-cuda-114>`_, a 
new kernel module ``nvidia-peermem`` is included in the standard NVIDIA driver installers (e.g. ``.run``). The 
kernel module provides Mellanox Infiniband-based HCAs direct peer-to-peer read and write access to the GPU's memory. 

In conjunction with the `Network Operator <https://github.com/Mellanox/network-operator>`_, the GPU Operator can be used to 
set up the networking related components such as Mellanox drivers, ``nvidia-peermem`` and Kubernetes device plugins to enable 
workloads to take advantage of GPUDirect RDMA and GPUDirect Storage. Refer to the Network Operator `documentation <https://docs.mellanox.com/display/COKAN10>`_ 
on installing the Network Operator. 

*************************************
Using nvidia-peermem (GPUDirect RDMA)
*************************************

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

For Red Hat Openshift on bare metal and on vSphere VMs with GPU passthrough and vGPU configurations, please follow this procedure :ref:`NVIDIA AI Enterprise with OpenShift <nvaie-ocp-22.9.1-22.9.1>`.

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


***********************
Using GPUDirect Storage
***********************

Supported Platforms
===================

For platforms supported, see :ref:`here <gpudirect_rdma_support>`

Prerequisites
===============

Make sure that `MOFED <https://github.com/Mellanox/ofed-docker>`_ drivers are installed through `Network Operator <https://github.com/Mellanox/network-operator>`_.


Installation
==============

The following section is applicable to the following configurations and describe how to deploy the GPU Operator using the Helm Chart:

* Kubernetes on bare metal and on vSphere VMs with GPU passthrough and vGPU.


Starting with v22.9.1, the GPU Operator provides an option to load the ``nvidia-fs`` kernel module during the bootstrap of the NVIDIA driver daemonset.
Please refer to below install commands based on Mellanox OFED (MOFED) drivers are installed through Network-Operator.


MOFED drivers installed with Network-Operator:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set driver.rdma.enabled=true
        --set gds.enabled=true


For detailed information on how to deploy Network Operator and GPU Operator for GPU Direct Storage, please use this `link <https://docs.nvidia.com/ai-enterprise/deployment-guide-bare-metal/0.1.0/gds-overview.html>`_.


Verification
==============

During the installation, an `initContainer` is used with the driver daemonset to wait on the Mellanox OFED (MOFED) drivers to be ready.
This initContainer checks for Mellanox NICs on the node and ensures that the necessary kernel symbols are exported MOFED kernel drivers.
Once everything is in place, the containers nvidia-peermem-ctr and nvidia-fs-ctr will be instantiated inside the driver daemonset.



.. code-block:: console

   $ kubectl get pod -n gpu-operator

   gpu-operator   gpu-feature-discovery-pktzg                                       1/1     Running     0          11m
   gpu-operator   gpu-operator-1672257888-node-feature-discovery-master-7ccb7txmc   1/1     Running     0          12m
   gpu-operator   gpu-operator-1672257888-node-feature-discovery-worker-bqhrl       1/1     Running     0          11m
   gpu-operator   gpu-operator-6f64c86bc-zjqdh                                      1/1     Running     0          12m
   gpu-operator   nvidia-container-toolkit-daemonset-rgwqg                          1/1     Running     0          11m
   gpu-operator   nvidia-cuda-validator-8whvt                                       0/1     Completed   0          8m50s
   gpu-operator   nvidia-dcgm-exporter-pt9q9                                        1/1     Running     0          11m
   gpu-operator   nvidia-device-plugin-daemonset-472fc                              1/1     Running     0          11m
   gpu-operator   nvidia-device-plugin-validator-29nhc                              0/1     Completed   0          8m34s
   gpu-operator   nvidia-driver-daemonset-j9vw6                                     3/3     Running     0          12m
   gpu-operator   nvidia-mig-manager-mtjcw                                          1/1     Running     0          7m35s
   gpu-operator   nvidia-operator-validator-b8nz2                                   1/1     Running     0          11m





.. code-block:: console

   $ kubectl describe pod -n <Operator Namespace> nvidia-driver-daemonset-xxxx
   <snip>
    Init Containers:
     mofed-validation:
      Container ID:  containerd://a31a8c16ce7596073fef7cb106da94c452fdff111879e7fc3ec58b9cef83856a
      Image:         nvcr.io/nvidia/cloud-native/gpu-operator-validator:v22.9.1
      Image ID:      nvcr.io/nvidia/cloud-native/gpu-operator-validator@sha256:18c9ea88ae06d479e6657b8a4126a8ee3f4300a40c16ddc29fb7ab3763d46005
     
    <snip>
    Containers:
     nvidia-driver-ctr:
      Container ID:  containerd://7cf162e4ee4af865c0be2023d61fbbf68c828d396207e7eab2506f9c2a5238a4
      Image:         nvcr.io/nvidia/driver:525.60.13-ubuntu20.04
      Image ID:      nvcr.io/nvidia/driver@sha256:0ee0c585fa720f177734b3295a073f402d75986c1fe018ae68bd73fe9c21b8d8

     
     <snip>
     nvidia-peermem-ctr:
      Container ID:  containerd://5c71c9f8ccb719728a0503500abecfb5423e8088f474d686ee34b5fe3746c28e
      Image:         nvcr.io/nvidia/driver:525.60.13-ubuntu20.04
      Image ID:      nvcr.io/nvidia/driver@sha256:0ee0c585fa720f177734b3295a073f402d75986c1fe018ae68bd73fe9c21b8d8
     
     <snip>
     nvidia-fs-ctr:
      Container ID:  containerd://f5c597d59e1cf8747aa20b8c229a6f6edd3ed588b9d24860209ba0cc009c0850
      Image:         nvcr.io/nvidia/cloud-native/nvidia-fs:2.14.13-ubuntu20.04
      Image ID:      nvcr.io/nvidia/cloud-native/nvidia-fs@sha256:109485365f68caeaee1edee0f3f4d722fe5b5d7071811fc81c630c8a840b847b

    <snip>



Lastly, verify that NVIDIA kernel modules have been successfully loaded on the worker node:

.. code-block:: console

   $ lsmod | grep nvidia

   nvidia_fs             245760  0
   nvidia_peermem         16384  0
   nvidia_modeset       1159168  0
   nvidia_uvm           1048576  0
   nvidia              39059456  115 nvidia_uvm,nvidia_peermem,nvidia_modeset
   ib_core               319488  9 rdma_cm,ib_ipoib,nvidia_peermem,iw_cm,ib_umad,rdma_ucm,ib_uverbs,mlx5_ib,ib_cm
   drm                   491520  6 drm_kms_helper,drm_vram_helper,nvidia,mgag200,ttm






*****************
Further Reading
*****************

Refer to the following resources for more information:

  * GPUDirect RDMA: https://docs.nvidia.com/cuda/gpudirect-rdma/index.html

  * NVIDIA Network Operator: https://github.com/Mellanox/network-operator

  * Blog post on deploying the Network Operator: https://developer.nvidia.com/blog/deploying-gpudirect-rdma-on-egx-stack-with-the-network-operator/
