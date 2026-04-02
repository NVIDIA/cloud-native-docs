Supported Platforms
====================

Following are the platforms supported by the NVIDIA Confidential Containers Reference Architecture.

Supported Hardware Platform
---------------------------

NVIDIA GPUs
-----------

.. flat-table::
   :header-rows: 1

   * - GPU Platform
   * - NVIDIA Hopper 100
   * - NVIDIA Hopper 200
   * - NVIDIA Blackwell B200
   * - NVIDIA Blackwell RTX Pro 6000

CPU Platforms
-------------

.. flat-table::
   :header-rows: 1

   * - Category
     - Operating System
     - Kernel Version
   * - AMD Genoa / Milan
     - Ubuntu 25.10
     - 6.17+
   * - Intel Emerald Rapids (ER) /  Granite Rapids (GR)
     - Ubuntu 25.10
     - 6.17+

For additional information on node configuration, refer to the `Confidential Computing Deployment Guide <https://docs.nvidia.com/cc-deployment-guide-tdx-snp.pdf>`_ for information about supported NVIDIA GPUs, such as the NVIDIA Hopper H100. 

The following topics in the deployment guide apply to a cloud-native environment:

* Hardware selection and initial hardware configuration, such as BIOS settings.
* Host operating system selection, initial configuration, and validation.

When following the cloud-native sections in the deployment guide linked above, use Ubuntu 25.10 as the host OS with its default kernel version and configuration.

For additional resources on machine setup:

* Refer to the `NVIDIA Trusted Computing Solutions website <https://docs.nvidia.com/nvtrust/index.html>`_.
* Refer to the :doc:`Licensing <licensing>` page for more information on the licensing requirements for NVIDIA Confidential Computing capabilities.

Supported Software Components
-----------------------------

.. flat-table::
   :header-rows: 1

   * - Component
     - Release/Version
   * - Guest OS
     - Distroless
   * - Guest kernel
     - 6.18.5
   * - OVMF
     - edk2-stable202511
   * - QEMU
     - 10.1 \+ Patches
   * - Containerd
     - 2.2.2 \+
   * - Kubernetes
     - 1.32 \+
   * - Node Feature Discovery (NFD)
     - v0.6.0
   * - NVIDIA GPU Operator
     - v26.3.0 and higher 
   * - Kata Containers
     - 3.29 (w/ kata-deploy helm) 
   * - Key Broker Service (KBS) protocol
     - 0.4.0 


.. _coco-supported-platforms:



