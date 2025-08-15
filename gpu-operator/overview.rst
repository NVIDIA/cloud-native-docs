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


*****************************
About the NVIDIA GPU Operator
*****************************

.. image:: graphics/nvidia-gpu-operator-image.jpg
   :width: 600

Kubernetes provides access to special hardware resources such as NVIDIA GPUs, NICs, Infiniband adapters and other devices
through the `device plugin framework <https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/>`_.
However, configuring and managing nodes with these hardware resources requires
configuration of multiple software components such as drivers, container runtimes or other libraries which are difficult
and prone to errors. The NVIDIA GPU Operator uses the `operator framework <https://coreos.com/blog/introducing-operator-framework>`_
within Kubernetes to automate the management of all NVIDIA software components needed to provision GPU. These components include the NVIDIA drivers (to enable CUDA),
Kubernetes device plugin for GPUs, the `NVIDIA Container Toolkit <https://github.com/NVIDIA/nvidia-container-toolkit>`_,
automatic node labeling using `GFD <https://github.com/NVIDIA/gpu-feature-discovery>`_, `DCGM <https://developer.nvidia.com/dcgm>`_ based monitoring and others.


.. card:: Red Hat OpenShift Container Platform

   For information about installing, managing, and upgrading the Operator,
   refer to :external+ocp:doc:`index`.

   Information about supported versions is available in :ref:`Supported Operating Systems and Kubernetes Platforms`.


About This Documentation
========================

Browse through the following documents for getting started, platform support and release notes.

Getting Started
---------------

The :ref:`operator-install-guide` guide includes information on installing the GPU Operator in a Kubernetes cluster.

Release Notes
---------------

Refer to :ref:`operator-release-notes` for information about releases.

Platform Support
------------------

The :ref:`operator-platform-support` describes the supported platform configurations.

Licenses and Contributing
=========================

.. _pstai: https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/
.. |pstai| replace:: Product-Specific Terms for NVIDIA AI Products

The NVIDIA GPU Operator source code is licensed under `Apache 2.0 <https://www.apache.org/licenses/LICENSE-2.0>`__ and
contributions are accepted with a DCO. Refer to the `contributing <https://github.com/NVIDIA/gpu-operator/blob/master/CONTRIBUTING.md>`_ document for
more information on how to contribute and the release artifacts.

The base images used by the software might include software that is licensed under open-source licenses such as GPL.
The source code for these components is archived on the CUDA opensource `index <https://developer.download.nvidia.com/compute/cuda/opensource/>`_.

The following table identifieis the licenses for the Operator and software components.
By installing and using the GPU Operator, you accept the terms and conditions of these licenses.

.. list-table::
   :header-rows: 1
   :widths: 30 10 60

   * - Component
     - Artifact Type
     - Artifact Licenses

   * - NVIDIA GPU Operator
     - Helm Chart
     - `Apache 2.0 <https://www.apache.org/licenses/LICENSE-2.0>`__

   * - NVIDIA GPU Operator
     - Image
     - |pstai|_

   * - NVIDIA GPU Feature Discovery
     - Image
     - |pstai|_

   * - NVIDIA GPU Driver
     - Image
     - `License for Customer Use of NVIDIA Software <http://www.nvidia.com/content/DriverDownload-March2009/licence.php?lang=us>`__

       |pstai|_

   * - NVIDIA Container Toolkit
     - Image
     - |pstai|_

   * - NVIDIA Kubernetes Device Plugin
     - Image
     - |pstai|_

   * - NVIDIA MIG Manager for Kubernetes
     - Image
     - |pstai|_

   * - Validator for NVIDIA GPU Operator
     - Image
     - |pstai|_

   * - NVIDIA DCGM
     - Image
     - |pstai|_

   * - NVIDIA DCGM Exporter
     - Image
     - |pstai|_

   * - NVIDIA Driver Manager for Kubernetes
     - Image
     - |pstai|_

   * - NVIDIA KubeVirt GPU Device Plugin
     - Image
     - |pstai|_

   * - NVIDIA vGPU Device Manager
     - Image
     - |pstai|_

   * - NVIDIA GDS Driver
     - Image
     - `License for Customer Use of NVIDIA Software <http://www.nvidia.com/content/DriverDownload-March2009/licence.php?lang=us>`__

       |pstai|_

   * - NVIDIA Confidential Computing
       Manager for Kubernetes
     - Image
     - |pstai|_

   * - NVIDIA Kata Manager for Kubernetes
     - Image
     - |pstai|_

   * - NVIDIA GDRCopy Driver
     - Image
     - |pstai|_