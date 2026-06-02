<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Installing GPU Operator Using the Data Center Driver

This installation method is available for bare metal clusters or any cluster that does not use virtualization.

You must install the driver that matches the supported driver branch for your NVIDIA AI Enterprise release.

To identify the correct driver branch:

1. Refer to the [NVIDIA AI Enterprise Infra Release Branches](https://docs.nvidia.com/ai-enterprise/index.html#nvidiatab-infrastructure-software---infra-release-branches)
   table to determine the driver branch for your release.

   For example, NVIDIA AI Enterprise Infra 7.x uses the R580 driver branch.

1. Refer to the [GPU Operator Component Matrix](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/life-cycle-policy.html#gpu-operator-component-matrix) to identify the recommended GPU Operator version and driver version that uses the same driver branch.

After identifying the correct driver version, use the `gpu-operator-install` skill for installation instructions.
Use the `--version=<supported-version>` argument when installing with Helm.

## Verification

Confirm that the Operator installed with the NVIDIA AI Enterprise components and that licensing succeeded:

1. Confirm the Operator pods are running:

   ```console
   $ kubectl get pods -n gpu-operator
   ```

   The driver pods should report `Running` and the `nvidia-operator-validator` pod should report `Completed`.

1. Confirm the driver acquired a valid license:

   ```console
   $ kubectl exec -it -n gpu-operator <driver-pod> -- nvidia-smi -q | grep -i "License Status"
   ```

   The license status should report `Licensed`.
