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

######################################################
Container Device Interface Support in the GPU Operator
######################################################

.. contents::
   :depth: 2
   :local:
   :backlinks: none

************************************
About the Container Device Interface
************************************

The Container Device Interface (CDI) is a specification for container runtimes
such as cri-o, containerd, and podman that standardizes access to complex
devices like NVIDIA GPUs by the container runtimes.
CDI support is provided by the NVIDIA Container Toolkit and the Operator extends
that support for Kubernetes clusters.

Use of CDI is transparent to cluster administrators and application developers.
The benefits of CDI are largely to reduce development and support for runtime-specific
plugins.

When CDI is enabled, two runtime classes, nvidia-cdi and nvidia-legacy, become available.
These two runtime classes are in addition to the default runtime class, nvidia.

If you do not set CDI as the default runtime, the runtime resolves to the
legacy runtime mode that the NVIDIA Container Toolkit provides on x86_64
machines or any architecture that has NVML libraries installed.

Optionally, you can specify the runtime class for a workload.
See :ref:`Specifying the Runtime Class for a Pod` for an example.


Support for Multi-Instance GPU
==============================

Configuring CDI is supported with Multi-Instance GPU (MIG).
Both the ``single`` and ``mixed`` strategies are supported.


Limitations and Restrictions
============================

Enabling CDI is not supported with Red Hat OpenShift Container Platform.
Refer to the :ref:`Supported Operating Systems and Kubernetes Platforms`.


********************************
Enabling CDI During Installation
********************************

Follow the instructions for installing the Operator with Helm on the :doc:`operator-install-guide` page.

When you install the Operator with Helm, specify the ``--set cdi.enabled=true`` argument.
Optionally, also specify the ``--set cdi.default=true`` argument to use the CDI runtime class by default for all pods.


*******************************
Enabling CDI After Installation
*******************************

.. rubric:: Prerequisites

* You installed version 22.3.0 or newer.
* (Optional) Confirm that the only runtime class is ``nvidia`` by running the following command:

  .. code-block:: console

     $ kubectl get runtimeclasses

  **Example Output**

  .. code-block:: output

     NAME     HANDLER   AGE
     nvidia   nvidia    47h


.. rubric:: Procedure

To enable CDI support, perform the following steps:

#. Enable CDI by modifying the cluster policy:

   .. code-block:: console

     $ kubectl patch clusterpolicy/cluster-policy --type='json' \
         -p='[{"op": "replace", "path": "/spec/cdi/enabled", "value":true}]'

   *Example Output*

   .. code-block:: output

    clusterpolicy.nvidia.com/cluster-policy patched

#. (Optional) Set the default container runtime mode to CDI by modifying the cluster policy:

   .. code-block:: console

     $ kubectl patch clusterpolicy/cluster-policy --type='json' \
         -p='[{"op": "replace", "path": "/spec/cdi/default", "value":true}]'

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

#. Verify that the runtime classes include nvidia-cdi and nvidia-legacy:

   .. code-block:: console

     $ kubectl get runtimeclasses

   *Example Output*

   .. literalinclude:: ./manifests/output/cdi-verify-get-runtime-classes.txt
      :language: output


*************
Disabling CDI
*************

To disable CDI support, perform the following steps:

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

      $ kubectl patch clusterpolicy/cluster-policy --type='json' \
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

#. (Optional) Verify that the ``nvidia-cdi`` and ``nvidia-legacy`` runtime classes
   are no longer available:

   .. code-block:: console

      $ kubectl get runtimeclass

   *Example Output*

   .. code-block:: output

      NAME     HANDLER   AGE
      nvidia   nvidia    11d


************************************************
Optional: Specifying the Runtime Class for a Pod
************************************************

If you enabled CDI mode for the default container runtime, then no action is required to use CDI.
However, you can use the following procedure to specify the legacy mode for a workload if you experience trouble.

If you did not enable CDI mode for the default container runtime, then you can
use the following procedure to verify that CDI is enabled and as a
routine practice to use the CDI mode of the container runtime.

#. Create a file, such as ``cuda-vectoradd-cdi.yaml``, with contents like the following example:

   .. literalinclude:: ./manifests/input/cuda-vectoradd-cdi.yaml
      :language: yaml
      :emphasize-lines: 7

   As an alternative, specify ``nvidia-legacy`` to use the legacy mode of the container runtime.

#. (Optional) Create a temporary namespace:

   .. code-block:: console

     $ kubectl create ns demo

   *Example Output*

   .. code-block:: output

     namespace/demo created

#. Start the pod:

   .. code-block:: console

    $ kubectl apply -n demo -f cuda-vectoradd-cdi.yaml

   *Example Output*

   .. code-block:: output

     pod/cuda-vectoradd created

#. View the logs from the pod:

   .. code-block:: console

     $ kubectl logs -n demo cuda-vectoradd

   *Example Output*

   .. literalinclude:: ./manifests/output/common-cuda-vectoradd-logs.txt
      :language: output

#. Delete the temporary namespace:

  .. code-block:: console

    $ kubectl delete ns demo

  *Example Output*

  .. code-block:: output

    namespace "demo" deleted


*******************
Related Information
*******************

* For more information about CDI, see the container device interface
  `repository <https://github.com/container-orchestrated-devices/container-device-interface>`_
  on GitHub.
