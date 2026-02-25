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

#################################################################################
Container Device Interface (CDI) and Node Resource Interface (NRI) Plugin Support
#################################################################################

This page gives an overview of CDI and NRI Plugin support in the GPU Operator.

**************************************
About Container Device Interface (CDI)
**************************************

The `Container Device Interface (CDI) <https://github.com/cncf-tags/container-device-interface/blob/main/SPEC.md>`_
is an open specification for container runtimes that abstracts what access to a device, such as an NVIDIA GPU, means,
and standardizes access across container runtimes. Popular container runtimes can read and process the specification to
ensure that a device is available in a container. CDI simplifies adding support for devices such as NVIDIA GPUs because
the specification is applicable to all container runtimes that support CDI.

Starting with GPU Operator v25.10.0, CDI is used by default for enabling GPU support in containers running on Kubernetes.
Specifically, CDI support in container runtimes, like containerd and cri-o, is used to inject GPU(s) into workload
containers. This differs from prior GPU Operator releases where CDI was used via a CDI-enabled ``nvidia`` runtime class.

Use of CDI is transparent to cluster administrators and application developers.
The benefits of CDI are largely to reduce development and support for runtime-specific
plugins.

************
Enabling CDI 
************

CDI is enabled by default during installation in GPU Operator v25.10.0 and later.
Follow the instructions for installing the Operator with Helm on the :doc:`getting-started` page.

CDI is also enabled by default during a Helm upgrade to GPU Operator v25.10.0 and later.

Enabling CDI After Installation
*******************************

CDI is enabled by default in GPU Operator v25.10.0 and later.
Use the following procedure to enable CDI if you disabled CDI during installation.

.. rubric:: Procedure

#. Enable CDI by modifying the cluster policy:

   .. code-block:: console

     $ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type='json' \
         -p='[{"op": "replace", "path": "/spec/cdi/enabled", "value":true}]'

   *Example Output*

   .. code-block:: output

    clusterpolicy.nvidia.com/cluster-policy patched

#. (Optional) Confirm that the container toolkit and device plugin pods restart:

   .. code-block:: console

     $ kubectl get pods -n gpu-operator

   *Example Output*

   .. literalinclude:: ./manifests/output/cdi-get-pods-restart.txt
      :language: output
      :emphasize-lines: 6,9


*************
Disabling CDI
*************

While CDI is the default and recommended mechanism for injecting GPU support into containers, you can
disable CDI and use the legacy NVIDIA Container Toolkit stack instead with the following procedure:

#. If your nodes use the CRI-O container runtime, then temporarily disable the
   GPU Operator validator:

   .. code-block:: console

      $ kubectl label nodes \
          nvidia.com/gpu.deploy.operator-validator=false \
          -l nvidia.com/gpu.present=true \
          --overwrite

   .. tip::

      You can run ``kubectl get nodes -o wide`` and view the ``CONTAINER-RUNTIME``
      column to determine if your nodes use CRI-O.

#. Disable CDI by modifying the cluster policy:

   .. code-block:: console

      $ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type='json' \
          -p='[{"op": "replace", "path": "/spec/cdi/enabled", "value":false}]'

   *Example Output*

   .. code-block:: output

      clusterpolicy.nvidia.com/cluster-policy patched

#. If you temporarily disabled the GPU Operator validator, re-enable the validator:

   .. code-block:: console

      $ kubectl label nodes \
          nvidia.com/gpu.deploy.operator-validator=true \
          nvidia.com/gpu.present=true \
          --overwrite


.. _nri-plugin:

**********************************************
About the Node Resource Interface (NRI) Plugin
**********************************************

Node Resource Interface (NRI) is a standardized interface for plugging in extensions, called NRI Plugins, to OCI-compatible container runtimes like CRI-O and containerd. 
NRI Plugins serve as hooks which intercept pod and container lifecycle events and perform functions including inject devices (CDI devices, Linux device nodes, device mounts) to a container, topology aware placement strategies, and more.
For more details on NRI, refer to the `NRI overview <https://github.com/containerd/nri/tree/main?tab=readme-ov-file#background>`_ in the containerd repository.

When enabled in the GPU Operator, the NRI Plugin, managed by the NVIDIA Container Toolkit, provides an alternative to the ``nvidia`` runtime class to provision GPU workload pods. 
It allows the GPU Operator to extend the container runtime behaviour without modifying the container runtime.
This feature also simplifies deployments on platforms like k3s, k0s, or RKE, because the GPU Operator no longer needs setting of values like ``CONTAINERD_CONFIG``, ``CONTAINERD_SOCKET``, or ``RUNTIME_CONFIG_SOURCE``.

***********************
Enabling the NRI Plugin
***********************

The NRI Plugin requires the following:

- CDI to be enabled in the GPU Operator.

- CRI-O v1.34.0 or later or containerd v1.7.30, v2.1.x, or v2.2.x.
  If you are not using the latest containerd version, check that both CDI and NRI are enabled in the containerd configuration file before deploying GPU Operator.

To enable the NRI Plugin during installation, follow the instructions for installing the Operator with Helm on the :doc:`getting-started` page and include the ``--set  cdi.nriPluginEnabled=true`` argument in you Helm command. 

Enabling the NRI Plugin After Installation
******************************************

#. Enable NRI Plugin by modifying the cluster policy:

   .. code-block:: console

     $ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type='json' \
         -p='[{"op": "replace", "path": "/spec/cdi/nriPluginEnabled", "value":true}]'

   *Example Output*

   .. code-block:: output

    clusterpolicy.nvidia.com/cluster-policy patched

#. (Optional) Confirm that the container toolkit and device plugin pods restart:

   .. code-block:: console

     $ kubectl get pods -n gpu-operator

   *Example Output*

   .. literalinclude:: ./manifests/output/nri-get-pods-restart.txt
      :language: output
      :emphasize-lines: 6,9


************************
Disabling the NRI Plugin
************************

Disable the NRI Plugin and use the ``nvidia`` runtime class instead with the following procedure:

Disable the NRI Plugin by modifying the cluster policy:

.. code-block:: console

   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type='json' \
         -p='[{"op": "replace", "path": "/spec/cdi/nriPluginEnabled", "value":false}]'

*Example Output*

.. code-block:: output

   clusterpolicy.nvidia.com/cluster-policy patched
