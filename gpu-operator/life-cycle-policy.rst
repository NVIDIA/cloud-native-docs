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

.. headings # #, * *, =, -, ^, "

.. Date: September 25 2022
.. Author: ebohnhorst


.. _operator-versioning:

******************************
NVIDIA GPU Operator Versioning
******************************

NVIDIA GPU Operator is versioned following the calendar versioning convention.

The version follows the pattern ``YY.MM.PP``, such as 23.6.0, 23.6.1, and 23.9.0.
The first two fields, ``YY.MM`` identify a major version and indicates when the major version was initially released.
The third field, ``PP``, identifies the patch version of the major version.
Patch releases typically include critical bug and CVE fixes, but can include minor features.

.. _operator_life_cycle_policy:

******************************
NVIDIA GPU Operator Life Cycle
******************************

When a major version of NVIDIA GPU Operator is released, the previous major version enters maintenance support
and only receives patch release updates for critical bug and CVE fixes.
All prior major versions enter end-of-life (EOL) and are no longer supported and do not receive patch release updates.

The product life cycle and versioning are subject to change in the future.

.. note::

    - Upgrades are only supported within a major release or to the next major release.

.. list-table:: Support Status for Releases
   :header-rows: 1

   * - GPU Operator Version
     - Status

   * - 25.3.x
     - Generally Available

   * - 24.9.x
     - Maintenance

   * - 24.6.x and lower
     - EOL


.. _operator-component-matrix:

*****************************
GPU Operator Component Matrix
*****************************

.. _gds: #gds-open-kernel
.. |gds| replace:: :sup:`1`

The following table shows the operands and default operand versions that correspond to a GPU Operator version.

When post-release testing confirms support for newer versions of operands, these updates are identified as *recommended updates* to a GPU Operator version.
Refer to :ref:`Upgrading the NVIDIA GPU Operator` for more information.

.. list-table::
   :header-rows: 1

   * - Component
     - Version

   * - NVIDIA GPU Operator
     - ${version}

   * - NVIDIA GPU Driver
     - | `570.124.06 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-124-06/index.html>`_ (default, recommended),
       | `570.86.15 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-86-15/index.html>`_ 

   * - NVIDIA Driver Manager for Kubernetes
     - `v0.8.0 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`__

   * - NVIDIA Container Toolkit
     - `1.17.4 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`__

   * - NVIDIA Kubernetes Device Plugin
     - `0.17.1 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__

   * - DCGM Exporter
     - `4.1.1-4.0.4 <https://github.com/NVIDIA/dcgm-exporter/releases>`__

   * - Node Feature Discovery
     - `v0.17.2 <https://github.com/kubernetes-sigs/node-feature-discovery/releases/>`__

   * - | NVIDIA GPU Feature Discovery
       | for Kubernetes
     - `0.17.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__

   * - NVIDIA MIG Manager for Kubernetes
     - `0.12.0 <https://github.com/NVIDIA/mig-parted/tree/main/deployments/gpu-operator>`__

   * - DCGM
     - `4.1.1-2 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`__

   * - Validator for NVIDIA GPU Operator
     - ${version}

   * - NVIDIA KubeVirt GPU Device Plugin
     - `v1.3.1 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`__

   * - NVIDIA vGPU Device Manager
     - `v0.3.0 <https://github.com/NVIDIA/vgpu-device-manager>`__

   * - NVIDIA GDS Driver |gds|_
     - `2.20.5 <https://github.com/NVIDIA/gds-nvidia-fs/releases>`__

   * - NVIDIA Kata Manager for Kubernetes
     - `v0.2.3 <https://github.com/NVIDIA/k8s-kata-manager>`__

   * - | NVIDIA Confidential Computing
       | Manager for Kubernetes
     - v0.1.1

   * - NVIDIA GDRCopy Driver
     - `v2.4.4 <https://github.com/NVIDIA/gdrcopy/releases>`__

.. _gds-open-kernel:

   :sup:`1`
   This release of the GDS driver requires that you use the NVIDIA Open GPU Kernel module driver for the GPUs.
   Refer to :doc:`gpu-operator-rdma` for more information.

.. note::

   - Driver version could be different with NVIDIA vGPU, as it depends on the driver
     version downloaded from the `NVIDIA vGPU Software Portal  <https://nvid.nvidia.com/dashboard/#/dashboard>`_.
   - The GPU Operator is supported on all active NVIDIA data center production drivers.
     Refer to `Supported Drivers and CUDA Toolkit Versions <https://docs.nvidia.com/datacenter/tesla/drivers/index.html#cuda-drivers>`_
     for more information.