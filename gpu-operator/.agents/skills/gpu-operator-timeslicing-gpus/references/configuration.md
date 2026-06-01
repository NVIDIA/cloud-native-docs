<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Configuring GPU Time-Slicing

Throughout, replace `<gpu-operator-version>` with your target GPU Operator release.

## About Configuring GPU Time-Slicing

You configure GPU time-slicing by performing the following high-level steps:

* Add a config map to the namespace that is used by the GPU operator.
* Configure the cluster policy so that the device plugin uses the config map.
* Apply a label to the nodes that you want to configure for GPU time-slicing.

On a machine with one GPU, the following config map configures Kubernetes so that
the node advertises four GPU resources.
A machine with two GPUs advertises eight GPUs, and so on.

## Sample Config Map

The following table describes the key fields in the config map.

| Field | Type | Description |
| --- | --- | --- |
| `data.<key>` | string | Specifies the time-slicing configuration name. You can specify multiple configurations if you want to assign node-specific configurations. In the preceding example, the value for `key` is `any`. |
| `flags.migStrategy` | string | Specifies how to label MIG devices for the nodes that receive the time-slicing configuration. Specify one of `none`, `single`, or `mixed`. The default value is `none`. |
| `renameByDefault` | boolean | When set to `true`, each resource is advertised under the name `<resource-name>.shared` instead of `<resource-name>`. For example, if this field is set to `true` and the resource is typically `nvidia.com/gpu`, the nodes that are configured for time-sliced GPU access then advertise the resource as `nvidia.com/gpu.shared`. Setting this field to true can be helpful if you want to schedule pods on GPUs with shared access by specifying `<resource-name>.shared` in the resource request. When this field is set to `false`, the advertised resource name, such as `nvidia.com/gpu`, is not modified. However, label for the product name is suffixed with `-SHARED`. For example, if the output of `kubectl describe node` shows the node label `nvidia.com/gpu.product=Tesla-T4`, then after the node is configured for time-sliced GPU access, the label becomes `nvidia.com/gpu.product=Tesla-T4-SHARED`. In this case, you can specify a node selector that includes the `-SHARED` suffix to schedule pods on GPUs with shared access. The default value is `false`. |
| `failRequestsGreaterThanOne` | boolean | The purpose of this field is to enforce awareness that requesting more than one GPU replica does not result in receiving more proportional access to the GPU. For example, if `4` GPU replicas are available and two pods request `1` GPU each and a third pod requests `2` GPUs, the applications in the three pods have an equal share of GPU compute time. Specifically, the pod that requests `2` GPUs does not receive twice as much compute time as the pods that request `1` GPU. When set to `true`, a resource request for more than one GPU fails with an `UnexpectedAdmissionError`. In this case, you must manually delete the pod, update the resource request, and redeploy. |
| `resources.name` | string | Specifies the resource type to make available with time-sliced access, such as `nvidia.com/gpu`, `nvidia.com/mig-1g.5gb`, and so on. |
| `resources.replicas` | integer | Specifies the number of time-sliced GPU replicas to make available for shared access to GPUs of the specified resource type. |

## Applying One Cluster-Wide Configuration

Perform the following steps to configure GPU time-slicing if you already installed the GPU operator
and want to apply the same time-slicing configuration on all nodes in the cluster.

1. Create a file, such as `time-slicing-config-all.yaml`, with contents like the following example:

   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: time-slicing-config-all
   data:
     any: |-
       version: v1
       flags:
         migStrategy: none
       sharing:
         timeSlicing:
           resources:
           - name: nvidia.com/gpu
             replicas: 4
   ```

1. Add the config map to the same namespace as the GPU operator:

   ```console
   $ kubectl create -n gpu-operator -f time-slicing-config-all.yaml
   ```

1. Configure the device plugin with the config map and set the default time-slicing configuration:

   ```console
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
       -n gpu-operator --type merge \
       -p '{"spec": {"devicePlugin": {"config": {"name": "time-slicing-config-all", "default": "any"}}}}'
   ```

1. Optional: Confirm that the `gpu-feature-discovery` and
   `nvidia-device-plugin-daemonset` pods restart.

   ```console
   $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'
   ```

   *Example Output*

Refer to the verification reference (see [references/verification.md](verification.md)).

## Applying Multiple Node-Specific Configurations

An alternative to applying one cluster-wide configuration is to specify multiple
time-slicing configurations in the config map and to apply labels node-by-node to
control which configuration is applied to which nodes.

1. Create a file, such as `time-slicing-config-fine.yaml`, with contents like the following example:

   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: time-slicing-config-fine
   data:
     a100-40gb: |-
       version: v1
       flags:
         migStrategy: mixed
       sharing:
         timeSlicing:
           resources:
           - name: nvidia.com/gpu
             replicas: 8
           - name: nvidia.com/mig-1g.5gb
             replicas: 2
           - name: nvidia.com/mig-2g.10gb
             replicas: 2
           - name: nvidia.com/mig-3g.20gb
             replicas: 3
           - name: nvidia.com/mig-7g.40gb
             replicas: 7
     tesla-t4: |-
       version: v1
       flags:
         migStrategy: none
       sharing:
         timeSlicing:
           resources:
           - name: nvidia.com/gpu
             replicas: 4
   ```

1. Add the config map to the same namespace as the GPU operator:

   ```console
   $ kubectl create -n gpu-operator -f time-slicing-config-fine.yaml
   ```

1. Configure the device plugin with the config map and set the default time-slicing configuration:

   ```console
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
       -n gpu-operator --type merge \
       -p '{"spec": {"devicePlugin": {"config": {"name": "time-slicing-config-fine"}}}}'
   ```

   Because the specification does not include the `devicePlugin.config.default` field,
   when the device plugin pods redeploy, they do not automatically apply the time-slicing
   configuration to all nodes.

1. Optional: Confirm that the `gpu-feature-discovery` and
   `nvidia-device-plugin-daemonset` pods restart.

   ```console
   $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'
   ```

   *Example Output*

1. Apply a label to the nodes by running one or more of the following commands:

   * Apply a label to nodes one-by-one by specifying the node name:

     ```console
     $ kubectl label node <node-name> nvidia.com/device-plugin.config=tesla-t4
     ```

   * Apply a label to several nodes at one time by specifying a label selector:

     ```console
     $ kubectl label node \
         --selector=nvidia.com/gpu.product=Tesla-T4 \
         nvidia.com/device-plugin.config=tesla-t4
     ```

Refer to the verification reference (see [references/verification.md](verification.md)).

## Configuring Time-Slicing Before Installing the NVIDIA GPU Operator

You can enable time-slicing with the NVIDIA GPU Operator by passing the
`devicePlugin.config.name=<config-map-name>` parameter during installation.

Perform the following steps to configure time-slicing before installing the operator:

1. Create the namespace for the operator:

   ```console
   $ kubectl create namespace gpu-operator
   ```

1. Create a file, such as `time-slicing-config.yaml`, with the config map contents.

   Refer to the **Applying One Cluster-Wide Configuration** or **Applying Multiple Node-Specific Configurations** sections.

1. Add the config map to the same namespace as the GPU operator:

   ```console
   $ kubectl create -f time-slicing-config.yaml
   ```

> [!NOTE]
> Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases).

1. Install the operator with Helm:

   ```console
   $ helm install gpu-operator nvidia/gpu-operator \
       -n gpu-operator \
       --version=<gpu-operator-version> \
       --set devicePlugin.config.name=time-slicing-config
   ```

1. Refer to either the **Applying One Cluster-Wide Configuration** or **Applying Multiple Node-Specific Configurations** section and perform the following tasks:

   * Configure the device plugin by running the `kubectl patch` command.
   * Apply labels to nodes if you added a config map with node-specific configurations.

After installation, refer to the verification reference (see [references/verification.md](verification.md)).

## Updating a Time-Slicing Config Map

The Operator does not monitor the time-slicing config maps.
As a result, if you modify a config map, the device plugin pods do not restart and do not apply the modified configuration.

To apply the modified config map, manually restart the device plugin pods:

```console
$ kubectl rollout restart -n gpu-operator daemonset/nvidia-device-plugin-daemonset
```

Currently running workloads are not affected and continue to run, though NVIDIA recommends performing the restart during a maintenance period.
