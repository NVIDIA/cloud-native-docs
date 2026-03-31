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


*****************************************************
NVIDIA Confidential Containers Reference Architecture
*****************************************************

.. _confidential-containers-overview:

Overview
========

NVIDIA GPUs power the training and deployment of Frontier Models—world-class Large Language Models (LLMs) that define the state of the art in AI reasoning and capability.

As organizations adopt these models in regulated industries such as financial services, healthcare, and the public sector, protecting model intellectual property and sensitive user data becomes essential. Additionally, the model deployment landscape is evolving to include public clouds, enterprise on-premises, and edge. A zero-trust posture on cloud-native platforms such as Kubernetes is essential to secure assets (model IP and enterprise private data) from untrusted infrastructure with privileged user access.

Securing data at rest and in transit is standard. Protecting data in-use remains a critical gap. Confidential Computing (CC) addresses this gap by providing isolation, encryption, and integrity verification of proprietary application code and sensitive data during processing. CC uses hardware-based Trusted Execution Environments (TEEs), such as AMD SEV-SNP / Intel TDX technologies, and NVIDIA Confidential Computing capabilities to create trusted enclaves.

In addition to TEEs, Confidential Computing provides Remote Attestation features. Attestation enables remote systems or users to interrogate the security state of a TEE before interacting with it and providing any secrets or sensitive data.

`Confidential Containers <https://github.com/confidential-containers>`_ (CoCo) is the cloud-native approach of CC on Kubernetes.
The Confidential Containers project leverages Kata Containers to provide the sandboxing capabilities. `Kata Containers <https://katacontainers.io/>`_ is an open-source project that provides lightweight Utility Virtual Machines (UVMs) that feel and perform like containers while providing strong workload isolation. Along with the Confidential Containers project, Kata enables the orchestration of secure, GPU-accelerated workloads in Kubernetes.

.. _coco-architecture:

Architecture Overview
=====================

NVIDIA's approach to the Confidential Containers architecture delivers on the key promise of Confidential Computing: confidentiality, integrity, and verifiability.
Integrating open source and NVIDIA software components with the Confidential Computing capabilities of NVIDIA GPUs, the Reference Architecture for Confidential Containers is designed to be the secure and trusted deployment model for AI workloads.

.. image:: graphics/CoCo-Reference-Architecture.png
   :alt: High-Level Reference Architecture for Confidential Containers

*High-Level Reference Architecture for Confidential Containers*

The key values of this architecture approach are:

1. **Built on OSS standards** - The Reference Architecture for Confidential Containers is built on key OSS components such as Kata, Trustee, QEMU, OVMF, and Node Feature Discovery (NFD), along with hardened NVIDIA components like NVIDIA GPU Operator.
2. **Highest level of isolation** - The Confidential Containers architecture is built on Kata containers, which is the industry standard for providing hardened sandbox isolation, and augmenting it with support for GPU passthrough to Kata containers makes the base of the Trusted Execution Environment (TEE).
3. **Zero-trust execution with attestation** - Ensuring the trust of the model providers/data owners by providing a full-stack verification capability with attestation. The integration of NVIDIA GPU attestation capabilities with Trustee based architecture, to provide composite attestation provides the base for secure, attestation based key-release for encrypted workloads, deployed inside the TEE.

.. _coco-use-cases:

Use Cases
=========

The target for Confidential Containers is to enable model providers (Closed and Open source) and Enterprises to leverage the advancements of Gen AI, agnostic to the deployment model (Cloud, Enterprise, or Edge). Some of the key use cases that CC and Confidential Containers enable are:

* **Zero-Trust AI & IP Protection:** You can deploy proprietary models (like LLMs) on third-party or private infrastructure. The model weights remain encrypted and are only decrypted inside the hardware-protected enclave, ensuring absolute IP protection from the host.
* **Data Clean Rooms:** This allows you to process sensitive enterprise data (like financial analytics or healthcare records) securely. Neither the infrastructure provider nor the model builder can see the raw data.

.. image:: graphics/CoCo-Sample-Workflow.png
   :alt: Sample Workflow for Securing Model IP on Untrusted Infrastructure with CoCo

*Sample Workflow for Securing Model IP on Untrusted Infrastructure with CoCo*

.. _coco-supported-platforms-components:

Software Components for Confidential Containers
===============================================

The following is a brief overview of the software components in NVIDIA's Reference Architecture for Confidential Containers

**Kata Containers**

Acts as the secure isolation layer by running standard Kubernetes Pods inside lightweight, hardware-isolated Utility Virtual Machines (UVMs) rather than sharing the untrusted host kernel. 
Kata containers are integrated with the Kubernetes `Agent Sandbox <https://github.com/kubernetes-sigs/agent-sandbox>`_ project to deliver sandboxing capabilities.

**NVIDIA GPU Operator**

Automates GPU lifecycle management. 
For Confidential Containers, it securely provisions GPU support and handles VFIO-based GPU passthrough directly into the Kata confidential Virtual Machine (VM)without breaking the hardware trust boundary.

The GPU Operator deploys the components needed to run Confidential Containers to simplify managing the software required for confidential computing and deploying confidential container workloads:

* NVIDIA Confidential Computing Manager (cc-manager) for Kubernetes - to set the confidential computing (CC) mode on the NVIDIA GPUs.
* NVIDIA Kata Sandbox Device Plugin - to discover NVIDIA GPUs along with their capabilities, to advertise these to Kubernetes, and to allocate GPUs during pod deployment.

Creating host-side CDI specifications for GPU passthrough, resulting in the file /var/run/cdi/nvidia.yaml, containing kind: nvidia.com/pgpu
Allocating GPUs during pod deployment.
Discovering NVIDIA GPUs, their capabilities, and advertising these to the Kubernetes control plane (allocatable resources as type nvidia.com/pgpu resources will appear for the node and GPU Device IDs will be registered with Kubelet). These GPUs can thus be allocated as container resources in your pod manifests. See below GPU Operator deployment instructions for the use of the key pgpu, controlled via a variable.


* NVIDIA VFIO Manager - binds discovered NVIDIA GPUs and nvswitches to the vfio-pci driver for VFIO passthrough.


**Kata Deploy**

Deployment mechanism (often managed via Helm) that installs the Kata runtime binaries, UVM images and kernels, and TEE-specific shims (such as ``kata-qemu-nvidia-gpu-snp`` or ``kata-qemu-nvidia-gpu-tdx``) onto the cluster's worker nodes.

**Node Feature Discovery (NFD)**

Bootstraps the node by advertising the node features via labels to make sophisticated scheduling decisions, like installing the Kata/CoCo stack only on the nodes that support the CC prerequisites for CPU and GPU. This feature directs the Operator to install node feature rules that detect CPU security features and the NVIDIA GPU hardware.

**Trustee**

Attestation and key brokering framework (which includes the Key Broker Service and Attestation Service). It acts as the cryptographic gatekeeper, verifying hardware/software evidence and only releasing secrets if the environment is proven secure.

**Snapshotter (e.g., Nydus)**

Handles the container image "guest pull" functionality. Used as a remote snapshotter, it bypasses image pulls on the host. Instead, it fetches and unpacks encrypted and signed container images directly inside the protected guest memory, keeping proprietary contents hidden and ensuring image integrity.

**Kata Agent and Agent Security Policy**

Runs inside the guest VM to manage the container lifecycle while enforcing a strict, immutable agent security policy based on Rego (regorus). This blocks the untrusted host from executing unauthorized commands, such as a malicious ``kubectl exec``.

**Confidential Data Hub (CDH)**

An in-guest component that securely receives sealed secrets from Trustee and transparently manages encrypted persistent storage and image decryption for the workload.

**NVRC (NVIDIA runcom)**

A minimal hardened init system that securely bootstraps the guest environment, life cycles the kata-agent, provides health checks on started helper daemons while drastically reducing the attack surface.


Cluster Topology Considerations
-------------------------------

You can configure all the worker nodes in your cluster for running GPU workloads with confidential containers, or you can configure some nodes for Confidential Containers and the others for traditional containers. Consider the following example where node A is configured to run traditional containers and node B is configured to run confidential containers.

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
     - * NVIDIA Confidential Computing Manager for Kubernetes
       * NVIDIA Sandbox Device Plugin
       * NVIDIA VFIO Manager
       * Node Feature Discovery

This configuration can be controlled through node labelling, as described in the :doc:`Confidential Containers deployment guide <confidential-containers-deploy>`.


