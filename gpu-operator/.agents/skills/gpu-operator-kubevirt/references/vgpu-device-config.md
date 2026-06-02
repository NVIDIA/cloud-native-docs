<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# vGPU Device Configuration

The vGPU Device Manager assists in creating vGPU devices on GPU worker nodes.
The vGPU Device Manager allows administrators to declaratively define a set of possible vGPU device configurations they would like applied to GPUs on a node.
At runtime, adminstrators then point the vGPU Device Manager at one of these configurations, and vGPU Device Manager takes care of applying it.

The configuration file is created as a ConfigMap, and is shared across all worker nodes.
At runtime, a node label, `nvidia.com/vgpu.config`, can be used to decide which of these configurations to actually apply to a node at any given time.
If the node is not labeled, then the `default` configuration will be used.
For more information on this component and how it is configured, refer to the [NVIDIA vGPU Device Manager README](https://github.com/NVIDIA/vgpu-device-manager).

By default, the GPU Operator deploys a ConfigMap for the vGPU Device Manager, containing named configurations for all [vGPU types supported by NVIDIA vGPU](https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#supported-gpus-grid-vgpu).
Users can select a specific configuration for a worker node by applying the `nvidia.com/vgpu.config` node label.
For example, labeling a node with `nvidia.com/vgpu.config=A10-8Q` would create three vGPU devices of type **A10-8Q** on all **A10** GPUs on the node. Note that three is the maximum number of **A10-8Q** devices that can be created per GPU.
If the node is not labeled, the `default` configuration will be applied.
The `default` configuration will create Q-series vGPU devices on all GPUs, where the amount of framebuffer memory per vGPU device is half the total GPU memory.
For example, the `default` configuration will create two **A10-12Q** devices on all **A10** GPUs.

You can also create different vGPU Q profiles on the same GPU using vGPU Device Manager configuration.
For example, you can create a **A10-4Q** and a **A10-6Q** device on same GPU by creating a vGPU Device Manager configuration with the following content:

```yaml
version: v1
vgpu-configs:
  custom-A10-config:
    - devices: all
       vgpu-devices:
         "A10-4Q": 3
         "A10-6Q": 2
```

If custom vGPU device configuration is desired, more than the default config map provides, you can create your own config map:

```console
$ kubectl create configmap custom-vgpu-config -n gpu-operator --from-file=config.yaml=/path/to/file
```

And then configure the GPU Operator to use it by setting `vgpuDeviceManager.config.name=custom-vgpu-config`.

## Apply a New vGPU Device Configuration

You can apply a specific vGPU device configuration on a per-node basis by setting the `nvidia.com/vgpu.config` node label.
It is recommended to set this node label prior to installing the GPU Operator if you do not want the default configuration applied.

Switching vGPU device configuration after one has been successfully applied assumes that no virtual machines with vGPU are currently running on the node.
Any existing virtual machines should be shutdown/migrated before you apply the new configuration.

To apply a new configuration after GPU Operator install, update the `nvidia.com/vgpu.config` node label.

> [!NOTE]
> On GPUs that support MIG, you have the option to select MIG-backed vGPU instances instead of time-sliced vGPU instances.
> To select a MIG-backed vGPU profile, label the node with the name of the MIG-backed vGPU profile.
> The following example shows how to apply a new configuration on a system with two **A10** GPUs.

```console
$ nvidia-smi -L
GPU 0: NVIDIA A10 (UUID: GPU-ebd34bdf-1083-eaac-2aff-4b71a022f9bd)
GPU 1: NVIDIA A10 (UUID: GPU-1795e88b-3395-b27b-dad8-0488474eec0c)
```

In this example, the GPU Operator has been installed and the `nvidia.com/vgpu.config` was not added to worker nodes, meaning the `default` vGPU config got applied.
This resulted in the creation of four **A10-12Q** devices (two per GPU):

```console
$ kubectl get node cnt-server-2 -o json | jq '.status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'
{
  "nvidia.com/NVIDIA_A10-12Q": "4"
}
```

Now if you wanted to create **A10-4Q** devices, add the `nvidia.com/vgpu.config` label to the node:

```console
$ kubectl label node <node-name> --overwrite nvidia.com/vgpu.config=A10-4Q
```

After the vGPU Device Manager finishes applying the new configuration, all GPU Operator pods should return to the Running state.

```console
$ kubectl get pods -n gpu-operator
NAME                                                          READY   STATUS    RESTARTS   AGE
...
nvidia-sandbox-device-plugin-daemonset-brtb6                  1/1     Running   0          10s
nvidia-sandbox-validator-ljnwg                                1/1     Running   0          10s
nvidia-vgpu-device-manager-8mgg8                              1/1     Running   0          30m
nvidia-vgpu-manager-daemonset-fpplc                           1/1     Running   0          31m
```

You can now see 12 **A10-4Q** devices on the node, as six **A10-4Q** devices can be created per **A10** GPU.

```console
$ kubectl get node cnt-server-2 -o json | jq '.status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'
{
  "nvidia.com/NVIDIA_A10-4Q": "12"
}
```
