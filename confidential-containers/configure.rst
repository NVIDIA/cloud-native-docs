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


.. _configure-confidential-containers:

#######################
Advanced Setup Overview
#######################

This page is the entry point for the **Advanced Setup** section.
For persona responsibilities and documentation structure, refer to :doc:`Personas <personas>`.

Before doing any of the topics, ensure you have completed the **Install** section.


.. grid:: 2
   :gutter: 3

   .. grid-item-card:: :octicon:`cpu;1.5em;sd-mr-1` Configuring Workloads
      :link: configure-workloads
      :link-type: doc

      Runtime class selection, GPU and NVSwitch resource types, and single- or multi-GPU passthrough.

   .. grid-item-card:: :octicon:`gear;1.5em;sd-mr-1` Managing the Confidential Computing Mode
      :link: configure-cc-mode
      :link-type: doc

      Set the confidential computing mode on NVIDIA GPUs at the cluster or node level.

   .. grid-item-card:: :octicon:`shield-check;1.5em;sd-mr-1` Attestation
      :link: attestation
      :link-type: doc

      Stand up a local Trustee instance and verify connectivity with the KBS client.

   .. grid-item-card:: :octicon:`stack;1.5em;sd-mr-1` Multi-GPU Passthrough
      :link: coco-multi-gpu-passthrough
      :link-type: ref

      Assign every GPU and NVSwitch on a node to a single Confidential Container virtual
      machine for NVSwitch-based HGX systems.
