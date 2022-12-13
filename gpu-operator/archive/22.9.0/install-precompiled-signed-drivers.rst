.. Date: Mar 15 2022
.. Author: smerla

.. _install-precompiled-signed-drivers-22.9.0:

Installing Precompiled and Canonical Signed Drivers on Ubuntu20.04
******************************************************************

GPU Operator supports deploying NVIDIA precompiled and signed drivers from Canonical on Ubuntu20.04. This is required
when nodes are enabled with Secure Boot. In order to use these, GPU Operator needs to be installed with options ``--set driver.version=<DRIVER_BRANCH>-signed``.

.. code-block:: console

   $ helm install --wait gpu-operator \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set driver.version=<DRIVER_BRANCH>-signed

supported DRIVER_BRANCH value currently are ``470`` and ``510`` which will install latest drivers available on that branch for current running
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
