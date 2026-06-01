<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Install Procedure

Throughout, replace `<gpu-operator-version>` with your target GPU Operator release (for example, the latest patch release listed on the [GPU Operator releases page](https://github.com/NVIDIA/gpu-operator/releases)).

> [!TIP]
> For installation on Red Hat OpenShift Container Platform, refer to [OpenShift installation steps](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/steps-overview.html).

1. Add the NVIDIA Helm repository:

   ```console
   $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
       && helm repo update
   ```

1. Install the GPU Operator.

   - Install the Operator with the default configuration:

     ```console
     $ helm install --wait --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --version=<gpu-operator-version>
     ```

   - Install the Operator and specify configuration options:

     ```console
     $ helm install --wait --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --version=<gpu-operator-version> \
         --set <option-name>=<option-value>
     ```

     Refer to the chart customization options (see [references/chart-options.md](chart-options.md)) and common deployment scenarios (see [references/deployment-scenarios.md](deployment-scenarios.md)) for more information.
