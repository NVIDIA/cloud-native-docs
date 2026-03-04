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

Overview of NVIDIA Confidential Containers
==========================================

.. _confidential-containers-overview:


NVIDIA GPUs power the training and deployment of Frontier Models—world-class Large Language Models (LLMs) that define the state of the art in AI reasoning and capability. As organizations adopt these models in regulated industries such as financial services, healthcare, and the public sector, protecting model intellectual property and sensitive user data becomes essential. 

While securing data at rest and in transit is industry standard, protecting data in use remains a critical gap. Confidential Computing (CC) addresses this gap by providing isolation, encryption, and integrity verification of proprietary application code and sensitive data during processing. CC uses hardware-based Trusted Execution Environments (TEEs)—such as AMD SEV—to create protected enclaves in both CPU and GPU.

The TEE provides embedded encryption keys and an attestation mechanism through cryptographic verification to ensure that keys are only accessible by authorized application code.

`Confidential Containers <https://github.com/confidential-containers>`_ (CoCo) is the cloud-native approach of CC in Kubernetes. `Kata Containers <https://katacontainers.io/>`_ is an open source project that provides lightweight utility Virtual Machines (UVMs) that feel and perform like containers but provide strong workload isolation. Along with the CoCo project, Kata enables the orchestration of secure, GPU-accelerated workloads in Kubernetes.

This page describes NVIDIA's Early Access implementation for orchestrating CoCo with Kata using the NVIDIA GPU Operator.

Architecture Overview
---------------------

The following high-level flow and diagram show some fundamental concepts for CoCo. The NVIDIA GPU operator is a central component to enable this workflow. In the following section, we describe the most important components and the deployment scenario.

.. image:: graphics/CoCo-Architecture.png
   :alt: High-Level Logical Diagram of Software Components and Communication Paths

*High-Level Logical Diagram of Software Components and Communication Paths*

1. The GPU Operator sets up the nodes to be Confidential Computing ready.

   * During installation, the GPU Operator deploys the components needed to run Confidential Containers to nodes that meet Confidential Container requirements.

2. Application Owner deploys container with Kata-Confidential Containers runtime class.

   * The user deploys a confidential container GPU workload, which is placed onto a specific node by the Kubernetes control plane. On this node, the local Kubelet instructs its container runtime to create this pod.
   * Containerd is configured to run a Kata runtime to start the Kata CVM.  
   * The Kata runtime starts the Kata CVM using the upstream Kata Containers kernel and NVIDIA initial RAM disk containing the VM's root filesystem.
   * In the Kata CVM's early boot phase, the `NVRC <https://github.com/NVIDIA/nvrc/tree/main>`_ prepares the passthrough GPU for container access.
   * Kata agent starts containers in the Kata CVM.  
   * The confidential containers attestation agent exercises remote attestation based on the Remote ATtestation ProcedureS (RATS) model in concert with the Confidential Containers' Trustee solution. As part of this, the attestation agent transitions the GPU into the Ready state. Refer to the attestation section for more details.


Key Software Components of the NVIDIA GPU Operator
===================================================

NVIDIA GPU Operator brings together the following software components to simplify managing the software required for confidential computing and deploying confidential container workloads:

**NVIDIA Kata Manager for Kubernetes**

GPU Operator deploys the NVIDIA Kata Manager for Kubernetes, k8s-kata-manager. The manager is responsible for creating host-side CDI specifications for GPU passthrough.

**NVIDIA Confidential Computing Manager for Kubernetes**

GPU Operator deploys the manager, k8s-cc-manager, to set the confidential computing (CC) mode on the NVIDIA GPUs.

**NVIDIA Sandbox Device Plugin**

GPU Operator deploys the sandbox device plugin, nvidia-sandbox-device-plugin-daemonset, to discover NVIDIA GPUs along with their capabilities, to advertise these to Kubernetes, and to allocate GPUs during pod deployment.

**NVIDIA VFIO Manager**

GPU Operator deploys the VFIO manager, nvidia-vfio-manager, to bind discovered NVIDIA GPUs to the vfio-pci driver for VFIO passthrough.

**Node Feature Discovery (NFD)**

When you install NVIDIA GPU Operator for confidential computing, you must specify the ``nfd.nodefeaturerules=true`` option. This option directs the Operator to install node feature rules that detect CPU security features and the NVIDIA GPU hardware. You can confirm the rules are installed by running ``kubectl get nodefeaturerules nvidia-nfd-nodefeaturerules``.

On nodes that have NVIDIA Hopper family GPU and AMD SEV-SNP, NFD adds labels to the node such as ``"feature.node.kubernetes.io/cpu-security.sev.snp.enabled": "true"`` and ``"nvidia.com/cc.capable": "true"``. NVIDIA GPU Operator only deploys the operands for confidential containers on nodes that have the ``"nvidia.com/cc.capable": "true"`` label.

Cluster Topology Considerations
---------------------------------

You can configure all the worker nodes in your cluster for running GPU workloads with confidential containers or you configure some nodes for confidential containers and the others for traditional containers. Consider the following example where node A is configured to run traditional containers and node B is configured to run confidential containers.

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Node A - Traditional Containers receives the following software components
     - Node B - Kata CoCo receives the following software components
   * - * NVIDIA Driver Manager for Kubernetes
       * NVIDIA Container Toolkit
       * NVIDIA Device Plugin for Kubernetes
       * NVIDIA DCGM and DCGM Exporter
       * NVIDIA MIG Manager for Kubernetes
       * Node Feature Discovery
       * NVIDIA GPU Feature Discovery
     - * NVIDIA Kata Manager for Kubernetes
       * NVIDIA Confidential Computing Manager for Kubernetes
       * NVIDIA Sandbox Device Plugin
       * NVIDIA VFIO Manager
       * Node Feature Discovery

This configuration can be controlled through node labelling as described in :ref:`Deploy Confidential Containers with NVIDIA GPU Operator <confidential-containers-deploy>`.