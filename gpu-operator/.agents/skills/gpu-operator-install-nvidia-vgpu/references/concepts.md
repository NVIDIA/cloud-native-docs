<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# About Installing the Operator and NVIDIA vGPU

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
