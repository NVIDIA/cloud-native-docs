.. Date: Aug 2 2021
.. Author: cdesiniotis

.. _install-gpu-operator-outdated-kernels:

Considerations when Installing with Outdated Kernels in Cluster
=================================================================

The ``Driver`` container deployed as part of the GPU Operator requires certain packages to be available as part of the driver installation.
On GPU nodes where the running kernel is not the latest, the ``Driver`` container may fail to find the right version of these packages 
(e.g. kernel-headers, kernel-devel) that correspond to the running kernel version. In the ``Driver`` container logs, you will most likely 
see the following error message: ``Could not resolve Linux kernel version``.

In general, upgrading your system to the latest kernel should fix this issue. But if this is not preferred, the following is a 
workaround to successfully deploy the GPU operator when GPU nodes in your cluster may not be running the latest kernel.

Add Archived Package Repositories
----------------------------------

The workaround is to find the package archive containing packages for your outdated kernel and to add this repository to the package 
manager running inside the ``Driver`` container. To achieve this, we can simply mount a repository list file into the ``Driver`` container.
A ``ConfigMap`` needs to be created with the repository list file created under the ``gpu-operator-resources`` namespace.

.. code-block:: console

   $ kubectl create configmap repo-config -n gpu-operator-resources --from-file=<path-to-repo-list-file>

Once the ConfigMap is created using the above command, update ``values.yaml`` with this information, to let the GPU Operator mount the repo configuration
within the ``Driver`` container to pull required packages.

Ubuntu
^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

   driver:
      repoConfig:
         configMapName: repo-config
         destinationDir: /etc/apt/sources.list.d

CentOS/RHEL/RHCOS
^^^^^^^^^^^^^^^^^^

.. code-block:: yaml

   driver:
      repoConfig:
         configMapName: repo-config
         destinationDir: /etc/yum.repos.d

Deploy GPU Operator with updated ``values.yaml``

.. code-block:: console

   $ helm install --wait --generate-name \
        nvidia/gpu-operator \
        -f values.yaml


Check the status of the pods to ensure all the containers are running:

.. code-block:: console

   $ kubectl get pods -n gpu-operator-resources
