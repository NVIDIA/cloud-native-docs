---
name: "gpu-operator-kubevirt"
description: "Guides users through configuring the GPU Operator for KubeVirt virtual machine workloads. Use when deploying GPU-enabled VMs or troubleshooting KubeVirt GPU passthrough."
triggers:
  - NVIDIA GPU Operator
  - KubeVirt
  - virtual machines
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - kubevirt
  - virtual-machines
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# GPU Operator with KubeVirt

Provision worker nodes for GPU-accelerated virtual machines with KubeVirt using
the GPU Operator, supporting both GPU passthrough and NVIDIA vGPU workloads
alongside container workloads in the same cluster.

## Prerequisites

Before using KubeVirt with the GPU Operator, ensure the following prerequisites are configured on your cluster and nodes:

- The virtualization and IOMMU extensions (Intel VT-d or AMD IOMMU) are enabled in the BIOS.
- The host is booted with `intel_iommu=on` or `amd_iommu=on` on the kernel command line.
- If planning to use NVIDIA vGPU, SR-IOV must be enabled in the BIOS if your GPUs are based on the NVIDIA Ampere architecture or later. Refer to the [NVIDIA vGPU Documentation](https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#prereqs-vgpu) to ensure you have met all the prerequisites for using NVIDIA vGPU.
- KubeVirt is installed in the cluster.
- Starting with KubeVirt v0.58.2 and v0.59.1, set the `DisableMDEVConfiguration` feature gate (the exact `kubectl patch` command is in [references/configure-and-install.md](references/configure-and-install.md)).

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All Helm/kubectl command sequences, KubeVirt CR manifests, VM
manifests, and image-build steps live only in those reference files — do not
improvise commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Concepts | What KubeVirt is, per-node component split by `nvidia.com/gpu.workload.config` (`container`/`vm-passthrough`/`vm-vgpu`), assumptions/constraints, and the high-level workflow. | [references/concepts.md](references/concepts.md) |
| Configure & install | Label worker nodes, install the GPU Operator with `sandboxWorkloads.enabled` (with or without vGPU), add vGPU or GPU-passthrough resources to the KubeVirt CR, and create a VM with a GPU. | [references/configure-and-install.md](references/configure-and-install.md) |
| vGPU device config | Use the vGPU Device Manager ConfigMap and the `nvidia.com/vgpu.config` node label to declaratively create and switch vGPU device profiles. | [references/vgpu-device-config.md](references/vgpu-device-config.md) |
| Build vGPU Manager image | Download the vGPU software, clone the driver-container repo, and build/push the private NVIDIA vGPU Manager image (required only for vGPU). | [references/build-vgpu-manager.md](references/build-vgpu-manager.md) |

## Hard rules (apply across all phases)

- A GPU worker node runs exactly one workload type (`container`, `vm-passthrough`, or `vm-vgpu`) — never a combination.
- You must manually add all passthrough/vGPU resources to the KubeVirt CR `permittedHostDevices` list before assigning them to VMs.
- The GPU Operator does NOT install NVIDIA drivers inside the guest VMs; that is the user's responsibility.
- Building the vGPU Manager image is required only for vGPU; skip it for PCI passthrough only.
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a version.

## Verification

After install and CR configuration, confirm the `sandbox-device-plugin` pod is
`Running` and the expected `nvidia.com/...` GPU/vGPU resources appear in the
node's allocatable resources before assigning them to a VM. Exact commands are
in [references/configure-and-install.md](references/configure-and-install.md)
and [references/vgpu-device-config.md](references/vgpu-device-config.md).
