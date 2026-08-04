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

.. headings (h1/h2/h3/h4/h5) are # * = -

=============
Prerequisites
=============

The following are the prerequisites for deploying the NVIDIA GPU Operator.


Hardware And Operating System Requirements
******************************************

Your GPUs and cluster align with the :ref:`GPU Operator support matrix
<operator-platform-support>` for hardware and operating system.

Additional Operating System configurations depend on how you plan to manage the NVIDIA GPU Driver:

* If you are planning to use NVIDIA GPU Driver Custom Resource Definition to manage drivers, you can use a mix of operating system versions on CPU and GPU nodes. Refer to the :doc:`NVIDIA GPU Driver Custom Resource Definition <gpu-driver-configuration>` page for more information on using this custom resource.

* If you are planning to use ClusterPolicy for driver configuration, all worker nodes or node groups that will run GPU workloads in the Kubernetes cluster must run the same operating system version to use the NVIDIA GPU Driver container.

* If you are planning to pre-install the NVIDIA GPU Driver on your nodes, then you can run different operating systems on your nodes.

* For worker nodes or node groups that run CPU workloads only, the nodes can run any operating system because the GPU Operator does not perform any configuration or management of nodes for CPU-only workloads.


Cluster Requirements
********************

* You have the ``kubectl`` and ``helm`` CLIs available on a client machine.
  For supported Kubernetes versions refer to the :ref:`Container Platforms support matrix <container-platforms>`.

  You can run the following commands to install the Helm CLI:

  .. code-block:: console

     $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
        && chmod 700 get_helm.sh \
        && ./get_helm.sh

* Nodes must be configured with a container engine such as CRI-O or containerd.
  For supported container runtime, refer to :ref:`Supported Container Runtimes <supported-container-runtimes>`.

* If your cluster uses Pod Security Admission (PSA) to restrict the behavior of pods, label the namespace for the Operator to set the enforcement policy to privileged:

  .. code-block:: console

     $ kubectl create ns gpu-operator
     $ kubectl label --overwrite ns gpu-operator pod-security.kubernetes.io/enforce=privileged

* Node Feature Discovery (NFD) is a dependency for the Operator on each node.
  By default, NFD master and worker are automatically deployed by the Operator.
  If NFD is already running in the cluster, then you must disable deploying NFD when you install the Operator.

  One way to determine if NFD is already running in the cluster is to check for an NFD label on your nodes (requires `jq <https://jqlang.org/>`__):

  .. code-block:: console

     $ kubectl get nodes -o json | jq '.items[].metadata.labels | keys | any(startswith("feature.node.kubernetes.io"))'

   If the command output is ``true``, then NFD is already running in the cluster.


DRA Requirements 
****************

If you are planning to use the DRA Driver for NVIDIA GPUs for GPU resource management, the following requirements must be met:

* Use Kubernetes 1.34.2 or later. 

* If you plan to use pre-installed driver, the NVIDIA GPU driver must be version 580 or later.

* For ComputeDomains, ensure the following:

  * NVIDIA Grace Blackwell GPUs with Multi-Node NVLink (MNNVL) are available on your cluster.
    Refer to the `NVIDIA Multi-Node NVLink Systems documentation
    <https://docs.nvidia.com/multi-node-nvlink-systems/index.html>`_ for details.

  * When using ComputeDomains with a pre-installed GPU driver:

    * The corresponding ``nvidia-imex-*`` packages are installed through your Linux distribution's package manager.
    * The IMEX systemd service is disabled before installing the GPU Operator (on all GPU nodes). For example:

      .. code-block:: console

         $ systemctl disable --now nvidia-imex.service && systemctl mask nvidia-imex.service


**********
Next Steps
**********

After verifying prerequisites, choose an install path:

- :ref:`install-paths` — overview of platform, license, and enablement-stack options
- :doc:`getting-started` — default Helm install for generic Kubernetes
- :doc:`install-gpu-operator-nvaie` — NVIDIA AI Enterprise
- :doc:`install-gpu-operator-vgpu` — NVIDIA vGPU
