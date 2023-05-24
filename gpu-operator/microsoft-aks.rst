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

#################################################
NVIDIA GPU Operator with Azure Kubernetes Service
#################################################

.. contents::
   :depth: 2
   :local:
   :backlinks: none


*************************************
Approaches for Working with Azure AKS
*************************************

You can approach running workloads in Azure AKS with NVIDIA GPUs in at least two ways.


Default AKS configuration without the GPU Operator
==================================================

By default, you can run Azure AKS images on GPU-enabled virtual machines with NVIDIA GPUs,
and not use the NVIDIA GPU Operator.

AKS images include a preinstalled NVIDIA GPU Driver and preinstalled NVIDIA Container Toolkit.

Using the default configuration, without the Operator, has the following limitations:

* Metrics are not collected or reported with NVIDIA DCGM Exporter.
* Validating the container runtime is manual rather than automatic with the Operator.
* Multi-Instance GPU (MIG) profiles must be set when you create the node pool and you
  cannot change the profile at run time.

If these limitations are acceptable to you, refer to
`Use GPUs for compute-intensive workloads on Azure Kubernetes Services <https://learn.microsoft.com/en-us/azure/aks/gpu-cluster>`_
in the Microsoft Azure product documentation for information about configuring your cluster.


GPU Operator with Preinstalled Driver and Container Toolkit
===========================================================

The images that are available in AKS always include a preinstalled NVIDIA GPU driver
and a preinstalled NVIDIA Container Toolkit.
These images reduce the primary benefit of installing the Operator so that it can
manage the lifecycle of these software components and others.

However, using the Operator can overcome the limitations identified in the preceding section.


***********************
Installing the Operator
***********************

After you start your Azure AKS cluster, you are ready to install the NVIDIA GPU Operator.

When you install the Operator, you must prevent the Operator from automatically
deploying NVIDIA Driver Containers and the NVIDIA Container Toolkit:

#. Install the Operator without the driver containers and toolkit:

   .. code-block:: console

      $ helm install gpu-operator nvidia/gpu-operator \
          -n gpu-operator --create namespace \
          --set driver.enabled=false \
          --set toolkit.enabled=false \
          --set operator.runtimeClass=nvidia-container-runtime

   Refer to :ref:`Chart Customization Options` for more information about installation options.

   *Example Output*

   .. code-block:: output

      NAME: gpu-operator
      LAST DEPLOYED: Fri May  5 15:30:05 2023
      NAMESPACE: gpu-operator
      STATUS: deployed
      REVISION: 1
      TEST SUITE: None

   The Operator requires several minutes to install.

#. Confirm that the Operator is installed and ran the CUDA validation container to completion:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator -l app=nvidia-cuda-validator

   *Example Output*

   .. code-block:: output

      NAME                          READY   STATUS      RESTARTS   AGE
      nvidia-cuda-validator-bpvkt   0/1     Completed   0          3m56s


**********
Next Steps
**********

* Refer to :ref:`Running Sample GPU Applications`
  for an example of running workloads on NVIDIA GPUs.
