<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Overview, Supported Components, and Validated Distributions

## Overview

The NVIDIA GPU Operator now offers government-ready components for NVIDIA AI Enterprise customers.
Government ready is NVIDIA's designation for software that meets applicable security requirements for deployment in your FedRAMP High or equivalent sovereign use case.
For more information on NVIDIA's government-ready support, refer to the white paper [AI Software for Regulated Environments](https://docs.nvidia.com/ai-enterprise/planning-resource/ai-software-regulated-environments-white-paper/latest/index.html).

## Supported GPU Operator Components

Refer to the [GPU Operator Component Matrix](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/life-cycle-policy.html#gpu-operator-component-matrix) for a full list of supported government-ready GPU Operator components.

Artifacts for these components are available from the [NVIDIA NGC Catalog](https://registry.ngc.nvidia.com/orgs/nvstaging/teams/cloud-native/containers/gpu-driver-stig-fips).

> [!NOTE]
> Not all GPU Operator components and features are available as government-ready containers in this release.
> For example, NVIDIA GDS Driver, NVIDIA Confidential Computing Manager, and NVIDIA GDRCopy Driver are not yet supported.

## Validated Kubernetes Distributions

The government-ready NVIDIA GPU Operator has been validated on the following Kubernetes distributions:

- Canonical Kubernetes 1.34 with Ubuntu Pro 24.04 and FIPS-compliant kernel
- Red Hat OpenShift 4.19 in FIPS mode
- Rancher Kubernetes Engine 2 with Ubuntu 24.04
- VMware VKS with Ubuntu 24.04
