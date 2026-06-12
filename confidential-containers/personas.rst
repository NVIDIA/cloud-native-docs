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

.. _coco-using-this-guide:

########
Personas
########

This page provides an overview of the prior knowledge recommended before implementing the architecture, the personas who own each part of the deployment, and how to navigate this documentation.

******************
Before You Begin
******************

This documentation describes NVIDIA's reference architecture and deployment recommendations for the upstream `CNCF Confidential Containers project <https://confidentialcontainers.org/>`_ with NVIDIA GPUs.
Understanding the upstream project's goals, architecture, and threat model will give you the context needed to understand architecture decisions described in this documentation.

Before using this documentation, you should be familiar with:

* Confidential Containers concepts outlined in the upstream `Confidential Containers documentation <https://confidentialcontainers.org/docs/>`__, including the trust model, attestation flow, and key features such as sealed secrets and encrypted container images.
  Start there if you are new to Confidential Computing on Kubernetes.
* Kubernetes administration and deployment experience, including deploying workloads, using ``kubectl``, and installing components with Helm.
  Refer to the `Kubernetes documentation <https://kubernetes.io/docs/home/>`_ if you need a foundation.
* Confidential Computing hardware, familiarity with AMD SEV-SNP or Intel TDX, and an understanding of which technology your target hardware uses.

The documentation on this site is specific for deploying Confidential Containers on NVIDIA GPUs with Kata Containers and the NVIDIA GPU Operator.
It covers the steps you take to enable and configure these components on your cluster to align with the NVIDIA Reference Architecture for Confidential Containers.
For more advanced Confidential Containers topics, refer to the upstream `Confidential Containers documentation <https://confidentialcontainers.org/docs/>`__.

********
Personas
********

The personas used throughout this documentation describe who is responsible for each stage of enabling and managing Confidential Computing, from hardware selection through workload deployment.
Depending on your role, you may complete several sections or only a subset.

.. list-table::
   :header-rows: 1
   :widths: 28 42 30

   * - Persona
     - Responsibilities
     - Start here
   * - :ref:`Hardware IT Administrator <coco-persona-hardware-it-administrator>`
     - Selects Confidential Computing-capable CPU and GPU hardware and configures BIOS/UEFI settings.
     - :doc:`Supported Platforms <supported-platforms>`
   * - :ref:`Host OS Administrator <coco-persona-host-os-administrator>`
     - Prepares the host operating system after hardware and BIOS configuration are complete.
     - :doc:`Supported Platforms <supported-platforms>`
   * - :ref:`Kubernetes Cluster Administrator <coco-persona-kubernetes-cluster-administrator>`
     - Installs and manages the Kubernetes cluster and the Confidential Containers software stack.
     - :doc:`Prerequisites <prerequisites>`
   * - :ref:`Security Engineer <coco-persona-security-engineer>`
     - Validates Confidential Computing configuration, attestation policy, and secret release for workloads.
     - :doc:`Attestation Quickstart <attestation>`
   * - :ref:`Container User <coco-persona-container-user>`
     - Deploys confidential GPU workloads on a prepared cluster.
     - :doc:`Configuring Workloads <configure-workloads>`

.. _coco-persona-hardware-it-administrator:

***************************
Hardware IT Administrator
***************************

The Hardware IT Administrator is near the beginning of the Confidential Computing workflow.
This persona selects the correct CPU and GPU part numbers and configures BIOS/UEFI settings for subsequent steps.
Typical roles include system architect and IT administrator.

Relevant pages in this documentation:

* :doc:`Supported Platforms <supported-platforms>`: validated CPU, GPU, OS, and component version combinations that NVIDIA has tested with Confidential Containers.

For BIOS configuration and hardware setup, refer to the `NVIDIA Confidential Computing Deployment Guide <https://docs.nvidia.com/cc-deployment-guide-tdx-snp.pdf>`_ *Hardware IT Administrator* section.

.. _coco-persona-host-os-administrator:

**********************
Host OS Administrator
**********************

The Host OS Administrator receives a system with BIOS/UEFI configured for Confidential Computing and prepares the host operating system.
This persona is responsible for host OS selection, initial configuration, and validation before confidential workloads can run.
Typical roles include system architect, cloud administrator, or advanced on-premises user.

Relevant pages in this documentation:

* :doc:`Supported Platforms <supported-platforms>`: validated host OS and kernel versions.

For host OS setup, refer to the `NVIDIA Confidential Computing Deployment Guide <https://docs.nvidia.com/cc-deployment-guide-tdx-snp.pdf>`_ *Host OS Administrator* section.

.. _coco-persona-kubernetes-cluster-administrator:

********************************
Kubernetes Cluster Administrator
********************************

The Kubernetes Cluster Administrator is responsible for installing and managing the Kubernetes cluster and the Confidential Containers software stack.
This persona could be a platform engineer with cluster-admin access to the API, host access to worker nodes, and familiarity with Helm and ``kubectl``.
This persona performs the initial deployment and is responsible for day-two operations such as upgrades and Confidential Computing mode changes.

Relevant pages:

* :doc:`Reference Architecture <overview>`: understand the software components and how they fit together.
* :doc:`Prerequisites <prerequisites>`: prepare worker nodes and the Kubernetes cluster.
* :doc:`Quickstart Install <install-quickstart>`: minimal steps to install Kata Containers and the GPU Operator.
* :doc:`Detailed Install Guide <confidential-containers-deploy>`: install with per-node labeling and additional configuration options.
* :doc:`Run a Sample Workload <run-sample-workload>`: confirm the deployment was successful.
* :doc:`Managing the Confidential Computing Mode <configure-cc-mode>`: change the CC mode on GPUs at the cluster or node level as needed.
* :doc:`Troubleshooting <troubleshooting>`: resolve install and deploy failures (for example :ref:`Insufficient nvidia.com/pgpu <coco-pending-pod>`).

.. _coco-persona-security-engineer:

*****************
Security Engineer
*****************

The Security Engineer might or might not be the Kubernetes Cluster Administrator.
Their work may cover attestation services, reference values, policies, and secret release for confidential workloads.
Typical roles include security engineer, platform security, or DevSecOps.

Relevant pages:

* :doc:`Reference Architecture <overview>`: understand the use cases, trust model, and how workloads are isolated from the infrastructure.
* :doc:`Attestation Quickstart <attestation>`: stand up a local Trustee instance and verify connectivity.
  Attestation is required for workloads that use secrets, encrypted container images, or authenticated registries.

For production attestation workflows, secret management, and policy configuration, refer to the upstream `Confidential Containers attestation documentation <https://confidentialcontainers.org/docs/attestation/>`_.

.. _coco-persona-container-user:

**************
Container User
**************

The Container User deploys confidential applications on a system that is already configured for Confidential Computing.
In this documentation, that means deploying confidential GPU workloads with Kubernetes manifests on a cluster that the Kubernetes Cluster Administrator has prepared.
This persona works primarily with Kubernetes workload manifests and does not require host access to worker nodes.

Relevant pages:

* :doc:`Configuring Workloads <configure-workloads>`: runtime class selection, GPU and NVSwitch resource types, and single- or multi-GPU passthrough manifests.
* :doc:`Run a Sample Workload <run-sample-workload>`: run the reference workload to confirm the cluster is ready before deploying your own application.
* :doc:`Advanced Setup Overview <configure>`: choose attestation, CC mode, and workload configuration topics after install.
