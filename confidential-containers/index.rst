.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
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

#################################
NVIDIA Confidential Containers
#################################

.. toctree::
   :caption: Learn
   :hidden:
   :titlesonly:

   Overview <self>
   Reference Architecture <overview.rst>
   Personas <personas.rst>
   Supported Platforms <supported-platforms.rst>

.. toctree::
   :caption: Install
   :hidden:
   :titlesonly:

   Prerequisites <prerequisites.rst>
   Quickstart Install <install-quickstart.rst>
   Detailed Install Guide <confidential-containers-deploy.rst>
   Run a Sample Workload <run-sample-workload.rst>

.. toctree::
   :caption: Advanced Setup
   :hidden:
   :titlesonly:

   Advanced Setup Overview <configure.rst>
   Configuring Workloads <configure-workloads.rst>
   Managing the Confidential Computing Mode <configure-cc-mode.rst>
   Attestation <attestation.rst>

.. toctree::
   :caption: Reference
   :hidden:
   :titlesonly:

   Troubleshooting <troubleshooting.rst>
   Release Notes <release-notes.rst>
   Licensing <licensing.rst>

The NVIDIA Confidential Containers reference architecture extends NVIDIA GPU Confidential Computing functionality to Kubernetes-based workload deployments
It is a validated reference architecture for running GPU-accelerated AI workloads on Kubernetes inside hardware-enforced Trusted Execution Environments (TEEs).
Leveraging the CNCF `Confidential Containers <https://confidentialcontainers.org/>`__ and Kata Containers with NVIDIA's GPU Operator, this reference architecture provides a way to protect model intellectual property and sensitive data from untrusted infrastructure across public cloud, on-premises, and edge deployments.
 

Benefits
========

The reference architecture provides the following benefits:


* Offers a way to secure model intellectual property and sensitive data from untrusted infrastructure—across public cloud, on-premises, and edge deployments.
* Accelerates adoption of generative AI in regulated industries by providing a way to deploy proprietary models on third-party or private infrastructure.
* Isolate GPU workloads in hardware-protected enclaves with encrypted memory and integrity verification.
* Operate confidential workloads with standard Kubernetes pods, runtime classes, and scheduling.
* Verify TEE state through remote attestation before releasing secrets or decrypted model weights.

See :doc:`Reference Architecture <overview>` for the full value proposition, trust model, and architecture diagrams.

Core Concepts
=============

`Confidential Containers <https://confidentialcontainers.org/>`__ is the cloud-native approach to Confidential Computing on Kubernetes.
Rather than running pods on the shared host kernel, it uses hardware-isolated virtual machines so workloads are protected from the host and other tenants.
On supported hardware (AMD SEV-SNP or Intel TDX), that isolation forms a trusted execution environment (TEE) with encrypted memory and integrity verification.

Key ideas include attestation, sealed secrets, and encrypted container images.
See the :ref:`Background <confidential-containers-overview>` section in the Reference Architecture, the upstream `Confidential Containers documentation <https://confidentialcontainers.org/docs/>`__, or :doc:`Personas <personas>` for role-based navigation.

Core Components
===============

This documentation focuses on the components you install, configure, and operate to deploy workloads in a confidential runtime on Kubernetes.
It provides a detailed overview in the :doc:`Reference Architecture <overview>` that describes the full stack, and end-to-end deployment guides for configuring Kata Containers and the NVIDIA GPU Operator.

* Kata Containers: Runs pods inside TEE-protected virtual machines instead of on the shared host kernel.
  Install Kata Deploy and TEE-specific runtime shims in :doc:`Quickstart Install <install-quickstart>` and :doc:`Detailed Install Guide <confidential-containers-deploy>`.
  Schedule workloads with a TEE-aware ``RuntimeClass`` in :doc:`Configuring Workloads <configure-workloads>`.

* NVIDIA GPU Operator: Automates GPU Confidential Computing on eligible nodes, including CC mode, VFIO passthrough, and GPU allocation for Kata pods.
  Configure the Operator and node labels in :doc:`Detailed Install Guide <confidential-containers-deploy>`.
  Manage CC mode in :doc:`Managing the Confidential Computing Mode <configure-cc-mode>`.

  For Confidential Containers, the Operator deploys:

  * NVIDIA Confidential Computing Manager (cc-manager)
  * NVIDIA Kata Sandbox Device Plugin
  * NVIDIA VFIO Manager
  * Node Feature Discovery (NFD)

* Trustee and attestation: Verifies TEE state and brokers key release for sealed secrets, encrypted images, and authenticated registries.
  Stand up and validate attestation in :doc:`Attestation <attestation>`.

Other architecture components, such as a guest snapshotter, Confidential Data Hub, Kata Agent security policies, and NVIDIA Runtime Container (NVRC), are described in the :ref:`Software Components for Confidential Containers <coco-supported-platforms-components>` section of the Reference Architecture.

Use Cases
=========

Common scenarios include protecting proprietary model IP on third-party infrastructure, running frontier models in a sovereign environment, and processing sensitive enterprise data in data clean rooms.
See :ref:`Use Cases <coco-use-cases>` in the Reference Architecture for workflows and deployment scenarios.


Learn
=====

.. grid:: 2
   :gutter: 3

   .. grid-item-card:: :octicon:`book;1.5em;sd-mr-1` Reference Architecture
      :link: overview
      :link-type: doc

      Use cases, software components, and cluster topology.

   .. grid-item-card:: :octicon:`info;1.5em;sd-mr-1` Personas
      :link: personas
      :link-type: doc

      Roles, responsibilities, and documentation navigation by persona.


   .. grid-item-card:: :octicon:`server;1.5em;sd-mr-1` Supported Platforms
      :link: supported-platforms
      :link-type: doc

      Validated hardware, OS, and component versions.

Install
=======

.. grid:: 2
   :gutter: 3

   .. grid-item-card:: :octicon:`checklist;1.5em;sd-mr-1` Prerequisites
      :link: prerequisites
      :link-type: doc

      Hardware, BIOS, and Kubernetes cluster requirements.

   .. grid-item-card:: :octicon:`zap;1.5em;sd-mr-1` Quickstart Install
      :link: install-quickstart
      :link-type: doc

      Minimal steps to install Kata Containers and the GPU Operator.

   .. grid-item-card:: :octicon:`rocket;1.5em;sd-mr-1` Detailed Install Guide
      :link: confidential-containers-deploy
      :link-type: doc

      Install with per-node labeling, configuration options, and troubleshooting.

   .. grid-item-card:: :octicon:`play;1.5em;sd-mr-1` Run a Sample Workload
      :link: run-sample-workload
      :link-type: doc

      Run a sample GPU workload; success is ``Test PASSED`` in the pod logs.

Advanced Setup
==============

.. grid:: 2
   :gutter: 3

   .. grid-item-card:: :octicon:`list-unordered;1.5em;sd-mr-1` Advanced Setup Overview
      :link: configure
      :link-type: doc

      Choose attestation, CC mode, and workload configuration after install.

   .. grid-item-card:: :octicon:`cpu;1.5em;sd-mr-1` Configuring Workloads
      :link: configure-workloads
      :link-type: doc

      Runtime classes, resource types, and multi-GPU passthrough.

   .. grid-item-card:: :octicon:`gear;1.5em;sd-mr-1` Managing the Confidential Computing Mode
      :link: configure-cc-mode
      :link-type: doc

      Set CC mode at the cluster or node level.

   .. grid-item-card:: :octicon:`shield-check;1.5em;sd-mr-1` Attestation
      :link: attestation
      :link-type: doc

      Trustee quickstart and connectivity checks (not required for the install sample).
