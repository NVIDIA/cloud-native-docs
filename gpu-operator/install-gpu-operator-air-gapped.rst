.. Date: Dec 11 2020
.. Author: smerla

.. _install-gpu-operator-air-gapped:

Install GPU Operator in Air-gapped Environments
***********************************************

Introduction
============

This page describes how to successfully deploy the GPU Operator in clusters with restricted internet access.
By default, The GPU Operator requires internet access for the following reasons:

    1) Container images need to be pulled during GPU Operator installation.
    2) The ``driver`` container needs to download several OS packages prior to driver installation.

       .. tip::
          Using :doc:`precompiled-drivers` removes the need for the ``driver`` containers to
          download operating system packages and removes the need to create a local package repository.

To address these requirements, it may be necessary to create a local image registry and/or a local package repository
so that the necessary images and packages are available for your cluster. In subsequent sections, we detail how to
configure the GPU Operator to use local image registries and local package repositories. If your cluster is behind
a proxy, also follow the steps from :ref:`install-gpu-operator-proxy`.

Different steps are required for different environments with varying levels of internet connectivity.
The supported use cases/environments are listed in the below table:

+--------------------------+-----------------------------------------+
|                          | Network Flow                            |
+--------------------------+--------------------+--------------------+
| Use Case                 | Pulling Images     | Pulling Packages   |
+========+=================+====================+====================+
| **1**  | HTTP Proxy with | K8s node --> HTTP  | Driver container   |
|        | full Internet   | Proxy --> Internet | --> HTTP Proxy --> |
|        | access          | Image Registry     | Internet Package   |
|        |                 |                    | Repository         |
+--------+-----------------+--------------------+--------------------+
| **2**  | HTTP Proxy with | K8s node --> HTTP  | Driver container   |
|        | limited Internet| Proxy --> Internet | --> HTTP Proxy --> |
|        | access          | Image Registry     | Local Package      |
|        |                 |                    | Repository         |
+--------+-----------------+--------------------+--------------------+
| **3a** | Full Air-Gapped | K8s node --> Local | Driver container   |
|        | (w/ HTTP Proxy) | Image Registry     | --> HTTP Proxy --> |
|        |                 |                    | Local Package      |
|        |                 |                    | Repository         |
+--------+-----------------+--------------------+--------------------+
| **3b** | Full Air-Gapped | K8s node --> Local | Driver container-->|
|        | (w/o HTTP Proxy)| Image Registry     | Local Package      |
|        |                 |                    | Repository         |
+--------+-----------------+--------------------+--------------------+

.. note::

   For Red Hat Openshift deployments in air-gapped environments (use cases 2, 3a and 3b), see the documentation `here <https://docs.nvidia.com/datacenter/cloud-native/openshift/mirror-gpu-ocp-disconnected.html>`_.

.. note::

   Ensure that Kubernetes nodes can successfully reach the local DNS server(s).
   Public name resolution for image registry and package repositories are
   mandatory for use cases 1 and 2.

Before proceeding to the next sections, get the ``values.yaml`` file used for GPU Operator configuration.

.. code-block:: console

  $ curl -sO https://raw.githubusercontent.com/NVIDIA/gpu-operator/v1.7.0/deployments/gpu-operator/values.yaml

.. note::

   Replace ``v1.7.0`` in the above command with the version you want to use.


Local Image Registry
===================

Without internet access, the GPU Operator requires all images to be hosted in a local image registry that is accessible
to all nodes in the cluster. To allow the GPU Operator to work with a local registry, users can specify local
repository, image, tag along with pull secrets in ``values.yaml``.

Pulling and pushing container images to local registry
------------------------------------------------------

To pull the correct images from the NVIDIA registry, you can leverage the fields ``repository``, ``image`` and ``version``
specified in the file ``values.yaml``.

The general syntax for the container image is ``<repository>/<image>:<version>``.

If the version is not specified, you can retrieve the information from the NVIDIA NGC catalog (https://ngc.nvidia.com/catalog)
by checking the available tags for an image.

An example is shown below with the gpu-operator container image:

.. code-block:: yaml

    operator:
        repository: nvcr.io/nvidia
        image: gpu-operator
        version: "v1.9.0"

For instance, to pull the gpu-operator image version v1.9.0, use the following instruction:

.. code-block:: console

    $ docker pull nvcr.io/nvidia/gpu-operator:v1.9.0

There is one caveat with regards to the driver image. The version field must be appended by the OS name running on the worker node.

.. code-block:: yaml

    driver:
        repository: nvcr.io/nvidia
        image: driver
        version: "470.82.01"

To pull the driver image for Ubuntu 20.04:

.. code-block:: console

    $ docker pull nvcr.io/nvidia/driver:470.82.01-ubuntu20.04

To pull the driver image for CentOS 8:

.. code-block:: console

    $ docker pull nvcr.io/nvidia/driver:470.82.01-centos8

To push the images to the local registry, simply tag the pulled images by prefixing the image with the image registry information.

Using the above examples, this will result in:

.. code-block:: console

    $ docker tag nvcr.io/nvidia/gpu-operator:v1.9.0 <local-registry>/<local-path>/gpu-operator:v1.9.0
    $ docker tag nvcr.io/nvidia/driver:470.82.01-ubuntu20.04 <local-registry>/<local-path>/driver:470.82.01-ubuntu20.04

Finally, push the images to the local registry:

.. code-block:: console

    $ docker push  <local-registry>/<local-path>/gpu-operator:v1.9.0
    $ docker push <local-registry>/<local-path>/driver:470.82.01-ubuntu20.04

Update ``values.yaml`` with local registry information in the repository field.

.. note::

   replace <repo.example.com:port> below with your local image registry url and port

Sample of ``values.yaml`` for GPU Operator v1.9.0:

.. code-block:: yaml

   operator:
     repository: <repo.example.com:port>
     image: gpu-operator
     version: 1.9.0
     imagePullSecrets: []
     initContainer:
       image: cuda
       repository: <repo.example.com:port>
       version: 11.4.2-base-ubi8

    validator:
      image: gpu-operator-validator
      repository: <repo.example.com:port>
      version: 1.9.0
      imagePullSecrets: []

    driver:
      repository: <repo.example.com:port>
      image: driver
      version: "470.82.01"
      imagePullSecrets: []
      manager:
        image: k8s-driver-manager
        repository: <repo.example.com:port>
        version: v0.2.0

    toolkit:
      repository: <repo.example.com:port>
      image: container-toolkit
      version: 1.7.2-ubuntu18.04
      imagePullSecrets: []

    devicePlugin:
      repository: <repo.example.com:port>
      image: k8s-device-plugin
      version: v0.10.0-ubi8
      imagePullSecrets: []

    dcgmExporter:
      repository: <repo.example.com:port>
      image: dcgm-exporter
      version: 2.3.1-2.6.0-ubuntu20.04
      imagePullSecrets: []

    gfd:
      repository: <repo.example.com:port>
      image: gpu-feature-discovery
      version: v0.4.1
      imagePullSecrets: []

    nodeStatusExporter:
      enabled: false
      repository: <repo.example.com:port>
      image: gpu-operator-validator
      version: "1.9.0"

    migManager:
      enabled: true
      repository: <repo.example.com:port>
      image: k8s-mig-manager
      version: v0.2.0-ubuntu20.04

    node-feature-discovery:
      image:
        repository: <repo.example.com:port>
        pullPolicy: IfNotPresent
        # tag, if defined will use the given image tag, else Chart.AppVersion will be used
        # tag:
      imagePullSecrets: []


Local Package Repository
========================

The ``driver`` container deployed as part of the GPU operator requires certain packages to be available as part of the
driver installation. In restricted internet access or air-gapped installations, users are required to create a
local mirror repository for their OS distribution and make the following packages available:

.. note::

   KERNEL_VERSION is the underlying running kernel version on the GPU node
   GCC_VERSION is the gcc version matching the one used for building underlying kernel

   Configuring a local package repository is not necessary for clusters that
   can run :doc:`precompiled-drivers`.

.. code-block:: yaml

    ubuntu:
       linux-headers-${KERNEL_VERSION}
       linux-image-${KERNEL_VERSION}
       linux-modules-${KERNEL_VERSION}

    centos:
       elfutils-libelf.x86_64
       elfutils-libelf-devel.x86_64
       kernel-headers-${KERNEL_VERSION}
       kernel-devel-${KERNEL_VERSION}
       kernel-core-${KERNEL_VERSION}
       gcc-${GCC_VERSION}

    rhel/rhcos:
       kernel-headers-${KERNEL_VERSION}
       kernel-devel-${KERNEL_VERSION}
       kernel-core-${KERNEL_VERSION}
       gcc-${GCC_VERSION}

For example, for Ubuntu these packages can be found at ``archive.ubuntu.com`` so this would be the mirror that
needs to be replicated locally for your cluster. Using ``apt-mirror``, these packages will be automatically mirrored
to your local package repository server.

For CentOS, ``reposync`` can be used to create the local mirror.

Once all above required packages are mirrored to the local repository, repo lists need to be created following
distribution specific documentation. A ``ConfigMap`` containing the repo list file needs to be created in
the namespace where the GPU Operator gets deployed.

An example of repo list is shown below for Ubuntu 20.04 (access to local package repository via HTTP):

``custom-repo.list``:

.. code-block::

   deb [arch=amd64] http://<local pkg repository>/ubuntu/mirror/archive.ubuntu.com/ubuntu focal main universe
   deb [arch=amd64] http://<local pkg repository>/ubuntu/mirror/archive.ubuntu.com/ubuntu focal-updates main universe
   deb [arch=amd64] http://<local pkg repository>/ubuntu/mirror/archive.ubuntu.com/ubuntu focal-security main universe

An example of repo list is shown below for CentOS 8 (access to local package repository via HTTP):

``custom-repo.repo``:

.. code-block::

   [baseos]
   name=CentOS Linux $releasever - BaseOS
   baseurl=http://<local pkg repository>/repos/centos/$releasever/$basearch/os/baseos/
   gpgcheck=0
   enabled=1

   [appstream]
   name=CentOS Linux $releasever - AppStream
   baseurl=http://<local pkg repository>/repos/centos/$releasever/$basearch/os/appstream/
   gpgcheck=0
   enabled=1

   [extras]
   name=CentOS Linux $releasever - Extras
   baseurl=http://<local pkg repository>/repos/centos/$releasever/$basearch/os/extras/
   gpgcheck=0
   enabled=1

Create the ``ConfigMap``:

.. code-block:: console

   $ kubectl create configmap repo-config -n gpu-operator --from-file=<path-to-repo-list-file>

Once the ConfigMap is created using the above command, update ``values.yaml`` with this information, to let the GPU Operator mount the repo configuration
within the ``driver`` container to pull required packages. Based on the OS distribution the GPU Operator will automatically mount this ConfigMap into the appropriate directory.

.. code-block:: yaml

      driver:
         repoConfig:
            configMapName: repo-config

If self-signed certificates are used for an HTTPS based internal repository then a ConfigMap needs to be created for those certs and provide that during the GPU Operator
install. Based on the OS distribution the GPU Operator will automatically mount this ConfigMap into the appropriate directory.

.. code-block:: console

   $ kubectl create configmap cert-config -n gpu-operator --from-file=<path-to-pem-file1> --from-file=<path-to-pem-file2>

.. code-block:: yaml

      driver:
         certConfig:
            name: cert-config

Deploy GPU Operator
===================

Download and deploy GPU Operator Helm Chart with the updated ``values.yaml``.

Fetch the chart from NGC repository. ``v1.9.0`` is used in the command below:

.. code-block:: console

    $ helm fetch https://helm.ngc.nvidia.com/nvidia/charts/gpu-operator-v1.9.0.tgz

Install the GPU Operator with updated ``values.yaml``:

.. code-block:: console

    $ helm install --wait gpu-operator \
         -n gpu-operator --create-namespace \
         gpu-operator-v1.9.0.tgz \
         -f values.yaml

Check the status of the pods to ensure all the containers are running:

.. code-block:: console

   $ kubectl get pods -n gpu-operator
