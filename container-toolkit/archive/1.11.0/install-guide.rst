.. Date: August 10 2020
.. Author: pramarao

.. _install-guide-1.11.0:

#########################
Installation Guide
#########################

*********************
Supported Platforms
*********************

The NVIDIA Container Toolkit is available on a variety of Linux distributions and supports different container engines.

.. note::

    As of NVIDIA Container Toolkit ``1.7.0`` (``nvidia-docker2 >= 2.8.0``) support for Jetson plaforms
    is included for Ubuntu 18.04, Ubuntu 20.04, and Ubuntu 22.04 distributions. This means that the installation
    instructions provided for these distributions are expected to work on Jetson devices.


Linux Distributions
=======================

Supported Linux distributions are listed below:

+-------------------------+---------------+-----------------+---------+-----------------+
| OS Name / Version       | Identifier    | amd64 / x86_64  | ppc64le | arm64 / aarch64 |
+=========================+===============+=================+=========+=================+
| Amazon Linux 2          | amzn2         |       X         |         |        X        |
+-------------------------+---------------+-----------------+---------+-----------------+
| Amazon Linux 2017.09    | amzn2017.09   |       X         |         |                 |
+-------------------------+---------------+-----------------+---------+-----------------+
| Amazon Linux 2018.03    | amzn2018.03   |       X         |         |                 |
+-------------------------+---------------+-----------------+---------+-----------------+
| Open Suse/SLES 15.0     | sles15.0      |       X         |         |                 |
+-------------------------+---------------+-----------------+---------+-----------------+
| Open Suse/SLES 15.x (*) | sles15.x      |       X         |         |                 |
+-------------------------+---------------+-----------------+---------+-----------------+
| Debian Linux 9          | debian9       |       X         |         |                 |
+-------------------------+---------------+-----------------+---------+-----------------+
| Debian Linux 10         | debian10      |       X         |         |                 |
+-------------------------+---------------+-----------------+---------+-----------------+
| Debian Linux 11 (#)     | debian11      |       X         |         |                 |
+-------------------------+---------------+-----------------+---------+-----------------+
| Centos 7                | centos7       |       X         |    X    |                 |
+-------------------------+---------------+-----------------+---------+-----------------+
| Centos 8                | centos8       |       X         |    X    |        X        |
+-------------------------+---------------+-----------------+---------+-----------------+
| RHEL 7.x (&)            | rhel7.x       |       X         |    X    |                 |
+-------------------------+---------------+-----------------+---------+-----------------+
| RHEL 8.x (@)            | rhel8.x       |       X         |    X    |        X        |
+-------------------------+---------------+-----------------+---------+-----------------+
| RHEL 9.x (@)            | rhel9.x       |       X         |    X    |        X        |
+-------------------------+---------------+-----------------+---------+-----------------+
| Ubuntu 16.04            | ubuntu16.04   |       X         |    X    |                 |
+-------------------------+---------------+-----------------+---------+-----------------+
| Ubuntu 18.04            | ubuntu18.04   |       X         |    X    |        X        |
+-------------------------+---------------+-----------------+---------+-----------------+
| Ubuntu 20.04 (%)        | ubuntu20.04   |       X         |    X    |        X        |
+-------------------------+---------------+-----------------+---------+-----------------+
| Ubuntu 22.04 (%)        | ubuntu22.04   |       X         |    X    |        X        |
+-------------------------+---------------+-----------------+---------+-----------------+

(*) Minor releases of Open Suse/SLES 15.x are symlinked (redirected) to ``sles15.1``.
(#) Debian 11 packages are symlinked (redirected) to ``debian10``.
(&) RHEL 7 packages are symlinked (redirected) to ``centos7``
(&) RHEL 8 and RHEL 9 packages are symlinked (redirected) to ``centos8``
(%) Ubuntu 20.04 and Ubuntu 22.04 packages are symlinked (redirected) to ``ubuntu18.04``

Container Runtimes
====================

Supported container runtimes are listed below:

+----------------------+-----------------+---------+-----------------+
| OS Name / Version    | amd64 / x86_64  | ppc64le | arm64 / aarch64 |
+======================+=================+=========+=================+
| Docker 18.09         |       X         |    X    |        X        |
+----------------------+-----------------+---------+-----------------+
| Docker 19.03         |       X         |    X    |        X        |
+----------------------+-----------------+---------+-----------------+
| Docker 20.10         |       X         |    X    |        X        |
+----------------------+-----------------+---------+-----------------+
| RHEL/CentOS 8 podman |       X         |         |                 |
+----------------------+-----------------+---------+-----------------+
| CentOS 8 Docker      |       X         |         |                 |
+----------------------+-----------------+---------+-----------------+
| RHEL/CentOS 7 Docker |       X         |         |                 |
+----------------------+-----------------+---------+-----------------+

.. note::
    On Red Hat Enterprise Linux (RHEL) 8, Docker is no longer a supported container runtime. See
    `Building, Running and Managing Containers <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/building_running_and_managing_containers/index>`_
    for more information on the container tools available on the distribution.

********************
Pre-Requisites
********************

NVIDIA Drivers
================

Before you get started, make sure you have installed the NVIDIA driver for your Linux distribution. The
recommended way to install drivers is to use the package manager for your distribution but other installer
mechanisms are also available (e.g. by downloading ``.run`` installers from NVIDIA Driver `Downloads <https://www.nvidia.com/Download/index.aspx?lang=en-us>`_).

For instructions on using your package manager to install drivers from the official CUDA network repository, follow
the steps in this `guide <https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html>`_.

Platform Requirements
========================

The list of prerequisites for running NVIDIA Container Toolkit is described below:

#. GNU/Linux x86_64 with kernel version > 3.10
#. Docker >= 19.03 (recommended, but some distributions may include older versions of Docker. The minimum supported version is 1.12)
#. NVIDIA GPU with Architecture >= Kepler (or compute capability 3.0)
#. `NVIDIA Linux drivers <http://www.nvidia.com/object/unix.html>`_ >= 418.81.07 (Note that older driver releases or branches are unsupported.)

.. note::

    Your driver version might limit your CUDA capabilities. Newer NVIDIA drivers are backwards-compatible with CUDA Toolkit versions, but each
    new version of CUDA requires a minimum driver version. Running a CUDA container requires a machine with at least one CUDA-capable GPU and
    a driver compatible with the CUDA toolkit version you are using. The machine running the CUDA container only requires the NVIDIA driver,
    the CUDA toolkit doesn't have to be installed. The `CUDA release notes <https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html#cuda-major-component-versions>`_
    includes a table of the minimum driver and CUDA Toolkit versions.

----

********************
Docker
********************
.. Docker instructions

.. include:: nvidia-docker.rst

----

********************
containerd
********************
.. containerd instructions

.. include:: nvidia-containerd.rst

----

********************
podman
********************
.. podman instructions

.. include:: nvidia-podman.rst
