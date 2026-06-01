<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Installing the GPU Operator with Driver Custom Resources

Perform the following steps to install the GPU Operator and use the NVIDIA driver custom resources.

1. Optional: If you want to run more than one driver type or version in the cluster,
   label the worker nodes to identify the driver type and version to install on each node:

   *Example*

   ```console
   $ kubectl label node <node-name> --overwrite driver.version=580.126.20
   ```

   - To use a mix of driver types, such as vGPU, label nodes for the driver type.
   - To use a mix of driver versions, label the nodes for the different versions.
   - To use a mix of conventional drivers and precompiled driver containers, label the nodes for the different types.

1. Install the Operator.

   - Add the NVIDIA Helm repository:

     ```console
     $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
         && helm repo update
     ```

> [!NOTE]
> Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases).

   - Install the Operator and specify at least the `--set driver.nvidiaDriverCRD.enabled=true` argument:

     ```console
     $ helm install --wait --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --version=<gpu-operator-version> \
         --set driver.nvidiaDriverCRD.enabled=true
     ```

     By default, Helm configures a `default` NVIDIA driver custom resource during installation.
     To prevent configuring the default custom resource, also specify `--set driver.nvidiaDriverCRD.deployDefaultCR=false`.

1. Apply NVIDIA driver custom resources manifests to install the NVIDIA GPU driver version, type, and so on for your nodes.
   Refer to the sample manifests (see [references/manifests.md](manifests.md)).
