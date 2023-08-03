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

.. Date: July 30 2020
.. Author: pramarao

.. |ocp_csp_support| replace:: Red Hat OpenShift is supported on the AWS (G4, G5, P3, P4), Azure (NC-T4-v3, NC-v3, ND-A100-v4), and GCP (T4, V100, A100) based instances.

.. _operator-platform-support:

################
Platform Support
################

.. contents::
   :depth: 2
   :local:
   :backlinks: none

.. include:: life-cycle-policy.rst

Supported NVIDIA GPUs and Systems
---------------------------------

The following NVIDIA data center GPUs are supported on x86 based platforms:

.. tabs::

  .. tab:: Data Center A, H and L-series Products

    +-------------------------+---------------------------+
    | Product                 | Architecture              |
    +=========================+===========================+
    | NVIDIA H800             | NVIDIA Hopper             |
    +-------------------------+---------------------------+
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

       * - Ubuntu 20.04 LTS
         - 1.21---1.27
         -
         - 7.0 U3c, 8.0 U1
         - 1.21---1.27
         -
         -

       * - Ubuntu 22.04 LTS
         - 1.21---1.27
         -
         -
         -
         -
         - 1.26

       * - CentOS 7
         - 1.21---1.27
         -
         -
         -
         -
         -

       * - Red Hat Core OS
         -
         - | 4.9, 4.10, 4.11
           | 4.12, 4.13
         -
         -
         -
         -

       * - | Red Hat
           | Enterprise
           | Linux 8.4,
           | 8.6, 8.7, 8.8
         - 1.21---1.27
         -
         -
         - 1.21---1.27
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

  .. tab:: Cloud Service Providers

    .. list-table::
       :header-rows: 1
       :stub-columns: 1

       * - | Operating
           | System
         - | Amazon EKS
           | Kubernetes
         - | Google GKE
           | Kubernetes
         - | Microsoft Azure
           | Kubernetes Service

       * - Ubuntu 20.04 LTS
         - 1.25, 1.26
         - 1.24, 1.25
         - 1.25

       * - Ubuntu 22.04 LTS
         - 1.25, 1.26
         - 1.24, 1.25
         - 1.25

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
         - 1.21--1.27
         -
         - 7.0 U3c, 8.0 U1
         - | 1.21, 1.22, 1.23,
           | 1.24, 1.25

       * - Ubuntu 22.04 LTS
         - 1.21--1.27
         -
         -
         -

       * - Red Hat Core OS
         -
         - | 4.9, 4.10, 4.11
           | 4.12, 4.13
         -
         -

       * - | Red Hat
           | Enterprise
           | Linux 8.4,
           | 8.6, 8.7
         - 1.21---1.27
         -
         -
         - 1.21---1.27


Supported Container Runtimes
----------------------------

The GPU Operator has been validated in the following scenarios:

+----------------------------+------------------------+----------------+
| Operating System           | Containerd 1.4 - 1.7   | CRI-O          |
+============================+========================+================+
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


Support for KubeVirt and OpenShift Virtualization
-------------------------------------------------

Red Hat OpenShift Virtualization is based on KubeVirt.

================    ===========   =============   =========    =============    ========
Operating System    Kubernetes           KubeVirt              OpenShift Virtualization
----------------    -----------   -------------------------    -------------------------
\                   \             | GPU           vGPU         | GPU            vGPU
                                  | Passthrough                | Passthrough
================    ===========   =============   =========    =============    ========
Ubuntu 20.04 LTS    1.21---1.27   0.36+           0.59.1+
Ubuntu 22.04 LTS    1.21---1.27   0.36+           0.59.1+
Red Hat Core OS                                                4.11, 4.12,      4.13
                                                               4.13
================    ===========   =============   =========    =============    ========

You can run GPU passthrough and NVIDIA vGPU in the same cluster as long as you use
a software version that meets both requirements.

NVIDIA vGPU is incompatible with KubeVirt v0.58.0, v0.58.1, and v0.59.0, as well
as OpenShift Virtualization 4.12.0---4.12.2.
Starting with KubeVirt v0.58.2 and v0.59.1, and OpenShift Virtualization 4.12.3 and 4.13,
you must set the ``DisableMDEVConfiguration`` feature gate.
Refer to :ref:`GPU Operator with KubeVirt` or :ref:`NVIDIA GPU Operator with OpenShift Virtualization`.


Support for GPUDirect RDMA
--------------------------

Supported operating systems and NVIDIA GPU Drivers with GPUDirect RDMA.

- Ubuntu 20.04 and 22.04 LTS with Network Operator 1.4
- Red Hat OpenShift 4.10 and 4.11 with Network Operator 1.4
- CentOS 7 with MOFED installed on the node

For more information on GPUDirect RDMA refer to :ref:`this document <operator-rdma>`.


Support for GPUDirect Storage
-----------------------------

Supported operating systems and NVIDIA GPU Drivers with GPUDirect Storage.

- Ubuntu 20.04 LTS with Network Operator 1.4
- Ubuntu 22.04 LTS with Network Operator 1.4
- Red Hat OpenShift Container Platform 4.11

.. note::

      Not supported with secure boot.
      Supported storage types are local NVMe and remote NFS.

Additional Supported Container Management Tools
-----------------------------------------------

* Helm v3
* Red Hat Operator Lifecycle Manager (OLM)
