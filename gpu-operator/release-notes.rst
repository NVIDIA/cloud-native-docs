.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
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

.. Date: July 30 2020
.. Author: pramarao

.. _operator-release-notes:

*****************************************
Release Notes
*****************************************

This document describes the new features, improvements, fixed and known issues for the NVIDIA GPU Operator.

See the :ref:`GPU Operator Component Matrix` for a list of components included in each release.

.. note::

   GPU Operator beta releases are documented on `GitHub <https://github.com/NVIDIA/gpu-operator/releases>`_. NVIDIA AI Enterprise builds are not posted on GitHub.

----

23.3.1
======

This release provides a packaging-only update to the 23.3.0 release to fix installation on Red Hat OpenShift Container Platform. Refer to GitHub `issue #513 <https://github.com/NVIDIA/gpu-operator/issues/513>`_. 

23.3.0
======


New Features
------------

* Added support for the NVIDIA Data Center GPU Driver version 525.105.17.
  Refer to the :ref:`GPU Operator Component Matrix`
  on the platform support page.

* Added support for GPUDirect Storage with Red Hat OpenShift Container Platform 4.11.
  Refer to :ref:`Support for GPUDirect Storage` on the platform support page.

* Added support for Canonical MicroK8s v1.26.
  Refer to :ref:`Supported Operating Systems and Kubernetes Platforms`
  on the platform support page.

* Added support for containerd v1.7.
  Refer to :ref:`Supported Container Runtimes`
  on the platform support page.

* Added support for Node Feature Discovery v0.12.1.
  This release adds support for using the NodeFeature API CRD for labelling nodes
  instead of labelling nodes over gRPC.
  The :ref:`documentation for upgrading the Operator manually <operator-upgrades>`
  is updated to include applying the custom resource definitions for Node Feature Discovery.

* Added support for running the NVIDIA GPU Operator in Amazon EKS and Google GKE.
  You must configure the cluster with custom nodes that run a supported operating
  system, such as Ubuntu 22.04.

* Added support for the Container Device Interface (CDI) that is implemented by the
  NVIDIA Container Toolkit v1.13.0.
  Refer to :ref:`gpu-operator-helm-chart-options` for information about the ``cdi.enable`` and
  ``cdi.default`` options to enable CDI during installation
  or :doc:`cdi` for post-installation configuration information.

* [Technology Preview] Added support for precompiled driver containers for select operating systems.
  This feature removes the dynamic dependencies to build the driver during installation in the
  cluster such as downloading kernel header packages and GCC tooling.
  Sites with isolated networks that cannot access the internet can benefit.
  Sites with machines that are resource constrained can also benefit by removing the computational demand
  to compile the driver.
  For more information, see :doc:`precompiled-drivers`.


Improvements
------------

* The upgrade process for the GPU driver is enhanced.
  This release introduces a ``maxUnavailable`` field that you can use to specify
  the number of nodes that can be unavailable during an upgrade.
  The value can be an integer or a string that specifies a percentage.
  If you specify a percentage, the number of nodes is calculated by rounding up.
  The default value is ``25%``.

  If you specify a value for ``maxUnavailable`` and also specify ``maxParallelUpgrades``,
  the ``maxUnavailable`` value applies an additional constraint on the value of
  ``maxParallelUpgrades`` to ensure that the number of parallel upgrades does not
  cause more than the intended number of nodes to become unavailable during the upgrade.
  For example, if you specify ``maxUnavailable=100%`` and ``maxParallelUpgrades=1``,
  one node at a time is upgraded.

* In previous releases, when you upgrade the GPU driver, the Operator validator
  pod could fail to complete all the validation checks.
  As a result, the node could remain in the validation required state indefinitely
  and prevent performing the driver upgrade on the other nodes in the cluster.
  This release adds a ``600`` second timeout for the validation process.
  If the validation does not complete successfully within the duration, the node is
  labelled ``upgrade-failed`` and the upgrade process proceeds on other nodes.

* The Multi-Instance GPU (MIG) manager is enhanced to support setting an initial
  value for the ``nvidia.com/mig.config`` node annotation.
  On nodes with MIG-capable GPUs that do not already have the annotation set, the
  value is set to ``all-disabled`` and the MIG manager does not create MIG devices.
  The value is overwritten when you label the node with a MIG profile.
  For configuration information, see :doc:`gpu-operator-mig`.


Fixed issues
------------

* Fixed an issue that prevented building the GPU driver container when a :ref:`Local Package Repository`
  is used.
  Previously, if you needed to provide CA certificates, the certificates were not installed correctly.
  The certificates are now installed in the correct directories.
  Refer to GitHub `issue #299 <https://github.com/NVIDIA/gpu-operator/issues/299>`_ for more details.

* Fixed an issue that created audit log records related to deprecated API requests for pod security policy.
  on Red Hat OpenShift Container Platform.
  Refer to GitHub `issue #451 <https://github.com/NVIDIA/gpu-operator/issues/451>`_
  and `issue #490 <https://github.com/NVIDIA/gpu-operator/issues/490>`_ for more details.

* Fixed an issue that caused the Operator to attempt to add a pod security policy on pre-release versions
  of Kubernetes v1.25.
  Refer to GitHub `issue #484 <https://github.com/NVIDIA/gpu-operator/issues/484>`_ for more details.

* Fixed a race condition that is related to preinstalled GPU drivers, validator pods, and the device plugin pods.
  The race condition can cause the device plugin pods to set the wrong path to the GPU driver.
  Refer to GitHub `issue #508 <https://github.com/NVIDIA/gpu-operator/issues/508>`_ for more details.

* Fixed an issue with the driver manager that prevented the manager from accurately detecting whether a
  node has preinstalled GPU drivers.
  This issue can appear if preinstalled GPU drivers were initially installed and later removed.
  The resolution is for the manager to check that the ``nvidia-smi`` file exists on the host
  and to check the output from executing the file.

* Fixed an issue that prevented adding custom annotations to daemon sets that the Operator starts.
  Refer to GitHub `issue #499 <https://github.com/NVIDIA/gpu-operator/issues/499>`_ for more details.

* Fixed an issue that is related to not starting the GPU Feature Discovery (GFD) pods when the DCGM Exporter
  service monitor is enabled, but a service monitor custom resource definition does not exist.
  Previously, there was no log record to describe why the GFD pods were not started.
  In this release, the Operator logs the error ``Couldn't find ServiceMonitor CRD`` and the
  message ``Install Prometheus and necessary CRDs for gathering GPU metrics`` to indicate
  the reason.

* Fixed a race condition that prevented the GPU driver containers from loading the nvidia-peermem Linux kernel module
  and caused the driver daemon set pods to crash loop back off.
  The condition could occur when both GPUDirect RDMA and GPUDirect Storage are enabled.
  In this release, the start script for the driver containers confirm that Operator validator
  indicates the driver container is ready before attempting to load the kernel module.

* Fixed an issue that caused upgrade of the GPU driver to fail when GPUDirect Storage is enabled.
  In this release, the driver manager unloads the nvidia-fs Linux kernel module before
  performing the upgrade.

* Added support for new MIG profiles with the 525 driver.

  * For A100-40GB devices:

    * ``1g.5gb.me``
    * ``1g.10gb``
    * ``4g.20gb``

  * For H100-80GB and A100-80GB devices:

    * ``1g.10gb``
    * ``1g.10gb.me``
    * ``1g.20gb``
    * ``4g.40gb``

  * For A30-24GB devices:

    * ``1g.6gb.me``
    * ``2g.12gb.me``

Common Vulnerabilities and Exposures (CVEs)
-------------------------------------------

The ``gpu-operator:v23.3.0`` and ``gpu-operator-validator:v23.3.0`` images have the following known high-vulnerability CVEs.
These CVEs are from the base images and are not in libraries that are used by the GPU operator:

* ``openssl-libs`` - `CVE-2023-0286 <https://access.redhat.com/security/cve/CVE-2023-0286>`_
* ``platform-python`` and ``python3-libs`` - `CVE-2023-24329 <https://access.redhat.com/security/cve/CVE-2023-24329>`_


Known Limitations
------------------

* Using NVIDIA vGPU on bare metal nodes and NVSwitch is not supported.
* When installing the Operator on Amazon EKS and using Kubernetes versions lower than
  ``1.25``, specify the ``--set psp.enabled=true`` Helm argument because EKS enables
  pod security policy (PSP).
  If you use Kubernetes version ``1.25`` or higher, do not specify the ``psp.enabled``
  argument so that the default value, ``false``, is used.
* All worker nodes within the Kubernetes cluster must use the same operating system version.
* NVIDIA GPUDirect Storage (GDS) is not supported with secure boot enabled systems.
* Driver Toolkit images are broken with Red Hat OpenShift version ``4.11.12`` and require cluster-level entitlements to be enabled
  in this case for the driver installation to succeed.
* The NVIDIA GPU Operator can only be used to deploy a single NVIDIA GPU Driver type and version. The NVIDIA vGPU and Data Center GPU Driver cannot be used within the same cluster.
* The ``nouveau`` driver must be blacklisted when using NVIDIA vGPU.
  Otherwise the driver fails to initialize the GPU with the error ``Failed to enable MSI-X`` in the system journal logs.
  Additionally, all GPU operator pods become stuck in the ``Init`` state.
* When using RHEL 8 with Kubernetes, SELinux must be enabled (either in permissive or enforcing mode) for use with the GPU Operator.
  Additionally, network-restricted environments are not supported.

----


22.9.2
======

New Features
------------

* Added support for Kubernetes v1.26 and Red Hat OpenShift 4.12.
  Refer to :doc:`platform-support` for more details.
* Added a new controller that is responsible for managing NVIDIA driver upgrades.
  Refer to :doc:`gpu-driver-upgrades` for more details.
* Added the ability to apply custom labels and annotations for all of the GPU Operator pods.
  Refer to :ref:`gpu-operator-helm-chart-options` for how to configure custom labels and annotations.
* Added support for NVIDIA vGPU 15.1.
  Refer to the `NVIDIA Virtual GPU Software Documentation <https://docs.nvidia.com/grid/15.0/index.html>`_.
* Added support for the NVIDIA HGX H100 System in the :ref:`Supported NVIDIA GPUs and Systems` table on the Platform Support page.
* Added 525.85.12 as the recommended driver version and 3.1.6 as the recommended DCGM version in the :ref:`GPU Operator Component Matrix`.
  These updates enable support for the NVIDIA HGX H100 System.

Improvements
------------

* Enhanced the driver validation logic to make sure that the current instance of the driver container has successfully finished installing drivers.
  This enhancement prevents other operands from incorrectly starting with previously loaded drivers.
* Increased overall driver startup probe timeout from 10 to 20 minutes.
  The increased timeout improves the installation experience for clusters with slow networks by avoiding unnecessary driver container restarts.

Fixed issues
------------

* Fixed an issue where containers allocated GPU lose access to them when systemd is triggered to run some reevaluation of the cgroups it manages.
  The issue affects systems using runc configured with systemd cgroups.
  Refer to Github `issue <https://github.com/NVIDIA/gpu-operator/issues/430>`_ for more details.
* Fixed an issue that prevented the GPU operator from applying PSA labels on the namespace when no prior labels existed.

Common Vulnerabilities and Exposures (CVEs)
-------------------------------------------

The ``gpu-operator:v22.9.2`` and ``gpu-operator:v22.9.2-ubi8`` images have the following known high-vulnerability CVEs.
These CVEs are from the base images and are not in libraries that are used by the GPU operator:

    * ``libksba`` - `CVE-2022-47629 <https://access.redhat.com/security/cve/CVE-2022-47629>`_

Known Limitations
------------------

* All worker nodes within the Kubernetes cluster must use the same operating system version.
* NVIDIA GPUDirect Storage (GDS) is not supported with secure boot enabled systems.
* Driver Toolkit images are broken with Red Hat OpenShift version ``4.11.12`` and require cluster-level entitlements to be enabled
  in this case for the driver installation to succeed.
* No support for newer MIG profiles ``1g.10gb``, ``1g.20gb``, ``2.12gb+me`` with R525 drivers.
* The NVIDIA GPU Operator can only be used to deploy a single NVIDIA GPU Driver type and version. The NVIDIA vGPU and Data Center GPU Driver cannot be used within the same cluster.
* The ``nouveau`` driver must be blacklisted when using NVIDIA vGPU.
  Otherwise the driver fails to initialize the GPU with the error ``Failed to enable MSI-X`` in the system journal logs.
  Additionally, all GPU operator pods become stuck in the ``Init`` state.
* When using RHEL 8 with Kubernetes, SELinux must be enabled (either in permissive or enforcing mode) for use with the GPU Operator.
  Additionally, network-restricted environments are not supported.

----

22.9.1
======

New Features
------------

* Support for CUDA 12.0 / R525 Data Center drivers on x86 / ARM servers.
* Support for RHEL 8.7 with Kubernetes and Containerd or CRI-O.
* Support for Ubuntu 20.4 and 22.04 with Kubernetes and CRI-O.
* Support for NVIDIA GPUDirect Storage using Ubuntu 20.04 and Ubuntu 22.04 with Kubernetes.
* Support for RTX 6000 ADA GPU
* Support for A800 GPU
* Support for vSphere 8.0 with Tanzu
* Support for vGPU 15.0
* Support for HPE Ezmeral Runtime Enterprise. Version 5.5 - with RHEL 8.4 and 8.5

Improvements
------------

* Added helm parameters to control operator logging levels and time encoding.
* When using CRI-O runtime with Kubernetes, it is no longer required to update the CRI-O config file to include ``/run/containers/oci/hooks.d`` as an additional path for OCI hooks. By default, the NVIDIA OCI runtime hook gets installed at ``/usr/share/containers/oci/hooks.d`` which is the default path configured with CRI-O.
* Allow per node configurations for NVIDIA Device Plugin using a custom ConfigMap and node label ``nvidia.com/device-plugin.config=<config-name>``.
* Support for `OnDelete <https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/#daemonset-update-strategy>`_ upgrade strategy for all Daemonsets deployed by the GPU Operator.
  This can be configured using ``daemonsets.upgradeStrategy`` parameter in the ``ClusterPolicy``. This prevents pods managed by the GPU Operator from being restarted automatically on spec updates.
* Enable eviction of GPU Pods only during driver container upgrades with ``ENABLE_GPU_POD_EVICTION`` env (default: "true") set under ``driver.manager.env`` in the ``ClusterPolicy``.
  This eliminates the requirement to drain the entire node currently.

Fixed issues
------------

* Fix repeated restarts of container-toolkit when used with containerd versions ``v1.6.9`` and above. Refer to Github `issue <https://github.com/NVIDIA/gpu-operator/issues/432>`_ for more details.
* Disable creation of PodSecurityPolicies (PSP) with K8s versions ``1.25`` and above as it is removed.

Common Vulnerabilities and Exposures (CVEs)
-------------------------------------------
* Fixed - Updated driver images for ``515.86.01``, ``510.108.03``, ``470.161.03``, ``450.216.04`` to address CVEs noted `here <https://nvidia.custhelp.com/app/answers/detail/a_id/5415>`_.
* The ``gpu-operator:v22.9.1`` and ``gpu-operator:v22.9.1-ubi8`` images have been released with the following known HIGH Vulnerability CVEs.
  These are from the base images and are not in libraries used by GPU Operator:
    * ``krb5-libs`` - `CVE-2022-42898 <https://nvd.nist.gov/vuln/detail/CVE-2022-42898>`_

Known Limitations
------------------

* All worker nodes within the Kubernetes cluster must use the same operating system version.
* NVIDIA GPUDirect Storage (GDS) is not supported with secure boot enabled systems.
* Driver Toolkit images are broken with Red Hat OpenShift version ``4.11.12`` and require cluster level entitlements to be enabled
  in this case for the driver installation to succeed.
* No support for newer MIG profiles ``1g.10gb``, ``1g.20gb``, ``2.12gb+me`` with R525 drivers. It will be added in the following release.
* The NVIDIA GPU Operator can only be used to deploy a single NVIDIA GPU Driver type and version. The NVIDIA vGPU and Data Center GPU Driver cannot be used within the same cluster.
* ``nouveau`` driver has to be blacklisted when using NVIDIA vGPU. Otherwise the driver will fail to initialize the GPU with the error ``Failed to enable MSI-X`` in the system journal logs and all GPU Operator pods will be stuck in ``Init`` state.
* When using RHEL8 with Kubernetes, SELinux has to be enabled (either in permissive or enforcing mode) for use with the GPU Operator. Additionally, network restricted environments are not supported.

22.9.0
======

New Features
------------

* Support for Hopper (H100) GPU with CUDA 11.8 / R520 Data Center drivers on x86 servers.
* Support for RHEL 8 with Kubernetes and Containerd or CRI-O.
* Support with Kubernetes 1.25.
* Support for RKE2 (Rancher Kubernetes Engine 2) with Ubuntu 20.04 and RHEL8.
* Support for GPUDirect RDMA with NVIDIA Network Operator 1.3.
* Support for Red Hat OpenShift with Cloud Service Providers (CSPs) Amazon AWS, Google GKE and Microsoft Azure.
* [General Availability] - Support for :ref:`KubeVirt and Red Hat OpenShift Virtualization with GPU Passthrough and NVIDIA vGPU based products<gpu-operator-kubevirt>`.
* [General Availability] - OCP and Upstream Kubernetes on ARM with :ref:`supported platforms<gpu-operator-arm-platforms>`.
* Support for `Pod Security Admission (PSA) <https://kubernetes.io/docs/concepts/security/pod-security-admission/>`_ through the ``psp.enabled`` flag. If enabled, the namespace where the operator is installed in will be labeled with the ``privileged`` pod security level.

Improvements
------------

* Support automatic upgrade and cleanup of ``clusterpolicies.nvidia.com`` CRD using Helm hooks. Refer to :ref:`Operator upgrades<operator-upgrades>` for more info.
* Support for dynamically enabling/disabling GFD, MIG Manager, DCGM and DCGM-Exporter.
* Switched to calendar versioning starting from this release for better life cycle management and support. Refer to :ref:`NVIDIA GPU Operator Versioning<operator-versioning>` for more info.

Fixed issues
------------

* Remove CUDA compat libs from the operator and all operand images to avoid mismatch with installed CUDA driver version. More info `here <https://github.com/NVIDIA/gpu-operator/issues/391>`_ and `here <https://github.com/NVIDIA/gpu-operator/issues/389>`_.
* Migrate to ``node.k8s.io/v1`` API for creation of ``RuntimeClass`` objects. More info `here <https://github.com/NVIDIA/gpu-operator/issues/409>`_.
* Remove PodSecurityPolicy (PSP) starting with Kubernetes v1.25. Setting ``psp.enabled`` will now enable Pod Security Admission (PSA) instead.

Known Limitations
------------------

* All worker nodes within the Kubernetes cluster must use the same operating system version.
* The NVIDIA GPU Operator can only be used to deploy a single NVIDIA GPU Driver type and version. The NVIDIA vGPU and Data Center GPU Driver cannot be used within the same cluster.
* ``nouveau`` driver has to be blacklisted when using NVIDIA vGPU. Otherwise the driver will fail to initialize the GPU with the error ``Failed to enable MSI-X`` in the system journal logs and all GPU Operator pods will be stuck in ``Init`` state.
* When using ``CRI-O`` runtime with Kubernetes, the config file ``/etc/crio/crio.conf`` has to include ``/run/containers/oci/hooks.d`` as path for ``hooks_dir``. Refer :ref:`here<custom-runtime-options>` for steps to configure this.
* When using RHEL8 with Kubernetes, SELinux has to be enabled (either in permissive or enforcing mode) for use with the GPU Operator. Additionally, network restricted environments are not supported.
* The ``gpu-operator:v22.9.0`` and ``gpu-operator:v22.9.0-ubi8`` images have been released with the following known HIGH Vulnerability CVEs.
  These are from the base images and are not in libraries used by GPU Operator:
    * ``expat`` - `CVE-2022-40674 <https://access.redhat.com/security/cve/CVE-2022-40674>`_
    * ``systemd-pam`` - `CVE-2022-2526 <https://access.redhat.com/security/cve/CVE-2022-2526>`_
    * ``systemd`` - `CVE-2022-2526 <https://access.redhat.com/security/cve/CVE-2022-2526>`_
    * ``systemd-libs`` - `CVE-2022-2526 <https://access.redhat.com/security/cve/CVE-2022-2526>`_

----

1.11.1
=====

Improvements
------------

* Added ``startupProbe`` to NVIDIA driver container to allow RollingUpgrades to progress to other nodes only after driver modules are successfully loaded on current one.
* Added support for ``driver.rollingUpdate.maxUnavailable`` parameter to specify maximum nodes for simultaneous driver upgrades. Default is 1.
* NVIDIA driver container will auto-disable itself on the node with pre-installed drivers by applying label ``nvidia.com/gpu.deploy.driver=pre-installed``. This is useful for heterogeneous clusters where only some GPU nodes have pre-installed drivers(e.g. DGX OS).

Fixed issues
------------

* Apply tolerations to ``cuda-validator`` and ``device-plugin-validator`` Pods based on ``deamonsets.tolerations`` in `ClusterPolicy`. For more info refer `here <https://github.com/NVIDIA/gpu-operator/issues/360>`_.
* Fixed an issue causing ``cuda-validator`` Pod to fail when ``accept-nvidia-visible-devices-envvar-when-unprivileged = false`` is set with NVIDIA Container Toolkit. For more info refer `here <https://github.com/NVIDIA/gpu-operator/issues/365>`_.
* Fixed an issue which caused recursive mounts under ``/run/nvidia/driver`` when both ``driver.rdma.enabled`` and ``driver.rdma.useHostMofed`` are set to ``true``. This caused other GPU Pods to fail to start.

----

1.11.0
======

New Features
------------

* Support for NVIDIA Data Center GPU Driver version ``515.48.07``.
* Support for NVIDIA AI Enterprise 2.1.
* Support for NVIDIA Virtual Compute Server 14.1 (vGPU).
* Support for Ubuntu 22.04 LTS.
* Support for secure boot with GPU Driver version 515 and Ubuntu Server 20.04 LTS and 22.04 LTS.
* Support for Kubernetes 1.24.
* Support for :ref:`Time-Slicing GPUs in Kubernetes<gpu-sharing>`.
* Support for Red Hat OpenShift on AWS, Azure and GCP instances. Refer to the Platform Support Matrix for the supported instances.
* Support for Red Hat Openshift 4.10 on AWS EC2 G5g instances(ARM).
* Support for Kubernetes 1.24 on AWS EC2 G5g instances(ARM).
* Support for use with the NVIDIA Network Operator 1.2.
* [Technical Preview] - Support for :ref:`KubeVirt and Red Hat OpenShift Virtualization with GPU Passthrough and NVIDIA vGPU based products<gpu-operator-kubevirt>`.
* [Technical Preview] - Kubernetes on ARM with Server Base System Architecture (SBSA).

Improvements
------------

* GPUDirect RDMA is now supported with CentOS using MOFED installed on the node.
* The NVIDIA vGPU Manager can now be upgraded to a newer branch while using an older, compatible guest driver.
* DGX A100 and non-DGX servers can now be used within the same cluster.
* Improved user interface while deploying a ClusterPolicy instance(CR) for the GPU Operator through Red Hat OpenShift Console.
* Improved the container-toolkit to handle v1 containerd configurations.

Fixed issues
------------

* Fix for incorrect reporting of ``DCGM_FI_DEV_FB_USED`` where reserved memory is reported as used memory. For more details refer to `GitHub issue <https://github.com/NVIDIA/gpu-operator/issues/348>`_.
* Fixed nvidia-peermem sidecar container to correctly load the ``nvidia-peermem`` module when MOFED is directly installed on the node.
* Fixed duplicate mounts of ``/run/mellanox/drivers`` within the driver container which caused driver cleanup or re-install to fail.
* Fixed uncordoning of the node with k8s-driver-manager whenever ENABLE_AUTO_DRAIN env is disabled.
* Fixed readiness check for MOFED driver installation by the NVIDIA Network Operator. This will avoid the GPU driver containers to be in ``CrashLoopBackOff`` while waiting for MOFED drivers to be ready.

Known Limitations
------------------

* All worker nodes within the Kubernetes cluster must use the same operating system version.
* The NVIDIA GPU Operator can only be used to deploy a single NVIDIA GPU Driver type and version. The NVIDIA vGPU and Data Center GPU Driver cannot be used within the same cluster.
* See the :ref:`limitations<gpu-operator-kubevirt-limitations>` sections for the [Technical Preview] of GPU Operator support for KubeVirt.
* The ``clusterpolicies.nvidia.com`` CRD has to be manually deleted after the GPU Operator is uninstalled using Helm.
* ``nouveau`` driver has to be blacklisted when using the NVIDIA vGPU. Otherwise the driver will fail to initialize the GPU with the error ``Failed to enable MSI-X`` in the system journal logs and all GPU Operator pods will be stuck in ``init`` state.
* The ``gpu-operator:v1.11.0`` and ``gpu-operator:v1.11.0-ubi8`` images have been released with the following known HIGH Vulnerability CVEs.
  These are from the base images and are not in libraries used by GPU Operator:
    * ``xz-libs`` - `CVE-2022-1271 <https://access.redhat.com/security/cve/CVE-2022-1271>`_


----

1.10.1
=====

Improvements
------------
* Validated secure boot with signed NVIDIA Data Center Driver R510.
* Validated cgroup v2 with Ubuntu Server 20.04 LTS.

Fixed issues
------------
* Fixed an issue when GPU Operator was installed and MIG was already enabled on a GPU. The GPU Operator will now install successfully and MIG can either be disabled via the label ``nvidia.com/mig.config=all-disabled`` or configured with the required MIG profiles.

Known Limitations
------------------

* The ``gpu-operator:v1.10.1`` and ``gpu-operator:v1.10.1-ubi8`` images have been released with the following known HIGH Vulnerability CVEs.
  These are from the base images and are not in libraries used by GPU Operator:
    * ``openssl-libs`` - `CVE-2022-0778 <https://access.redhat.com/security/cve/CVE-2022-0778>`_
    * ``zlib`` - `CVE-2018-25032 <https://access.redhat.com/security/cve/CVE-2018-25032>`_
    * ``gzip`` - `CVE-2022-1271 <https://access.redhat.com/security/cve/CVE-2022-1271>`_

----

1.10.0
=====

New Features
-------------
* Support for NVIDIA Data Center GPU Driver version `510.47.03`.
* Support NVIDIA A2, A100X and A30X
* Support for A100X and A30X on the DPU’s Arm processor.
* Support for secure boot with Ubuntu Server 20.04 and NVIDIA Data Center GPU Driver version R470.
* Support for Red Hat OpenShift 4.10.
* Support for GPUDirect RDMA with Red Hat OpenShift.
* Support for NVIDIA AI Enterprise 2.0.
* Support for NVIDIA Virtual Compute Server 14 (vGPU).

Improvements
------------
* Enabling/Disabling of GPU System Processor (GSP) Mode through NVIDIA driver module parameters.
* Ability to avoid deploying GPU Operator Operands on certain worker nodes through labels. Useful for running VMs with GPUs using KubeVirt.

Fixed issues
------------
* Increased lease duration of GPU Operator to 60s to avoid restarts during etcd defrag. More details `here <https://github.com/NVIDIA/gpu-operator/issues/326>`_.
* Avoid spurious alerts generated of type ``GPUOperatorOpenshiftDriverToolkitEnabledNfdTooOld`` on RedHat OpenShift when there are no GPU nodes in the cluster.
* Avoid uncordoning nodes during driver pod startup when ``ENABLE_AUTO_DRAIN`` is set to ``false``.
* Collection of GPU metrics in MIG mode is now supported with 470+ drivers.
* Fabric Manager (required for NVSwitch based systems) with CentOS 7 is now supported.


Known Limitations
------------------
* Upgrading to a new NVIDIA AI Enterprise major branch:
Upgrading the vGPU host driver to a newer major branch than the vGPU guest driver will result in GPU driver pod transitioning to a failed state. This happens for instance when the Host is upgraded to vGPU version 14.x while the Kubernetes nodes are still running with vGPU version 13.x.

To overcome this situation, before upgrading the host driver to the new vGPU branch, apply the following steps:

  #. kubectl edit clusterpolicy
  #. modify the policy and set the environment variable DISABLE_VGPU_VERSION_CHECK to true as shown below:

      .. code-block:: yaml

        driver:
          env:
          - name: DISABLE_VGPU_VERSION_CHECK
            value: "true"

  #. write and quit the clusterpolicy edit
* The ``gpu-operator:v1.10.0`` and ``gpu-operator:v1.10.0-ubi8`` images have been released with the following known HIGH Vulnerability CVEs.
  These are from the base images and are not in libraries used by GPU Operator:
    * ``openssl-libs`` - `CVE-2022-0778 <https://access.redhat.com/security/cve/CVE-2022-0778>`_

----

1.9.1
=====

Improvements
------------
* Improved logic in the driver container for waiting on MOFED driver readiness. This ensures that ``nvidia-peermem`` is built and installed correctly.

Fixed issues
------------
* Allow ``driver`` container to fallback to using cluster entitlements on Red Hat OpenShift on build failures. This issue exposed itself when using GPU Operator with some Red Hat OpenShift 4.8.z versions and Red Hat OpenShift 4.9.8. GPU Operator 1.9+ with Red Hat OpenShift 4.9.9+ doesn't require entitlements.
* Fixed an issue when DCGM-Exporter didn't work correctly with using the separate DCGM host engine that is part of the standalone DCGM pod. Fixed the issue and changed the default behavior to use the DCGM Host engine that is embedded in DCGM-Exporter. The standalone DCGM pod will not be launched by default but can be enabled for use with DGX A100.
* Update to latest Go vendor packages to avoid any CVE's.
* Fixed an issue to allow GPU Operator to work with ``CRI-O`` runtime on Kubernetes.
* Mount correct source path for Mellanox OFED 5.x drivers for enabling GPUDirect RDMA.

----

1.9.0
=====

New Features
-------------
* Support for NVIDIA Data Center GPU Driver version `470.82.01`.
* Support for DGX A100 with DGX OS 5.1+.
* Support for preinstalled GPU Driver with MIG Manager.
* Removed dependency to maintain active Red Hat OpenShift entitlements to build the GPU Driver. Introduce entitlement free driver builds starting with Red Hat OpenShift 4.9.9.
* Support for GPUDirect RDMA with preinstalled Mellanox OFED drivers.
* Support for GPU Operator and operands upgrades using Red Hat OpenShift Lifecycle Manager (OLM).
* Support for NVIDIA Virtual Compute Server 13.1 (vGPU).

Improvements
-------------
* Automatic detection of default runtime used in the cluster. Deprecate the operator.defaultRuntime parameter.
* GPU Operator and its operands are installed into a single user specified namespace.
* A loaded Nouveau driver is automatically detected and unloaded as part of the GPU Operator install.
* Added an option to mount a ConfigMap of self-signed certificates into the driver container. Enables SSL connections to private package repositories.

Fixed issues
------------
* Fixed an issue when DCGM Exporter was in CrashLoopBackOff as it could not connect to the DCGM port on the same node.

Known Limitations
------------------
* GPUDirect RDMA is only supported with R470 drivers on Ubuntu 20.04 LTS and is not supported on other distributions (e.g. CoreOS, CentOS etc.)
* The GPU Operator supports GPUDirect RDMA only in conjunction with the Network Operator. The Mellanox OFED drivers can be installed by the Network Operator or pre-installed on the host.
* Upgrades from v1.8.x to v1.9.x are not supported due to GPU Operator 1.9 installing the GPU Operator and its operands into a single namespace. Previous GPU Operator versions installed them into different namespaces. Upgrading to GPU Operator 1.9 requires uninstalling pre 1.9 GPU Operator versions prior to installing GPU Operator 1.9
* Collection of GPU metrics in MIG mode is not supported with 470+ drivers.
* The GPU Operator requires all MIG related configurations to be executed by MIG Manager. Enabling/Disabling MIG and other MIG related configurations directly on the host is discouraged.
* Fabric Manager (required for NVSwitch based systems) with CentOS 7 is not supported.
.. * See the :ref:`operator-known-limitations` at the bottom of this page.

----

1.8.2
=====

Fixed issues
------------
* Fixed an issue where Driver Daemonset was spuriously updated on RedHat OpenShift causing repeated restarts in Proxy environments.
* The MIG Manager version was bumped to `v0.1.3` to fix an issue when checking whether a GPU was in MIG mode or not.
  Previously, it would always check for MIG mode directly over the PCIe bus instead of using NVML. Now it checks with NVML when it can, only falling back to the PCIe bus when NVML is not available.
  Please refer to the `Release notes <https://github.com/NVIDIA/mig-parted/releases/tag/v0.1.3>`_  for a complete list of fixed issues.
* Container Toolkit bumped to version `v1.7.1` to fix an issue when using A100 80GB.

Improvements
-------------
* Added support for user-defined MIG partition configuration via a `ConfigMap`.

----

1.8.1
=====

Fixed issues
------------
* Fixed an issue with using the `NVIDIA License System <https://docs.nvidia.com/license-system/latest/>`_ in NVIDIA AI Enterprise deployments.

----

1.8.0
=====

New Features
-------------
* Support for NVIDIA Data Center GPU Driver version `470.57.02`.
* Added support for NVSwitch systems such as HGX A100. The driver container detects the presence of NVSwitches
  in the system and automatically deploys the `Fabric Manager <https://docs.nvidia.com/datacenter/tesla/pdf/fabric-manager-user-guide.pdf>`_
  for setting up the NVSwitch fabric.
* The driver container now builds and loads the ``nvidia-peermem`` kernel module when GPUDirect RDMA is enabled and Mellanox devices are present in the system.
  This allows the GPU Operator to complement the `NVIDIA Network Operator <https://github.com/Mellanox/network-operator>`_ to enable GPUDirect RDMA in the
  Kubernetes cluster. Refer to the :ref:`RDMA<operator-rdma>` documentation on getting started.

  .. note::

    This feature is available only when used with R470 drivers on Ubuntu 20.04 LTS.
* Added support for :ref:`upgrades<operator-upgrades>` of the GPU Operator components. A new ``k8s-driver-manager`` component handles upgrades
  of the NVIDIA drivers on nodes in the cluster.
* NVIDIA DCGM is now deployed as a component of the GPU Operator. The standalone DCGM container allows multiple clients such as
  `DCGM-Exporter <https://docs.nvidia.com/datacenter/cloud-native/gpu-telemetry/dcgm-exporter.html>`_ and `NVSM <http://docs.nvidia.com/datacenter/nvsm/nvsm-user-guide/index.html>`_
  to be deployed and connect to the existing DCGM container.
* Added a ``nodeStatusExporter`` component that exports operator and node metrics in a Prometheus format. The component provides
  information on the status of the operator (e.g. reconciliation status, number of GPU enabled nodes).

Improvements
-------------
* Reduced the size of the ClusterPolicy CRD by removing duplicates and redundant fields.
* The GPU Operator now supports detection of the virtual PCIe topology of the system and makes the topology available to
  vGPU drivers via a configuration file. The driver container starts the ``nvidia-topologyd`` daemon in vGPU configurations.
* Added support for specifying the ``RuntimeClass`` variable via Helm.
* Added ``nvidia-container-toolkit`` images to support CentOS 7 and CentOS 8.
* ``nvidia-container-toolkit`` now supports configuring `containerd` correctly for K3s.
* Added new debug options (logging, verbosity levels) for ``nvidia-container-toolkit``


Fixed issues
------------
* The driver container now loads ``ipmi_devintf`` by default. This allows tools such as ``ipmitool`` that rely on ``ipmi`` char devices
  to be created and available.

Known Limitations
------------------
* GPUDirect RDMA is only supported with R470 drivers on Ubuntu 20.04 LTS and is not supported on other distributions (e.g. CoreOS, CentOS etc.)
* The operator supports building and loading of ``nvidia-peermem`` only in conjunction with the Network Operator. Use with pre-installed MOFED drivers
  on the host is not supported. This capability will be added in a future release.
* Support for DGX A100 with GPU Operator 1.8 will be available in an upcoming patch release.
* This version of GPU Operator does not work well on RedHat OpenShift when a cluster-wide proxy is configured and causes constant restarts of driver container.
  This will be fixed in an upcoming patch release `v1.8.2`.
.. * See the :ref:`operator-known-limitations` at the bottom of this page.

----

1.7.1
=====

Fixed issues
------------
* NFD version bumped to `v0.8.2` to support correct kernel version labelling on Anthos nodes. See `NFD issue <https://github.com/kubernetes-sigs/node-feature-discovery/pull/402>`_ for more details.

----

1.7.0
=====

New Features
-------------
* Support for NVIDIA Data Center GPU Driver version `460.73.01`.
* Added support for automatic configuration of MIG geometry on NVIDIA Ampere products (e.g. A100) using the ``k8s-mig-manager``.
* GPU Operator can now be deployed on systems with pre-installed NVIDIA drivers and the NVIDIA Container Toolkit.
* DCGM-Exporter now supports telemetry for MIG devices on supported Ampere products (e.g. A100).
* Added support for a new ``nvidia`` ``RuntimeClass`` with `containerd`.
* The Operator now supports ``PodSecurityPolicies`` when enabled in the cluster.

Improvements
-------------
* Changed the label selector used by the DaemonSets of the different states of the GPU Operator. Instead of having a global
  label ``nvidia.com/gpu.present=true``, each DaemonSet now has its own label, ``nvidia.com/gpu.deploy.<state>=true``. This
  new behavior allows a finer grain of control over the components deployed on each of the GPU nodes.
* Migrated to using the latest operator-sdk for building the GPU Operator.
* The operator components are deployed with ``node-critical`` ``PriorityClass`` to minimize the possibility of eviction.
* Added a spec for the ``initContainer`` image, to allow flexibility to change the base images as required.
* Added the ability to configure the MIG strategy to be applied by the Operator.
* The driver container now auto-detects OpenShift/RHEL versions to better handle node/cluster upgrades.
* Validations of the container-toolkit and device-plugin installations are done on all GPU nodes in the cluster.
* Added an option to skip plugin validation workload pod during the Operator deployment.

Fixed issues
------------
* The ``gpu-operator-resources`` namespace is now created by the Operator so that they can be used by both Helm
  and OpenShift installations.

Known Limitations
------------------
* DCGM does not support profiling metrics on RTX 6000 and RTX 8000. Support will be added in a future release of DCGM Exporter.
* After un-install of GPU Operator, NVIDIA driver modules might still be loaded. Either reboot the node or forcefully remove them using
  ``sudo rmmod nvidia nvidia_modeset nvidia_uvm`` command before re-installing GPU Operator again.
* When MIG strategy of ``mixed`` is configured, device-plugin-validation may stay in ``Pending`` state due to incorrect GPU resource request type. User would need to
  modify the pod spec to apply correct resource type to match the MIG devices configured in the cluster.

----

1.6.2
=====

Fixed issues
------------
* Fixed an issue with NVIDIA Container Toolkit 1.4.6 which causes an error with containerd as ``Error while dialing dial unix /run/containerd/containerd.sock: connect: connection refused``. NVIDIA Container Toolkit 1.4.7 now sets ``version`` as an integer to fix this error.
* Fixed an issue with NVIDIA Container Toolkit which causes nvidia-container-runtime settings to be persistent across node reboot and causes driver pod to fail. Now nvidia-container-runtime will fallback to using ``runc`` when driver modules are not yet loaded during node reboot.
* GPU Operator now mounts runtime hook configuration for CRIO under ``/run/containers/oci/hooks.d``.

----

1.6.1
=====

Fixed issues
------------
* Fixed an issue with NVIDIA Container Toolkit 1.4.5 when used with containerd and an empty containerd configuration which file causes error ``Error while dialing dial unix /run/containerd/containerd.sock: connect: connection refused``. NVIDIA Container Toolkit 1.4.6 now explicitly sets the ``version=2`` along with other changes when the default containerd configuration file is empty.

----

1.6.0
=====

New Features
-------------
* Support for Red Hat OpenShift 4.7.
* Support for NVIDIA Data Center GPU Driver version `460.32.03`.
* Automatic injection of Proxy settings and custom CA certificates into driver container for Red Hat OpenShift.

DCGM-Exporter support includes the following:

* Updated DCGM to v2.1.4
* Increased reporting interval to 30s instead of 2s to reduce overhead
* Report NVIDIA vGPU licensing status and row-remapping metrics for Ampere GPUs

Improvements
-------------
* NVIDIA vGPU licensing configuration (gridd.conf) can be provided as a ConfigMap
* ClusterPolicy CRD has been updated from v1beta1 to v1. As a result minimum supported Kubernetes version is 1.16 from GPU Operator 1.6.0 onwards.

Fixed issues
------------
* Fixes for DCGM Exporter to work with CPU Manager.
* nvidia-gridd daemon logs are now collected on host by rsyslog.

Known Limitations
------------------
* DCGM does not support profiling metrics on RTX 6000 and RTX 8000. Support will be added in a future release of DCGM Exporter.
* After un-install of GPU Operator, NVIDIA driver modules might still be loaded. Either reboot the node or forcefully remove them using
  ``sudo rmmod nvidia nvidia_modeset nvidia_uvm`` command before re-installing GPU Operator again.
* When MIG strategy of ``mixed`` is configured, device-plugin-validation may stay in ``Pending`` state due to incorrect GPU resource request type. User would need to
  modify the pod spec to apply correct resource type to match the MIG devices configured in the cluster.
* ``gpu-operator-resources`` project in Red Hat OpenShift requires label ``openshift.io/cluster-monitoring=true`` for Prometheus to collect DCGM metrics. User will need to add this
  label manually when project is created.

----

1.5.2
=====

Improvements
-------------
* Allow ``mig.strategy=single`` on nodes with non-MIG GPUs.
* Pre-create MIG related ``nvcaps`` at startup.
* Updated device-plugin and toolkit validation to work with CPU Manager.

Fixed issues
------------
* Fixed issue which causes GFD pods to fail with error ``Failed to load NVML`` error even after driver is loaded.

----

1.5.1
=====

Improvements
-------------
* Kubelet's cgroup driver as ``systemd`` is now supported.

Fixed issues
------------
* Device-Plugin stuck in ``init`` phase on node reboot or when new node is added to the cluster.

----

1.5.0
=====

New Features
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
* The GPU Operator v1.5.x does not support mixed types of GPUs in the same cluster. All GPUs within a cluster need to be either NVIDIA vGPUs, GPU Passthrough GPUs or Bare Metal GPUs.
* GPU Operator v1.5.x with NVIDIA vGPUs support Turing and newer GPU architectures.
* DCGM does not support profiling metrics on RTX 6000 and RTX 8000. Support will be added in a future release of DCGM Exporter.
* After un-install of GPU Operator, NVIDIA driver modules might still be loaded. Either reboot the node or forcefully remove them using
  ``sudo rmmod nvidia nvidia_modeset nvidia_uvm`` command before re-installing GPU Operator again.
* When MIG strategy of ``mixed`` is configured, device-plugin-validation may stay in ``Pending`` state due to incorrect GPU resource request type. User would need to
  modify the pod spec to apply correct resource type to match the MIG devices configured in the cluster.
* ``gpu-operator-resources`` project in Red Hat OpenShift requires label ``openshift.io/cluster-monitoring=true`` for Prometheus to collect DCGM metrics. User will need to add this
  label manually when project is created.

----

1.4.0
=====

New Features
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
  that allow additional configuration of the plugin.
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
* After un-install of GPU Operator, NVIDIA driver modules might still be loaded. Either reboot the node or forcefully remove them using
  ``sudo rmmod nvidia nvidia_modeset nvidia_uvm`` command before re-installing GPU Operator again.

----

1.3.0
=====

New Features
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
* After un-install of GPU Operator, NVIDIA driver modules might still be loaded. Either reboot the node or forcefully remove them using
  ``sudo rmmod nvidia nvidia_modeset nvidia_uvm`` command before re-installing GPU Operator again.

----

1.2.0
=====

New Features
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
* After un-install of GPU Operator, NVIDIA driver modules might still be loaded. Either reboot the node or forcefully remove them using
  ``sudo rmmod nvidia nvidia_modeset nvidia_uvm`` command before re-installing GPU Operator again.

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

New Features
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

.. _operator-known-limitations:

Known Limitations
------------------

* After un-install of GPU Operator, NVIDIA driver modules might still be loaded. Either reboot the node or forcefully remove them using
  ``sudo rmmod nvidia nvidia_modeset nvidia_uvm`` command before re-installing GPU Operator again.
