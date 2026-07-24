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

.. headings (h1/h2/h3/h4/h5) are # * = - ^

.. _gpucluster-reference:

#######################################
GPUCluster Custom Resource Reference
#######################################

The ``GPUCluster`` custom resource definition (CRD) configures the Dynamic Resource Allocation (DRA) GPU resource
management model that the NVIDIA GPU Operator manages.
A single ``GPUCluster`` instance in the cluster describes the desired state of the DRA operands—the
`DRA Driver for NVIDIA GPUs <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/>`__, DCGM, and DCGM Exporter—including
which container images to use and how each component is configured.

The GPU Operator watches the ``GPUCluster`` object and reconciles the managed DaemonSets and Deployments to match the
desired state.

Unlike :doc:`ClusterPolicy <clusterpolicy-reference>`, ``GPUCluster`` does not manage the NVIDIA GPU driver or the
NVIDIA Kubernetes Device Plugin.
The GPU driver must be pre-installed on the host or managed by an ``NVIDIADriver`` custom resource, and GPUs are
surfaced to workloads through DRA rather than through extended resources.
For a conceptual overview of the DRA stack, installation steps, and deployment scenarios, refer to
:doc:`Deploying the GPU Operator with DRA Support <gpu-operator-dra>`.

.. note::

   Deploying and managing the DRA Driver for NVIDIA GPUs through the ``GPUCluster`` custom resource is in Technology
   Preview. The ``GPUCluster`` API is served under ``nvidia.com/v1alpha1`` and is subject to change in future releases.
   ``GPUCluster`` is supported only for greenfield (new) deployments.
   Migrating an existing ``ClusterPolicy`` deployment to ``GPUCluster`` in place is not supported.
   Do not use ``ClusterPolicy`` and ``GPUCluster`` as GPU resource management models in the same cluster.

*******************************
Singleton Behavior
*******************************

``GPUCluster`` is a *singleton* resource: the GPU Operator reconciles only one instance in the cluster.
The GPU Operator Helm chart creates a default instance named ``gpu-cluster`` when DRA support is enabled
(``gpuCluster.enabled=true``).

The first ``GPUCluster`` object that the controller observes becomes the active instance ("first-wins").
Any additional ``GPUCluster`` objects are not reconciled and are marked with the ``ignored`` state in their status.
To change the configuration, edit the active instance rather than creating a second one.

*******************************
GPUCluster Resource Structure
*******************************

``GPUCluster`` is a cluster-scoped resource in the ``nvidia.com/v1alpha1`` API group.
Its short name is ``gc``.

.. code-block:: yaml

   apiVersion: nvidia.com/v1alpha1
   kind: GPUCluster
   metadata:
     name: gpu-cluster
   spec:
     draDriver: {}
     dcgm: {}
     dcgmExporter: {}
     hostPaths: {}
     daemonsets: {}

**Top-Level Spec Fields**

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Required

   * - ``draDriver``
     - Configuration for the DRA Driver for NVIDIA GPUs, including the GPU allocation (``gpus``) and ComputeDomains
       capabilities.
     - Yes

   * - ``dcgm``
     - Configuration for the standalone NVIDIA DCGM hostengine. Disabled by default. When disabled, DCGM Exporter uses
       its embedded ``nv-hostengine``.
     - No

   * - ``dcgmExporter``
     - Configuration for the NVIDIA DCGM Exporter (GPU telemetry). Enabled by default.
     - No

   * - ``hostPaths``
     - Custom host filesystem paths used by the deployed components.
     - No

   * - ``daemonsets``
     - Common settings applied to all DaemonSets managed by the ``GPUCluster`` controller.
     - No

*******************************
spec.draDriver
*******************************

Configures the DRA Driver for NVIDIA GPUs.
There is no top-level ``enabled`` toggle: the GPU allocation (``gpus``) capability is always deployed, and the
ComputeDomains capability has its own ``enabled`` field.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``repository``
     - Container registry and path for the DRA driver image.
     - ``registry.k8s.io/dra-driver-nvidia``

   * - ``image``
     - DRA driver image name (without tag).
     - ``dra-driver-nvidia-gpu``

   * - ``version``
     - DRA driver image tag or version string.
     - Defined by the Operator release. Refer to the :ref:`operator-component-matrix`.

   * - ``imagePullPolicy``
     - Kubernetes `image pull policy <https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy>`_.
       Accepted values: ``Always``, ``IfNotPresent``, ``Never``.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - List of Kubernetes Secret names that contain credentials for pulling the DRA driver image from a private
       registry.
     - None

   * - ``featureGates``
     - Map of DRA driver feature gate names to booleans. Rendered as the ``FEATURE_GATES`` environment variable on the
       DRA driver containers, for example ``{MPSSupport: true}``.
     - None

   * - ``gpus``
     - Configuration for the ``gpu.nvidia.com`` (GPU allocation) capability. See :ref:`gpucluster-dradriver-gpus`.
     - N/A

   * - ``computeDomains``
     - Configuration for the ComputeDomains (Multi-Node NVLink) capability. See
       :ref:`gpucluster-dradriver-computedomains`.
     - N/A

.. _gpucluster-dradriver-gpus:

spec.draDriver.gpus
===================

Configures the ``gpu.nvidia.com`` capability, which maps onto the ``gpus`` container of the kubelet-plugin DaemonSet.
This capability is always deployed.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``kubeletPlugin``
     - Configuration for the ``gpus`` kubelet-plugin container. See :ref:`gpucluster-dradriver-kubeletplugin`.
     - N/A

.. _gpucluster-dradriver-computedomains:

spec.draDriver.computeDomains
=============================

Configures the ComputeDomains capability, an abstraction for secure `Multi-Node NVLink (MNNVL)
<https://docs.nvidia.com/multi-node-nvlink-systems/index.html>`_ on NVIDIA GB200 and similar systems.
The ``kubeletPlugin`` maps onto the ``compute-domains`` container of the kubelet-plugin DaemonSet, and the
``controller`` is a separate Deployment.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - Whether the ComputeDomains capability is deployed. When enabled, the DRA driver deploys the
       ``compute-domains`` kubelet-plugin container and the compute-domain controller Deployment.
     - ``true``

   * - ``controller``
     - Overrides for the compute-domain controller Deployment. Accepts ``env`` and ``resources``.
     - N/A

   * - ``kubeletPlugin``
     - Configuration for the ``compute-domains`` kubelet-plugin container. See
       :ref:`gpucluster-dradriver-kubeletplugin`.
     - N/A

.. _gpucluster-dradriver-kubeletplugin:

kubelet-plugin fields
=====================

The ``gpus.kubeletPlugin`` and ``computeDomains.kubeletPlugin`` blocks map onto the two containers of a single
kubelet-plugin DaemonSet and accept the following fields.
Scheduling is opinionated and is not configurable.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``env``
     - List of environment variables (``name``/``value`` pairs) to set in the container.
     - None

   * - ``resources``
     - CPU and memory resource requests and limits for the container. Follows the standard Kubernetes
       ``ResourceRequirements`` structure.
     - None

   * - ``healthcheckPort``
     - Port for a gRPC health service checked by a liveness probe. Set to a negative value to disable the service and
       the probe.
     - Component default

The ``computeDomains.controller`` Deployment accepts ``env`` and ``resources`` with the same meanings.

*******************************
spec.dcgm
*******************************

Configures the standalone NVIDIA DCGM hostengine.
This component is **disabled by default**; when it is disabled, DCGM Exporter uses its embedded ``nv-hostengine``.

The ``dcgm`` section uses the same fields as the ``dcgm`` section of ``ClusterPolicy``.
Refer to ``spec.dcgm`` in the :doc:`ClusterPolicy Custom Resource Reference <clusterpolicy-reference>` for the full
list of fields.

*******************************
spec.dcgmExporter
*******************************

Configures the NVIDIA DCGM Exporter for GPU telemetry.
This component is **enabled by default**.

The ``dcgmExporter`` section uses the same fields as the ``dcgmExporter`` section of ``ClusterPolicy``.
Refer to ``spec.dcgmExporter`` in the :doc:`ClusterPolicy Custom Resource Reference <clusterpolicy-reference>` for the
full list of fields.

*******************************
spec.hostPaths
*******************************

Configures custom host filesystem paths used by the deployed components, such as the root filesystem, the driver
install directory, and the kubelet root directory.

The ``hostPaths`` section uses the same fields as the ``hostPaths`` section of ``ClusterPolicy``.
Refer to ``spec.hostPaths`` in the :doc:`ClusterPolicy Custom Resource Reference <clusterpolicy-reference>` for the
full list of fields.

*******************************
spec.daemonsets
*******************************

Applies common settings—such as labels, annotations, priority class, tolerations, and update strategy—to all
DaemonSets that the ``GPUCluster`` controller manages.

The ``daemonsets`` section uses the same fields as the ``daemonsets`` section of ``ClusterPolicy``.
Refer to ``spec.daemonsets`` in the :doc:`ClusterPolicy Custom Resource Reference <clusterpolicy-reference>` for the
full list of fields.

*******************************
Status
*******************************

The GPU Operator reports the observed state of the active ``GPUCluster`` instance in its ``status`` field.
The ``status.state`` value is shown in the ``Status`` column of ``kubectl get gpucluster``.

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - State
     - Description

   * - ``ready``
     - All enabled operands are deployed and healthy.

   * - ``notReady``
     - One or more operands are not yet deployed or are not healthy.

   * - ``disabled``
     - The ``GPUCluster`` instance is present but its operands are disabled.

   * - ``ignored``
     - A duplicate ``GPUCluster`` instance that the singleton controller does not reconcile.

The ``status`` field also reports the ``namespace`` in which the operator and operands are installed and a list of
``conditions`` that represent the current state of the resource.
