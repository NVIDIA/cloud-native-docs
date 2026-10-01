.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
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

.. _install-gpu-operator-ipv6:

#####################################
Install GPU Operator in IPv6 Networks
#####################################

************************
About IPv6-Only Clusters
************************

You do not need any IPv6-specific configuration to install the Operator in an IPv6-only cluster.

The only exception is when you deploy DCGM separately from DCGM Exporter.
By default, DCGM Exporter runs an embedded DCGM host engine, ``nv-hostengine``, inside the exporter container.
If you set ``dcgm.enabled`` to ``true``, the Operator deploys DCGM as a separate ``nvidia-dcgm`` daemon set.
DCGM Exporter then connects to the host engine through the ``nvidia-dcgm`` service on port ``5555``.
In an IPv6-only cluster, you must configure the separate host engine to listen on IPv6 addresses.

*******************************************
Configure Standalone DCGM for IPv6 Clusters
*******************************************

The DCGM container starts the host engine with the ``-b 0.0.0.0`` argument by default.
This argument binds the host engine to IPv4 addresses only.
In an IPv6-only cluster, DCGM Exporter cannot connect to the host engine and the exporter pods go into ``CrashLoopBackOff``.

To bind the host engine to IPv6 addresses, set ``dcgm.args`` and specify ``::`` as the bind address.
The ``::`` value binds the host engine to all interfaces for IPv4 and IPv6.
The values in ``dcgm.args`` replace the default container arguments, so you must specify the complete argument list.

.. rubric:: Prerequisites

* GPU Operator v26.7.1 or later.
  Earlier versions include a DCGM Exporter that cannot resolve the ``nvidia-dcgm`` service name to an IPv6 address.

.. rubric:: Procedure

#. Create a file, such as ``dcgm-values.yaml``, with the following content:

   .. code-block:: yaml

      dcgm:
        enabled: true
        args:
          - "-n"
          - "-b"
          - "::"
          - "--log-level"
          - "NONE"
          - "-f"
          - "-"

#. Install the Operator with the values file:

   .. code-block:: console

      $ helm install --wait --generate-name \
          -n gpu-operator --create-namespace \
          nvidia/gpu-operator \
          --version=${version} \
          -f dcgm-values.yaml

   If the Operator is already installed, you can patch the cluster policy instead:

   .. code-block:: console

      $ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type=merge \
          -p '{"spec":{"dcgm":{"enabled":true,"args":["-n","-b","::","--log-level","NONE","-f","-"]}}}'
