<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Upgrading and Verifying the NVIDIA GPU Driver

## Upgrading the NVIDIA GPU Driver

You can upgrade the driver version by editing or patching the NVIDIA driver custom resource.

When you update the custom resource, the Operator performs a rolling update of the pods in the affected daemon set.

1. Update the `driver.version` field in the driver custom resource:

   ```console
   $ kubectl patch nvidiadriver/demo-silver --type='json' \
       -p='[{"op": "replace", "path": "/spec/version", "value": "525.125.06"}]'
   ```

1. Optional: Monitor the progress:

   ```console
   $ kubectl get pods -n gpu-operator -l app.kubernetes.io/component=nvidia-driver
   ```

   *Example Output*

   ```output
   NAME                                             READY   STATUS        RESTARTS   AGE
   nvidia-gpu-driver-ubuntu20.04-788484b9bb-6zhd9   1/1     Running       0          5m1s
   nvidia-gpu-driver-ubuntu22.04-8896c4bf7-7s68q    1/1     Terminating   0          37m
   nvidia-gpu-driver-ubuntu22.04-8896c4bf7-jm74l    1/1     Running       0          37m
   ```

Eventually, the Operator replaces the pods that used the previous driver version with pods that use the updated driver version.

## Verification

Confirm that the driver custom resources are applied and the driver pods are running:

1. List the `NVIDIADriver` custom resources and confirm their state:

   ```console
   $ kubectl get nvidiadrivers
   ```

1. Confirm the driver pods are running on the expected nodes:

   ```console
   $ kubectl get pods -n gpu-operator -l app.kubernetes.io/component=nvidia-driver -o wide
   ```

   Each driver pod should report `Running`. If a pod is not progressing, inspect the events:

   ```console
   $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'
   ```
