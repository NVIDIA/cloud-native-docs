---
name: "gpu-operator-install-airgapped-environments"
description: "Guides users through installing the GPU Operator in air-gapped or restricted network environments. Use when users need mirrored images, private registries, or offline installation steps."
triggers:
  - NVIDIA GPU Operator
  - air-gapped
  - restricted network
  - installation
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - air-gapped
  - private-registry
  - installation
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Install NVIDIA GPU Operator in Air-Gapped Environments

Deploy the GPU Operator in clusters with restricted or no internet access. The
Operator normally needs the internet to pull container images and to let the
`driver` container download OS packages. In an air-gapped setup you mirror the
images into a local registry and (unless using precompiled drivers) mirror the
OS packages into a local package repository, then install with a customized
`values.yaml`.

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes that has restricted or no internet access.
- A private container registry reachable from the cluster, and a local package repository or HTTP proxy for operating-system packages.
- The `kubectl` and `helm` CLIs available on a client machine, plus a workstation with internet access for mirroring images and charts.

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All command sequences, the use-case matrix, full `values.yaml`
samples, repo-list/cert ConfigMap manifests, and the deploy commands live only
in those reference files — do not improvise commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Concepts | Why the Operator needs internet, the four supported connectivity use cases (HTTP-proxy full/limited, full air-gapped w/ and w/o proxy), DNS requirements, the OpenShift-disconnected pointer, and fetching the base `values.yaml`. | [references/concepts.md](references/concepts.md) |
| Local image registry | Pull NVIDIA images, tag and push them to your local registry (note the driver-image OS-suffix caveat), and the full per-component `values.yaml` repository/version/imagePullSecrets sample. | [references/local-image-registry.md](references/local-image-registry.md) |
| Local package repository | Mirror the required OS packages (Ubuntu/CentOS/RHEL lists), build repo-list files, create the `repo-config` (and optional `cert-config`) ConfigMaps, and wire them via `driver.repoConfig` / `driver.certConfig`. Not needed with precompiled drivers. | [references/local-package-repository.md](references/local-package-repository.md) |
| Deploy | Fetch the chart `.tgz` and `helm install` with the customized `values.yaml`; confirm pods are running. | [references/deploy.md](references/deploy.md) |

## Hard rules (apply across all phases)

- In a full air-gapped cluster, every image must be hosted in a local registry reachable by all nodes.
- The driver image version must be suffixed with the node OS (e.g., `${recommended}-ubuntu20.04`).
- A local package repository is not required if the cluster uses precompiled drivers (see the `gpu-operator-precompiled-drivers` skill).
- For self-signed HTTPS repositories, supply a `cert-config` ConfigMap; cert format/suffix is OS-dependent.
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a version.

## Verification

After deploying, run `kubectl get pods -n gpu-operator` and confirm all
containers are `Running`. Exact commands are in
[references/deploy.md](references/deploy.md).
