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

    Upgrades are only supported within a major release or to the next major release.

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

.. _ki: #known-issue
.. |ki| replace:: :sup:`1`
.. _gds: #gds-open-kernel
.. |gds| replace:: :sup:`2`

The following table shows the operands and default operand versions that correspond to a GPU Operator version.

When post-release testing confirms support for newer versions of operands, these updates are identified as *recommended updates* to a GPU Operator version.
Refer to :ref:`Upgrading the NVIDIA GPU Operator` for more information.

**D** = Default driver, **R** = Recommended driver

.. flat-table::
   :header-rows: 2

   * - :rspan:`1` Component
     - :cspan:`4` GPU Operator Version

   * - v25.3.4
     - v25.3.3
     - v25.3.2
     - v25.3.1
     - v25.3.0

   * - NVIDIA GPU Driver |ki|_
     - | `590.48.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-590-48-01/index.html>`_
       | `580.126.16 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-126-16/index.html>`_ (**R**)
       | `580.126.09 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-126-09/index.html>`_ 
       | `580.95.05 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-95-05/index.html>`_ 
       | `580.82.07 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-82-07/index.html>`_ (**D**)
       | `580.65.06 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-65-06/index.html>`_
       | `575.57.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-575-57-08/index.html>`_
       | `570.211.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-211-01/index.html>`_
       | `570.172.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-172-08/index.html>`_
       | `570.158.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-158-01/index.html>`_
       | `570.148.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-148-08/index.html>`_
       | `535.288.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-288-01/index.html>`_
       | `535.261.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-261-03/index.html>`_
       | `550.163.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-550-163-01/index.html>`_
       | `535.247.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-247-01/index.html>`_ 
     - | `580.82.07 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-82-07/index.html>`_ (**D**, **R**)
       | `580.65.06 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-65-06/index.html>`_
       | `575.57.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-575-57-08/index.html>`_
       | `570.172.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-172-08/index.html>`_
       | `570.158.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-158-01/index.html>`_
       | `570.148.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-148-08/index.html>`_
       | `535.261.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-261-03/index.html>`_
       | `550.163.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-550-163-01/index.html>`_
       | `535.247.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-247-01/index.html>`_ 
     - | `580.65.06 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-65-06/index.html>`_ (**R**)        
       | `575.57.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-575-57-08/index.html>`_
       | `570.172.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-172-08/index.html>`_ (**D**)        
       | `570.158.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-158-01/index.html>`_
       | `570.148.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-148-08/index.html>`_
       | `535.261.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-261-03/index.html>`_
       | `550.163.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-550-163-01/index.html>`_
       | `535.247.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-247-01/index.html>`_ 
     - | `580.65.06 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-65-06/index.html>`_ (**R**)
       | `575.57.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-575-57-08/index.html>`_
       | `570.172.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-172-08/index.html>`_ (**D**)
       | `570.158.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-158-01/index.html>`_
       | `570.148.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-148-08/index.html>`_
       | `535.261.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-261-03/index.html>`_
       | `550.163.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-550-163-01/index.html>`_
       | `535.247.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-247-01/index.html>`_ 
     - | `580.65.06 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-580-65-06/index.html>`_ (**R**)
       | `575.57.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-575-57-08/index.html>`_
       | `570.172.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-172-08/index.html>`_ (**D**)
       | `570.158.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-158-01/index.html>`_
       | `570.148.08 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-570-148-08/index.html>`_
       | `550.163.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-550-163-01/index.html>`_
       | `535.261.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-261-03/index.html>`_
       | `535.247.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-247-01/index.html>`_ 

   * - NVIDIA Driver Manager for Kubernetes
     - :cspan:`1` `v0.8.1 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`__
     - :cspan:`2` `v0.8.0 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`__

   * - NVIDIA Container Toolkit
     - :cspan:`3` `1.17.8 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`__
     - `1.17.5 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`__

   * - NVIDIA Kubernetes Device Plugin
     - :cspan:`1` `0.17.4 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__
     - `0.17.3 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__
     - `0.17.2 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__
     - `0.17.1 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__

   * - DCGM Exporter
     - :cspan:`1` `4.3.1-4.4.0 <https://github.com/NVIDIA/dcgm-exporter/releases>`__
     - :cspan:`1` `4.2.3-4.1.3 <https://github.com/NVIDIA/dcgm-exporter/releases>`__
     - `4.1.1-4.0.4 <https://github.com/NVIDIA/dcgm-exporter/releases>`__

   * - Node Feature Discovery
     - :cspan:`3` `v0.17.3 <https://github.com/kubernetes-sigs/node-feature-discovery/releases/>`__
     - `v0.17.2 <https://github.com/kubernetes-sigs/node-feature-discovery/releases/>`__

   * - | NVIDIA GPU Feature Discovery
       | for Kubernetes
     - :cspan:`1` `0.17.4 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__
     - `0.17.3 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__
     - `0.17.3 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__
     - `0.17.1 <https://github.com/NVIDIA/k8s-device-plugin/releases>`__

   * - NVIDIA MIG Manager for Kubernetes
     - :cspan:`1` `0.12.3 <https://github.com/NVIDIA/mig-parted/blob/main/CHANGELOG.md>`__
     - `0.12.2 <https://github.com/NVIDIA/mig-parted/tree/main/deployments/gpu-operator>`__
     - :cspan:`1` `0.12.1 <https://github.com/NVIDIA/mig-parted/tree/main/deployments/gpu-operator>`__

   * - DCGM
     - :cspan:`1` `4.3.1 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`__
     - :cspan:`1` `4.2.3 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`__
     - `4.1.1-2 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`__

   * - Validator for NVIDIA GPU Operator
     - v25.3.4
     - v25.3.3
     - v25.3.2
     - v25.3.1
     - v25.3.0

   * - NVIDIA KubeVirt GPU Device Plugin
     - :cspan:`1` `v1.4.0 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`__
     - :cspan:`2` `v1.3.1 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`__

   * - NVIDIA vGPU Device Manager
     - :cspan:`1` `v0.4.0 <https://github.com/NVIDIA/vgpu-device-manager>`__
     - :cspan:`2` `v0.3.0 <https://github.com/NVIDIA/vgpu-device-manager>`__

   * - NVIDIA GDS Driver |gds|_
     - :cspan:`4` `2.20.5 <https://github.com/NVIDIA/gds-nvidia-fs/releases>`__

   * - NVIDIA Kata Manager for Kubernetes
     - :cspan:`4` `v0.2.3 <https://github.com/NVIDIA/k8s-kata-manager>`__

   * - | NVIDIA Confidential Computing
       | Manager for Kubernetes
     - :cspan:`4` v0.1.1

   * - NVIDIA GDRCopy Driver
     - :cspan:`1` `v2.5.1 <https://github.com/NVIDIA/gdrcopy/releases>`__
     - :cspan:`1` `v2.5.0 <https://github.com/NVIDIA/gdrcopy/releases>`__
     - `v2.4.4 <https://github.com/NVIDIA/gdrcopy/releases>`__

.. _known-issue:

   :sup:`1`
   Known Issue: For drivers 570.124.06, 570.133.20, 570.148.08, and 570.158.01,
   GPU workloads cannot be scheduled on nodes that have a mix of MIG slices and full GPUs. 
   This manifests as GPU pods getting stuck indefinitely in the ``Pending`` state. 
   NVIDIA recommends that you downgrade the driver to version 570.86.15 to work around this issue.
   For more detailed information, see GitHub issue https://github.com/NVIDIA/gpu-operator/issues/1361.


.. _gds-open-kernel:

   :sup:`2`
   This release of the GDS driver requires that you use the NVIDIA Open GPU Kernel module driver for the GPUs.
   Refer to :doc:`gpu-operator-rdma` for more information.
   
.. note::

   - Driver version could be different with NVIDIA vGPU, as it depends on the driver
     version downloaded from the `NVIDIA Licensing Portal  <https://ui.licensing.nvidia.com>`_.
   - The GPU Operator is supported on all active NVIDIA data center production drivers.
     Refer to `Supported Drivers and CUDA Toolkit Versions <https://docs.nvidia.com/datacenter/tesla/drivers/index.html#supported-drivers-and-cuda-toolkit-versions>`_
     for more information.