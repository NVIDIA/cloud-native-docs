---
name: "gpu-operator-container-device"
description: "Explains how to configure CDI and NRI support for GPU workloads. Use when enabling CDI, configuring containerd, or troubleshooting CDI-based GPU injection."
triggers:
  - NVIDIA GPU Operator
  - CDI
  - NRI
  - containerd
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - cdi
  - nri
  - containerd
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Container Device Interface (CDI) and Node Resource Interface (NRI) Plugin Support

Configure how the GPU Operator injects GPUs into containers. The **Container
Device Interface (CDI)** is the default, runtime-agnostic injection mechanism
(default-on since GPU Operator v25.10.0). The **Node Resource Interface (NRI)
Plugin** is an optional containerd extension that injects GPUs into GPU
management containers without requiring `runtimeClassName: nvidia`.

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes.
- The NVIDIA GPU Operator installed (use the `gpu-operator-install` skill).
- A container runtime that supports CDI. CDI is enabled by default starting with GPU Operator v25.10.0. The NRI Plugin requires containerd v1.7.30, v2.1.x, or v2.2.x and is not supported with CRI-O.

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All `kubectl patch` cluster-policy commands, Helm flags, and
verification output live only in those reference files — do not improvise
commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| CDI | What CDI is, its interaction with GPU Management Containers and `NVIDIA_VISIBLE_DEVICES`, and how to enable CDI after install or disable it (including the CRI-O validator toggle). | [references/cdi.md](references/cdi.md) |
| NRI Plugin | What the NRI Plugin is, its containerd requirements, how it removes the need for the `nvidia` runtime class / containerd config edits, and how to enable/disable it (install flag `cdi.nriPluginEnabled=true` or cluster-policy patch). | [references/nri.md](references/nri.md) |
| Verification | Confirm the toolkit and device-plugin daemonsets are `Running` and run a CUDA sample that reports `Test PASSED`. | [references/verification.md](references/verification.md) |

## Hard rules (apply across all phases)

- CDI is the default and recommended injection mechanism since GPU Operator v25.10.0; disabling it reverts to the legacy NVIDIA Container Toolkit stack.
- The NRI Plugin requires CDI enabled and a supported containerd version; it is not supported with CRI-O.
- When CDI is enabled and the NRI Plugin is not, GPU Management Containers using `NVIDIA_VISIBLE_DEVICES` must set `runtimeClassName: nvidia`.
- Enabling the NRI Plugin deletes the `nvidia` runtime class; disabling it recreates the class.

## Verification

Confirm the container-toolkit and device-plugin daemonsets are `Running` and a
CUDA sample reports `Test PASSED`. Exact commands are in
[references/verification.md](references/verification.md).
