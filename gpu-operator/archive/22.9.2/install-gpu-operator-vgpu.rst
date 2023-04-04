.. Date: Jan 17 2021
.. Author: smerla

.. _install-gpu-operator-22.9.2-vgpu:

##################
NVIDIA vGPU
##################

This document provides an overview of the workflow to getting started with using the GPU Operator with NVIDIA vGPU.

.. note::

   NVIDIA vGPU is only supported with the NVIDIA License System.

.. note::

    Below steps assume ``gpu-operator`` as the default namespace for installing the GPU Operator. In case of RedHat OpenShift, the default
    namespace would be ``nvidia-gpu-operator``. Please change the namespace accordingly based on your cluster configuration. Also replace
    ``kubectl`` in the below commands with ``oc`` when running on RedHat OpenShift.

*********************
High Level Workflow
*********************

The following section outlines the high level workflow to use the GPU Operator with NVIDIA vGPUs.

#. Download the vGPU Software and latest NVIDIA vGPU Driver Catalog file.
#. Clone driver container source repository for building private driver image.
#. Build the driver container image.
#. Push the driver container image to your private repository.
#. Create a `ConfigMap` in the `gpu-operator` namespace with vGPU license configuration file.
#. Create an `ImagePullSecret` in the `gpu-operator` namespace for your private repository.
#. Install the GPU Operator.

Detailed Workflow
===================

Download the vGPU Software and latest NVIDIA vGPU driver catalog file from the `NVIDIA Licensing Portal <https://nvid.nvidia.com/dashboard/#/dashboard>`_.

#. Login to the NVIDIA Licensing Portal and navigate to the “Software Downloads” section.
#. The NVIDIA vGPU Software is located in the Software Downloads section of the NVIDIA Licensing Portal.
#. The NVIDIA vGPU catalog driver file is located in the “Additional Software” section.
#. The vGPU Software bundle is packaged as a zip file. Download and unzip the bundle to obtain the NVIDIA vGPU Linux guest driver (NVIDIA-Linux-x86_64-<version>-grid.run file)

Clone the driver container repository and build driver image

* Open a terminal and clone the driver container image repository

.. code-block:: console

    $ git clone https://gitlab.com/nvidia/container-images/driver

.. code-block:: console

    $ cd driver

* Change to the OS directory under the driver directory.

.. code-block:: console

    $ cd ubuntu20.04

.. note::

    For RedHat OpenShift, run ``cd rhel`` to use ``rhel`` folder instead.

* Copy the NVIDIA vGPU guest driver from your extracted zip file and the NVIDIA vGPU driver catalog file

.. code-block:: console

    $ cp <local-driver-download-directory>/*-grid.run drivers

.. code-block:: console

    $ cp vgpuDriverCatalog.yaml drivers

* Build the driver container image

Set the private registry name using below command on the terminal

.. code-block:: console

    $ export PRIVATE_REGISTRY=<private registry name>

Set the OS_TAG. The OS_TAG has to match the Guest OS version. Please refer to `OS Support <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/platform-support.html#linux-distributions>`_ for the list of supported OS distributions.
In the below example ``ubuntu20.04`` is used, for RedHat OpenShift this should be ``rhcos4.x`` where ``x`` is the supported minor OCP version.

.. code-block:: console

    $ export OS_TAG=ubuntu20.04

Set the driver container image version to a user defined version number. For example, ``1.0.0``:

.. code-block:: console

    $ export VERSION=1.0.0

.. note::

    ``VERSION`` can be any user defined value. Please note this value to use during operator installation command

Set the version of the CUDA base image used when building the driver container:

.. code-block:: console

    $ export CUDA_VERSION=11.8.0

.. note::

   The ``CUDA_VERSION`` only dictates what base image is used when building the driver container,
   and does not have any correlation to the version of CUDA associated with / supported by the
   resulting driver container.

Replace the ``VGPU_DRIVER_VERSION`` below with the appropriate Linux guest vGPU driver version downloaded 
from the NVIDIA software portal. In this example, the ``525.60.13`` driver has been downloaded. Note that 
the ``-grid`` suffix needs to be added to the environment variable as shown:

.. code-block:: console

    $ export VGPU_DRIVER_VERSION=525.60.13-grid 

.. note::

    GPU Operator automatically selects the compatible guest driver version from the drivers bundled with the ``driver`` image.
    If version check is disabled with ``--build-arg DISABLE_VGPU_VERSION_CHECK=true`` when building driver image, then 
    ``VGPU_DRIVER_VERSION`` value is used as default.

Build the driver container image

.. code-block:: console

    $ sudo docker build \
      --build-arg DRIVER_TYPE=vgpu \
      --build-arg DRIVER_VERSION=$VGPU_DRIVER_VERSION \
      --build-arg CUDA_VERSION=$CUDA_VERSION \
      -t ${PRIVATE_REGISTRY}/driver:${VERSION}-${OS_TAG} .

* Push the driver container image to your private repository

.. code-block:: console

    $ sudo docker login ${PRIVATE_REGISTRY} --username=<username> {enter password on prompt}

.. code-block:: console

    $ sudo docker push ${PRIVATE_REGISTRY}/driver:${VERSION}-${OS_TAG}

* Install the GPU Operator.

Create a NVIDIA vGPU license file named `gridd.conf` with the below content.

.. code-block:: text

    # Description: Set License Server Address
    # Data type: string
    # Format:  "<address>"
    ServerAddress=<license server address>

Input the license server address of the License Server

.. note::

    Optionally add a backup/secondary license server address if one is configured. ``BackupServerAddress=<backup license server address>``

Create a ConfigMap `licensing-config` using `gridd.conf` file created above

.. code-block:: console

    $ kubectl create namespace gpu-operator

.. code-block:: console

    $ kubectl create configmap licensing-config \
      -n gpu-operator --from-file=gridd.conf

Creating an image pull secrets

.. code-block:: console

    $ export REGISTRY_SECRET_NAME=registry-secret

.. code-block:: console

    $ kubectl create secret docker-registry ${REGISTRY_SECRET_NAME} \
      --docker-server=${PRIVATE_REGISTRY} --docker-username=<username> \
      --docker-password=<password> \
      --docker-email=<email-id> -n gpu-operator

.. note::

    Please note the secret name ``REGISTRY_SECRET_NAME`` for using during operator installation command.

* Install GPU Operator via the Helm chart

Please refer to :ref:`install-gpu-operator-22.9.2` section for GPU operator installation command and options for vGPU on Kubernetes.

* Install GPU Operator via OLM on RedHat OpenShift

Please refer to :ref:`install-nvidiagpu-22.9.2` section for GPU operator installation command and options for using NVIDIA vGPU on RedHat OpenShift.
