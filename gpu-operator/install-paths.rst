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

.. headings (h1/h2/h3/h4/h5) are # * = -

.. _install-paths:
.. _gpu-operator-install-paths:

================
Install Overview
================

The NVIDIA GPU Operator supports many Kubernetes platforms, licensing models, and deployment configurations.
This page helps you choose the install guide that matches your environment.
Each linked page contains the step-by-step procedures; start here when you are not sure where to begin.

Before you install, review :doc:`prerequisites` to confirm that your cluster, hardware, and tooling meet the requirements for your chosen path.

.. admonition:: Red Hat OpenShift Container Platform
   :class: tip

   If you run Red Hat OpenShift, install the GPU Operator through OperatorHub or the OpenShift CLI (OLM), not the Helm
   quickstart in this book. Refer to :external+ocp:doc:`index` for OpenShift install, upgrade, and disconnected
   deployment procedures.


GPU Resource Management
=======================

The GPU Operator supports managing GPU resources on your cluster using the following methods:

- NVIDIA Device Plugin through the ``ClusterPolicy`` custom resource.
- DRA Driver for NVIDIA GPUs through the ``GPUCluster`` custom resource.

At install time, choose one GPU resource management model for the cluster.
Use either ``ClusterPolicy`` or ``GPUCluster``; using both in the same cluster is not supported.

.. note::

   Deploying the DRA model through the ``GPUCluster`` custom resource is in Technology Preview and is supported only
   for greenfield (new) deployments.
   The ``GPUCluster`` API is served under ``nvidia.com/v1alpha1`` and is subject to change in future releases.
   Migrating an existing ``ClusterPolicy`` deployment to ``GPUCluster`` in place is not supported.

.. list-table::
   :header-rows: 1
   :widths: 34 33 33

   * - Component
     - Device-plugin model (``ClusterPolicy``)
     - DRA model (``GPUCluster``)
   * - GPU allocation
     - NVIDIA Kubernetes Device Plugin (extended resources)
     - DRA Driver for NVIDIA GPUs (ResourceClaims)
   * - NVIDIA GPU driver
     - Managed by ``ClusterPolicy`` or ``NVIDIADriver``
     - Pre-installed or managed by ``NVIDIADriver`` (not managed by ``GPUCluster``)
   * - Default install path
     - :doc:`Install with Helm <getting-started>`
     - :doc:`Deploying the GPU Operator with DRA Support <gpu-operator-dra>`

Do not deploy ``ClusterPolicy`` and ``GPUCluster`` as GPU resource management models in the same cluster.
Refer to :doc:`Deploying the GPU Operator with DRA Support <gpu-operator-dra>` for the supported greenfield DRA
deployment.

For the fully supported standalone DRA Driver Helm chart (without Operator-managed ``GPUCluster``), refer to
:doc:`DRA Driver for NVIDIA GPUs <dra-intro-install>`.


Driver Provisioning
===================

How the NVIDIA GPU driver is installed is independent of which platform or GPU resource management model you choose.

.. list-table::
   :header-rows: 1
   :widths: 30 35 35

   * - Model
     - When to use
     - Where to configure
   * - Operator-managed (``ClusterPolicy``)
     - Default for generic Kubernetes and most cloud installs
     - :doc:`Install with Helm <getting-started>` and :ref:`common deployment scenarios`
   * - ``NVIDIADriver`` custom resource
     - Per-node or mixed-OS driver management; use this for Operator-managed drivers with the DRA model
     - :doc:`GPU Driver CRD <gpu-driver-configuration>`
   * - Pre-installed on the host
     - Driver already present on GPU nodes (``driver.enabled=false``)
     - :doc:`Install with Helm <getting-started>`, :doc:`Microsoft AKS <microsoft-aks>`, or
       :doc:`Deploying the GPU Operator with DRA Support <gpu-operator-dra>`


NVIDIA Licenses
===============

If your deployment requires a licensed NVIDIA product or a sovereign-cloud configuration, use one of these guides
instead of the default Helm install.

.. grid:: 1 1 2 2
   :gutter: 3

   .. grid-item-card:: :octicon:`briefcase;1.5em;sd-mr-1` NVIDIA AI Enterprise
      :link: install-gpu-operator-nvaie
      :link-type: doc

      Install with NVAIE licensing using the NGC Bash script (vGPU guest) or standard Helm (datacenter driver).
      +++
      :bdg-secondary:`NVAIE`

   .. grid-item-card:: :octicon:`device-desktop;1.5em;sd-mr-1` NVIDIA vGPU
      :link: install-gpu-operator-vgpu
      :link-type: doc

      Build a custom driver image and install with vGPU licensing secrets.
      +++
      :bdg-secondary:`vGPU`

   .. grid-item-card:: :octicon:`shield;1.5em;sd-mr-1` Government Ready Components
      :link: install-gpu-operator-gov-ready
      :link-type: doc

      Deploy STIG- and FIPS-hardened containers for sovereign and FedRAMP environments.
      Requires NVAIE licensing.
      +++
      :bdg-secondary:`gov-ready`


Platform
========

Select the guide for your Kubernetes distribution or cloud platform.

.. grid:: 1 1 2 2
   :gutter: 3

   .. grid-item-card:: :octicon:`server;1.5em;sd-mr-1` Upstream Kubernetes or Bare Metal
      :link: getting-started
      :link-type: doc

      Install with Helm on upstream Kubernetes, bare-metal hosts, or VMs with GPU passthrough. This is the default path
      for most self-managed clusters.
      +++
      :bdg-secondary:`Helm` :bdg-secondary:`default`

   .. grid-item-card:: :octicon:`cloud;1.5em;sd-mr-1` Amazon EKS
      :link: amazon-eks
      :link-type: doc

      Prepare Ubuntu node groups and choose between the default EKS GPU stack and Operator-managed drivers.
      +++
      :bdg-secondary:`EKS`

   .. grid-item-card:: :octicon:`cloud;1.5em;sd-mr-1` Azure AKS
      :link: microsoft-aks
      :link-type: doc

      Compare AKS GPU options and install the Operator with ``--skip-gpu-driver-install`` or pre-installed drivers.
      +++
      :bdg-secondary:`AKS`

   .. grid-item-card:: :octicon:`cloud;1.5em;sd-mr-1` Google GKE
      :link: google-gke
      :link-type: doc

      Choose between the Google driver installer plus the Operator, or full Operator driver management on Ubuntu nodes.
      +++
      :bdg-secondary:`GKE`

   .. grid-item-card:: :octicon:`package;1.5em;sd-mr-1` Red Hat OpenShift
      :link: https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/index.html
      :link-type: url

      Install through OperatorHub or ``oc`` using the OpenShift documentation book.
      +++
      :bdg-secondary:`OLM` :bdg-secondary:`OpenShift`

   .. grid-item-card:: :octicon:`checklist;1.5em;sd-mr-1` Partner Validated Platforms
      :link: https://docs.nvidia.com/datacenter/cloud-native/partner-validated/latest/index.html
      :link-type: url

      Validated configurations for partner Kubernetes distributions such as Mirantis MKE and SUSE RKE2.
      +++
      :bdg-secondary:`partner`

   .. grid-item-card:: :octicon:`globe;1.5em;sd-mr-1` Google Cloud Anthos
      :link: https://docs.nvidia.com/datacenter/cloud-native/edge/latest/anthos-guide.html
      :link-type: url

      Deploy on Anthos clusters on bare metal or VMware vSphere.
      +++
      :bdg-secondary:`Anthos`

.. _install-paths-network:

Specialized Network Environments
================================

These guides apply **in addition to** your primary install path when the cluster has network or mesh constraints.

.. grid:: 1 1 3 3
   :gutter: 3

   .. grid-item-card:: :octicon:`globe;1.5em;sd-mr-1` HTTP Proxy
      :link: install-gpu-operator-proxy
      :link-type: doc

      Configure the driver container to reach external endpoints through a proxy.
      +++
      :bdg-secondary:`proxy`

   .. grid-item-card:: :octicon:`lock;1.5em;sd-mr-1` Air-Gapped Network
      :link: install-gpu-operator-air-gapped
      :link-type: doc

      Mirror images and package repositories for disconnected clusters.
      +++
      :bdg-secondary:`air-gap`

   .. grid-item-card:: :octicon:`git-branch;1.5em;sd-mr-1` Service Mesh
      :link: install-gpu-operator-service-mesh
      :link-type: doc

      Disable sidecar injection on the ``gpu-operator`` namespace before installing.
      +++
      :bdg-secondary:`Istio` :bdg-secondary:`Linkerd`

----

Suggested Paths
===============

If you are new to the GPU Operator, follow one of these common sequences.

.. mermaid::

   flowchart LR
       subgraph bareMetal["Bare Metal / Generic K8s"]
           P1[Prerequisites] --> H1[Install with Helm]
       end

       subgraph cloud["Cloud Managed K8s"]
           P2[Prerequisites] --> C1[Platform Guide]
           C1 --> H2[Install with Helm]
       end

       subgraph ocp["OpenShift"]
           O1[OpenShift Book]
       end

       subgraph dra["DRA Greenfield"]
           P3[Prerequisites] --> D1[DRA Install Guide]
       end

       H1 --> V[Verify Installation]
       H2 --> V
       O1 --> V
       D1 --> V

**Common journeys:**

- **Bare metal or generic Kubernetes**: :doc:`prerequisites` → :doc:`Install with Helm <getting-started>` → verify
- **Amazon EKS, Azure AKS, or Google GKE**: :doc:`prerequisites` → platform guide → :doc:`Install with Helm
  <getting-started>` → verify
- **Red Hat OpenShift**: :external+ocp:doc:`index` (OperatorHub or ``oc`` install)
- **DRA-native cluster (Technology Preview)**: :doc:`prerequisites` → :doc:`Deploying the GPU Operator with DRA Support
  <gpu-operator-dra>` → verify

If your cluster uses a restricted network, add the matching guide from :ref:`install-paths-network` before or during
install.

----

Next Steps
==========

After you choose a path:

#. Review :doc:`prerequisites` for your platform, license, and GPU resource management model.
#. Follow the install guide for your chosen path.
#. Verify the installation using the steps in that guide.
#. Configure workloads (MIG, time-slicing, RDMA, and others) from the Advanced Operator Configuration section in the
   sidebar.
