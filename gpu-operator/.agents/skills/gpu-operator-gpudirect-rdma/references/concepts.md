<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# GPUDirect RDMA and GPUDirect Storage: Concepts and Common Prerequisites

## About GPUDirect RDMA and GPUDirect Storage

[GPUDirect RDMA](https://docs.nvidia.com/cuda/gpudirect-rdma/index.html) is a technology in NVIDIA GPUs that enables direct
data exchange between GPUs and a third-party peer device using PCI Express. The third-party devices could be network interfaces
such as NVIDIA ConnectX SmartNICs or BlueField DPUs, or video acquisition adapters.

[GPUDirect Storage](https://docs.nvidia.com/gpudirect-storage/overview-guide/index.html) (GDS) enables a direct data path between local or remote storage, such as NFS servers or NVMe/NVMe over Fabric (NVMe-oF), and GPU memory.
GDS performs direct memory access (DMA) transfers between GPU memory and storage.
DMA avoids a bounce buffer through the CPU.
This direct path increases system bandwidth and decreases the latency and utilization load on the CPU.

To support GPUDirect RDMA, userspace CUDA APIs are required.
The kernel mode support is provided by one of two approaches: DMA-BUF from the Linux kernel or the legacy `nvidia-peermem` kernel module.
NVIDIA recommends using the DMA-BUF rather than using the `nvidia-peermem` kernel module from the GPU Driver.

The Operator uses GDS driver version 2.17.5 or newer.
This version and higher is only supported with the NVIDIA Open GPU Kernel module driver.
In GPU Operator v25.3.0 and later, the `driver.kernelModuleType` default is `auto`, for the supported driver versions.
This configuration allows the GPU Operator to choose the recommended driver kernel module type depending on the driver branch and the GPU devices available.
Newer driver versions will use the open kernel module by default, however to make sure you are using the open kernel module, include `--set driver.kernelModuleType=open` command-line argument in your helm Operator install command.

In conjunction with the Network Operator, the GPU Operator can be used to
set up the networking related components such as network device kernel drivers and Kubernetes device plugins to enable
workloads to take advantage of GPUDirect RDMA and GPUDirect Storage.
Refer to the Network Operator [documentation](https://docs.nvidia.com/networking/software/cloud-orchestration/index.html) for installation information.

## Common Prerequisites

The prerequisites for configuring GPUDirect RDMA or GPUDirect Storage depend on whether you use DMA-BUF from the Linux kernel or the legacy `nvidia-peermem` kernel module.

| Technology | DMA-BUF | Legacy NVIDIA-peermem |
| --- | --- | --- |
| GPU Driver | An Open Kernel module driver is required. | Any supported driver. |
| CUDA | CUDA 11.7 or higher. The CUDA runtime is provided by the driver. | No minimum version. The CUDA runtime is provided by the driver. |
| GPU | Turing architecture data center, Quadro RTX, and RTX GPU or higher. | All data center, Quadro RTX, and RTX GPU or higher. |
| Network Device Drivers | MLNX_OFED or DOCA-OFED are optional. You can use the Linux driver packages from the package manager. | MLNX_OFED or DOCA-OFED are required. |
| Linux Kernel | 5.12 or higher. | No minimum version. |

* Make sure the network device drivers are installed.

  You can use the [Network Operator](https://docs.nvidia.com/networking/software/cloud-orchestration/index.html)
  to manage the driver lifecycle for MLNX_OFED and DOCA-OFED drivers.

  You can install the drivers on each host.
  Refer to [Adapter Software](https://docs.nvidia.com/networking/software/adapter-software/index.html)
  in the networking documentation for information about the MLNX_OFED, DOCA-OFED, and Linux inbox drivers.

* For installations on VMware vSphere, refer to the following additional prerequisites:

  * Make sure the network interface controller and the NVIDIA GPU are in the same PCIe IO root complex.
  * Enable the following PCI options:

    * `pciPassthru.allowP2P = true`
    * `pciPassthru.RelaxACSforP2P = true`
    * `pciPassthru.use64bitMMIO = true`
    * `pciPassthru.64bitMMIOSizeGB = 128`

    For information about configuring the settings, refer to the
    [Deploy an AI-Ready Enterprise Platform on vSphere 7](https://www.vmware.com/docs/deploy-an-ai-ready-enterprise-platform-on-vsphere-7-update-2#vm-settings-A)
    document from VMWare.

## Related Information

Refer to the following resources for more information:

  * GPUDirect RDMA: https://docs.nvidia.com/cuda/gpudirect-rdma/index.html

  * NVIDIA Network Operator: https://github.com/Mellanox/network-operator

  * Blog post on deploying the Network Operator: https://developer.nvidia.com/blog/deploying-gpudirect-rdma-on-egx-stack-with-the-network-operator/
