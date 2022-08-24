.. Date: Aug 22 2022
.. Author: kquinn

.. _steps_overview:

*****************************************
Overview
*****************************************
Follow these steps to install the **NVIDIA GPU Operator**:

#. :ref:`install-nfd`.
#. :ref:`install-nvidiagpu`.
#. :ref:`running-sample-app`.


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
   all OpenShift versions prior to 4.9.9. See :ref:`broken driver toolkit <broken-dtk>` for more information.

   You do not need an entitlement on OpenShift Container Platform versions greater than 4.9.9.

#. Verify your cluster has the OpenShift Driver toolkit:

   .. code-block:: console

      $ oc get -n openshift is/driver-toolkit

   Expected output example:

   .. code-block:: console

      NAME             IMAGE REPOSITORY                                                            TAGS                           UPDATED
      driver-toolkit   image-registry.openshift-image-registry.svc:5000/openshift/driver-toolkit   410.84.202203290245-0,latest   47 minutes ago


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

.. _broken-dtk:

Broken driver toolkit
=====================

OpenShift `4.8.19`, `4.8.21`, `4.9.8` are known to have a broken Driver Toolkit image. The following messages are recorded in the driver Pod containers. Follow the guidance in :ref:`enabling a Cluster-wide entitlement <cluster-entitlement>` and once complete the ``nvidia-driver-daemonset`` will automatically fallback. To disable the usage of Driver Toolkit image altogether, edit the **ClusterPolicy** instance and set ``driver.use_ocp_driver_toolkit`` option to ``false``. Also, we recommend maintaining entitlements for OpenShift versions <``4.9.9``.

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
