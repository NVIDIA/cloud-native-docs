---
name: "gpu-operator-install-http-proxy"
description: "Guides users through installing the GPU Operator with HTTP proxy settings. Use when clusters require proxy configuration for image pulls or network access."
triggers:
  - NVIDIA GPU Operator
  - HTTP proxy
  - installation
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - proxy
  - installation
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Install GPU Operator in Proxy Environments

Deploy the GPU Operator in clusters behind an HTTP proxy. By default the
Operator needs internet access to pull container images and to let the
`driver` container download OS packages; this skill configures the `driver`
container to route that traffic through the proxy. Configuring Kubernetes /
container-runtime components for the proxy is out of scope (not GPU-Operator-specific).

> [!TIP]
> Using precompiled drivers removes the need for the `driver` container to download OS packages (use the `gpu-operator-precompiled-drivers` skill).

## Prerequisites

- A Kubernetes cluster configured with HTTP proxy settings, where the container runtime is enabled with the HTTP proxy.
- The `kubectl` and `helm` CLIs available on a client machine.

## Activation

Do this first: choose the phase matching your platform from the Phases table
below, then **read the corresponding `references/<phase>.md` file before
acting**. All command sequences, `values.yaml` content, and manifest details
live only in those reference files — do not improvise commands from this
dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Openshift | Use the cluster-wide Proxy object; the Operator auto-injects proxy ENV into the `driver` container. Skip the non-Openshift phase. | [references/openshift.md](references/openshift.md) |
| Configure and deploy (non-Openshift) | Fetch `values.yaml`, set `driver.env` proxy variables (upper- and lowercase HTTP_PROXY/HTTPS_PROXY/NO_PROXY), fetch the chart, and install with the updated values. | [references/configure-and-deploy.md](references/configure-and-deploy.md) |

## Hard rules (apply across all phases)

- On Openshift, do not hand-edit `driver.env`; configure the cluster-wide Proxy object and let the Operator inject the values.
- Set proxy variables in both uppercase and lowercase forms.
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a version.

## Verification

After install, run `kubectl get pods -n gpu-operator` and confirm all
containers reach `Running`/`Completed`. Exact commands are in
[references/configure-and-deploy.md](references/configure-and-deploy.md).
