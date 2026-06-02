<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# About NVIDIA AI Enterprise and Supported Platforms

NVIDIA AI Enterprise is an end-to-end, cloud-native suite of AI and data analytics software, optimized, certified, and supported by NVIDIA with NVIDIA-Certified Systems.

Deploying the GPU Operator with NVIDIA AI Enterprise offers two installation options.

| vGPU Guest Driver | Data Center Driver |
| --- | --- |
| Uses a a prebuilt vGPU driver image that is only available to NVIDIA AI Enterprise customers. It is configured to use the [NVIDIA License System (NLS)](https://docs.nvidia.com/license-system/latest/). Installations on virtualization platforms must use the vGPU driver installation. Installation is performed by downloading a Bash script from NVIDIA NGC and running the script. | Uses the GPU Operator Helm chart that is publicly available and GPU driver containers that are publicly available. You must determine the supported driver branch, such as 550, for your NVIDIA AI Enterprise release. Installation is performed by running the `helm` command. |

For information about supported platforms, hypervisors, and operating systems, refer to the
[Product Support Matrix](https://docs.nvidia.com/ai-enterprise/latest/product-support-matrix/index.html)
in the NVIDIA AI Enterprise documentation.

For information about using vGPU with Red Hat OpenShift, refer to [NVIDIA AI Enterprise with OpenShift](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/nvaie-with-ocp.html).

## Related Information

-  [NVIDIA AI Enterprise](https://www.nvidia.com/en-us/data-center/products/ai-enterprise-suite/) web page.
