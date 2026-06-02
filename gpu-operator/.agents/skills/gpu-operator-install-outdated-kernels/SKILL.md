---
name: "gpu-operator-install-outdated-kernels"
description: "Explains how to install the GPU Operator when nodes run outdated kernels. Use when driver containers fail because kernel versions are older than supported defaults."
triggers:
  - NVIDIA GPU Operator
  - outdated kernels
  - driver containers
  - installation
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - kernels
  - driver
  - installation
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Considerations when Installing with Outdated Kernels in Cluster

When a GPU node runs a kernel that is not the latest available, the `driver`
container can fail to find matching kernel packages (kernel-headers,
kernel-devel) and logs `Could not resolve Linux kernel version`. Upgrading to
the latest kernel is the preferred fix; when that is not an option, this skill
provides a workaround that mounts an archived package repository into the
`driver` container.

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes.
- The `kubectl` and `helm` CLIs available on a client machine.
- One or more GPU nodes whose running kernel is not the latest available kernel, where the `driver` container reports `Could not resolve Linux kernel version`.

## Activation

Do this first: read the workaround reference below **before acting**. All
command sequences, the repo-list file contents, the `values.yaml` snippets,
and the install command live only in the reference file — do not improvise
commands from this dispatch layer.

## Steps

| Step | Summary | Reference |
|------|---------|-----------|
| Workaround | Identify the running kernel, find the matching archived package repo, create a repo-list `ConfigMap` in `gpu-operator`, set `driver.repoConfig` in `values.yaml` (Ubuntu vs RHEL/CentOS/RHCOS paths), and install. | [references/workaround.md](references/workaround.md) |

## Hard rules (apply across all phases)

- Prefer upgrading the node kernel; the archived-repo workaround is for when upgrading is not an option.
- Create the repo-config `ConfigMap` in the `gpu-operator` namespace.
- Use the `destinationDir` matching the node OS family (`/etc/apt/sources.list.d` for Ubuntu, `/etc/yum.repos.d` for RHEL/CentOS/RHCOS).
- Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases). Never hardcode a version.

## Verification

After deploying, run `kubectl get pods -n gpu-operator` and confirm all
containers are `Running`. Exact commands are in
[references/workaround.md](references/workaround.md).
