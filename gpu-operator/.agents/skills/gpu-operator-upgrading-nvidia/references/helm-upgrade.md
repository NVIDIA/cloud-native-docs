<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Using Helm

The GPU Operator supports dynamic updates to existing resources.
This ability enables the GPU Operator to ensure settings from the cluster policy specification are always applied and current.

Because Helm [does not support](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations) automatic upgrade of existing CRDs,
you can upgrade the GPU Operator chart manually or by enabling a Helm hook.

> [!NOTE]
> Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases).

## Option 1: Manually Upgrading CRDs

   ```mermaid
   flowchart LR

      A["Update CRD from
        the latest chart"]
      -->
      B["Upgrade by
        using Helm"]
   ```

With this procedure, all existing GPU Operator resources are updated inline and the cluster policy resource is patched with updates from `values.yaml`.

1. Specify the Operator release tag in an environment variable:

   ```console
   $ export RELEASE_TAG=<gpu-operator-version>
   ```

1. Apply the custom resource definitions for the cluster policy and NVIDIA driver:

   ```console
   $ kubectl apply -f \
       https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/$RELEASE_TAG/deployments/gpu-operator/crds/nvidia.com_clusterpolicies.yaml

   $ kubectl apply -f \
       https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/$RELEASE_TAG/deployments/gpu-operator/crds/nvidia.com_nvidiadrivers.yaml
   ```

   *Example Output*

   ```output
   customresourcedefinition.apiextensions.k8s.io/clusterpolicies.nvidia.com configured
   customresourcedefinition.apiextensions.k8s.io/nvidiadrivers.nvidia.com created
   ```

1. Apply the custom resource definition for Node Feature Discovery:

   ```console
   $ kubectl apply -f \
       https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/$RELEASE_TAG/deployments/gpu-operator/charts/node-feature-discovery/crds/nfd-api-crds.yaml
   ```

   *Example Output*

   ```output
   customresourcedefinition.apiextensions.k8s.io/nodefeaturerules.nfd.k8s-sigs.io configured
   ```

1. Update the information about the Operator chart:

   ```console
   $ helm repo update nvidia
   ```

   *Example Output*

   ```output
   Hang tight while we grab the latest from your chart repositories...
   ...Successfully got an update from the "nvidia" chart repository
   Update Complete. ⎈Happy Helming!⎈
   ```

1. Fetch the values from the chart:

   ```console
   $ helm show values nvidia/gpu-operator --version=$RELEASE_TAG > values-$RELEASE_TAG.yaml
   ```

1. Update the values file as needed.

1. Upgrade the Operator:

   ```console
   $ helm upgrade gpu-operator nvidia/gpu-operator -n gpu-operator -f values-$RELEASE_TAG.yaml --version $RELEASE_TAG
   ```

   *Example Output*

   ```output
   Release "gpu-operator" has been upgraded. Happy Helming!
   NAME: gpu-operator
   LAST DEPLOYED: Thu Apr 20 15:05:52 2023
   NAMESPACE: gpu-operator
   STATUS: deployed
   REVISION: 2
   TEST SUITE: None
   ```

## Option 2: Automatically Upgrading CRDs Using a Helm Hook

Starting with GPU Operator v22.09, a `pre-upgrade` Helm [hook](https://helm.sh/docs/topics/charts_hooks/#the-available-hooks) can automatically upgrade to latest CRD.

Starting with GPU Operator v24.9.0, the upgrade CRD Helm hook is enabled by default and runs an upgrade CRD job when you upgrade using Helm.

1. Specify the Operator release tag in an environment variable:

   ```console
   $ export RELEASE_TAG=<gpu-operator-version>
   ```

1. Update the information about the Operator chart:

   ```console
   $ helm repo update nvidia
   ```

   *Example Output*

   ```output
   Hang tight while we grab the latest from your chart repositories...
   ...Successfully got an update from the "nvidia" chart repository
   Update Complete. ⎈Happy Helming!⎈
   ```

1. Fetch the values from the chart:

   ```console
   $ helm show values nvidia/gpu-operator --version=$RELEASE_TAG > values-$RELEASE_TAG.yaml
   ```

1. Update the values file as needed.

1. Upgrade the Operator:

   ```console
   $ helm upgrade gpu-operator nvidia/gpu-operator -n gpu-operator \
       --disable-openapi-validation -f values-$RELEASE_TAG.yaml --version $RELEASE_TAG
   ```

   > [!NOTE]
   > * Option `--disable-openapi-validation` is required in this case so that Helm will not try to validate if CR instance from the new chart is valid as per old CRD.
   >   Since CR instance in the Chart is valid for the upgraded CRD, this will be compatible.

   * Helm hooks used with the GPU Operator use the operator image itself. If operator image itself cannot be pulled successfully (either due to network error or an invalid NGC registry secret in case of NVAIE), hooks will fail.
     In this case, chart needs to be deleted using `--no-hooks` option to avoid deletion to be hung on hook failures.
