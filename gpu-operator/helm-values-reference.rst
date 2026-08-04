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

.. _helm-values-reference:
.. _gpu-operator-helm-chart-options:

###########################
Helm Chart Values Reference
###########################

The NVIDIA GPU Operator is installed and configured with a Helm chart.
This page is a reference for the most frequently used chart values, grouped by component.

You can set values on the command line with ``--set <key>=<value>`` when you install or upgrade the chart, or provide
a values file with ``-f values.yaml``.
To view the complete set of values for a specific chart version, run:

.. code-block:: console

   $ helm show values nvidia/gpu-operator --version=${version}

.. note::

   Many chart values populate fields of the ``ClusterPolicy`` or ``GPUCluster`` custom resources that the chart
   creates. For the complete custom resource schemas, refer to the
   :doc:`ClusterPolicy Custom Resource Reference <clusterpolicy-reference>` and the
   :doc:`GPUCluster Custom Resource Reference <gpucluster-reference>`.

*******************************
Operator and Global Settings
*******************************

.. list-table::
   :widths: 25 50 25
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``operator.labels``
     - Map of custom labels to add to all GPU Operator managed pods.
     - ``{}``

   * - ``operator.env``
     - List of environment variables (``name``/``value`` pairs) set on the GPU Operator.
       For a ``GPUCluster`` deployment, set ``DEFAULT_GPU_ALLOCATION_MODE`` to ``dra`` so newly-added GPU nodes use the
       DRA model. Refer to :ref:`Deployment Model <dra-deployment-scenarios>`.
     - ``[]``

   * - ``daemonsets.labels``
     - Map of custom labels to add to all GPU Operator managed DaemonSet pods.
     - ``{}``

   * - ``daemonsets.annotations``
     - Map of custom annotations to add to all GPU Operator managed DaemonSet pods.
     - ``{}``

   * - ``psa.enabled``
     - When set to ``true``, the Operator configures Pod Security Admission labels on its namespace.
     - ``false``

   * - ``psp.enabled`` (Deprecated)
     - Deploys ``PodSecurityPolicies`` when enabled. PodSecurityPolicy is no longer supported in current Kubernetes
       releases.
     - ``false``

*****************
NVIDIA GPU Driver
*****************

These values configure the ``driver`` section of ``ClusterPolicy``.
For per-node driver configuration through the ``NVIDIADriver`` custom resource, refer to
:doc:`GPU Driver CRD <gpu-driver-configuration>`.

.. list-table::
   :widths: 25 50 25
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``driver.enabled``
     - By default, the Operator deploys NVIDIA drivers as a container on the system.
       Set this value to ``false`` when using the Operator on systems with pre-installed drivers.
     - ``true``

   * - ``driver.nvidiaDriverCRD.enabled``
     - When set to ``true``, the Operator deploys and uses the NVIDIA GPU Driver custom resource definition.
       Refer to the :doc:`NVIDIA GPU Driver Custom Resource Definition <gpu-driver-configuration>` page for more
       information.
     - ``false``

   * - ``driver.repository``
     - Image repository for the driver container. Specify another image repository when using custom driver images.
     - ``nvcr.io/nvidia``

   * - ``driver.image``
     - Name of the NVIDIA driver container image to use.
     - ``driver``

   * - ``driver.version``
     - Version of the NVIDIA datacenter driver supported by the Operator.
       If you set ``driver.usePrecompiled`` to ``true``, set this field to a driver branch, such as ``535``.
     - Depends on the Operator version. Refer to the :ref:`operator-component-matrix`.

   * - ``driver.imagePullSecrets``
     - List of image pull secrets used for pulling the driver container image from the registry.
     - None

   * - ``driver.kernelModuleType``
     - Type of NVIDIA GPU kernel modules to use. Valid values are ``auto`` (default), ``proprietary``, and ``open``.
       ``auto`` selects the recommended module type based on the GPU devices and driver branch.
     - ``auto``

   * - ``driver.rdma.enabled``
     - Controls whether the driver DaemonSet builds and loads the legacy ``nvidia-peermem`` kernel module.
       Refer to :doc:`gpu-operator-rdma` for guidance on whether you need it.
     - ``false``

   * - ``driver.rdma.useHostMofed``
     - Indicates that MLNX_OFED (MOFED) drivers are pre-installed on the host.
     - ``false``

   * - ``driver.secretEnv``
     - Name of a secret passed to the driver container. A common use is passing an Ubuntu Pro token secret for
       government-ready components. Refer to :doc:`install-gpu-operator-gov-ready`.
     - None

   * - ``driver.startupProbe``
     - Startup probe configuration for the driver container. By default the probe runs ``nvidia-smi`` with a ``60s``
       timeout after an initial delay. Increase ``timeoutSeconds`` if ``nvidia-smi`` runs slowly in your cluster.
     - ``60s``

   * - ``driver.usePrecompiled``
     - When set to ``true``, the Operator attempts to deploy driver containers with precompiled kernel drivers.
       Refer to the :doc:`precompiled driver containers <precompiled-drivers>` page for supported operating systems.
     - ``false``

   * - ``driver.useOpenKernelModules`` (Deprecated)
     - Deprecated as of v25.3.0 and ignored. Use ``driver.kernelModuleType`` instead.
     - ``false``

************************
NVIDIA Container Toolkit
************************

.. list-table::
   :widths: 25 50 25
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``toolkit.enabled``
     - By default, the Operator deploys the NVIDIA Container Toolkit as a container on the system.
       Set this value to ``false`` when using the Operator on systems with pre-installed NVIDIA runtimes.
     - ``true``

*************
Device Plugin
*************

.. list-table::
   :widths: 25 50 25
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``devicePlugin.config``
     - Specifies the configuration for the NVIDIA Device Plugin as a config map. In most cases this is configured
       after installing the Operator, for example to configure :doc:`gpu-sharing`.
     - ``{}``

***********
CDI and NRI
***********

.. list-table::
   :widths: 25 50 25
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``cdi.enabled``
     - When set to ``true`` (default), the Container Device Interface (CDI) is used for injecting GPUs into workload
       containers, and the Operator no longer configures the ``nvidia`` runtime class as the default runtime handler.
       Refer to the :doc:`cdi` page for more information.
     - ``true``

   * - ``cdi.nriPluginEnabled``
     - When set to ``true``, the Node Resource Interface (NRI) Plugin is used for injecting GPUs into workload
       containers, and the NVIDIA Container Toolkit no longer modifies the runtime configuration.
       Requires containerd v1.7.30, v2.1.x, or v2.2.x, or CRI-O v1.34 or later. Refer to the :doc:`cdi` page.
     - ``false``

   * - ``cdi.default`` (Deprecated)
     - Deprecated as of v25.10.0 and ignored. ``cdi.enabled`` defaults to ``true`` in v25.10.0 and later.
     - ``false``

**********************
DCGM and DCGM Exporter
**********************

.. list-table::
   :widths: 25 50 25
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``dcgm.enabled``
     - When set to ``true``, the Operator deploys a standalone NVIDIA DCGM hostengine. When ``false``, DCGM Exporter
       uses its embedded ``nv-hostengine``.
     - ``false``

   * - ``dcgmExporter.enabled``
     - By default, the Operator gathers GPU telemetry using
       `DCGM Exporter <https://docs.nvidia.com/datacenter/cloud-native/gpu-telemetry/latest/dcgm-exporter.html>`_.
       Set this value to ``false`` to disable it.
     - ``true``

   * - ``dcgmExporter.service.internalTrafficPolicy``
     - Specifies the
       `internalTrafficPolicy <https://kubernetes.io/docs/concepts/services-networking/service/#traffic-policies>`_
       for the DCGM Exporter service. Available values are ``Cluster`` (default) or ``Local``.
     - ``Cluster``

   * - ``dcgmExporter.hostNetwork``
     - When set to ``true``, DCGM Exporter exposes a metric port on the host's network namespace.
     - ``false``

   * - ``dcgmExporter.annotations``
     - Map of custom annotations to add to the DCGM Exporter DaemonSet.
     - ``{}``

   * - ``dcgmExporter.enablePodLabels``
     - When set to ``true``, Kubernetes pod labels are added as Prometheus label dimensions on GPU metrics.
       This provisions a cluster-scoped ClusterRole and ClusterRoleBinding (``nvidia-dcgm-exporter-read-pods``) that
       grants the DCGM Exporter service account ``get``, ``list``, and ``watch`` access to pods.
       Use ``dcgmExporter.podLabelAllowlistRegex`` to limit which labels are emitted.
     - ``false``

   * - ``dcgmExporter.enablePodUID``
     - When set to ``true``, the Kubernetes pod UID is added as a Prometheus label dimension on GPU metrics.
       Like ``dcgmExporter.enablePodLabels``, this provisions a cluster-scoped ClusterRole and ClusterRoleBinding.
     - ``false``

   * - ``dcgmExporter.podLabelAllowlistRegex``
     - List of regular expressions that filter which pod labels are emitted as Prometheus dimensions when
       ``dcgmExporter.enablePodLabels`` is ``true``. NVIDIA recommends configuring this allowlist in clusters with
       many pod labels to reduce Prometheus cardinality.
     - None

************************
MIG (Multi-Instance GPU)
************************

.. list-table::
   :widths: 25 50 25
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``mig.strategy``
     - Controls the strategy used with MIG on supported NVIDIA GPUs. Options are ``single`` or ``mixed``.
     - ``single``

   * - ``migManager.enabled``
     - The MIG Manager watches for changes to the MIG geometry and applies reconfiguration as needed. By default it
       only runs on nodes with GPUs that support MIG.
     - ``true``

**********************
Node Feature Discovery
**********************

.. list-table::
   :widths: 25 50 25
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``nfd.enabled``
     - Deploys the Node Feature Discovery (NFD) plugin as a DaemonSet.
       Set this value to ``false`` if NFD is already running in the cluster.
     - ``true``

   * - ``nfd.nodefeaturerules``
     - Installs node feature rules related to confidential computing. NFD uses the rules to detect security features
       in CPUs and NVIDIA GPUs. Set this value to ``true`` when configuring the Operator for Confidential Containers.
     - ``false``

.. _helm-values-dra:

************************
DRA Support (GPUCluster)
************************

These values enable and configure the DRA GPU resource management model.
The ``gpuCluster.*`` values populate the ``GPUCluster`` custom resource; for the full field list, refer to the
:doc:`GPUCluster Custom Resource Reference <gpucluster-reference>` and
:doc:`Deploying the GPU Operator with DRA Support <gpu-operator-dra>`.

.. list-table::
   :widths: 25 50 25
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``gpuCluster.enabled``
     - When set to ``true``, the Operator creates the default ``GPUCluster`` resource and enables the DRA model.
     - ``false``

   * - ``gpuCluster.draDriver.*``
     - Configures the DRA driver image and its GPU allocation (``gpus``) and ComputeDomains capabilities.
       Populates ``spec.draDriver`` of the ``GPUCluster`` resource.
     - See reference

   * - ``operator.env[*]`` (``DEFAULT_GPU_ALLOCATION_MODE``)
     - Set to ``dra`` for a ``GPUCluster`` deployment so newly-added GPU nodes use the DRA model.
     - unset

*****************
Sandbox Workloads
*****************

These values apply when running virtual machine workloads (KubeVirt) or Kata Containers.

.. list-table::
   :widths: 25 50 25
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``sandboxWorkloads.enabled``
     - Specifies whether sandbox workloads are enabled.
     - ``false``

   * - ``sandboxWorkloads.defaultWorkload``
     - Default workload type for the cluster: ``container``, ``vm-passthrough``, or ``vm-vgpu``.
       Refer to :doc:`KubeVirt <gpu-operator-kubevirt>` and :doc:`Kata Containers <deploy-kata-containers>`.
     - ``container``

   * - ``sandboxWorkloads.mode``
     - Sandbox mode used when deploying sandbox workloads. Accepted values are ``kubevirt`` (default) and ``kata``.
     - ``kubevirt``

****************
Other Components
****************

.. list-table::
   :widths: 25 50 25
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``ccManager.enabled``
     - When set to ``true``, the Operator deploys the NVIDIA Confidential Computing Manager for Kubernetes.
     - ``false``

   * - ``gdrcopy.enabled``
     - Enables support for GDRCopy. When set to ``true``, the GDRCopy driver runs as a sidecar container in the GPU
       driver pod. For information about GDRCopy, refer to the
       `gdrcopy <https://developer.nvidia.com/gdrcopy>`__ page.
     - ``false``
