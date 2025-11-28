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

Deploying the GPU Operator with NVIDIA AI Enterprise offers two installation options.

.. list-table::
   :header-rows: 1

   * - vGPU Guest Driver
     - Data Center Driver

   * - Uses a a prebuilt vGPU driver image that is only available to NVIDIA AI Enterprise customers.

       It is configured to use the `NVIDIA License System (NLS) <https://docs.nvidia.com/license-system/latest/>`_.
       Installations on virtualization platforms must use the vGPU driver installation.

       Installation is performed by downloading a Bash script from NVIDIA NGC and running the script.

     - Uses the GPU Operator Helm chart that is publicly available and GPU driver containers that are publicly available.

       You must determine the supported driver branch, such as 550, for your NVIDIA AI Enterprise release.

       Installation is performed by running the ``helm`` command.

For information about supported platforms, hypervisors, and operating systems, refer to the
`Product Support Matrix <https://docs.nvidia.com/ai-enterprise/latest/product-support-matrix/index.html>`__
in the NVIDIA AI Enterprise documentation.

For information about using vGPU with Red Hat OpenShift, refer to :external+ocp:doc:`nvaie-with-ocp`.


*********************************************
Installing GPU Operator Using the vGPU Driver
*********************************************

Prerequisites
=============

- A client configuration token has been generated for the client on which the script will install the vGPU guest driver.
  Refer to `Generating a Client Configuration Token <https://docs.nvidia.com/license-system/latest/nvidia-license-system-user-guide/index.html#generating-client-configuration-token>`__
  in the *NVIDIA License System User Guide* for more information.
- An NGC CLI API key that is used to create an image pull secret.
  The secret is used to pull the prebuilt vGPU driver image from NVIDIA NGC.
  Refer to `Generating Your NGC API Key <https://docs.nvidia.com/ngc/latest/ngc-private-registry-user-guide.html#prug-generating-personal-api-key>`__
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
Updating NLS Client License Token
*********************************

In case the NLS client license token needs to be updated, use the following procedure:

Create an empty vGPU license configuration file:

.. code-block:: console

  $ sudo touch gridd.conf

Generate and download a new NLS client license token. Refer to Section 4.6 of the `NLS User Guide <https://docs.nvidia.com/license-system/latest/pdf/nvidia-license-system-user-guide.pdf>`_ for instructions.

Rename the NLS client license token that you downloaded to ``client_configuration_token.tok``.

.. warning::

   The ``configMap(configMapName)`` is  **deprecated** and will be removed in a future release.
   Use ``secrets(secretName)`` instead.

Create a new ``licensing-config-new`` Secret object in the ``gpu-operator`` namespace (make sure the name of the secret is not already used in the kubernetes cluster). Both the vGPU license configuration file and the NLS client license token will be added to this Secret:


.. code-block:: console

    $ kubectl create secret generic licensing-config-new \
        -n gpu-operator --from-file=gridd.conf --from-file=<path>/client_configuration_token.tok


Edit the clusterpolicies by using the command:

.. code-block:: console

    $ kubectl edit clusterpolicies.nvidia.com


Go to the driver section and replace the following argument:

.. code-block:: console

  licensingConfig:
      secretName: licensing-config

with

.. code-block:: console

  licensingConfig:
      secretName: licensing-config-new

Write and exit from the kubectl edit session (you can use :qw for instance if vi utility is used)

GPU Operator sequentially redeploys all the driver pods with this new licensing information.

****************************************************
Installing GPU Operator Using the Data Center Driver
****************************************************

This installation method is available for bare metal clusters or any cluster that does not use virtualization.

You must install the driver that matches the supported driver branch for your NVIDIA AI Enterprise release.
The following list summarizes the driver branches for each release.

* v7.x: 580 branch
* v6.x: 570 branch
* v5.x: 550 branch
* v4.x: 535 branch
* v3.x: 525 branch
* v1.x: 470 branch

For newer releases, you can confirm the the supported driver branch by performing the following steps:

#. Refer to the `NVIDIA AI Enterprise Infra Release Branches <https://docs.nvidia.com/ai-enterprise/#infrastructure-software>`__
   for NVIDIA AI Enterprise and access the documentation for your release.

#. In the release notes, identify the supported NVIDIA Data Center GPU Driver branch.

   For example, the `Supported Hardware and Software <https://docs.nvidia.com/ai-enterprise/5.1/release-notes/index.html#supported-hardware-software>`__ for the 5.1 release
   indicates that the release uses the 550.90.07 version of the Linux driver.

#. Refer to :ref:`operator-component-matrix` to identify the recommended driver version that uses the same driver branch, 550, in this case.

After identifying the correct driver version, refer to :ref:`install-gpu-operator` to install the Operator by using Helm.
Specify the ``--version=<supported-version>`` argument to install a supported version of the Operator for your NVIDIA AI Enterprise release.


*******************
Related Information
*******************

.. toctree::

   Government Ready <install-gpu-operator-gov-ready.rst>

-  `NVIDIA AI Enterprise <https://www.nvidia.com/en-us/data-center/products/ai-enterprise-suite/>`_ web page.
