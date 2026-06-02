<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Cluster Policy Updates, Driver Controls, OLM, and Verification

## Cluster Policy Updates

The GPU Operator also supports dynamic updates to the `ClusterPolicy` CustomResource using `kubectl`:

```console
$ kubectl edit clusterpolicy
```

After the edits are complete, Kubernetes will automatically apply the updates to cluster.

## Additional Controls for Driver Upgrades

While most of the GPU Operator managed daemonsets can be upgraded seamlessly, the NVIDIA driver daemonset has special considerations.
Refer to the GPU driver upgrade behavior (use the `gpu-operator-driver-upgrades` skill) for more information.

## Using Operator Lifecycle Manager (OLM) in OpenShift

For upgrading the GPU Operator when running in OpenShift, refer to the official OpenShift documentation on [upgrading installed operators](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/operators/administrator-tasks#olm-upgrading-operators).

## Verification

After upgrading, confirm that the Operator and its operands are healthy:

1. Confirm all GPU Operator pods are running or completed:

   ```console
   $ kubectl get pods -n gpu-operator
   ```

   The `nvidia-operator-validator` pod should report `Completed`, and the driver, toolkit, and device-plugin pods should report `Running` on the expected GPU nodes.
