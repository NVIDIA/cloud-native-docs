.. Date: July 30 2020
.. Author: pramarao

.. _operator-platform-support:

****************
Platform Support
****************
This documents provides an overview of the GPUs and system platform configurations supported.

GPUs
----
Pascal+ GPUs are supported (incl. Tesla V100 and T4)

Container Platforms
-------------------
The following Kubernetes platforms are supported:

* Kubernetes v1.13+
* Red Hat OpenShift 4.1, 4.2 and 4.3 using Red Hat Enterprise Linux CoreOS (RHCOS) and CRI-O container runtime. See 
  the OpenShift `guide <https://docs.nvidia.com/datacenter/kubernetes/openshift-on-gpu-install-guide/index.html>`_ for getting started.
* Google Cloud Anthos. See the user `guide <https://docs.nvidia.com/datacenter/kubernetes/openshift-on-gpu-install-guide/index.html>`_ for getting started.

.. note::
   Note that the Kubernetes community supports only the last three minor releases as of v1.17. Older releases 
   may be supported through enterprise distributions of Kubernetes such as Red Hat OpenShift. See the prerequisites 
   for enabling monitoring in Kubernetes releases before v1.16.

Linux distributions
-------------------
The following Linux distributions are supported:

* Ubuntu 18.04.z LTS
* Red Hat Enterprise Linux CoreOS (RHCOS) for use with OpenShift
* CentOS 8 (HVM only, PV not supported)

In addition, the following container management tools are supported:

* Helm v3 (v3.1.z)
* Docker CE 19.03.z

.. note::
   Note that the GA has been validated with the 4.15 LTS kernel. When using the HWE kernel (e.g. v5.3), there are additional prerequisites before deploying the operator.

Deployment Scenarios
--------------------
The GPU Operator has been validated in the following scenarios:

* Bare-metal
* GPU passthrough virtualization

.. note::
   The GPU Operator deploys the NVIDIA driver as a container. In this environment, running on desktop environments (e.g. workstations with GPUs and display) is not 
   supported.

Software Versions
------------------
The GPU operator has been validated with the following NVIDIA components:

* NVIDIA Container Toolkit ``1.0.5``
* NVIDIA Kubernetes Device Plugin ``1.0.0-beta4``
* NVIDIA Tesla Driver 440 (Current release is ``440.64.00``. See driver release notes)
* NVIDIA DCGM ``1.7.2``

