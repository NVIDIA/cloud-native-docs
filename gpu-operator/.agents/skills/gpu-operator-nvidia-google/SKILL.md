---
name: "gpu-operator-nvidia-google"
description: "Guides users through installing and configuring the NVIDIA GPU Operator on Google GKE. Use when deploying GPU workloads on GKE or troubleshooting GKE-specific GPU Operator setup."
triggers:
  - NVIDIA GPU Operator
  - Google GKE
  - Kubernetes
  - installation
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - google-cloud
  - gke
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# NVIDIA GPU Operator with Google GKE

Deploy the NVIDIA GPU Operator on Google GKE Standard node pools. Two driver
strategies are supported: the **Google driver installer** (the Google installer
manages the driver; the Operator manages everything else) and the **NVIDIA
Driver Manager** (the Operator manages the driver and the full software
lifecycle). The choice depends on node OS. GKE Autopilot is not supported.

## Prerequisites

- You installed and initialized the Google Cloud CLI. Refer to [gcloud CLI overview](https://cloud.google.com/sdk/gcloud) in the Google Cloud documentation.
- You have a Google Cloud project to use for your GKE cluster. Refer to [Creating and managing projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects) in the Google Cloud documentation.
- You have the project ID for your Google Cloud project. Refer to [Identifying projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects) in the Google Cloud documentation.
- You know the machine type for the node pool and that the machine type is supported in your region and zone. Refer to [GPU platforms](https://cloud.google.com/compute/docs/gpus) in the Google Cloud documentation.

## Activation

Do this first: pick the driver-management approach matching your node OS from
the Phases table below, then **read the corresponding `references/<phase>.md`
file before acting**. All `gcloud`/`kubectl`/`helm` command sequences, the
`ResourceQuota` YAML, Helm `--set` values, and verification output live only in
those reference files — do not improvise commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Approaches | The two GKE strategies (Google Driver Installer vs NVIDIA Driver Manager), their supported OSes, the Autopilot non-support note, and the standard node-pool disabling flags. | [references/approaches.md](references/approaches.md) |
| Google Driver Installer | Create the node pool with GKE-device-plugin/driver disabled, set credentials, create the `gpu-operator` namespace + a `ResourceQuota`, apply the Google driver-installer daemonset (COS/Ubuntu), and Helm-install the Operator with `driver.enabled=false` and the GKE install paths. | [references/google-driver-installer.md](references/google-driver-installer.md) |
| NVIDIA Driver Manager | Create an `UBUNTU_CONTAINERD` cluster with the GKE device plugin disabled, set credentials, create the namespace + `ResourceQuota`, then install the Operator (via the `gpu-operator-install` skill) so it manages the driver. | [references/nvidia-driver-manager.md](references/nvidia-driver-manager.md) |

## Hard rules (apply across all phases)

- GKE Autopilot does not support the GPU Operator; use Standard node pools.
- On all GPU node pools, disable the GKE GPU device plugin (`--node-labels="gke-no-default-nvidia-gpu-device-plugin=true"`) and, for the Google-installer/NVIDIA-manager paths, the automatic driver install (`--accelerator ...,gpu-driver-version=disabled`).
- For the Google Driver Installer path, set the toolkit/driver install dir to the writable `/home/kubernetes/bin/nvidia` and install with `driver.enabled=false`.
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a version.

## Verification

Confirm GPU nodes advertise `nvidia.com/gpu` capacity and the
`nvidia-operator-validator` pod is `Completed`. Exact commands are in
[references/nvidia-driver-manager.md](references/nvidia-driver-manager.md).
