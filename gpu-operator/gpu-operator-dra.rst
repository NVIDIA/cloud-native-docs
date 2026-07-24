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

.. _gpu-operator-dra:

###########################################
Deploying the GPU Operator with DRA Support
###########################################

Dynamic Resource Allocation (DRA) is a Kubernetes API for flexibly requesting, configuring, and sharing specialized
devices such as GPUs.
Starting with GPU Operator ${version}, the GPU Operator can deploy and manage the `DRA Driver for NVIDIA GPUs
<https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/>`__ (v${dra_version}) directly, as a native operand, through the
``GPUCluster`` custom resource.

This page describes the architecture of the DRA-based software stack, how to install the GPU Operator with DRA
support enabled, and the current limitations of the integration.

.. note::

   Deploying and managing the DRA Driver for NVIDIA GPUs through the ``GPUCluster`` custom resource is in Technology
   Preview.
   The ``GPUCluster`` API is served under ``nvidia.com/v1alpha1`` and is subject to change in future releases.
   Only greenfield (new) deployments are supported.
   Migrating an existing ``ClusterPolicy`` deployment to ``GPUCluster`` in place is not supported.

   If you want to install the fully-supported DRA Driver for NVIDIA GPUs as a standalone Helm chart alongside the GPU
   Operator instead of having the Operator manage it, refer to
   :doc:`DRA Driver for NVIDIA GPUs <dra-intro-install>`.

Before you begin, it is recommended that you are familiar with the following:

* `Upstream Kubernetes DRA documentation <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/>`_.
* `DRA Driver for NVIDIA GPUs documentation <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/>`__.

********
Overview
********

The GPU Operator supports two GPU resource management models.
The ``ClusterPolicy`` custom resource configures the device-plugin model and deploys the NVIDIA Kubernetes Device
Plugin along with the other operands needed to manage GPU resources.

For a greenfield DRA deployment, the cluster-scoped ``GPUCluster`` custom resource configures the operands needed to
use the DRA Driver for NVIDIA GPUs to allocate GPUs.
Use one GPU resource management model in a cluster; deploying both ``ClusterPolicy`` and ``GPUCluster`` as active
models is not supported.

With the DRA Driver for NVIDIA GPUs, your Kubernetes workloads can allocate and consume two types of resources:

* GPU allocation for controlled sharing and dynamic reconfiguration of GPUs.
  This replaces the traditional GPU allocation method that is provided by the NVIDIA Kubernetes Device Plugin.
* ComputeDomains, an abstraction for secure `Multi-Node NVLink (MNNVL)
  <https://docs.nvidia.com/multi-node-nvlink-systems/index.html>`_ on NVIDIA GB200 and similar systems.

You can use these features independently or together in the same cluster.

Unlike ``ClusterPolicy``, the ``GPUCluster`` resource does not manage the NVIDIA GPU driver or a device plugin.
The GPU driver must be either pre-installed on the host or managed by an ``NVIDIADriver`` custom resource, and GPUs are
surfaced to workloads through DRA.

The following table summarizes the differences between the two stacks.

.. list-table::
   :header-rows: 1
   :widths: 34 33 33

   * - Component
     - Device-plugin model (``ClusterPolicy``)
     - DRA model (``GPUCluster``)
   * - GPU allocation mechanism
     - NVIDIA Kubernetes Device Plugin (extended resources)
     - DRA Driver for NVIDIA GPUs (ResourceClaims)
   * - NVIDIA GPU driver
     - Managed by ``ClusterPolicy`` or ``NVIDIADriver``
     - Pre-installed or managed by ``NVIDIADriver`` (not managed by ``GPUCluster``)
   * - NVIDIA Container Toolkit
     - Deployed
     - Not deployed (workloads use CDI through DRA)
   * - GPU Feature Discovery (GFD)
     - Deployed
     - Not deployed by ``GPUCluster``
   * - DCGM and DCGM Exporter
     - Deployed
     - Deployed
   * - MIG Manager
     - Deployed
     - Not deployed
   * - Validation
     - ``nvidia-operator-validator``
     - ``nvidia-dra-validator`` (validates through a DRA ResourceClaim)

************
Architecture
************

The DRA model
=============

The DRA model is configured through the ``GPUCluster`` custom resource.
When you install the GPU Operator with DRA support enabled, the Helm chart creates a default ``GPUCluster`` resource
named ``gpu-cluster``, which the GPU Operator watches and reconciles into the following operands:

* **DRA Driver for NVIDIA GPUs** — a kubelet-plugin DaemonSet and, when ComputeDomains are enabled, a controller
  Deployment.
* **DCGM Exporter** — enabled by default, for GPU telemetry.
* **DCGM** — the standalone NVIDIA DCGM hostengine, disabled by default (DCGM Exporter uses its embedded
  ``nv-hostengine`` when standalone DCGM is disabled).
* **DRA validator** — validates that the DRA driver can allocate a GPU on each node.

``GPUCluster`` is a singleton, cluster-scoped resource in the ``nvidia.com/v1alpha1`` API group.
For the full list of ``GPUCluster`` fields, its singleton behavior, and status values, refer to the
:doc:`GPUCluster Custom Resource Reference <gpucluster-reference>`.

How the DRA driver works
========================

The DRA Driver for NVIDIA GPUs runs as a kubelet-plugin DaemonSet on each GPU node.
The kubelet-plugin pod is composed of the following:

* An ``dra-driver-validator`` init container that confirms an NVIDIA GPU driver is installed and ready before the
  driver starts.
  The validator probes for a driver that is pre-installed on the host and, if none is found, for a
  driver installed by the GPU Operator, and it writes the resulting driver root paths to a file that the
  kubelet-plugin containers read on startup.
* A ``gpus`` container (always deployed) that advertises GPU devices for allocation.
* A ``compute-domains`` container (deployed when ComputeDomains are enabled) that advertises ComputeDomain devices.

When the driver is running, it publishes the GPUs on each node as ``ResourceSlice`` objects and registers a set of
``DeviceClass`` objects that workloads reference in their claims:

.. list-table::
   :header-rows: 1
   :widths: 45 55

   * - DeviceClass
     - Purpose
   * - ``gpu.nvidia.com``
     - Full GPU allocation.
   * - ``mig.nvidia.com``
     - Multi-Instance GPU (MIG) device allocation.
   * - ``vfio.gpu.nvidia.com``
     - GPUs bound to ``vfio-pci`` for passthrough (for example, to virtual machines).
   * - ``compute-domain-daemon.nvidia.com``
     - ComputeDomain daemon devices (created when ComputeDomains are enabled).
   * - ``compute-domain-default-channel.nvidia.com``
     - ComputeDomain channel devices (created when ComputeDomains are enabled).

Claiming GPUs for workloads
===========================

With DRA, a workload requests a GPU by referencing a ``ResourceClaim`` or ``ResourceClaimTemplate`` that targets one
of the NVIDIA ``DeviceClass`` objects, rather than requesting an extended resource such as ``nvidia.com/gpu``.

The following example allocates a single full GPU to a pod:

.. code-block:: yaml

   apiVersion: resource.k8s.io/v1
   kind: ResourceClaimTemplate
   metadata:
     name: single-gpu
   spec:
     spec:
       devices:
         requests:
         - name: gpu
           exactly:
             deviceClassName: gpu.nvidia.com
             allocationMode: ExactCount
             count: 1
   ---
   apiVersion: v1
   kind: Pod
   metadata:
     name: gpu-workload
   spec:
     restartPolicy: Never
     resourceClaims:
     - name: gpu
       resourceClaimTemplateName: single-gpu
     containers:
     - name: workload
       image: nvcr.io/nvidia/cuda:12.6.2-base-ubi9
       command: ["nvidia-smi", "-L"]
       resources:
         claims:
         - name: gpu

For GPU resource management, DRA enables scenarios that are difficult to express with extended resources, including:

* Requesting GPUs with specific attributes (for example, a model, memory capacity, or a MIG profile) through CEL
  selectors in the claim.
* Controlled sharing of a single GPU across multiple containers or pods.
* Allocating MIG devices dynamically through the ``mig.nvidia.com`` DeviceClass.

.. note::

   To keep existing workloads that request GPUs through the extended resource API (for example, ``nvidia.com/gpu: 1``)
   working while the DRA driver is used, enable the `DRAExtendedResource
   <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/#extended-resource>`_ feature
   gate. This feature gate is enabled by default in Kubernetes v1.36 and later.

For detailed workload examples, including MIG and ComputeDomain workloads, refer to the `DRA Driver for NVIDIA GPUs
documentation <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/>`__.

Management access to GPUs
=========================

Operands such as DCGM Exporter and the DRA validator need administrative access to GPUs.
Instead of relying on the ``nvidia`` runtime class, these operands request access through a DRA ``ResourceClaim`` that
sets ``adminAccess: true``.
Administrative access requires the GPU Operator namespace to carry the ``resource.kubernetes.io/admin-access: "true"``
label; the GPU Operator applies this label automatically during reconciliation.

.. note::

   The ``adminAccess`` field is gated by the ``DRAAdminAccess`` feature gate, which is beta and enabled by default
   starting in Kubernetes v1.34.

****************************
Limitations and Restrictions
****************************

Before you enable DRA support, review the following limitations.

* **Technology preview.** The DRA Driver for NVIDIA GPUs itself is fully supported; deploying and managing it through
  the ``GPUCluster`` resource is a technology preview feature. The ``nvidia.com/v1alpha1`` API is subject to change.
* **New installations only.** Only greenfield (new) installations are supported. There is no supported procedure for
  migrating an existing device-plugin (``ClusterPolicy``) installation to the DRA model in place.
* **Kubernetes version.** DRA must be served by the cluster. Kubernetes v1.34.2 or later is required. If the
  ``resource.k8s.io`` DeviceClass API is not served, the Helm install fails with a validation error.
* **Driver management.** ``GPUCluster`` does not manage the GPU driver or a device plugin. The driver must be
  pre-installed on the host or managed by an ``NVIDIADriver`` custom resource.
* **Driver auto-upgrade.** Automatic driver upgrades are not yet supported for DRA nodes. When drivers are managed by
  an ``NVIDIADriver`` resource that serves DRA nodes, disable automatic upgrades by setting
  ``spec.driver.upgradePolicy.autoUpgrade: false``.
* **GPU Feature Discovery.** GFD is not deployed by ``GPUCluster``.
* **ComputeDomains hardware.** ComputeDomains require NVIDIA Grace Blackwell systems with Multi-Node NVLink, such as
  NVIDIA HGX GB200 NVL72 or NVIDIA HGX GB300 NVL72.


.. _dra-deployment-scenarios:

****************
Deployment Model
****************

The ``GPUCluster`` resource supports a dedicated, greenfield DRA deployment.
Every GPU node is served by the DRA model.
Do not use ``ClusterPolicy`` and ``GPUCluster`` as GPU resource management models in the same cluster.
In-place migration from an existing device-plugin deployment is not supported.

Install with ``gpuCluster.enabled=true`` and set ``DEFAULT_GPU_ALLOCATION_MODE`` to ``dra``.
Setting ``DEFAULT_GPU_ALLOCATION_MODE`` to ``dra`` ensures that every GPU node is labeled for, and served by, the DRA
model.

Refer to :ref:`Install <dra-install>` for the commands.

Operator-managed or pre-installed driver
=========================================

The ``GPUCluster`` resource does not manage the NVIDIA GPU driver, so you choose how the driver is provided on your
GPU nodes:

* **Operator-managed driver** — the GPU Operator installs and manages the driver through the ``NVIDIADriver`` custom
  resource (``driver.nvidiaDriverCRD.enabled=true``).
* **Pre-installed driver** — the NVIDIA GPU driver is already installed on each GPU node
  (``driver.enabled=false``).

Both options are shown as tabs in :ref:`Install <dra-install>`.

.. _dra-install:

*******
Install
*******

This section covers a fresh install of the GPU Operator with DRA support enabled.

#. Add the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
          && helm repo update

#. Install the GPU Operator with the ``GPUCluster`` resource enabled and ``DEFAULT_GPU_ALLOCATION_MODE`` set to ``dra``
   so that GPU nodes are served by the DRA model.

   Select the tab that matches how the GPU driver is managed on your cluster.

   .. tab-set::

      .. tab-item:: Operator-managed driver

         Use this option to let the GPU Operator install and manage the driver through the ``NVIDIADriver`` custom
         resource.

         .. code-block:: console

            $ helm upgrade --install gpu-operator nvidia/gpu-operator \
                --version=${version} \
                --create-namespace \
                --namespace gpu-operator \
                --set gpuCluster.enabled=true \
                --set driver.nvidiaDriverCRD.enabled=true \
                --set operator.env[0].name=DEFAULT_GPU_ALLOCATION_MODE \
                --set operator.env[0].value=dra

      .. tab-item:: Pre-installed driver

         Use this option when the NVIDIA GPU driver is already installed on each GPU node.

         .. code-block:: console

            $ helm upgrade --install gpu-operator nvidia/gpu-operator \
                --version=${version} \
                --create-namespace \
                --namespace gpu-operator \
                --set gpuCluster.enabled=true \
                --set driver.enabled=false \
                --set operator.env[0].name=DEFAULT_GPU_ALLOCATION_MODE \
                --set operator.env[0].value=dra

   The ``gpuCluster.enabled=true`` flag creates the default ``GPUCluster`` resource and enables the DRA model.
   Setting ``DEFAULT_GPU_ALLOCATION_MODE`` to ``dra`` ensures that GPU nodes are labeled for, and served by, the DRA
   model.

   To customize the DRA driver or the other operands, refer to
   :ref:`Helm Configuration Reference <dra-helm-reference>`.

*********************
Validate Installation
*********************

#. Confirm that the ``GPUCluster`` resource reports a ``ready`` state:

   .. code-block:: console

      $ kubectl get gpucluster

   *Example Output*

   .. code-block:: output

      NAME          STATUS   AGE
      gpu-cluster   ready    3m12s

#. Confirm that the DRA model operands are running:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator

   *Example Output*

   .. code-block:: output

      NAME                                             READY   STATUS      RESTARTS   AGE
      gpu-operator-...                                 1/1     Running     0          4m
      nvidia-dra-driver-controller-...                 1/1     Running     0          3m
      nvidia-dra-driver-kubelet-plugin-...             2/2     Running     0          3m
      nvidia-dra-validator-...                         1/1     Running     0          2m
      nvidia-dcgm-exporter-...                         1/1     Running     0          2m

   The kubelet-plugin pod runs two containers when both GPU allocation and ComputeDomains are enabled — one for GPU
   resources (``gpus``) and one for ComputeDomain resources (``compute-domains``) — so it shows ``2/2``.
   If ComputeDomains are disabled, the kubelet-plugin pod shows ``1/1`` and the ``nvidia-dra-driver-controller``
   Deployment is not present.
   The ``nvidia-dra-validator`` pod becomes ready only after the DRA driver successfully allocates a GPU on the node.

#. Verify that the NVIDIA DeviceClasses are available:

   .. code-block:: console

      $ kubectl get deviceclass

   *Example Output*

   .. code-block:: output

      NAME                                        AGE
      compute-domain-daemon.nvidia.com            3m
      compute-domain-default-channel.nvidia.com   3m
      gpu.nvidia.com                              3m
      mig.nvidia.com                              3m
      vfio.gpu.nvidia.com                         3m

#. Verify that the driver publishes GPUs as ``ResourceSlice`` objects:

   .. code-block:: console

      $ kubectl get resourceslices

   Each GPU node should have one or more ``ResourceSlice`` objects that describe its GPUs.

.. _dra-helm-reference:

****************************
Helm Configuration Reference
****************************

The following Helm values enable and configure the DRA integration.
The ``gpuCluster.*`` values populate the default ``GPUCluster`` resource that the chart creates; each maps to a field
documented in the :doc:`GPUCluster Custom Resource Reference <gpucluster-reference>`.

.. list-table::
   :header-rows: 1
   :widths: 40 15 45

   * - Helm value
     - Default
     - Description
   * - ``gpuCluster.enabled``
     - ``false``
     - Enables DRA support by creating the default ``GPUCluster`` resource.
   * - ``operator.env[*]`` (``DEFAULT_GPU_ALLOCATION_MODE``)
     - unset
     - Set to ``dra`` for a ``GPUCluster`` deployment so newly-added GPU nodes use the DRA model.
   * - ``gpuCluster.draDriver.*``
     - See reference
     - Configures the DRA driver image and its GPU allocation (``gpus``) and ComputeDomains capabilities. Populates
       ``spec.draDriver`` of the ``GPUCluster`` resource.

The DRA model also reuses the following top-level Helm values, which are shared with the device-plugin model and are
applied to the operands that ``GPUCluster`` deploys. These populate the corresponding sections of the ``GPUCluster``
resource.

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Helm value
     - Description
   * - ``dcgmExporter.*``
     - Configuration for DCGM Exporter (enabled by default).
   * - ``dcgm.*``
     - Configuration for the standalone DCGM hostengine (disabled by default).
   * - ``hostPaths.*``
     - Host paths for the root filesystem, driver install directory, and kubelet root directory.
   * - ``daemonsets.*``
     - Common labels, annotations, priority class, tolerations, and update strategy for the deployed workloads.

For the full set of configurable ``GPUCluster`` fields, refer to the
:doc:`GPUCluster Custom Resource Reference <gpucluster-reference>`.

************************
Additional Documentation
************************

For more information about the DRA Driver for NVIDIA GPUs, refer to the following resources:

* :doc:`DRA Driver for NVIDIA GPUs <dra-intro-install>` — installing the DRA driver as a standalone Helm chart.
* `DRA Driver for NVIDIA GPUs documentation <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/>`__
* `Upstream Kubernetes DRA documentation <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/>`_
