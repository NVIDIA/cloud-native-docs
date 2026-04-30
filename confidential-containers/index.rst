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

**********************************************************
NVIDIA Confidential Containers Architecture
**********************************************************

.. toctree::
   :caption: NVIDIA Confidential Containers Architecture
   :hidden:
   :titlesonly:

   Overview <overview.rst>
   Supported Platforms <supported-platforms.rst>

.. toctree::
   :caption: Install
   :hidden:
   :titlesonly:

   Prerequisites <prerequisites.rst>
   Deploy Confidential Containers <confidential-containers-deploy.rst>
   Run a Sample Workload <run-sample-workload.rst>

.. toctree::
   :caption: Configure
   :hidden:
   :titlesonly:

   Managing the CC Mode <configure-cc-mode.rst>
   Multi-GPU Passthrough <configure-multi-gpu.rst>
   Image Pull Timeouts <configure-image-pull-timeouts.rst>
   Attestation <attestation.rst>

.. toctree::
   :caption: Reference
   :hidden:
   :titlesonly:

   Release Notes <release-notes.rst>
   Licensing <licensing.rst>


This is documentation for NVIDIA's implementation of Confidential Containers including reference architecture information and supported platforms.


.. grid:: 3
   :gutter: 3

   .. grid-item-card:: :octicon:`book;1.5em;sd-mr-1` Overview
      :link: overview
      :link-type: doc

      Start here to review the reference architecture, use cases, and software components.

   .. grid-item-card:: :octicon:`server;1.5em;sd-mr-1` Supported Platforms
      :link: supported-platforms
      :link-type: doc

      Learn about the validated hardware, OS, and component versions.

   .. grid-item-card:: :octicon:`checklist;1.5em;sd-mr-1` Prerequisites
      :link: prerequisites
      :link-type: doc

      Hardware, BIOS, and Kubernetes cluster requirements.

   .. grid-item-card:: :octicon:`rocket;1.5em;sd-mr-1` Deploy Confidential Containers
      :link: confidential-containers-deploy
      :link-type: doc

      Install Kata Containers and the NVIDIA GPU Operator on Kubernetes.

   .. grid-item-card:: :octicon:`play;1.5em;sd-mr-1` Run a Sample Workload
      :link: run-sample-workload
      :link-type: doc

      Verify your deployment by running a GPU workload in a confidential container.

   .. grid-item-card:: :octicon:`gear;1.5em;sd-mr-1` Managing the CC Mode
      :link: configure-cc-mode
      :link-type: doc

      Set the confidential computing mode on NVIDIA GPUs at cluster or node level.

   .. grid-item-card:: :octicon:`cpu;1.5em;sd-mr-1` Multi-GPU Passthrough
      :link: configure-multi-gpu
      :link-type: doc

      Configure multi-GPU passthrough for NVSwitch-based HGX systems.

   .. grid-item-card:: :octicon:`clock;1.5em;sd-mr-1` Image Pull Timeouts
      :link: configure-image-pull-timeouts
      :link-type: doc

      Tune image pull timeouts for large container images in confidential VMs.

   .. grid-item-card:: :octicon:`shield-check;1.5em;sd-mr-1` Attestation
      :link: attestation
      :link-type: doc

      Remote attestation, Trustee, and the NVIDIA verifier for GPU workloads.

   .. grid-item-card:: :octicon:`note;1.5em;sd-mr-1` Release Notes
      :link: release-notes
      :link-type: doc

      New features and known issues for each release.

   .. grid-item-card:: :octicon:`law;1.5em;sd-mr-1` Licensing
      :link: licensing
      :link-type: doc

      Licensing information for Confidential Containers documentation.

