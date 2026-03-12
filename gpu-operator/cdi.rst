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

############################################################
Container Device Interface (CDI) Support in the GPU Operator
############################################################

************************************
About the Container Device Interface
************************************

The `Container Device Interface (CDI) <https://github.com/cncf-tags/container-device-interface/blob/main/SPEC.md>`_
is an open specification for container runtimes that abstracts what access to a device, such as an NVIDIA GPU, means,
and standardizes access across container runtimes. Popular container runtimes can read and process the specification to
ensure that a device is available in a container. CDI simplifies adding support for devices such as NVIDIA GPUs because
the specification is applicable to all container runtimes that support CDI.

Starting with GPU Operator v25.10.0, CDI is used by default for enabling GPU support in containers running on Kubernetes.
Specifically, CDI support in container runtimes, e.g. containerd and cri-o, is used to inject GPU(s) into workload
containers. This differs from prior GPU Operator releases where CDI was used via a CDI-enabled ``nvidia`` runtime class.

If you are upgrading from a version of the GPU Operator prior to v25.10.0, where CDI was disabled by default, and you are upgrading to v25.10.0 or later, where CDI is enabled by default, no configuration changes are required for standard workloads using GPU allocation through the Device Plugin.
For workloads that already have ``runtimeClassName: nvidia`` set in their pod spec YAML, no change is necessary.

Use of CDI is transparent to cluster administrators and application developers.
The benefits of CDI are largely to reduce development and support for runtime-specific
plugins.


CDI and GPU Management Containers
*****************************

When CDI is enabled in GPU Operator versions v25.10.0 and later, GPU Management Containers that use the ``NVIDIA_VISIBLE_DEVICES`` environment variable to get GPU access, bypassing GPU allocation via the Device Plugin, must set ``runtimeClassName: nvidia`` in the pod specification.
A GPU Management Containers is a container that requires access to all GPUs without them being allocated by Kubernetes. 
Examples of GPU Management Containers include monitoring agents and device plugins.

It is recommended that ``NVIDIA_VISIBLE_DEVICES`` only be used by management containers.

********************************
Enabling CDI During Installation
********************************

CDI is enabled by default during installation in GPU Operator v25.10.0 and later.
Follow the instructions for installing the Operator with Helm on the :doc:`getting-started` page.

CDI is also enabled by default during a Helm upgrade to GPU Operator v25.10.0 and later.

*******************************
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
