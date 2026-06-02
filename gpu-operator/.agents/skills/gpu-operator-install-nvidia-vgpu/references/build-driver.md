<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Download vGPU Software and Build the Driver Container

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
