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

.. |ocp_csp_support| replace:: Red Hat OpenShift Container Platform is supported on the AWS (G4, G5, P3, P4, P5), Azure (NC-T4-v3, NC-v3, ND-A100-v4), and GCP (T4, V100, A100) based instances.

.. _operator-platform-support:

################
Platform Support
################

.. contents::
   :depth: 2
   :local:
   :backlinks: none

.. include:: life-cycle-policy.rst

.. _supported nvidia gpus and systems:

Supported NVIDIA Data Center GPUs and Systems
---------------------------------------------

The following NVIDIA data center GPUs are supported on x86 based platforms:

.. _open-kern-module: #requires-open-kernel-module
.. |open-kern-module| replace:: :sup:`1`

.. tab-set::

  .. tab-item:: GH-series Products


     .. list-table::
        :header-rows: 1

        * - Product
          - Architecture

        * - NVIDIA GH200 |open-kern-module|_
          - NVIDIA Grace Hopper

     .. _requires-open-kernel-module:

     :sup:`1`
     NVIDIA GH200 systems require the NVIDIA Open GPU Kernel module driver.
     You can install the open kernel modules by specifying the ``driver.useOpenKernelModules=true``
     argument to the ``helm`` command.
     Refer to :ref:`Common Chart Customization Options` for more information.

  .. tab-item:: A, H and L-series Products
     :selected:

     +-------------------------+---------------------------+
     | Product                 | Architecture              |
     +=========================+===========================+
     | NVIDIA H800             | NVIDIA Hopper             |
     +-------------------------+---------------------------+
     | | NVIDIA H200,          | NVIDIA Hopper             |
     | | NVIDIA H200 NVL       |                           |
     +-------------------------+---------------------------+
     | NVIDIA HGX H200         | NVIDIA Hopper and         |
     |                         | NVSwitch                  |
     +-------------------------+---------------------------+
     | NVIDIA DGX H100         | NVIDIA Hopper and         |
     |                         | NVSwitch                  |
     +-------------------------+---------------------------+
     | NVIDIA HGX H100         | NVIDIA Hopper and         |
     |                         | NVSwitch                  |
     +-------------------------+---------------------------+
     | | NVIDIA H100,          | NVIDIA Hopper             |
     | | NVIDIA H100 NVL       |                           |
     +-------------------------+---------------------------+
     | NVIDIA H20              | NVIDIA Hopper             |
     +-------------------------+---------------------------+
     | | NVIDIA L40,           | NVIDIA Ada                |
     | | NVIDIA L40S           |                           |
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
       * The GPU Operator supports DGX A100 with DGX OS 5.1+ and Red Hat OpenShift using Red Hat Core OS.
         For installation instructions, see :ref:`preinstalled-drivers-and-toolkit` for DGX OS 5.1+ and :ref:`openshift-introduction` for Red Hat OpenShift.

  .. tab-item:: D,T and V-series Products

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

  .. tab-item:: RTX / T-series Products

    +-------------------------+------------------------+
    | Product                 | Architecture           |
    +=========================+========================+
    | NVIDIA RTX A6000        | NVIDIA Ampere /Ada     |
    +-------------------------+------------------------+
    | NVIDIA RTX A5000        | NVIDIA Ampere          |
    +-------------------------+------------------------+
    | NVIDIA RTX A4500        | NVIDIA Ampere          |
    +-------------------------+------------------------+
    | NVIDIA RTX A4000        | NVIDIA Ampere          |
    +-------------------------+------------------------+
    | NVIDIA Quadro RTX 8000  | Turing                 |
    +-------------------------+------------------------+
    | NVIDIA Quadro RTX 6000  | Turing                 |
    +-------------------------+------------------------+
    | NVIDIA Quadro RTX 5000  | Turing                 |
    +-------------------------+------------------------+
    | NVIDIA Quadro RTX 4000  | Turing                 |
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

+-------------------------+---------------------------+
| Product                 | Architecture              |
+=========================+===========================+
| NVIDIA A100X            | Ampere                    |
+-------------------------+---------------------------+
| NVIDIA A30X             | Ampere                    |
+-------------------------+---------------------------+
| NVIDIA IGX Orin         | Ampere                    |
+-------------------------+---------------------------+
| AWS EC2 G5g instances   | Turing                    |
+-------------------------+---------------------------+

In addition to the products specified in the preceding table, any ARM based
system that meets the following requirements is supported:

- NVIDIA GPUs connected to the PCI bus.
- A :ref:`supported operating system <container-platforms>`
  such as Ubuntu or Red Hat Enterprise Linux.

.. note::

   The GPU Operator only supports platforms using discrete GPUs.
   NVIDIA Jetson, or other embedded products with integrated GPUs, are not supported.

   NVIDIA IGX Orin, a platform with an integrated GPU, is supported as long as the discrete GPU is the device being used.

.. _Supported Deployment Options, Hypervisors, and NVIDIA vGPU Based Products:

Supported Deployment Options
----------------------------

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

.. note::

  GPU Operator is supported with NVIDIA vGPU 12.0+.

.. _container-platforms:

Supported Operating Systems and Kubernetes Platforms
----------------------------------------------------

.. _fn1: #ubuntu-kernel
.. |fn1| replace:: :sup:`1`

The GPU Operator has been validated in the following scenarios:

.. note::

   The Kubernetes community supports only the last three minor releases as of v1.17. Older releases
   may be supported through enterprise distributions of Kubernetes such as Red Hat OpenShift.

.. tab-set::

  .. tab-item:: Bare Metal / Virtual Machines with GPU Passthrough

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
         - | Nutanix
           | NKP

       * - Ubuntu 20.04 LTS |fn1|_
         - 1.24---1.31
         -
         - 7.0 U3c, 8.0 U2
         - 1.24---1.31
         -
         -
         - 2.12, 2.13

       * - Ubuntu 22.04 LTS |fn1|_
         - 1.24---1.31
         -
         - 8.0 U2
         - 1.24---1.31
         -
         - 1.26
         - 2.12, 2.13

       * - Red Hat Core OS
         -
         - | 4.12---4.17
         -
         -
         -
         -
         -

       * - | Red Hat
           | Enterprise
           | Linux 8.8,
           | 8.10
         - 1.24---1.31
         -
         -
         - 1.24---1.31
         -
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
         -

    .. _ubuntu-kernel:

    :sup:`1`
    For Ubuntu 22.04 LTS, kernel versions 6.5 and 5.15 are LTS ESM kernels.
    For Ubuntu 20.04 LTS, kernel versions 5.4 and 5.15 are LTS ESM kernels.
    The GPU Driver containers support these Linux kernels.
    Refer to the Kernel release schedule on Canonical's
    `Ubuntu kernel lifecycle and enablement stack <https://ubuntu.com/kernel/lifecycle>`_ page for more information.
    NVIDIA recommends disabling automatic updates for the Linux kernel that are performed
    by the ``unattended-upgrades`` package to prevent an upgrade to an unsupported kernel version.

    .. note::

      |ocp_csp_support|

  .. tab-item:: Cloud Service Providers

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
         - 1.25---1.28
         - 1.25---1.28
         - 1.25---1.28

       * - Ubuntu 22.04 LTS
         - 1.25---1.28
         - 1.25---1.28
         - 1.25---1.28

  .. tab-item:: Virtual Machines with NVIDIA vGPU

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
         - | Nutanix
           | NKP

       * - Ubuntu 20.04 LTS
         - 1.24--1.31
         -
         - 7.0 U3c, 8.0 U2
         - 1.23---1.25
         - 2.12, 2.13

       * - Ubuntu 22.04 LTS
         - 1.24--1.31
         -
         - 8.0 U2
         -
         - 2.12, 2.13

       * - Red Hat Core OS
         -
         - 4.12---4.17
         -
         -
         -

       * - | Red Hat
           | Enterprise
           | Linux 8.4,
           | 8.6---8.9
         - 1.24---1.31
         -
         -
         - 1.24---1.31
         -


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

================    ===========   =============   =========    =============    ===========
Operating System    Kubernetes           KubeVirt              OpenShift Virtualization
----------------    -----------   -------------------------    ----------------------------
\                   \             | GPU           vGPU         | GPU            vGPU
                                  | Passthrough                | Passthrough
================    ===========   =============   =========    =============    ===========
Ubuntu 20.04 LTS    1.23---1.29   0.36+           0.59.1+
Ubuntu 22.04 LTS    1.23---1.29   0.36+           0.59.1+
Red Hat Core OS                                                4.12---4.17      4.13---4.17
================    ===========   =============   =========    =============    ===========

You can run GPU passthrough and NVIDIA vGPU in the same cluster as long as you use
a software version that meets both requirements.

NVIDIA vGPU is incompatible with KubeVirt v0.58.0, v0.58.1, and v0.59.0, as well
as OpenShift Virtualization 4.12.0---4.12.2.
Starting with KubeVirt v0.58.2 and v0.59.1, and OpenShift Virtualization 4.12.3 and 4.13,
you must set the ``DisableMDEVConfiguration`` feature gate.
Refer to :ref:`GPU Operator with KubeVirt` or :ref:`NVIDIA GPU Operator with OpenShift Virtualization`.

KubeVirt and OpenShift Virtualization with NVIDIA vGPU is supported on the following devices:

- H100

- GA10x: A100, A40, RTX A6000, RTX A5500, RTX A5000, A30, A16, A10, A2.

  The A10G and A10M GPUs are excluded.

- AD10x: L40, RTX 6000 Ada, L4.

  The L40G GPU is excluded.


Support for GPUDirect RDMA
--------------------------

Supported operating systems and NVIDIA GPU Drivers with GPUDirect RDMA.

- Ubuntu 20.04 and 22.04 LTS with Network Operator 24.10.0
- Red Hat OpenShift 4.12 and higher with Network Operator 23.10.0

For information about configuring GPUDirect RDMA, refer to :doc:`gpu-operator-rdma`.


Support for GPUDirect Storage
-----------------------------

Supported operating systems and NVIDIA GPU Drivers with GPUDirect Storage.

- Ubuntu 20.04 and 22.04 LTS with Network Operator 24.10.0
- Red Hat OpenShift Container Platform 4.12 and higher

.. note::

   Version v2.17.5 and higher of the NVIDIA GPUDirect Storage kernel driver, ``nvidia-fs``,
   requires the NVIDIA Open GPU Kernel module driver.
   You can install the open kernel modules by specifying the ``driver.useOpenKernelModules=true``
   argument to the ``helm`` command.
   Refer to :ref:`Common Chart Customization Options` for more information.

   Not supported with secure boot.
   Supported storage types are local NVMe and remote NFS.

Additional Supported Container Management Tools
-----------------------------------------------

* Helm v3
* Red Hat Operator Lifecycle Manager (OLM)
