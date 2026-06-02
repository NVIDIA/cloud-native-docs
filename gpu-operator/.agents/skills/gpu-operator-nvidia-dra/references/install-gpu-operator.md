<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Install the NVIDIA GPU Operator (for DRA)

> [!NOTE]
> Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases).

## GPU Allocation

1. Create a node selector label on all the nodes in your cluster that support GPU allocation through DRA:

   ```console
   kubectl label node $HOSTNAME nvidia.com/dra-kubelet-plugin=true
   ```

2. Add the Helm repo:

   ```console
   helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
   && helm repo update
   ```

3. Install the GPU Operator with the NVIDIA Kubernetes Device Plugin disabled:

   ```console
   helm upgrade --install gpu-operator nvidia/gpu-operator \
     --version=<gpu-operator-version> \
     --create-namespace \
     --namespace gpu-operator \
     --set devicePlugin.enabled=false \
     --set driver.manager.env[0].name=NODE_LABEL_FOR_GPU_POD_EVICTION \
     --set driver.manager.env[0].value="nvidia.com/dra-kubelet-plugin"
   ```

   Make sure that the value of `driver.manager.env` matches the node selector label that was used when installing the DRA driver helm chart.

## ComputeDomain

1. Add the Helm repo:

```console
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
&& helm repo update
```

2. Install the GPU Operator with the device plugin disabled:

```console
helm upgrade --install gpu-operator nvidia/gpu-operator \
  --version=<gpu-operator-version> \
  --create-namespace \
  --namespace gpu-operator
```

Refer to the [GPU Operator installation guide](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-install.html) for additional configuration options when installing the GPU Operator.

If you are planning to use MIG devices, refer to the [NVIDIA GPU Operator MIG documentation](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-mig.html) to configure your cluster for MIG support.
