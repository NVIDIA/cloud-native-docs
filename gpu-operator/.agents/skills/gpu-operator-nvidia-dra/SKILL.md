---
name: "gpu-operator-nvidia-dra"
description: "Explains how to install and use the NVIDIA DRA Driver for GPUs. Use when users ask about Dynamic Resource Allocation, DRA installation, or GPU resource claims."
triggers:
  - NVIDIA GPU Operator
  - DRA
  - Dynamic Resource Allocation
  - Kubernetes
  - installation
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - dra
  - dynamic-resource-allocation
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# NVIDIA DRA Driver for GPUs

Install and use the NVIDIA DRA Driver for GPUs (v25.12.0+) with the GPU
Operator. Dynamic Resource Allocation (DRA) lets workloads flexibly request,
configure, and share GPUs. The driver provides two independently-usable
resources: **GPU allocation** (a replacement for the Device Plugin's allocation)
and **ComputeDomains** (Multi-Node NVLink for GB200-class systems).

## Prerequisites

> [!TIP]
> You can use the NVIDIA DRA Driver for GPUs ComputeDomain and GPU allocation independently or together in the same cluster. They have different prerequisites; to use both features together, configure your cluster to meet the prerequisites for both.

For GPU allocation with the GPU Operator:

- Kubernetes v1.34.2 or newer. If you plan to use traditional extended resource requests such as `nvidia.com/gpu` with the DRA driver, enable the [`DRAExtendedResource`](https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/#extended-resource) feature gate.
- GPU Operator v25.10.0 or later with the NVIDIA Kubernetes Device Plugin disabled to avoid conflicts with the DRA Driver for GPUs. The DRA Driver requires Container Device Interface (CDI) enabled in the container runtime and NVIDIA Driver version 580 or later, both of which are default in GPU Operator v25.10.0 and later.
- Label the nodes you plan to use for GPU allocation (for example, `nvidia.com/dra-kubelet-plugin=true`) and use them as node selectors in the DRA driver Helm chart.

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All `kubectl`/`helm` command sequences, `values.yaml` content
(including GKE-specific values), and validation output live only in those
reference files — do not improvise commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Concepts | What DRA is, the GPU-allocation vs ComputeDomain resource types, and the known issues (Driver-Manager eviction label requirement; A100/MIG manual restart). | [references/concepts.md](references/concepts.md) |
| Install the GPU Operator | Label DRA nodes, add the Helm repo, and install the Operator with the Device Plugin disabled — the GPU-allocation path adds the `driver.manager.env` eviction-label flags; the ComputeDomain path does not. | [references/install-gpu-operator.md](references/install-gpu-operator.md) |
| Install the DRA driver + validate | Create the DRA-driver `values.yaml` (standard and GKE variants), install `nvidia-dra-driver-gpu` for GPU-allocation and/or ComputeDomain (Operator- vs host-provided driver root), and validate pods + DeviceClasses. | [references/install-dra-driver.md](references/install-dra-driver.md) |
| Enable health checks | Turn on the alpha `NVMLDeviceHealthCheck` feature gate for XID-based GPU health monitoring, and inspect health via kubelet logs and ResourceSlices. | [references/health-checks.md](references/health-checks.md) |

## Hard rules (apply across all phases)

- Disable the NVIDIA Kubernetes Device Plugin (`devicePlugin.enabled=false`) to avoid conflicts with the DRA driver's GPU allocation.
- For GPU allocation, pass the node eviction label through `driver.manager.env` and ensure it matches the DRA driver chart's `kubeletPlugin.nodeSelector` label.
- `gpuResourcesEnabledOverride=true` is required to fully enable GPU-allocation support; disable a feature with `resources.gpus.enabled=false` or `resources.computeDomains.enabled=false`.
- Set `nvidiaDriverRoot=/run/nvidia/driver` for Operator-managed drivers (GKE: `/home/kubernetes/bin/nvidia`); for host/pre-installed drivers set `/` or omit.
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a version.

## Verification

Confirm the `nvidia-dra-driver-gpu` controller and kubelet-plugin pods are
`Running` and the expected DeviceClasses (`gpu.nvidia.com`, `mig.nvidia.com`,
and/or the `compute-domain-*` classes) exist. Exact commands are in
[references/install-dra-driver.md](references/install-dra-driver.md).
