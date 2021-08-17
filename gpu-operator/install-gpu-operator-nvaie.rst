.. Date: Aug 18 2021
.. Author: cdesiniotis

.. _install-gpu-operator-nvaie:


#####################
NVIDIA AI Enterprise
#####################

Prior to installing the GPU Operator with NVIDIA AI Enterprise, the following tasks need to be completed for your cluster.

Create the ``gpu-operator-resources`` namespace:

.. code-block:: console

    $ kubectl create namespace gpu-operator-resources

Create a vGPU license configuration file by `licensing an NVIDIA vGPU <https://docs.nvidia.com/grid/latest/grid-licensing-user-guide/index.html#licensing-grid-vgpu-linux-config-file>`_, omitting the steps for restarting the ``nvidia-gridd`` service and confirming that the service has obtained a license.

From the vGPU license configuration file, create the ``licensing-config`` ConfigMap object in the ``gpu-operator-resources`` namespace:

.. code-block:: console

    $ kubectl create configmap licensing-config \
        -n gpu-operator-resources --from-file=/etc/nvidia/gridd.conf

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

The GPU Operator is now ready to install. Please refer to :ref:`Install NVIDIA GPU Operator` section for installing the GPU Operator.