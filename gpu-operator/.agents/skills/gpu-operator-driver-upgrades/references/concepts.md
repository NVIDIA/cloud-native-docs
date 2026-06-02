<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# About Upgrading the GPU Driver

The NVIDIA driver daemon set requires special consideration for upgrades because the driver kernel modules must be unloaded and loaded again on each driver container restart.
Consequently, the following steps must occur across a driver upgrade:

1. Disable all clients to the GPU driver.
1. Unload the current GPU driver kernel modules.
1. Start the updated GPU driver pod.
1. Install the updated GPU driver and load the updated kernel modules.
1. Enable the clients of the GPU driver.

The GPU Operator supports several methods for managing and automating this driver upgrade process.

> [!NOTE]
> The GPU Operator only manages the lifecycle of containerized drivers.
> Drivers which are pre-installed on the host are not managed by the GPU Operator.
