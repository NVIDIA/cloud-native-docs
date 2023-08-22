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

.. Date: Aug 18 2021
.. Author: cdesiniotis

.. _install-gpu-operator-nvaie:

#####################
NVIDIA AI Enterprise
#####################

.. contents::
   :local:
   :depth: 2
   :backlinks: none


**************************************************
About NVIDIA AI Enterprise and Supported Platforms
**************************************************

NVIDIA AI Enterprise is an end-to-end, cloud-native suite of AI and data analytics software, optimized, certified, and supported by NVIDIA with NVIDIA-Certified Systems.
Additional information can be found at the `NVIDIA AI Enterprise <https://www.nvidia.com/en-us/data-center/products/ai-enterprise-suite/>`_ web page.

NVIDIA AI Enterprise customers have access to a pre-configured GPU Operator within the NVIDIA Enterprise Catalog.
The GPU Operator is pre-configured to simplify the provisioning experience with NVIDIA AI Enterprise deployments.

The pre-configured GPU Operator differs from the GPU Operator in the public NGC catalog. The differences are:

  * It is configured to use a prebuilt vGPU driver image (Only available to NVIDIA AI Enterprise customers)

  * It is configured to use the `NVIDIA License System (NLS) <https://docs.nvidia.com/license-system/latest/>`_

The following sections apply to the following configurations:

* Kubernetes on bare metal and on vSphere VMs with GPU passthrough and vGPU
* VMware vSphere with Tanzu

NVIDIA AI Enterprise includes support for Red Hat OpenShift Container Platform.

* OpenShift Container Platform on bare metal or VMware vSphere with GPU Passthrough
* OpenShift Container Platform on VMware vSphere with NVIDIA vGPU

For Red Hat OpenShift, refer to :doc:`openshift/nvaie-with-ocp`.


***********************
Installing GPU Operator
***********************

To install GPU Operator with NVIDIA AI Enterprise, apply the following steps.

.. note::

   You can also use the following `script <https://raw.githubusercontent.com/NVIDIA/gpu-operator/master/scripts/install-gpu-operator-nvaie.sh>`_, which automates the below installation instructions.
   Create the ``gpu-operator`` namespace:

.. code-block:: console

    $ kubectl create namespace gpu-operator

Create an empty vGPU license configuration file:

.. code-block:: console

  $ sudo touch gridd.conf

Generate and download a NLS client license token. Please refer to Section 4.6 of the `NLS User Guide <https://docs.nvidia.com/license-system/latest/pdf/nvidia-license-system-user-guide.pdf>`_ for instructions.

Rename the NLS client license token that you downloaded to ``client_configuration_token.tok``.

Create the ``licensing-config`` ConfigMap object in the ``gpu-operator`` namespace. Both the vGPU license
configuration file and the NLS client license token will be added to this ConfigMap:

.. code-block:: console

    $ kubectl create configmap licensing-config \
        -n gpu-operator --from-file=gridd.conf --from-file=<path>/client_configuration_token.tok

Create an image pull secret in the ``gpu-operator`` namespace for the private
registry that contains the containerized NVIDIA vGPU software graphics driver for Linux for
use with NVIDIA GPU Operator:

  * Set the registry secret name:

  .. code-block:: console

    $ export REGISTRY_SECRET_NAME=ngc-secret


  * Set the private registry name:

  .. code-block:: console

    $ export PRIVATE_REGISTRY=nvcr.io/nvaie

  * Create an image pull secret in the ``gpu-operator`` namespace with the registry
    secret name and the private registry name that you set. Replace ``password``,
    and ``email-address`` with your NGC API key and email address respectively:

  .. code-block:: console

    $ kubectl create secret docker-registry ${REGISTRY_SECRET_NAME} \
        --docker-server=${PRIVATE_REGISTRY} \
        --docker-username='$oauthtoken' \
        --docker-password='<password>' \
        --docker-email='<email-address>' \
        -n gpu-operator


Add the NVIDIA AI Enterprise Helm repository, where password is the NGC API key for accessing the NVIDIA Enterprise Collection that you generated:

.. code-block:: console

  $ helm repo add nvaie https://helm.ngc.nvidia.com/nvaie \
    --username='$oauthtoken' --password='<password>' \
    && helm repo update


Install the NVIDIA GPU Operator:

.. code-block:: console

   $ helm install --wait gpu-operator nvaie/gpu-operator-<M>-<m> -n gpu-operator

Replace *M* and *m* with the major and minor release values, such as ``3-1``.

To deploy the Helm chart with some customizations, refer to
:ref:`Chart Customization Options <gpu-operator-helm-chart-options>`.


*********************************************************************
Installing GPU Operator with the NVIDIA Datacenter Driver
*********************************************************************

To install GPU Operator on baremetal with the NVIDIA Datacenter Driver, apply the following steps.

.. note::

   You can also use the following `script <https://raw.githubusercontent.com/NVIDIA/gpu-operator/master/scripts/install-gpu-operator-nvaie.sh>`_, which automates the below installation instructions.
   Create the ``gpu-operator`` namespace:

.. code-block:: console

    $ kubectl create namespace gpu-operator


Create an image pull secret in the ``gpu-operator`` namespace for the private
registry that contains the NVIDIA GPU Operator:

  * Set the registry secret name:

  .. code-block:: console

    $ export REGISTRY_SECRET_NAME=ngc-secret


  * Set the private registry name:

  .. code-block:: console

    $ export PRIVATE_REGISTRY=nvcr.io/nvaie

  * Create an image pull secret in the ``gpu-operator`` namespace with the registry
    secret name and the private registry name that you set. Replace ``password``,
    and ``email-address`` with your NGC API key and email address respectively:

  .. code-block:: console

    $ kubectl create secret docker-registry ${REGISTRY_SECRET_NAME} \
        --docker-server=${PRIVATE_REGISTRY} \
        --docker-username='$oauthtoken' \
        --docker-password='<password>' \
        --docker-email='<email-address>' \
        -n gpu-operator


Add the NVIDIA AI Enterprise Helm repository, where password is the NGC API key for accessing the NVIDIA Enterprise Collection that you generated:

.. code-block:: console

  $ helm repo add nvaie https://helm.ngc.nvidia.com/nvaie \
    --username='$oauthtoken' --password='<password>' \
    && helm repo update


Install the NVIDIA GPU Operator:

.. code-block:: console

    $ helm install --wait gpu-operator nvaie/gpu-operator-<M>-<m> -n gpu-operator \
      --set driver.repository=nvcr.io/nvidia \
      --set driver.image=driver \
      --set driver.version=525.60.13 \
      --set driver.licensingConfig.configMapName=""

Replace *M* and *m* with the major and minor release values, such as ``3-1``.

To deploy the Helm chart with some customizations, refer to
:ref:`Chart Customization Options <gpu-operator-helm-chart-options>`.


*********************************
Updating NLS client license token
*********************************

In case the NLS client license token needs to be updated, please use the following procedure:

Create an empty vGPU license configuration file:

.. code-block:: console

  $ sudo touch gridd.conf

Generate and download a new NLS client license token. Please refer to Section 4.6 of the `NLS User Guide <https://docs.nvidia.com/license-system/latest/pdf/nvidia-license-system-user-guide.pdf>`_ for instructions.

Rename the NLS client license token that you downloaded to ``client_configuration_token.tok``.

Create a new ``licensing-config-new`` ConfigMap object in the ``gpu-operator`` namespace (make sure the name of the configmap is not already used in the kubernetes cluster). Both the vGPU license configuration file and the NLS client license token will be added to this ConfigMap:


.. code-block:: console

    $ kubectl create configmap licensing-config-new \
        -n gpu-operator --from-file=gridd.conf --from-file=<path>/client_configuration_token.tok


Edit the clusterpolicies by using the command:

.. code-block:: console

    $ kubectl edit clusterpolicies.nvidia.com


Go to the driver section and replace the following argument:

.. code-block:: console

  licensingConfig:
      configMapName: licensing-config

with

.. code-block:: console

  licensingConfig:
      configMapName: licensing-config-new

Write and exit from the kubectl edit session (you can use :qw for instance if vi utility is used)

GPU Operator will redeploy sequentially all the driver pods with this new licensing information.
