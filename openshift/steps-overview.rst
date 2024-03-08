.. Date: Aug 22 2022
.. Author: kquinn

.. headings # #, * *, =, -, ^, "

.. _steps_overview:

#################################
Installation and Upgrade Overview
#################################

.. contents::
   :depth: 2
   :local:
   :backlinks: none


****************
High-Level Steps
****************

Follow these high-level steps to install an entitlement-free supported version of the NVIDIA GPU Operator:

#. :ref:`install-nfd`.
#. :ref:`install-nvidiagpu`.
#. :ref:`running-sample-app`.

.. important::

   The installation process for NVIDIA AI Enterprise customers is documented separately.
   Refer to :doc:`nvaie-with-ocp`.

*********************************
Preparing to Install the Operator
*********************************

You can deploy the Operator on a a newly deployed cluster that was not upgraded without entitlement on the following versions:

* OpenShift 4.9.9 and above z-streams

.. * OpenShift 4.8.22 and above z-streams
.. * All the versions of OpenShift 4.9 except 4.9.8

=========================================
Special Considerations for OpenShift 4.15
=========================================

In OpenShift 4.15, secrets are no longer automatically generated when the integrated OpenShift image registry is disabled.
For more information, see `OpenShift 4.15 Release notes <https://docs.openshift.com/container-platform/4.15/release_notes/ocp-4-15-release-notes.html#ocp-4-15-auth-generated-secrets>`_.

This affects the NVIDIA GPU Operator, where the lack of registry enabled blocks the creation of
the ``DriverToolkit DaemonSet`` when it checks for the existence of a ``build-dockercfg`` secret for
the Driver Toolkit service account. This results in a stalled state for the NVIDIA GPU Operator:

.. code-block:: console

   % oc get pods  -n nvidia-gpu-operator

*Example Output*

.. code-block:: output

   NAME                                                  READY   STATUS            RESTARTS   AGE
   gpu-feature-discovery-sdqsz                           0/1     Init:0/1          0          21s
   gpu-operator-76d46f779b-6p8bl                         1/1     Running           0          5d15h
   nvidia-container-toolkit-daemonset-pxwdm              0/1     Init:0/1          0          21s
   nvidia-dcgm-exporter-g78h4                            0/1     Init:0/2          0          20s
   nvidia-dcgm-j5bsj                                     0/1     Init:0/1          0          20s
   nvidia-device-plugin-daemonset-b5lrj                  0/1     Init:0/1          0          20s
   nvidia-driver-daemonset-415.92.202402201450-0-ggztt   0/2     PodInitializing   0          69s
   nvidia-node-status-exporter-6lt9p                     1/1     Running           0          5d15h
   nvidia-operator-validator-wpcq6                       0/1     Init:0/4          0          20s

To ensure the NVIDIA GPU Operator runs on OpenShift 4.15 you need to have a registry setup.
You should configure a registry with a PVC openshift-image-registry, as explained in
`Image Registry Operator in OpenShift Container Platform <https://docs.openshift.com/container-platform/latest/registry/configuring-registry-operator.html>`_.

If your storage registry is not configured and for non-production cluster, you can use an ephemeral
storage (emptyDir):

.. code-block:: console

   % oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"emptyDir":{}}}}'


You can switch the registry in Managed state:

.. code-block:: console

% oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"managementState":"Managed"}}'


When the registry is in Managed state, the NVIDIA GPU Operator creates the secrets:

.. code-block:: console

   % oc get secrets -n nvidia-gpu-operator


*Example Output*

.. code-block:: output

   NAME                                       	TYPE                               	DATA   AGE
   builder-dockercfg-rnt7v                    	kubernetes.io/dockercfg           	1      59s
   builder-token-wt69b                        	kubernetes.io/service-account-token 4  	   63s
   default-dockercfg-qmkpw                    	kubernetes.io/dockercfg           	1  	   59s
   default-token-fv25v                        	kubernetes.io/service-account-token 4    	 63s
   deployer-dockercfg-bl9k4                   	kubernetes.io/dockercfg           	1  	   59s
   deployer-token-7mbpl                       	kubernetes.io/service-account-token 4  	   63s
   gpu-operator-dockercfg-8q6kv               	kubernetes.io/dockercfg           	1      59s
   gpu-operator-token-s74gl                   	kubernetes.io/service-account-token 4      63s
   nvidia-container-toolkit-dockercfg-vxbjl   	kubernetes.io/dockercfg           	1  	   59s
   nvidia-container-toolkit-token-rjl4d       	kubernetes.io/service-account-token 4      63s
   nvidia-dcgm-dockercfg-wbrhq                	kubernetes.io/dockercfg           	1  	   59s
   nvidia-dcgm-exporter-dockercfg-b9r67       	kubernetes.io/dockercfg           	1  	   59s
   nvidia-dcgm-exporter-token-fbhjr           	kubernetes.io/service-account-token 4  	   63s
   nvidia-dcgm-token-9dcdh                    	kubernetes.io/service-account-token 4  	   63s
   nvidia-device-plugin-dockercfg-k9zzj       	kubernetes.io/dockercfg           	1  	   59s
   nvidia-device-plugin-token-lpt7v           	kubernetes.io/service-account-token 4  	   63s
   nvidia-driver-dockercfg-lkpj9              	kubernetes.io/dockercfg           	1  	   59s
   nvidia-driver-token-7hw7h                  	kubernetes.io/service-account-token 4  	   63s
   nvidia-gpu-feature-discovery-dockercfg-bhm2s   kubernetes.io/dockercfg           1  	   59s
   nvidia-gpu-feature-discovery-token-m25nq   	kubernetes.io/service-account-token 4  	   63s
   nvidia-mig-manager-dockercfg-vv8sg         	kubernetes.io/dockercfg           	1  	   59s
   nvidia-mig-manager-token-rqpnl             	kubernetes.io/service-account-token 4  	   63s
   nvidia-node-status-exporter-dockercfg-wzlfm	kubernetes.io/dockercfg           	1  	   59s
   nvidia-node-status-exporter-token-mjcvh    	kubernetes.io/service-account-token 4  	   63s
   nvidia-operator-validator-dockercfg-glr5p  	kubernetes.io/dockercfg           	1  	   59s
   nvidia-operator-validator-token-fx52q      	kubernetes.io/service-account-token 4  	   63s


After few minutes, the NVIDIA GPU Operator is fully installed:

.. code-block:: console

   % oc get pods -n nvidia-gpu-operator

*Example Output*

.. code-block:: output

   NAME                                              	READY   STATUS  	RESTARTS   AGE
   gpu-feature-discovery-sdqsz                       	1/1 	Running 	  0        	 3m22s
   gpu-operator-76d46f779b-6p8bl                     	1/1 	Running 	  0      	   5d15h
   nvidia-container-toolkit-daemonset-pxwdm          	1/1 	Running 	  0      	   3m22s
   nvidia-cuda-validator-7j2p9                       	0/1 	Completed   0      	   45s
   nvidia-dcgm-exporter-g78h4                        	1/1 	Running 	  0      	   3m21s
   nvidia-dcgm-j5bsj                                 	1/1 	Running 	  0      	   3m21s
   nvidia-device-plugin-daemonset-b5lrj              	1/1 	Running 	  0      	   3m21s
   nvidia-driver-daemonset-415.92.202402201450-0-ggztt   2/2 	Running 	0      	   4m10s
   nvidia-node-status-exporter-6lt9p                 	1/1 	Running 	  0      	   5d15h
   nvidia-operator-validator-wpcq6                   	1/1 	Running 	  0      	   3m21s


.. note::

   The Driver Toolkit, which enables entitlement-free deployments of the Operator, is available for certain z-streams on OpenShift
   4.8 and all z-streams on OpenShift 4.9. However, some Driver Toolkit images are broken, so we recommend maintaining entitlements for
   all OpenShift versions prior to 4.9.9. See :ref:`broken driver toolkit <broken-dtk>` for more information.

   You do not need an entitlement on OpenShift Container Platform versions greater than 4.9.9.

-  Verify your cluster has the OpenShift Driver toolkit:

   .. code-block:: console

      $ oc get -n openshift is/driver-toolkit

   *Example Output*

   .. code-block:: output

      NAME             IMAGE REPOSITORY                                                            TAGS                           UPDATED
      driver-toolkit   image-registry.openshift-image-registry.svc:5000/openshift/driver-toolkit   410.84.202203290245-0,latest   47 minutes ago


*********************************
Preparing to Upgrade the Operator
*********************************

After an upgrade a bug in OpenShift Cluster Version Operator (`BZ#2014071 <https://bugzilla.redhat.com/show_bug.cgi?id=2014071>`_) prevents the proper upgrade of the Driver Toolkit image stream.
A fix for this issue has been merged in the following releases:

* OpenShift 4.8.21 and above z-streams
* OpenShift 4.9.5 and above z-streams

#. Verify your cluster is affected by this bug, search for a tag with an empty name:

   .. code-block:: console

      $ oc get -n openshift is/driver-toolkit '-ojsonpath={.spec.tags[?(@.name=="")]}'

   *Example Output*

   .. code-block:: json

      {{"annotations":null,"from":{"kind":"DockerImage","name":"[quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:71207482fa6fcef0e3ca283d0cafebed4d5ac78c62312fd6e19ac5ca2294d296](http://quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:71207482fa6fcef0e3ca283d0cafebed4d5ac78c62312fd6e19ac5ca2294d296)"},"generation":5,"importPolicy":{"scheduled":true},"name":"","referencePolicy":{"type":"Source"}}

#. As a workaround, delete the broken image stream and the Cluster Version Operator recreates it:

   .. code-block:: console

      $ oc delete -n openshift is/driver-toolkit

   *Example Output*

   .. code-block:: output

      imagestream.image.openshift.io "driver-toolkit" deleted


.. _broken-dtk:

*******************************
About the Broken Driver Toolkit
*******************************

OpenShift 4.8.19, 4.8.21, 4.9.8 are known to have a broken Driver Toolkit image.
The following messages are recorded in the driver pod containers.
Follow the guidance in :ref:`enabling a Cluster-wide entitlement <cluster-entitlement>`.
Afterward, the ``nvidia-driver-daemonset`` automatically uses an entitlement-based fallback.

To disable the use of Driver Toolkit image altogether, edit the cluster policy instance and set ``driver.use_ocp_driver_toolkit`` option to ``false``.
Also, we recommend maintaining entitlements for OpenShift versions < 4.9.9.

#. View the logs from the OpenShift Driver Toolkit container:

   .. code-block:: console

      $ oc logs nvidia-driver-daemonset-49.84.202111111343-0-6mpw4 -c openshift-driver-toolkit-ctr

   *Example Output*

   .. code-block:: output

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

#. View the logs from the NVIDIA Driver container:

   .. code-block:: console

      $ oc logs nvidia-driver-daemonset-49.84.202111111343-0-6mpw4 -c nvidia-driver-ctr

   *Example Output*

   .. code-block:: output

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
