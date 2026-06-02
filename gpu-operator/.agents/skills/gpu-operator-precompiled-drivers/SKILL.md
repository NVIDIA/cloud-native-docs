---
name: "gpu-operator-precompiled-drivers"
description: "Explains how to use precompiled NVIDIA driver containers with the GPU Operator. Use when reducing driver build time or selecting precompiled driver images."
triggers:
  - NVIDIA GPU Operator
  - precompiled drivers
  - driver containers
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - driver
  - precompiled-drivers
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Precompiled Driver Containers

Use precompiled NVIDIA driver containers so driver pods do not download kernel
headers / compiler tooling / OS packages and do not spend compute compiling
modules at runtime — valuable for air-gapped or resource-constrained sites. This
skill covers checking image availability, enabling/disabling precompiled
support, and building a custom precompiled image when no published variant
matches your kernel.

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes.
- The `kubectl` and `helm` CLIs available on a client machine.
- A supported operating system for which NVIDIA publishes precompiled driver containers. Refer to the [GPU Operator Component Matrix](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/life-cycle-policy.html#gpu-operator-component-matrix) for supported operating systems.

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All command sequences, image-tag patterns, Helm `--set` flags,
cluster-policy patches, and the custom-image build steps live only in those
reference files — do not improvise commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Concepts | What precompiled driver containers are, their benefits, and the limitations/restrictions (x86_64-only, LTSB branch, supported kernel variants, no vGPU/GDS). | [references/concepts.md](references/concepts.md) |
| Availability | The `<driver-branch>-<kernel-version>-<os-tag>` naming pattern and how to check (NGC web catalog or `ngc registry image info nvidia/driver`) whether an image exists for your kernel. | [references/availability.md](references/availability.md) |
| Enable / disable | Enable during install (`driver.usePrecompiled=true` + `driver.version`), enable after install (cluster-policy patch), and disable (cluster-policy patch back to a conventional driver version). | [references/enable-disable.md](references/enable-disable.md) |
| Build custom image | When no published variant matches: prerequisites, clone `gpu-driver-container`, set build env vars, `docker build`, push to a private registry, and wire it up via `driver.repository` / `driver.imagePullSecrets`. | [references/build-custom.md](references/build-custom.md) |

## Hard rules (apply across all phases)

- Precompiled driver containers are x86_64-only, support the most recent LTSB driver branch, and do not support NVIDIA vGPU or GPUDirect Storage (GDS).
- NVIDIA publishes images only for the `aws`, `azure`, `generic`, `nvidia`, and `oracle` kernel variants; other variants require a custom build.
- When precompiled is active, driver pod names include the kernel semantic version (e.g., `5.15.0-69-generic`); when disabled, they do not — use this to verify the mode.
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a version.

## Verification

Confirm the driver daemonset pods are `Running` and that their names do (precompiled)
or do not (conventional) include a Linux kernel semantic version. Exact commands are in
[references/enable-disable.md](references/enable-disable.md).
