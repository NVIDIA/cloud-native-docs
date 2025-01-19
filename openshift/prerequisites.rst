.. Date: November 26 2021
.. Author: kquinn

*******************************************
Prerequisites for GPU Operator on OpenShift
*******************************************

Before following the steps in this guide, ensure that your environment has:

* A working OpenShift cluster up and running with a GPU worker node. See `OpenShift Container Platform installation <https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/installation_overview/ocp-installation-overview>`_  for guidance on installing.
  Refer to :external+gpuop:ref:`Container Platforms <container-platforms>` for the support matrix of the GPU Operator releases and the supported container platforms for more information.
* Access to the OpenShift cluster as a ``cluster-admin`` to perform the necessary steps.
* OpenShift CLI (``oc``) installed.
