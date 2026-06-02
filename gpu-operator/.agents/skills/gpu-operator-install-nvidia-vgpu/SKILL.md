---
name: "gpu-operator-install-nvidia-vgpu"
description: "Guides users through installing the GPU Operator with NVIDIA vGPU. Use when deploying virtual GPU software or configuring vGPU licensing with Kubernetes."
triggers:
  - NVIDIA GPU Operator
  - NVIDIA vGPU
  - installation
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - vgpu
  - installation
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Using NVIDIA vGPU

Install the GPU Operator on NVIDIA vGPU. Because the vGPU guest driver may not
be publicly redistributed, the flow is: download the licensed vGPU software,
build and push a private vGPU driver container, configure the cluster with the
NVIDIA License System token + image pull secret, then install the Operator
pointing at your private driver image.

## Prerequisites

Before installing the GPU Operator on NVIDIA vGPU, ensure the following:

- The NVIDIA vGPU Host Driver version 12.0 (or later) is pre-installed on all hypervisors hosting NVIDIA vGPU accelerated Kubernetes worker node virtual machines. Refer to the [NVIDIA Virtual GPU Software Documentation](https://docs.nvidia.com/grid/) for details.
- You must have access to the NVIDIA Enterprise Application Hub at https://nvid.nvidia.com/dashboard/ and the NVIDIA Licensing Portal.
- Your organization must have an instance of a Cloud License Service (CLS) or a Delegated License Service (DLS).
- You must generate and download a client configuration token for your CLS instance or DLS instance. Refer to the [NVIDIA License System Quick Start Guide](https://docs.nvidia.com/license-system/latest/nvidia-license-system-quick-start-guide/) for information about generating a token.

  > [!NOTE]
  > For vGPU 18.0 and later, ensure that you use DLS 3.4 or later.

- You have access to a private registry such as NVIDIA NGC Private Registry and can push container images to the registry.
- Git and Docker are required to build the vGPU driver image from the source repository and push it to the private registry.
- Each Kubernetes worker node in the cluster has access to the private registry. Private registry access is usually managed through image pull secrets. You specify the secrets to the NVIDIA GPU Operator when you install the Operator with Helm.

  > [!NOTE]
  > Uploading the NVIDIA vGPU driver to a publicly available repository or otherwise publicly sharing the driver is a violation of the NVIDIA vGPU EULA.

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All download steps, build commands, secret manifests, Helm `--set`
flags, and verification output live only in those reference files — do not
improvise commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Concepts | What NVIDIA vGPU is, the namespace/`oc`-vs-`kubectl` notes (incl. OpenShift defaults), the License-System-only requirement, and where to find platform support. | [references/concepts.md](references/concepts.md) |
| Download + build driver | Download the vGPU software and driver catalog from the Licensing Portal, then clone `gpu-driver-container`, stage the `*-grid.run` + catalog, set build env vars, `make build-vgpuguest-<os>`, and push to your private registry. | [references/build-driver.md](references/build-driver.md) |
| Configure + install | Create `gridd.conf`, the `client_configuration_token.tok`, the `licensing-config` secret and the registry image-pull secret, then `helm install` pointing `driver.repository`/`driver.version`/`driver.imagePullSecrets`/`driver.licensingConfig.secretName` at your private image; verify. | [references/configure-and-install.md](references/configure-and-install.md) |

## Hard rules (apply across all phases)

- NVIDIA vGPU is only supported with the NVIDIA License System (CLS or DLS).
- Publicly sharing or uploading the NVIDIA vGPU driver violates the NVIDIA vGPU EULA; build into a private registry only.
- Docker is the only supported tool for building the driver container image (multi-arch additionally needs buildx).
- The client configuration token file must be named exactly `client_configuration_token.tok`.
- On OpenShift, the default namespace is `nvidia-gpu-operator` and `kubectl` becomes `oc`.

## Verification

Confirm the `nvidia-vgpu-driver-daemonset` pods are `Running` and
`nvidia-operator-validator` is `Completed`. Exact commands are in
[references/configure-and-install.md](references/configure-and-install.md).
