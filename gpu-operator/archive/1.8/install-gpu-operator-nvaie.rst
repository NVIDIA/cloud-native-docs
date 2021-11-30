.. Date: Aug 18 2021
.. Author: cdesiniotis

.. _install-gpu-operator-1.8-nvaie:


#####################
NVIDIA AI Enterprise
#####################

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

Create the ``gpu-operator-resources`` namespace:

.. code-block:: console

    $ kubectl create namespace gpu-operator-resources

Create an empty vGPU license configuration file:

.. code-block:: console

  $ sudo touch gridd.conf

Generate and download a NLS client license token. Please refer to Section 4.6 of the `NLS User Guide <https://docs.nvidia.com/license-system/latest/pdf/nvidia-license-system-user-guide.pdf>`_ for instructions.

Rename the NLS client license token that you downloaded to ``client_configuration_token.tok``.

Create the ``licensing-config`` ConfigMap object in the ``gpu-operator-resources`` namespace. Both the vGPU license
configuration file and the NLS client license token will be added to this ConfigMap:

.. code-block:: console

    $ kubectl create configmap licensing-config \
        -n gpu-operator-resources --from-file=gridd.conf --from-file=<path>/client_configuration_token.tok

Create an image pull secret in the ``gpu-operator-resources`` namespace for the private
registry that contains the containerized NVIDIA vGPU software graphics driver for Linux for
use with NVIDIA GPU Operator:

  * Set the registry secret name:

  .. code-block:: console

    $ export REGISTRY_SECRET_NAME=ngc-secret


  * Set the private registry name:

  .. code-block:: console

    $ export PRIVATE_REGISTRY=nvcr.io/nvaie

  * Create an image pull secret in the ``gpu-operator-resources`` namespace with the registry
    secret name and the private registry name that you set. Replace ``user-name``, ``password``,
    and ``e-mail-address`` with your credentials for logging into the Docker server:

  .. code-block:: console

    $ kubectl create secret docker-registry ${REGISTRY_SECRET_NAME} \
        --docker-server=${PRIVATE_REGISTRY} --docker-username=user-name \
        --docker-password=password \
        --docker-email=e-mail-address -n gpu-operator-resources

The GPU Operator is now ready to install. Please refer to :ref:`install-gpu-operator-1.8` section for installing the GPU Operator.
