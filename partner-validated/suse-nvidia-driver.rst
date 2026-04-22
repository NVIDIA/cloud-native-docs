.. headings # #, * *, =, -, ^, "

.. |prod-name-long| replace:: SUSE Linux Enterprise Server NVIDIA Driver
.. |prod-name-short| replace:: SLES NVIDIA Driver

#########################################
NVIDIA GPU Operator with |prod-name-long|
#########################################


******************************
Validated Configuration Matrix
******************************

|prod-name-short|  has self-validated with the following components and versions:

.. list-table::
   :header-rows: 1

   * - Version
     - | NVIDIA
       | GPU Operator
     - | Operating
       | System
     - | Container
       | Runtime
     - Kubernetes
     - NVIDIA GPU

   * - RKE2
     - | 25.10
       | 26.3
     - | SLES 15
       | SLES 16
     - Containerd
     - 1.34
     - | NVIDIA H200 NVL
       | L40S


* Refer to the SUSE Registry for more information on these precomplied drivers:

  * `SUSE Linux Enterprise Server 15 NVIDIA Driver <https://registry.suse.com/repositories/third-party-nvidia-driver-sles15>`__
  * `SUSE Linux Enterprise Server 16 NVIDIA Driver <https://registry.suse.com/repositories/third-party-nvidia-driver-sles16>`__