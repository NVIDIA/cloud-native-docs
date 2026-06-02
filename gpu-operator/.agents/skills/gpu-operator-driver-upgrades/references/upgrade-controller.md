<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Upgrades with the Upgrade Controller

NVIDIA recommends upgrading by using the upgrade controller and the controller is enabled by default in the GPU Operator.
The controller automates the upgrade process and generates metrics and events so that you can monitor the upgrade process.

## Procedure

1. Upgrade the driver by changing the `driver.version` value in the cluster policy:

   ```console
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
       --type='json' \
       -p='[{"op": "replace", "path": "/spec/driver/version", "value":"580.95.05"}]'
   ```

   If you are using Openshift, you must update the `driver.version`, `driver.repository` and `driver.image` values in the cluster policy.

   ```console
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
       --type='json' \
       -p='[{"op": "replace", "path": "/spec/driver/version", "value":"580.95.05"},{"op": "replace", "path": "/spec/driver/repository", "value":"nvcr.io/nvidia"},{"op": "replace", "path": "/spec/driver/image", "value":"driver"}]'
   ```

2. (Optional) For each node, monitor the upgrade status:

   ```console
   $ kubectl get node -l nvidia.com/gpu.present \
      -ojsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.nvidia\.com/gpu-driver-upgrade-state}{"\n"}{end}'
   ```

   *Example Output*

   ```output
   k8s-node-1 upgrade-required
   k8s-node-2 upgrade-required
   k8s-node-3 upgrade-required
   ```

   You can periodically poll the upgrade status by running the preceding command.
   The GPU driver upgrade is complete when the output shows `upgrade-done`:

   ```output
   k8s-node-1 upgrade-done
   k8s-node-2 upgrade-done
   k8s-node-3 upgrade-done
   ```

## Configuration Options

You can set the following fields in the cluster policy to configure the upgrade controller:

```yaml
driver:

  upgradePolicy:
    # autoUpgrade (default=true): Switch which enables / disables the driver upgrade controller.
    # If set to false all other options are ignored.
    autoUpgrade: true
    # maxParallelUpgrades (default=1): Number of nodes that can be upgraded in parallel. 0 means infinite.
    maxParallelUpgrades: 1
    # maximum number of nodes with the driver installed, that can be unavailable during
    # the upgrade. Value can be an absolute number (ex: 5) or
    # a percentage of total nodes at the start of upgrade (ex:
    # 10%). Absolute number is calculated from percentage by rounding
    # up. By default, a fixed value of 25% is used.'
    maxUnavailable: 25%
    # waitForCompletion: Options for the 'wait-for-completion' state, which will wait for a user-defined group of pods
    # to complete before upgrading the driver on a node.
    waitForCompletion:
      # timeoutSeconds (default=0): The length of time to wait before giving up. 0 means infinite.
      timeoutSeconds: 0
      # podSelector (default=""): The label selector defining the group of pods to wait for completion of. "" means to wait on none.
      podSelector: ""

    # gpuPodDeletion: Options for the 'pod-deletion' state, which will evict all pods on the node allocated a GPU.
    gpuPodDeletion:
      # force (default=false): Delete pods even if they are not managed by a controller (for example ReplicationController, ReplicaSet,
      # Job, DaemonSet or StatefulSet).
      force: false
      # timeoutSeconds (default=300): The length of time to wait before giving up. 0 means infinite. When the timeout is met,
      # the GPU  pod(s) will be forcefully deleted.
      timeoutSeconds: 300
      # deleteEmptyDir (default=false): Delete pods even if they are using emptyDir volumes (local data will be deleted).
      deleteEmptyDir: false

    # drain: Options for the 'drain' state, which invokes 'kubectl drain' on the node.
    # Unlike 'gpuPodDeletion', which targets only GPU-allocated pods, drain evicts all pods on the node.
    # This should only be enabled as a fallback when 'gpuPodDeletion' cannot remove all GPU-using pods on its own.
    drain:
      # enable (default=false): Set to true to allow node drain as a fallback when
      # 'gpuPodDeletion' cannot evict all GPU pods. By default, drain evicts all pods
      # on the node. Use podSelector to limit which pods are evicted.
      enable: false
      # force (default=false): Delete pods even if they are not managed by a controller
      # (for example, ReplicationController, ReplicaSet, Job, DaemonSet, or StatefulSet).
      # Applies to all pods on the node, not just GPU pods.
      force: false
      # podSelector (default=""): Label selector to restrict which pods are evicted
      # during drain. An empty string means all pods on the node are evicted.
      podSelector: ""
      # timeoutSeconds (default=300): The length of time to wait before giving up.
      # 0 means infinite. When the timeout is reached, the drain attempt is abandoned.
      timeoutSeconds: 300
      # deleteEmptyDir (default=false): Allow eviction of pods that use emptyDir volumes.
      # Enabling this results in permanent loss of any data stored in those volumes.
      deleteEmptyDir: false
```

> [!WARNING]
> `driver.upgradePolicy.drain.enable` is a cluster-wide policy setting.
> When set to `true`, the upgrade controller drains each node before upgrading the driver on that node.
> Draining a node evicts all pods from that node, including workloads unrelated to the GPU driver.
> This is a disruptive operation that interrupts running GPU and non-GPU workloads on every node the upgrade controller processes.

Enable `drain` only when `gpuPodDeletion` is insufficient to remove all GPU-using pods on its own.
Adjust the `gpuPodDeletion` settings first and use `drain` only if those settings do not work.
If you must enable `drain`, use `podSelector` to limit which pods are evicted.
If you specify a value for `maxUnavailable` and also specify `maxParallelUpgrades`,
the `maxUnavailable` value applies an additional constraint on the value of
`maxParallelUpgrades` to ensure that the number of parallel upgrades does not
cause more than the intended number of nodes to become unavailable during the upgrade.
For example, if you specify `maxUnavailable=100%` and `maxParallelUpgrades=1`,
one node is upgraded at a time .

The `maxUnavailable` value also applies to the currently unavailable nodes in the cluster.
If you cordoned nodes in the cluster and the `maxUnavailable` value is already met by the number of cordoned nodes,
then the upgrade does not progress.

## Upgrade State Machine

The upgrade controller manages driver upgrades through a well-defined state machine.
The node label, `nvidia.com/gpu-driver-upgrade-state`, indicates the state a node is currently in.
The set of possible states are:

* Unknown (empty): The upgrade controller is disabled or the node has not been processed yet.
* `upgrade-required`: NVIDIA driver pod is not up-to-date and requires an upgrade. No actions are performed at this stage.
* `cordon-required`: Node will be marked Unschedulable in preparation for the driver upgrade.
* `wait-for-jobs-required`: Node will wait on the completion of a group of pods/jobs before proceeding.
* `pod-deletion-required`: Pods allocated with GPUs are deleted from the node. If pod deletion fails, the node state is set to `drain-required`
  if drain is enabled in ClusterPolicy.
* `drain-required`: Node is drained using `kubectl drain`, which evicts all pods on the
  node.
  This state is only reached if `gpuPodDeletion` fails to remove all
  GPU-using pods and `drain.enable` is set to `true` in the cluster policy.
  This state is skipped if all GPU pods are successfully deleted from the node.
* `pod-restart-required`: The NVIDIA driver pod running on the node will be restarted and upgraded to the new version.
* `validation-required`: Validation of the new driver deployed on the node is required before proceeding. The GPU Operator
  performs validations in the pod named `operator-validator`.
* `uncordon-required`: Node will be marked Schedulable to complete the upgrade process.
* `upgrade-done`: NVIDIA driver pod is up-to-date and running on the node.
* `upgrade-failed`: A failure occurred during the driver upgrade.

The complete state machine is depicted in the diagram below.

![](graphics/upgrade-controller-state-machine.png)

## Pausing Driver Upgrades

To pause the automatic driver upgrade process in the cluster, toggle `driver.upgradePolicy.autoUpgrade` flag
in the cluster policy.
The entire state machine pauses and effectively disables any pending nodes from being upgraded.
You can toggle the flag to `true` again to re-enable the upgrade controller and resume any pending upgrades.

## Skipping Driver Upgrades

To skip driver upgrades on a certain node, label the node with `nvidia.com/gpu-driver-upgrade.skip=true`.

## Metrics and Events

The GPU Operator generates the following metrics during the upgrade process which can be scraped by Prometheus.

* `gpu_operator_auto_upgrade_enabled`: 1 if driver auto upgrade is enabled; 0 if not.
* `gpu_operator_nodes_upgrades_in_progress`: Total number of nodes in which a driver pod is being upgraded on.
* `gpu_operator_nodes_upgrades_done`: Total number of nodes in which a driver pod has been successfully upgraded.
* `gpu_operator_nodes_upgrades_failed`: Total number of nodes in which a driver pod upgrade has failed.
* `gpu_operator_nodes_upgrades_available`: Total number of nodes in which a driver pod upgrade can start on.
* `gpu_operator_nodes_upgrades_pending`: Total number of nodes in which driver pod upgrades are pending.

The GPU Operator generates events during the upgrade process.
The most common events are for state transitions or failures at a particular state.
Below are an example set of events generated for the upgrade of one node.

```console
$ kubectl get events -n default --sort-by='.lastTimestamp' | grep GPUDriverUpgrade
```

*Example Output*

```output
10m         Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [upgrade-required]
10m         Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [cordon-required]
10m         Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [wait-for-jobs-required]
10m         Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [pod-deletion-required]
10m         Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [pod-restart-required]
7m          Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [validation-required]
6m          Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [uncordon-required]
6m          Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [upgrade-done]
```

## Troubleshooting

If the upgrade fails for a particular node, the node is labelled with the `upgrade-failed` state.

1. View the upgrade state labels:

   ```console
   $ kubectl get node -l nvidia.com/gpu.present \
       -ojsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.nvidia\.com/gpu-driver-upgrade-state}{"\n"}{end}'
   ```

   *Example Output*

   ```output
   k8s-node-1 upgrade-done
   k8s-node-2 upgrade-done
   k8s-node-3 upgrade-failed
   ```

1. Check the events to determine the stage that the upgrade failed:

   ```console
   $ kubectl get events -n default --sort-by='.lastTimestamp' | grep GPUDriverUpgrade
   ```

1. (Optional) Check the logs from the upgrade controller in the gpu-operator container:

   ```console
   $ kubectl logs -n gpu-operator gpu-operator-xxxxx | grep controllers.Upgrade
   ```

1. After resolving the upgrade failures for a particular node, you can restart the upgrade process on the node by placing it in the `upgrade-required` state:

   ```console
   $ kubectl label node <node-name>  nvidia.com/gpu-driver-upgrade-state=upgrade-required --overwrite
   ```
