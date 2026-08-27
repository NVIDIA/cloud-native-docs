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

.. headings # #, * *, =, -, ^, "

.. _coco-supported-platforms:

###################
Supported Platforms
###################

Following are the platforms supported by the NVIDIA Confidential Containers Reference Architecture.

This page is relevant to the following users:

* The :ref:`Hardware IT Administrator <coco-persona-hardware-it-administrator>` uses the hardware tables to confirm that the selected CPU and GPU are validated for Confidential Computing before configuring the system.
* The :ref:`Host OS Administrator <coco-persona-host-os-administrator>` uses the hardware tables to confirm validated host OS and kernel versions.
* The :ref:`Kubernetes Cluster Administrator <coco-persona-kubernetes-cluster-administrator>` uses the component matrix to confirm supported versions.

********
Hardware
********

NVIDIA GPUs
===========

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - GPU
     - Passthrough

   * - NVIDIA H100
     - Single-GPU

   * - NVIDIA H200
     - Single-GPU

   * - NVIDIA H100 Protected PCIe (PPCIe)
     - Multi-GPU

   * - NVIDIA H200 Protected PCIe (PPCIe)
     - Multi-GPU

   * - NVIDIA B200
     - Single-GPU, Multi-GPU

   * - NVIDIA HGX B300
     - Single-GPU, Multi-GPU

   * - NVIDIA RTX Pro 6000 BSE
     - Single-GPU

.. note::

    :ref:`Multi-GPU passthrough <coco-multi-gpu-passthrough>` on NVIDIA Hopper HGX systems requires that you set the Confidential Computing mode to ``ppcie`` mode.
    Refer to :doc:`Managing the Confidential Computing Mode <configure-cc-mode>` for details.

.. note::

    For both single and multi GPU Passthrough, all GPUs on the host must be configured for Confidential Computing and all GPUs must be assigned to one Confidential Container virtual machine.
    Configuring only some GPUs on a node for Confidential Computing is not supported.

Host Platforms
==============

.. flat-table::
   :header-rows: 1

   * - CPU Platform
     - TEE
     - Host Operating System
     - Host Kernel Version
   * - AMD Genoa / Milan
     - AMD SEV-SNP
     - Ubuntu 25.10 or 26.04
     - 6.17+
   * - Intel Emerald Rapids (ER) /  Granite Rapids (GR)
     - Intel TDX
     - Ubuntu 25.10 or 26.04
     - 6.17+

For additional information on node configuration, refer to the `Confidential Computing Deployment Guide <https://docs.nvidia.com/cc-deployment-guide-tdx-snp.pdf>`_ for information about supported NVIDIA GPUs, such as the NVIDIA Hopper H100.

The following topics in the deployment guide apply to a cloud-native environment:

* Hardware selection and initial hardware configuration, such as BIOS settings.
* Host operating system selection, initial configuration, and validation.

When following the cloud-native sections in the deployment guide linked above, use Ubuntu 25.10 or 26.04 as the host OS with its default kernel version and configuration.

For additional resources on machine setup:

* Refer to the `NVIDIA Trusted Computing Solutions website <https://docs.nvidia.com/nvtrust/index.html>`_.
* Refer to the :doc:`Licensing <licensing>` page for more information on the licensing requirements for NVIDIA Confidential Computing capabilities.

.. _coco-supported-software-components:


*****************************
Supported Software Components
*****************************

Cluster and Deployment Software
================================

The installation guides begin with an existing Kubernetes cluster that uses ``containerd``.
You then install Kata Containers and the NVIDIA GPU Operator.

.. flat-table::
   :header-rows: 1

   * - Component
     - Release/Version
     - Installation
   * - `Kubernetes <https://kubernetes.io/>`__
     - 1.32 \+
     - Prerequisite, must already be installed on the cluster hosts.
   * - `containerd <https://github.com/containerd/containerd>`__
     - 2.3.x
     - Prerequisite, must already be installed on the cluster hosts.
   * - `Kata Containers <https://katacontainers.io/>`__
     - ${kata_version}
     - Installed with the ``kata-deploy`` Helm chart by following the :doc:`Quickstart Install <install-quickstart>` or :doc:`Detailed Install Guide <confidential-containers-deploy>`.
   * - `NVIDIA GPU Operator <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html>`__ and its components.

       Refer to the :ref:`GPU Operator Component Matrix <gpuop:operator-component-matrix>` for the list of components and versions included in each release.
     - ${gpu_operator_version} and higher
     - Installed by following the :doc:`Quickstart Install <install-quickstart>` or :doc:`Detailed Install Guide <confidential-containers-deploy>`.

Kata-provided Guest and Runtime Artifacts
=========================================

The supported ``kata-deploy`` Helm chart installs the guest OS, guest kernel, OVMF, and QEMU artifacts listed in the following table as part of Kata Containers.
You do not supply or install these artifacts individually.

.. flat-table::
   :header-rows: 1

   * - Artifact
     - Release/Version
   * - Guest OS
     - Distroless
   * - Guest kernel
     - 6.18.5
   * - `OVMF <https://github.com/tianocore/edk2>`__
     - edk2-stable202511
   * - `QEMU <https://www.qemu.org/>`__
     - 10.1 \+ Patches

Separately Deployed Components and Interfaces
=============================================

The following components and interfaces are not installed by the :doc:`Quickstart Install <install-quickstart>` or :doc:`Detailed Install Guide <confidential-containers-deploy>`.

.. flat-table::
   :header-rows: 1

   * - Interface or Component
     - Version
     - When It Is Needed
     - How It Is Provided
   * - `Key Broker Service (KBS) protocol <https://confidentialcontainers.org/docs/attestation/>`__
     - 0.4.0
     - Required for Trustee-based attestation and secret or key release.
     - The :doc:`Attestation <attestation>` quickstart installs a local evaluation Trustee.
       Deploy a production Trustee separately by following the upstream Confidential Containers documentation.
   * - `Kata Lifecycle Manager <https://github.com/kata-containers/lifecycle-manager>`__
     - 0.1.8
     - Optional for Kata Containers upgrades and day-two lifecycle management.
     - Install separately by following the upstream Kata Lifecycle Manager documentation.
   * - `Kata Containers genpolicy <https://github.com/kata-containers/kata-containers/blob/${kata_version}/src/tools/genpolicy/README.md>`__
     - ${kata_version}
     - Used to generate an agent security policy for attested production workloads.
     - Download separately from the corresponding Kata Containers release.

Users may leverage `Red Hat OpenShift Sandboxed Containers <https://docs.redhat.com/en/documentation/openshift_sandboxed_containers/1.13>`__ to deploy Confidential Containers.
