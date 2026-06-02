<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Enabling and Disabling Precompiled Driver Container Support

## Enabling Support During Installation

> [!NOTE]
> Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases).

Refer to the common instructions for installing the Operator with Helm at install-gpu-operator.
Specify the `--set driver.usePrecompiled=true` and `--set driver.version=<driver-branch>` arguments like the following example command:

```console
$ helm install --wait gpu-operator \
     -n gpu-operator --create-namespace \
     nvidia/gpu-operator \
     --version=<gpu-operator-version> \
     --set driver.usePrecompiled=true \
     --set driver.version="<driver-branch>"
```

Specify a value like `525` for `<driver-branch>`.
Refer to Common Chart Customization Options for information about other installation options.

## Enabling Support After Installation

Perform the following steps to enable support for precompiled driver containers:

1. Enable support by modifying the cluster policy:

   ```shell
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type='json' \
      -p='[
        {"op":"replace", "path":"/spec/driver/usePrecompiled", "value":true},
        {"op":"replace", "path":"/spec/driver/version", "value":"<driver-branch>"}
      ]'
   ```

   Specify a value like `525` for `<driver-branch>`.

   *Example Output*

   ```output
   clusterpolicy.nvidia.com/cluster-policy patched
   ```

1. Optional: Confirm that the driver daemon set pods terminate:

   ```console
   $ kubectl get pods -n gpu-operator
   ```

   *Example Output*

1. Confirm that the driver container pods are running:

   ```console
   $ kubectl get pods -l app=nvidia-driver-daemonset -n gpu-operator
   ```

   *Example Output*

   Ensure that the pod names include a Linux kernel semantic version number like `5.15.0-69-generic`.

## Disabling Support for Precompiled Driver Containers

Perform the following steps to disable support for precompiled driver containers:

1. Disable support by modifying the cluster policy:

   ```shell
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type='json' \
       -p='[
         {"op": "replace", "path": "/spec/driver/usePrecompiled", "value":false},
         {"op": "replace", "path": "/spec/driver/version", "value":"550.90.07"},
       ]'
   ```

   *Example Output*

   ```output
   clusterpolicy.nvidia.com/cluster-policy patched
   ```

1. Confirm that the conventional driver container pods are running:

   ```console
   $ kubectl get pods -l app=nvidia-driver-daemonset -n gpu-operator
   ```

   *Example Output*

   Ensure that the pod names do not include a Linux kernel semantic version number.
