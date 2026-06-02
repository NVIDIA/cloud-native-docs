---
name: "gpu-operator-nvidia-azure"
description: "Guides users through installing and configuring the NVIDIA GPU Operator on Azure AKS. Use when deploying GPU workloads on Azure or troubleshooting AKS-specific GPU Operator setup."
triggers:
  - NVIDIA GPU Operator
  - Azure AKS
  - Microsoft Azure
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - azure
  - aks
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# NVIDIA GPU Operator with Azure Kubernetes Service

Deploy the NVIDIA GPU Operator on Azure AKS. AKS GPU images ship with a
preinstalled NVIDIA driver and Container Toolkit, so the right approach depends
on whether you create the node pool with `--skip-gpu-driver-install` (Operator
manages the full lifecycle) or run on the default image (Operator runs with
driver/toolkit deployment disabled).

## Prerequisites

- An Azure subscription and the Azure CLI (`az`) installed and configured.
- The `kubectl` and `helm` CLIs available on a client machine.
- An AKS cluster with a GPU-enabled node pool that uses a supported operating system. Use a node pool created with `--skip-gpu-driver-install` so that the GPU Operator manages the driver lifecycle.

## Activation

Do this first: pick the approach matching your AKS node pool from the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All command sequences and expected output live only in those
reference files — do not improvise commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Approaches | The three AKS options: `--skip-gpu-driver-install` node pool (Operator manages everything), default AKS without the Operator (and its DCGM/validation/MIG limitations), and Operator-with-preinstalled-driver-and-toolkit. | [references/approaches.md](references/approaches.md) |
| Install (preinstalled driver/toolkit) | Add the NVIDIA Helm repo and install the Operator with `driver.enabled=false`, `toolkit.enabled=false`, and `operator.runtimeClass=nvidia-container-runtime`; confirm the CUDA validator completes. | [references/install-preinstalled.md](references/install-preinstalled.md) |

## Hard rules (apply across all phases)

- On default AKS images (driver + toolkit preinstalled), install the Operator with `driver.enabled=false` and `toolkit.enabled=false` so it does not redeploy those components.
- For full lifecycle management, create the node pool with `--skip-gpu-driver-install` and install the Operator normally (no special flags).
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a version.

## Verification

Confirm the Operator ran the CUDA validation container to completion via
`kubectl get pods -n gpu-operator -l app=nvidia-cuda-validator` (expect
`Completed`). Exact commands are in
[references/install-preinstalled.md](references/install-preinstalled.md).
