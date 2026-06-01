---
name: "gpu-operator-kata-containers"
description: "Guides users through configuring Kata Containers for GPU workloads with the GPU Operator. Use when deploying sandboxed GPU workloads with Kata Containers."
triggers:
  - NVIDIA GPU Operator
  - Kata Containers
  - sandboxed workloads
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - kata-containers
  - sandboxed-workloads
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Deploy with Kata Containers

Configure the NVIDIA GPU Operator to run sandboxed GPU workloads with
[Kata Containers](https://katacontainers.io/), which run pods inside lightweight
VMs for stronger workload isolation via GPU passthrough.

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes, and the `kubectl` and `helm` CLIs available.
- Hosts configured to enable hardware virtualization and Access Control Services (ACS) in the BIOS. With some AMD CPUs and BIOSes, ACS might be grouped under Advanced Error Reporting (AER).
- Hosts configured to support IOMMU. Check with `ls /sys/kernel/iommu_groups`; if the host is not configured, add the `intel_iommu=on` (or `amd_iommu=on` for AMD CPUs) kernel command-line argument.
- For Kubernetes versions older than v1.34, the `KubeletPodResourcesGet` feature gate must be explicitly enabled.

> Full prerequisite detail (hardware/BIOS, IOMMU, driver removal, Helm install, feature-gate config) is in [references/prerequisites.md](references/prerequisites.md).

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All command sequences, manifest contents, and verification output
live only in those reference files — do not improvise commands from this
dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Concepts | What Kata Containers are, benefits, limitations/restrictions, cluster topology (per-node component split), and the high-level configuration flow. | [references/concepts.md](references/concepts.md) |
| Prerequisites | Detailed hardware/BIOS, IOMMU configuration, host driver removal, Helm install, and the `KubeletPodResourcesGet` feature gate. | [references/prerequisites.md](references/prerequisites.md) |
| Install | Label nodes for Kata, install the upstream `kata-deploy` Helm chart, install the GPU Operator in Kata sandbox mode, and optionally configure GPU/NVSwitch resource type names. | [references/install.md](references/install.md) |
| Workload | Run a sample GPU workload with the `kata-qemu-nvidia-gpu` runtime class, verify it, and troubleshoot. | [references/workload.md](references/workload.md) |

## Hard rules (apply across all phases)

- For GPU passthrough, all GPUs on a node must be assigned to one Kata VM; configuring only some GPUs per node is not supported. vGPU is not supported.
- NVIDIA supports the Operator and Kata Containers with the containerd runtime only.
- A labeled Kata node runs only Kata workloads — it cannot also run traditional GPU container workloads.
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a version.

## Verification

After install, confirm the Sandbox Device Plugin and VFIO Manager pods are
`Running`, then run the sample workload and confirm `Test PASSED`. Exact
commands and expected output are in [references/install.md](references/install.md)
and [references/workload.md](references/workload.md).
