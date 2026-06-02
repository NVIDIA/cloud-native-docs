<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Determining if a Precompiled Driver Container is Available

The precompiled driver containers are named according to the following pattern:

   <driver-branch>-<linux-kernel-version>-<os-tag>

For example, `525-5.15.0-69-generic-ubuntu22.04`.

Use one of the following ways to check if a driver container is available for your Linux kernel and driver branch:

* Use a web browser to access the NVIDIA GPU Driver page of the NVIDIA GPU Cloud registry at
  https://catalog.ngc.nvidia.com/orgs/nvidia/containers/driver/tags.
  Use the search field to filter the tags by your operating system version.

* Use the [NGC CLI](https://ngc.nvidia.com/setup/installers/cli) tool to list the tags for the driver container:

  ```console
  $ ngc registry image info nvidia/driver
  ```

  *Example Output*

  ```output
  Image Repository Information
    Name: driver
    Display Name: NVIDIA GPU Driver
    Short Description: Provision NVIDIA GPU Driver as a Container.
    Built By: NVIDIA
    Publisher: NVIDIA
    Multinode Support: False
    Multi-Arch Support: True
    Logo: https://assets.nvidiagrid.net/ngc/logos/Infrastructure.png
    Labels: Multi-Arch, NVIDIA AI Enterprise Supported, Infrastructure Software, Kubernetes Infrastructure
    Public: Yes
    Last Updated: Apr 20, 2023
    Latest Image Size: 688.87 MB
    Latest Tag: 525-5.15.0-69-generic-ubuntu22.04
    Tags:
        525-5.15.0-69-generic-ubuntu22.04
        525-5.15.0-70-generic-ubuntu22.04
        ...
  ```
