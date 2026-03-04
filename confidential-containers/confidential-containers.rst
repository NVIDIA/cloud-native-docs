.. _early-access-gpu-operator-confidential-containers-kata:

.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software

.. headings # #, * *, =, -, ^, "

.. _confidential-containers-platform-support:

################
Platform Support 
################

Refer to the *Confidential Computing Deployment Guide* at the https://docs.nvidia.com/confidential-computing website for information about supported NVIDIA GPUs, such as the NVIDIA Hopper H100, and specifically to https://docs.nvidia.com/cc-deployment-guide-snp.pdf for setup specific to AMD SEV-SNP machines.

The following topics in the deployment guide apply to a cloud-native environment:

* Hardware selection and initial hardware configuration, such as BIOS settings.  
* Host operating system selection, initial configuration, and validation. 

When following the cloud-native sections in above linked deployment guide, use Ubuntu 25.10 as host OS with its default kernel version and configuration.

The remaining configuration topics in the deployment guide do not apply to a cloud-native environment. NVIDIA GPU Operator performs the actions that are described in these topics.

For scope of this EA, the following is the validated support matrix. Any other combination has not been evaluated:

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Component
     - Release
   * - GPU Platform
     - Hopper 100/200
   * - GPU Driver
     - R580 TRD 3
   * - kata-containers/kata-containers
     - 3.24.0
   * - NVIDIA/gpu-operator
     - v25.10.0 and higher

.. _limitations-and-restrictions:

Limitations and Restrictions
=============================

* Only the AMD platform using SEV-SNP is supported for Confidential Containers Early Access. 
* GPUs are available to containers as a single GPU in passthrough mode only. Multi-GPU passthrough and vGPU are not supported.  
* Support is limited to initial installation and configuration only. Upgrade and configuration of existing clusters to configure confidential computing is not supported.  
* Support for confidential computing environments is limited to the implementation described on this page.  
* NVIDIA supports the GPU Operator and confidential computing with the containerd runtime only.   
* OpenShift is not supported in the Early Access release.
* NFD doesn't label all Confidential Container capable nodes as such automatically. In some cases, users must manually label nodes to deploy the NVIDIA Confidential Computing Manager for Kubernetes operand onto these nodes as described below.

Deployment and Configuration
=============================

For detailed instructions on deploying and configuring confidential containers with the NVIDIA GPU Operator, refer to the following guide: