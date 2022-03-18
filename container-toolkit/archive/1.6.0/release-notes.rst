.. Date: September 21 2021
.. Author: elezar

.. _toolkit-release-notes-1.6.0:

*****************************************
Release Notes
*****************************************
This document describes the new features, improvements, fixed and known issues for the NVIDIA Container Toolkit.

----

NVIDIA Container Toolkit 1.7.0
====================================

This version of the NVIDIA Container Toolkit allows up to date packages to be installed on Jetson devices.
The following packages are included:

* ``nvidia-container-toolkit 1.7.0``
* ``libnvidia-container-tools 1.7.0``
* ``libnvidia-container1 1.7.0``

The following packages have also been updated to depend on ``nvidia-container-toolkit`` of at least ``1.7.0``:

* ``nvidia-container-runtime 3.7.0``
* ``nvidia-docker2 2.8.0``

Packaging Changes
------------------

* On Ubuntu ``arm64`` distributions the ``libnvidia-container-tools`` package depends on both ``libnvidia-container0`` and ``libnvidia-container1`` to support Jetson devices

Fixes and Features
-------------------

* Add a ``supported-driver-capabilities`` config option to allow for a subset of all driver capabilities to be specified
* Makes the fixes from ``v1.6.0`` to addresses an incompatibility with recent docker.io and containerd.io updates on Ubuntu installations (see `NVIDIA/nvidia-container-runtime#157 <https://github.com/NVIDIA/nvidia-container-runtime/issues/157>`_) available on Jetson devices.

specific to libnvidia-container
``````````````````````````````````

* Filter command line options based on `libnvidia-container` library version
* Include `libnvidia-container` version in CLI version output
* Allow for `nvidia-container-cli` to load `libnvidia-container.so.0` dynamically on Jetson platforms


NVIDIA Container Toolkit 1.6.0
==============================

This version of the NVIDIA Container Toolkit moves to unify the packaging of the components of the NVIDIA container stack.
The following packages are included:

* ``nvidia-container-toolkit 1.6.0``
* ``libnvidia-container-tools 1.6.0``
* ``libnvidia-container1 1.6.0``

The following packages have also been updated to depend on ``nvidia-container-toolkit`` of at least ``1.6.0``:

* ``nvidia-container-runtime 3.6.0``
* ``nvidia-docker2 2.7.0``

.. note::

    All the above packages are published to the `libnvidia-container <https://nvidia.github.io/libnvidia-container/>`_ repository.

.. note::

    As of version ``2.7.0`` the ``nvidia-docker2`` package depends directly on ``nvidia-container-toolkit``.
    This means that the ``nvidia-container-runtime`` package is no longer required and may be uninstalled as part of the upgrade process.


Packaging Changes
------------------

* The ``nvidia-container-toolkit`` package now provides the ``nvidia-container-runtime`` executable
* The ``nvidia-docker2`` package now depends directly on the ``nvidia-container-toolkit`` directly
* The ``nvidia-container-runtime`` package is now an architecture-independent meta-package serving only to define a dependency on the ``nvidia-container-toolkit`` for workflows that require this
* Added packages for Amazon Linux 2 on AARC64 platforms for all components


Fixes and Features
------------------

* Move OCI and command line checks for the NVIDIA Container Runtime to an internal go package (``oci``)
* Update OCI runtime specification dependency to `opencontainers/runtime-spec@a3c33d6 <https://github.com/opencontainers/runtime-spec/commit/a3c33d663ebc/>`_ to fix compatibility with docker when overriding clone3 syscall return value [fixes `NVIDIA/nvidia-container-runtime#157 <https://github.com/NVIDIA/nvidia-container-runtime/issues/157>`_]
* Use relative path to OCI specification file (``config.json``) if bundle path is not specified as an argument to the nvidia-container-runtime

specific to libnvidia-container
``````````````````````````````````

* Bump ``nvidia-modprobe`` dependency to ``495.44`` in the NVIDIA Container Library to allow for non-root monitoring of MIG devices
* Fix bug that lead to unexpected mount error when ``/proc/driver/nvidia`` does not exist on the host


Known Issues
---------------

Dependency errors when installing older versions of ``nvidia-container-runtime`` on Debian-based systems
``````````````````````````````````````````````````````````````````````````````````````````````````````````

With the release of the ``1.6.0`` and ``3.6.0`` versions of the ``nvidia-container-toolkit`` and
``nvidia-container-runtime`` packages, respectively, some files were reorganized and the package
dependencies updated accordingly. (See case 10 in the `Debian Package Transition <https://wiki.debian.org/PackageTransition>`_ documentation).

Due to these new constraints a package manager may not correctly resolve the required version of ``nvidia-container-toolkit`` when
pinning to versions of the ``nvidia-container-runtime`` prior to ``3.6.0``.

This means that if a command such as:

.. code-block:: console

    sudo apt-get install nvidia-container-runtime=3.5.0-1

is used to install a specific version of the ``nvidia-container-runtime`` package, this may fail with the following error message:

.. code-block:: console

    Some packages could not be installed. This may mean that you have
    requested an impossible situation or if you are using the unstable
    distribution that some required packages have not yet been created
    or been moved out of Incoming.
    The following information may help to resolve the situation:

    The following packages have unmet dependencies:
    nvidia-container-runtime : Depends: nvidia-container-toolkit (>= 1.5.0) but it is not going to be installed
                                Depends: nvidia-container-toolkit (< 2.0.0) but it is not going to be installed
    E: Unable to correct problems, you have held broken packages.

In order to address this, the versions of the ``nvidia-container-toolkit`` package should be specified explicitly to be at most ``1.5.1``

.. code-block:: console

    sudo apt-get install \
        nvidia-container-runtime=3.5.0-1 \
        nvidia-container-toolkit=1.5.1-1

In general, it is suggested that all components of the NVIDIA container stack be pinned to their required versions.

For the ``nvidia-container-runtime`` ``3.5.0`` these are:

* ``nvidia-container-toolkit 1.5.1``
* ``libnvidia-container-tools 1.5.1``
* ``libnvidia-container1 1.5.1``

To pin all the package versions above, run:

.. code-block:: console

    sudo apt-get install \
        nvidia-container-runtime=3.5.0-1 \
        nvidia-container-toolkit=1.5.1-1 \
        libnvidia-container-tools=1.5.1-1 \
        libnvidia-container1==1.5.1-1


Toolkit Container 1.7.0
=======================

Known issues
------------

* The ``container-toolkit:1.7.0-ubuntu18.04`` image contains the `CVE-2021-3711 <http://people.ubuntu.com/~ubuntu-security/cve/CVE-2021-3711>`_. This CVE affects ``libssl1.1`` and ``openssl`` included in the ubuntu-based CUDA `11.4.1` base image. The components of the NVIDIA Container Toolkit included in the container do not use ``libssl1.1`` or ``openssl`` and as such this is considered low risk if the container is used as intended; that is to install and configure the NVIDIA Container Toolkit in the context of the NVIDIA GPU Operator.
