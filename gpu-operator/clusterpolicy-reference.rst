
.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2024-2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
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

.. _clusterpolicy-reference:

##############################################
ClusterPolicy Custom Resource Reference
##############################################

The ``ClusterPolicy`` custom resource definition (CRD) is the primary configuration object for the NVIDIA GPU Operator.
A single ``ClusterPolicy`` instance in the cluster describes the desired state of every GPU Operator component—which operands to enable,
which container images to use, and how each component should be configured.

The GPU Operator watches the ``ClusterPolicy`` object and reconciles all managed DaemonSets and Deployments to match the desired state.

.. note::

   The NVIDIA GPU Operator also provides a separate ``NVIDIADriver`` custom resource for fine-grained, per-node driver configuration.
   When you enable the NVIDIA Driver CRD (``spec.driver.useNvidiaDriverCRD: true``), driver configuration is taken from ``NVIDIADriver`` objects rather than from the ``driver`` section of ``ClusterPolicy``.
   For more information, refer to :doc:`GPU Driver CRD <gpu-driver-configuration>`.

*********************************
ClusterPolicy Resource Structure
*********************************

``ClusterPolicy`` is a cluster-scoped resource in the ``nvidia.com/v1`` API group.

.. code-block:: yaml

   apiVersion: nvidia.com/v1
   kind: ClusterPolicy
   metadata:
     name: gpu-cluster-policy
   spec:
     operator: {}
     daemonsets: {}
     driver: {}
     toolkit: {}
     devicePlugin: {}
     dcgmExporter: {}
     dcgm: {}
     nodeStatusExporter: {}
     gfd: {}
     mig: {}
     migManager: {}
     validator: {}
     gds: {}
     gdrcopy: {}
     sandboxWorkloads: {}
     vfioManager: {}
     sandboxDevicePlugin: {}
     vgpuManager: {}
     vgpuDeviceManager: {}
     cdi: {}
     kataManager: {}
     ccManager: {}
     hostPaths: {}
     kataSandboxDevicePlugin: {}


**Top-Level Spec Fields**

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Required

   * - ``operator``
     - Configuration options for the GPU Operator itself.
     - Yes

   * - ``daemonsets``
     - Common settings applied to all DaemonSets managed by the Operator.
     - Yes

   * - ``driver``
     - Configuration for deploying and managing the NVIDIA GPU Driver.
     - Yes

   * - ``toolkit``
     - Configuration for the NVIDIA Container Toolkit.
     - Yes

   * - ``devicePlugin``
     - Configuration for the NVIDIA Kubernetes Device Plugin.
     - Yes

   * - ``dcgmExporter``
     - Configuration for the NVIDIA DCGM Exporter (GPU telemetry).
     - Yes

   * - ``dcgm``
     - Configuration for deploying NVIDIA DCGM host engine as a standalone pod.
     - Yes

   * - ``nodeStatusExporter``
     - Configuration for the Node Status Exporter.
     - Yes

   * - ``gfd``
     - Configuration for the NVIDIA GPU Feature Discovery (GFD) plugin.
     - Yes

   * - ``mig``
     - MIG (Multi-Instance GPU) strategy configuration.
     - No

   * - ``migManager``
     - Configuration for the NVIDIA MIG Manager.
     - No

   * - ``validator``
     - Configuration for the NVIDIA GPU Operator Validator.
     - No

   * - ``gds``
     - Configuration for NVIDIA GPUDirect Storage (GDS). Experimental.
     - No

   * - ``gdrcopy``
     - Configuration for the NVIDIA GDRCopy driver.
     - No

   * - ``sandboxWorkloads``
     - Configuration for sandbox workloads (KubeVirt, Kata Containers).
     - No

   * - ``vfioManager``
     - Configuration for the VFIO-PCI Manager (used with VM passthrough workloads).
     - No

   * - ``sandboxDevicePlugin``
     - Configuration for the NVIDIA KubeVirt GPU Device Plugin.
     - No

   * - ``vgpuManager``
     - Configuration for the NVIDIA vGPU Manager.
     - No

   * - ``vgpuDeviceManager``
     - Configuration for the NVIDIA vGPU Device Manager.
     - No

   * - ``cdi``
     - Configuration for the Container Device Interface (CDI).
     - No

   * - ``kataManager``
     - Configuration for the Kata Manager (Kata Containers support).
     - No

   * - ``ccManager``
     - Configuration for the NVIDIA Confidential Computing Manager.
     - No

   * - ``hostPaths``
     - Custom host filesystem paths used by GPU Operator components.
     - No

   * - ``kataSandboxDevicePlugin``
     - Configuration for the NVIDIA Kata Sandbox Device Plugin.
     - No

   * - ``psa``
     - Configuration for PodSecurityAdmission.
     - No

   * - ``psp``
     - Deprecated. PodSecurityPolicy configuration (no longer supported).
     - No


**Common Component Fields**

Most component sections share the following fields.
Component-specific fields are documented in each section below.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - Whether the Operator deploys this component.
       Set to ``false`` to disable a component without removing the rest of the GPU Operator configuration.
     - Varies by component. See individual sections.

   * - ``repository``
     - Container registry and path for the component image.
       Override this when using a private registry or air-gapped environment.
     - Component-specific NGC registry path.

   * - ``image``
     - Container image name (without tag).
     - Component-specific.

   * - ``version``
     - Image tag or version string.
     - Defined by the Operator release. Refer to the :ref:`operator-component-matrix`.

   * - ``imagePullPolicy``
     - Kubernetes `image pull policy <https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy>`_.
       Accepted values: ``Always``, ``IfNotPresent``, ``Never``.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - List of Kubernetes Secret names that contain credentials for pulling images from a private registry.
     - None

   * - ``resources``
     - CPU and memory resource requests and limits for component pods.
       Follows the standard Kubernetes ``ResourceRequirements`` structure.
     - None (uses Kubernetes defaults)

   * - ``args``
     - Additional command-line arguments to pass to the component container.
     - None

   * - ``env``
     - List of environment variables (``name``/``value`` pairs) to set in the component container.
     - None

   * - ``hostNetwork``
     - When ``true``, the component pod runs in the host network namespace.
       Required in some environments for proper network access.
     - ``false``


*************************
spec.operator
*************************

Configures operator-level settings.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``runtimeClass``
     - Specifies the Kubernetes RuntimeClass used for GPU-enabled pods.
     - ``nvidia``

   * - ``labels``
     - Map of additional labels to add to all GPU Operator managed pods.
     - None

   * - ``annotations``
     - Map of additional annotations to add to all GPU Operator managed pods.
     - None

   * - ``use_ocp_driver_toolkit``
     - On OpenShift, when set to ``true``, the Operator uses the DriverToolkit image to build and install driver kernel modules.
     - ``false``

   * - ``defaultRuntime``
     - Deprecated. The container runtime is now detected automatically at runtime.
     - N/A

   * - ``initContainer``
     - Deprecated. Configuration for the init container image used with all components.
     - N/A


*************************
spec.daemonsets
*************************

Applies common settings to all DaemonSets managed by the GPU Operator.
These settings serve as defaults and can be supplemented by per-component configuration.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``labels``
     - Map of additional labels to apply to all GPU Operator DaemonSet pods.
     - None

   * - ``annotations``
     - Map of additional annotations to apply to all GPU Operator DaemonSet pods.
     - None

   * - ``tolerations``
     - List of Kubernetes tolerations to apply to all DaemonSet pods.
       Refer to the `Kubernetes tolerations documentation <https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/>`_.
     - None

   * - ``priorityClassName``
     - Priority class for all DaemonSet pods.
     - None

   * - ``updateStrategy``
     - DaemonSet update strategy. Accepted values: ``RollingUpdate``, ``OnDelete``.
     - ``RollingUpdate``

   * - ``rollingUpdate.maxUnavailable``
     - For ``RollingUpdate``, the maximum number of nodes that can simultaneously have DaemonSet pods updated.
       Accepts an absolute number or a percentage string (for example, ``"25%"``).
     - ``1``

   * - ``podSecurityContext``
     - Pod-level security context applied as defaults to all DaemonSet pods.
       Follows the standard Kubernetes ``PodSecurityContext`` structure.
     - None


*************************
spec.driver
*************************

Controls NVIDIA GPU Driver deployment.
When ``useNvidiaDriverCRD`` is ``false`` (the default), the Operator manages a single driver DaemonSet
for the entire cluster based on this configuration.
When ``useNvidiaDriverCRD`` is ``true``, driver configuration is instead sourced from ``NVIDIADriver`` custom resources.
Refer to :doc:`GPU Driver CRD <gpu-driver-configuration>` for details.

.. list-table::
   :header-rows: 1
   :widths: 30 50 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, the Operator deploys the NVIDIA GPU Driver as a container.
       Set to ``false`` on systems that have a pre-installed GPU driver.
     - ``true``

   * - ``useNvidiaDriverCRD``
     - When ``true``, driver management uses ``NVIDIADriver`` custom resources instead of this section.
       Refer to :doc:`GPU Driver CRD <gpu-driver-configuration>`.
     - ``false``

   * - ``usePrecompiled``
     - When ``true``, the Operator uses driver containers with pre-compiled kernel modules.
       Refer to :doc:`precompiled-drivers` for supported operating systems and limitations.
       Set ``version`` to a driver branch (for example, ``"580"``), not a full version.
       This field is immutable when using the ``NVIDIADriver`` CRD.
     - ``false``

   * - ``kernelModuleType``
     - Specifies the GPU kernel module type. Accepted values:

       - ``auto`` — The Operator selects open or proprietary modules based on the GPU and driver branch.
         Supported with driver 570.86.15 or later; 550 and 535 branch drivers do not support ``auto``.
       - ``open`` — Uses NVIDIA Open GPU Kernel Modules (OpenRM).
       - ``proprietary`` — Uses the proprietary NVIDIA kernel module.
     - ``auto``

   * - ``useOpenKernelModules``
     - Deprecated as of v25.3.0. Use ``kernelModuleType`` instead.
     - N/A

   * - ``repository``
     - Registry path for the driver container.
     - ``nvcr.io/nvidia``

   * - ``image``
     - Driver container image name.
     - ``driver``

   * - ``version``
     - GPU driver version to install.
       For a standard driver, specify the full version such as ``580.126.20``.
       For precompiled drivers, specify the branch such as ``580``.
       Refer to the :ref:`operator-component-matrix` for supported versions.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy for the driver container.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets for the driver container registry.
     - None

   * - ``hostNetwork``
     - When ``true``, the driver pod runs in the host network namespace.
     - ``false``

   * - ``secretEnv``
     - Name of a Kubernetes Secret containing environment variables to pass to the driver container.
       A common use case is providing an Ubuntu Pro token for government-ready deployments.
       Refer to :doc:`install-gpu-operator-gov-ready`.
     - None

   * - ``startupProbe``
     - Startup probe settings for the driver container.
       By default, the driver container waits 60 seconds before probing with ``nvidia-smi``.
       Increase ``timeoutSeconds`` if ``nvidia-smi`` is slow in your environment.
       See :ref:`ContainerProbeSpec fields <driver-probe-spec>`.
     - ``initialDelaySeconds: 60, timeoutSeconds: 60``

   * - ``livenessProbe``
     - Liveness probe settings for the driver container.
       See :ref:`ContainerProbeSpec fields <driver-probe-spec>`.
     - None

   * - ``readinessProbe``
     - Readiness probe settings for the driver container.
       See :ref:`ContainerProbeSpec fields <driver-probe-spec>`.
     - None

   * - ``rdma.enabled``
     - When ``true``, the driver pod builds and loads the ``nvidia-peermem`` kernel module to support legacy GPUDirect RDMA.
       Refer to :doc:`gpu-operator-rdma` to determine whether you need this or can use the DMA-BUF approach instead.
     - ``false``

   * - ``rdma.useHostMofed``
     - When ``true``, indicates that MLNX_OFED (MOFED) drivers are pre-installed on the host.
       Used together with ``rdma.enabled``.
     - ``false``

   * - ``upgradePolicy``
     - Automatic driver upgrade policy.
       When configured, the Operator can perform rolling upgrades of driver pods without manual intervention.
       Follows the ``DriverUpgradePolicySpec`` from the ``k8s-operator-libs`` library.
       Refer to the `NVIDIA k8s-operator-libs documentation <https://github.com/NVIDIA/k8s-operator-libs>`__ for field details.
     - None (upgrades must be triggered manually)

   * - ``manager``
     - Configuration for the NVIDIA Driver Manager init container, which prepares nodes for driver installation.
       See :ref:`DriverManagerSpec fields <driver-manager-spec>`.
     - Managed by the Operator.

   * - ``resources``
     - Resource requests and limits for the driver container.
     - None

   * - ``args``
     - Additional arguments for the driver container.
     - None

   * - ``env``
     - Environment variables for the driver container.
     - None

   * - ``repoConfig``
     - Custom apt/yum repository configuration for the driver container.
       Specify a ConfigMap name that the Operator mounts into the driver container for custom package sources.
       Refer to :doc:`install-gpu-operator-air-gapped` for air-gapped use cases.
     - None

   * - ``certConfig``
     - Custom certificate configuration for the driver container.
       Specify a ConfigMap name containing custom CA certificates.
     - None

   * - ``licensingConfig``
     - vGPU license configuration. See :ref:`DriverLicensingConfigSpec fields <driver-licensing-spec>`.
       Required when deploying with NVIDIA vGPU.
     - None

   * - ``virtualTopology``
     - Virtual topology daemon configuration for NVIDIA vGPU drivers.
       Specify a ConfigMap name containing the ``nvidia-topologyd.conf`` configuration file.
     - None

   * - ``kernelModuleConfig``
     - Custom kernel module parameters for the NVIDIA driver.
       Specify a ConfigMap name containing kernel module configuration.
       Refer to :doc:`custom-driver-params`.
     - None


.. _driver-probe-spec:

ContainerProbeSpec Fields
==========================

Used by ``startupProbe``, ``livenessProbe``, and ``readinessProbe`` in the ``driver`` section.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``initialDelaySeconds``
     - Seconds to wait after the container starts before initiating probes.
     - ``0``

   * - ``timeoutSeconds``
     - Seconds after which a probe times out. Minimum value: ``1``.
     - ``1``

   * - ``periodSeconds``
     - How often (in seconds) to perform the probe. Minimum value: ``1``.
     - ``10``

   * - ``successThreshold``
     - Minimum consecutive successes for the probe to be considered successful. Minimum: ``1``.
     - ``1``

   * - ``failureThreshold``
     - Minimum consecutive failures before the probe is considered failed. Minimum: ``1``.
     - ``3``


.. _driver-manager-spec:

DriverManagerSpec Fields
=========================

Configures the Driver Manager init container that runs before the driver container to manage driver lifecycle (for example, unloading existing modules before an upgrade).

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``repository``
     - Registry path for the Driver Manager image.
     - Operator default.

   * - ``image``
     - Driver Manager image name.
     - ``k8s-driver-manager``

   * - ``version``
     - Driver Manager image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy for the Driver Manager image.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets for the Driver Manager registry.
     - None

   * - ``env``
     - Environment variables to set in the Driver Manager init container.
     - None


.. _driver-licensing-spec:

DriverLicensingConfigSpec Fields
==================================

Required for NVIDIA vGPU deployments to configure the license server.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``secretName``
     - Name of a Kubernetes Secret containing the NLS (NVIDIA Licensing System) client configuration token.
       Refer to :doc:`install-gpu-operator-vgpu`.
     - None

   * - ``configMapName``
     - Deprecated. Use ``secretName`` instead.
     - None

   * - ``nlsEnabled``
     - When ``true``, uses the NVIDIA Licensing System (NLS) for license management.
     - ``false``


*************************
spec.toolkit
*************************

Controls deployment of the NVIDIA Container Toolkit, which configures the container runtime
(containerd, CRI-O, or Docker) to support GPU-accelerated containers.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys the NVIDIA Container Toolkit.
       Set to ``false`` on systems where the NVIDIA Container Toolkit is pre-installed.
     - ``true``

   * - ``repository``
     - Registry path for the Container Toolkit image.
     - ``nvcr.io/nvidia/k8s``

   * - ``image``
     - Container Toolkit image name.
     - ``container-toolkit``

   * - ``version``
     - Container Toolkit image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``installDir``
     - Host path where the NVIDIA Container Toolkit installs its binaries.
     - ``/usr/local/nvidia``

   * - ``hostNetwork``
     - When ``true``, the Container Toolkit pod uses the host network namespace.
     - ``false``

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments for the Container Toolkit container.
     - None

   * - ``env``
     - Environment variables for the Container Toolkit container.
       Used to configure non-default container runtime socket paths or configuration locations.
       Refer to :doc:`getting-started` for examples.
     - None


*************************
spec.devicePlugin
*************************

Controls deployment of the NVIDIA Kubernetes Device Plugin, which advertises GPU resources to the Kubernetes scheduler.
For configuration options such as time-slicing, MPS, or MIG strategy, the Device Plugin is configured
through a ConfigMap. Refer to :doc:`gpu-sharing` and :doc:`gpu-operator-mig`.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys the NVIDIA Kubernetes Device Plugin.
     - ``true``

   * - ``repository``
     - Registry path for the Device Plugin image.
     - ``nvcr.io/nvidia``

   * - ``image``
     - Device Plugin image name.
     - ``k8s-device-plugin``

   * - ``version``
     - Device Plugin image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``hostNetwork``
     - When ``true``, the Device Plugin pod uses the host network namespace.
     - ``false``

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments for the Device Plugin container.
     - None

   * - ``env``
     - Environment variables for the Device Plugin container.
     - None

   * - ``config.name``
     - Name of the ConfigMap containing the Device Plugin configuration.
       The ConfigMap can contain multiple named configurations for different node types.
       Refer to :doc:`gpu-sharing` for configuring time-slicing and MPS.
     - None

   * - ``config.default``
     - The default configuration name within the ConfigMap to use when no specific configuration is selected.
     - None

   * - ``mps.root``
     - Host path to use as the MPS (Multi-Process Service) root directory.
       Relevant when using the Device Plugin in MPS mode.
     - ``/run/nvidia/mps``


*************************
spec.dcgmExporter
*************************

Controls deployment of the NVIDIA DCGM Exporter, which exposes GPU metrics in Prometheus format.
Refer to the `DCGM Exporter documentation <https://docs.nvidia.com/datacenter/cloud-native/gpu-telemetry/latest/dcgm-exporter.html>`_ for details on available metrics.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys the NVIDIA DCGM Exporter.
     - ``true``

   * - ``repository``
     - Registry path for the DCGM Exporter image.
     - ``nvcr.io/nvidia/k8s``

   * - ``image``
     - DCGM Exporter image name.
     - ``dcgm-exporter``

   * - ``version``
     - DCGM Exporter image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``hostNetwork``
     - When ``true``, the DCGM Exporter pod exposes its metrics port on the host network namespace.
     - ``false``

   * - ``hostPID``
     - When ``true``, the DCGM Exporter pod can access the host's PID namespace.
       Required for some per-process GPU metrics.
     - ``false``

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments for the DCGM Exporter container.
     - None

   * - ``env``
     - Environment variables for the DCGM Exporter container.
     - None

   * - ``config.name``
     - Name of the ConfigMap containing a custom ``dcgm-metrics.csv`` file.
       Use this to override the default set of metrics collected by DCGM Exporter.
     - None (uses default metric set)

   * - ``service.type``
     - Kubernetes Service type for the DCGM Exporter Service.
       Refer to the `Kubernetes Service documentation <https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types>`_.
     - ``ClusterIP``

   * - ``service.internalTrafficPolicy``
     - `Internal traffic policy <https://kubernetes.io/docs/concepts/services-networking/service/#traffic-policies>`_ for the DCGM Exporter Service.
       Use ``Local`` to limit metrics scraping to only the local node's DCGM Exporter.
     - ``Cluster``

   * - ``serviceMonitor.enabled``
     - When ``true``, deploys a Prometheus Operator ``ServiceMonitor`` resource for automatic metrics discovery.
       Requires the Prometheus Operator to be installed in the cluster.
     - ``false``

   * - ``serviceMonitor.interval``
     - How frequently Prometheus scrapes DCGM Exporter.
       If not specified, Prometheus uses its global scrape interval.
       Supported units: ``y``, ``w``, ``d``, ``h``, ``m``, ``s``, ``ms``.
     - Prometheus global scrape interval

   * - ``serviceMonitor.honorLabels``
     - When ``true``, the metric's own labels take precedence on collision with target labels.
     - ``false``

   * - ``serviceMonitor.additionalLabels``
     - Map of additional labels to add to the ``ServiceMonitor`` resource.
       Use these to match the label selectors of your Prometheus instance.
     - None

   * - ``serviceMonitor.relabelings``
     - List of Prometheus relabel configurations to rewrite labels on metric sets.
       Follows the Prometheus Operator ``RelabelConfig`` structure.
     - None

   * - ``hpcJobMapping.enabled``
     - When ``true``, enables HPC job mapping for DCGM Exporter.
       Allows correlating GPU metrics with HPC workload manager job IDs.
     - ``false``

   * - ``hpcJobMapping.directory``
     - Host directory path where HPC job mapping files are written by the workload manager.
     - ``/var/lib/dcgm-exporter/job-mapping``


*************************
spec.dcgm
*************************

Controls deployment of NVIDIA DCGM host engine as a standalone pod.
By default, DCGM runs as a sidecar in the DCGM Exporter pod.
Enabling the standalone DCGM pod can improve performance when multiple consumers
need to connect to the same DCGM host engine.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys NVIDIA DCGM host engine as a standalone pod.
     - ``true``

   * - ``repository``
     - Registry path for the DCGM image.
     - ``nvcr.io/nvidia/cloud-native``

   * - ``image``
     - DCGM image name.
     - ``dcgm``

   * - ``version``
     - DCGM image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``hostNetwork``
     - When ``true``, the DCGM pod uses the host network namespace.
     - ``false``

   * - ``hostPort``
     - Deprecated. Host port previously used for the DCGM engine.
     - N/A

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments.
     - None

   * - ``env``
     - Environment variables.
     - None


*************************
spec.nodeStatusExporter
*************************

Controls deployment of the Node Status Exporter, which reports GPU node status information to the Kubernetes API.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys the Node Status Exporter.
     - ``false``

   * - ``repository``
     - Registry path for the Node Status Exporter image.
     - ``nvcr.io/nvidia/cloud-native``

   * - ``image``
     - Node Status Exporter image name.
     - ``gpu-operator-validator``

   * - ``version``
     - Image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``hostNetwork``
     - When ``true``, the Node Status Exporter pod uses the host network namespace.
     - ``false``

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments.
     - None

   * - ``env``
     - Environment variables.
     - None


*************************
spec.gfd
*************************

Controls deployment of the NVIDIA GPU Feature Discovery (GFD) plugin, which labels Kubernetes nodes with GPU hardware properties
(such as GPU model, driver version, CUDA version, and MIG configuration).
Node Feature Discovery (NFD) must be deployed in the cluster for GFD to function.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys GPU Feature Discovery.
     - ``true``

   * - ``repository``
     - Registry path for the GFD image.
     - ``nvcr.io/nvidia``

   * - ``image``
     - GFD image name.
     - ``k8s-device-plugin``

   * - ``version``
     - GFD image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``hostNetwork``
     - When ``true``, the GFD pod uses the host network namespace.
     - ``false``

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments.
     - None

   * - ``env``
     - Environment variables.
     - None


*************************
spec.mig
*************************

Configures the MIG (Multi-Instance GPU) strategy.
Refer to :doc:`gpu-operator-mig` for complete MIG configuration guidance.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``strategy``
     - MIG strategy to use on MIG-capable GPUs (such as A100, H100).
       Accepted values:

       - ``none`` — MIG is not enabled. All GPU memory is exposed as a single resource.
       - ``single`` — All MIG instances on a node share the same MIG geometry.
         Only one ``nvidia.com/gpu`` resource type is advertised.
       - ``mixed`` — Nodes can have different MIG instance types.
         Individual MIG instance types are advertised as separate resources.
     - ``none``


*************************
spec.migManager
*************************

Controls deployment of the NVIDIA MIG Manager, which watches for MIG geometry changes
and automatically reconfigures nodes. The MIG Manager runs only on MIG-capable nodes.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys the NVIDIA MIG Manager.
       The MIG Manager only schedules on nodes with MIG-capable GPUs.
     - ``true``

   * - ``repository``
     - Registry path for the MIG Manager image.
     - ``nvcr.io/nvidia/cloud-native``

   * - ``image``
     - MIG Manager image name.
     - ``k8s-mig-manager``

   * - ``version``
     - MIG Manager image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``hostNetwork``
     - When ``true``, the MIG Manager pod uses the host network namespace.
     - ``false``

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments.
     - None

   * - ``env``
     - Environment variables.
     - None

   * - ``config.name``
     - Name of the ConfigMap containing the ``mig-parted`` MIG partition configuration.
       If not specified, MIG configuration is dynamically generated from the node's hardware.
     - None

   * - ``config.default``
     - Default MIG configuration to apply when a node has no ``nvidia.com/mig.config`` label.
       Accepted values: ``all-disabled``.
     - ``all-disabled``

   * - ``gpuClientsConfig.name``
     - Name of the ConfigMap listing GPU client processes that the MIG Manager should stop before reconfiguring MIG geometry.
     - None


*************************
spec.validator
*************************

Controls deployment of the NVIDIA GPU Operator Validator, which runs a series of tests
to confirm that each GPU Operator component is functioning correctly on each node.
The Validator runs as a DaemonSet and reports pass/fail status.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``repository``
     - Registry path for the Validator image.
     - ``nvcr.io/nvidia/cloud-native``

   * - ``image``
     - Validator image name.
     - ``gpu-operator-validator``

   * - ``version``
     - Validator image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``hostNetwork``
     - When ``true``, the Validator pod uses the host network namespace.
     - ``false``

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments.
     - None

   * - ``env``
     - Environment variables.
     - None

   * - ``plugin.env``
     - Environment variables specific to the Device Plugin validation step.
     - None

   * - ``toolkit.env``
     - Environment variables specific to the Container Toolkit validation step.
     - None

   * - ``driver.env``
     - Environment variables specific to the driver validation step.
     - None

   * - ``cuda.env``
     - Environment variables specific to the CUDA workload validation step.
     - None

   * - ``vfioPCI.env``
     - Environment variables specific to the VFIO-PCI device validation step.
     - None

   * - ``vgpuManager.env``
     - Environment variables specific to the vGPU Manager validation step.
     - None

   * - ``vgpuDevices.env``
     - Environment variables specific to the vGPU device validation step.
     - None


*************************
spec.gds
*************************

Controls deployment of the NVIDIA GPUDirect Storage (GDS) driver.
GDS enables direct DMA transfers between GPU memory and storage without CPU involvement.
This feature is experimental.

When using the ``NVIDIADriver`` CRD, configure GDS within the ``NVIDIADriver`` spec instead.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, enables GPUDirect Storage.
     - ``false``

   * - ``repository``
     - Registry path for the GDS driver image.
     - ``nvcr.io/nvidia/cloud-native``

   * - ``image``
     - GDS driver image name.
     - ``nvidia-fs``

   * - ``version``
     - GDS driver image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``args``
     - Additional arguments.
     - None

   * - ``env``
     - Environment variables.
     - None


*************************
spec.gdrcopy
*************************

Controls deployment of the NVIDIA GDRCopy driver (``gdrdrv`` kernel module), which enables
low-latency GPU-to-CPU memory copies using GPUDirect RDMA.
When using ``ClusterPolicy``-managed drivers, the GDRCopy driver runs as a sidecar in the driver pod.

When using the ``NVIDIADriver`` CRD, configure GDRCopy within the ``NVIDIADriver`` spec instead.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys the GDRCopy driver.
     - ``false``

   * - ``repository``
     - Registry path for the GDRCopy driver image.
     - ``nvcr.io/nvidia/cloud-native``

   * - ``image``
     - GDRCopy driver image name.
     - ``gdrdrv``

   * - ``version``
     - GDRCopy driver image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``args``
     - Additional arguments.
     - None

   * - ``env``
     - Environment variables.
     - None


*************************
spec.sandboxWorkloads
*************************

Controls support for sandbox-based GPU workloads such as KubeVirt virtual machines or Kata Containers.
When enabled, the Operator deploys additional components including the VFIO Manager, vGPU Manager (if applicable),
and sandbox-specific device plugins.

Refer to :doc:`gpu-operator-kubevirt` and :doc:`deploy-kata-containers` for deployment guides.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, enables sandbox workload support and deploys the additional required components.
     - ``false``

   * - ``defaultWorkload``
     - Default GPU workload type to configure on worker nodes.
       Accepted values:

       - ``container`` — Standard GPU containers.
       - ``vm-passthrough`` — GPU passthrough to virtual machines using VFIO-PCI.
       - ``vm-vgpu`` — vGPU virtualization.
     - ``container``

   * - ``mode``
     - Sandbox mode for sandboxed workloads.
       Accepted values:

       - ``kubevirt`` — KubeVirt-based virtual machines.
       - ``kata`` — Kata Containers-based sandboxes.
     - ``kubevirt``


*************************
spec.vfioManager
*************************

Controls deployment of the VFIO-PCI Manager, which binds GPU devices to the ``vfio-pci``
kernel driver to enable PCI passthrough to virtual machines.
Only deployed when ``sandboxWorkloads.enabled`` is ``true`` and ``sandboxWorkloads.mode`` is ``kubevirt``.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys the VFIO Manager.
     - ``false``

   * - ``repository``
     - Registry path for the VFIO Manager image.
     - ``nvcr.io/nvidia/cloud-native``

   * - ``image``
     - VFIO Manager image name.
     - ``vfio-manager``

   * - ``version``
     - VFIO Manager image version.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``hostNetwork``
     - When ``true``, the VFIO Manager pod uses the host network namespace.
     - ``false``

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments.
     - None

   * - ``env``
     - Environment variables.
     - None

   * - ``driverManager``
     - Driver Manager configuration for the VFIO Manager.
       See :ref:`DriverManagerSpec fields <driver-manager-spec>`.
     - Managed by the Operator.


*************************
spec.sandboxDevicePlugin
*************************

Controls deployment of the NVIDIA KubeVirt GPU Device Plugin, which advertises vGPU and GPU passthrough
devices to the Kubernetes scheduler for use by KubeVirt virtual machines.
Only deployed when ``sandboxWorkloads.enabled`` is ``true``.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys the KubeVirt GPU Device Plugin.
     - ``false``

   * - ``repository``
     - Registry path for the Sandbox Device Plugin image.
     - ``nvcr.io/nvidia``

   * - ``image``
     - Sandbox Device Plugin image name.
     - ``kubevirt-gpu-device-plugin``

   * - ``version``
     - Image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``hostNetwork``
     - When ``true``, the Sandbox Device Plugin pod uses the host network namespace.
     - ``false``

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments.
     - None

   * - ``env``
     - Environment variables.
     - None


*************************
spec.vgpuManager
*************************

Controls deployment of the NVIDIA vGPU Manager (vGPU host driver), which runs on the hypervisor node
and manages vGPU instances for virtual machines.
Only deployed when ``sandboxWorkloads.enabled`` is ``true``.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys the NVIDIA vGPU Manager.
     - ``false``

   * - ``repository``
     - Registry path for the vGPU Manager image.
     - Must be specified; images are not on NGC.

   * - ``image``
     - vGPU Manager image name.
     - Must be specified.

   * - ``version``
     - vGPU Manager image version. Must match the NVIDIA vGPU software version in use.
     - Must be specified.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets. Required if images are on a private registry.
     - None

   * - ``hostNetwork``
     - When ``true``, the vGPU Manager pod uses the host network namespace.
     - ``false``

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments.
     - None

   * - ``env``
     - Environment variables.
     - None

   * - ``kernelModuleConfig``
     - Custom kernel module parameters for the vGPU Manager.
     - None

   * - ``driverManager``
     - Driver Manager configuration.
       See :ref:`DriverManagerSpec fields <driver-manager-spec>`.
     - Managed by the Operator.


*************************
spec.vgpuDeviceManager
*************************

Controls deployment of the NVIDIA vGPU Device Manager, which manages vGPU device creation
on virtualization hosts.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys the NVIDIA vGPU Device Manager.
     - ``false``

   * - ``repository``
     - Registry path for the vGPU Device Manager image.
     - ``nvcr.io/nvidia/cloud-native``

   * - ``image``
     - vGPU Device Manager image name.
     - ``vgpu-device-manager``

   * - ``version``
     - vGPU Device Manager image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``hostNetwork``
     - When ``true``, the vGPU Device Manager pod uses the host network namespace.
     - ``false``

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments.
     - None

   * - ``env``
     - Environment variables.
     - None

   * - ``config.name``
     - Name of the ConfigMap containing the vGPU device configuration.
       The ConfigMap can contain multiple named configurations.
     - None

   * - ``config.default``
     - Default configuration name within the ConfigMap.
     - ``default``


*************************
spec.cdi
*************************

Configures how the Container Device Interface (CDI) is used in the cluster.
CDI is the default and recommended mechanism for exposing GPU devices to containers.
Refer to :doc:`cdi` for more information.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, the Container Toolkit uses CDI as the mechanism for making GPUs accessible to containers.
     - ``true``

   * - ``nriPluginEnabled``
     - When ``true``, deploys an NRI (Node Resource Interface) plugin as an additional mechanism
       for injecting CDI devices into GPU management containers.
       When enabled, you do not need to configure ``toolkit.env`` options for CDI injection.
     - ``false``

   * - ``default``
     - Deprecated as of v25.10.0. CDI is enabled by default and this field is ignored.
     - N/A


*************************
spec.kataManager
*************************

Controls deployment of the NVIDIA Kata Manager, which prepares NVIDIA-specific Kata runtime classes
on nodes for use with Kata Containers-based sandbox workloads.
Only deployed when ``sandboxWorkloads.enabled`` is ``true`` and ``sandboxWorkloads.mode`` is ``kata``.

Refer to :doc:`deploy-kata-containers` for deployment guidance.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys the Kata Manager.
     - ``false``

   * - ``config``
     - Kata Manager configuration specifying which kata runtime artifacts to use.
       Follows the ``Config`` structure from the `k8s-kata-manager <https://github.com/NVIDIA/k8s-kata-manager>`_ repository.
     - None

   * - ``repository``
     - Registry path for the Kata Manager image.
     - ``nvcr.io/nvidia/cloud-native``

   * - ``image``
     - Kata Manager image name.
     - ``k8s-kata-manager``

   * - ``version``
     - Kata Manager image version.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``hostNetwork``
     - When ``true``, the Kata Manager pod uses the host network namespace.
     - ``false``

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments.
     - None

   * - ``env``
     - Environment variables.
     - None


*************************
spec.ccManager
*************************

Controls deployment of the NVIDIA Confidential Computing Manager, which configures
the Confidential Computing (CC) mode on compatible GPUs (H100 and later).

Refer to :doc:`confidential-containers-deploy` for deployment guidance.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys the Confidential Computing Manager.
     - ``false``

   * - ``defaultMode``
     - Default Confidential Computing mode to apply to all CC-capable GPUs on each node.
       Accepted values:

       - ``off`` — CC mode disabled.
       - ``on`` — CC mode enabled.
       - ``devtools`` — CC mode enabled with DevTools access for debugging.
     - None

   * - ``repository``
     - Registry path for the CC Manager image.
     - ``nvcr.io/nvidia/cloud-native``

   * - ``image``
     - CC Manager image name.
     - ``k8s-cc-manager``

   * - ``version``
     - CC Manager image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``hostNetwork``
     - When ``true``, the CC Manager pod uses the host network namespace.
     - ``false``

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments.
     - None

   * - ``env``
     - Environment variables.
     - None


*****************************
spec.kataSandboxDevicePlugin
*****************************

Controls deployment of the NVIDIA Kata Sandbox Device Plugin, which advertises GPU devices
to the Kubernetes scheduler for use with Kata Containers-based sandbox workloads.
Deployed when ``sandboxWorkloads.enabled`` is ``true`` and ``sandboxWorkloads.mode`` is ``kata``.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, deploys the Kata Sandbox Device Plugin.
     - ``false``

   * - ``repository``
     - Registry path for the Kata Sandbox Device Plugin image.
     - ``nvcr.io/nvidia``

   * - ``image``
     - Kata Sandbox Device Plugin image name.
     - ``kata-gpu-sandbox-device-plugin``

   * - ``version``
     - Image version.
       Refer to the :ref:`operator-component-matrix`.
     - Version defined by the Operator release.

   * - ``imagePullPolicy``
     - Image pull policy.
     - ``IfNotPresent``

   * - ``imagePullSecrets``
     - Image pull secrets.
     - None

   * - ``hostNetwork``
     - When ``true``, the Kata Sandbox Device Plugin pod uses the host network namespace.
     - ``false``

   * - ``resources``
     - Resource requests and limits.
     - None

   * - ``args``
     - Additional arguments.
     - None

   * - ``env``
     - Environment variables.
     - None


*************************
spec.hostPaths
*************************

Defines custom host filesystem paths needed by GPU Operator components.
Override these only when your nodes use non-standard filesystem layouts.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``rootFS``
     - Path to the root filesystem of the host.
       Must be a chroot-able filesystem. Used by components that interact with the host OS directly
       (for example, MIG Manager and Container Toolkit when stopping or restarting systemd services).
     - ``/``

   * - ``driverInstallDir``
     - Root directory where the GPU driver files (libraries, executables, configuration) are installed.
       Override when using a custom driver install path.
     - ``/run/nvidia/driver``


*************************
spec.psa
*************************

Configures PodSecurityAdmission for GPU Operator pods.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Default

   * - ``enabled``
     - When ``true``, enables PodSecurityAdmission configuration for all GPU Operator pods.
     - ``false``


*****************************
ClusterPolicy Status Fields
*****************************

The Operator sets the following fields in ``ClusterPolicy.status``.

.. list-table::
   :header-rows: 1
   :widths: 25 55 20

   * - Field
     - Description
     - Values

   * - ``state``
     - Overall state of the ClusterPolicy.
     - ``ready``, ``notReady``, ``ignored``

   * - ``namespace``
     - Namespace in which the GPU Operator is installed.
     - Operator namespace string.

   * - ``conditions``
     - List of Kubernetes conditions describing the detailed state of the ClusterPolicy.
       Each condition has a ``Type``, ``Status``, ``Reason``, and ``Message``.
     - Standard Kubernetes condition list.

To check the ClusterPolicy status:

.. code-block:: console

   $ kubectl get clusterpolicy gpu-cluster-policy -o jsonpath='{.status}'
