.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

.. headings # #, * *, =, -, ^, "

.. _coco-release-notes:

*************
Release Notes
*************

This document describes the new features and known issues for the NVIDIA Confidential Containers Reference Architecture.

----

.. _coco-v1.0.0:

1.0.0
=====

This is the initial general availability (GA) release of the NVIDIA Confidential Containers Reference Architecture, a validated deployment model for running GPU-accelerated AI workloads inside hardware-enforced Trusted Execution Environments (TEEs).
a validated deployment model for running GPU-accelerated AI workloads inside hardware-enforced Trusted Execution Environments (TEEs).
It is designed for organizations in regulated industries that require strong isolation and cryptographic verification to protect model intellectual property and sensitive data on untrusted infrastructure.

The architecture combines NVIDIA GPU Confidential Computing, Kata Containers, and the NVIDIA GPU Operator to provide a secure, attestable, Kubernetes-native platform for confidential AI workloads.

Key Features
------------

* This release supports HGX platforms with:

  - NVIDIA H100 (single-GPU passthrough)
  - NVIDIA H200 (single-GPU passthrough)
  - NVIDIA H100 Protected PCIe (multi-GPU passthrough)
  - NVIDIA H200 Protected PCIe (multi-GPU passthrough)
  - NVIDIA B200 (single-GPU and multi-GPU passthrough)
  - NVIDIA RTX Pro 6000 BSE (single-GPU passthrough)
  - AMD Genoa / Milan CPUs with Ubuntu 25.10 (kernel 6.17+) for SEV-SNP 
  - Intel Emerald Rapids / Granite Rapids CPUs with Ubuntu 25.10 (kernel 6.17+) for TDX

* This release supports the following software components:

  - NVIDIA GPU Operator v26.3.1
  - Kata Containers 3.29 (installed with the ``kata-deploy`` Helm chart)
  - Kata Lifecycle Manager 0.1.4
  - Key Broker Service (KBS) protocol 0.4.0
  - QEMU 10.1 + Patches
  - OVMF edk2-stable202511
  - Containerd 2.2.2
  - Kubernetes 1.32+
  - Ubuntu 25.10 (host OS)

* This release has Technology Support for Red Hat OpenShift Sandboxed Containers 1.12.


Limitations and Restrictions
----------------------------

* NVIDIA supports the GPU Operator and confidential computing with the containerd runtime only.

* All GPUs on the host must be configured for Confidential Computing.
  Configuring only a subset of GPUs on a node is not supported.
  For multi-GPU passthrough, all GPUs must be assigned to a single confidential VM.