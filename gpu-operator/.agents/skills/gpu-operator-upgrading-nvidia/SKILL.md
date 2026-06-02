---
name: "gpu-operator-upgrading-nvidia"
description: "Guides users through upgrading the NVIDIA GPU Operator with Helm and handling CRD updates. Use when planning or performing a GPU Operator upgrade."
triggers:
  - NVIDIA GPU Operator
  - upgrade
  - Helm
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - upgrade
  - helm
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Upgrading the NVIDIA GPU Operator

Upgrade an existing GPU Operator installation. Because Helm does not
automatically upgrade existing CRDs, you either upgrade the CRDs manually before
`helm upgrade` or let the default `pre-upgrade` Helm hook do it. The Operator
also supports dynamic `ClusterPolicy` edits, and the driver daemonset has
additional upgrade considerations.

## Prerequisites

- A Kubernetes cluster with an existing NVIDIA GPU Operator installation and the `kubectl` and `helm` CLIs available.
- If your cluster uses Pod Security Admission (PSA) to restrict the behavior of pods, label the namespace for the Operator to set the enforcement policy to privileged:

  ```console
  $ kubectl label --overwrite ns gpu-operator pod-security.kubernetes.io/enforce=privileged
  ```

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All `kubectl`/`helm` command sequences, CRD-apply URLs, and
verification output live only in those reference files — do not improvise
commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Helm upgrade | Both CRD-handling options: Option 1 (manually apply the clusterpolicies/nvidiadrivers/NFD CRDs, then `helm upgrade`) and Option 2 (the default `pre-upgrade` Helm hook, using `--disable-openapi-validation`). | [references/helm-upgrade.md](references/helm-upgrade.md) |
| Cluster policy, driver controls, OLM, verification | Dynamic `ClusterPolicy` edits via `kubectl edit`, the pointer to driver-daemonset upgrade considerations, the OpenShift OLM upgrade path, and post-upgrade health verification. | [references/other-updates.md](references/other-updates.md) |

## Hard rules (apply across all phases)

- Helm does not auto-upgrade existing CRDs; either apply them manually (Option 1) or rely on the default Helm hook (Option 2, default since v24.9.0).
- Option 2 requires `--disable-openapi-validation` so Helm does not validate the new CR against the old CRD.
- Helm hooks run the Operator image; if it cannot be pulled, delete with `--no-hooks` to avoid a hung deletion.
- The NVIDIA driver daemonset has special upgrade behavior — see the `gpu-operator-driver-upgrades` skill.
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a version.

## Verification

After upgrade, confirm `nvidia-operator-validator` is `Completed` and the
driver/toolkit/device-plugin pods are `Running`. Exact commands are in
[references/other-updates.md](references/other-updates.md).
