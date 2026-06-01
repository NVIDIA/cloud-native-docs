---
name: "gpu-operator-custom-driver"
description: "Shows how to provide custom NVIDIA driver parameters to GPU Operator driver containers. Use when changing driver module options or customizing driver container behavior."
triggers:
  - NVIDIA GPU Operator
  - driver parameters
  - NVIDIA driver
  - configuration
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - driver
  - configuration
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Customizing NVIDIA GPU Driver Parameters during Installation

The NVIDIA Driver kernel modules accept a number of parameters which can be used to customize the behavior of the driver.
By default, the GPU Operator loads the kernel modules with default values.
On a machine with the driver already installed, you can list the parameter names and values with the `cat /proc/driver/nvidia/params` command.
You can pass custom parameters to the kernel modules that get loaded as part of the
NVIDIA Driver installation (`nvidia`, `nvidia-modeset`, `nvidia-uvm`, and `nvidia-peermem`).

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes.
- The NVIDIA GPU Operator installed (use the `gpu-operator-install` skill).
- The GPU Operator deploys the NVIDIA driver as a container (`driver.enabled=true`, the default). Custom kernel-module parameters do not apply when you use pre-installed host drivers.

## Configure Custom Driver Parameters

To pass custom parameters, execute the following steps.

1. Create a configuration file named `<module>.conf`, where `<module>` is the name of the kernel module the parameters are for.
   The file should contain parameters as key-value pairs -- one parameter per line.

   The following example shows the GPU firmware logging parameter being passed to the `nvidia` module.

   ```console
   $ cat nvidia.conf
   NVreg_EnableGpuFirmwareLogs=2
   ```

1. Create a `ConfigMap` for the configuration file.
   If multiple modules are being configured, pass multiple files when creating the `ConfigMap`.

   ```console
   $ kubectl create configmap kernel-module-params -n gpu-operator --from-file=nvidia.conf=./nvidia.conf
   ```

> [!NOTE]
> Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases).

1. Install the GPU Operator and set `driver.kernelModuleConfig.name` to the name of the `ConfigMap`
   containing the kernel module parameters.

   ```console
   $ helm install --wait --generate-name \
      -n gpu-operator --create-namespace \
      nvidia/gpu-operator \
      --version=<gpu-operator-version> \
      --set driver.kernelModuleConfig.name="kernel-module-params"
   ```

### Example using `nvidia-uvm` module

This example shows the Heterogeneous Memory Management (HMM) being disabled in the `nvidia-uvm` module.
Refer to [Simplifying GPU Application Development with Heterogeneous Memory Management](https://developer.nvidia.com/blog/simplifying-gpu-application-development-with-heterogeneous-memory-management/) for more information about HMM.

1. Create a configuration file named `nvidia-uvm.conf`:

   ```console
   $ cat nvidia-uvm.conf
   uvm_disable_hmm=1
   ```

1. Create a `ConfigMap` for the configuration file.
   If multiple modules are being configured, pass multiple files when creating the `ConfigMap`.

   ```console
   $ kubectl create configmap kernel-module-params -n gpu-operator --from-file=nvidia-uvm.conf=./nvidia-uvm.conf
   ```

1. Install the GPU Operator and set `driver.kernelModuleConfig.name` to the name of the `ConfigMap`
   containing the kernel module parameters.

   ```console
   $ helm install --wait --generate-name \
      -n gpu-operator --create-namespace \
      nvidia/gpu-operator \
      --version=<gpu-operator-version> \
      --set driver.kernelModuleConfig.name="kernel-module-params"
   ```

1. Verify the parameter has been correctly applied, go to `/sys/module/nvidia_uvm/parameters/` on the node:

   ```console
   $ ls /sys/module/nvidia_uvm/parameters/
   ```

   *Example Output*

   ```output
   ...
   uvm_disable_hmm                               uvm_perf_access_counter_migration_enable  uvm_perf_prefetch_min_faults
   uvm_downgrade_force_membar_sys                uvm_perf_access_counter_threshold         uvm_perf_prefetch_threshold
   ...
   ```

   Then check the value of the parameter:

   ```console
   $ cat /sys/module/nvidia_uvm/parameters/uvm_disable_hmm
   ```

   *Example Output*

   ```output
   Y
   ```
