---
name: "gpu-operator-driver-upgrades"
description: "Explains GPU driver upgrade behavior and configuration. Use when planning driver upgrades or troubleshooting driver upgrade workflows managed by the GPU Operator."
triggers:
  - NVIDIA GPU Operator
  - GPU driver
  - driver upgrades
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - driver
  - upgrades
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# GPU Driver Upgrades

Manage upgrades of the containerized NVIDIA driver. Because the driver kernel
modules must be unloaded and reloaded on each restart, the Operator automates
the disable-clients / unload / restart-pod / install / re-enable sequence. Two
mechanisms are available: the recommended **upgrade controller** (default-on,
observable, with pause/skip and per-node state) and the legacy
**`k8s-driver-manager`** init container.

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes.
- The NVIDIA GPU Operator installed (use the `gpu-operator-install` skill).
- The driver deployed as a container by the Operator (`driver.enabled=true`, the default). The GPU Operator only manages the lifecycle of containerized drivers; drivers pre-installed on the host are not managed by the Operator.

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All `kubectl patch` cluster-policy commands, `upgradePolicy` /
`driver.manager` configuration blocks, the state-machine reference, metrics, and
troubleshooting commands live only in those reference files — do not improvise
commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Concepts | Why driver upgrades need special handling (kernel-module unload/reload) and the five-step upgrade sequence the Operator automates; containerized-only scope. | [references/concepts.md](references/concepts.md) |
| Upgrade controller (recommended) | Patch `driver.version` (plus repo/image on OpenShift), monitor per-node `gpu-driver-upgrade-state`, the full `upgradePolicy` config (maxParallel/maxUnavailable/gpuPodDeletion/drain), the upgrade state machine, pausing/skipping, Prometheus metrics, and troubleshooting. | [references/upgrade-controller.md](references/upgrade-controller.md) |
| Without the upgrade controller | The legacy `k8s-driver-manager` init-container path: patch `driver.version`, watch the daemonset rollout, and the `driver.manager` env configuration (GPU-pod-eviction/auto-drain/OnDelete strategy). | [references/without-controller.md](references/without-controller.md) |

## Hard rules (apply across all phases)

- The GPU Operator only manages containerized drivers; host-preinstalled drivers are not upgraded by the Operator.
- The upgrade controller is the recommended path and is enabled by default; no new features are being added to `k8s-driver-manager`.
- `driver.upgradePolicy.drain.enable=true` is cluster-wide and disruptive (evicts all pods, including non-GPU workloads); enable only as a fallback when `gpuPodDeletion` cannot remove all GPU pods, and scope it with `podSelector`.
- On OpenShift, patch `driver.version`, `driver.repository`, and `driver.image` together.
- Driver version values shown (e.g., `580.95.05`) are illustrative; use the version appropriate to your deployment.

## Verification

Poll the per-node `nvidia.com/gpu-driver-upgrade-state` label until every GPU
node reports `upgrade-done`. The exact `kubectl` command and the
`upgrade-failed` troubleshooting flow are in
[references/upgrade-controller.md](references/upgrade-controller.md).
