.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
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

##########################
DRA Driver for NVIDIA GPUs
##########################

Dynamic Resource Allocation (DRA) is a Kubernetes API for flexibly requesting, configuring, and sharing specialized devices such as GPUs.
For example, workloads can request GPUs by attributes, such as model, memory, and compute capability.
Workloads use resource claims to request GPUs and share allocated devices across containers or pods.

By default, the Operator does not install the DRA Driver.
Refer to :ref:`Install the DRA Driver <dra-driver-install>` for the commands.

Before using the DRA Driver for NVIDIA GPUs, familiarize yourself with the following documentation:

* `Dynamic Resource Allocation <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/>`_ in the Kubernetes documentation.
* `DRA Driver for NVIDIA GPUs documentation <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/>`__.

*********************************
Comparison: DRA and Device Plugin
*********************************

The GPU Operator supports the DRA Driver as a more recent alternative to the NVIDIA Kubernetes Device Plugin.
However, some features of the DRA Driver have alpha support status.

A cluster can have either a ``GPUCluster`` resource for DRA or a ``ClusterPolicy`` resource for the Device Plugin, but not both.

Capability Comparison
=====================

The following table compares the GPU allocation capabilities of the two mechanisms when managed by the GPU Operator:

.. list-table:: GPU Allocation Capability Comparison
   :header-rows: 1
   :widths: 23 38 39

   * - Capability
     - DRA with a ``GPUCluster`` resource
     - Device Plugin with a ``ClusterPolicy`` resource

   * - API and Device Selection
     - Uses DRA API to select GPUs by attributes---model, architecture, memory, compute capability, UUID, addressing mode, PCI/topology information---using CEL expressions.

       With Kubernetes v1.36, the driver also supports the extended resource names for backward compatibility.
     - Uses Kubernetes extended resource names and counts.
       Node labeling or other external mechanisms required for structured selection.

   * - Full GPU and MIG Device Allocation
     - Allocates full GPU devices and preconfigured MIG devices.
       Alpha ``DynamicMIG`` creates MIG devices for a claim.
     - Allocates full GPU devices or preconfigured MIG devices.
       MIG Manager configures MIG geometry before allocation.

   * - GPU Sharing
     - Alpha ``ConsumableShares`` feature gate implements Kubernetes consumable capacity for scheduler-accounted sharing among independent resource claims for full GPUs and MIG devices.
       The driver also supports time-slicing through a shared DRA claim.
       Custom time-slice intervals require the Alpha ``TimeSlicingSettings`` feature gate.
       MPS requires the Alpha ``MPSSupport`` gate.
     - Advertises time-slicing replicas and experimental MPS replicas for all GPUs on a node.

   * - Multi-Node NVLink
     - Provides the ComputeDomain API and controller for coordinated workloads.
     - Does not provide the ComputeDomain API.

   * - Device Health Reporting
     - Alpha ``NVMLDeviceHealthCheck`` is disabled by default.
       gRPC health probes report kubelet plugin availability only.
     - Reports unhealthy devices through the Kubernetes Device Plugin API.

   * - Device Injection
     - Requires a Container Device Interface (CDI)-compatible runtime.
     - Supports multiple device injection strategies.

   * - Components Managed by the Operator
     - With a ``GPUCluster`` resource, the Operator manages:

       * DRA Driver kubelet plugin
       * ComputeDomain controller and kubelet plugin, when enabled
       * DRA validator
       * DCGM Exporter, when enabled
       * Standalone NVIDIA Data Center GPU Manager (DCGM), when enabled

     - With a ``ClusterPolicy`` resource, the Operator manages:

       * NVIDIA Container Toolkit
       * GPU Feature Discovery
       * MIG Manager
       * Sandbox device plugin
       * Kata Containers
       * KubeVirt
       * NVIDIA vGPU Manager

   * - Kubernetes Scheduling
     - Allocation through a resource claim, which can be referenced by multiple containers or pods.
     - Allocation through the resource limits specified for the container.

DRA Driver Feature Maturity
===========================

The following table groups the DRA Driver capabilities by maturity:

.. list-table:: DRA Driver Capability Maturity
   :header-rows: 1
   :widths: 34 22 18 26

   * - Capability
     - Support Status
     - Default
     - Operator Control

   * - ComputeDomains
     - Generally Available
     - Enabled
     - ``draDriver.computeDomains.enabled``

   * - Full GPU and existing MIG device allocation
     - Generally Available
     - Enabled
     - Always enabled

   * - ``ComputeDomainCliques``, ``CrashOnNVLinkFabricErrors``, ``IMEXDaemonsWithDNSNames``
     - Generally Available
     - Enabled
     - ``draDriver.featureGates``

   * - ``ConsumableShares``, ``DeviceMetadata``, ``DynamicMIG``, ``MPSSupport``, ``NVMLDeviceHealthCheck``, ``PassthroughSupport``, ``TimeSlicingSettings``
     - Alpha
     - Disabled
     - ``draDriver.featureGates``

Refer to the `DRA Driver v${dra_version} overview <https://github.com/kubernetes-sigs/dra-driver-nvidia-gpu/blob/v${dra_version}/README.md#overview>`__
and `feature-gate definitions <https://github.com/kubernetes-sigs/dra-driver-nvidia-gpu/blob/v${dra_version}/pkg/featuregates/featuregates.go>`__
for the authoritative support status, maturity, and default values.

DRA Driver Limitations
======================

Consider the following limitations before selecting DRA Driver v${dra_version}:

* ``NVMLDeviceHealthCheck`` is alpha and disabled by default.
  The gRPC health probe reports kubelet plugin availability, and DCGM provides telemetry.
  Neither provides DRA allocation health status.
* Consumable capacity is available through the alpha ``ConsumableShares`` feature gate, which is disabled by default.
  When enabled, the feature provides scheduler-accounted capacity sharing among independent resource claims for full GPUs and MIG devices.
  Kubernetes v1.34 and v1.35 require enabling the ``DRAConsumableCapacity`` feature gate.
  Kubernetes v1.36 and later enable the feature by default.
  You must also set the ``CONSUMABLE_SHARES`` environment variable for the DRA Driver kubelet plugin to ``memory``, ``unlimited``, or a positive integer.
  Set the environment variable through ``draDriver.gpus.kubeletPlugin.env``.
  MPS cannot be used when consumable capacity is configured through ``ConsumableShares``.
* Alpha feature gates have compatibility constraints.
  ``DynamicMIG`` conflicts with ``PassthroughSupport``, ``NVMLDeviceHealthCheck``, and ``MPSSupport``.
  ``PassthroughSupport`` conflicts with ``NVMLDeviceHealthCheck``, and ``DeviceMetadata`` requires ``PassthroughSupport``.
* Kubernetes does not support preemption for DRA resources.
  Injecting DRA-allocated devices requires a preconfigured CDI-compatible container runtime.
  The managed ``gpu.nvidia.com`` device class does not set ``spec.extendedResourceName`` to ``nvidia.com/gpu``.

************************
Installation Limitations
************************

* Use this workflow for a new installation.
  An in-place migration from a standalone DRA Driver Helm release or from a ``ClusterPolicy`` resource to a ``GPUCluster`` resource is not supported.
* The ``GPUCluster`` resource does not expose the controller affinity, priority class, toleration,
  and kubelet-plugin node selector overrides that were used by the previous standalone DRA Driver procedure for Google Kubernetes Engine (GKE).
  This page does not provide a managed DRA installation procedure for GKE.

.. _dra-driver-install:

*******
Install
*******

Prerequisites
=============

In addition to ensuring that your GPUs and cluster align with the :ref:`GPU Operator support matrix <operator-platform-support>`, verify the following prerequisites:

* Kubernetes v1.34.2 or later with the ``DeviceClass`` resource available in the ``resource.k8s.io`` API group.
* NVIDIA GPU driver version 580 or later.
  The Operator can install the driver or you can use a pre-installed driver.
* A container runtime that supports CDI and is configured to use CDI for injecting DRA-allocated devices.
* No ``ClusterPolicy`` resource exists in the cluster.

  .. code-block:: console

     $ kubectl get clusterpolicy

  If a ``ClusterPolicy`` resource exists, use a new cluster for the DRA workflow.

.. note::

   To use an extended-resource request with the DRA Driver, enable the
   `DRAExtendedResource <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/#extended-resource>`_ feature gate.
   This feature gate is enabled by default in Kubernetes v1.36.0 and later.
   Request ``deviceclass.resource.kubernetes.io/gpu.nvidia.com`` to use the managed ``gpu.nvidia.com`` device class.
   The legacy name ``nvidia.com/gpu`` requires a separate device class that sets ``spec.extendedResourceName`` to that value.

.. _computedomain-prereqs:

For ComputeDomain support, verify the following additional prerequisites:

* NVIDIA Grace Blackwell GPUs with Multi-Node NVLink available on your cluster,
  such as NVIDIA HGX GB200 NVL72 or NVIDIA HGX GB300 NVL72.
  Refer to the `NVIDIA Multi-Node NVLink Systems documentation <https://docs.nvidia.com/multi-node-nvlink-systems/index.html>`_ for more information.
* If you use a pre-installed NVIDIA GPU driver:

  * Install the corresponding ``nvidia-imex-*`` packages through the Linux distribution package manager.
  * Disable and mask the IMEX systemd service on every GPU node before installing the GPU Operator:

    .. code-block:: console

       $ systemctl disable --now nvidia-imex.service
       $ systemctl mask nvidia-imex.service

Procedure
=========

The following procedures install the GPU Operator with the DRA Driver.
The GPU Operator runs the DRA Driver in the GPU Operator namespace.
The Helm chart creates the cluster-scoped ``GPUCluster`` resource that the Operator uses to manage DRA components.
A cluster supports only one ``GPUCluster`` resource, which must be named ``gpu-cluster``.
The ``GPUCluster`` resource does not manage the NVIDIA GPU driver.
Use an ``NVIDIADriver`` resource to install a containerized GPU driver or use a driver that is pre-installed on the host.

The Helm commands set the following values:

* ``gpuCluster.deployCR=true`` enables the GPU Operator to install and manage the DRA Driver.
* ``clusterPolicy.deployCR=false`` prevents creation of the ``ClusterPolicy`` resource.
  The chart fails if you set both ``gpuCluster.deployCR`` and ``clusterPolicy.deployCR`` to ``true``.
* ``driver.nvidiaDriverCRD.enabled=true`` enables the GPU Operator to install the NVIDIA GPU driver through an ``NVIDIADriver`` resource.
  This value controls the NVIDIA GPU driver, not the DRA Driver.
  The Operator-Managed Driver procedure requires this value.
* ``driver.enabled=false`` uses the NVIDIA GPU driver that is pre-installed on the host.
  The Pre-Installed Driver procedure uses this value.

#. Add the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
          && helm repo update

#. Install the GPU Operator by using the procedure for your driver configuration.

   .. tab-set::
      :sync-group: dra-driver-install

      .. tab-item:: Operator-Managed Driver
         :sync: managed

         .. code-block:: console

            $ helm upgrade --install gpu-operator nvidia/gpu-operator \
                --version=${version} \
                --namespace gpu-operator \
                --create-namespace \
                --set clusterPolicy.deployCR=false \
                --set gpuCluster.deployCR=true \
                --set driver.nvidiaDriverCRD.enabled=true

         The chart creates the default ``NVIDIADriver`` resource to manage the NVIDIA GPU driver, not the DRA Driver.

      .. tab-item:: Pre-Installed Driver
         :sync: preinstalled

         .. code-block:: console

            $ helm upgrade --install gpu-operator nvidia/gpu-operator \
                --version=${version} \
                --namespace gpu-operator \
                --create-namespace \
                --set clusterPolicy.deployCR=false \
                --set gpuCluster.deployCR=true \
                --set driver.enabled=false

By default, the Operator enables both GPU allocation and ComputeDomain support.
To install GPU allocation without ComputeDomain support, add the following option to the Helm command:

.. code-block:: console

   --set draDriver.computeDomains.enabled=false

Do not install a separate ``dra-driver-nvidia-gpu`` Helm release for this managed workflow.

************************
Configure DRA Components
************************

The GPU Operator Helm values render the specification of the ``gpu-cluster`` resource.
The following settings provide the primary configuration surface:

.. list-table::
   :header-rows: 1
   :widths: 38 62

   * - Helm value
     - Description

   * - ``draDriver.repository``, ``draDriver.image``, and ``draDriver.version``
     - Configure the DRA Driver container image.

   * - ``draDriver.imagePullPolicy`` and ``draDriver.imagePullSecrets``
     - Configure image pulling for the DRA Driver containers.

   * - ``draDriver.featureGates``
     - Enable or disable DRA Driver feature gates.
       The Operator renders the map as the ``FEATURE_GATES`` environment variable for DRA Driver containers.

   * - ``draDriver.gpus.kubeletPlugin``
     - Configure environment variables, resource requests and limits, and the gRPC health check for the GPU kubelet-plugin container.

   * - ``draDriver.computeDomains.enabled``
     - Enable or disable the ComputeDomain controller and kubelet-plugin container.

   * - ``draDriver.computeDomains.controller``
     - Configure environment variables and resource requests and limits for the ComputeDomain controller.

   * - ``draDriver.computeDomains.kubeletPlugin``
     - Configure environment variables, resource requests and limits, and the gRPC health check for the ComputeDomain kubelet-plugin container.

   * - ``hostPaths.kubeletRootDir``
     - Configure the kubelet root directory when it differs from ``/var/lib/kubelet``.

   * - ``daemonsets``
     - Configure common labels, annotations, and tolerations.
       ``daemonsets.priorityClassName`` applies to the DRA Driver kubelet plugin and ComputeDomain controller.

For example, the following values enable a DRA Driver feature gate, configure container resources,
and enable the default gRPC health checks on their default ports:

.. code-block:: yaml

   draDriver:
     featureGates:
       NVMLDeviceHealthCheck: true
     gpus:
       kubeletPlugin:
         resources:
           requests:
             cpu: 50m
             memory: 64Mi
         healthcheck:
           enabled: true
     computeDomains:
       enabled: true
       controller:
         resources:
           requests:
             cpu: 50m
             memory: 64Mi
       kubeletPlugin:
         healthcheck:
           enabled: true

The GPU kubelet-plugin health-check port defaults to ``51516`` and the ComputeDomain kubelet-plugin health-check port defaults to ``51515``.
The Operator also enables ComputeDomain GPU clique labeling by setting ``GPU_CLIQUE_LABEL_ENABLED=true`` automatically.

*********************
Validate Installation
*********************

Reconciliation typically completes within 3 minutes.
During reconciliation, the STATUS column progresses from empty to `notReady` to `ready`.

#. Verify that the ``GPUCluster`` resource is ready:

   .. code-block:: console

      $ kubectl get gpucluster gpu-cluster

   *Example Output*

   .. code-block:: output

      NAME          STATUS   AGE
      gpu-cluster   ready    3m

   If the resource does not become ready, inspect its conditions and recent events:

   .. code-block:: console

      $ kubectl describe gpucluster gpu-cluster

   A ``PrerequisiteNotMet`` condition can indicate that a ``ClusterPolicy`` resource exists.
   An ``OperandNotReady`` condition indicates that the Operator is waiting for one or more managed pods.

#. Confirm that the managed components are running in the GPU Operator namespace:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator

   Expected workload names include the following:

   * ``nvidia-dra-driver-kubelet-plugin``
   * ``nvidia-dra-driver-controller`` when ComputeDomain support is enabled
   * ``nvidia-dra-validator``
   * ``nvidia-dcgm-exporter-dra`` when DCGM Exporter is enabled
   * ``nvidia-dcgm-dra`` when standalone DCGM is enabled

   The DRA Driver kubelet-plugin daemon set runs a GPU container and,
   when ComputeDomain support is enabled, a ComputeDomain container.
   The DRA validator and enabled telemetry components run one pod on each GPU node.
   The validator allocates a GPU through a resource claim and verifies that the device is usable.

#. Verify that the device classes are available:

   .. code-block:: console

      $ kubectl get deviceclass

   *Example Output*

   .. code-block:: output

      NAME                                        AGE
      compute-domain-daemon.nvidia.com            2m
      compute-domain-default-channel.nvidia.com   2m
      gpu.nvidia.com                              2m
      mig.nvidia.com                              2m
      vfio.gpu.nvidia.com                         2m

   The ComputeDomain device classes are present only when ComputeDomain support is enabled.
   The ``vfio.gpu.nvidia.com`` device class requires the alpha ``PassthroughSupport`` feature gate to use VFIO passthrough.
   This feature gate is disabled by default.

*************************
Running a Sample Workload
*************************

Refer to `Request full GPUs <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/guides/gpu-allocation/allocating-gpus/>`__
in the DRA Driver documentation for information about the following workload-related tasks:

* Request any GPU
* Request multiple GPUs in one pod
* Share a GPU across containers in a pod
* Select a GPU by product name
* Select a GPU by memory size
* Combine attribute and capacity selectors

*********
Telemetry
*********

DCGM Exporter is enabled by default with a ``GPUCluster`` resource and uses its embedded host engine.
Standalone DCGM is disabled by default.
Set ``dcgm.enabled=true`` to deploy the standalone ``nvidia-dcgm-dra`` host engine instead.

When either ``dcgmExporter.enablePodLabels`` or ``dcgmExporter.enablePodUID`` is enabled,
the Operator enables DRA resource slice attribution in DCGM Exporter and grants the exporter read access to ``ResourceSlice`` objects.
This enables pod metadata enrichment for GPUs allocated through DRA.

.. _dra-driver-upgrade:
.. _upgrade:

*******
Upgrade
*******

The DRA Driver is upgraded as part of the GPU Operator release.
When you upgrade the GPU Operator, preserve ``clusterPolicy.deployCR=false`` and ``gpuCluster.deployCR=true`` in your values.
You can select a different DRA Driver version by setting ``draDriver.version``.
Refer to :ref:`Upgrading the NVIDIA GPU Operator` for the Operator upgrade procedure and required CRD updates.

During an Operator-managed NVIDIA GPU driver upgrade, pods with allocated ``gpu.nvidia.com`` resource claims are treated as GPU workloads.
The driver upgrade policy applies to those pods, and the DRA Driver kubelet plugin remains available while claims are unprepared.
You do not need to configure a separate node label for DRA workload eviction.

This procedure does not migrate a standalone DRA Driver Helm release to a ``GPUCluster`` resource.
For a standalone installation, refer to the `upstream DRA Driver upgrade guide <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/upgrade/>`__
or select the GPU Operator documentation version that matches the installed release.

.. _dra-driver-uninstall:

*********
Uninstall
*********

Before uninstalling the GPU Operator, delete user workloads and user-created resource claims for GPUs
and verify that the workload pods terminate and the claims are unprepared.
Afterward, uninstall the GPU Operator by using Helm.

The chart includes a ``pre-delete`` hook that deletes ``gpu-cluster`` and waits for the ``GPUCluster`` resource finalizer to perform ordered teardown.

.. tip:: The uninstall command output can report that the ``gpu-cluster`` resource was kept.

   However, a pre-delete hook actually deletes the resource.

   .. code-block:: console

      These resources were kept due to the resource policy:
      [GPUCluster] gpu-cluster

      release "gpu-operator" uninstalled

The finalizer removes Operator-managed daemon sets that consume resource claims before the DRA Driver kubelet plugin is removed.
Do not use ``helm uninstall --no-hooks`` while ``gpu-cluster`` exists because Helm can remove the Operator before this teardown completes.

Refer to :doc:`uninstall` for the complete uninstall procedure and CRD cleanup information.

***************
Troubleshooting
***************

Recover From an Uninstall That Skipped the Pre-Delete Hook
==========================================================

If you run ``helm uninstall gpu-operator --no-hooks`` while ``gpu-cluster`` exists,
Helm removes the Operator before the ``pre-delete`` hook can perform an ordered teardown.
The following resources are left in the cluster with no controller to reconcile them:

* The ``gpu-cluster`` resource, which cannot be deleted because the
  ``gpucluster.nvidia.com/dra-resourceclaim`` finalizer requires the Operator.
* The DRA Driver kubelet plugin, DRA validator, and DCGM Exporter pods.
* Operator-managed resource claims for the preceding pods.

To recover, remove the finalizer from ``gpu-cluster``, then force-delete the remaining managed components:

#. Remove the finalizer from ``gpu-cluster``:

   .. code-block:: console

      $ kubectl patch gpucluster gpu-cluster --type=json \
          -p='[{"op":"remove","path":"/metadata/finalizers"}]'

#. Remove finalizers from the orphaned resource claims in the GPU Operator namespace:

   .. code-block:: console

      $ for rc in $(kubectl get resourceclaim -n gpu-operator -o name); do
          kubectl patch $rc -n gpu-operator --type=json \
              -p='[{"op":"remove","path":"/metadata/finalizers"}]'
        done

#. Force-delete any pods that remain in the ``Terminating`` state:

   .. code-block:: console

      $ kubectl delete pods -n gpu-operator --all --grace-period=0 --force

#. Delete the GPU Operator namespace to remove residual state:

   .. code-block:: console

      $ kubectl delete namespace gpu-operator

To avoid this recovery path, run ``helm uninstall`` without ``--no-hooks`` so that the
``pre-delete`` hook can complete ordered teardown.

Clean Up Resource Claims Stuck in ``deleted,allocated,reserved``
================================================================

resource claims in the ``deleted,allocated,reserved`` state indicate that the API server
accepted a delete request, but the DRA Driver kubelet plugin has not completed the
device _unprepare_ step for the claim.
This state can persist if the DRA Driver kubelet plugin was removed or restarted
before it could unprepare the allocated devices.

Take one of the following actions:

* If the DRA Driver kubelet plugin can be restarted, ensure that the
  ``nvidia-dra-driver-kubelet-plugin`` pod is running.
  The plugin completes the unprepare step and the resource claims are removed.

* If the DRA Driver kubelet plugin cannot be restarted, such as after an
  uninstall that skipped the pre-delete hook, remove the finalizers from
  the affected resource claims:

  .. code-block:: console

     $ for rc in $(kubectl get resourceclaim -n gpu-operator -o name); do
         kubectl patch $rc -n gpu-operator --type=json \
             -p='[{"op":"remove","path":"/metadata/finalizers"}]'
       done

  Removing finalizers bypasses the unprepare step.
  Use this option only during recovery when no DRA workloads are running.

************************
Additional Documentation
************************

For more details on the DRA Driver for NVIDIA GPUs, refer to the following resources:

* `DRA Driver for NVIDIA GPUs documentation <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/>`__
* `DRA Driver v${dra_version} release notes <https://github.com/kubernetes-sigs/dra-driver-nvidia-gpu/releases/tag/v${dra_version}>`__
* :ref:`gpu-operator-kubevirt-dra`
