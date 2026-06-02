<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Container Device Interface (CDI)

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

> [!NOTE]
> Setting `runtimeClassName: nvidia` in the pod specification is not required when the NRI Plugin is enabled in GPU Operator.
> Refer to About the Node Resource Interface (NRI) Plugin.

## Enabling CDI

CDI is enabled by default during installation in GPU Operator v25.10.0 and later.
Follow the instructions for installing the Operator with Helm on the getting-started page.

CDI is also enabled by default during a Helm upgrade to GPU Operator v25.10.0 and later.

### Enabling CDI After Installation

CDI is enabled by default in GPU Operator v25.10.0 and later.
Use the following procedure to enable CDI if you disabled CDI during installation.

#### Procedure

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

## Disabling CDI

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

   > [!TIP]
   > You can run `kubectl get nodes -o wide` and view the `CONTAINER-RUNTIME`
   > column to determine if your nodes use CRI-O.

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
