---
name: "gpu-operator-multiinstance"
description: "Explains MIG strategies, labels, and configuration with the GPU Operator. Use when partitioning GPUs, enabling MIG, or troubleshooting MIG resource exposure."
triggers:
  - NVIDIA GPU Operator
  - MIG
  - Multi-Instance GPU
  - GPU partitioning
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - mig
  - gpu-partitioning
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# GPU Operator with MIG

Partition MIG-capable NVIDIA GPUs into separate, secure GPU instances using the
GPU Operator's MIG Manager: choose a MIG strategy, enable MIG at install, label
nodes with MIG profiles, and reconfigure or disable MIG dynamically.

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes.
- The NVIDIA GPU Operator installed (use the `gpu-operator-install` skill).
- One or more MIG-capable NVIDIA GPUs (such as A100, A30, H100, or H200). The MIG Manager runs by default only on nodes with GPUs that support MIG.

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All Helm/kubectl command sequences, MIG profile labels, ConfigMap
manifests, and expected node-label output live only in those reference files —
do not improvise commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Concepts & install | What MIG is, the `single` vs `mixed` strategies, enabling MIG and deploying MIG Manager at install time, how MIG profiles/ConfigMaps are generated, and the MIG Manager architecture. | [references/concepts-and-install.md](references/concepts-and-install.md) |
| Examples | Worked examples: single strategy, mixed strategy, dynamic reconfiguration, custom ConfigMap at install, custom ConfigMap applied manually, verification, and disabling MIG. | [references/examples.md](references/examples.md) |
| Preinstalled drivers | Using MIG Manager when GPU drivers are preinstalled on the host (`driver.enabled=false`) and managing host GPU clients via the `clients.yaml` ConfigMap. | [references/preinstalled-drivers.md](references/preinstalled-drivers.md) |

## Hard rules (apply across all phases)

- You must enable MIG and choose a strategy (`single` or `mixed`) at install before you can configure MIG profiles.
- MIG Manager requires that no user workloads run on the GPUs being configured; cordon nodes that may reboot (for example CSP environments with `WITH_REBOOT`).
- Use `mixed` strategy whenever a node's configuration specifies more than one instance profile.
- Custom MIG ConfigMaps must contain a key named `config.yaml`.
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a version.

## Verification

After labeling a node with a MIG profile, confirm `nvidia.com/mig.config.state:
success` on the node and run a sample CUDA workload that requests a MIG resource.
Exact commands and expected label output are in
[references/examples.md](references/examples.md).
