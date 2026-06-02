---
name: "gpu-operator-custom-driver"
description: "Shows how to provide custom NVIDIA driver parameters to GPU Operator driver containers. Use when changing driver module options or customizing driver container behavior."
triggers:
  - NVIDIA GPU Operator
  - driver parameters
  - NVIDIA driver
  - configuration
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - driver
  - configuration
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Customizing NVIDIA GPU Driver Parameters during Installation

The NVIDIA Driver kernel modules accept a number of parameters that customize
driver behavior. By default, the GPU Operator loads the kernel modules
(`nvidia`, `nvidia-modeset`, `nvidia-uvm`, and `nvidia-peermem`) with default
values. This skill shows how to supply custom kernel-module parameters through
a `ConfigMap` referenced at install time.

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes.
- The NVIDIA GPU Operator installed (use the `gpu-operator-install` skill).
- The GPU Operator deploys the NVIDIA driver as a container (`driver.enabled=true`, the default). Custom kernel-module parameters do not apply when you use pre-installed host drivers.

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All command sequences, manifest contents, and verification output
live only in those reference files — do not improvise commands from this
dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Configure | Create a `<module>.conf` parameter file, wrap it in a `ConfigMap`, and install the GPU Operator with `driver.kernelModuleConfig.name` pointing at it. | [references/configure.md](references/configure.md) |
| Example (`nvidia-uvm`) | A worked example that disables Heterogeneous Memory Management (HMM) via `uvm_disable_hmm`, plus how to verify the parameter on the node. | [references/example-nvidia-uvm.md](references/example-nvidia-uvm.md) |

## Hard rules (apply across all phases)

- The `<module>.conf` filename must match the kernel module the parameters apply to (`nvidia`, `nvidia-modeset`, `nvidia-uvm`, or `nvidia-peermem`).
- Parameters are key-value pairs, one per line.
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a version.

## Verification

Inspect the applied parameter on a GPU node under
`/sys/module/<module>/parameters/`. The worked example in
[references/example-nvidia-uvm.md](references/example-nvidia-uvm.md) shows the
exact commands and expected output.
