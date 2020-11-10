.. Date: July 30 2020
.. Author: pramarao

.. _operator-release-notes:

*****************************************
Release Notes
*****************************************
This document describes the new features, improvements, fixed and known issues for the NVIDIA GPU Operator.

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

Known Limitations
------------------
* After the removal of the GPU Operator, a restart of the Docker daemon is required as the default container runtime is setup to be the NVIDIA runtime. Run the following command:

.. code-block:: console

  $ sudo systemctl restart docker

* GPU Operator will fail on nodes already setup with NVIDIA components (driver, runtime, device plugin). Support for better error handling will be added in a future release.
* The GPU Operator currently does not handle updates to the underlying software components (e.g. drivers) in an automated manner.
* This release of the operator does not support accessing images from private registries, which may be required for air-gapped deployments.
