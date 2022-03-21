.. Date: July 30 2020
.. Author: pramarao

.. _operator-platform-support-1.9.1:

****************
Platform Support
****************
This documents provides an overview of the GPUs and system platform configurations supported.

GPUs
----
The following NVIDIA datacenter/enterprise GPUs are supported:

+--------------------------+------------------+
| Product                  | GPU Architecture |
+==========================+==================+
| **Datacenter A-series Products**            |
+--------------------------+------------------+
| NVIDIA A100              | NVIDIA Ampere    |
+--------------------------+------------------+
| NVIDIA A40               | NVIDIA Ampere    |
+--------------------------+------------------+
| NVIDIA A30               | NVIDIA Ampere    |
+--------------------------+------------------+
| NVIDIA A16               | NVIDIA Ampere    |
+--------------------------+------------------+
| NVIDIA A10               | NVIDIA Ampere    |
+--------------------------+------------------+
| **Datacenter T-series Products**            |
+--------------------------+------------------+
| NVIDIA T4                | Turing           |
+--------------------------+------------------+
| **Datacenter V-series Products**            |
+--------------------------+------------------+
| NVIDIA V100              | Volta            |
+--------------------------+------------------+
| **Datacenter P-series Products**            |
+--------------------------+------------------+
| NVIDIA Tesla P100        | Pascal           |
+--------------------------+------------------+
| NVIDIA Tesla P40         | Pascal           |
+--------------------------+------------------+
| NVIDIA Tesla P4          | Pascal           |
+--------------------------+------------------+
| **RTX-Series / T-Series Products**          |
+--------------------------+------------------+
| NVIDIA RTX A6000         | NVIDIA Ampere    |
+--------------------------+------------------+
| NVIDIA RTX A5000         | NVIDIA Ampere    |
+--------------------------+------------------+
| NVIDIA RTX A4000         | NVIDIA Ampere    |
+--------------------------+------------------+
| Quadro RTX 8000          | Turing           |
+--------------------------+------------------+
| Quadro RTX 6000          | Turing           |
+--------------------------+------------------+
| Quadro RTX 5000          | Turing           |
+--------------------------+------------------+
| Quadro RTX 4000          | Turing           |
+--------------------------+------------------+
| NVIDIA T1000	           | Turing           |
+--------------------------+------------------+
| NVIDIA T600              | Turing           |
+--------------------------+------------------+
| NVIDIA T400              | Turing           |
+--------------------------+------------------+

The following NVIDIA server platforms are supported:

+--------------------------+--------------------+
| Product                  | Architecture       |
+==========================+====================+
| **Datacenter A-series Products**              |
+--------------------------+--------------------+
| NVIDIA HGX A100          | A100 and NVSwitch  |
+--------------------------+--------------------+
| NVIDIA DGX A100          | A100 and NVSwitch  |
+--------------------------+--------------------+

.. note::

   The GPU Operator supports DGX A100 with DGX OS 5.1+ and DGX A100 with OCP using RHCOS. For installation instructions,
   see :ref:`here <preinstalled-drivers-and-toolkit-1.9.1>` for DGX OS 5.1+ and :ref:`here <openshift-introduction-1.9.1>` for OCP.

.. note::

   The GPU Operator only supports platforms using discrete GPUs - Jetson or other embedded products with integrated GPUs are not supported.

.. _container-platforms-1.9.1:

Container Platforms
-------------------
The following Kubernetes platforms are supported:

* Kubernetes v1.19+
* VMware vSphere with Tanzu
* Red Hat OpenShift 4 using Red Hat Enterprise Linux CoreOS (RHCOS) and CRI-O container runtime. See 
  the OpenShift `guide <https://docs.nvidia.com/datacenter/kubernetes/openshift-on-gpu-install-guide/index.html>`_ for getting started.
* Google Cloud Anthos. See the user `guide <https://docs.nvidia.com/datacenter/cloud-native/kubernetes/anthos-guide.html>`_ for getting started.

.. note::
   Note that the Kubernetes community supports only the last three minor releases as of v1.17. Older releases
   may be supported through enterprise distributions of Kubernetes such as Red Hat OpenShift. See the prerequisites
   for enabling monitoring in Kubernetes releases before v1.16.

The following table includes the support matrix of the GPU Operator releases and supported container platforms.

.. tabs::

    .. tab:: Baremetal/Passthrough

      +--------------------------+---------------+------------------------+----------------+
      | GPU Operator Release     | Kubernetes    | OpenShift              | Anthos         |
      +==========================+===============+========================+================+
      | 1.9                      | v1.19+        | 4.8 and 4.9            | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.8                      | v1.18+        | 4.7, 4.8 and 4.9       | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.7                      | v1.18+        | 4.5, 4.6 and 4.7       | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.6                      | v1.16+        | 4.5, 4.6 and 4.7       | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.5                      | v1.13+        | 4.4.29+, 4.5 and 4.6   | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.4                      | v1.13+        | 4.4.29+, 4.5 and 4.6   | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.3                      | v1.13+        | 4.4.29+, 4.5 and 4.6   | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.2                      | v1.13+        | Not supported          | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.1.7                    | v1.13+        | 4.1, 4.2, 4.3, and 4.4 | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.1                      | v1.13+        | Not supported          | Not supported  |
      +--------------------------+---------------+------------------------+----------------+
      | 1.0                      | v1.13+        | Not supported          | Not supported  |
      +--------------------------+---------------+------------------------+----------------+

    .. tab:: NVIDIA vGPU

      +--------------------------+---------------+------------------------+----------------+
      | GPU Operator Release     | Kubernetes    | OpenShift              | Anthos         |
      +==========================+===============+========================+================+
      | 1.9                      | v1.19+        | 4.8 and 4.9            | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+
      | 1.8                      | v1.18+        | 4.7 and 4.8            | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+
      | 1.7                      | v1.18+        | 4.6, 4.7 and 4.8       | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+
      | 1.6                      | v1.16+        | 4.6 and 4.7            | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+
      | 1.5                      | v1.13+        | 4.6                    | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+

    .. tab:: NVIDIA AI Enterprise

      +--------------------------+---------------+------------------------+----------------+---------------------------+---------------+
      | GPU Operator Release     | Kubernetes    | OpenShift              | Anthos         | vSphere with Tanzu        | NVAIE Release |
      +==========================+===============+========================+================+===========================+===============+
      | 1.9.1                    | v1.21+        | Not Supported          | Not Supported  | Supported                 | 1.1           |
      +--------------------------+---------------+------------------------+----------------+---------------------------+---------------+
      | 1.8.1                    | v1.21+        | Not Supported          | Not Supported  | Not Supported             | 1.0           |
      +--------------------------+---------------+------------------------+----------------+---------------------------+---------------+

.. note::
   The GPU Operator versions are expressed as *x.y.z* or `<major, minor, patch>` and follows the `semver <https://semver.org/>`_ terminology.

   Only the most recent release of the GPU Operator is maintained through *z* patch updates. All prior releases of the GPU Operator are
   deprecated (and unsupported) when a new *x.y* version of the GPU Operator is released.

   The product lifecycle and versioning are subject to change in the future.

Linux distributions
-------------------

.. tabs::

    .. tab:: Baremetal/Passthrough

         The following Linux distributions are supported:

         * Ubuntu 18.04.z, 20.04.z LTS
         * DGX OS 5.1+
         * Red Hat Enterprise Linux CoreOS (RHCOS) for use with OpenShift 4.8 and 4.9
         * CentOS 7


    .. tab:: NVIDIA vGPU

         The following Linux distributions are supported:

         * Ubuntu 20.04.z LTS
         * Red Hat Enterprise Linux CoreOS (RHCOS) for use with OpenShift 4.8 and 4.9

    .. tab:: NVIDIA AI Enterprise

         The following Linux distributions are supported:

         * Ubuntu 20.04.z LTS

In addition, the following container management tools are supported:

* Helm v3
* Docker CE 19.03+
* containerd 1.4+
* CRI-O with OpenShift 4 using Red Hat Enterprise Linux CoreOS (RHCOS)

.. _operator-component-matrix-1.9.1:

GPU Operator Component Matrix
------------------------------

.. list-table::
    :widths: 20 40 60 60 60 60 60 60 60 60
    :header-rows: 1
    :align: center

    * - Release
      - NVIDIA Driver
      - NVIDIA Driver Manager for K8s
      - NVIDIA Container Toolkit
      - NVIDIA K8s Device Plugin
      - NVIDIA DCGM-Exporter
      - Node Feature Discovery
      - NVIDIA GPU Feature Discovery
      - NVIDIA MIG Manager for K8s
      - NVIDIA DCGM

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

.. note::

    - Driver version could be different with NVIDIA vGPU, as it depends on the driver
      version downloaded from the `NVIDIA vGPU Software Portal  <https://nvid.nvidia.com/dashboard/#/dashboard>`_.
    - The GPU Operator is supported on all the R450, R460 and R470 NVIDIA datacenter production drivers. For a list of supported
      datacenter drivers versions, visit this `link <https://docs.nvidia.com/datacenter/tesla/drivers/index.html#cuda-drivers>`_.

Supported Platforms with NVIDIA AI Enterprise
-----------------------------------------------

The following platforms are supported. Refer to the `NVIDIA AI Enterprise Documentation <https://docs.nvidia.com/ai-enterprise/>`_ for more detailed information.

* VMware vSphere 7.0 Update 2+ with Ubuntu 20.04 guest operating systems
* Ubuntu 20.04.z LTS bare metal
* VMware vSphere with Tanzu (7.0 U3) with Ubuntu 20.04 guest operating systems

Supported NVIDIA vGPU Products
------------------------------

NVIDIA vGPU 12.0+ with the following software products

* NVIDIA Virtual Compute Server (C-Series)
* NVIDIA RTX Virtual Workstation (vWS)

Supported Hypervisors with NVIDIA vGPU
--------------------------------------

The following Virtualization Platforms are supported. Refer to the `NVIDIA vGPU Documentation <https://docs.nvidia.com/grid/12.0/product-support-matrix/index.html>`_ for more detailed information.

* VMware vSphere 7
* Red Hat Enterprise Linux KVM
* Red Hat Virtualization (RHV)

.. .. note::
..   Note that the GA has been validated with the 4.15 LTS kernel. When using the HWE kernel (e.g. v5.3), there are additional prerequisites before deploying the operator.

Deployment Scenarios
--------------------
The GPU Operator has been validated in the following scenarios:

* Bare-metal
* GPU passthrough virtualization
* NVIDIA vGPU
* `NVIDIA AI Enterprise <https://docs.nvidia.com/ai-enterprise/>`_

.. note::
   The GPU Operator deploys the NVIDIA driver as a container. In this environment, running on desktop environments (e.g. workstations with GPUs and display) is not
   supported.
