---
name: "gpu-operator-timeslicing-gpus"
description: "Explains GPU sharing and time-slicing configuration. Use when users need multiple workloads to share GPUs or need to configure time-sliced GPU resources."
triggers:
  - NVIDIA GPU Operator
  - GPU sharing
  - time-slicing
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - gpu-sharing
  - time-slicing
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Time-Slicing GPUs in Kubernetes

Oversubscribe NVIDIA GPUs by defining time-sliced replicas with the GPU Operator
and NVIDIA Kubernetes Device Plugin, so multiple workloads share a GPU without
the hardware memory/fault isolation that MIG provides.

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes.
- The NVIDIA GPU Operator installed (use the `gpu-operator-install` skill).
- NVIDIA GPUs that support time-slicing. Time-slicing shares access to a GPU among workloads without memory or fault isolation; for hardware-isolated partitioning, use MIG (use the `gpu-operator-multiinstance` skill).

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All config map manifests, the field-reference table, `kubectl`/Helm
command sequences, and expected node-label output live only in those reference
files — do not improvise commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Concepts | What GPU time-slicing is, how it differs from MIG, supported platforms/resource types, limitations, and the node-label changes (`.replicas`, `-SHARED` suffix). | [references/concepts.md](references/concepts.md) |
| Configuration | The config map field reference plus all four ways to apply it: one cluster-wide config, multiple node-specific configs, configuring before install, and updating an existing config map. | [references/configuration.md](references/configuration.md) |
| Verification | Confirm the node advertises the additional GPU resources (for both `renameByDefault` modes) and deploy a multi-replica sample workload to validate sharing. | [references/verification.md](references/verification.md) |

## Hard rules (apply across all phases)

- Time-slicing provides NO memory or fault isolation between replicas; use MIG when isolation is required.
- Requesting more than one time-sliced GPU does NOT grant proportional compute; set `failRequestsGreaterThanOne=true` to enforce awareness of this.
- The Operator does not monitor time-slicing config maps; after editing one, manually restart the device plugin daemonset to apply changes.
- The config map must live in the same namespace as the GPU Operator.
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a version.

## Verification

After applying a config, confirm the node's `nvidia.com/gpu` (or
`nvidia.com/gpu.shared`) capacity reflects the configured replica count, then
optionally deploy the multi-replica sample workload. Exact commands and
expected label output are in [references/verification.md](references/verification.md).
