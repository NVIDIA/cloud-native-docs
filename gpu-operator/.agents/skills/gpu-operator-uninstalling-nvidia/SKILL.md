---
name: "gpu-operator-uninstalling-nvidia"
description: "Guides users through uninstalling the NVIDIA GPU Operator and cleaning up related resources. Use when removing the Operator from a Kubernetes cluster."
triggers:
  - NVIDIA GPU Operator
  - uninstall
  - removal
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - uninstall
  - cleanup
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Uninstalling the GPU Operator

Remove the NVIDIA GPU Operator from a Kubernetes cluster and clean up the
resources it leaves behind, including driver custom resources, CRDs, and loaded
kernel modules.

## Prerequisites

- A Kubernetes cluster with the NVIDIA GPU Operator installed.
- The `kubectl` and `helm` CLIs available on a client machine, with access to the cluster and the namespace where the Operator is installed (typically `gpu-operator`).

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All command sequences and expected output live only in those
reference files — do not improvise commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Procedure | Optionally delete `nvidiadriver` custom resources, delete the Operator Helm release, confirm pods are gone, and (note) unload lingering driver kernel modules / handle Helm-hook image-pull failures. | [references/procedure.md](references/procedure.md) |
| CRD cleanup | Why the `clusterpolicies` and `nvidiadrivers` CRDs survive a chart delete by default, and the two ways to remove them (`operator.cleanupCRD=true` post-delete hook, or manual `kubectl delete crd`). | [references/crd-cleanup.md](references/crd-cleanup.md) |

## Hard rules (apply across all phases)

- Helm does not delete CRDs on chart removal by default; the `clusterpolicies.nvidia.com` CRD persists unless explicitly cleaned up.
- Helm hooks run the Operator image itself; if the image cannot be pulled, delete with `--no-hooks` to avoid hanging.
- Driver kernel modules can remain loaded after uninstall; reboot or `rmmod` to fully remove them.

## Verification

After deleting the Operator release, confirm `kubectl get pods -n gpu-operator`
reports `No resources found.` Exact commands and expected output are in
[references/procedure.md](references/procedure.md).
