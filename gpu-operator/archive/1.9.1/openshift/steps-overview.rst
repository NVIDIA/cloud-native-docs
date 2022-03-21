.. Date: November 15 2021
.. Author: kquinn

.. _steps_overview-1.9.1:

*****************************************
Overview
*****************************************
Follow these steps to install the **NVIDIA GPU Operator**:

#. :ref:`install-nfd-1.9.1`.
#. :ref:`install-nvidiagpu-1.9.1`.
#. :ref:`running-sample-app-1.9.1`.

Improvements with version 1.9
-----------------------------

The **NVIDIA GPU Operator** in version 1.9 has the following enhancements:

* You can install the Operator into the ``nvidia-gpu-operator`` dedicated namespace. This replaces the ``openshift-operators`` and ``gpu-operator-resources`` used in previous versions.

  .. note:: The option does exist to install the Operator to any existing namespace or to a created new namespace. The recommendation is to **not** enable namespace monitoring unless only trusted operators are installed in the choosen namespace.
     When the GPU Operator is installed into the suggested namespace ``nvidia-gpu-operator`` alerts are automatically enabled and logged in the console.

     Verify monitoring is enabled for the namespace:

      .. code-block:: console

         $ oc get ns/nvidia-gpu-operator --show-labels | grep openshift.io/cluster-monitoring=true

* State indicator metrics are now generated which include:

   - Successful deployment
   - Number of GPUs available in the nodes
   - Validation of the different stack layers
* Prometheus alerts are generated when GPU nodes are not available or when the driver cannot be built.
* The ``nvidia-driver-daemonset`` now includes two containers where in previous releases it only had one:

   - ``nvidia-driver-ctr``
   - ``openshift-driver-toolkit-ctr``

* The driver toolkit removes the requirements to:

   - Set up an entitlement
   - Mirror the RPM packages in a disconnected environment
   - Configure a proxy to access the package repository

Upgrade
-------

To upgrade the **NVIDIA GPU Operator** from 1.8 to 1.9 you must uninstall 1.8 and install 1.9. For information about upgrading the OpenShift Container Platform release, see `Updating a cluster between minor versions <https://docs.openshift.com/container-platform/latest/updating/updating-cluster-between-minor.html>`_.

Entitlement-free supported versions
-----------------------------------

Clean Install
=============

You can deploy the **NVIDIA GPU Operator** on a clean install of the OpenShift Container Platform (a newly deployed cluster that was not upgraded) without entitlement on the following versions:

* OpenShift 4.9.9 and above z-streams
.. * OpenShift 4.8.22 and above z-streams
.. * All the versions of OpenShift 4.9 except 4.9.8

.. note::

   The Driver Toolkit, which enables entitlement-free deployments of the GPU Operator, is available for certain z-streams on OpenShift
   4.8 and all z-streams on OpenShift 4.9. However, some Driver Toolkit images are broken, so we recommend maintaining entitlements for
   all OpenShift versions prior to 4.9.9. See :ref:`broken driver toolkit <broken-dtk-1.9.1>` for more information.

#. Verify your cluster has the OpenShift Driver toolkit:

   .. code-block:: console

      $ oc get -n openshift is/driver-toolkit

   Expected output example:

   .. code-block:: console

      $ NAME             IMAGE REPOSITORY                                                            TAGS                          UPDATED
        driver-toolkit   image-registry.openshift-image-registry.svc:5000/openshift/driver-toolkit   49.84.202110081407-0,latest   10 days ago

Upgrade
=======

After an **upgrade** a bug in OpenShift Cluster Version Operator (`BZ#2014071 <https://bugzilla.redhat.com/show_bug.cgi?id=2014071>`_) prevents the proper upgrade of the Driver Toolkit imagestream. A fix for this issue has been merged in the following releases:

* OpenShift 4.8.21 and above z-streams
* OpenShift 4.9.5 and above z-streams

#. Verify your cluster is affected by this bug, search for a tag with an empty name:

   .. code-block:: console

      $ oc get -n openshift is/driver-toolkit '-ojsonpath={.spec.tags[?(@.name=="")]}'

   .. code-block:: console

      {{"annotations":null,"from":{"kind":"DockerImage","name":"[quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:71207482fa6fcef0e3ca283d0cafebed4d5ac78c62312fd6e19ac5ca2294d296](http://quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:71207482fa6fcef0e3ca283d0cafebed4d5ac78c62312fd6e19ac5ca2294d296)"},"generation":5,"importPolicy":{"scheduled":true},"name":"","referencePolicy":{"type":"Source"}}

#. As a workaround, delete the broken imagestream and the Cluster Version Operator recreates it:

   .. code-block:: console

      $ oc delete -n openshift is/driver-toolkit

   .. code-block:: console

      imagestream.image.openshift.io "driver-toolkit" deleted

.. _broken-dtk-1.9.1:

Broken driver toolkit
=====================

OpenShift `4.8.19`, `4.8.21`, `4.9.8` are known to have a broken Driver Toolkit image. The following messages are recorded in the driver Pod containers. Follow the guidance in :ref:`enabling a Cluster-wide entitlement <cluster-entitlement-1.9.1>` and once complete the ``nvidia-driver-daemonset`` will automatically fallback. To disable the usage of Driver Toolkit image altogether, edit the **ClusterPolicy** instance and set ``driver.use_ocp_driver_toolkit`` option to ``false``. Also, we recommend maintaining entitlements for OpenShift versions <``4.9.9``.

   .. code-block:: console

      $ oc logs nvidia-driver-daemonset-49.84.202111111343-0-6mpw4 -c openshift-driver-toolkit-ctr

   .. code-block:: console

      + '[' -f /mnt/shared-nvidia-driver-toolkit/dir_prepared ']'
      Waiting for nvidia-driver-ctr container to prepare the shared directory ...
      + echo Waiting for nvidia-driver-ctr container to prepare the shared directory ...
      + sleep 10
      + '[' -f /mnt/shared-nvidia-driver-toolkit/dir_prepared ']'
      + exec /mnt/shared-nvidia-driver-toolkit/ocp_dtk_entrypoint dtk-build-driver
      Running dtk-build-driver
      WARNING: broken Driver Toolkit image detected:
      - Node kernel:    4.18.0-305.25.1.el8_4.x86_64
      - Kernel package: 4.18.0-305.28.1.el8_4.x86_64
      INFO: informing nvidia-driver-ctr to fallback on entitled-build.
      INFO: nothing else to do in openshift-driver-toolkit-ctr container, sleeping forever.

   .. code-block:: console

       $ oc logs nvidia-driver-daemonset-49.84.202111111343-0-6mpw4 -c nvidia-driver-ctr

   .. code-block:: console

      Running nv-ctr-run-with-dtk
      + [[ '' == \t\r\u\e ]]
      + [[ ! -f /mnt/shared-nvidia-driver-toolkit/dir_prepared ]]
      + cp -r /tmp/install.sh /usr/local/bin/ocp_dtk_entrypoint /usr/local/bin/nvidia-driver /usr/local/bin/extract-vmlinux /usr/bin/kubectl /usr/local/bin/vgpu-util /drivers /licenses /mnt/shared-nvidia-driver-toolkit/
      + env
      + sed 's/=/="/'
      + sed 's/$/"/'
      + touch /mnt/shared-nvidia-driver-toolkit/dir_prepared
      + set +x
      Wed Nov 24 13:36:31 UTC 2021 Waiting for openshift-driver-toolkit-ctr container to start ...
      WARNING: broken driver toolkit detected, using entitlement-based fallback
