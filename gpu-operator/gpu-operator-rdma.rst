.. Date: Aug 4 2021
.. Author: pramarao

.. headings (h1/h2/h3/h4/h5) are # * = -

.. _operator-rdma:

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

Prerequisites
===============

First, install the Network Operator on the system to ensure that the `MOFED <https://github.com/Mellanox/ofed-docker>`_ drivers are setup in the system.  

Installation
==============

With v1.8, the GPU Operator provides an option to load the ``nvidia-peermem`` kernel module during the bootstrap of the NVIDIA driver daemonset. 

.. code-block:: console

   $ helm install --wait --generate-name \
        nvidia/gpu-operator \
        --set driver.rdma.enabled=true

During the installation, an `initContainer` is used with the driver daemonset to wait on the Mellanox OFED (MOFED) drivers to be ready. 
This initContainer checks for Mellanox NICs on the node and ensures that the necessary kernel symbols are exported MOFED kernel drivers. 
        

For more information on ``nvidia-peermem``, refer to the `documentation <https://docs.nvidia.com/cuda/gpudirect-rdma/index.html#nvidia-peermem>`_.

*****************
Platform Support
*****************

The following Linux distributions are supported:

* Ubuntu 20.04 LTS

The following NVIDIA drivers are supported:

* R470 datacenter drivers (470.57.02+)

*****************
Further Reading
*****************

Refer to the following resources for more information:
#. GPUDirect RDMA: https://docs.nvidia.com/cuda/gpudirect-rdma/index.html
#. NVIDIA Network Operator: https://github.com/Mellanox/network-operator
#. Blog post on deploying the Network Operator: https://developer.nvidia.com/blog/deploying-gpudirect-rdma-on-egx-stack-with-the-network-operator/
