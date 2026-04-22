.. headings # #, * *, =, -, ^, "

.. |prod-name-long| replace:: SUSE Rancher Kubernetes Engine 2
.. |prod-name-short| replace:: SUSE RKE2

#############################################
|prod-name-long| with the NVIDIA GPU Operator
#############################################


******************************
Validated Configuration Matrix
******************************

SUSE, which provides its own driver container for SUSE Linux Enterprise Server (SLES), has self-validated using the following components and versions:

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
     - v26.3.1
     - | SLES 15
       | SLES 16
     - containerd
     - 1.34
     - | NVIDIA H200 NVL
       | NVIDIA L40S


Refer to the SUSE Registry for more information on these precompiled driver containers:

* `SUSE Linux Enterprise Server 15 NVIDIA Driver <https://registry.suse.com/repositories/third-party-nvidia-driver-sles15>`__
* `SUSE Linux Enterprise Server 16 NVIDIA Driver <https://registry.suse.com/repositories/third-party-nvidia-driver-sles16>`__