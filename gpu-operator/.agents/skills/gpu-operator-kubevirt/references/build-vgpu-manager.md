<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Building the NVIDIA vGPU Manager image

> [!NOTE]
> Building the NVIDIA vGPU Manager image is only required if you are planning to use NVIDIA vGPU.
> If only planning to use PCI passthrough, skip this section.
> This section covers building the NVIDIA vGPU Manager container image and pushing it to a private registry.

Download the vGPU Software from the [NVIDIA Licensing Portal](https://stg.ui.licensing.nvidia.com/).

* Login to the NVIDIA Licensing Portal and navigate to the **Software Downloads** section.
* The NVIDIA vGPU Software is located in the **Software Downloads** section of the NVIDIA Licensing Portal.
* The vGPU Software bundle is packaged as a zip file. Download and unzip the bundle to obtain the NVIDIA vGPU Manager for Linux file, `NVIDIA-Linux-x86_64-<version>-vgpu-kvm.run`.

Next, clone the driver container repository and build the driver image with the following steps.

Open a terminal and clone the driver container image repository.

```console
$ git clone https://github.com/NVIDIA/gpu-driver-container.git
$ cd gpu-driver-container
```

1. Copy the NVIDIA vGPU manager from your extracted ZIP file to the operating system version you want to build the image for:
   * We use Ubuntu 22.04 as an example.

   Copy `<local-driver-download-directory>/\*-vgpu-kvm.run` to `vgpu-manager/ubuntu22.04/`.

   ```console
   $ cp <local-driver-download-directory>/*-vgpu-kvm.run vgpu-manager/ubuntu22.04/
   ```

> [!NOTE]
> For Red Hat OpenShift, use a directory that includes `rhel` in the directory name. For example, `vgpu-manager/rhel8`.

Set the following environment variables:

| Variable | Description |
| --- | --- |
| `PRIVATE_REGISTRY` | name of private registry used to store driver image |
| `VGPU_HOST_DRIVER_VERSION` | NVIDIA vGPU Manager version downloaded from NVIDIA Software Portal |
| `OS_TAG` | this must match the Guest OS version. In the following example `ubuntu22.04` is used. For Red Hat OpenShift this should be set to `rhcos4.x` where x is the supported minor OCP version. |

```console
$ export PRIVATE_REGISTRY=my/private/registry VGPU_HOST_DRIVER_VERSION=580.82.07 OS_TAG=ubuntu22.04
```

Build the NVIDIA vGPU Manager image.

```console
$ VGPU_HOST_DRIVER_VERSION=${VGPU_HOST_DRIVER_VERSION} IMAGE_NAME=${PRIVATE_REGISTRY}/vgpu-manager make build-vgpuhost-${OS_TAG}
```

Push NVIDIA vGPU Manager image to your private registry.

```console
$ VGPU_HOST_DRIVER_VERSION=${VGPU_HOST_DRIVER_VERSION} IMAGE_NAME=${PRIVATE_REGISTRY}/vgpu-manager make push-vgpuhost-${OS_TAG}
```
