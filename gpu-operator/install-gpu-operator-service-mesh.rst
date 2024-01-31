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

You can use NVIDIA GPU Operator in a cluster that uses a service mesh provided by Istio CNI or Linkerd CNI.

The typical consideration for using the Operator with a service mesh is that the ``k8s-driver-manager`` init container
for the ``driver`` container needs network access to the Kubernetes API server of the cluster.

The data plane---implemented by Istio CNI or Linkerd CNI as proxies running as sidecar containers---must be running for any pod networking to work.
The proxy sidecar containers start only after the init phase of the pod, so init containers are not able to communicate with the API server.

To address the connectivity challenge, NVIDIA recommends disabling injection for the GPU Operator namespace.
Refer to the following documentation for more information:

- `Controlling the injection policy <https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#controlling-the-injection-policy>`_
  in the Istio documentation.
- `Overriding injection <https://linkerd.io/2.14/features/proxy-injection/#overriding-injection>`_
  in the Linkerd documentation.


****************************************
Label the Namespace to Disable Injection
****************************************

- Label the Operator namespace to prevent automatic injection:

  .. code-block:: console

     $ kubectl label namespace gpu-operator istio-injection=disabled

  Or, for Linkerd:

  .. code-block:: console

     $ kubectl label namespace gpu-operator linkerd.io/inject=disabled


If the GPU Operator is not already installed, refer to
:doc:`getting-started`
for information about custom options and common installation scenarios.
