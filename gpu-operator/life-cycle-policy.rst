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

   * - 23.6.x
     - Generally Available
     - Enters maintenance when v23.9.0 is released.

   * - 23.3.x
     - Maintenance
     - Enters EOL when v23.9.0 is released.

   * - 22.9.x
     - EOL
     -

   * - 1.11.x and lower
     - EOL
     -


.. _operator-component-matrix:

*****************************
GPU Operator Component Matrix
*****************************

The following table shows the operands and default operand versions that correspond to a GPU Operator version.

When post-release testing confirms support for newer versions of operands, these updates are identified as *recommended updates* to a GPU Operator version.
Refer to :ref:`Upgrading the GPU Operator` for more information.

  .. list-table::
      :header-rows: 1
      :align: center

      * - Release
        - | NVIDIA
          | GPU
          | Driver
        - | NVIDIA Driver
          | Manager for K8s
        - | NVIDIA
          | Container
          | Toolkit
        - | NVIDIA Kubernetes
          | Device Plugin
        - DCGM Exporter
        - | Node Feature
          | Discovery
        - | NVIDIA GPU Feature
          | Discovery for Kubernetes
        - | NVIDIA MIG Manager
          | for Kubernetes
        - DCGM
        - | Validator for
          | NVIDIA GPU Operator
        - | NVIDIA KubeVirt
          | GPU Device Plugin
        - | NVIDIA vGPU
          | Device Manager
        - NVIDIA GDS Driver
        - | NVIDIA Kata Manager
          | for Kubernetes
        - | NVIDIA Confidential
          | Computing Manager
          | for Kubernetes

      * - v23.6.2
        - | `535.161.07 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-161-07/index.html>`_ (recommended),
          | `535.104.05 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-104-05/index.html>`_ (default),
          | `525.125.06 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-525-125-06/index.html>`_,
          | `470.199.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-199-02/index.html>`_,
        - `v0.6.2 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.13.4 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.14.1 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `3.1.8-3.1.5 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        -  v0.13.1
        - `0.8.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.5.3 <https://github.com/NVIDIA/mig-parted/tree/main/deployments/gpu-operator>`_
        - | `3.1.8-1 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`_ (default),
        - v23.6.1
        - `v1.2.2 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`_
        - v0.2.3
        - `2.16.1 <https://github.com/NVIDIA/gds-nvidia-fs/releases>`_
        - v0.1.0
        - v0.1.0

      * - v23.6.1
        - | `535.104.12 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-104-12/index.html>`_ (recommended),
          | `535.104.05 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-104-05/index.html>`_ (default),
          | `525.125.06 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-525-125-06/index.html>`_,
          | `470.199.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-199-02/index.html>`_,
        - `v0.6.2 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.13.4 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.14.1 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `3.1.8-3.1.5 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        -  v0.13.1
        - `0.8.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.5.3 <https://github.com/NVIDIA/mig-parted/tree/main/deployments/gpu-operator>`_
        - | `3.1.8-1 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`_ (default),
        - v23.6.1
        - `v1.2.2 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`_
        - v0.2.3
        - `2.16.1 <https://github.com/NVIDIA/gds-nvidia-fs/releases>`_
        - v0.1.0
        - v0.1.0

      * - v23.6.0
        - | `535.86.10 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-86-10/index.html>`_ (default),
          | `525.125.06 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-525-125-06/index.html>`_,
          | `470.199.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-199-02/index.html>`_,
        - `v0.6.2 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.13.4 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.14.1 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `3.1.8-3.1.5 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        -  v0.13.1
        - `0.8.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.5.3 <https://github.com/NVIDIA/mig-parted/tree/main/deployments/gpu-operator>`_
        - | `3.1.8-1 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`_ (default),
        - v23.6.0
        - `v1.2.2 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`_
        - v0.2.3
        - `2.16.1 <https://github.com/NVIDIA/gds-nvidia-fs/releases>`_
        - v0.1.0
        - v0.1.0

      * - v23.3.2
        - | `535.54.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-54-03/index.html>`_ (recommended),
          | `525.125.06 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-525-125-06/index.html>`_,
          | `525.105.17 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-525-105-17/index.html>`_ (default),
          | `515.86.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-515-86-01/index.html>`_,
          | `510.108.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-510-108-03/index.html>`_,
          | `470.199.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-199-02/index.html>`_,
          | `470.161.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-161-03/index.html>`_,
          | `450.248.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-248-02/index.html>`_,
          | `450.216.04 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-216-04/index.html>`_
        - `v0.6.1 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.13.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.14.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `3.1.7-3.1.4 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        -  v0.12.1
        - `0.8.0 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.5.2 <https://github.com/NVIDIA/mig-parted/tree/main/deployments/gpu-operator>`_
        - | `3.1.7-1 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`_ (default),
        - v23.3.2
        - `v1.2.1 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`_
        - v0.2.1
        - `2.15.1 <https://github.com/NVIDIA/gds-nvidia-fs/releases>`_
        - N/A
        - N/A

      * - v23.3.1
        - | `525.105.17 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-525-105-17/index.html>`_ (default),
          | `515.86.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-515-86-01/index.html>`_,
          | `510.108.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-510-108-03/index.html>`_,
          | `470.161.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-161-03/index.html>`_,
          | `450.216.04 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-216-04/index.html>`_
        - `v0.6.1 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.13.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.14.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `3.1.7-3.1.4 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        -  v0.12.1
        - `0.8.0 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.5.2 <https://github.com/NVIDIA/mig-parted/tree/main/deployments/gpu-operator>`_
        - | `3.1.7-1 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`_ (default),
        - v23.3.1
        - `v1.2.1 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`_
        - v0.2.1
        - `2.15.1 <https://github.com/NVIDIA/gds-nvidia-fs/releases>`_
        - N/A
        - N/A

      * - v23.3.0
        - | `525.105.17 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-525-105-17/index.html>`_ (default),
          | `515.86.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-515-86-01/index.html>`_,
          | `510.108.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-510-108-03/index.html>`_,
          | `470.161.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-161-03/index.html>`_,
          | `450.216.04 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-216-04/index.html>`_
        - `v0.6.1 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.13.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.14.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `3.1.7-3.1.4 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        -  v0.12.1
        - `0.8.0 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.5.2 <https://github.com/NVIDIA/mig-parted/tree/main/deployments/gpu-operator>`_
        - | `3.1.7-1 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`_ (default),
        - v23.3.0
        - `v1.2.1 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`_
        - v0.2.1
        - `2.15.1 <https://github.com/NVIDIA/gds-nvidia-fs/releases>`_
        - N/A
        - N/A

      * - v22.9.2
        - | `535.54.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-535-54-03/index.html>`_ (recommended),
          | `525.125.06 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-525-125-06/index.html>`_,
          | `525.85.12 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-525-85-12/index.html>`_,
          | `525.60.13 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-525-60-13/index.html>`_ (default),
          | `515.86.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-515-86-01/index.html>`_,
          | `510.108.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-510-108-03/index.html>`_,
          | `470.199.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-199-02/index.html>`_,
          | `470.161.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-161-03/index.html>`_,
          | `450.248.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-248-02/index.html>`_,
          | `450.216.04 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-216-04/index.html>`_
        - `v0.6.0 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.11.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.13.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `3.1.3-3.1.2 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        -  v0.10.1
        - `0.7.0 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.5.0 <https://github.com/NVIDIA/mig-parted/tree/master/deployments/gpu-operator>`_
        - | `3.1.6 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`_ (recommended),
          | `3.1.3-1 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`_ (default)
        - v22.9.1
        - `v1.2.1 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`_
        - v0.2.0
        - `2.14.13 <https://github.com/NVIDIA/gds-nvidia-fs/releases>`_
        - N/A
        - N/A

      * - v22.9.1
        - | `525.60.13 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-525-60-13/index.html>`_ (default),
          | `515.86.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-515-86-01/index.html>`_,
          | `510.108.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-510-108-03/index.html>`_,
          | `470.161.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-161-03/index.html>`_,
          | `450.216.04 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-216-04/index.html>`_
        - `v0.5.1 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.11.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.13.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `3.1.3-3.1.2 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        -  v0.10.1
        - `0.7.0 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.5.0 <https://github.com/NVIDIA/mig-parted/tree/master/deployments/gpu-operator>`_
        - `3.1.3-1 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`_
        - v22.9.1
        - `v1.2.1 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`_
        - v0.2.0
        - `2.14.13 <https://github.com/NVIDIA/gds-nvidia-fs/releases>`_
        - N/A
        - N/A

  .. note::

      - Driver version could be different with NVIDIA vGPU, as it depends on the driver
        version downloaded from the `NVIDIA vGPU Software Portal  <https://nvid.nvidia.com/dashboard/#/dashboard>`_.
      - The GPU Operator is supported on all active NVIDIA datacenter production drivers.
        Refer to `Supported Drivers and CUDA Toolkit Versions <https://docs.nvidia.com/datacenter/tesla/drivers/index.html#cuda-drivers>`_
        for more information.
