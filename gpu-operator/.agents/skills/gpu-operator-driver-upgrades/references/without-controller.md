<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Upgrades without the Upgrade Controller

If the upgrade controller is disabled or not supported for your GPU Operator version, a component called `k8s-driver-manager` is responsible
for executing the driver upgrade process.
The `k8s-driver-manager` is an `initContainer` within the driver Daemonset, which ensures all existing GPU driver clients are disabled before
unloading the current driver modules and continuing with the new driver installation.
This method still automates the core driver upgrade process, but lacks the observability that the upgrade controller provides as well as additional
controls such as pausing/skipping upgrades.
In addition, no new features will be added to the `k8s-driver-manager` moving forward in favor of the upgrade controller.

## Procedure

1. Upgrade the driver by changing `driver.version` value in ClusterPolicy:

   ```console
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type='json' -p='[{"op": "replace", "path": "/spec/driver/version", "value":"580.95.05"},{"op": "replace", "path": "/spec/driver/repository", "value":"nvcr.io/nvidia"},{"op": "replace", "path": "/spec/driver/image", "value":"driver"}]'
   ```

2. (Optional) To monitor the status of the upgrade, watch the deployment of the new driver pod on GPU worker nodes:

   ```console
   $ kubectl get pods -n gpu-operator -lapp=nvidia-driver-daemonset -w
   ```

## Configuration Options

The following configuration options are available for `k8s-driver-manager`. The options allow users to control the
GPU pod eviction and node drain behavior.

```yaml
driver:
  manager:
    env:
    - name: ENABLE_GPU_POD_EVICTION
      value: "true"
    - name: ENABLE_AUTO_DRAIN
      value: "true"
    - name: DRAIN_USE_FORCE
      value: "false"
    - name: DRAIN_POD_SELECTOR_LABEL
      value: ""
    - name: DRAIN_TIMEOUT_SECONDS
      value: "0s"
    - name: DRAIN_DELETE_EMPTYDIR_DATA
      value: "false"
```

* The `ENABLE_GPU_POD_EVICTION` environment variable enables `k8s-driver-manager` to attempt evicting only GPU pods from the node before attempting a node drain. Only if this fails and
  `ENABLE_AUTO_DRAIN` is enabled will the node ever be drained.
* The `DRAIN_USE_FORCE` environment variable must be enabled to evict GPU pods that are not managed by any of the replication controllers such as deployment, daemon set, stateful set, and replica set.
* The `DRAIN_DELETE_EMPTYDIR_DATA` environment variable must be enabled to delete GPU pods that use the `emptyDir` type volume.

> [!NOTE]
> Since GPU pods get evicted whenever the NVIDIA Driver daemon set specification is updated, it might not always be desirable to allow this to happen automatically.
> To prevent this `daemonsets.updateStrategy` parameter in the `ClusterPolicy` can be set to [OnDelete](https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/#daemonset-update-strategy) .
> With `OnDelete` update strategy, a new driver pod with the updated spec will only get deployed on a node once the old driver pod is manually deleted.
> Thus, admins can control when to rollout spec updates to driver pods on any given node.
> For more information on DaemonSet update strategies, refer to the [Kubernetes documentation](https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/#daemonset-update-strategy).
