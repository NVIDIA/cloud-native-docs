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

.. _nvaie-rn: https://docs.nvidia.com/ai-enterprise/latest/release-notes/index.html
.. |nvaie-rn| replace:: *NVIDIA AI Enterprise Release Notes*

.. |ellipses-img| image:: https://brand-assets.cne.ngc.nvidia.com/assets/icons/2.2.2/fill/common-more-horiz.svg
    :width: 14px
    :height: 14px
    :alt: Actions button

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

Deploying the GPU Operator with NVIDIA AI Enterprise differs from the GPU Operator in the public NGC catalog.
The differences are:

  * It is configured to use a prebuilt vGPU driver image that is only available to NVIDIA AI Enterprise customers.

  * It is configured to use the `NVIDIA License System (NLS) <https://docs.nvidia.com/license-system/latest/>`_.

The GPU Operator with NVIDIA AI Enterprise is supported with the following platforms:

* Kubernetes on bare metal and on vSphere VMs with GPU passthrough and vGPU
* VMware vSphere with Tanzu

NVIDIA AI Enterprise includes support for Red Hat OpenShift Container Platform.

* OpenShift Container Platform on bare metal or VMware vSphere with GPU Passthrough
* OpenShift Container Platform on VMware vSphere with NVIDIA vGPU

For Red Hat OpenShift, refer to :external+ocp:doc:`nvaie-with-ocp`.


***********************
Installing GPU Operator
***********************

Beginning with the NVIDIA AI Enterprise release 5.0, the GPU Operator is installed using Bash script.

To deploy an earlier version of NVIDIA AI Enterprise, refer to the documentation for the GPU Operator version specified in the NVIDIA AI Enterprise documentation
or an earlier version of the GPU Operator documentation, such as the 
`23.9.1 <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/23.9.1/install-gpu-operator-nvaie.html>`__
version.

Prerequisites
=============

- A client configuration token has been generated for the client on which the script will install the vGPU guest driver.
  Refer to `Generating a Client Configuration Token <https://docs.nvidia.com/license-system/latest/nvidia-license-system-user-guide/index.html#generating-client-configuration-token>`__
  in the *NVIDIA License System User Guide* for more information.
- An NGC CLI API key that is used to create an image pull secret.
  The secret is used to pull the prebuilt vGPU driver image from NVIDIA NGC.
  Refer to `Generating Your NGC API Key <https://docs.nvidia.com/ngc/gpu-cloud/ngc-private-registry-user-guide/index.html#generating-api-key>`__
  in the *NVIDIA NGC Private Registry User Guide* for more information.

Procedure
=========

#. Export the NGC CLI API key and your email address as environment variables:

   .. code-block:: console
    
      $ export NGC_API_KEY="M2Vub3QxYmgyZ..."
      $ export NGC_USER_EMAIL="user@example.com"

#. Go to the
   `NVIDIA GPU Operator - Deploy Installer Script <https://catalog.ngc.nvidia.com/orgs/nvidia/teams/vgpu/resources/gpu-operator-installer-5>`__
   web page on NVIDIA NGC.

   Click the **File Browser** tab, identify your NVIDIA AI Enterprise release, click |ellipses-img|, and select **Download File**.

   Copy the downloaded script to the same directory as the client configuration token.

#. Rename the client configuration token that you downloaded to ``client_configuration_token.tok``.
   Originally, the client configuration token is named to match the pattern: ``client_configuration_token_mm-dd-yyyy-hh-mm-ss.tok``.

#. From the directory that contains the downloaded script and the client configuration token, run the script:

   .. code-block:: console

      $ bash gpu-operator-nvaie.sh install


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

*******************
Related Information
*******************

-  `NVIDIA AI Enterprise <https://www.nvidia.com/en-us/data-center/products/ai-enterprise-suite/>`_ web page.
