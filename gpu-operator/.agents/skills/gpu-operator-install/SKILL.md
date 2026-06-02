---
name: "gpu-operator-install"
description: "Installs the NVIDIA GPU Operator in a Kubernetes cluster with Helm. Use when users are getting started, installing the Operator for the first time, or checking installation prerequisites."
triggers:
  - NVIDIA GPU Operator
  - installation
  - Helm
  - Kubernetes
  - getting started
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - installation
  - helm
  - getting-started
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Installing the NVIDIA GPU Operator

Install the NVIDIA GPU Operator in a Kubernetes cluster with Helm, including
prerequisites, chart customization options, common deployment scenarios,
containerd configuration, and verification with sample GPU workloads.

> [!TIP]
> For installation on Red Hat OpenShift Container Platform, refer to [OpenShift installation steps](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/steps-overview.html).

## Prerequisites

- The `kubectl` and `helm` CLIs available on a client machine.
- Worker nodes configured with a container engine such as CRI-O or containerd.
- If using ClusterPolicy-managed drivers, all GPU worker nodes must run the same OS version (or pre-install the driver). With the driver CRD or pre-installed drivers, mixed OS versions are allowed.
- If the cluster uses Pod Security Admission, label the Operator namespace `pod-security.kubernetes.io/enforce=privileged`.
- Node Feature Discovery (NFD) is required; the Operator deploys it by default. If NFD is already running, set `nfd.enabled=false` at install.

> Full prerequisite detail (Helm install, PSA labeling, NFD detection) is in [references/prerequisites.md](references/prerequisites.md).

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All Helm command sequences, the full chart-options table, sample
manifests, and expected output live only in those reference files — do not
improvise commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Prerequisites | CLI tools, OS-version constraints, container engine, Pod Security Admission labeling, and Node Feature Discovery detection. | [references/prerequisites.md](references/prerequisites.md) |
| Install | Add the NVIDIA Helm repo and install the Operator with the default or a `--set`-customized configuration. | [references/install.md](references/install.md) |
| Chart options | Full table of the most frequently used `--set` Helm chart customization parameters and defaults. | [references/chart-options.md](references/chart-options.md) |
| Deployment scenarios | Namespace selection, excluding operands/driver on some nodes, RHEL, pre-installed drivers and/or toolkit, and custom driver images. | [references/deployment-scenarios.md](references/deployment-scenarios.md) |
| containerd config | `toolkit.env` configuration for containerd, RKE2, and MicroK8s, plus the commercially supported platforms table. | [references/containerd-config.md](references/containerd-config.md) |
| Verification | Run the CUDA VectorAdd and Jupyter Notebook sample workloads to confirm GPU scheduling. | [references/verification.md](references/verification.md) |

## Hard rules (apply across all phases)

- Replace `<gpu-operator-version>` with your target GPU Operator release (for example, the latest patch release on the [GPU Operator releases page](https://github.com/NVIDIA/gpu-operator/releases)). Never hardcode a specific version.
- The Operator and its operands install into the same namespace; choose it at install time (`default` if unspecified).
- If NFD already runs in the cluster, install with `nfd.enabled=false` to avoid a duplicate deployment.

## Verification

After install, run a sample GPU workload (CUDA VectorAdd) and confirm
`Test PASSED`. Exact manifests and commands are in
[references/verification.md](references/verification.md).
