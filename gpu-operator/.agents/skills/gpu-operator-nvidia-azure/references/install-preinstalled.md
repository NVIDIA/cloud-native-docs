<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Installing the Operator for Preinstalled Driver and Toolkit

After you start your Azure AKS cluster with an image that includes a preinstalled NVIDIA GPU Driver
and NVIDIA Container Toolkit, you are ready to install the NVIDIA GPU Operator.

When you install the Operator, you must prevent the Operator from automatically
deploying NVIDIA Driver Containers and the NVIDIA Container Toolkit.

1. Add the NVIDIA Helm repository:

   ```console
   $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
      && helm repo update
   ```

   > [!NOTE]
   > Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases).

1. Install the Operator without the driver containers and toolkit:

   ```console
   $ helm install gpu-operator nvidia/gpu-operator \
       -n gpu-operator --create-namespace \
       --version=<gpu-operator-version> \
       --set driver.enabled=false \
       --set toolkit.enabled=false \
       --set operator.runtimeClass=nvidia-container-runtime
   ```

   Refer to Common Chart Customization Options for more information about installation options.

   *Example Output*

   ```output
   NAME: gpu-operator
   LAST DEPLOYED: Fri May  5 15:30:05 2023
   NAMESPACE: gpu-operator
   STATUS: deployed
   REVISION: 1
   TEST SUITE: None
   ```

   The Operator requires several minutes to install.

1. Confirm that the Operator is installed and ran the CUDA validation container to completion:

   ```console
   $ kubectl get pods -n gpu-operator -l app=nvidia-cuda-validator
   ```

   *Example Output*

   ```output
   NAME                          READY   STATUS      RESTARTS   AGE
   nvidia-cuda-validator-bpvkt   0/1     Completed   0          3m56s
   ```
