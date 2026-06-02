---
name: "gpu-operator-install-governmentready-environments"
description: "Guides users through government-ready GPU Operator installation considerations. Use when deploying in hardened or regulated Kubernetes environments."
triggers:
  - NVIDIA GPU Operator
  - government-ready
  - installation
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - government-ready
  - installation
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# NVIDIA GPU Operator Government Ready

Install the government-ready NVIDIA GPU Operator for NVIDIA AI Enterprise
customers deploying into FedRAMP High or equivalent sovereign environments. The
government-ready path uses STIG/FIPS driver images from NGC, an Ubuntu Pro token
for FIPS-kernel package access, and a privileged pod-security namespace policy.

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes.
- The `kubectl` and `helm` CLIs available on a client machine.
- An NVIDIA AI Enterprise subscription. Government-ready components are available to NVIDIA AI Enterprise customers for FedRAMP High or equivalent sovereign use cases.

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All command sequences, secret manifests, Helm `--set` values, and
verification steps live only in those reference files — do not improvise
commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Overview | What government-ready means (FedRAMP High / sovereign), which GPU Operator components are supported (and which are not yet), and the validated Kubernetes distributions. | [references/overview.md](references/overview.md) |
| Install | The full Canonical-Kubernetes install: detailed prerequisites (NGC token, Ubuntu Pro token, Helm, namespace, optional service mesh), install NFD, create the NGC pull secret + Ubuntu Pro token secret, label the namespace privileged, and Helm-install with the STIG/FIPS driver image. | [references/install.md](references/install.md) |
| Update Ubuntu Pro token | Rotate the Ubuntu Pro token post-install by editing the secret named in `driver.secretEnv`. | [references/update-ubuntu-pro-token.md](references/update-ubuntu-pro-token.md) |

## Hard rules (apply across all phases)

- Government-ready components require an active NVIDIA AI Enterprise subscription and NGC API token.
- On Canonical Kubernetes with the FIPS kernel, an Ubuntu Pro token (as a Kubernetes secret) is required for the driver container to fetch kernel headers.
- Label the Operator namespace `pod-security.kubernetes.io/enforce=privileged` before installing.
- Install NFD (upstream version aligned to the component matrix) before the Operator; set `nfd.enabled=false` on the Operator install.
- For OpenShift, follow the dedicated government-ready OpenShift install guide instead.

## Verification

Confirm the Operator and STIG/FIPS driver operands deploy successfully in the
target namespace per [references/install.md](references/install.md); for
OpenShift use the linked OpenShift guide's verification.
