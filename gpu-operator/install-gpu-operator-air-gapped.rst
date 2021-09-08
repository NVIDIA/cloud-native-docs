.. Date: Dec 11 2020
.. Author: smerla

.. _install-gpu-operator-air-gapped:

Considerations to Install in Air-Gapped Clusters
===================================================

Local Image Registry
----------------------

With Air-Gapped installs, the GPU Operator requires all images to be hosted in a local image registry accessible to each node in the cluster. To allow
GPU Operator to work with local registry, users can specify local repository, image, tag along with pull secrets in ``values.yaml``.

Get the values.yaml

.. code-block:: console

  $ curl -sO https://raw.githubusercontent.com/NVIDIA/gpu-operator/master/deployments/gpu-operator/values.yaml

Update ``values.yaml`` with repository, image details as applicable

.. note::

   replace <repo.example.com:port> below with your local image registry url and port

.. note::

   some pods use initContainers with image(11.0-base-ubi8) as ``nvcr.io/nvidia/cuda@sha256:ed723a1339cddd75eb9f2be2f3476edf497a1b189c10c9bf9eb8da4a16a51a59``
   make sure to push this to local repository as well.

.. code-block:: yaml

   operator:
     repository: <repo.example.com:port>
     image: gpu-operator
     version: 1.4.0
     imagePullSecrets: []
     validator:
       image: cuda-sample
       repository: <my-repository:port>
       version: vectoradd-cuda10.2
       imagePullSecrets: []

   driver:
     repository: <repo.example.com:port>
     image: driver
     version: "450.80.02"
     imagePullSecrets: []
  
   toolkit:
     repository: <repo.example.com:port>
     image: container-toolkit
     version: 1.4.0-ubuntu18.04
     imagePullSecrets: []
  
   devicePlugin:
     repository: <repo.example.com:port>
     image: k8s-device-plugin
     version: v0.7.1
     imagePullSecrets: []

   dcgmExporter:
     repository: <repo.example.com:port>
     image: dcgm-exporter
     version: 2.0.13-2.1.2-ubuntu20.04
     imagePullSecrets: []

   gfd:
     repository: <repo.example.com:port>
     image: gpu-feature-discovery
     version: v0.2.2
     imagePullSecrets: []

   node-feature-discovery:
     imagePullSecrets: []
     image:
       repository: <repo.example.com:port>
       tag: "v0.6.0"

Local Package Repository
^^^^^^^^^^^^^^^^^^^^^^^^^

The ``Driver`` container deployed as part of GPU operator require certain packages to be available as part of driver installation. In Air-Gapped installations,
users are required to create a mirror repository for their OS distribution and make following packages available:

.. note::

   KERNEL_VERSION is the underlying running kernel version on the GPU node
   GCC_VERSION is the gcc version matching the one used for building underlying kernel

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


Once, all above required packages are mirrored to local repository, repo lists needs to be created following distribution specific documentation.
A ``ConfigMap`` needs to be created with the repo list file created under ``gpu-operator-resources`` namespace.

.. code-block:: console

   $ kubectl create configmap repo-config -n gpu-operator-resources --from-file=<path-to-repo-list-file>

Once the ConfigMap is created using above command, update ``values.yaml`` with this information, to let GPU Operator mount the repo configiguration
within ``Driver`` container to pull required packages.

For Ubuntu:

.. code-block:: yaml

   driver:
      repoConfig:
         configMapName: repo-config
         destinationDir: /etc/apt/sources.list.d

For RHEL/Centos/RHCOS:

.. code-block:: yaml

   driver:
      repoConfig:
         configMapName: repo-config
         destinationDir: /etc/yum.repos.d

Proxy settings:

If mirror repository is configured behind a proxy, specify ``driver.env`` in ``values.yaml`` with appropriate HTTP_PROXY, HTTPS_PROXY and NO_PROXY environment variables(in both uppercase and lowercase).

.. code-block:: yaml

   driver:
      env:
      - name: HTTPS_PROXY
        value: http://<example.proxy.com:port>
      - name: HTTP_PROXY
        value: http://<example.proxy.com:port>
      - name: NO_PROXY
        value: example.com
      - name: https_proxy
        value: http://<example.proxy.com:port>
      - name: http_proxy
        value: http://<example.proxy.com:port>
      - name: no_proxy
        value: example.com

.. note::

   * Proxy related ENV are automatically injected by GPU Operator for RedHat OpenShift.
   * GPU Operator `v1.8.0` does not work well on RedHat OpenShift when a cluster-wide proxy is configured and causes constant restarts of driver container.
     This will be fixed in an upcoming patch release `v1.8.2`.
   * If HTTPS Proxy server is setup then change the values of `HTTPS_PROXY` and `https_proxy` to use `https` instead.

Download and Deploy GPU Operator Chart with updated ``values.yaml``

Fetch latest version of the chart from NGC `repository <https://ngc.nvidia.com/helm-charts/nvidia:gpu-operator>`_. ``v1.7.1`` is used in the command below.

.. code-block:: console

   $ helm fetch https://helm.ngc.nvidia.com/nvidia/charts/gpu-operator-v1.7.1.tgz

.. code-block:: console

   $ helm install --wait gpu-operator \
        gpu-operator-v1.7.1.tgz \
        -f values.yaml


Check the status of the pods to ensure all the containers are running:

.. code-block:: console

   $ kubectl get pods -n gpu-operator-resources