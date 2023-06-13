.. headings # #, * *, =, -, ^, "

.. |prod-name-long| replace:: Your Product Name v1.0
.. |prod-name-short| replace:: YPN

#########################################
NVIDIA GPU Operator with |prod-name-long|
#########################################

.. contents::
   :depth: 2
   :local:
   :backlinks: none


*********************************************
About the GPU Operator with |prod-name-short|
*********************************************

Use this section of the documentation to describe the benefits that customers
can experience by using the NVIDIA GPU Operator and the product together.

Providing a summary of the competitive advantages that your product provides
is appropriate.

Providing a URL to your product documentation so readers can learn more about
your product is also appropriate.


******************************
Validated Configuration Matrix
******************************

Identify the hardware baseline that was used to self-validate your product with
the Operator.

.. rubric:: Example

.. list-table::
   :header-rows: 1

   * - <product-name-short>
     - | NVIDIA
       | GPU Operator
     - | Operating
       | System
     - | Container
       | Runtime
     - Kubernetes
     - Helm
     - NVIDIA GPU
     - Hardware Model

  * - |prod-name-long|
    - v23.3.1
    - | Ubuntu 22.04
      | Ubuntu 20.04
    - containerd v1.6
    - 1.25, 1.26
    - v3
    - | NVIDIA HGX H100
      | NVIDIA H100
      | NVIDIA A100
    - | Dell PowerEdge R740
      | 2 $\times$ Intel Xeon Silver 2.2 GHz
      | 64GB RAM, 1TB NVMe

Include at least the following pieces of information:

* **Product name.**
  Specify your product name and version.

* **GPU Operator version.**
  Specify the version of the NVIDIA GPU Operator that you self-validated.

* **Operating system.**
  Specify the operating system name and version that you self-validated.

* **Container runtime.**
  Specify the container runtime name and version.
  Refer to the
  `Supported Container Runtimes <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/platform-support.html#supported-container-runtimes>`_
  section of the platform support page.

* **Kubernetes version.**
  Specify the Kubernetes version, such as ``1.25``, that your product uses.

* **Helm version.**
  Specify the version of Helm that you used with your product to self-validate.
  If Helm is not used to install the NVIDIA GPU Operator, identify the product
  and version that you used for installation.

* **NVIDIA GPU model.**
  Use the same product model name that is provided in the
  `Supported NVIDIA GPUs and Systems <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/platform-support.html#supported-nvidia-gpus-and-systems>`_
  section of the platform support page.

* **Hardware model.**
  Including a summary of the CPU model, number of CPUs, memory, and other
  popular specifications is appropriate.


*************
Prerequisites
*************

Specify the conditions that the customer must meet before beginning to install
the NVIDIA GPU Operator.

References to product documentation are appropriate.

A few commands with brief example output that customers can run to verify their
readiness is appropriate.

A bulleted list is an effective presentation for simple and brief prerequisites
information, but is not required.

If the prerequisites are not simple and require running several commands to
verify readiness to begin, organize the commands or requirements into stages
and create a level 3 heading for each of the stages.


*********
Procedure
*********

You can keep the heading as Procedure, or you can replace with text similar to
Configuring |prod-name-short| with the GPU Operator.

If the procedure is in the range of 7 to 10 steps, then present them after
the heading.

If the procedure is more sophisticated, organize the steps into stages and
create a level 3 heading for each of the stages.


****************************************************
Verifying |prod-name-short| with the GPU Operator
****************************************************

Optionally, include commands that the customer can run to verify that the
installation is successful and that workloads can use the NVIDIA GPUs.


***************
Getting Support
***************

Indicate how end users can receive support from you regarding your product.

Also indicate that end users can open issues on the NVIDIA GPU Operator
repository on GitHub and indicate the user account to mention for assistance: https://github.com/NVIDIA/gpu-operator.


*******************
Related Information
*******************

Provide URLs to product documentation, support forums, and so on.