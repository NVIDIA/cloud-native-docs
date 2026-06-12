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

NVIDIA Confidential Containers is a validated reference architecture for running GPU-accelerated AI workloads on Kubernetes inside hardware-enforced Trusted Execution Environments (TEEs).
It extends NVIDIA GPU Confidential Computing to standard Kubernetes deployments using CNCF `Confidential Containers <https://confidentialcontainers.org/>`__ and Kata Containers with the NVIDIA GPU Operator.
Use it to protect model intellectual property and sensitive data from untrusted infrastructure across public cloud, on-premises, and edge deployments.

Benefits
========

Confidential Containers provides the following benefits:

* Protect model IP and sensitive data on untrusted public cloud, on-premises, or edge infrastructure.
* Deploy proprietary generative AI models in regulated industries on third-party or private clusters.
* Isolate GPU workloads in hardware-protected enclaves with encrypted memory and integrity verification.
* Operate confidential workloads with standard Kubernetes pods, runtime classes, and scheduling.
* Verify TEE state through remote attestation before releasing secrets or decrypted model weights.

Refer to :doc:`Reference Architecture <overview>` for the full value proposition, trust model, and architecture diagrams.

Use Cases
---------

Common scenarios include protecting proprietary model IP on third-party infrastructure, running frontier models in a sovereign environment, and processing sensitive enterprise data in data clean rooms.
Refer to :ref:`Use Cases <coco-use-cases>` in the Reference Architecture for workflows and deployment scenarios.

Core Concepts
=============

`Confidential Containers <https://confidentialcontainers.org/>`__ runs Kubernetes pods in hardware-isolated virtual machines instead of on the shared host kernel, protecting workloads from the host and other tenants.
On supported hardware (AMD SEV-SNP or Intel TDX), that isolation forms a trusted execution environment (TEE) with encrypted memory and integrity verification.

Attestation, sealed secrets, and encrypted container images are core to the model.
Refer to :ref:`Background <confidential-containers-overview>` in the Reference Architecture.

Core Components
===============

This documentation focuses on the components you install, configure, and operate to run workloads in a Confidential Containers runtime on Kubernetes.
The :doc:`Reference Architecture <overview>` describes the full stack. 
The install guides cover Kata Containers and the NVIDIA GPU Operator end to end.

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

Using This Documentation
========================

This documentation describes the NVIDIA reference architecture for Confidential Containers and deployment recommendations for the upstream `CNCF Confidential Containers project <https://confidentialcontainers.org/>`_ with NVIDIA GPUs.
It covers NVIDIA-specific configurations needed to run Confidential Containers workloads on Kubernetes.
This primarily includes the steps to enable and configure Kata Containers and the NVIDIA GPU Operator on your cluster.

For advanced Confidential Containers topics and day-two operations, refer to the upstream `Confidential Containers documentation <https://confidentialcontainers.org/docs/>`__, as the workflows and implementations are not NVIDIA specific.
For example, an attestation implementation is not specific to NVIDIA GPUs.
A brief attestation overview and evaluation quickstart is available in :doc:`Attestation <attestation>`, but full production attestation implementation guides are in the upstream `Confidential Containers attestation documentation <https://confidentialcontainers.org/docs/attestation/>`__.


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
