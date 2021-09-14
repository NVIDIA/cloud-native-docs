.. Date: August 10 2021
.. Author: kquinn

*****************************************
Prerequisites
*****************************************
Before following the steps in this guide, ensure that your environment has:

* A working OpenShift cluster up and running with a GPU worker node. See `OpenShift Container Platform installation <https://docs.openshift.com/container-platform/latest/installing/index.html>`_  for guidance on installing. Refer to `Container Platforms <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/platform-support.html#container-platforms>`_ for the support matrix of the GPU Operator releases and the supported container platforms for more information.
* Access to the OpenShift cluster as a ``cluster-admin`` to perform the necessary steps.
* OpenShift CLI (``oc``) installed.
* Ensure that the appropriate Red Hat subscriptions and entitlements for OpenShift are properly enabled.

   .. note:: The UBI-based driver pods of the NVIDIA GPU Operator require these Red Hat subscription entitlements so that additional UBI packages can be installed.
