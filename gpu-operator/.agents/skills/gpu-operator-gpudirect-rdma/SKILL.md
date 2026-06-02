---
name: "gpu-operator-gpudirect-rdma"
description: "Guides users through GPUDirect RDMA and GPUDirect Storage configuration. Use when enabling high-performance networking or storage access for GPU workloads."
triggers:
  - NVIDIA GPU Operator
  - GPUDirect RDMA
  - GPUDirect Storage
  - networking
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - gpudirect
  - rdma
  - storage
  - networking
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# GPUDirect RDMA and GPUDirect Storage

Enable direct data paths between NVIDIA GPUs and peer devices (RDMA-capable NICs
for GPUDirect RDMA, or storage for GPUDirect Storage) using the GPU Operator
together with the NVIDIA Network Operator.

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes.
- The NVIDIA GPU Operator installed (use the `gpu-operator-install` skill).
- NVIDIA Network Operator installed for RDMA-capable networking, and compatible RDMA-capable NICs on the GPU nodes.
- A supported NVIDIA Open GPU Kernel module driver, which is required for GPUDirect Storage.

> The full kernel-mode requirements (DMA-BUF vs legacy `nvidia-peermem`) and the per-technology prerequisite matrix are in [references/concepts.md](references/concepts.md).

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All Helm/kubectl command sequences, manifests, and expected
verification output live only in those reference files — do not improvise
commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Concepts | What GPUDirect RDMA and GPUDirect Storage are, the DMA-BUF vs legacy `nvidia-peermem` kernel-mode approaches, the per-technology prerequisite matrix, vSphere requirements, and related links. | [references/concepts.md](references/concepts.md) |
| GPUDirect RDMA | Platform support, installing the GPU Operator with RDMA enabled (DMA-BUF or legacy), verifying the driver daemon set, and verifying with an end-to-end `ib_write_bw` data transfer between two pods. | [references/rdma.md](references/rdma.md) |
| GPUDirect Storage | Platform support, installing the GPU Operator with `gds.enabled=true`, and verifying that the `nvidia-fs` module and driver pods are loaded. | [references/storage.md](references/storage.md) |

## Hard rules (apply across all phases)

- NVIDIA recommends DMA-BUF over the legacy `nvidia-peermem` kernel module; only add `--set driver.rdma.enabled=true` when you specifically need the legacy module.
- GPUDirect Storage (GDS 2.17.5+) requires the NVIDIA Open GPU Kernel module driver.
- Add `--set driver.kernelModuleType=open` if you are using a driver version from a branch earlier than R570.
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a version.

## Verification

For RDMA, run the two-pod `ib_write_bw` data transfer and confirm a high
sustained transfer rate. For GDS, confirm the `nvidia-fs` kernel module is
loaded and the driver pods are `Running`. Exact commands and expected output
are in [references/rdma.md](references/rdma.md) and
[references/storage.md](references/storage.md).
