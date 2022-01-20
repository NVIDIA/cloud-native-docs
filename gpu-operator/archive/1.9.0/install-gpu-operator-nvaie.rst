.. Date: Aug 18 2021
.. Author: cdesiniotis

.. _install-gpu-operator-1.9.0-nvaie:


#####################
NVIDIA AI Enterprise
#####################


NVIDIA AI Enterprise is an end-to-end, cloud-native suite of AI and data analytics software, optimized, certified, and supported by NVIDIA to run on VMware vSphere  with  NVIDIA-Certified  Systems. Additional information can be found in the `NVIDIA AI Enterprise web page <https://www.nvidia.com/en-us/data-center/products/ai-enterprise-suite/#benefits>`_

 
NVIDIA AI Enterprise customers have access to a pre-configured GPU Operator within the NVIDIA Enterprise Catalog.
The GPU Operator is pre-configured to simplify the provisioning experience with NVIDIA AI Enterprise deployments.

The pre-configured GPU Operator differs from the GPU Operator in the public NGC catalog. The differences are:

  * It is configured to use a prebuilt vGPU driver image (Only available to NVIDIA AI Enterprise customers)

  * It is configured to use containerd as the container runtime

  * It is configured to use the `NVIDIA License System (NLS) <https://docs.nvidia.com/license-system/latest/>`_


*********************
Prerequisite Tasks
*********************

Prior to installing the GPU Operator with NVIDIA AI Enterprise, the following tasks need to be completed for your cluster.

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
        --docker-password=<password> \
        --docker-email=<email-address> \
        -n gpu-operator

The GPU Operator is now ready to install. Please refer to :ref:`install-gpu-operator-1.9.0` section for installing the GPU Operator.
