---
name: "gpu-operator-install-nvidia-vgpu"
description: "Guides users through installing the GPU Operator with NVIDIA vGPU. Use when deploying virtual GPU software or configuring vGPU licensing with Kubernetes."
triggers:
  - NVIDIA GPU Operator
  - NVIDIA vGPU
  - installation
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - vgpu
  - installation
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Prerequisites

Before installing the GPU Operator on NVIDIA vGPU, ensure the following:

# Using NVIDIA vGPU

## About Installing the Operator and NVIDIA vGPU

NVIDIA Virtual GPU (vGPU) enables multiple virtual machines (VMs) to have simultaneous,
direct access to a single physical GPU, using the same NVIDIA graphics drivers that are deployed on non-virtualized operating systems.

The installation steps assume `gpu-operator` as the default namespace for installing the NVIDIA GPU Operator.
In case of Red Hat OpenShift Container Platform, the default namespace is `nvidia-gpu-operator`.
Change the namespace shown in the commands accordingly based on your cluster configuration.
Also replace `kubectl` in the following commands with `oc` when running on Red Hat OpenShift.

NVIDIA vGPU is only supported with the NVIDIA License System.

## Platform Support

For information about the supported platforms, refer to Supported Deployment Options, Hypervisors, and NVIDIA vGPU Based Products.

For Red Hat OpenShift Virtualization, refer to NVIDIA GPU Operator with OpenShift Virtualization.

## Download vGPU Software

Perform the following steps to download the vGPU software and the latest NVIDIA vGPU driver catalog file from the NVIDIA Licensing Portal.

1. Log in to the NVIDIA Enterprise Application Hub at https://nvid.nvidia.com/dashboard and then click **NVIDIA LICENSING PORTAL**.
1. In the left navigation pane of the NVIDIA Licensing Portal, click **SOFTWARE DOWNLOADS**.
1. Locate **vGPU Driver Catalog** in the table of driver downloads and click **Download**.
1. Click the **PRODUCT FAMILY** menu and select **vGPU** to filter the downloads to vGPU only.
1. Locate the vGPU software for your platform in the table of software downloads and click **Download**.

The vGPU software is packaged as a ZIP file.
Unzip the file to obtain the NVIDIA vGPU Linux guest driver.
The guest driver file name follows the pattern `NVIDIA-Linux-x86_64-<version>-grid.run`.

## Build the Driver Container

Perform the following steps to build and push a container image that includes the vGPU Linux guest driver.

1. Clone the driver container repository and change directory into the repository:

   ```console
   $ git clone https://github.com/NVIDIA/gpu-driver-container.git
   ```

   ```console
   $ cd gpu-driver-container
   ```

1. Copy the NVIDIA vGPU guest driver from your extracted ZIP file and the NVIDIA vGPU driver catalog file to the operating system version you want to build the driver container for:

   Copy `<local-driver-download-directory>/\*-grid.run` and `vgpuDriverCatalog.yaml` to `ubuntu22.04/drivers/`.

   ```console
   $ cp <local-driver-download-directory>/*-grid.run ubuntu22.04/drivers/
   ```

   ```console
   $ cp vgpuDriverCatalog.yaml ubuntu22.04/drivers/
   ```

   For Red Hat OpenShift Container Platform, use a directory that includes `rhel` in the directory name.

1. Set environment variables for building the driver container image.

   -  Specify your private registry URL:

      ```console
      $ export PRIVATE_REGISTRY=<private-registry-url>
      ```

   - Specify the `OS_TAG` environment variable to identify the guest operating system name and version:

     ```console
     $ export OS_TAG=ubuntu22.04
     ```

     The value must match the guest operating system version.
     For Red Hat OpenShift Container Platform, specify `rhcos4.<x>` where `x` is the supported minor OCP version.
     Refer to Supported Operating Systems and Kubernetes Platforms for the list of supported OS distributions.

   - Specify the Linux guest vGPU driver version that you downloaded from the NVIDIA Licensing Portal:

     ```console
     $ export VGPU_DRIVER_VERSION=580.95.05
     ```

     The Operator automatically selects the compatible guest driver version from the drivers bundled with the `driver` image.
     If you disable the version check by specifying `--build-arg DISABLE_VGPU_VERSION_CHECK=true` when you build the driver image,
     then the `VGPU_DRIVER_VERSION` value is used as default.

1. Build the driver container image.

   > [!NOTE]
   > Docker is the only supported container tool for building the driver container image.
   > Multi-architecture builds additionally require [buildx](https://github.com/docker/buildx).

   ```console
   $ VGPU_GUEST_DRIVER_VERSION=${VGPU_DRIVER_VERSION} IMAGE_NAME=${PRIVATE_REGISTRY}/driver make build-vgpuguest-${OS_TAG}
   ```

1. Push the driver container image to your private registry.

   1. Log in to your private registry:

      ```console
      $ sudo docker login ${PRIVATE_REGISTRY} --username=<username>
      ```

      Enter your password when prompted.

   1. Push the driver container image to your private registry:

      ```console
      $ VGPU_GUEST_DRIVER_VERSION=${VGPU_DRIVER_VERSION} IMAGE_NAME=${PRIVATE_REGISTRY}/driver make push-vgpuguest-${OS_TAG}
      ```

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

## Related Skills

- verify gpu operator install
