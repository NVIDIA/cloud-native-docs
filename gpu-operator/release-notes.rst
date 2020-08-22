.. Date: July 30 2020
.. Author: pramarao

.. _operator-release-notes:

*****************************************
Release Notes
*****************************************
This document describes the new features, improvements, fixed and known issues for the NVIDIA GPU Operator.

----

1.1.0
=====
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
* The driver container now sets up the required dependencies on i2c and ipmi_msghandler modules.
* Fixed an issue with the validation steps (for the driver and device plugin) taking considerable time. Node provisioning times are now improved by 5x.
* The SRO custom resource definition is setup as part of the operator.
* Fixed an issue with the clean up of driver mount files when deleting the operator from the cluster. This issue used to require a reboot of the node, which is no longer required.

Known Limitations
------------------
* After the removal of the GPU Operator, a restart of the Docker daemon is required as the default container runtime is setup to be the NVIDIA runtime. Run the following command:

.. code:: bash

   sudo systemctl restart docker

* GPU Operator will fail on nodes already setup with NVIDIA components (driver, runtime, device plugin). Support for better error handling will be added in a future release.
* The GPU Operator currently does not handle updates to the underlying software components (e.g. drivers) in an automated manner.
* This release of the operator does not support accessing images from private registries, which may be required for air-gapped deployments.
