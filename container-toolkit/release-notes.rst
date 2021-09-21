.. Date: September 21 2021
.. Author: elezar

.. _toolkit-release-notes:

*****************************************
Release Notes
*****************************************
This document describes the new features, improvements, fixed and known issues for the NVIDIA Container Toolkit.

----

Toolkit Container 1.7.0
=======================

Known issues
------------

* The ``container-toolkit:1.7.0-ubuntu18.04`` image contains the `CVE-2021-3711 <http://people.ubuntu.com/~ubuntu-security/cve/CVE-2021-3711>`_. This CVE affects ``libssl1.1`` and ``openssl`` included in the ubuntu-based CUDA `11.4.1` base image. The components of the NVIDIA Container Toolkit included in the container do not use ``libssl1.1`` or ``openssl`` and as such this is considered low risk if the container is used as intended; that is to install and configure the NVIDIA Container Toolkit in the context of the NVIDIA GPU Operator.
