.. Date: Aug 2 2021
.. Author: cdesiniotis

.. _install-gpu-operator-22.9.2-outdated-kernels:

Considerations when Installing with Outdated Kernels in Cluster
***************************************************************

The ``driver`` container deployed as part of the GPU Operator requires certain packages to be available as part of the driver installation.
On GPU nodes where the running kernel is not the latest, the ``driver`` container may fail to find the right version of these packages 
(e.g. kernel-headers, kernel-devel) that correspond to the running kernel version. In the ``driver`` container logs, you will most likely 
see the following error message: ``Could not resolve Linux kernel version``.

In general, upgrading your system to the latest kernel should fix this issue. But if this is not an option, the following is a 
workaround to successfully deploy the GPU operator when GPU nodes in your cluster may not be running the latest kernel.

Add Archived Package Repositories
=================================

The workaround is to find the package archive containing packages for your outdated kernel and to add this repository to the package 
manager running inside the ``driver`` container. To achieve this, we can simply mount a repository list file into the ``driver`` container using a ``ConfigMap``.
The ``ConfigMap`` containing the repository list file needs to be created in the ``gpu-operator`` namespace.

Let us demonstrate this workaround via an example. The system used in this example is running CentOS 7 with an outdated kernel:

.. code-block:: console

    $ uname -r
    3.10.0-1062.12.1.el7.x86_64

The official archive for older CentOS packages is https://vault.centos.org/. Typically, most archived CentOS repositories
are found in ``/etc/yum.repos.d/CentOS-Vault.repo`` but they are disabled by default. If the appropriate archive repository
was enabled, then the ``driver`` container would resolve the kernel version and be able to install the correct versions
of the prerequisite packages.

We can simply drop in a replacement of ``/etc/yum.repos.d/CentOS-Vault.repo`` to ensure the appropriate CentOS archive is enabled.
For the kernel running in this example, the ``CentOS-7.7.1908`` archive contains the kernel-headers version we are looking for.
Here is our example drop-in replacement file:

.. code-block::

   [C7.7.1908-base]
   name=CentOS-7.7.1908 - Base
   baseurl=http://vault.centos.org/7.7.1908/os/$basearch/
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
   enabled=1

   [C7.7.1908-updates]
   name=CentOS-7.7.1908 - Updates
   baseurl=http://vault.centos.org/7.7.1908/updates/$basearch/
   gpgcheck=1
   gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
   enabled=1

Once the repo list file is created, we can create a ``ConfigMap`` for it:

.. code-block:: console

   $ kubectl create configmap repo-config -n gpu-operator --from-file=<path-to-repo-list-file>

Once the ``ConfigMap`` is created using the above command, update ``values.yaml`` with this information, to let the GPU Operator mount the repo configuration
within the ``driver`` container to pull required packages.

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

Deploy GPU Operator with updated ``values.yaml``:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        -f values.yaml


Check the status of the pods to ensure all the containers are running:

.. code-block:: console

   $ kubectl get pods -n gpu-operator
