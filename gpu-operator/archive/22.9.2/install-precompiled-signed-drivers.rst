.. Date: Mar 15 2022
.. Author: smerla

.. _install-precompiled-signed-drivers-22.9.2:

Installing Precompiled and Canonical Signed Drivers on Ubuntu 20.04 and 22.04
*****************************************************************************

GPU Operator supports deploying NVIDIA precompiled and signed drivers from Canonical on Ubuntu 20.04 and 22.04 (x86 platform only). This is required
when nodes are enabled with Secure Boot. In order to use these, GPU Operator needs to be installed with options ``--set driver.version=<DRIVER_BRANCH>-signed``.

.. code-block:: console

   $ helm install --wait gpu-operator \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set driver.version=<DRIVER_BRANCH>-signed

supported DRIVER_BRANCH value currently are ``470``, ``510`` and ``515`` which will install latest drivers available on that branch for current running
kernel version.

Following are the packages used in this case by the driver container.

* linux-objects-nvidia-${DRIVER_BRANCH}-server-${KERNEL_VERSION} - Linux kernel nvidia modules.
* linux-signatures-nvidia-${KERNEL_VERSION} - Linux kernel signatures for nvidia modules.
* linux-modules-nvidia-${DRIVER_BRANCH}-server-${KERNEL_VERSION} - Meta package for nvidia driver modules, signatures and kernel interfaces.
* nvidia-utils-${DRIVER_BRANCH}-server - NVIDIA driver support binaries.
* nvidia-compute-utils-${DRIVER_BRANCH}-server - NVIDIA compute utilities (includes nvidia-persistenced).

.. note::

   * Before upgrading kernel on the worker nodes please ensure that above packages are available for that kernel version, else upgrade will
     cause driver installation failures.

To check if above packages are available for a specific kernel version, use the following commands (in this example, we use the 515 branch):


.. code-block:: console

   $ KERNEL_VERSION=$(uname -r)
   $ DRIVER_BRANCH=515
   $ sudo apt-get update
   $ sudo apt-cache show linux-modules-nvidia-${DRIVER_BRANCH}-server-${KERNEL_VERSION}

A successful output is shown below:

.. code-block:: console

   $ sudo apt-cache show linux-modules-nvidia-${DRIVER_BRANCH}-server-${KERNEL_VERSION}
   
   Package: linux-modules-nvidia-515-server-5.15.0-56-generic
   Architecture: amd64
   Version: 5.15.0-56.62+1
   Priority: optional
   Section: restricted/kernel
   Source: linux-restricted-modules
   Origin: Ubuntu
   Maintainer: Canonical Kernel Team <kernel-team@lists.ubuntu.com>
   Bugs: https://bugs.launchpad.net/ubuntu/+filebug
   Installed-Size: 34
   Depends: debconf (>= 0.5) | debconf-2.0, linux-image-5.15.0-56-generic | linux-image-unsigned-5.15.0-56-generic, linux-signatures-nvidia-5.15.0-56-generic  (= 5.15.0-56.62+1), linux-objects-nvidia-515-server-5.15.0-56-generic (= 5.15.0-56.62+1), nvidia-kernel-common-515-server (<= 515.86.01-1), nvidia-kernel-common-515-server (>= 515.86.01)
   Filename: pool/restricted/l/linux-restricted-modules/linux-modules-nvidia-515-server-5.15.0-56-generic_5.15.0-56.62+1_amd64.deb
   Size: 7040
   MD5sum: 530d817653545eaac63ec64d6edc115c
   SHA1: e2fd492c06a9be7d0a603d6861d7e35a267d2943
   SHA256: 999477c5bd0b213196ed93fd6340a0183dc3d8202be2aa5a008d50f3ba184a3a
   SHA512: 45b2bd3f377449742c92b5f7c89c09540edd3e5162cc8d87e3a2c5c45939595c9972982a1ff4e520a56b1525b9f208a2b791619f028f6b420faec0892c430632
   Description-en: Linux kernel nvidia modules for version 5.15.0-56
   This package pulls together the Linux kernel nvidia modules for
   version 5.15.0-56 with the appropriate signatures.
   .
   You likely do not want to install this package directly. Instead, install the
   one of the linux-modules-nvidia-515-server-generic* meta-packages,
   which will ensure that upgrades work correctly, and that supporting packages are
   also installed.
   Description-md5: 13391e5f98aed1dde0d387f22d097bed
