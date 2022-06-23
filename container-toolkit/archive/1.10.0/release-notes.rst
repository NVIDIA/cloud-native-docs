.. Date: September 21 2021
.. Author: elezar

.. _toolkit-release-notes-1.10.0:

*****************************************
Release Notes
*****************************************
This document describes the new features, improvements, fixed and known issues for the NVIDIA Container Toolkit.

----

NVIDIA Container Toolkit 1.10.0
====================================

This release of the NVIDIA Container Toolkit ``v1.10.0`` is primarily targeted at improving support for Tegra-based systems.
It sees the introduction of a new mode of operation for the NVIDIA Container Runtime that makes modifications to the incoming OCI runtime
specification directly instead of relying on the NVIDIA Container CLI.

The following packages are included:

* ``nvidia-container-toolkit 1.10.0``
* ``libnvidia-container-tools 1.10.0``
* ``libnvidia-container1 1.10.0``

The following ``container-toolkit`` containers are included:

* ``nvcr.io/nvidia/k8s/container-toolkit:v1.10.0-centos7``
* ``nvcr.io/nvidia/k8s/container-toolkit:v1.10.0-ubi8``
* ``nvcr.io/nvidia/k8s/container-toolkit:v1.10.0-ubuntu18.04``
* ``nvcr.io/nvidia/k8s/container-toolkit:v1.10.0-ubuntu20.04`` (also as ``nvcr.io/nvidia/k8s/container-toolkit:v1.10.0``)

The following packages have also been updated to depend on ``nvidia-container-toolkit`` of at least ``1.10.0``:

* ``nvidia-container-runtime 3.10.0``
* ``nvidia-docker2 2.11.0``

Packaging Changes
------------------

* The package repository includes support for Ubuntu 22.04. This redirects to the Ubuntu 18.04 packages.
* The package repository includes support for RHEL 9.0. This redirects to the Centos 8 packages.
* The package repository includes support for OpenSUSE 15.2 and 15.3. These redirect to the OpenSUSE 15.1 packages.
* The ``nvidia-docker2`` Debian packages were updated to allow installation with ``moby-engine`` instead of requiring ``docker-ce``, ``docker-ee``, or ``docker.io``.

Fixes and Features
-------------------

* Add ``nvidia-ctk`` CLI to provide utilities for interacting with the NVIDIA Container Toolkit
* Add a new mode to the NVIDIA Container Runtime targeted at Tegra-based systems using CSV-file based mount specifications.
* Use default config instead of raising an error if config file cannot be found
* Switch to debug logging to reduce log verbosity
* Support logging to logs requested in command line
* Allow low-level runtime path to be set explicitly as ``nvidia-container-runtime.runtimes`` option
* Fix failure to locate low-level runtime if PATH envvar is unset
* Add ``--version`` flag to all CLIs

specific to libnvidia-container
``````````````````````````````````
* Bump ``libtirpc`` to ``1.3.2``
* Fix bug when running host ldconfig using glibc compiled with a non-standard prefix
* Add ``libcudadebugger.so`` to list of compute libraries
* [WSL2] Fix segmentation fault on WSL2s system with no adpaters present (e.g. ``/dev/dxg`` missing)
* Ignore pending MIG mode when checking if a device is MIG enabled
* [WSL2] Fix bug where ``/dev/dxg`` is not mounted when ``NVIDIA_DRIVER_CAPABILITIES`` does not include "compute"

specific to container-toolkit container images
````````````````````````````````````````````````

* Fix a bug in applying runtime configuratin to containerd when version 1 config files are used
* Update base images to CUDA 11.7.0
* Multi-arch images for Ubuntu 18.04 are no longer available. (For multi-arch support for the container toolkit images at least Ubuntu 20.04 is required)
* Centos 8 images are no longer available since the OS is considered EOL and no CUDA base image updates are available
* Images are no longer published to Docker Hub and the NGC images should be used instead


Known Issues
-------------

* The ``container-toolkit:v1.10.0`` images have been released with the following known HIGH Vulnerability CVEs. These are from the base images and are not in libraries used by the components included in the container image as part of the NVIDIA Container Toolkit:

  * ``nvcr.io/nvidia/k8s/container-toolkit:v1.10.0-centos7``:

    * ``xz`` - `CVE-2022-1271 <https://access.redhat.com/security/cve/CVE-2022-1271>`_
    * ``xz-libs`` - `CVE-2022-1271 <https://access.redhat.com/security/cve/CVE-2022-1271>`_

  * ``nvcr.io/nvidia/k8s/container-toolkit:v1.10.0-ubi8``:

    * ``xz-libs`` - `CVE-2022-1271 <https://access.redhat.com/security/cve/CVE-2022-1271>`_


NVIDIA Container Toolkit 1.9.0
====================================

This release of the NVIDIA Container Toolkit ``v1.9.0`` is primarily targeted at adding multi-arch support for the ``container-toolkit`` images.
It also includes enhancements for use on Tegra-systems and some notable bugfixes.

The following packages are included:

* ``nvidia-container-toolkit 1.9.0``
* ``libnvidia-container-tools 1.9.0``
* ``libnvidia-container1 1.9.0``

The following ``container-toolkit`` containers are included (note these are also available on Docker Hub as ``nvidia/container-toolkit``):

* ``nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-centos7``
* ``nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-centos8``
* ``nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-ubi8``
* ``nvcr.io/nvidia/k8s/container-toolkit:v1.9.0`` and ``nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-ubuntu18.04``

The following packages have also been updated to depend on ``nvidia-container-toolkit`` of at least ``1.9.0``:

* ``nvidia-container-runtime 3.9.0``
* ``nvidia-docker2 2.10.0``

Fixes and Features
-------------------

specific to libnvidia-container
``````````````````````````````````

* Add additional check for Tegra in ``/sys/.../family`` file in CLI
* Update jetpack-specific CLI option to only load Base CSV files by default
* Fix bug (from ``v1.8.0``) when mounting GSP firmware into containers without ``/lib`` to ``/usr/lib`` symlinks
* Update ``nvml.h`` to CUDA 11.6.1 nvML_DEV 11.6.55
* Update switch statement to include new brands from latest ``nvml.h``
* Process all ``--require`` flags on Jetson platforms
* Fix long-standing issue with running ldconfig on Debian systems

specific to container-toolkit container images
````````````````````````````````````````````````

* Publish an ``nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-ubuntu20.04`` image based on ``nvidia/cuda:11.6.0-base-ubuntu20.04``
* The following images are available as multi-arch images including support for ``linux/amd64`` and ``linux/arm64`` platforms:

  * ``nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-centos8``
  * ``nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-ubi8``
  * ``nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-ubuntu18.04`` (and ``nvcr.io/nvidia/k8s/container-toolkit:v1.9.0``)
  * ``nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-ubuntu20.04``

Known Issues
-------------

* The ``container-toolkit:v1.9.0`` images have been released with the following known HIGH Vulnerability CVEs. These are from the base images and are not in libraries used by the components included in the container image as part of the NVIDIA Container Toolkit:

  * ``nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-centos7``:

    * ``expat`` - `CVE-2022-25235 <https://access.redhat.com/security/cve/CVE-2022-25235>`_
    * ``expat`` - `CVE-2022-25236 <https://access.redhat.com/security/cve/CVE-2022-25236>`_
    * ``expat`` - `CVE-2022-25315 <https://access.redhat.com/security/cve/CVE-2022-25315>`_

  * ``nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-centos8``:

    * ``cyrus-sasl-lib`` - `CVE-2022-24407 <https://access.redhat.com/security/cve/CVE-2022-24407>`_
    * ``openssl``, ``openssl-libs`` - `CVE-2022-0778 <https://access.redhat.com/security/cve/CVE-2022-0778>`_
    * ``expat`` - `CVE-2022-25235 <https://access.redhat.com/security/cve/CVE-2022-25235>`_
    * ``expat`` - `CVE-2022-25236 <https://access.redhat.com/security/cve/CVE-2022-25236>`_
    * ``expat`` - `CVE-2022-25315 <https://access.redhat.com/security/cve/CVE-2022-25315>`_

  * ``nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-ubi8``:

    * ``openssl-libs`` - `CVE-2022-0778 <https://access.redhat.com/security/cve/CVE-2022-0778>`_


NVIDIA Container Toolkit 1.8.1
====================================

This version of the NVIDIA Container Toolkit is a bugfix release and fixes issue with ``cgroup`` support found in
NVIDIA Container Toolkit ``1.8.0``.

The following packages are included:

* ``nvidia-container-toolkit 1.8.1``
* ``libnvidia-container-tools 1.8.1``
* ``libnvidia-container1 1.8.1``

The following ``container-toolkit`` containers have are included (note these are also available on Docker Hub as ``nvidia/container-toolkit``):

* ``nvcr.io/nvidia/k8s/container-toolkit:v1.8.1-centos7``
* ``nvcr.io/nvidia/k8s/container-toolkit:v1.8.1-centos8``
* ``nvcr.io/nvidia/k8s/container-toolkit:v1.8.1-ubi8``
* ``nvcr.io/nvidia/k8s/container-toolkit:v1.8.1`` and ``nvcr.io/nvidia/k8s/container-toolkit:v1.8.1-ubuntu18.04``

The following packages have also been updated to depend on ``nvidia-container-toolkit`` of at least ``1.8.1``:

* ``nvidia-container-runtime 3.8.1``
* ``nvidia-docker2 2.9.1``

Fixes and Features
-------------------

specific to libnvidia-container
``````````````````````````````````

* Fix bug in determining cgroup root when running in nested containers
* Fix permission issue when determining cgroup version under certain conditions


NVIDIA Container Toolkit 1.8.0
====================================

This version of the NVIDIA Container Toolkit adds ``cgroupv2`` support and removes packaging support for Amazon Linux 1.

The following packages are included:

* ``nvidia-container-toolkit 1.8.0``
* ``libnvidia-container-tools 1.8.0``
* ``libnvidia-container1 1.8.0``

The following ``container-toolkit`` containers have are included (note these are also available on Docker Hub as ``nvidia/container-toolkit``):

* ``nvcr.io/nvidia/k8s/container-toolkit:v1.8.0-centos7``
* ``nvcr.io/nvidia/k8s/container-toolkit:v1.8.0-centos8``
* ``nvcr.io/nvidia/k8s/container-toolkit:v1.8.0-ubi8``
* ``nvcr.io/nvidia/k8s/container-toolkit:v1.8.0`` and ``nvcr.io/nvidia/k8s/container-toolkit:v1.8.0-ubuntu18.04``

The following packages have also been updated to depend on ``nvidia-container-toolkit`` of at least ``1.8.0``:

* ``nvidia-container-runtime 3.8.0``
* ``nvidia-docker2 2.9.0``

Packaging Changes
------------------

* Packages for Amazon Linux 1 are no longer built or published
* The ``container-toolkit`` container is built and released from the same repository as the NVIDIA Container Toolkit packages.

Fixes and Features
-------------------

specific to libnvidia-container
``````````````````````````````````

* Add `cgroupv2` support
* Fix a bug where the GSP firmware path was mounted with write permissions instead of read-only
* Include the GSP firmware path (if present) in the output of the `nvidia-container-cli list` command
* Add support for injecting PKS libraries into a container


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

* Filter command line options based on ``libnvidia-container`` library version
* Include ``libnvidia-container`` version in CLI version output
* Allow for ``nvidia-container-cli`` to load ``libnvidia-container.so.0`` dynamically on Jetson platforms


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
