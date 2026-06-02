<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Verification

Confirm that CDI or the NRI Plugin is configured as expected:

1. Confirm the GPU Operator pods, including the container toolkit and device plugin, are running:

   ```console
   $ kubectl get pods -n gpu-operator
   ```

   The `nvidia-container-toolkit-daemonset` and `nvidia-device-plugin-daemonset` pods should report `Running`.

1. Run a GPU workload and confirm the GPU is injected into the container:

   ```console
   $ kubectl run cuda-check --rm -it --restart=Never \
       --image=nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda11.7.1-ubuntu20.04
   ```

   A successful run reports `Test PASSED`, confirming that the device was injected through CDI or the NRI Plugin.
