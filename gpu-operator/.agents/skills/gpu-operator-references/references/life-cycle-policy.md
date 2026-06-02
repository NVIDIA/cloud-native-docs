<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->
# NVIDIA GPU Operator Versioning

NVIDIA GPU Operator is versioned following the calendar versioning convention.

The version follows the pattern `YY.MM.PP`, such as 23.6.0, 23.6.1, and 23.9.0.
The first two fields, `YY.MM` identify a major version and indicates when the major version was initially released.
The third field, `PP`, identifies the patch version of the major version.
Patch releases typically include critical bug and CVE fixes, but can include minor features.

## NVIDIA GPU Operator Life Cycle

When a new major version of NVIDIA GPU Operator is released, the previous major version enters deprecated support and only receives patch release updates for critical bug and CVE fixes.
All prior major versions enter end of support and are no longer supported and do not receive patch release updates.

The product life cycle and versioning are subject to change in the future.

> [!NOTE]
> Upgrades are only supported within a major release or to the next major release.
| GPU Operator Version | Status |
| --- | --- |
| 26.3.x | Supported |
| 25.10.x | Deprecated |
| 25.3.x and lower | End of Support |
# GPU Operator Component Matrix

The following table shows the operands and default operand versions that correspond to a GPU Operator version.

When post-release testing confirms support for newer versions of operands, these updates are identified as *recommended updates* to a GPU Operator version.
Refer to Upgrading the NVIDIA GPU Operator for more information.

> [!NOTE]
> All the following components are supported as government-ready in the NVIDIA GPU Operator v26.3, except for NVIDIA GDS Driver, NVIDIA Confidential Computing Manager, and NVIDIA GDRCopy Driver.
**D** = Default driver, **R** = Recommended driver

| 1 Component | 1 GPU Operator Version |  |
| --- | --- | --- |
| v26.3.0 | v26.3.1 |  |
| NVIDIA GPU Driver ki_ | [595.71.05](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-595-71-05/index.html) [595.58.03](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-595-58-03/index.html) [590.48.01](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-590-48-01/index.html) [580.159.03](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-159-03/index.html) (**R**) [580.126.20](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-126-20/index.html) (**D**) [570.211.01](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-211-01/index.html) [535.309.01](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-309-01/index.html) [535.288.01](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-288-01/index.html) | [595.71.05](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-595-71-05/index.html) [595.58.03](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-595-58-03/index.html) [590.48.01](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-590-48-01/index.html) [580.159.03](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-159-03/index.html) (**R**) [580.126.20](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-126-20/index.html) (**D**) [570.211.01](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-211-01/index.html) [535.309.01](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-309-01/index.html) [535.288.01](https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-288-01/index.html) |
| NVIDIA Driver Manager for Kubernetes | [v0.10.0](https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager) |  |
| NVIDIA Container Toolkit | [1.19.0](https://github.com/NVIDIA/nvidia-container-toolkit/releases) |  |
| NVIDIA Kubernetes Device Plugin | [0.19.0](https://github.com/NVIDIA/k8s-device-plugin/releases) |  |
| DCGM Exporter | [v4.5.1-4.8.0](https://github.com/NVIDIA/dcgm-exporter/releases) |  |
| Node Feature Discovery | [v0.18.3](https://github.com/kubernetes-sigs/node-feature-discovery/releases/) |  |
| NVIDIA GPU Feature Discovery for Kubernetes | [0.19.0](https://github.com/NVIDIA/k8s-device-plugin/releases) |  |
| NVIDIA MIG Manager for Kubernetes | [0.14.0](https://github.com/NVIDIA/mig-parted/blob/main/CHANGELOG.md) |  |
| DCGM | [4.5.2-1](https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html) |  |
| Validator for NVIDIA GPU Operator | v26.3.0 | v26.3.1 |
| NVIDIA KubeVirt GPU Device Plugin | [v1.5.0](https://github.com/NVIDIA/kubevirt-gpu-device-plugin) |  |
| NVIDIA vGPU Device Manager | [v0.4.2](https://github.com/NVIDIA/vgpu-device-manager) |  |
| NVIDIA GDS Driver gds_ | [2.27.3](https://github.com/NVIDIA/gds-nvidia-fs/releases) |  |
| NVIDIA Confidential Computing Manager for Kubernetes | [v0.3.0](https://github.com/NVIDIA/k8s-cc-manager/releases) | [v0.4.0](https://github.com/NVIDIA/k8s-cc-manager/releases) |
| NVIDIA GDRCopy Driver | [v2.5.1](https://github.com/NVIDIA/gdrcopy/releases) | [v2.5.2](https://github.com/NVIDIA/gdrcopy/releases) |
| NVIDIA Kata Sandbox Device Plugin | [v0.0.2](https://github.com/NVIDIA/sandbox-device-plugin/releases) | [v0.0.3](https://github.com/NVIDIA/sandbox-device-plugin/releases) |
> [!NOTE]
> - Driver version could be different with NVIDIA vGPU, as it depends on the driver
>   version downloaded from the [NVIDIA Licensing Portal](https://ui.licensing.nvidia.com).
> - The GPU Operator is supported on all active NVIDIA data center production drivers.
>   Refer to [Supported Drivers and CUDA Toolkit Versions](https://docs.nvidia.com/datacenter/tesla/drivers/index.html#supported-drivers-and-cuda-toolkit-versions)
>   for more information.
