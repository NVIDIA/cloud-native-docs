Supported Platforms
====================

Following are the platforms supported by Confidential Containers open Reference Architecture published by NVIDIA.

Supported Hardware Platforms
----------------------------

.. flat-table::
   :header-rows: 1

   * - Category
     - Release/Version
   * - GPU Platform
     - | Hopper 100/200
       | Blackwell B200
       | Blackwell RTX Pro 6000
   * - CPU Platform
     - | AMD Genoa/ Milan
       | Intel ER/ GR

Supported Software Components
-----------------------------

.. flat-table::
   :header-rows: 1

   * - Component
     - Release/Version
   * - Host OS
     - Ubuntu 25.10
   * - Host Kernel
     - 6.17+
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
     - v25.10.0 and higher 
   * - Kata 
     - 3.25 (w/ kata-deploy helm) 
   * - KBS protocol
     - 0.4.0 
   * - Kubernetes
     - 1.32+
   * - Attestation Support
     - Composite Attestation for CPU \+ GPU; integration with Trustee for local verifier.

.. _coco-supported-platforms:

Limitations and Restrictions
----------------------------

* GPUs are available to containers as a single GPU in passthrough mode only. Multi-GPU passthrough and vGPU are not supported.
* Support is limited to initial installation and configuration only. Upgrade and configuration of existing clusters to configure confidential computing is not supported.
* Support for confidential computing environments is limited to the implementation described on this page.
* NVIDIA supports the GPU Operator and confidential computing with the containerd runtime only.
* NFD doesn't label all Confidential Container capable nodes as such automatically. In some cases, users must manually label nodes to deploy the NVIDIA Confidential Computing Manager for Kubernetes operand onto these nodes as described in the deployment guide.