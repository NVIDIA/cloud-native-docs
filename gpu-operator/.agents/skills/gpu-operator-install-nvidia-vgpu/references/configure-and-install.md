<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Configure the Cluster and Install the Operator

## Configure the Cluster with the vGPU License Information and the Driver Container Image

1. Create an NVIDIA vGPU license file named `gridd.conf` with contents like the following example:

   ```text
   # Description: Set Feature to be enabled
   # Data type: integer
   # Possible values:
   # 0 => for unlicensed state
   # 1 => for NVIDIA vGPU
   # 2 => for NVIDIA RTX Virtual Workstation
   # 4 => for NVIDIA Virtual Compute Server
   FeatureType=1
   ```

1. Rename the client configuration token file that you downloaded to `client_configuration_token.tok` using a command like the following example:

   ```console
   $ cp ~/Downloads/client_configuration_token_03-28-2023-16-16-36.tok client_configuration_token.tok
   ```

   The file must be named `client_configuration_token.tok`.

1. Create the `gpu-operator` namespace:

   ```console
   $ kubectl create namespace gpu-operator
   ```

1. Create a secret that is named `licensing-config` using the `gridd.conf` and `client_configuration_token.tok` files:

   ```console
   $ kubectl create secret generic licensing-config \
       -n gpu-operator --from-file=gridd.conf --from-file=client_configuration_token.tok
   ```

1. Create an image pull secret in the `gpu-operator` namespace with the registry secret and private registry.

   1. Set an environment variable with the name of the secret:

      ```console
      $ export REGISTRY_SECRET_NAME=registry-secret
      ```

   1. Create the secret:

      ```console
      $ kubectl create secret docker-registry ${REGISTRY_SECRET_NAME} \
          --docker-server=${PRIVATE_REGISTRY} --docker-username=<username> \
          --docker-password=<password> \
          --docker-email=<email-id> -n gpu-operator
      ```

   You need to specify the secret name `REGISTRY_SECRET_NAME` when you install the GPU Operator with Helm.

## Install the Operator

- Install the Operator:

  ```console
  $ helm install --wait --generate-name \
       -n gpu-operator --create-namespace \
       nvidia/gpu-operator \
       --set driver.repository=${PRIVATE_REGISTRY} \
       --set driver.version=${VGPU_DRIVER_VERSION} \
       --set driver.imagePullSecrets={$REGISTRY_SECRET_NAME} \
       --set driver.licensingConfig.secretName=licensing-config
  ```

The preceding command installs the Operator with the default configuration.
Refer to the [GPU Operator Helm chart options](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#common-chart-customization-options) for information about configuration options.

## Verification

Confirm that the Operator installed and the vGPU driver pods are running:

1. Confirm the Operator pods, including the vGPU driver, are running:

   ```console
   $ kubectl get pods -n gpu-operator
   ```

   The `nvidia-vgpu-driver-daemonset` pods should report `Running` and the `nvidia-operator-validator` pod should report `Completed`. For general post-install validation, use the `gpu-operator-install` skill's verification steps.
