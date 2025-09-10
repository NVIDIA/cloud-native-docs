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

.. |ocp_csp_support| replace:: Red Hat OpenShift Container Platform is supported on AWS, Azure, GCP, and OCI (Oracle) Virtual Machine or Bare Metal instances with T4, V100, L4, L40s, A10, A100, H100, and H200.

.. _operator-platform-support:

################
Platform Support
################

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
     | NVIDIA DGX H100         | NVIDIA Hopper and         |
     |                         | NVSwitch                  |
     +-------------------------+---------------------------+
     | NVIDIA DGX H200         | NVIDIA Hopper and         |
     |                         | NVSwitch                  |
     +-------------------------+---------------------------+
     | NVIDIA HGX H100         | NVIDIA Hopper and         |
     |                         | NVSwitch                  |
     +-------------------------+---------------------------+
     | NVIDIA HGX H200         | NVIDIA Hopper and         |
     |                         | NVSwitch                  |
     +-------------------------+---------------------------+
     | | NVIDIA H100,          | NVIDIA Hopper             |
     | | NVIDIA H100 NVL       |                           |
     +-------------------------+---------------------------+
     | NVIDIA H20              | NVIDIA Hopper             |
     +-------------------------+---------------------------+
     | NVIDIA L20              | NVIDIA Ada                |
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
    | NVIDIA RTX PRO 6000     | NVIDIA Blackwell       |
    | Blackwell Server Edition|                        |
    +-------------------------+------------------------+
    | NVIDIA RTX PRO 6000D    | NVIDIA Blackwell       |
    +-------------------------+------------------------+
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

     .. note::

      NVIDIA RTX PRO 6000 Blackwell Server Edition notes:
        * Driver versions 575.57.08 or later is required.  
        * MIG is not supported on the 575.57.08 driver release.
        * You must disable High Memory Mode (HMM) in UVM by :ref:`Customizing NVIDIA GPU Driver Parameters during Installation`.

  .. tab-item:: B-series Products

    +-------------------------+------------------------+
    | Product                 | Architecture           |
    +=========================+========================+
    | NVIDIA DGX B200         | NVIDIA Blackwell       |
    +-------------------------+------------------------+
    | NVIDIA HGX B200         | NVIDIA Blackwell       |
    +-------------------------+------------------------+
    | NVIDIA HGX GB200 NVL72  | NVIDIA Blackwell       |
    +-------------------------+------------------------+

     .. note::

       * HGX B200 requires a driver container version of 570.133.20 or later.


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

.. _fn1: #kubernetes-version
.. |fn1| replace:: :sup:`1`
.. _fn2: #ubuntu-kernel
.. |fn2| replace:: :sup:`2`
.. _fn3: #rhel-9
.. |fn3| replace:: :sup:`3`

The GPU Operator has been validated in the following scenarios:

.. tab-set::

  .. tab-item:: Bare Metal / Virtual Machines with GPU Passthrough

    .. list-table::
       :header-rows: 1
       :stub-columns: 1

       * - | Operating
           | System
         - Kubernetes |fn1|_
         - | Red Hat
           | OpenShift
         - | VMware vSphere
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

       * - Ubuntu 20.04 LTS |fn2|_
         - 1.29---1.33
         -
         - 7.0 U3c, 8.0 U2, 8.0 U3
         - 1.29---1.33
         -
         -
         - 2.12, 2.13, 2.14

       * - Ubuntu 22.04 LTS |fn2|_
         - 1.29---1.33
         -
         - 8.0 U2, 8.0 U3
         - 1.29---1.33
         -
         - 1.26
         - 2.12, 2.13, 2.14, 2.15

       * - Ubuntu 24.04 LTS
         - 1.29---1.33
         -
         -
         - 1.29---1.33
         -
         -
         -

       * - Red Hat Core OS
         -
         - | 4.12---4.19
         -
         -
         -
         -
         -

       * - | Red Hat
           | Enterprise
           | Linux 9.2, 9.4, 9.5, 9.6 |fn3|_
         - 1.29---1.33
         -
         -
         - 1.29---1.33
         -
         -
         -

       * - | Red Hat
           | Enterprise
           | Linux 8.8,
           | 8.10
         - 1.29---1.33
         -
         -
         - 1.29---1.33
         -
         -
         - 2.12, 2.13, 2.14, 2.15
         
    .. _kubernetes-version:

    :sup:`1`
    The Kubernetes community only supports the last three minor `releases <https://kubernetes.io/releases/>`_.
    Older releases may be supported through enterprise distributions of Kubernetes such as Red Hat OpenShift.

    .. _ubuntu-kernel:

    :sup:`2`
    For Ubuntu 22.04 LTS, kernel versions 6.8 (non-precompiled driver containers only) 6.5 and 5.15 are LTS ESM kernels.
    For Ubuntu 20.04 LTS, kernel versions 5.4 and 5.15 are LTS ESM kernels.
    The GPU Driver containers support these Linux kernels.
    Refer to the Kernel release schedule on Canonical's
    `Ubuntu kernel lifecycle and enablement stack <https://ubuntu.com/kernel/lifecycle>`_ page for more information.
    NVIDIA recommends disabling automatic updates for the Linux kernel that are performed
    by the ``unattended-upgrades`` package to prevent an upgrade to an unsupported kernel version.

    .. _rhel-9:

    :sup:`3`
    Non-precompiled driver containers for Red Hat Enterprise Linux 9.2, 9.4, 9.5, and 9.6 versions are available for x86 based platforms only. 
    They are not available for ARM based systems.

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
         - | VMware vSphere
           | with Tanzu
         - | Rancher Kubernetes
           | Engine 2
         - | Nutanix
           | NKP

       * - Ubuntu 20.04 LTS
         - 1.29--1.33
         -
         - 7.0 U3c, 8.0 U2, 8.0 U3
         - 1.29--1.33
         - 2.12, 2.13

       * - Ubuntu 22.04 LTS
         - 1.29--1.33
         -
         - 8.0 U2, 8.0 U3
         - 1.29--1.33
         - 2.12, 2.13

       * - Ubuntu 24.04 LTS
         - 1.29--1.33
         -
         - 
         - 1.29--1.33
         - 

       * - Red Hat Core OS
         -
         - 4.12---4.19
         -
         -
         -

       * - | Red Hat
           | Enterprise
           | Linux 8.4,
           | 8.6---8.10
         - 1.29---1.33
         -
         -
         - 1.29---1.33
         -


Supported Precompiled Drivers
-----------------------------

The GPU Operator has been validated with the following precompiled drivers.
See the :doc:`precompiled-drivers` page for more information about using precompiled drivers.

+----------------------------+------------------------+----------------+---------------------+
| Operating System           | Kernel Flavor          | Kernel Version | CUDA Driver Branch  |
+============================+========================+================+=====================+
| Ubuntu 22.04               | Generic, NVIDIA, Azure |  5.15          |  R535, R550, R570   |
|                            | AWS, Oracle            |                |                     |
+----------------------------+------------------------+----------------+---------------------+
| Ubuntu 24.04               | Generic, NVIDIA, Azure |  6.8           |  R550, R570         |
|                            | AWS, Oracle            |                |                     |
+----------------------------+------------------------+----------------+---------------------+



Supported Container Runtimes
----------------------------

The GPU Operator has been validated for the following container runtimes:

+----------------------------+------------------------+----------------+
| Operating System           | Containerd 1.6 - 2.1   | CRI-O          |
+============================+========================+================+
| Ubuntu 20.04 LTS           | Yes                    | Yes            |
+----------------------------+------------------------+----------------+
| Ubuntu 22.04 LTS           | Yes                    | Yes            |
+----------------------------+------------------------+----------------+
| Ubuntu 24.04 LTS           | Yes                    | Yes            |
+----------------------------+------------------------+----------------+
| Red Hat Core OS (RHCOS)    | No                     | Yes            |
+----------------------------+------------------------+----------------+
| Red Hat Enterprise Linux 8 | Yes                    | Yes            |
+----------------------------+------------------------+----------------+
| Red Hat Enterprise Linux 9 | Yes                    | Yes            |
+----------------------------+------------------------+----------------+


Support for KubeVirt and OpenShift Virtualization
-------------------------------------------------

Red Hat OpenShift Virtualization is based on KubeVirt.


================    ===========   =============   =========    =============    ===========
Operating System    Kubernetes           KubeVirt              OpenShift Virtualization
----------------    -----------   -------------------------    ----------------------------
\                   \             | GPU           vGPU         | GPU            vGPU
                                  | Passthrough                | Passthrough
================    ===========   =============   =========    =============    ===========
Ubuntu 20.04 LTS    1.23---1.33   0.36+           0.59.1+
Ubuntu 22.04 LTS    1.23---1.33   0.36+           0.59.1+
Red Hat Core OS                                                4.12---4.19      4.13---4.19
================    ===========   =============   =========    =============    ===========

You can run GPU passthrough and NVIDIA vGPU in the same cluster as long as you use
a software version that meets both requirements.

NVIDIA vGPU is incompatible with KubeVirt v0.58.0, v0.58.1, and v0.59.0, as well
as OpenShift Virtualization 4.12.0---4.12.2.
Starting with KubeVirt v0.58.2 and v0.59.1, and OpenShift Virtualization 4.12.3 and 4.13,
you must set the ``DisableMDEVConfiguration`` feature gate.
Refer to :ref:`GPU Operator with KubeVirt` or :ref:`NVIDIA GPU Operator with OpenShift Virtualization`.

KubeVirt and OpenShift Virtualization with NVIDIA vGPU is supported on the following devices:

- RTX Pro 6000 Blackwell Server Edition

- H200NVL

- H100 

- GA10x: A100, A40, RTX A6000, RTX A5500, RTX A5000, A30, A16, A10, A2.

  The A10G and A10M GPUs are excluded.

- AD10x: L40, RTX 6000 Ada, L4.

  The L40G GPU is excluded.

Note that HGX platforms are not supported.

.. note::
  
  KubeVirt with NVIDIA vGPU is supported on ``nodes`` with Linux kernel < 6.0, such as Ubuntu 22.04 ``LTS``.

Support for GPUDirect RDMA 
--------------------------

Supported operating systems and NVIDIA GPU Drivers with GPUDirect RDMA.

- RHEL 8 with Network Operator 25.1.0.
- Ubuntu 24.04 LTS with Network Operator 25.1.0.
- Ubuntu 20.04 and 22.04 LTS with Network Operator 24.10.0.
- Red Hat Enterprise Linux 9.2, 9.4, 9.5, and 9.6 with Network Operator 25.1.0.
- Red Hat OpenShift 4.12 and higher with Network Operator 23.10.0.

For information about configuring GPUDirect RDMA, refer to :doc:`gpu-operator-rdma`.


Support for GPUDirect Storage
-----------------------------

Supported operating systems and NVIDIA GPU Drivers with GPUDirect Storage.

- Ubuntu 24.04 LTS Network Operator 25.1.0
- Ubuntu 20.04 and 22.04 LTS with Network Operator 24.10.0
- Red Hat OpenShift Container Platform 4.12 and higher

.. note::

   Version v2.17.5 and higher of the NVIDIA GPUDirect Storage kernel driver, ``nvidia-fs``,
   requires the NVIDIA Open GPU Kernel module driver.
   You can install the open kernel modules by specifying the ``driver.kernelModuleType=auto`` if you are using driver container version 570.86.15, 570.124.06 or later. 
   Or use ``driver.kernelModuleType=open`` if you are using a different driver version or branch.
   argument to the ``helm`` command.
   Refer to :ref:`Common Chart Customization Options` for more information.

   Not supported with secure boot.
   Supported storage types are local NVMe and remote NFS.

Additional Supported Container Management Tools
-----------------------------------------------

* Helm v3
* Red Hat Operator Lifecycle Manager (OLM)
