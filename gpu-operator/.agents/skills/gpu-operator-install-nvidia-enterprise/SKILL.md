---
name: "gpu-operator-install-nvidia-enterprise"
description: "Guides users through installing the GPU Operator with NVIDIA AI Enterprise. Use when deploying licensed NVIDIA AI Enterprise GPU software on Kubernetes."
triggers:
  - NVIDIA GPU Operator
  - NVIDIA AI Enterprise
  - installation
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - nvidia-ai-enterprise
  - installation
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# NVIDIA AI Enterprise

Install the GPU Operator with NVIDIA AI Enterprise. There are two installation
paths: the **vGPU guest driver** (required on virtualization platforms; uses a
prebuilt licensed image and an NGC-hosted Bash installer script with NVIDIA
License System tokens) and the **data center driver** (bare-metal / non-virtualized;
public Helm chart and driver containers matched to your release's driver branch).

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes.
- The `kubectl` and `helm` CLIs available on a client machine.
- An NVIDIA AI Enterprise subscription with access to the NVIDIA Enterprise Catalog (NGC) and an NGC API key for the private registry.

## Activation

Do this first: pick the installation path (and any token-update task) matching
your platform from the Phases table below, then **read the corresponding
`references/<phase>.md` file before acting**. All command sequences, manifest
edits, and verification output live only in those reference files — do not
improvise commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Concepts | What NVIDIA AI Enterprise is, the vGPU-guest-driver vs data-center-driver decision table, and where to check the platform support matrix. | [references/concepts.md](references/concepts.md) |
| vGPU driver install | For virtualization platforms: prerequisites (client config token, NGC API key), export env vars, download the NGC installer script, rename the token, and run `gpu-operator-nvaie.sh install`. | [references/vgpu-driver.md](references/vgpu-driver.md) |
| NLS token update | Rotate the NLS client license token: create `gridd.conf`, build a `licensing-config-new` Secret, and repoint `licensingConfig.secretName` in the cluster policy. | [references/nls-token-update.md](references/nls-token-update.md) |
| Data center driver install | For bare-metal/non-virtualized: identify the supported driver branch + matching GPU Operator version, then install via the `gpu-operator-install` skill with `--version=<supported-version>`; verify licensing. | [references/datacenter-driver.md](references/datacenter-driver.md) |

## Hard rules (apply across all phases)

- Installations on virtualization platforms must use the vGPU driver path; the data center driver path is for bare-metal / non-virtualized clusters only.
- The vGPU path requires a valid NLS client configuration token renamed to `client_configuration_token.tok`.
- Prefer `secrets(secretName)` for licensing config; `configMap(configMapName)` is deprecated.
- Match the driver branch to your NVIDIA AI Enterprise release per the component matrix; never hardcode an arbitrary version.

## Verification

Confirm driver pods are `Running`, `nvidia-operator-validator` is `Completed`,
and `nvidia-smi -q | grep "License Status"` reports `Licensed`. Exact commands
are in [references/datacenter-driver.md](references/datacenter-driver.md).
