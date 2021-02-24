.. Date: July 30 2020
.. Author: pramarao

.. _operator-release-notes:

*****************************************
Release Notes
*****************************************
This document describes the new features, improvements, fixed and known issues for the NVIDIA GPU Operator.

----

1.6.0
=====
This release of the GPU Operator includes the following components:

+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| Component                | Version       | Release Notes                                                                                         |
+==========================+===============+=======================================================================================================+
| NVIDIA Driver            | 460.32.03     | `Release Notes <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-460-32-03/index.html>`_  |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| NVIDIA Container Toolkit | 1.4.5         | `Release Notes <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_                        |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| NVIDIA K8s Device Plugin | 0.8.2         | `Release Notes <https://github.com/NVIDIA/k8s-device-plugin/releases>`_                               |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| NVIDIA DCGM-Exporter     | 2.2.0         | `Release Notes <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_                            |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| Node Feature Discovery   | 0.6.0         |                                                                                                       |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| GPU Feature Discovery    | 0.4.1         | `Release Notes <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_                           |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+

.. note::

  Driver version could be different with NVIDIA vGPU, as it depends on the driver version downloaded from the `NVIDIA vGPU Software Portal  <https://nvid.nvidia.com/dashboard/#/dashboard>`_.

New features
-------------
* Support for NVIDIA Data Center GPU Driver version `460.32.03`.
* Automatic injection of Proxy settings and custom CA certificates into driver container for Red Hat OpenShift.
* Support for Red Hat OpenShift 4.7.

DCGM-Exporter support includes the following:

* Updated DCGM to v2.1.4
* Increased reporting interval to 30s instead of 2s to reduce overhead
* Report NVIDIA vGPU licensing status and row-remapping metrics for Ampere GPUs

Improvements
-------------
* NVIDIA vGPU licensing configuration(gridd.conf) can be provided as a ConfigMap to driver component in operator.

Fixed issues
------------
* Fixes for DCGM Exporter to work with CPU Manager.
* nvidia-gridd daemon logs are now collected on host by rsyslog.

Known Limitations
------------------
See the :ref:`operator-known-limitations` at the bottom of this page.

----

1.5.2
=====
This release of the GPU Operator includes the following components:

+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| Component                | Version       | Release Notes                                                                                         |
+==========================+===============+=======================================================================================================+
| NVIDIA Driver            | 450.80.02     | `Release Notes <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-102-04/index.html>`_ |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| NVIDIA Container Toolkit | 1.4.4         | `Release Notes <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_                        |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| NVIDIA K8s Device Plugin | 0.8.1         | `Release Notes <https://github.com/NVIDIA/k8s-device-plugin/releases>`_                               |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| NVIDIA DCGM-Exporter     | 2.1.2         | `Release Notes <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_                            |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| Node Feature Discovery   | 0.6.0         |                                                                                                       |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| GPU Feature Discovery    | 0.4.0         | `Release Notes <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_                           |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+

.. note::

  Driver version could be different with NVIDIA vGPU, as it depends on the driver version downloaded from the `NVIDIA vGPU Software Portal  <https://nvid.nvidia.com/dashboard/#/dashboard>`_.

New features
-------------

Improvements
-------------
* Allow ``mig.strategy=single`` on nodes with non-MIG GPUs.
* Pre-create MIG related ``nvcaps`` at startup.
* Updated device-plugin and toolkit validation to work with CPU Manager.

Fixed issues
------------
* Fixed issue which causes GFD pods to fail with error ``Failed to load NVML`` error even after driver is loaded.

Known Limitations
------------------
See the :ref:`operator-known-limitations` at the bottom of this page.

----

1.5.1
=====
This release of the GPU Operator includes the following components:

+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| Component                | Version       | Release Notes                                                                                         |
+==========================+===============+=======================================================================================================+
| NVIDIA Driver            | 450.80.02     | `Release Notes <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-102-04/index.html>`_ |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| NVIDIA Container Toolkit | 1.4.3         | `Release Notes <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_                        |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| NVIDIA K8s Device Plugin | 0.7.3         | `Release Notes <https://github.com/NVIDIA/k8s-device-plugin/releases>`_                               |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| NVIDIA DCGM-Exporter     | 2.1.2         | `Release Notes <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_                            |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| Node Feature Discovery   | 0.6.0         |                                                                                                       |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| GPU Feature Discovery    | 0.3.0         | `Release Notes <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_                           |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+

.. note::

  Driver version could be different with NVIDIA vGPU, as it depends on the driver version downloaded from the `NVIDIA vGPU Software Portal  <https://nvid.nvidia.com/dashboard/#/dashboard>`_.

New features
-------------

Improvements
-------------
* Kubelet's cgroup driver as ``systemd`` is now supported.

Fixed issues
------------
* Device-Plugin stuck in ``init`` phase on node reboot or when new node is added to the cluster.

Known Limitations
------------------
See the :ref:`operator-known-limitations` at the bottom of this page.

----

1.5.0
=====
This release of the GPU Operator includes the following components:

+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| Component                | Version       | Release Notes                                                                                         |
+==========================+===============+=======================================================================================================+
| NVIDIA Driver            | 450.80.02     | `Release Notes <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-102-04/index.html>`_ |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| NVIDIA Container Toolkit | 1.4.2         | `Release Notes <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_                        |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| NVIDIA K8s Device Plugin | 0.7.3         | `Release Notes <https://github.com/NVIDIA/k8s-device-plugin/releases>`_                               |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| NVIDIA DCGM-Exporter     | 2.1.2         | `Release Notes <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_                            |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| Node Feature Discovery   | 0.6.0         |                                                                                                       |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+
| GPU Feature Discovery    | 0.3.0         | `Release Notes <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_                           |
+--------------------------+---------------+-------------------------------------------------------------------------------------------------------+

.. note::

  Driver version could be different with NVIDIA vGPU, as it depends on the version which user downloads from NVIDIA Software Portal.

New features
-------------
* Added support for NVIDIA vGPU

Improvements 
-------------
* Driver Validation container is run as an initContainer within device-plugin Daemonset pods. Thus driver installation on each NVIDIA GPU/vGPU node will be validated.
* GFD will label vGPU nodes with driver version and branch name of NVIDIA vGPU installed on Hypervisor.
* Driver container will perform automatic compatibility check of NVIDIA vGPU driver with the version installed on the underlying Hypervisor.

Fixed issues
------------
* GPU Operator will no longer crash when no GPU nodes are found.
* Container Toolkit pods wait for drivers to be loaded on the system before setting the default container runtime as `nvidia`.
* On host reboot, ordering of pods is maintained to ensure that drivers are always loaded first.
* Fixed device-plugin issue causing ``symbol lookup error: nvidia-device-plugin: undefined symbol: nvmlEventSetWait_v2`` error.

Known Limitations
------------------
See the :ref:`operator-known-limitations` at the bottom of this page.

----

1.4.0
=====
This release of the GPU Operator includes the following components:

+--------------------------+---------------+
| Component                | Version       |
+==========================+===============+
| NVIDIA Driver            | 450.80.02     |
+--------------------------+---------------+
| NVIDIA Container Toolkit | 1.4.0         |
+--------------------------+---------------+
| NVIDIA K8s Device Plugin | 0.7.1         |
+--------------------------+---------------+
| NVIDIA DCGM-Exporter     | 2.1.2         |
+--------------------------+---------------+
| Node Feature Discovery   | 0.6.0         |
+--------------------------+---------------+
| GPU Feature Discovery    | 0.2.2         |
+--------------------------+---------------+

New features
-------------
* Added support for CentOS 7 and 8.
  
  .. note::

    Due to a known limitation with the GPU Operator's default values on CentOS, install the operator on CentOS 7/8 
    using the following Helm command:

    .. code-block:: console

      $ helm install --wait --generate-name \
        nvidia/gpu-operator \
        --set toolkit.version=1.4.0-ubi8

    This issue will be fixed in the next release. 

* Added support for airgapped enterprise environments.
* Added support for ``containerd`` as a container runtime under Kubernetes.

Improvements 
-------------
* Updated DCGM-Exporter to ``2.1.2``, which uses DCGM 2.0.13.
* Added the ability to pass arguments to the NVIDIA device plugin to enable ``migStrategy`` and ``deviceListStrategy`` flags 
  that allow addtional configuration of the plugin.
* Added more resiliency to ``dcgm-exporter``- ``dcgm-exporter`` would not check whether GPUs support profiling metrics and would result in a ``CrashLoopBackOff`` 
  state at launch in these configurations.

Fixed issues
------------
* Fixed the issue where the removal of the GPU Operator from the cluster required a restart of the Docker daemon (since the Operator 
  sets the ``nvidia`` as the default runtime). 
* Fixed volume mounts for ``dcgm-exporter`` under the GPU Operator to allow pod<->device metrics attribution.
* Fixed an issue where the GFD and ``dcgm-exporter`` container images were artificially limited to R450+ (CUDA 11.0+) drivers.

Known Limitations
------------------
See the :ref:`operator-known-limitations` at the bottom of this page.

----

1.3.0
=====
This release of the GPU Operator includes the following components:

+--------------------------+---------------+
| Component                | Version       |
+==========================+===============+
| NVIDIA Driver            | 450.80.02     |
+--------------------------+---------------+
| NVIDIA Container Toolkit | 1.3.0         |
+--------------------------+---------------+
| NVIDIA K8s Device Plugin | 0.7.0         |
+--------------------------+---------------+
| NVIDIA DCGM-Exporter     | 2.1.0         |
+--------------------------+---------------+
| Node Feature Discovery   | 0.6.0         |
+--------------------------+---------------+
| GPU Feature Discovery    | 0.2.1         |
+--------------------------+---------------+

New features
-------------
* Integrated `GPU Feature Discovery <https://github.com/NVIDIA/gpu-feature-discovery>`_ to automatically generate labels for GPUs leveraging NFD.
* Added support for Red Hat OpenShift 4.4+ (i.e. 4.4.29+, 4.5 and 4.6). The GPU Operator can be deployed from OpenShift OperatorHub. See the catalog 
  `listing <https://catalog.redhat.com/software/operators/nvidia/gpu-operator/5ea882962937381642a232cd>`_ for more information.

Improvements 
-------------
* Updated DCGM-Exporter to ``2.1.0`` and added profiling metrics by default.
* Added further capabilities to configure tolerations, node affinity, node selectors, pod security context, resource requirements through the ``ClusterPolicy``.
* Optimized the footprint of the validation containers images - the image sizes are now down to ~200MB.
* Validation images are now configurable for air-gapped installations.

Fixed issues
------------
* Fixed the ordering of the state machine to ensure that the driver daemonset is deployed before the other components. This fix addresses the issue 
  where the NVIDIA container toolkit would be setup as the default runtime, causing the driver container initialization to fail.

Known Limitations
------------------
See the Known Limitations at the bottom of this page. 

----

1.2.0
=====
This release of the GPU Operator includes the following components:

+--------------------------+---------------+
| Component                | Version       |
+==========================+===============+
| NVIDIA Driver            | 450.80.02     |
+--------------------------+---------------+
| NVIDIA Container Toolkit | 1.3.0         |
+--------------------------+---------------+
| NVIDIA K8s Device Plugin | 0.7.0         |
+--------------------------+---------------+
| NVIDIA DCGM-Exporter     | 2.1.0-rc.2    |
+--------------------------+---------------+
| Node Feature Discovery   | 0.6.0         |
+--------------------------+---------------+

New features
-------------
* Added support for Ubuntu 20.04.z LTS. 
* Added support for the NVIDIA A100 GPU (and appropriate updates to the underlying components of the operator).

Improvements 
-------------
* Updated Node Feature Discovery (NFD) to 0.6.0.
* Container images are now hosted (and mirrored) on both `DockerHub <https://hub.docker.com/u/nvidiadocker.io>`_ and `NGC <https://ngc.nvidia.com/catalog/containers/nvidia:gpu-operator>`_. 

Fixed issues
------------
* Fixed an issue where the GPU operator would not correctly detect GPU nodes due to inconsistent PCIe node labels.
* Fixed a race condition where some of the NVIDIA pods would start out of order resulting in some pods in ``RunContainerError`` state.
* Fixed an issue in the driver container where the container would fail to install on systems with the ``linux-gke`` kernel due to not finding the kernel headers.

Known Limitations
------------------
See the Known Limitations at the bottom of this page. 

----

1.1.0
=====

This release of the GPU Operator includes the following components:

+--------------------------+---------------+
| Component                | Version       |
+==========================+===============+
| NVIDIA Driver            | 440.64.00     |
+--------------------------+---------------+
| NVIDIA Container Toolkit | 1.0.5         |
+--------------------------+---------------+
| NVIDIA K8s Device Plugin | 1.0.0-beta4   |
+--------------------------+---------------+
| NVIDIA DCGM-Exporter     | 1.7.2         |
+--------------------------+---------------+
| Node Feature Discovery   | 0.5.0         |
+--------------------------+---------------+

New features
-------------
* DCGM is now deployed as part of the GPU Operator on OpenShift 4.3.

Improvements 
-------------
* The operator CRD has been renamed to ``ClusterPolicy``.
* The operator image is now based on UBI8.
* Helm chart has been refactored to fix issues and follow some best practices.

Fixed issues
------------
* Fixed an issue with the toolkit container which would setup the NVIDIA runtime under ``/run/nvidia`` with a symlink to ``/usr/local/nvidia``. 
  If a node was rebooted, this would prevent any containers from being run with Docker as the container runtime configured in ``/etc/docker/daemon.json`` 
  would not be available after reboot.
* Fixed a race condition with the creation of the CRD and registration.

----

1.0.0
=====
New features
-------------
* Added support for Helm v3. Note that installing the GPU Operator using Helm v2 is no longer supported.
* Added support for Red Hat OpenShift 4 (4.1, 4.2 and 4.3) using Red Hat Enterprise Linux Core OS (RHCOS) and CRI-O runtime on GPU worker nodes.
* GPU Operator now deploys NVIDIA DCGM for GPU telemetry on Ubuntu 18.04 LTS

Fixed Issues 
-------------
* The driver container now sets up the required dependencies on ``i2c`` and ``ipmi_msghandler`` modules.
* Fixed an issue with the validation steps (for the driver and device plugin) taking considerable time. Node provisioning times are now improved by 5x.
* The SRO custom resource definition is setup as part of the operator.
* Fixed an issue with the clean up of driver mount files when deleting the operator from the cluster. This issue used to require a reboot of the node, which is no longer required.

----

.. _operator-known-limitations:

Known Limitations
=================

* The GPU Operator does not include `NVIDIA Fabric Manager <https://docs.nvidia.com/datacenter/tesla/fabric-manager-user-guide/index.html>`_ and 
  thus does not yet support systems that use the NVSwitch fabric (e.g. HGX, DGX-2 or DGX A100).
* GPU Operator will fail on nodes already setup with NVIDIA components (driver, runtime, device plugin). Support for better error handling will be added in a future release.
* The GPU Operator currently does not handle updates to the underlying software components (e.g. drivers) in an automated manner.
* The GPU Operator v1.5.x does not support mixed types of GPUs in the same cluster. All GPUs within a cluster need to be either NVIDIA vGPUs, GPU Passthrough GPUs or Bare Metal GPUs.
* GPU Operator v1.5.x with NVIDIA vGPUs support Turing and newer GPU architectures.
* DCGM does not support profiling metrics on RTX 6000 and RTX8000. Support will be added in a future release of DCGM Exporter.
* DCGM Exporter 2.0.13 does not report vGPU License Status correctly. Fix will be added to a future NVIDIA GPU Operator release.
* After un-install of GPU Operator, nvidia driver modules might still be loaded. User would need to either reboot the node or forcefully remove them using ``sudo rmmod nvidia nvidia_modeset nvidia_uvm`` command before re-installing GPU Operator again.
* When MIG strategy of ``mixed`` is configured, device-plugin-validation may stay in ``Pending`` state due to incorrect GPU resource request type. User would need to modify the pod spec to apply correct resource type to match the MIG devices configured in the cluster.

