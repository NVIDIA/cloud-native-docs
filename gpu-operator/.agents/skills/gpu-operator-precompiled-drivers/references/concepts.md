<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# About Precompiled Driver Containers

Containers with precompiled drivers do not require internet access to download Linux kernel
header files, GCC compiler tooling, or operating system packages.

Using precompiled drivers also avoids the burst of compute demand that is required
to compile the kernel drivers with the conventional driver containers.

These two benefits are valuable to most sites, but are especially beneficial to sites
with restricted internet access or sites with resource-constrained hardware.

## Limitations and Restrictions

* Support for deploying the driver containers with precompiled drivers is limited to
  hosts with the x86_64 architecture and operating system versions listed in the supported-precompiled-drivers table.

  For information about using precompiled drivers with OpenShift Container Platform,
  refer to [GPU Operator with precompiled drivers on OpenShift](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/gpu-operator-with-precompiled-drivers.html).

* NVIDIA supports precompiled driver containers for the most recently released long-term
  servicing branch (LTSB) driver branch.

* NVIDIA builds images for the `aws`, `azure`, `generic`, `nvidia`, and `oracle` kernel variants.
  If your hosts run a different kernel variant, you can build a precompiled driver image
  and use your own container registry.

* Precompiled driver containers do not support NVIDIA vGPU or GPUDirect Storage (GDS).
