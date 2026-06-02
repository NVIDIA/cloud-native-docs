---
name: "gpu-operator-install-service-mesh"
description: "Guides users through GPU Operator service mesh considerations. Use when deploying with Istio or troubleshooting sidecar injection and service mesh interactions."
triggers:
  - NVIDIA GPU Operator
  - service mesh
  - Istio
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - service-mesh
  - istio
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Install GPU Operator with Service Mesh

Run the NVIDIA GPU Operator in a cluster that uses an Istio CNI or Linkerd CNI
service mesh. The core requirement is that the driver's `k8s-driver-manager`
init container can reach the Kubernetes API server, which conflicts with
default sidecar injection.

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes.
- A service mesh based on Istio CNI or Linkerd CNI installed in the cluster.
- The `kubectl` and `helm` CLIs available on a client machine.

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All command sequences and verification output live only in those
reference files — do not improvise commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Considerations | Why service-mesh sidecars break the driver init container's API-server access, and why NVIDIA recommends disabling injection for the Operator namespace. | [references/considerations.md](references/considerations.md) |
| Disable injection | Label the `gpu-operator` namespace to disable Istio/Linkerd sidecar injection, then install (via the `gpu-operator-install` skill) and verify pods start. | [references/disable-injection.md](references/disable-injection.md) |

## Hard rules (apply across all phases)

- Disable sidecar injection for the `gpu-operator` namespace specifically; do not disable it cluster-wide.
- Use the injection-disable label matching your mesh (`istio-injection=disabled` for Istio, `linkerd.io/inject=disabled` for Linkerd).
- For Operator install options and scenarios, defer to the `gpu-operator-install` skill rather than duplicating install steps here.

## Verification

After labeling and installing, confirm all Operator operands (including
`nvidia-driver-daemonset` and `nvidia-operator-validator`) report `Running` or
`Completed`. A stuck `k8s-driver-manager` init container indicates injection is
still enabled for the namespace. Exact commands are in
[references/disable-injection.md](references/disable-injection.md).
