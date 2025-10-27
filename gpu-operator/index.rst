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

.. toctree::
   :caption: NVIDIA GPU Operator
   :titlesonly:
   :hidden:

   About the Operator <overview.rst>
   Install <getting-started.rst>
   Upgrade <upgrade.rst>
   Uninstall <uninstall.rst>
   Platform Support <platform-support.rst>
   Release Notes <release-notes.rst>
   Troubleshooting <troubleshooting.rst>
   gpu-driver-upgrades.rst
   install-gpu-operator-vgpu.rst
   install-gpu-operator-nvaie.rst
   Security Considerations <security.rst>



.. toctree::
   :caption: Advanced Operator Configuration
   :titlesonly:
   :hidden:

   Multi-Instance GPU <gpu-operator-mig.rst>
   Time-Slicing GPUs <gpu-sharing.rst>
   gpu-operator-rdma.rst
   Outdated Kernels <install-gpu-operator-outdated-kernels.rst>
   Custom GPU Driver Parameters <custom-driver-params.rst>
   precompiled-drivers.rst
   GPU Driver CRD <gpu-driver-configuration.rst>
   Container Device Interface Support <cdi.rst>

.. toctree::
   :caption:  Sandboxed Workloads
   :titlesonly:
   :hidden:

   KubeVirt <gpu-operator-kubevirt.rst>
   Kata Containers <gpu-operator-kata.rst>
   
.. toctree::
   :caption: Specialized Networks
   :titlesonly:
   :hidden:

   HTTP Proxy <install-gpu-operator-proxy.rst>
   Air-Gapped Network <install-gpu-operator-air-gapped.rst>
   Service Mesh <install-gpu-operator-service-mesh.rst>

.. toctree::
   :caption: CSP configurations
   :titlesonly:
   :hidden:

   Amazon EKS <amazon-eks.rst>
   Azure AKS <microsoft-aks.rst>
   Google GKE <google-gke.rst>

.. toctree::
   :caption: NVIDIA DRA Driver for GPUs
   :titlesonly:
   :hidden:

   Introduction & Installation <dra-intro-install.rst>
   GPUs <dra-gpus.rst>
   ComputeDomains <dra-cds.rst>

.. include:: overview.rst
