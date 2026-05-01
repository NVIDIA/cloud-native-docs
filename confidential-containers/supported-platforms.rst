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

*******************
Supported Platforms
*******************

Following are the platforms supported by the NVIDIA Confidential Containers Reference Architecture.

Supported Hardware Platform
===========================

NVIDIA GPUs
-----------

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

   * - NVIDIA RTX Pro 6000 BSE
     - Single-GPU

.. note::

    Multi-GPU passthrough on NVIDIA Hopper HGX systems requires that you set the Confidential Computing mode to ``ppcie`` mode.
    Refer to :ref:`Managing the Confidential Computing Mode <managing-confidential-computing-mode>` in the deployment guide for details.

.. note::

    For both single and multi GPU Passthrough, all GPUs on the host must be configured for Confidential Computing and all GPUs must be assigned to one Confidential Container virtual machine.
    Configuring only some GPUs on a node for Confidential Computing is not supported.

CPU Platforms
-------------

.. flat-table::
   :header-rows: 1

   * - Category
     - Operating System
     - Kernel Version
   * - AMD Genoa / Milan
     - Ubuntu 25.10
     - 6.17+
   * - Intel Emerald Rapids (ER) /  Granite Rapids (GR)
     - Ubuntu 25.10
     - 6.17+

For additional information on node configuration, refer to the `Confidential Computing Deployment Guide <https://docs.nvidia.com/cc-deployment-guide-tdx-snp.pdf>`_ for information about supported NVIDIA GPUs, such as the NVIDIA Hopper H100.

The following topics in the deployment guide apply to a cloud-native environment:

* Hardware selection and initial hardware configuration, such as BIOS settings.
* Host operating system selection, initial configuration, and validation.

When following the cloud-native sections in the deployment guide linked above, use Ubuntu 25.10 as the host OS with its default kernel version and configuration.

For additional resources on machine setup:

* Refer to the `NVIDIA Trusted Computing Solutions website <https://docs.nvidia.com/nvtrust/index.html>`_.
* Refer to the :doc:`Licensing <licensing>` page for more information on the licensing requirements for NVIDIA Confidential Computing capabilities.

.. _coco-supported-software-components:

Supported Software Components
-----------------------------

.. flat-table::
   :header-rows: 1

   * - Component
     - Release/Version
   * - Guest OS
     - Distroless
   * - Guest kernel
     - 6.18.5
   * - `OVMF <https://github.com/tianocore/edk2>`__
     - edk2-stable202511
   * - `QEMU <https://www.qemu.org/>`__
     - 10.1 \+ Patches
   * - `Containerd <https://github.com/containerd/containerd>`__
     - 2.2.2
   * - `Kubernetes <https://kubernetes.io/>`__
     - 1.32 \+
   * - `NVIDIA GPU Operator <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html>`__ and its components.
       
       Refer to the :ref:`GPU Operator Component Matrix <gpuop:operator-component-matrix>` for the list of components and versions included in each release.
     - v26.3.1 and higher
   * - `Kata Containers <https://katacontainers.io/>`__
     - 3.29 (installed with ``kata-deploy`` Helm chart)
   * - `Key Broker Service (KBS) protocol <https://confidentialcontainers.org/docs/attestation/>`__
     - 0.4.0
   * - `Kata Lifecycle Manager <https://github.com/kata-containers/lifecycle-manager>`__
     - 0.1.4

Additionally, `Red Hat OpenShift Sandboxed Containers <https://docs.redhat.com/en/documentation/openshift_sandboxed_containers/1.12>`__ version 1.12 is supported as a Technology Preview and not supported in production environments.






