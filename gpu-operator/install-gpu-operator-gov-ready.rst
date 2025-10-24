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


.. _install-gpu-operator-gov-ready:

####################################
NVIDIA GPU Operator Government Ready
####################################

The NVIDIA GPU Operator now offers government-ready components for NVIDIA AI Enterprise customers.
Government ready is NVIDIA's designation for software that meets applicable security requirements for deployment in your FedRAMP High or equivalent sovereign use case. 
For more information on NVIDIA's government-ready support, refer to the white paper `AI Software for Regulated Environments <https://docs.nvidia.com/ai-enterprise/planning-resource/ai-software-regulated-environments-white-paper/latest/index.html>`_.


Supported GPU Operator Components
==================================
The government-ready NVIDIA GPU Operator includes the following components:

.. _fn1: #base-image
.. |fn1| replace:: :sup:`1`

.. list-table::
   :header-rows: 1

   * - Component
     - Version
   * - NVIDIA GPU Operator
     - v25.10.0
   * - NVIDIA GPU Feature Discovery
     - 0.18.0
   * - NVIDIA Container Toolkit
     - 1.18.0
   * - NVIDIA Device Plugin
     - 0.18.0
   * - NVIDIA DCGM-exporter
     - 4.4.1-4.6.0
   * - NVIDIA MIG Manager
     - 0.13.0
   * - NVIDIA Driver
     - 580.82.07 |fn1|_

:sup:`1`
Built using the following base images:

- STIG Ubuntu 24.04 base image for FIPS Canonical K8s.
- `UBI-STIG base image <https://catalog.redhat.com/en/software/containers/ubi9/ubi-stig/68e7aca8a3801e04bcb7873b#overview>`_ for FIPS OpenShift

Artifacts for these components are available from the `NVIDIA NGC Catalog <https://registry.ngc.nvidia.com/orgs/nvstaging/teams/cloud-native/containers/gpu-driver-stig-fips>`_.

.. note::

    Not all GPU Operator components and features are available as government-ready containers in the v25.10.0 release.
    For example, GPUDirect Storage and KubeVirt are not yet supported.


Validated Kubernetes Distributions
===================================

The government-ready NVIDIA GPU Operator has been validated on the following Kubernetes distributions:

- Canonical Kubernetes 1.34 with Ubuntu Pro 24.04 and FIPS-compliant kernel
- Red Hat OpenShift 4.19 in FIPS mode

Install Government-Ready NVIDIA GPU Operator
=============================================

Once you have your :ref:`gov-ready-prerequisites` configured, use the following steps to install the NVIDIA GPU Operator on Canonical Kubernetes distributions:

#. :ref:`install-nfd`
#. :ref:`create-ngc-api-pull-secret`
#. :ref:`create-ubuntu-pro-token-secret`
#. :ref:`deploy-nvidia-gpu-operator-gov-ready`

.. note::

    For deployment on OpenShift, refer to the :external+ocp:doc:`install-gpu-operator-gov-ready-openshift` page.

.. _gov-ready-prerequisites:

Prerequisites
-------------

- An active NVIDIA AI Enterprise subscription and NGC API token to access GPU Operator government-ready containers.
  Refer to `Generating Your NGC API Key <https://docs.nvidia.com/ngc/gpu-cloud/ngc-user-guide/index.html#generating-api-key>`_ in the NVIDIA NGC User Guide for more information on NGC API tokens.

- An Ubuntu Pro token for Canonical Kubernetes deployments.
  This token is required for the driver container to download kernel headers and other necessary packages from the Canonical repository when using the FIPS-enabled kernel on Ubuntu 24.04.
  Refer to the `Ubuntu Pro documentation <https://documentation.ubuntu.com/pro-client/en/v30/howtoguides/get_token_and_attach/>`_ for more information on accessing Ubuntu Pro tokens.

- The ``helm`` CLI installed on a client machine.

  You can run the following commands to install the Helm CLI:

  .. code-block:: console

     $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
         && chmod 700 get_helm.sh \
         && ./get_helm.sh

- A namespace to deploy the NVIDIA GPU Operator.
  The example install commands below use ``gpu-operator`` as the namespace.

- Optionally, Service Mesh for intra-cluster traffic encryption.
  By default, the NVIDIA GPU Operator does not encrypt traffic between its controller (and operands) and the Kubernetes API server.
  If you wish to encrypt this communication, you should deploy and maintain a service mesh application within the Kubernetes cluster to enable secure traffic.

.. _install-nfd:

Install Node Feature Discovery (NFD)
-------------------------------------

NFD is an open-source project that is a dependency for the Operator on each node in your cluster.
It must be deployed before installing the NVIDIA GPU Operator.

Using Helm, deploy NFD with the following command:

.. code-block:: console

   $ helm install nfd --namespace node-feature-discovery --create-namespace oci://registry.k8s.io/nfd/charts/node-feature-discovery --version 0.18.0

The NFD container is built on top of a scratch image, providing a highly secure container environment.
For information on NFD CVEs and security updates, refer to the `NFD GitHub repository <https://github.com/kubernetes-sigs/node-feature-discovery/security>`_.

.. _create-ngc-api-pull-secret:

Create NGC API Pull Secret
---------------------------

Add a Docker registry secret for downloading the GPU Operator artifacts from NVIDIA NGC in the same namespace where you are planning to deploy the NVIDIA GPU Operator.
Update ``ngc-api-key`` in the command below with your NGC API key.

.. code-block:: console

   $ kubectl create secret -n gpu-operator docker-registry ngc-secret \
       --docker-server=nvcr.io \
       --docker-username='$oauthtoken' \
       --docker-password=<ngc-api-key>

.. _create-ubuntu-pro-token-secret:

Create Ubuntu Pro Token Secret
-------------------------------

Create a Kubernetes secret to hold the value of your Ubuntu Pro token secret. 
This secret will be used in the install command in the next step.

The Ubuntu Pro Token is required for the driver container to download kernel headers and other necessary packages from the Canonical repository when using the FIPS-enabled kernel on Ubuntu 24.04.

1. Get Ubuntu Pro token:

   .. code-block:: console

      $ echo UBUNTU_PRO_TOKEN=${UBUNTU_PRO_TOKEN} > ubuntu-fips.env

2. Create Ubuntu Pro token Secret:

   .. code-block:: console

      $ kubectl create secret generic ubuntu-fips-secret \
          --from-env-file=./ubuntu-fips.env --namespace gpu-operator

   Note that the namespace in the above command is ``gpu-operator``. Update this to the namespace you are planning to use for the NVIDIA GPU Operator.

.. _deploy-nvidia-gpu-operator-gov-ready:

Install NVIDIA GPU Operator Government-Ready Components
--------------------------------------------------------

1. Add the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
          && helm repo update

2. Install the NVIDIA GPU Operator.

   .. code-block:: console

      $  helm install gpu-operator nvidia/gpu-operator \
         --namespace gpu-operator \
         --set driver.secretEnv=ubuntu-fips-secret \
         --set driver.repository=nvcr.io/nvidia/driver-stig-fips \
         --set driver.version=580.82.07-stig-fips-ubuntu24.04 \
         --set driver.image=gpu-driver-stig-fips \
         --set driver.imagePullSecrets={ngc-secret}

Refer to `Common Chart Customization Options <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#common-chart-customization-options>`_ for more information about installation options.

.. _update-ubuntu-pro-token-in-clusterpolicy:

Update Ubuntu Pro Token in ClusterPolicy
=========================================

You can update your Ubuntu Pro Token after installation by editing your Ubuntu Pro Token secret.
This secret name is set as value of ``driver.secretEnv`` of the GPU Operator ClusterPolicy.

Edit your Ubuntu Pro Token secret.

.. code-block:: console

   $ kubectl edit secrets <ubuntu-fips-secret>

Then update the secret with your new Ubuntu Pro Token.
This token is required for the driver container to download kernel headers and other necessary packages from the Canonical repository when using the FIPS-enabled kernel on Ubuntu 24.04.

