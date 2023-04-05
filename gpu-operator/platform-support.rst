.. Date: July 30 2020
.. Author: pramarao

.. |ocp_csp_support| replace:: Red Hat OpenShift is supported on the AWS (G4, G5, P3, P4), Azure (NC-T4-v3, NC-v3, ND-A100-v4), and GCP (T4, V100, A100) based instances.

.. _operator-platform-support:

****************
Platform Support
****************

This documents provides an overview of the GPUs and system Platform configurations supported.

.. include:: life-cycle-policy.rst

Supported NVIDIA GPUs and Systems
---------------------------------

The following NVIDIA data center GPUs are supported on x86 based platforms:

.. tabs::

  .. tab:: Data Center A, H and L-series Products

    +-------------------------+---------------------------+
    | Product                 | Architecture              |
    +=========================+===========================+
    | NVIDIA HGX H100         | NVIDIA Hopper and         |
    |                         | NVSwitch                  |
    +-------------------------+---------------------------+
    | NVIDIA H100             | NVIDIA Hopper             |
    +-------------------------+---------------------------+
    | NVIDIA L40              | NVIDIA Ada                |
    +-------------------------+---------------------------+
    | NVIDIA L4               | NVIDIA Ada                |
    +-------------------------+---------------------------+
    | NVIDIA DGX A100         | A100 and NVSwitch         |
    +-------------------------+---------------------------+
    | NVIDIA HGX A100         | A100 and NVSwitch         |
    +-------------------------+---------------------------+
    | NVIDIA A800             | NVIDIA Ampere             |
    +-------------------------+---------------------------+
    | NVIDIA A100             | NVIDIA Ampere             |
    +-------------------------+---------------------------+
    | NVIDIA A100X            | NVIDIA Ampere             |
    +-------------------------+---------------------------+
    | NVIDIA A40              | NVIDIA Ampere             |
    +-------------------------+---------------------------+
    | NVIDIA A30              | NVIDIA Ampere             |
    +-------------------------+---------------------------+
    | NVIDIA A30X             | NVIDIA Ampere             |
    +-------------------------+---------------------------+
    | NVIDIA A16              | NVIDIA Ampere             |
    +-------------------------+---------------------------+
    | NVIDIA A10              | NVIDIA Ampere             |
    +-------------------------+---------------------------+
    | NVIDIA A2               | NVIDIA Ampere             |
    +-------------------------+---------------------------+

    .. note::

      * Hopper (H100) GPU is only supported on x86 servers.
      * The GPU Operator supports DGX A100 with DGX OS 5.1+ and Red Hat OpenShift using Red Hat Core OS. For installation instructions, see :ref:`here <preinstalled-drivers-and-toolkit>` for DGX OS 5.1+ and :ref:`here <openshift-introduction>` for Red Hat OpenShift.

  .. tab:: Data Center D,T and V-series Products

    +-----------------------+------------------------+
    | Product               | Architecture           |
    +=======================+========================+
    | NVIDIA T4             | Turing                 |
    +-----------------------+------------------------+
    | NVIDIA V100           | Volta                  |
    +-----------------------+------------------------+
    | NVIDIA P100           | Pascal                 |
    +-----------------------+------------------------+
    | NVIDIA P40            | Pascal                 |
    +-----------------------+------------------------+
    | NVIDIA P4             | Pascal                 |
    +-----------------------+------------------------+

  .. tab:: Data Center RTX / T-series Products

    +-------------------------+------------------------+
    | Product                 | Architecture           |
    +=========================+========================+
    | NVIDIA RTX A6000        | NVIDIA Ampere /Ada     |
    +-------------------------+------------------------+
    | NVIDIA RTX A5000        | NVIDIA Ampere          |
    +-------------------------+------------------------+
    | NVIDIA RTX A4000        | NVIDIA Ampere          |
    +-------------------------+------------------------+
    | NVIDIA RTX A8000        | Turing                 |
    +-------------------------+------------------------+
    | NVIDIA RTX A6000        | Turing                 |
    +-------------------------+------------------------+
    | NVIDIA RTX A5000        | Turing                 |
    +-------------------------+------------------------+
    | NVIDIA RTX A4000        | Turing                 |
    +-------------------------+------------------------+
    | NVIDIA T1000            | Turing                 |
    +-------------------------+------------------------+
    | NVIDIA T600             | Turing                 |
    +-------------------------+------------------------+
    | NVIDIA T400             | Turing                 |
    +-------------------------+------------------------+


.. _gpu-operator-arm-platforms:

Supported ARM Based Platforms
-----------------------------

The following NVIDIA data center GPUs are supported:

.. tabs::

  .. tab:: ARM platforms

    +-------------------------+---------------------------+
    | Product                 | Architecture              |
    +=========================+===========================+
    | NVIDIA A100X            | Ampere                    |
    +-------------------------+---------------------------+
    | NVIDIA A30X             | Ampere                    |
    +-------------------------+---------------------------+
    | AWS EC2 G5g instances   | Turing                    |
    +-------------------------+---------------------------+

    .. note::

      The GPU Operator only supports platforms using discrete GPUs.
      NVIDIA Jetson, or other embedded products with integrated GPUs, are not supported.

    .. note::

      The R520 Data Center Driver is not supported for ARM.


Supported Deployment Options, Hypervisors, and NVIDIA vGPU Based Products
-------------------------------------------------------------------------

The GPU Operator has been validated in the following scenarios:

+-----------------------------------------------------+
| Deployment Options                                  |
+=====================================================+
| Bare Metal                                          |
+-----------------------------------------------------+
| Virtual machines with GPU Passthrough               |
+-----------------------------------------------------+
| Virtual machines with NVIDIA vGPU based products    |
+-----------------------------------------------------+

Hypervisors (On-premises)

+-----------------------------------------------------+
| Hypervisors                                         |
+=====================================================+
| VMware vSphere 7 and 8                              |
+-----------------------------------------------------+
| Red Hat Enterprise Linux KVM                        |
+-----------------------------------------------------+
| Red Hat Virtualization (RHV)                        |
+-----------------------------------------------------+

NVIDIA vGPU based products

+-----------------------------------------------------+
| NVIDIA vGPU based products                          |
+=====================================================+
| NVIDIA vGPU (NVIDIA AI Enterprise)                  |
+-----------------------------------------------------+
| NVIDIA vCompute Server                              |
+-----------------------------------------------------+
| NVIDIA RTX Virtual Workstation                      |
+-----------------------------------------------------+

.. note::

  GPU Operator is supported with NVIDIA vGPU 12.0+.

.. _container-platforms:

Supported Operating Systems and Kubernetes Platforms
----------------------------------------------------

The GPU Operator has been validated in the following scenarios:

.. note::

   The Kubernetes community supports only the last three minor releases as of v1.17. Older releases
   may be supported through enterprise distributions of Kubernetes such as Red Hat OpenShift.

.. tabs::

  .. tab:: Bare Metal / Virtual Machines with GPU Passthrough

    .. list-table::
       :header-rows: 1
       :stub-columns: 1

       * - | Operating
           | System
         - Kubernetes
         - | Red Hat
           | OpenShift
         - | VMWare vSphere
           | with Tanzu
         - | Rancher Kubernetes
           | Engine 2
         - | HPE Ezmeral
           | Runtime
           | Enterprise
         - | Canonical
           | MicroK8s

       * - Ubuntu 18.04 LTS
         - | 1.21, 1.22, 1,23
           | 1.24, 1.25, 1.26
         -
         -
         -
         -
         -

       * - Ubuntu 20.04 LTS
         - | 1.21, 1.22, 1,23
           | 1.24, 1.25, 1.26
         -
         - 7.0 U3c, 8.0
         - | 1.21, 1.22, 1.23,
           | 1.24, 1.25
         -
         -

       * - Ubuntu 22.04 LTS
         - | 1.21, 1.22, 1,23
           | 1.24, 1.25, 1.26
         -
         -
         -
         -
         - 1.26

       * - CentOS 7
         - | 1.21, 1.22, 1,23
           | 1.24, 1.25, 1.26
         -
         -
         -
         -
         -

       * - Red Hat Core OS
         -
         - | 4.9, 4.10
           | 4.11, 4.12
         -
         -
         -
         -

       * - | Red Hat
           | Enterprise
           | Linux 8.4,
           | 8.6, 8.7
         - | 1.21, 1.22, 1,23
           | 1.24, 1.25, 1.26
         -
         -
         - | 1.21, 1.22, 1.23,
           | 1.24, 1.25
         -
         -

       * - | Red Hat
           | Enterprise
           | Linux 8.4, 8.5
         -
         -
         -
         -
         - 5.5
         -

    .. note::

      |ocp_csp_support|

  .. tab:: Virtual Machines with NVIDIA vGPU

    .. list-table::
       :header-rows: 1
       :stub-columns: 1

       * - | Operating
           | System
         - Kubernetes
         - | Red Hat
           | OpenShift
         - | VMWare vSphere
           | with Tanzu
         - | Rancher Kubernetes
           | Engine 2

       * - Ubuntu 20.04 LTS
         - | 1.21, 1.22, 1,23
           | 1.24, 1.25, 1.26
         -
         - 7.0 U3c, 8.0
         - | 1.21, 1.22, 1.23,
           | 1.24, 1.25

       * - Ubuntu 22.04 LTS
         - | 1.21, 1.22, 1,23
           | 1.24, 1.25, 1.26
         -
         -
         -

       * - Red Hat Core OS
         -
         - | 4.9, 4.10
           | 4.11, 4.12
         -
         -

       * - | Red Hat
           | Enterprise
           | Linux 8.4,
           | 8.6, 8.7
         - | 1.21, 1.22, 1,23
           | 1.24, 1.25, 1.26
         -
         -
         - | 1.21, 1.22, 1.23,
           | 1.24, 1.25

Supported Container Runtimes
----------------------------

The GPU Operator has been validated in the following scenarios:

+----------------------------+------------------------+----------------+
| Operating System           | Containerd 1.4 - 1.7   | CRI-O          |
+============================+========================+================+
| Ubuntu 18.04 LTS           | Yes                    | Yes            |
+----------------------------+------------------------+----------------+
| Ubuntu 20.04 LTS           | Yes                    | Yes            |
+----------------------------+------------------------+----------------+
| Ubuntu 22.04 LTS           | Yes                    | Yes            |
+----------------------------+------------------------+----------------+
| CentOS 7                   | Yes                    | No             |
+----------------------------+------------------------+----------------+
| Red Hat Core OS (RHCOS)    | No                     | Yes            |
+----------------------------+------------------------+----------------+
| Red Hat Enterprise Linux 8 | Yes                    | Yes            |
+----------------------------+------------------------+----------------+

.. note::

  The GPU Operator has been validated with version 2 of the containerd config file.

NVIDIA AI Enterprise Support Matrix
-----------------------------------

The latest version of NVIDIA AI Enterprise supports the following scenarios:

.. tabs::

  .. tab:: Bare Metal / Virtual Machines with GPU Passthrough

    .. list-table::
       :header-rows: 1
       :stub-columns: 1

       * - | Operating
           | System
         - Kubernetes
         - | Red Hat
           | OpenShift
         - | VMWare vSphere
           | with Tanzu

       * - Ubuntu 20.04 LTS
         - | 1.21, 1.22, 1,23
           | 1.24, 1.25
         -
         - 7.0 U3c, 8.0

       * - Ubuntu 22.04 LTS
         - | 1.21, 1.22, 1,23
           | 1.24, 1.25
         -
         -

       * - Red Hat Core OS
         -
         - | 4.9.9+, 4.10
           | 4.11
         -

  .. tab:: Virtual Machines with NVIDIA vGPU

    .. list-table::
       :header-rows: 1
       :stub-columns: 1

       * - | Operating
           | System
         - Kubernetes
         - | Red Hat
           | OpenShift
         - | VMWare vSphere
           | with Tanzu

       * - Ubuntu 20.04 LTS
         - | 1.21, 1.22, 1,23
           | 1.24, 1.25
         -
         - 7.0 U3c, 8.0

       * - Ubuntu 22.04 LTS
         - | 1.21, 1.22, 1,23
           | 1.24, 1.25
         -
         -

       * - Red Hat Core OS
         -
         - | 4.9.9+, 4.10
           | 4.11
         -

.. note::

   |ocp_csp_support|

Support for KubeVirt
--------------------

KubeVirt v0.36.0 is supported with the following operating systems and Kubernetes versions.

.. list-table::
   :header-rows: 1
   :stub-columns: 1

   * - | Operating
       | System
     - Kubernetes
     - | Red Hat
       | OpenShift

   * - Ubuntu 20.04 LTS
     - | 1.21, 1.22, 1,23
       | 1.24, 1.25, 1.26
     -

   * - Ubuntu 22.04 LTS
     - | 1.21, 1.22, 1,23
       | 1.24, 1.25, 1.26
     -

   * - Red Hat Core OS
     -
     - 4.11

Support for GPUDirect RDMA
--------------------------

Supported operating systems and NVIDIA GPU Drivers with GPUDirect RDMA.

+-----------------------------------------------------------+------------------------+---------------------------+---------------------------+---------------------------+---------------------------+
|                                                           | 470 GPU Driver         | 510 GPU Driver            | 515 GPU Driver            | 520 GPU Driver            | 525 GPU Driver            |
+===========================================================+========================+===========================+===========================+===========================+===========================+
| Ubuntu 20.04 and 22.04 LTS with Network Operator 1.4      | 470.161.03             | 510.108.03                | 515.86.01                 | 520.61.07                 | 525.105.17                |
+-----------------------------------------------------------+------------------------+---------------------------+---------------------------+---------------------------+---------------------------+
| Red Hat OpenShift 4.10 and 4.11 with Network Operator 1.4 | 470.161.03             | 510.108.03                | 515.86.01                 | 520.61.07                 | 525.105.17                |
+-----------------------------------------------------------+------------------------+---------------------------+---------------------------+---------------------------+---------------------------+
| CentOS 7 with MOFED installed on the node                 | 470.161.03             | 510.108.03                | 515.86.01                 | 520.61.07                 | 525.105.17                |
+-----------------------------------------------------------+------------------------+---------------------------+---------------------------+---------------------------+---------------------------+

For more information on GPUDirect RDMA refer to :ref:`this document <operator-rdma>`.

Support for GPUDirect Storage
-----------------------------

Supported operating systems and NVIDIA GPU Drivers with GPUDirect Storage.

+--------------------------------------------------+---------------------------+
|                                                  | GPU Driver (GDS Driver)   |
+==================================================+===========================+
| Ubuntu 20.04 LTS with Network Operator 1.4       | 525.105.17 (2.15.1)       |
+--------------------------------------------------+---------------------------+
| Ubuntu 22.04 LTS with Network Operator 1.4       | 525.105.17 (2.15.1)       |
+--------------------------------------------------+---------------------------+
| Red Hat OpenShift Container Platform 4.11        | 525.105.17 (2.15.1)       |
+--------------------------------------------------+---------------------------+

.. note::

      Not supported with secure boot.
      Supported storage types are local NVMe and remote NFS.

Additional Supported Container Management Tools
-----------------------------------------------

* Helm v3
* Red Hat Operator Lifecycle Manager (OLM)

Previous GPU Operator Releases
------------------------------

The following table outlines a historic view of GPU Operator support matrix.

.. tabs::

    .. tab:: Bare metal / Virtual machines with GPU Passthrough

      +--------------------------+---------------+------------------------+----------------+
      | GPU Operator Release     | Kubernetes    | OpenShift              | Anthos         |
      +==========================+===============+========================+================+
      | v23.3.0                  | v1.21+        | 4.9, 4.10, 4.11, 4.12  | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | v22.9.2                  | v1.21+        | 4.9, 4.10, 4.11, 4.12  | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | v22.9.1                  | v1.21+        | 4.9, 4.10, 4.11        | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | v22.9.0                  | v1.21+        | 4.9, 4.10, 4.11        | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.11                     | v1.21+        | 4.9, 4.10, 4.11        | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.10                     | v1.21+        | 4.9, 4.10              | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.9                      | v1.19+        | 4.8, 4.9               | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.8                      | v1.18+        | 4.7, 4.8, 4.9          | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.7                      | v1.18+        | 4.5, 4.6, 4.7          | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.6                      | v1.16+        | 4.5, 4.6, 4.7          | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.5                      | v1.13+        | 4.4.29+, 4.5, 4.6      | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.4                      | v1.13+        | 4.4.29+, 4.5, 4.6      | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.3                      | v1.13+        | 4.4.29+, 4.5, 4.6      | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.2                      | v1.13+        | Not supported          | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.1.7                    | v1.13+        | 4.1, 4.2, 4.3, 4.4     | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.1                      | v1.13+        | Not supported          | Not supported  |
      +--------------------------+---------------+------------------------+----------------+
      | 1.0                      | v1.13+        | Not supported          | Not supported  |
      +--------------------------+---------------+------------------------+----------------+

    .. tab:: Virtual machines with NVIDIA vCompute Server and NVIDIA RTX Virtual Workstation

      +--------------------------+---------------+------------------------+----------------+
      | GPU Operator Release     | Kubernetes    | Red Hat OpenShift      | Anthos         |
      +==========================+===============+========================+================+
      | v22.9.2                  | v1.21+        | 4.9, 4.10, 4.11, 4.12  | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+
      | v22.9.1                  | v1.21+        | 4.9, 4.10, 4.11        | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+
      | v22.9.0                  | v1.21+        | 4.9, 4.10, 4.11        | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+
      | 1.11                     | v1.21+        | 4.9, 4.10, 4.11        | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+
      | 1.10                     | v1.21+        | 4.9, 4.10              | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+
      | 1.9                      | v1.19+        | 4.8, 4.9               | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+
      | 1.8                      | v1.18+        | 4.7, 4.8               | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+
      | 1.7                      | v1.18+        | 4.6, 4.7, 4.8          | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+
      | 1.6                      | v1.16+        | 4.6, 4.7               | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+
      | 1.5                      | v1.13+        | 4.6                    | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+

    .. tab:: NVIDIA AI Enterprise

      +--------------------------+---------------+--------------------------+---------------------------+---------------+
      | GPU Operator Release     | Kubernetes    | OpenShift                | vSphere with Tanzu        | Release       |
      +==========================+===============+==========================+===========================+===============+
      | v22.9.2                  | v1.21+.       | 4.9.9+, 4.10, 4.11, 4.12 | Supported                 | 3.0 and 1.4   |
      +--------------------------+---------------+--------------------------+---------------------------+---------------+
      | v22.9.1                  | v1.21+.       | 4.9.9+, 4.10, 4.11       | Supported                 | 3.0 and 1.4   |
      +--------------------------+---------------+--------------------------+---------------------------+---------------+
      | v22.9.0                  | v1.21+        | 4.9.9+, 4.10, 4.11       | Supported                 | 1.3 and 2.3   |
      +--------------------------+---------------+--------------------------+---------------------------+---------------+
      | 1.11.1                   | v1.21+        | 4.9.9+, 4.10, 4.11       | Supported                 | 2.2           |
      +--------------------------+---------------+--------------------------+---------------------------+---------------+
      | 1.11                     | v1.21+        | 4.9.9+, 4.10, 4.11       | Supported                 | 2.1           |
      +--------------------------+---------------+--------------------------+---------------------------+---------------+
      | 1.10.1                   | v1.21+        | 4.9.9+, 4.10             | Supported                 | 2.0           |
      +--------------------------+---------------+--------------------------+---------------------------+---------------+
      | 1.9.1                    | v1.21+        | Not Supported            | Supported                 | 1.1           |
      +--------------------------+---------------+--------------------------+---------------------------+---------------+
      | 1.8.1                    | v1.21+        | Not Supported            | Not Supported             | 1.0           |
      +--------------------------+---------------+--------------------------+---------------------------+---------------+
