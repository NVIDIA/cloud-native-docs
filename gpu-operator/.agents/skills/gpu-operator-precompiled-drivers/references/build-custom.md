<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Building a Custom Driver Container Image

If a precompiled driver container for your Linux kernel variant is not available,
you can perform the following steps to build and run a container image.

> [!NOTE]
> NVIDIA provides limited support for custom driver container images.

## Prerequisites

* You have access to a private container registry, such as NVIDIA NGC Private Registry, and can push container images to the registry.
* Your build machine has access to the internet to download operating system packages.
* You know a CUDA version, such as `12.1.0`, that you want to use.
  The CUDA version only specifies which base image is used to build the driver container.
  The version does not have any correlation to the version of CUDA that is associated with or supported by the resulting driver container.

  One way to find a supported CUDA version for your operating system is to access the NVIDIA GPU Cloud registry
  at https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda/tags and view the tags.
  Use the search field to filter the tags, such as `base-ubuntu22.04`.
  The filtered results show the CUDA versions, such as `12.1.0`, `12.0.1`, `12.0.0`, and so on.
* You know the GPU driver branch, such as `525`, that you want to use.

## Procedure

1. Clone the driver container repository and change directory into the repository:

   ```console
   $ git clone https://github.com/NVIDIA/gpu-driver-container.git
   ```

   ```console
   $ cd gpu-driver-container
   ```

1. Change directory to the operating system name and version under the driver directory:

   ```console
   $ cd ubuntu22.04/precompiled
   ```

1. Set environment variables for building the driver container image.

   -  Specify your private registry URL:

      ```console
      $ export PRIVATE_REGISTRY=<private-registry-url>
      ```

   - Specify the `KERNEL_VERSION` environment variable that matches your kernel variant, such as `5.15.0-1033-aws`:

     ```console
     $ export KERNEL_VERSION=5.15.0-1033-aws
     ```

   - Specify the version of the CUDA base image to use when building the driver container:

     ```console
     $ export CUDA_VERSION=12.1.0
     ```

   - Specify the driver branch, such as `525`:

     ```console
     $ export DRIVER_BRANCH=525
     ```

   - Specify the `OS_TAG` environment variable to identify the guest operating system name and version:

     ```console
     $ export OS_TAG=ubuntu22.04
     ```

     The value must match the guest operating system version.

1. Build the driver container image:

   ```console
   $ sudo docker build \
       --build-arg KERNEL_VERSION=$KERNEL_VERSION \
       --build-arg CUDA_VERSION=$CUDA_VERSION \
       --build-arg DRIVER_BRANCH=$DRIVER_BRANCH \
       -t ${PRIVATE_REGISTRY}/driver:${DRIVER_BRANCH}-${KERNEL_VERSION}-${OS_TAG} .
   ```

1. Push the driver container image to your private registry.

   - Log in to your private registry:

     ```console
     $ sudo docker login ${PRIVATE_REGISTRY} --username=<username>
     ```

     Enter your password when prompted.

   - Push the driver container image to your private registry:

     ```console
     $ sudo docker push ${PRIVATE_REGISTRY}/driver:${DRIVER_BRANCH}-${KERNEL_VERSION}-${OS_TAG}
     ```

## Next Steps

* To use the custom driver container image, follow the steps for enabling support during or after installation.

  If you have not already installed the GPU Operator, in addition to the `--set driver.usePrecompiled=true`
  and `--set driver.version=${DRIVER_BRANCH}` arguments for Helm, also specify the `--set driver.repository="$PRIVATE_REGISTRY"` argument.

  If the container registry is not public, you need to create an image pull secret in the GPU Operator namespace
  and specify it in the `--set driver.imagePullSecrets=<pull-secret>` argument.

  If you already installed the GPU Operator, specify the private registry for the driver in the cluster policy:

  ```console
  $ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type='json' \
      -p='[{"op": "replace", "path": "/spec/driver/repository", "value":"$PRIVATE_REGISTRY"}]'
  ```
