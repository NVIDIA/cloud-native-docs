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

.. _install-precompiled-drivers:

#############################
Precompiled Driver Containers
#############################

.. contents::
   :depth: 2
   :local:
   :backlinks: none

***********************************
About Precompiled Driver Containers
***********************************

.. note:: Technology Preview features are not supported in production environments
          and are not functionally complete.
          Technology Preview features provide early access to upcoming product features,
          enabling customers to test functionality and provide feedback during the development process.
          These releases may not have any documentation, and testing is limited.


Containers with precompiled drivers do not require internet access to download Linux kernel
header files, GCC compiler tooling, or operating system packages.

Using precompiled drivers also avoids the burst of compute demand that is required
to compile the kernel drivers with the conventional driver containers.

These two benefits are valuable to most sites, but are especially beneficial to sites
with restricted internet access or sites with resource-constrained hardware.


Limitations and Restrictions
============================

* Support for deploying the driver containers with precompiled drivers is limited to
  hosts with the Ubuntu 22.04 operating system and x86_64 architecture.

* NVIDIA supports precompiled driver containers for the most recently released long-term
  servicing branch (LTSB) driver branch, 525.

* NVIDIA builds images for the ``generic`` kernel variant.
  If your hosts run a different kernel variant, you can build a precompiled driver image
  and use your own container registry.

* Precompiled driver containers do not support NVIDIA vGPU or GPUDirect Storage (GDS).


**********************************************************
Determining if a Precompiled Driver Container is Available
**********************************************************

The precompiled driver containers are named according to the following pattern:

   <driver-branch>-<linux-kernel-version>-<os-tag>

For example, ``525-5.15.0-69-generic-ubuntu22.04``.

Use one of the following ways to check if a driver container is available for your Linux kernel and driver branch:

* Use a web browser to access the NVIDIA GPU Driver page of the NVIDIA GPU Cloud registry at
  https://catalog.ngc.nvidia.com/orgs/nvidia/containers/driver/tags.
  Use the search field to filter the tags by your operating system version.

* Use the `NGC CLI <https://ngc.nvidia.com/setup/installers/cli>`_ tool to list the tags for the driver container:

  .. code-block:: console

     $ ngc registry image info nvidia/driver

  *Example Output*

  .. code-block:: output

     Image Repository Information
       Name: driver
       Display Name: NVIDIA GPU Driver
       Short Description: Provision NVIDIA GPU Driver as a Container.
       Built By: NVIDIA
       Publisher: NVIDIA
       Multinode Support: False
       Multi-Arch Support: True
       Logo: https://assets.nvidiagrid.net/ngc/logos/Infrastructure.png
       Labels: Multi-Arch, NVIDIA AI Enterprise Supported, Infrastructure Software, Kubernetes Infrastructure
       Public: Yes
       Last Updated: Apr 20, 2023
       Latest Image Size: 688.87 MB
       Latest Tag: 525-5.15.0-69-generic-ubuntu22.04
       Tags:
           525-5.15.0-69-generic-ubuntu22.04
           525-5.15.0-70-generic-ubuntu22.04
           ...


*****************************************************************
Enabling Precompiled Driver Container Support During Installation
*****************************************************************

Follow the instructions for installing the Operator with Helm on the :doc:`operator-install-guide` page.

Specify the ``--set driver.usePrecompiled=true`` and ``--set driver.version=<driver-branch>`` arguments like the following example command:

.. code-block:: console

   $ helm install --wait gpu-operator \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set driver.usePrecompiled=true \
        --set driver.version="<driver-branch>"
    
Specify a value like ``525`` for ``<driver-branch>``.
Refer to :ref:`Chart Customization Options` for information about other installation options.


***********************************
Enabling Support After Installation
***********************************

Perform the following steps to enable support for precompiled driver containers:

#. Enable support by modifying the cluster policy:

   .. code-block:: console

     $ kubectl patch clusterpolicy/cluster-policy --type='json' \
         -p='[
           {"op":"replace", "path":"/spec/driver/usePrecompiled", "value":true},
           {"op":"replace", "path":"/spec/driver/version", "value":"<driver-branch>"}
         ]'

   Specify a value like ``525`` for ``<driver-branch>``.

   *Example Output*

   .. code-block:: output

    clusterpolicy.nvidia.com/cluster-policy patched

#. (Optional) Confirm that the driver daemonset pods terminate:

   .. code-block:: console

     $ kubectl get pods -n gpu-operator

   *Example Output*

   .. literalinclude:: ./manifests/output/precomp-driver-terminating.txt
      :language: output
      :emphasize-lines: 11

#. Confirm that the driver container pods are running:

   .. code-block:: console

      $ kubectl get pods -l app=nvidia-driver-daemonset -n gpu-operator

   *Example Output*

   .. literalinclude:: ./manifests/output/precomp-driver-running.txt
      :language: output

   Ensure that the pod names include a Linux kernel semantic version number like ``5.15.0-69-generic``.


***************************************************
Disabling Support for Precompiled Driver Containers
***************************************************

Perform the following steps to disable support for precompiled driver containers:

#. Disable support by modifying the cluster policy:

   .. code-block:: console

     $ kubectl patch clusterpolicy/cluster-policy --type='json' \
         -p='[{"op": "replace", "path": "/spec/driver/usePrecompiled", "value":false}]'

   *Example Output*

   .. code-block:: output

    clusterpolicy.nvidia.com/cluster-policy patched


#. Confirm that the conventional driver container pods are running:

   .. code-block:: console

      $ kubectl get pods -l app=nvidia-driver-daemonset -n gpu-operator

   *Example Output*

   .. literalinclude:: ./manifests/output/precomp-driver-conventional-running.txt
      :language: output

   Ensure that the pod names do not include a Linux kernel semantic version number.


****************************************
Building a Custom Driver Container Image
****************************************

If a precompiled driver container for your Linux kernel variant is not available,
you can perform the following steps to build and run a container image.

.. note::

   NVIDIA provides limited support for custom driver container images.

.. rubric:: Prerequisites

* You have access to a private container registry, such as NVIDIA NGC Private Registry, and can push container images to the registry.
* Your build machine has access to the internet to download operating system packages.
* You know a CUDA version, such as ``12.1.0``, that you want to use.
  The CUDA version only specifies which base image is used to build the driver container.
  The version does not have any correlation to the version of CUDA that is associated with or supported by the resulting driver container.

  One way to find a supported CUDA version for your operating system is to access the NVIDIA GPU Cloud registry
  at https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda/tags and view the tags.
  Use the search field to filter the tags, such as ``base-ubuntu22.04``.
  The filtered results show the CUDA versions, such as ``12.1.0``, ``12.0.1``, ``12.0.0``, and so on.
* You know the GPU driver branch, such as ``525``, that you want to use.

.. rubric:: Procedure

#. Clone the driver container repository and change directory into the repository:

   .. code-block:: console

      $ git clone https://gitlab.com/nvidia/container-images/driver

   .. code-block:: console

      $ cd driver

#. Change directory to the operating system name and version under the driver directory:

   .. code-block:: console

      $ cd ubuntu22.04/precompiled

#. Set environment variables for building the driver container image.

   -  Specify your private registry URL:

      .. code-block:: console

         $ export PRIVATE_REGISTRY=<private-registry-url>

   - Specify the ``KERNEL_VERSION`` environment variable that matches your kernel variant, such as ``5.15.0-1033-aws``:

     .. code-block:: console

        $ export KERNEL_VERSION=5.15.0-1033-aws

   - Specify the version of the CUDA base image to use when building the driver container:

     .. code-block:: console

        $ export CUDA_VERSION=12.1.0

   - Specify the driver branch, such as ``525``:

     .. code-block:: console

        $ export DRIVER_BRANCH=525

   - Specify the ``OS_TAG`` environment variable to identify the guest operating system name and version:

     .. code-block:: console

        $ export OS_TAG=ubuntu22.04

     The value must match the guest operating system version.

#. Build the driver container image:

   .. code-block:: console

      $ sudo docker build \
          --build-arg KERNEL_VERSION=$KERNEL_VERSION \
          --build-arg CUDA_VERSION=$CUDA_VERSION \
          --build-arg DRIVER_BRANCH=$DRIVER_BRANCH \
          -t ${PRIVATE_REGISTRY}/driver:${DRIVER_BRANCH}-${KERNEL_VERSION}-${OS_TAG} .

#. Push the driver container image to your private registry.

   - Log in to your private registry:

     .. code-block:: console

        $ sudo docker login ${PRIVATE_REGISTRY} --username=<username>

     Enter your password when prompted.

   - Push the driver container image to your private registry:

     .. code-block:: console

        $ sudo docker push ${PRIVATE_REGISTRY}/driver:${DRIVER_BRANCH}-${KERNEL_VERSION}-${OS_TAG}

.. rubric:: Next Steps

* To use the custom driver container image, follow the steps for enabling support during or after installation.

  If you have not already installed the GPU Operator, in addition to the ``--set driver.usePrecompiled=true``
  and ``--set driver.version=${DRIVER_BRANCH}`` arguments for Helm, also specify the ``--set driver.repository="$PRIVATE_REGISTRY"`` argument.

  If the container registry is not public, you need to create an image pull secret in the GPU operator namespace
  and specify it in the ``--set driver.imagePullSecrets=<pull-secret>`` argument.

  If you already installed the GPU Operator, specify the private registry for the driver in the cluster policy:

  .. code-block:: console

     $ kubectl patch clusterpolicy/cluster-policy --type='json' \
         -p='[{"op": "replace", "path": "/spec/driver/repository", "value":"$PRIVATE_REGISTRY"}]'