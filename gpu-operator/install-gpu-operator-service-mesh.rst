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

######################################
Install GPU Operator with Service Mesh
######################################

.. contents::
   :depth: 2
   :local:
   :backlinks: none


*****************************************
Special Considerations for Service Meshes
*****************************************

This page describes how to successfully deploy the NVIDIA GPU Operator in clusters that use service meshes such as
Istio and Linkerd.

The typical consideration for using the Operator with a service mesh is that the init container
for the ``driver`` container needs to download several OS packages prior to driver installation.

The Istio CNI plugin and Linkerd CNI plugin can cause networking connectivity problems with application init containers.
To address the connectivity problems, NVIDIA recommends disabling injection for the GPU Operator namespace.
Refer to the following documentation for more information:

- `Controlling the injection policy <https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#controlling-the-injection-policy>`_
  in the Istio documentation.
- `Overriding injection <https://linkerd.io/2.14/features/proxy-injection/#overriding-injection>`_
  in the Linkerd documentation.


***************************************
Deploy GPU Operator with a Service Mesh
***************************************

#. Create the GPU Operator namespace:

   .. code-block:: console

      $ kubectl create namespace gpu-operator

#. Label the Operator namespace to prevent automatic injection:

   .. code-block:: console

      $ kubectl label namespace gpu-operator istio-injection=disabled

   Or, for Linkerd:

   .. code-block:: console

      $ kubectl label namespace gpu-operator linkerd.io/inject=disabled


#. Install the Operator with Helm:

   .. code-block:: console

      $ helm install --wait --generate-name \
          -n gpu-operator --create-namespace \
          nvidia/gpu-operator

   Refer to the common :doc:`installation <getting-started>` documentation
   for information about custom options and common installation scenarios.
