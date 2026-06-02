<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Enable Health Checks

The NVIDIA DRA driver supports GPU health monitoring using the [NVIDIA Management Library (NVML)](https://developer.nvidia.com/management-library-nvml).
This feature uses NVML to check for [GPU XID errors](https://docs.nvidia.com/deploy/xid-errors/introduction.html) and determines if a GPU or MIG device is functioning properly.

Health checking is managed by the `NVMLDeviceHealthCheck` feature gate.
This is currently an alpha feature and is disabled by default.

When enabled, the DRA Driver for GPUs continuously monitors GPUs for XID errors and assigns health statuses:
* Healthy - GPU is functioning normally. The GPU may have a non-critical XID error but is still available for workloads.
* Unhealthy - GPU has a critical XID error and is not suitable for workloads.

To enable GPU health monitoring, deploy the DRA driver with the NVMLDeviceHealthCheck feature gate:

```console
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update
helm upgrade -i nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
  --namespace nvidia-dra-driver-gpu \
  --set gpuResourcesEnabledOverride=true \
  --set featureGates.NVMLDeviceHealthCheck=true
```

> [!NOTE]
> Unhealthy GPUs will not appear in the ResourceSlice list. After the device recovers and is marked healthy again, you must restart the DRA Driver for the device to be added back into the available resources pool.
> After enabling health checks, you can monitor health status in the kubelet logs.

1. Check kubelet plugin logs.
   Health status changes are logged in the kubelet plugin container. Run `kubectl get pods -n nvidia-dra-driver-gpu` and find the `nvidia-dra-driver-gpu-kubelet-plugin-<pod>` pod name. Replace `<pod>` with your actual pod name.

   ```console
   kubectl logs nvidia-dra-driver-gpu-kubelet-plugin-<pod> \
     -n nvidia-dra-driver-gpu \
     -c gpus
   ```

2. List all ResourceSlices.
   View all ResourceSlices in the cluster to see which devices are available:

   ```console
   kubectl get resourceslice
   ```

3. Inspect a specific ResourceSlice.
   View detailed information about a specific resource slice. Healthy devices are listed in the resource slice, while unhealthy devices are not listed:

   ```console
   kubectl get resourceslice <resourceslice-name> -o yaml
   ```
