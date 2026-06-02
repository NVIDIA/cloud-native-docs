<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Example: `nvidia-uvm` module

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
