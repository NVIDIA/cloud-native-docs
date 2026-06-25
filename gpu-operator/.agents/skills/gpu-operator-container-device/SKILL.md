---
name: "gpu-operator-container-device"
description: "Explains how to configure CDI and NRI support for GPU workloads. Use when enabling CDI, configuring containerd, or troubleshooting CDI-based GPU injection. Trigger keywords - NVIDIA GPU Operator, CDI, NRI, containerd, Kubernetes."
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Container Device Interface (CDI) and Node Resource Interface (NRI) Plugin Support

This page gives an overview of CDI and NRI Plugin support in the GPU Operator.

## About Container Device Interface (CDI)

The [Container Device Interface (CDI)](https://github.com/cncf-tags/container-device-interface/blob/main/SPEC.md)
is an open specification for container runtimes that abstracts what access to a device, such as an NVIDIA GPU, means,
and standardizes access across container runtimes. Popular container runtimes can read and process the specification to
ensure that a device is available in a container. CDI simplifies adding support for devices such as NVIDIA GPUs because
the specification is applicable to all container runtimes that support CDI.

Starting with GPU Operator v25.10.0, CDI is used by default for enabling GPU support in containers running on Kubernetes.
Specifically, CDI support in container runtimes, like containerd and cri-o, is used to inject GPU(s) into workload
containers. This differs from prior GPU Operator releases where CDI was used via a CDI-enabled `nvidia` runtime class.

If you are upgrading from a version of the GPU Operator prior to v25.10.0, where CDI was disabled by default, and you are upgrading to v25.10.0 or later, where CDI is enabled by default, no configuration changes are required for standard workloads using GPU allocation through the Device Plugin.
For workloads that already have `runtimeClassName: nvidia` set in their pod spec YAML, no change is necessary.

Use of CDI is transparent to cluster administrators and application developers.
The benefits of CDI are largely to reduce development and support for runtime-specific
plugins.

### CDI and GPU Management Containers

When CDI is enabled in GPU Operator versions v25.10.0 and later, GPU Management Containers that use the `NVIDIA_VISIBLE_DEVICES` environment variable to get GPU access, bypassing GPU allocation via the Device Plugin or DRA Driver for GPUs, must set `runtimeClassName: nvidia` in the pod specification.
A GPU Management Container is a container that requires access to all GPUs without them being allocated by Kubernetes.
Examples of GPU Management Containers include monitoring agents and device plugins.

It is recommended that `NVIDIA_VISIBLE_DEVICES` only be used by GPU Management Containers.

**Note:**

Setting `runtimeClassName: nvidia` in the pod specification is not required when the NRI Plugin is enabled in GPU Operator.
Refer to About the Node Resource Interface (NRI) Plugin.

## Step 1: Enabling CDI

CDI is enabled by default during installation in GPU Operator v25.10.0 and later.
Follow the instructions for installing the Operator with Helm on the getting-started page.

CDI is also enabled by default during a Helm upgrade to GPU Operator v25.10.0 and later.

### Enabling CDI After Installation

CDI is enabled by default in GPU Operator v25.10.0 and later.
Use the following procedure to enable CDI if you disabled CDI during installation.

### Procedure
1. Enable CDI by modifying the cluster policy:

   ```console
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type='json' \
       -p='[{"op": "replace", "path": "/spec/cdi/enabled", "value":true}]'
   ```

   *Example Output*

   ```output
   clusterpolicy.nvidia.com/cluster-policy patched
   ```

1. (Optional) Confirm that the container toolkit and device plugin pods restart:

   ```console
   $ kubectl get pods -n gpu-operator
   ```

   *Example Output*

## Step 2: Disabling CDI

While CDI is the default and recommended mechanism for injecting GPU support into containers, you can
disable CDI and use the legacy NVIDIA Container Toolkit stack instead with the following procedure:

1. If your nodes use the CRI-O container runtime, then temporarily disable the
   GPU Operator validator:

   ```console
   $ kubectl label nodes \
       nvidia.com/gpu.deploy.operator-validator=false \
       -l nvidia.com/gpu.present=true \
       --overwrite
   ```

   **Tip:**

   You can run `kubectl get nodes -o wide` and view the `CONTAINER-RUNTIME`
   column to determine if your nodes use CRI-O.
1. Disable CDI by modifying the cluster policy:

   ```console
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type='json' \
       -p='[{"op": "replace", "path": "/spec/cdi/enabled", "value":false}]'
   ```

   *Example Output*

   ```output
   clusterpolicy.nvidia.com/cluster-policy patched
   ```

1. If you temporarily disabled the GPU Operator validator, re-enable the validator:

   ```console
   $ kubectl label nodes \
       nvidia.com/gpu.deploy.operator-validator=true \
       nvidia.com/gpu.present=true \
       --overwrite
   ```

## About the Node Resource Interface (NRI) Plugin

Node Resource Interface (NRI) is a standardized interface for plugging in extensions, called NRI Plugins, to OCI-compatible container runtimes like containerd.
NRI Plugins serve as hooks which intercept pod and container lifecycle events and perform functions including injecting devices to a container, topology aware placement strategies, and more. For more details on NRI, refer to the [NRI overview](https://github.com/containerd/nri/tree/main?tab=readme-ov-file#background) in the containerd repository.

When enabled in the GPU Operator, the NVIDIA Container Toolkit daemonset will run an NRI Plugin on every GPU node.
The purpose of the NRI Plugin is to inject GPUs into GPU management containers that use the `NVIDIA_VISIBLE_DEVICES` environment variable to get GPU access, bypassing GPU allocation via the Device Plugin or DRA Driver for GPUs.

In previous GPU Operator versions, device injection was handled by the `nvidia` container runtime. With CDI and the NRI Plugin enabled, the `nvidia` runtime class is no longer needed. When enabling the NRI plugin during install, the `nvidia` runtime class will not be created. If you enable the NRI Plugin after install, the `nvidia` runtime class will be deleted.

Additionally, with the NRI Plugin enabled, modifications to the container runtime configuration are no longer needed. For example, no modifications are made to containerd’s config.toml file.
This means that on platforms that configure containerd in a non-standard way, like k3s, k0s, and Rancher Kubernetes Engine 2, users no longer need to configure environment variables like `CONTAINERD_CONFIG`, `CONTAINERD_SOCKET`, or `RUNTIME_CONFIG_SOURCE`.

## Step 3: Enabling the NRI Plugin

The NRI Plugin requires the following:

- CDI to be enabled in the GPU Operator.

- containerd v1.7.30, v2.1.x, or v2.2.x.
  If you are not using the latest containerd version, check that both CDI and NRI are enabled in the containerd configuration file before deploying GPU Operator.

  **Note:**

  Enabling the NRI plugin is not supported with cri-o.
To enable the NRI Plugin during installation, follow the instructions for installing the Operator with Helm on the getting-started page and include the `--set cdi.nriPluginEnabled=true` argument in your Helm command.

### Enabling the NRI Plugin After Installation

1. Enable NRI Plugin by modifying the cluster policy:

   ```console
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type='json' \
       -p='[{"op": "replace", "path": "/spec/cdi/nriPluginEnabled", "value":true}]'
   ```

   *Example Output*

   ```output
   clusterpolicy.nvidia.com/cluster-policy patched
   ```

   After enabling the NRI Plugin, the `nvidia` runtime class will be deleted.

1. (Optional) Confirm that the container toolkit and device plugin pods restart:

   ```console
   $ kubectl get pods -n gpu-operator
   ```

   *Example Output*

## Step 4: Disabling the NRI Plugin

Disable the NRI Plugin and use the `nvidia` runtime class instead with the following procedure:

Disable the NRI Plugin by modifying the cluster policy:

```console
$ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type='json' \
      -p='[{"op": "replace", "path": "/spec/cdi/nriPluginEnabled", "value":false}]'
```

*Example Output*

```output
clusterpolicy.nvidia.com/cluster-policy patched
```

After disabling the NRI Plugin, the `nvidia` runtime class will be created.
