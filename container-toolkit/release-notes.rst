.. Date: September 21 2021
.. Author: elezar

.. _toolkit-release-notes:

*****************************************
Release Notes
*****************************************
This document describes the new features, improvements, fixed and known issues for the NVIDIA Container Toolkit.

----

NVIDIA Container Toolkit 1.6.0
==============================

Changes
------------

* Move OCI and command line checks for the NVIDIA Container Runtime to an internal go package (``oci``)
* Update OCI runtime specification dependency to `opencontainers/runtime-spec@a3c33d6 <https://github.com/opencontainers/runtime-spec/commit/a3c33d663ebc/>`_ to fix compatibility with docker when overriding clone3 syscall return value [fixes `NVIDIA/nvidia-container-runtime#157 <https://github.com/NVIDIA/nvidia-container-runtime/issues/157>`_]
* Use relative path to OCI specification file (``config.json``) if bundle path is not specified as an argument to the nvidia-container-runtime
* Added packages for Amazon Linux 2 on AARC64
* Include the ``nvidia-container-runtime`` executable in the ``nvidia-container-toolkit`` package

Changes from libnvidia-container
``````````````````````````````````
* Bump ``nvidia-modprobe`` dependency to ``495.44`` in the NVIDIA Container Library
* Fix bug that lead to unexpected mount error when ``/proc/driver/nvidia`` does not exist on the host


This version of the NVIDIA Container Toolkit moves to unify the packaging of the components of the NVIDIA container stack.
The following packages are included:

* ``nvidia-container-toolkit 1.6.0``
* ``libnvidia-container-tools 1.6.0``
* ``libnvidia-container1 1.6.0``

The following packages have also been updated to depend on ``nvidia-container-toolkit`` of at least ``1.6.0``:

* ``nvidia-container-runtime 3.6.0``
* ``nvidia-docker2 2.7.0``

.. note::

    As of version ``2.7.0`` the ``nvidia-docker2`` package depends directly on ``nvidia-container-toolkit``.
    This means that the ``nvidia-container-runtime`` package is no longer required and may be uninstalled as part of the upgrade process.

.. note::

    All the above packages are published to the `libnvidia-container <https://nvidia.github.io/libnvidia-container/>`_ experimental repository.


Toolkit Container 1.7.0
=======================

Known issues
------------

* The ``container-toolkit:1.7.0-ubuntu18.04`` image contains the `CVE-2021-3711 <http://people.ubuntu.com/~ubuntu-security/cve/CVE-2021-3711>`_. This CVE affects ``libssl1.1`` and ``openssl`` included in the ubuntu-based CUDA `11.4.1` base image. The components of the NVIDIA Container Toolkit included in the container do not use ``libssl1.1`` or ``openssl`` and as such this is considered low risk if the container is used as intended; that is to install and configure the NVIDIA Container Toolkit in the context of the NVIDIA GPU Operator.
