.. Date: July 30 2020
.. Author: pramarao

.. _operator-platform-support:

****************
Platform Support
****************
This documents provides an overview of the GPUs and system platform configurations supported.

GPUs
----
Pascal+ GPUs are supported (incl. NVIDIA A100, T4 and V100). 

.. note:: 

   The GPU Operator only supports platforms using discrete GPUs - Jetson or other embedded products with integrated GPUs are not supported. 

Container Platforms
-------------------
The following Kubernetes platforms are supported:

* Kubernetes v1.13+
* Red Hat OpenShift 4 using Red Hat Enterprise Linux CoreOS (RHCOS) and CRI-O container runtime. See 
  the OpenShift `guide <https://docs.nvidia.com/datacenter/kubernetes/openshift-on-gpu-install-guide/index.html>`_ for getting started.
* Google Cloud Anthos. See the user `guide <https://docs.nvidia.com/datacenter/cloud-native/kubernetes/anthos-guide.html>`_ for getting started.

.. note::
   Note that the Kubernetes community supports only the last three minor releases as of v1.17. Older releases 
   may be supported through enterprise distributions of Kubernetes such as Red Hat OpenShift. See the prerequisites 
   for enabling monitoring in Kubernetes releases before v1.16.

The following table includes the support matrix of the GPU Operator releases and supported container platforms.

.. tabs:: 

    .. tab:: Baremetal/Passthrough

      +--------------------------+---------------+------------------------+----------------+
      | GPU Operator Release     | Kubernetes    | OpenShift              | Anthos         |
      +==========================+===============+========================+================+
      | 1.5.0                    | v1.13+        | 4.4.29+, 4.5 and 4.6   | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.4.0                    | v1.13+        | 4.4.29+, 4.5 and 4.6   | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.3.0                    | v1.13+        | 4.4.29+, 4.5 and 4.6   | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.2.0                    | v1.13+        | Not supported          | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.1.7                    | v1.13+        | 4.1, 4.2, 4.3, and 4.4 | Supported      |
      +--------------------------+---------------+------------------------+----------------+
      | 1.1.0                    | v1.13+        | Not supported          | Not supported  |
      +--------------------------+---------------+------------------------+----------------+
      | 1.0.0                    | v1.13+        | Not supported          | Not supported  |
      +--------------------------+---------------+------------------------+----------------+

    .. tab:: NVIDIA vGPU

      +--------------------------+---------------+------------------------+----------------+
      | GPU Operator Release     | Kubernetes    | OpenShift              | Anthos         |
      +==========================+===============+========================+================+
      | 1.5.0                    | v1.13+        | 4.6                    | Not Supported  |
      +--------------------------+---------------+------------------------+----------------+

Linux distributions
-------------------

.. tabs:: 

    .. tab:: Baremetal/Passthrough

         The following Linux distributions are supported:

         * Ubuntu 18.04.z, 20.04.z LTS
         * Red Hat Enterprise Linux CoreOS (RHCOS) for use with OpenShift 4.4, 4.5, 4.6
         * CentOS 7 and 8

    .. tab:: NVIDIA vGPU

         The following Linux distributions are supported:

         * Ubuntu 20.04.z LTS
         * Red Hat Enterprise Linux CoreOS (RHCOS) for use with OpenShift 4.6

In addition, the following container management tools are supported:

* Helm v3
* Docker CE 19.03.z
* containerd 1.4+
* CRI-O with OpenShift 4 using Red Hat Enterprise Linux CoreOS (RHCOS)

Supported NVIDIA vGPU Products
------------------------------

NVIDIA vGPU 12.0+ with the following software products

* NVIDIA Virtual Compute Server (C-Series)
* NVIDIA RTX Virtual Workstation (vWS)

Supported Hypervisors with NVIDIA vGPU
--------------------------------------

The following Virtualization Platforms are supported. Refer to the `NVIDIA vGPU Documentation <https://docs.nvidia.com/grid/12.0/product-support-matrix/index.html>`_ for more detailed information.

* VMware vSphere 7
* Red Hat Enterprise Linux KVM 
* Red Hat Virtualization (RHV)

.. .. note::
..   Note that the GA has been validated with the 4.15 LTS kernel. When using the HWE kernel (e.g. v5.3), there are additional prerequisites before deploying the operator.

Deployment Scenarios
--------------------
The GPU Operator has been validated in the following scenarios:

* Bare-metal
* GPU passthrough virtualization
* NVIDIA vGPU

.. note::
   The GPU Operator deploys the NVIDIA driver as a container. In this environment, running on desktop environments (e.g. workstations with GPUs and display) is not 
   supported.
