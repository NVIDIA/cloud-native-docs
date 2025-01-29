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

.. Date: Jan 17 2021
.. Author: smerla

.. _install-gpu-operator-vgpu:

#################
Using NVIDIA vGPU
#################


*********************************************
About Installing the Operator and NVIDIA vGPU
*********************************************

NVIDIA Virtual GPU (vGPU) enables multiple virtual machines (VMs) to have simultaneous,
direct access to a single physical GPU, using the same NVIDIA graphics drivers that are
deployed on non-virtualized operating systems.

The installation steps assume ``gpu-operator`` as the default namespace for installing the NVIDIA GPU Operator.
In case of Red Hat OpenShift Container Platform, the default namespace is ``nvidia-gpu-operator``.
Change the namespace shown in the commands accordingly based on your cluster configuration.
Also replace ``kubectl`` in the below commands with ``oc`` when running on RedHat OpenShift.

NVIDIA vGPU is only supported with the NVIDIA License System.

****************
Platform Support
****************

For information about the supported platforms, see :ref:`Supported Deployment Options, Hypervisors, and NVIDIA vGPU Based Products`.

For Red Hat OpenShift Virtualization, see :ref:`NVIDIA GPU Operator with OpenShift Virtualization`.


*************
Prerequisites
*************

Before installing the GPU Operator on NVIDIA vGPU, ensure the following:

* The NVIDIA vGPU Host Driver version 12.0 (or later) is pre-installed on all hypervisors hosting NVIDIA vGPU accelerated Kubernetes worker node virtual machines.
  Refer to `NVIDIA Virtual GPU Software Documentation <https://docs.nvidia.com/grid/>`_ for details.
* You must have access to the NVIDIA Enterprise Application Hub at https://nvid.nvidia.com/dashboard/ and the NVIDIA Licensing Portal.
* Your organization must have an instance of a Cloud License Service (CLS) or a Delegated License Service (DLS).
* You must generate and download a client configuration token for your CLS instance or DLS instance.
  Refer to the |license-system-qs-guide-link|_ for information about generating a token.
* You have access to a private registry, such as NVIDIA NGC Private Registry, and can push container images to the registry.
* Git and Docker or Podman are required to build the vGPU driver image from source repository and push to the private registry.
* Each Kubernetes worker node in the cluster has access to the private registry.
  Private registry access is usually managed through image pull secrets.
  You specify the secrets to the NVIDIA GPU Operator when you install the Operator with Helm.

  .. note::

     Uploading the NVIDIA vGPU driver to a publicly available repository or otherwise publicly sharing the driver is a violation of the NVIDIA vGPU EULA.

.. _license-system-qs-guide-link: https://docs.nvidia.com/license-system/latest/nvidia-license-system-quick-start-guide/
.. |license-system-qs-guide-link| replace:: *NVIDIA License System Quick Start Guide*


**********************
Download vGPU Software
**********************

Perform the following steps to download the vGPU software and the latest NVIDIA vGPU driver catalog file from the NVIDIA Licensing Portal.

#. Log in to the NVIDIA Enterprise Application Hub at https://nvid.nvidia.com/dashboard and then click **NVIDIA LICENSING PORTAL**.
#. In the left navigation pane of the NVIDIA Licensing Portal, click **SOFTWARE DOWNLOADS**.
#. Locate **vGPU Driver Catalog** in the table of driver downloads and click **Download**.
#. Click the **PRODUCT FAMILY** menu and select **vGPU** to filter the downloads to vGPU only.
#. Locate the vGPU software for your platform in the table of software downloads and click **Download**.

The vGPU software is packaged as a ZIP file.
Unzip the file to obtain the NVIDIA vGPU Linux guest driver.
The guest driver file name follows the pattern ``NVIDIA-Linux-x86_64-<version>-grid.run``.

**************************
Build the Driver Container
**************************

Perform the following steps to build and push a container image that includes the vGPU Linux guest driver.

#. Clone the driver container repository and change directory into the repository:

   .. code-block:: console

      $ git clone https://gitlab.com/nvidia/container-images/driver

   .. code-block:: console

      $ cd driver

#. Change directory to the operating system name and version under the driver directory:

   .. code-block:: console

      $ cd ubuntu20.04

   For Red Hat OpenShift Container Platform, use a directory that includes ``rhel`` in the directory name.

#. Copy the NVIDIA vGPU guest driver from your extracted ZIP file and the NVIDIA vGPU driver catalog file:

   .. code-block:: console

      $ cp <local-driver-download-directory>/*-grid.run drivers/

   .. code-block:: console

      $ cp vgpuDriverCatalog.yaml drivers/

#. Set environment variables for building the driver container image.

   -  Specify your private registry URL:

      .. code-block:: console

         $ export PRIVATE_REGISTRY=<private-registry-url>

   - Specify the ``OS_TAG`` environment variable to identify the guest operating system name and version:


     .. code-block:: console

        $ export OS_TAG=ubuntu20.04

     The value must match the guest operating system version.
     For Red Hat OpenShift Container Platform, specify ``rhcos4.<x>`` where ``x`` is the supported minor OCP version.
     Refer to :ref:`Supported Operating Systems and Kubernetes Platforms` for the list of supported OS distributions.

   - Specify the driver container image tag, such as ``1.0.0``:

     .. code-block:: console

        $ export VERSION=1.0.0

     The specified value can be any user-defined value.
     The value is used to install the Operator in a subsequent step.

   - Specify the version of the CUDA base image to use when building the driver container:

     .. code-block:: console

        $ export CUDA_VERSION=11.8.0

     The CUDA version only specifies which base image is used to build the driver container.
     The version does not have any correlation to the version of CUDA that is associated with or supported by the
     resulting driver container.

   - Specify the Linux guest vGPU driver version that you downloaded from the NVIDIA Licensing Portal and append ``-grid``:

     .. code-block:: console

        $ export VGPU_DRIVER_VERSION=525.60.13-grid

     The Operator automatically selects the compatible guest driver version from the drivers bundled with the ``driver`` image.
     If you disable the version check by specifying ``--build-arg DISABLE_VGPU_VERSION_CHECK=true`` when you build the driver image,
     then the ``VGPU_DRIVER_VERSION`` value is used as default.

#. Build the driver container image:

   .. code-block:: console

      $ sudo docker build \
          --build-arg DRIVER_TYPE=vgpu \
          --build-arg DRIVER_VERSION=$VGPU_DRIVER_VERSION \
          --build-arg CUDA_VERSION=$CUDA_VERSION \
          --build-arg TARGETARCH=amd64 \  # amd64 or arm64
          -t ${PRIVATE_REGISTRY}/driver:${VERSION}-${OS_TAG} .

#. Push the driver container image to your private registry.

   #. Log in to your private registry:

      .. code-block:: console

         $ sudo docker login ${PRIVATE_REGISTRY} --username=<username>

      Enter your password when prompted.

   #. Push the driver container image to your private registry:

      .. code-block:: console

         $ sudo docker push ${PRIVATE_REGISTRY}/driver:${VERSION}-${OS_TAG}


**************************************************************************************
Configure the Cluster with the vGPU License Information and the Driver Container Image
**************************************************************************************

#. Create an NVIDIA vGPU license file named ``gridd.conf`` with contents like the following example:

   .. code-block:: text

      # Description: Set Feature to be enabled
      # Data type: integer
      # Possible values:
      # 0 => for unlicensed state
      # 1 => for NVIDIA vGPU
      # 2 => for NVIDIA RTX Virtual Workstation
      # 4 => for NVIDIA Virtual Compute Server
      FeatureType=1

#. Rename the client configuration token file that you downloaded to ``client_configuration_token.tok``
   using a command like the following example:

   .. code-block:: console

      $ cp ~/Downloads/client_configuration_token_03-28-2023-16-16-36.tok client_configuration_token.tok

   The file must be named ``client_configuraton_token.tok``.

#. Create the ``gpu-operator`` namespace:

   .. code-block:: console

      $ kubectl create namespace gpu-operator

#. Create a config map that is named ``licensing-config`` using the ``gridd.conf`` and ``client_configuration_token.tok`` files:

   .. code-block:: console

      $ kubectl create configmap licensing-config \
          -n gpu-operator --from-file=gridd.conf --from-file=client_configuration_token.tok

#. Create an image pull secret in the ``gpu-operator`` namespace with the registry secret and private registry.


   #. Set an environment variable with the name of the secret:

      .. code-block:: console

         $ export REGISTRY_SECRET_NAME=registry-secret

   #. Create the secret:

      .. code-block:: console

         $ kubectl create secret docker-registry ${REGISTRY_SECRET_NAME} \
             --docker-server=${PRIVATE_REGISTRY} --docker-username=<username> \
             --docker-password=<password> \
             --docker-email=<email-id> -n gpu-operator

   You need to specify the secret name ``REGISTRY_SECRET_NAME`` when you install the GPU Operator with Helm.


********************
Install the Operator
********************

- Install the Operator:

  .. code-block:: console

     $ helm install --wait --generate-name \
          -n gpu-operator --create-namespace \
          nvidia/gpu-operator \
          --set driver.repository=${PRIVATE_REGISTRY} \
          --set driver.version=${VERSION} \
          --set driver.imagePullSecrets={$REGISTRY_SECRET_NAME} \
          --set driver.licensingConfig.configMapName=licensing-config

The preceding command installs the Operator with the default configuration.
Refer to :ref:`gpu-operator-helm-chart-options` for information about configuration options.


**********
Next Steps
**********

- :ref:`verify gpu operator install`
