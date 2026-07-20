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



.. |prod-name-long| replace:: Rafay Platform
.. |prod-name-short| replace:: Rafay

#############################################
|prod-name-long| with the NVIDIA GPU Operator
#############################################


********************************************
About |prod-name-long| with the GPU Operator
********************************************

The |prod-name-long| provides the software foundation for operating and governing modern AI
infrastructure, including bare-metal provisioning, infrastructure lifecycle management, Kubernetes,
virtual machines, AI workbenches, and token factories. Together these capabilities help operators
increase infrastructure utilization and monetize AI services. Platform capabilities include
centralized fleet lifecycle management, cluster blueprints and Add-On management, zero-trust kubectl
access, RBAC/SSO, per-tenant cost allocation, and centralized audit logging.

The |prod-name-long| includes a Managed Kubernetes Service (Rafay MKS), a CNCF-conformant Kubernetes
distribution that provisions and manages the full lifecycle of upstream Kubernetes clusters on bare
metal and virtual machines. Using the NVIDIA GPU Operator with Rafay MKS gives customers a validated,
repeatable way to deliver GPU-accelerated Kubernetes infrastructure for AI/ML workloads:

* **Standardized GPU cluster provisioning.** Platform teams can package the GPU Operator as an Add-On
  in a Rafay cluster blueprint so every MKS cluster comes up with a consistent, version-pinned NVIDIA
  software stack (driver, container toolkit, device plugin, DCGM, and so on).

* **Fleet-wide lifecycle management.** The Rafay controller manages Kubernetes, CNI, CSI, and Add-On
  lifecycle across many clusters, which simplifies keeping GPU Operator versions, Kubernetes versions,
  and container runtimes in a known-good, validated combination.

* **Secure day-2 operations.** Operators can validate GPU health remotely (for example, running
  ``nvidia-smi`` in a GPU Operator pod through Rafay's zero-trust kubectl) without bastion hosts or
  shared kubeconfigs.

* **Multi-tenant, self-service GPU consumption.** On top of MKS, the |prod-name-long| lets platform
  teams publish Jupyter Notebooks, LLM inference endpoints, AI/ML jobs, and custom services as SKUs in
  a tenant-facing catalog. End users provision them on demand via a self-service portal, with RBAC,
  quotas, and per-tenant metering and cost allocation applied automatically. Rafay's **Token Factory**
  extends the model to token-metered LLM endpoints for delivering GenAI-as-a-service, and the **App
  Marketplace** supports packaged applications including NVIDIA NIM microservices.

* **Full-stack automation.** The same |prod-name-long| that manages the Rafay MKS distribution-based
  Kubernetes cluster also automates the provisioning of bare-metal servers and VMs the cluster sits
  on and manages the wider data-center inventory: virtual machines, storage, network switches, and
  InfiniBand fabrics. From one control plane, GPU capacity can serve both K8s tenants and non-K8s
  tenants (HPC jobs on SLURM, VM-based training pipelines) without a second orchestration layer.

For more information about Rafay MKS, refer to the `Rafay product documentation
<https://docs.rafay.co/learn/mks/>`__.


******************************
Validated Configuration Matrix
******************************

Rafay self-validated the NVIDIA GPU Operator with the following configuration:

.. list-table::
   :header-rows: 1

   * - Product Name
     - | NVIDIA
       | GPU
       | Operator
     - | Operating
       | System
     - | Container
       | Runtime
     - | Kubernetes
       | Version
     - | Helm
       | Version
     - | NVIDIA
       | GPU Model
     - | NVIDIA
       | GPU Driver
     - Hardware Model
     - Date Validated

   * - Rafay MKS 3.1
     - v26.3.1
     - Ubuntu 24.04.3 LTS
     - containerd 2.0.4
     - v1.34.3
     - v3.14.4
     - NVIDIA H100 NVL
     - 580.159.04
     - | Supermicro SYS-221GE-NR
       | Intel Xeon Gold 6548Y+ (32 cores/socket, 2 sockets)
       | 1 TB RAM
     - June 2026


*************
Prerequisites
*************

Before installing the NVIDIA GPU Operator on a Rafay MKS cluster, verify the following:

* A running Rafay MKS cluster on Kubernetes v1.34.3 (or a Kubernetes version listed in the validated
  configuration matrix), provisioned via the Rafay Console, Rafay CLI, API, or Terraform Provider.
  Refer to the `Rafay MKS provisioning documentation
  <https://docs.rafay.co/clusters/upstream/baremetal_vm/overview/>`__.

* At least one worker node with a supported NVIDIA GPU (validated with NVIDIA H100 NVL) physically
  installed.

* Nodes running Ubuntu 24.04 LTS with containerd 2.0.x as the container runtime.

* Cluster admin access via a kubeconfig downloaded from the Rafay Console, or zero-trust kubectl
  access through the |prod-name-long|.

* Helm v3 installed on the workstation used to install the GPU Operator Certification Helm chart.

* Outbound access from the cluster to the NVIDIA NGC registry (nvcr.io) and the NVIDIA Helm
  repository (https://helm.ngc.nvidia.com/nvidia).

Verify readiness with the following commands.

Confirm all nodes are ``Ready`` and report the expected Kubernetes version and container runtime:

.. code-block:: console

   $ kubectl get nodes -o wide

*Example output:*

.. code-block:: text

   NAME         STATUS   ROLES           AGE   VERSION   ...   CONTAINER-RUNTIME
   mks-cp-01    Ready    control-plane   7d    v1.34.3   ...   containerd://2.0.4
   mks-gpu-01   Ready    worker          7d    v1.34.3   ...   containerd://2.0.4

Confirm the NVIDIA GPU is visible on the worker node:

.. code-block:: console

   $ lspci | grep -i nvidia

*Example output:*

.. code-block:: text

   17:00.0 3D controller: NVIDIA Corporation H100 NVL (rev a1)

Confirm Helm 3.x is installed on the workstation:

.. code-block:: console

   $ helm version --short


*******************************************
Configuring Rafay MKS with the GPU Operator
*******************************************

On Rafay MKS, the NVIDIA GPU Operator is installed as an `Add-On <https://docs.rafay.co/blueprints/addons/>`_ (a versioned Helm chart managed by
the Rafay controller) that is part of a Rafay Cluster Blueprint. This is the recommended fleet-native
approach and lets every GPU-enabled MKS cluster in the fleet install the same NVIDIA stack from a
single source of truth in the |prod-name-long|.

Provisioning the MKS cluster
============================

Provision the Rafay MKS cluster with at least one GPU-enabled worker node using the Rafay Console,
RCTL CLI, API, or Terraform. Refer to the `Rafay MKS documentation for bare metal and VMs
<https://docs.rafay.co/clusters/upstream/baremetal_vm/overview/>`__.

Download the kubeconfig from the Rafay Console and confirm cluster access:

.. code-block:: console

   $ kubectl get nodes

*Example output:*

.. code-block:: text

   NAME         STATUS   ROLES           AGE   VERSION
   mks-cp-01    Ready    control-plane   7d    v1.34.3
   mks-gpu-01   Ready    worker          7d    v1.34.3

Preparing the cluster for the GPU Operator
==========================================

Because Rafay MKS provisions upstream Kubernetes, no MKS-specific privilege or configuration changes
are expected to be required before installing the GPU Operator.

Installing the GPU Operator as a Rafay Add-On
=============================================

Install the GPU Operator by defining it as a Rafay Add-On and referencing that Add-On from a Cluster
Blueprint applied to your GPU-enabled MKS clusters.

#. In the Rafay Console, create a new Add-On for the NVIDIA GPU Operator with the following
   configuration:

   * Source: https://helm.ngc.nvidia.com/nvidia

   * Version: v26.3.1

   * Namespace: ``gpu-operator`` (created by the Add-On if it does not exist).

   * Values: the certification pinned the NVIDIA driver version explicitly. Here is the
     ``values.yaml`` for the Add-On:

     .. code-block:: yaml

        driver:
          enabled: true
          repository: nvcr.io/nvidia
          image: driver
          version: "580.159.04"

#. Reference the GPU Operator Add-On from a **Cluster Blueprint** in the same Rafay Project. The
   Blueprint can include other Add-Ons the target clusters require (CNI, storage, observability, and
   so on).

#. Deploy the Cluster Blueprint to the target GPU-enabled MKS cluster(s). The Rafay control plane
   reconciles the cluster to the Blueprint and installs the GPU Operator via Helm.

#. Wait for all GPU Operator pods to reach ``Running`` or ``Completed``:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator


*****************************************
Verifying Rafay MKS with the GPU Operator
*****************************************

View the nodes and the number of NVIDIA GPUs on each node:

.. code-block:: console

   $ kubectl get nodes \
       -o=custom-columns=NAME:.metadata.name,GPUs:.metadata.labels.nvidia\.com/gpu\.count

*Example output:*

.. code-block:: text

   NAME         GPUs
   mks-gpu-01   1

Run ``nvidia-smi`` through the driver daemonset. Rafay customers can run this command from the Rafay
Console using the zero-trust kubectl web shell:

.. code-block:: console

   $ kubectl exec -n gpu-operator -it \
       $(kubectl get pods -n gpu-operator -l app=nvidia-driver-daemonset -o name | head -1) \
       -- nvidia-smi

The output shows the NVIDIA H100 NVL GPU, the driver version, and the CUDA version.

Refer to `Running Sample GPU Applications
<https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#running-sample-gpu-applications>`__
in the NVIDIA GPU Operator documentation for additional verification workloads.


***************
Getting Support
***************

* Rafay product documentation: https://docs.rafay.co

* Rafay product support: support@rafay.co


*******************
Related Information
*******************

* Rafay MKS documentation: https://docs.rafay.co/learn/mks/

* Rafay MKS on bare metal and VMs: https://docs.rafay.co/clusters/upstream/baremetal_vm/overview/

* NVIDIA GPU Operator documentation:
  https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html

* NVIDIA GPU Operator platform support:
  https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/platform-support.html
