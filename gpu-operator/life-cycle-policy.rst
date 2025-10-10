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

   * - 24.9.x
     - Generally Available

   * - 24.6.x
     - Maintenance

   * - 24.3.x and lower
     - EOL


.. _operator-component-matrix:

*****************************
GPU Operator Component Matrix
*****************************

.. _ki: #known-issue
.. |ki| replace:: :sup:`1`

The following table shows the operands and default operand versions that correspond to a GPU Operator version.

When post-release testing confirms support for newer versions of operands, these updates are identified as *recommended updates* to a GPU Operator version.
Refer to :ref:`Upgrading the NVIDIA GPU Operator` for more information.

.. list-table::
   :header-rows: 1

   * - Component
     - | GPU Operator
       | v24.9.2
     - | GPU Operator
       | v24.9.1
     - | GPU Operator
       | v24.9.0

   * - NVIDIA GPU Driver
     - | `580.65.06 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-65-06/index.html>`_ (rec.)
       | `575.57.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-575-57-08/index.html>`_
       | `570.172.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-172-08/index.html>`_ 
       | `570.158.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-158-01/index.html>`_
       | `570.148.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-148-08/index.html>`_
       | `570.133.20 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-133-20/index.html>`_ 
       | `570.86.15 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-86-15/index.html>`_ 
       | `565.57.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-565-57-01/index.html>`_
       | `560.35.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-560-35-03/index.html>`_
       | `550.163.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-550-163-01/index.html>`_
       | `550.144.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-550-144-03/index.html>`_ (default)
       | `550.127.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-550-127-08/index.html>`_
       | `535.261.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-261-03/index.html>`_
       | `535.247.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-247-01/index.html>`_
       | `535.230.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-230-02/index.html>`_
       | `535.216.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-216-03/index.html>`_
     - | `565.57.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-565-57-01/index.html>`_
       | `560.35.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-560-35-03/index.html>`_
       | `550.144.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-550-144-03/index.html>`_ (rec.)
       | `550.127.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-550-127-08/index.html>`_ (default)
       | `535.230.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-230-02/index.html>`_
       | `535.216.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-216-03/index.html>`_
     - | `565.57.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-565-57-01/index.html>`_
       | `560.35.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-560-35-03/index.html>`_
       | `550.127.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-550-127-08/index.html>`_ (rec.)
       | `550.127.05 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-550-127-05/index.html>`_ (default)
       | `535.216.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-216-03/index.html>`_

   * - NVIDIA Driver Manager for Kubernetes
     - `v0.7.0 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`__
     - `v0.7.0 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`__
     - `v0.7.0 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`__

   * - NVIDIA Container Toolkit
     - `1.17.4 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`__
     - `1.17.3 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`__
     - `1.17.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`__

   * - NVIDIA Kubernetes Device Plugin
     - `0.17.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__
     - `0.17.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__
     - `0.17.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__

   * - DCGM Exporter
     - `3.3.9-3.6.1 <https://github.com/NVIDIA/dcgm-exporter/releases>`__
     - `3.3.9-3.6.1 <https://github.com/NVIDIA/dcgm-exporter/releases>`__
     - `3.3.8-3.6.0 <https://github.com/NVIDIA/dcgm-exporter/releases>`__

   * - Node Feature Discovery
     - v0.16.6
     - v0.16.6
     - v0.16.6

   * - | NVIDIA GPU Feature Discovery
       | for Kubernetes
     - `0.17.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__
     - `0.17.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__
     - `0.17.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__

   * - NVIDIA MIG Manager for Kubernetes
     - `0.10.0 <https://github.com/NVIDIA/mig-parted/tree/main/deployments/gpu-operator>`__
     - `0.10.0 <https://github.com/NVIDIA/mig-parted/tree/main/deployments/gpu-operator>`__
     - `0.10.0 <https://github.com/NVIDIA/mig-parted/tree/main/deployments/gpu-operator>`__

   * - DCGM
     - `3.3.9-1 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`__
     - `3.3.9-1 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`__
     - `3.3.8-1 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`__

   * - Validator for NVIDIA GPU Operator
     - v24.9.2
     - v24.9.1
     - v24.9.0

   * - NVIDIA KubeVirt GPU Device Plugin
     - `v1.2.10 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`__
     - `v1.2.10 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`__
     - `v1.2.10 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`__

   * - NVIDIA vGPU Device Manager
     - `v0.2.8 <https://github.com/NVIDIA/vgpu-device-manager>`__
     - `v0.2.8 <https://github.com/NVIDIA/vgpu-device-manager>`__
     - `v0.2.8 <https://github.com/NVIDIA/vgpu-device-manager>`__

   * - NVIDIA GDS Driver 
     - `2.20.5 <https://github.com/NVIDIA/gds-nvidia-fs/releases>`__
     - `2.20.5 <https://github.com/NVIDIA/gds-nvidia-fs/releases>`__
     - `2.20.5 <https://github.com/NVIDIA/gds-nvidia-fs/releases>`__

   * - NVIDIA Kata Manager for Kubernetes
     - `v0.2.2 <https://github.com/NVIDIA/k8s-kata-manager>`__
     - `v0.2.2 <https://github.com/NVIDIA/k8s-kata-manager>`__
     - `v0.2.2 <https://github.com/NVIDIA/k8s-kata-manager>`__

   * - | NVIDIA Confidential Computing
       | Manager for Kubernetes
     - v0.1.1
     - v0.1.1
     - v0.1.1

   * - NVIDIA GDRCopy Driver
     - `v2.4.1-1 <https://github.com/NVIDIA/gdrcopy/releases>`__
     - `v2.4.1-1 <https://github.com/NVIDIA/gdrcopy/releases>`__
     - `v2.4.1-1 <https://github.com/NVIDIA/gdrcopy/releases>`__

.. _known-issue:

   :sup:`1`
   Known Issue: For drivers 570.124.06, 570.133.20, 570.148.08, 570.158.01,
   GPU workloads cannot be scheduled on nodes that have a mix of MIG slices and full GPUs. 
   This manifests as GPU pods getting stuck indefinitely in the ``Pending`` state. 
   It's recommended that you downgrade the driver to version 570.86.15 to work around this issue.
   For more detailed information, see GitHub issue https://github.com/NVIDIA/gpu-operator/issues/1361.

.. note::
    
  **NVIDIA GPU Driver** 
   - If you are using driver versions 570.133.20, 550.163.01, or 535.247.01 and have configured ``driver.useOpenKernelModules=true``, you must also set the ``KERNEL_MODULE_TYPE=open`` environment variable in your ClusterPolicy to use the open kernel module.
     The  ``driver.useOpenKernelModules`` parameter is no longer honored by newer driver versions. 
     Its recommended that you upgrade to GPU Operator version 25.3.0 or later, which supports auto-selecting the correct kernel module type.
   - Driver version could be different with NVIDIA vGPU, as it depends on the driver
     version downloaded from the `NVIDIA vGPU Software Portal  <https://nvid.nvidia.com/dashboard/#/dashboard>`_.
   - The GPU Operator is supported on all active NVIDIA data center production drivers.
     Refer to `Supported Drivers and CUDA Toolkit Versions <https://docs.nvidia.com/datacenter/tesla/drivers/index.html#cuda-drivers>`_
     for more information.
  **NVIDIA GDS Driver**
   - This release of the GDS driver requires that you use the NVIDIA Open GPU Kernel module driver for the GPUs.
     Refer to :doc:`gpu-operator-rdma` for more information.
