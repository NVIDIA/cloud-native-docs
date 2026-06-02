<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Overview and Known Issues

Dynamic Resource Allocation (DRA) is a Kubernetes concept for flexibly requesting, configuring, and sharing specialized devices like GPUs.
DRA puts device configuration and scheduling into the hands of device vendors through drivers such as the DRA Driver for GPUs.
This documentation outlines how to install the NVIDIA DRA Driver for GPUs v25.12.0 and later with the NVIDIA GPU Operator.

Before using the DRA Driver for GPUs, it is recommended that you are familiar with the following concepts:

* [Upstream Kubernetes DRA documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/).
* [DRA Driver repository documentation](https://github.com/NVIDIA/k8s-dra-driver-gpu)

## Overview

With NVIDIA's DRA Driver for GPUs, your Kubernetes workload can allocate and consume the following two types of resources:

* GPU allocation: for controlled sharing and dynamic reconfiguration of GPUs. This functionality is a replacement for the traditional GPU allocation method used by the NVIDIA Kubernetes Device Plugin.
* ComputeDomains: An abstraction for robust and secure [Multi-Node NVLink (MNNVL)](https://docs.nvidia.com/multi-node-nvlink-systems/index.html) for NVIDIA GB200 and similar systems.

You can use the NVIDIA DRA Driver for GPUs with the NVIDIA GPU Operator to deploy and manage your GPUs and ComputeDomains.

## Known Issues

* There is a known issue where the NVIDIA Driver Manager is not aware of the DRA driver kubelet plugin, and will not correctly evict it on pod restarts.
  You must label the nodes you plan to use with DRA GPU allocation and pass the node label in the GPU Operator Helm command in the `driver.manager.env` flag.
  This enables the NVIDIA Driver Manager to evict the GPU kubelet plugin correctly on driver container upgrades.
* For A100 GPUs, the MIG manager does not automatically evict the DRA kubelet plugin during MIG configuration changes.
  If the DRA kubelet plugin is deployed before a MIG change, then you must manually restart the DRA kubelet plugin.

## Additional Documentation

Refer to the [DRA Driver for GPUs repository](https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki) for additional documentation, including

* [Upgrade Guide](https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki/Installation#upgrading)
* [Troubleshooting Guide](https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki/Troubleshooting)
