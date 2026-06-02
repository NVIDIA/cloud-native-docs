<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Configure Custom Driver Parameters

The NVIDIA Driver kernel modules accept a number of parameters that customize
driver behavior. By default, the GPU Operator loads the kernel modules with
default values. On a machine with the driver already installed, you can list
the parameter names and values with the `cat /proc/driver/nvidia/params`
command. You can pass custom parameters to the kernel modules that get loaded
as part of the NVIDIA Driver installation (`nvidia`, `nvidia-modeset`,
`nvidia-uvm`, and `nvidia-peermem`).

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
