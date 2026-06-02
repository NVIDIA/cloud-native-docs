<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Label the Namespace to Disable Injection

- Label the Operator namespace to prevent automatic injection:

  ```console
  $ kubectl label namespace gpu-operator istio-injection=disabled
  ```

  Or, for Linkerd:

  ```console
  $ kubectl label namespace gpu-operator linkerd.io/inject=disabled
  ```

If the GPU Operator is not already installed, use the `gpu-operator-install` skill for information about custom options and common installation scenarios.

## Verification

After labeling the namespace and installing the Operator, confirm that the GPU Operator pods start successfully despite the service mesh:

1. Confirm the Operator pods are running:

   ```console
   $ kubectl get pods -n gpu-operator
   ```

   All operands, including the `nvidia-driver-daemonset` and `nvidia-operator-validator` pods, should report `Running` or `Completed`. If the `k8s-driver-manager` init container is stuck, confirm that sidecar injection is disabled for the `gpu-operator` namespace.
