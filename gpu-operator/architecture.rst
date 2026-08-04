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

.. _gpu-operator-control-plane-architecture:
.. _gpu-operator-architecture:

#######################################
GPU Operator Control Plane Architecture
#######################################

The NVIDIA GPU Operator is a Kubernetes controller that translates a cluster-level GPU policy into
the node-level software stack required to run GPU workloads.
This page is for platform engineers who need to understand the control plane, operand dependencies,
and the path from GPU discovery to workload allocation.

.. note::

   This page describes the device-plugin-based control path implemented on the GPU Operator
   ``main`` branch at the source baseline recorded at the end of this file.
   DRA-based resource allocation uses a different architecture and is outside this page's scope.

The GPU Operator manager watches custom resources and Nodes through the Kubernetes API.
It labels eligible nodes, creates or updates operand resources in a fixed order, and reports
reconciliation status.
Most operands run as DaemonSets on GPU nodes and are selected by labels that the Operator manages.

*******************
Operator Components
*******************

The GPU Operator manages a set of components that together provide the GPU software stack.
The following table lists the components, the category each belongs to, whether it is deployed by
default with the container workload configuration, and what it does.

.. list-table:: GPU Operator components
   :header-rows: 1
   :widths: 24 46

   * - Component
     - Description
   * - GPU Operator controller
     - Runs the reconcilers that watch the custom resources and Nodes and manage every operand.
   * - Node Feature Discovery (NFD)
     - Detects NVIDIA PCI devices and platform features and labels Nodes.
       Installed as a subchart unless NFD is already present in the cluster.
   * - NVIDIA driver
     - Installs the kernel modules and user-space driver libraries on GPU nodes.
       Can be disabled when the driver is preinstalled on the host.
   * - NVIDIA Container Toolkit
     - Configures the container runtime and Container Device Interface (CDI) so containers can
       access GPUs.
   * - NVIDIA Kubernetes Device Plugin
     - Registers ``nvidia.com/gpu`` and MIG extended resources with kubelet.
   * - MPS control daemon
     - Supports Multi-Process Service (MPS) GPU sharing; deployed with the device plugin.
   * - GPU Feature Discovery (GFD)
     - Publishes GPU model, memory, and MIG capabilities as Node labels.
   * - MIG Manager
     - Applies the requested Multi-Instance GPU (MIG) geometry on MIG-capable nodes.
   * - Operator Validator
     - Runs driver, toolkit, CUDA, and device-plugin checks and gates dependent operands through
       readiness files.
   * - DCGM
     - Standalone NVIDIA DCGM hostengine.
       When disabled, DCGM Exporter uses its embedded engine.
   * - DCGM Exporter
     - Exports GPU health and utilization metrics for Prometheus.
   * - Node Status Exporter
     - Reports node-level GPU Operator state.
   * - Sandbox Device Plugin
     - Advertises passthrough GPUs to kubelet on KubeVirt or Kata nodes.
   * - VFIO Manager
     - Binds GPUs to the ``vfio-pci`` driver for VFIO passthrough.
   * - vGPU Manager
     - Installs the NVIDIA vGPU host driver on vGPU nodes.
   * - vGPU Device Manager
     - Creates and manages vGPU devices on the node.
   * - Sandbox Validator
     - Validates the sandboxed and virtualized workload stack.
   * - Confidential Computing Manager
     - Sets confidential computing mode on GPUs for Kata Containers and Confidential Containers.

The remaining sections describe how these components are organized into layers, the order in which
they are reconciled, and the topologies in which they are deployed.

****************
Component Layers
****************

API and desired-state layer
===========================

The API layer stores the configuration that the Operator reconciles:

* ``ClusterPolicy`` is the primary, cluster-scoped API.
  It configures the driver, container toolkit, device plugin, telemetry, validation, and optional
  workload stacks.
  Only one ``ClusterPolicy`` is active in a cluster.
* ``GPUCluster`` is a cluster-scoped API for configuring the DRA Driver for NVIDIA GPUs.
  It configures the DRA Driver for NVIDIA GPUs, including the DRA Driver for NVIDIA GPUs DaemonSet.
  Only one ``GPUCluster`` is active in a cluster.
* ``NVIDIADriver`` is an optional, cluster-scoped API for assigning different driver configurations
  to different node pools.
  When this mode is enabled, the ``NVIDIADriver`` controller manages driver DaemonSets instead of
  the ``ClusterPolicy`` controller.
* Kubernetes ``Node`` objects carry discovery, placement, workload, and upgrade state as labels
  and annotations.

For the fields available in these APIs, refer to :ref:`clusterpolicy-reference`,
:ref:`gpucluster-reference`, and
:doc:`NVIDIA GPU Driver Custom Resource Definition <gpu-driver-configuration>`.

Control plane
=============

The Operator runs as a controller-runtime manager in the Operator namespace.
The manager starts four reconcilers:

* **ClusterPolicy reconciler** — renders and reconciles the operand resources that implement the
  active policy.
* **Node labeling reconciler** — converts hardware discovery and workload configuration into
  ``nvidia.com/gpu.present`` and ``nvidia.com/gpu.deploy.*`` placement labels.
* **NVIDIADriver reconciler** — manages driver DaemonSets and node ownership when the NVIDIA driver
  custom resource mode is enabled.
* **Upgrade reconciler** — coordinates driver rollout state and the handling of GPU workloads during
  an automatic driver upgrade.

The reconcilers use the Kubernetes API as the shared state store.
They watch custom resources, Nodes, and owned DaemonSets rather than communicating directly with
each other.

Discovery and placement layer
=============================

Node Feature Discovery (NFD) identifies NVIDIA PCI devices and publishes feature labels on Nodes.
The Node labeling reconciler uses those labels to set ``nvidia.com/gpu.present=true`` and the
per-operand deployment labels.

This separation has two effects:

* hardware discovery remains independent from operand lifecycle management; and
* each DaemonSet can use a narrow node selector such as
  ``nvidia.com/gpu.deploy.device-plugin=true``.

The user-controlled ``nvidia.com/gpu.workload.config`` label selects the effective workload stack
for a node.
The default stack supports container workloads.
Optional stacks support GPU passthrough, NVIDIA vGPU, and sandboxed workloads.

Node operand layer
==================

The default container workload path includes the following operands:

* **NVIDIA driver** — installs or exposes the kernel modules and user-space driver libraries.
  The driver can instead be preinstalled on the host.
* **NVIDIA Container Toolkit** — configures the container runtime and Container Device Interface
  (CDI) support.
* **Operator Validator** — checks driver, toolkit, CUDA, and device-plugin readiness.
  Other operands use its readiness files to avoid starting before their dependencies are usable.
* **NVIDIA Kubernetes Device Plugin** — registers GPU and MIG extended resources with kubelet.
* **GPU Feature Discovery (GFD)** — publishes GPU capabilities and topology as Node labels.
* **MIG Manager** — applies the requested Multi-Instance GPU configuration on supported nodes.
* **DCGM and DCGM Exporter** — provide GPU health data and Prometheus metrics.

Optional operands add node-status reporting, vGPU management, VFIO management, device plugins for
sandboxed workloads, and confidential-computing support.

****************************
Desired-State Reconciliation
****************************

The ``ClusterPolicy`` reconciler processes operand states in a fixed sequence.
The important dependency order is:

#. prerequisites and Operator metrics;
#. driver;
#. container toolkit;
#. validation;
#. device plugin and MPS control daemon;
#. DCGM and DCGM Exporter;
#. GFD;
#. MIG Manager and node-status exporter; and
#. optional vGPU, VFIO, sandbox, and confidential-computing operands.

For each state, the Operator loads the embedded manifests, applies policy-specific transformations,
and creates or updates Kubernetes objects.
Objects within a state are processed in a stable order so that service accounts and RBAC exist
before the workloads that use them.

An operand state can be disabled by policy or skipped when another component owns that function.
For example, the ``ClusterPolicy`` driver state is skipped when ``NVIDIADriver`` custom resources
manage the driver.

The Operator records the aggregate result in ``ClusterPolicy.status``.
If an operand is not ready, reconciliation is retried.
A missing NFD label set or a cluster with no GPU nodes is reported as a condition rather than
treated as a terminal controller failure.

***********************
GPU Workload Data Flow
***********************

For the default device-plugin model, a GPU request follows this path:

#. NFD detects NVIDIA hardware and labels the Node.
#. The Node labeling reconciler adds the Operator's GPU and operand placement labels.
#. The driver DaemonSet makes the GPU available to the host operating system.
#. The Container Toolkit configures the container runtime and CDI integration.
#. The validator records that the required host components are ready.
#. The NVIDIA Kubernetes Device Plugin registers resources such as ``nvidia.com/gpu`` with kubelet.
#. A workload requests an NVIDIA extended resource in its Pod specification.
#. The Kubernetes scheduler selects a Node with available GPU capacity.
#. Kubelet calls the device plugin to allocate the device, and the runtime or CDI injects the
   required device nodes and configuration into the container.

MIG changes the resources advertised by the device plugin, but it does not change this
control-plane flow.
For MIG configuration concepts, refer to :ref:`install-gpu-operator-mig`.

*********************
Deployment Topologies
*********************

The Operator supports several deployment topologies that combine the components in different ways.
The following table compares them.
The sections that follow describe each topology in more detail.

.. list-table:: Deployment topology comparison
   :header-rows: 1
   :widths: 26 30 44

   * - Topology
     - Driver management
     - Operands and typical use
   * - Operator-managed stack (default)
     - ``ClusterPolicy`` manages the driver.
     - Deploys the full container operand set on NFD-discovered nodes.
       Use when the Operator should own the complete GPU software lifecycle.
   * - Preinstalled host components
     - Driver, toolkit, or both installed outside the Operator; the matching state is disabled.
     - The Operator still manages the device plugin, validation, telemetry, and other enabled
       operands.
       Use when the platform or node image already provides host software.
   * - Multiple driver pools
     - ``NVIDIADriver`` custom resources, one per node pool, selected by node selector.
     - The Operator creates driver DaemonSets per operating system and, for precompiled drivers,
       per kernel version.
       Use when node pools require different driver types or versions.
   * - Sandboxed and virtualized workloads
     - Data-center driver or vGPU host driver, depending on the workload configuration.
     - Replaces the container operands with passthrough, vGPU, Kata, or confidential-computing
       operands.
       Use for virtual machine or sandboxed GPU workloads.

Operator-managed stack
======================

This is the default topology.
``ClusterPolicy`` manages the driver and the remaining operands on nodes discovered by NFD.
Use this topology when the Operator should own the complete GPU software lifecycle.

Preinstalled host components
============================

The driver, the Container Toolkit, or both can be installed outside the Operator.
The corresponding policy state is disabled, while the Operator continues to manage the
device plugin, validation, telemetry, and other enabled operands.
Use this topology when the platform or image lifecycle already owns host software.

Multiple driver pools
=====================

The NVIDIA driver custom resource mode assigns each GPU node to an ``NVIDIADriver`` resource by
node selector.
The controller creates the driver DaemonSets needed for the matching operating system and, for
precompiled drivers, kernel versions.
Use this topology when node pools require different driver types or versions.

Sandboxed and virtualized workloads
===================================

Optional policy settings replace or extend the default container workload labels with operands for
GPU passthrough, NVIDIA vGPU, Kata Containers, or confidential containers.
These operands remain under the same reconciliation and node-labeling control plane, but require
additional runtime and platform integration.

******************
Integration Points
******************

Node Feature Discovery
======================

NFD is the hardware-discovery input to the architecture.
Without the NVIDIA PCI labels that NFD publishes, the Operator cannot classify GPU nodes or place
the node-level operands.

Container runtimes
==================

The Container Toolkit integrates with containerd, CRI-O, or Docker.
CDI is enabled by default and provides a runtime-independent device injection path.
RuntimeClass and NVIDIA Runtime Injection (NRI) options support alternate runtime configurations.

Prometheus
==========

DCGM Exporter exposes GPU telemetry.
When the Prometheus Operator integration is enabled, the GPU Operator creates the corresponding
ServiceMonitor and PrometheusRule resources.
The Operator also publishes reconciliation, GPU-node, and driver-upgrade metrics.

OpenShift
=========

On Red Hat OpenShift, the Operator detects platform APIs and can integrate with Security Context
Constraints, the Driver Toolkit, cluster proxy settings, and user-workload monitoring.

**************************
Operational Considerations
**************************

Observability
=============

Use the following signals together:

* ``ClusterPolicy.status`` and ``NVIDIADriver.status`` report reconciliation state and conditions.
* Controller logs identify the operand state and Kubernetes object that failed to reconcile.
* Operator metrics report reconciliation status, GPU-node counts, and upgrade activity.
* DCGM Exporter reports GPU health and utilization.
* The optional node-status exporter reports node-level GPU state.

Resilience and upgrades
=======================

Reconciliation is idempotent: the Operator continuously compares desired and observed state and
retries resources that are not ready.
Optional leader election prevents multiple Operator replicas from acting as the active controller.

The upgrade reconciler coordinates automatic driver rollout through node upgrade-state labels.
It can drain GPU workloads before a driver pod is replaced and returns the node to service after
validation.
For configuration and limitations, refer to :ref:`gpu-driver-upgrades`.

Security boundary
=================

Several node-level operands require privileged containers, host PID or IPC access, host-path
mounts, and permission to load kernel modules or restart the container runtime.
Restrict access to the Operator namespace and its custom resources to cluster administrators.
For details, refer to :doc:`Security Considerations <security>`.

*******
Related
*******

* :ref:`operator-install-guide`
* :ref:`clusterpolicy-reference`
* :ref:`gpu-driver-upgrades`
* :ref:`install-gpu-operator-mig`
* :doc:`Troubleshooting the NVIDIA GPU Operator <troubleshooting>`

.. Source baseline: NVIDIA/gpu-operator origin/main at
   57752060b8cd83ffa4a54a58b2de093e48f8bb5e (2026-07-20).
