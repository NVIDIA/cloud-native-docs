---
name: "gpu-operator-nvidia-amazon"
description: "Guides users through installing and configuring the NVIDIA GPU Operator on Amazon EKS. Use when deploying GPU workloads on AWS or troubleshooting EKS-specific GPU Operator setup."
triggers:
  - NVIDIA GPU Operator
  - Amazon EKS
  - AWS
  - Kubernetes
  - installation
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - aws
  - eks
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# NVIDIA GPU Operator with Amazon EKS

Deploy the NVIDIA GPU Operator on Amazon EKS. The recommended approach is to
create a GPU node group on an Operator-supported AMI (Ubuntu) so the Operator
manages the full driver/toolkit/device-plugin lifecycle, rather than relying on
the default Amazon Linux AMI's preinstalled (lagging) driver.

## Prerequisites

- An AWS account, plus the AWS CLI and `eksctl` installed and configured (see the per-example prerequisites below for details).
- The `kubectl` and `helm` CLIs available on a client machine.
- An Amazon EKS cluster, or the ability to create one, with a GPU-enabled node group that uses an AMI with an operating system that the GPU Operator supports.

## Activation

Do this first: identify which phase the user's request maps to in the Phases
table below, then **read the corresponding `references/<phase>.md` file before
acting**. All `eksctl`/`kubectl` command sequences, the `ClusterConfig` YAML,
and verification output live only in those reference files — do not improvise
commands from this dispatch layer.

## Phases

| Phase | Summary | Reference |
|-------|---------|-----------|
| Approaches | The two EKS options (default Amazon Linux without the Operator vs a GPU node group with the Operator), node-group/client-application choices (self-managed vs managed; eksctl/Console/Terraform), and the high-level steps + instance-type/AMI selection guidance. | [references/approaches.md](references/approaches.md) |
| eksctl example | A worked self-managed-node-group example: the `cluster-config.yaml` (`ClusterConfig`), `eksctl create cluster`, and post-install verification that GPU nodes advertise capacity and the validator completes. | [references/eksctl-example.md](references/eksctl-example.md) |

## Hard rules (apply across all phases)

- The GPU Operator does not support Amazon Linux 2; use a supported AMI (Ubuntu 20.04/22.04) and do not mix Amazon Linux 2 nodes with supported-OS nodes in the same cluster.
- Choose an instance type with enough pod IP addresses for your workload (e.g., `g4dn.xlarge` supports 29).
- AMI values are region- and Kubernetes-version-specific; look them up rather than hardcoding.
- After the node group exists, install the Operator via the `gpu-operator-install` skill.

## Verification

Confirm GPU nodes advertise `nvidia.com/gpu` capacity and the
`nvidia-operator-validator` pod is `Completed`. Exact commands are in
[references/eksctl-example.md](references/eksctl-example.md).
