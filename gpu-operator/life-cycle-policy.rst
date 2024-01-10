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

To understand the NVIDIA GPU Operator life cycle policy, it is important to know how the NVIDIA GPU Operator is versioned.

As of September 2022, the NVIDIA GPU Operator is versioned following the calendar schema. NVIDIA GPU Operator v22.9.0 will be the first release following calendar versioning, and NVIDIA GPU Operator 1.11 is therefore the last release following the old versioning schema.

Now, let's have a look at how to interpret a NVIDIA GPU Operator release that follows calendar versioning. In this example, we will use v22.9.0 as the example.

The first two segments in the version are in the format of `YY.MM` which represent the major version and also when the NVIDIA GPU Operator was initially released. In this example, the NVIDIA GPU Operator was released in September 2022. Zero padding is omitted for month to be still compatible with semantic versioning.

The third segment as in '.0' represents a dot release. Dot releases typically include fixes for bugs or CVEs but could also include minor features like support for a new NVIDIA GPU driver.


.. _operator_life_cycle_policy:

******************************
NVIDIA GPU Operator Life Cycle
******************************

The NVIDIA GPU Operator life cycle policy provides a predictable support policy and timeline of when new NVIDIA GPU Operator versions are released.

Starting with the NVIDIA GPU Operator v23.3.0, a new major GPU Operator version is released every three months.
Therefore, the next major release of the NVIDIA GPU Operator is scheduled for June 2023 and will be named v23.6.0.

Every major release of the NVIDIA GPU Operator, starting with v23.3.0, is maintained for six months.
Bug fixes and CVEs are released throughout the six months while minor feature updates are only released within the first three months.

This life cycle allows NVIDIA GPU Operator users to use a given NVIDIA GPU Operator version for up to six months.
It also provides users a three month period where they can plan the transition to the next major NVIDIA GPU Operator version.

The product life cycle and versioning are subject to change in the future.

.. note::

    - Upgrades are only supported within a major release or to the next major release.

.. list-table:: Support Status for Releases
   :header-rows: 1
   :widths: 25 25 50

   * - GPU Operator Version
     - Status
     - Details

   * - 23.9.x
     - Generally Available
     - Enters maintenance when v23.12.0 is released.

   * - 23.6.x
     - Maintenance
     - Enters EOL when v23.12.0 is released.

   * - 23.3.x and lower,

       1.11.x and lower

     - EOL
     -


.. _operator-component-matrix:

*****************************
GPU Operator Component Matrix
*****************************

The following table shows the operands and default operand versions that correspond to a GPU Operator version.

When post-release testing confirms support for newer versions of operands, these updates are identified as *recommended updates* to a GPU Operator version.
Refer to :ref:`Upgrading the NVIDIA GPU Operator` for more information.

.. list-table::
   :header-rows: 1

   * - Component
     - Version

   * - NVIDIA GPU Operator
     - v23.9.1

   * - NVIDIA GPU Driver
     - | `535.129.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-129-03/index.html>`_ (default),
       | `525.147.05 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-525-147-05/index.html>`_,
       | `470.223.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-223-02/index.html>`_,

   * - NVIDIA Driver Manager for K8s
     - `v0.6.5 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_

   * - NVIDIA Container Toolkit
     - `1.14.3 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_

   * - NVIDIA Kubernetes Device Plugin
     - `0.14.3 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_

   * - DCGM Exporter
     - `3.3.0-3.2.0 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_

   * - Node Feature Discovery
     - v0.14.2

   * - | NVIDIA GPU Feature Discovery
       | for Kubernetes
     - `0.8.2 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_

   * - NVIDIA MIG Manager for Kubernetes
     - `0.5.5 <https://github.com/NVIDIA/mig-parted/tree/main/deployments/gpu-operator>`_

   * - DCGM
     - `3.3.0-1 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`_

   * - Validator for NVIDIA GPU Operator
     - v23.9.1

   * - NVIDIA KubeVirt GPU Device Plugin
     - `v1.2.4 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`_

   * - NVIDIA vGPU Device Manager
     - v0.2.4

   * - NVIDIA GDS Driver
     - `2.17.5 <https://github.com/NVIDIA/gds-nvidia-fs/releases>`_

   * - NVIDIA Kata Manager for Kubernetes
     - v0.1.2

   * - | NVIDIA Confidential Computing
       | Manager for Kubernetes
     - v0.1.1

.. note::

   - Driver version could be different with NVIDIA vGPU, as it depends on the driver
     version downloaded from the `NVIDIA vGPU Software Portal  <https://nvid.nvidia.com/dashboard/#/dashboard>`_.
   - The GPU Operator is supported on all active NVIDIA datacenter production drivers.
     Refer to `Supported Drivers and CUDA Toolkit Versions <https://docs.nvidia.com/datacenter/tesla/drivers/index.html#cuda-drivers>`_
     for more information.
