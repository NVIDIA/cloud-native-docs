.. Date: September 25 2022
.. Author: ebohnhorst

.. _gpu-operator-life-cycle-policy:

.. _operator-versioning:

NVIDIA GPU Operator Versioning
----

To understand the NVIDIA GPU Operator life cycle policy, it is important to know how the NVIDIA GPU Operator is versioned.

As of September 2022, the NVIDIA GPU Operator is versioned following the calendar schema. NVIDIA GPU Operator v22.9.0 will be the first release following calendar versioning, and NVIDIA GPU Operator 1.11 is therefore the last release following the old versioning schema.

Now, let's have a look at how to interpret a NVIDIA GPU Operator release that follows calendar versioning. In this example, we will use v22.9.0 as the example.

The first two segments in the version are in the format of `YY.MM` which represent the major version and also when the NVIDIA GPU Operator was initially released. In this example, the NVIDIA GPU Operator was released in September 2022. Zero padding is omitted for month to be still compatible with semantic versioning.

The third segment as in '.0' represents a dot release. Dot releases typically include fixes for bugs or CVEs but could also include minor features like support for a new NVIDIA GPU driver.


.. _operator_life_cycle_policy:

NVIDIA GPU Operator Life Cycle
------------------------------

The NVIDIA GPU Operator life cycle policy provides a predictable support policy and timeline of when new NVIDIA GPU Operator versions are released.

Starting with the NVIDIA GPU Operator v22.9.0, a new major GPU Operator version will be released every 6 months.
Therefore, the next major release of the NVIDIA GPU Operator will be released in March 2023 and will be named v23.3.0.

Every major release of the NVIDIA GPU Operator, starting with v22.09, is maintained for 12 months.
Bug fixes and CVEs are released throughout the 12 months while minor feature updates are only released within the first six months.

This life cycle allows NVIDIA GPU Operator users to use a given NVIDIA GPU Operator version for up to 12 months.
It also provides users a 6 month period where they can plan the transition to the next major NVIDIA GPU Operator version.

The product lifecycle and versioning are subject to change in the future.

.. note::

    - Upgrades are only supported within a major release or to the next major release.


.. _operator-component-matrix:

GPU Operator Component Matrix
-----------------------------

The following table shows the operands and default operand versions that correspond to a GPU Operator version.

When post-release testing confirms support for newer versions of operands, these updates are identified as *recommended updates* to a GPU Operator version.
Refer to :ref:`upgrade` for information about upgrading the Operator.

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

      * - v22.9.2
        - | `525.85.12 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-525-85-12/index.html>`_ (recommended),
          | `525.60.13 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-525-60-13/index.html>`_ (default),
          | `515.86.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-515-86-01/index.html>`_,
          | `510.108.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-510-108-03/index.html>`_,
          | `470.161.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-161-03/index.html>`_,
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

      * - v22.9.0
        - | 520.61.05,
          | `515.65.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-515-65-01/index.html>`_ (default),
          | `510.85.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-510-85-02/index.html>`_,
          | `470.141.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-141-03/index.html>`_,
          | `450.203.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-203-03/index.html>`_
        - `v0.4.2 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.11.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.12.3 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `3.0.4-3.0.0 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        -  v0.10.1
        - `0.6.2 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.5.0 <https://github.com/NVIDIA/mig-parted/tree/master/deployments/gpu-operator>`_
        - `3.0.4-1 <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/changelog.html>`_
        - v22.9.0
        - `v1.2.1 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`_
        - v0.2.0
        - N/A

      * - 1.11
        - | `515.48.07 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-515-48-07/index.html>`_ (default),
          | `510.47.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-510-47-03/index.html>`_,
          | `470.129.06 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-129-06/index.html>`_,
          | `450.191.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-191-01/index.html>`_
        - `v0.4.0 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.10.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.12.2 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.4.5-2.6.7 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        -  v0.10.1
        - `0.6.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.4.2 <https://github.com/NVIDIA/mig-parted/tree/master/deployments/gpu-operator>`_
        - `2.4.5-1 <https://docs.nvidia.com/datacenter/dcgm/latest/dcgm-release-notes/index.html>`_
        - v1.11.0
        - `v1.1.2 <https://github.com/NVIDIA/kubevirt-gpu-device-plugin>`_
        - v0.1.0
        - N/A

      * - 1.10
        - `510.47.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-510-47-03/index.html>`_
        - `v0.3.0 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.9.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.11.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.3.4-2.6.4 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.8.2
        - `0.5.0 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.3.0 <https://github.com/NVIDIA/mig-parted/tree/master/deployments/gpu-operator>`_
        - `2.3.4.1 <https://docs.nvidia.com/datacenter/dcgm/latest/dcgm-release-notes/index.html>`_
        - v1.10.0
        - N/A
        - N/A
        - N/A

      * - 1.9.1
        - `470.82.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-82-01/index.html>`_
        - `v0.2.0 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.7.2 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.10.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.3.1-2.6.1 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.8.2
        - `0.4.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.2.0 <https://github.com/NVIDIA/mig-parted/tree/master/deployments/gpu-operator>`_
        - `2.3.1 <https://docs.nvidia.com/datacenter/dcgm/latest/dcgm-release-notes/index.html>`_
        - v1.9.1
        - N/A
        - N/A
        - N/A

      * - 1.9.0
        - `470.82.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-82-01/index.html>`_
        - `v0.2.0 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.7.2 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.10.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.3.1-2.6.0 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.8.2
        - `0.4.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.2.0 <https://github.com/NVIDIA/mig-parted/tree/master/deployments/gpu-operator>`_
        - `2.3.1 <https://docs.nvidia.com/datacenter/dcgm/latest/dcgm-release-notes/index.html>`_
        - v1.9.0
        - N/A
        - N/A
        - N/A

      * - 1.8.2
        - `470.57.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-57-02/index.html>`_
        - `v0.1.0 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.7.1 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.9.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.2.9-2.4.0 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.8.2
        - `0.4.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.1.3 <https://github.com/NVIDIA/mig-parted/tree/master/deployments/gpu-operator>`_
        - `2.2.3 <https://docs.nvidia.com/datacenter/dcgm/latest/dcgm-release-notes/index.html>`_
        - v1.8.2
        - N/A
        - N/A
        - N/A

      * - 1.8.1
        - `470.57.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-57-02/index.html>`_
        - `v0.1.0 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.6.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.9.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.2.9-2.4.0 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.8.2
        - `0.4.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.1.2 <https://github.com/NVIDIA/mig-parted/tree/master/deployments/gpu-operator>`_
        - `2.2.3 <https://docs.nvidia.com/datacenter/dcgm/latest/dcgm-release-notes/index.html>`_
        - v1.8.1
        - N/A
        - N/A
        - N/A

      * - 1.8.0
        - `470.57.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-470-57-02/index.html>`_
        - `v0.1.0 <https://ngc.nvidia.com/catalog/containers/nvidia:cloud-native:k8s-driver-manager>`_
        - `1.6.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.9.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.2.9-2.4.0 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.8.2
        - `0.4.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.1.2 <https://github.com/NVIDIA/mig-parted/tree/master/deployments/gpu-operator>`_
        - `2.2.3 <https://docs.nvidia.com/datacenter/dcgm/latest/dcgm-release-notes/index.html>`_
        - v1.8.0
        - N/A
        - N/A
        - N/A

      * - 1.7.1
        - `460.73.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-460-73-01/index.html>`_
        - N/A
        - `1.5.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.9.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.1.8-2.4.0-rc.2 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.8.2
        - `0.4.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.1.0 <https://github.com/NVIDIA/mig-parted/tree/master/deployments/gpu-operator>`_
        - N/A
        - v1.7.1
        - N/A
        - N/A
        - N/A

      * - 1.7.0
        - `460.73.01 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-460-73-01/index.html>`_
        - N/A
        - `1.5.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.9.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.1.8-2.4.0-rc.2 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.6.0
        - `0.4.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - `0.1.0 <https://github.com/NVIDIA/mig-parted/tree/master/deployments/gpu-operator>`_
        - N/A
        - v1.7.0
        - N/A
        - N/A
        - N/A

      * - 1.6.2
        - `460.32.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-460-32-03/index.html>`_
        - N/A
        - `1.4.7 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.8.2 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.2.0 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.6.0
        - `0.4.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A

      * - 1.6.1
        - `460.32.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-460-32-03/index.html>`_
        - N/A
        - `1.4.6 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.8.2 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.2.0 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.6.0
        - `0.4.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A

      * - 1.6.0
        - `460.32.03 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-460-32-03/index.html>`_
        - N/A
        - `1.4.5 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.8.2 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.2.0 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.6.0
        - `0.4.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A

      * - 1.5.2
        - `450.80.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-102-04/index.html>`_
        - N/A
        - `1.4.4 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.8.1 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.1.2 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.6.0
        - `0.4.0 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A

      * - 1.5.1
        - `450.80.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-102-04/index.html>`_
        - N/A
        - `1.4.3 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.7.3 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.1.2 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.6.0
        - `0.3.0 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A

      * - 1.5.0
        - `450.80.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-102-04/index.html>`_
        - N/A
        - `1.4.2 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.7.3 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.1.2 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.6.0
        - `0.3.0 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A

      * - 1.4.0
        - `450.80.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-102-04/index.html>`_
        - N/A
        - `1.4.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.7.1 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.1.2 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.6.0
        - `0.2.2 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A

      * - 1.3.0
        - `450.80.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-102-04/index.html>`_
        - N/A
        - `1.3.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.7.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.1.0 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.6.0
        - `0.2.1 <https://github.com/NVIDIA/gpu-feature-discovery/releases>`_
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A

      * - 1.2.0
        - `450.80.02 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-450-102-04/index.html>`_
        - N/A
        - `1.3.0 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `0.7.0 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `2.1.0-rc.2 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.6.0
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A

      * - 1.1.0
        - `440.64.00 <https://docs.nvidia.com/datacenter/tesla/tesla-release-notes-440-6400/index.html>`_
        - N/A
        - `1.0.5 <https://github.com/NVIDIA/nvidia-container-toolkit/releases>`_
        - `1.0.0-beta4 <https://github.com/NVIDIA/k8s-device-plugin/releases>`_
        - `1.7.2 <https://github.com/NVIDIA/gpu-monitoring-tools/releases>`_
        - 0.5.0
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A
        - N/A

  .. note::

      - Driver version could be different with NVIDIA vGPU, as it depends on the driver
        version downloaded from the `NVIDIA vGPU Software Portal  <https://nvid.nvidia.com/dashboard/#/dashboard>`_.
      - The GPU Operator is supported on all the R450, R470, R510, 515, 520 and 525 NVIDIA datacenter production drivers. For a list of supported
        datacenter drivers versions, visit this `link <https://docs.nvidia.com/datacenter/tesla/drivers/index.html#cuda-drivers>`_.
