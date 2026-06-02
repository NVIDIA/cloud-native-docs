<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Node Resource Interface (NRI) Plugin

## About the Node Resource Interface (NRI) Plugin

Node Resource Interface (NRI) is a standardized interface for plugging in extensions, called NRI Plugins, to OCI-compatible container runtimes like containerd.
NRI Plugins serve as hooks which intercept pod and container lifecycle events and perform functions including injecting devices to a container, topology aware placement strategies, and more. For more details on NRI, refer to the [NRI overview](https://github.com/containerd/nri/tree/main?tab=readme-ov-file#background) in the containerd repository.

When enabled in the GPU Operator, the NVIDIA Container Toolkit daemonset will run an NRI Plugin on every GPU node.
The purpose of the NRI Plugin is to inject GPUs into GPU management containers that use the `NVIDIA_VISIBLE_DEVICES` environment variable to get GPU access, bypassing GPU allocation via the Device Plugin or DRA Driver for GPUs.

In previous GPU Operator versions, device injection was handled by the `nvidia` container runtime. With CDI and the NRI Plugin enabled, the `nvidia` runtime class is no longer needed. When enabling the NRI plugin during install, the `nvidia` runtime class will not be created. If you enable the NRI Plugin after install, the `nvidia` runtime class will be deleted.

Additionally, with the NRI Plugin enabled, modifications to the container runtime configuration are no longer needed. For example, no modifications are made to containerd’s config.toml file.
This means that on platforms that configure containerd in a non-standard way, like k3s, k0s, and Rancher Kubernetes Engine 2, users no longer need to configure environment variables like `CONTAINERD_CONFIG`, `CONTAINERD_SOCKET`, or `RUNTIME_CONFIG_SOURCE`.

## Enabling the NRI Plugin

The NRI Plugin requires the following:

- CDI to be enabled in the GPU Operator.

- containerd v1.7.30, v2.1.x, or v2.2.x.
  If you are not using the latest containerd version, check that both CDI and NRI are enabled in the containerd configuration file before deploying GPU Operator.

  > [!NOTE]
  > Enabling the NRI plugin is not supported with cri-o.
  > To enable the NRI Plugin during installation, follow the instructions for installing the Operator with Helm on the getting-started page and include the `--set cdi.nriPluginEnabled=true` argument in your Helm command.

### Enabling the NRI Plugin After Installation

1. Enable NRI Plugin by modifying the cluster policy:

   ```console
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type='json' \
       -p='[{"op": "replace", "path": "/spec/cdi/nriPluginEnabled", "value":true}]'
   ```

   *Example Output*

   ```output
   clusterpolicy.nvidia.com/cluster-policy patched
   ```

   After enabling the NRI Plugin, the `nvidia` runtime class will be deleted.

1. (Optional) Confirm that the container toolkit and device plugin pods restart:

   ```console
   $ kubectl get pods -n gpu-operator
   ```

   *Example Output*

## Disabling the NRI Plugin

Disable the NRI Plugin and use the `nvidia` runtime class instead with the following procedure:

Disable the NRI Plugin by modifying the cluster policy:

```console
$ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type='json' \
      -p='[{"op": "replace", "path": "/spec/cdi/nriPluginEnabled", "value":false}]'
```

*Example Output*

```output
clusterpolicy.nvidia.com/cluster-policy patched
```

After disabling the NRI Plugin, the `nvidia` runtime class will be created.
