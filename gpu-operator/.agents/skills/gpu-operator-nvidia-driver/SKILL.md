---
name: "gpu-operator-nvidia-driver"
description: "Explains how to configure NVIDIA GPU Driver custom resources for driver lifecycle management. Use when users need custom driver configuration or mixed operating system support."
triggers:
  - NVIDIA GPU Operator
  - GPU driver
  - custom resource
  - driver configuration
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - driver
  - custom-resource
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# NVIDIA GPU Driver Custom Resource Definition

Configure NVIDIA GPU Driver (`NVIDIADriver`) custom resources to manage the
driver type and version per node, including mixed driver types, mixed versions,
and mixed operating systems within a single cluster.

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes.
- The NVIDIA GPU Operator installed with the driver custom resource enabled (`--set driver.nvidiaDriverCRD.enabled=true`). Use the `gpu-operator-install` skill to install the Operator.
- This feature is recommended for new cluster installations only. You cannot use ClusterPolicy-managed drivers and the `NVIDIADriver` custom resource at the same time.

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. The procedural detail (commands, manifest contents, field tables)
lives only in those reference files — read the relevant one rather than
improvising from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Concepts | What the `NVIDIADriver` CRD is, its limitations, CRD-vs-ClusterPolicy comparison, driver daemon sets, default custom resource, feature compatibility, and the full field reference table. | [references/concepts.md](references/concepts.md) |
| Install | Install the GPU Operator with the driver CRD enabled, including optional node labeling and the Helm repository/install commands. | [references/install.md](references/install.md) |
| Manifests | Sample `NVIDIADriver` manifests: one type/version on all nodes, multiple versions, precompiled on all nodes, and precompiled on some nodes. | [references/manifests.md](references/manifests.md) |
| Upgrade & verify | Patch the driver version (rolling update) and verify that custom resources are applied and driver pods are running. | [references/upgrade-and-verify.md](references/upgrade-and-verify.md) |

## Hard rules (apply across all phases)

- Never use ClusterPolicy-managed drivers and the `NVIDIADriver` custom resource at the same time — choose one per cluster.
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a specific version.
- This feature is recommended for new cluster installations only; upgrades from ClusterPolicy-managed drivers are not supported.

## Verification

After applying driver custom resources, confirm they are reconciled and the
driver pods are `Running`. The exact commands are in
[references/upgrade-and-verify.md](references/upgrade-and-verify.md).
