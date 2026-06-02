<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# About Using the Operator with Google GKE

There are two ways to use NVIDIA GPU Operator with Google Kubernetes Engine (GKE).
You can use Google driver installer to install and manage NVIDIA GPU Driver on the nodes
or you can use the Operator and driver manager to manage the driver and other NVIDIA software components.

The choice depends on the operating system and whether you prefer to have the Operator manage all the software components.

| Approach | Supported OS | Summary |
| --- | --- | --- |
| Google Driver Installer | Container-Optimized OS, Ubuntu with containerd | The Google driver installer manages the NVIDIA GPU Driver. NVIDIA GPU Operator manages other software components. |
| NVIDIA Driver Manager | Ubuntu with containerd | NVIDIA GPU Operator manages the lifecycle and upgrades of the driver and other NVIDIA software. |

The preceding information relates to using GKE Standard node pools.
For Autopilot Pods, using the GPU Operator is not supported, and you can refer to
[Deploy GPU workloads in Autopilot](https://cloud.google.com/kubernetes-engine/docs/how-to/autopilot-gpus).

## Related Information

* If you have an existing GKE cluster, refer to
  [Add and manage node pools](https://cloud.google.com/kubernetes-engine/docs/how-to/node-pools)
  in the GKE documentation.
* When you create new node pools, specify the
  `--node-labels="gke-no-default-nvidia-gpu-device-plugin=true"` and
  `--accelerator type=...,gpu-driver-version=disabled` CLI arguments
  to disable the GKE GPU device plugin daemon set and automatic driver installation on GPU nodes.
