.. Date: May 12 2022
.. Author: elezar

.. _toolkit-troubleshooting-1.10.0:

*****************************************
Troubleshooting
*****************************************
This document describes common issues and known workarounds or solutions

.. _conflicting_signed_by-1.10.0

Conflicting values set for option Signed-By error when running ``apt update``
====================================

When following the installation instructions on Ubuntu or Debian-based systems and updating the package repository, the following error could be triggered:

.. code-block:: console

    $ sudo apt-get update
    E: Conflicting values set for option Signed-By regarding source https://nvidia.github.io/libnvidia-container/stable/ubuntu18.04/amd64/ /: /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg !=
    E: The list of sources could not be read.

This is caused by the combination of two things:

#. A recent update to the installation instructions to create a repo list file ``/etc/apt/sources.list.d/nvidia-container-toolkit.list``
#. The deprecation of ``apt-key`` meaning that the ``signed-by`` directive is included in the repo list file

If this error is triggered it means that another reference to the same repository exists that does not specify the ``signed-by`` directive.
The most likely candidates would be one or more of the files ``libnvidia-container.list``, ``nvidia-docker.list``, or ``nvidia-container-runtime.list`` in the
folder ``/etc/apt/sources.list.d/``.

The conflicting repository references can be obtained by running and inspecting the output:

.. code-block:: console

    $ grep "nvidia.github.io" /etc/apt/sources.list.d/*

The list of files with (possibly)  conflicting references can be optained by running:

.. code-block:: console

    $ grep -l "nvidia.github.io" /etc/apt/sources.list.d/* | grep -vE "/nvidia-container-toolkit.list\$"

Deleting the listed files should resolve the original error.


Permission denied error when running the ``nvidia-docker`` wrapper under SELinux
====================================

When running the ``nvidia-docker`` wrapper (provided by the ``nvidia-docker2`` package) on SELinux environments
one may see the following error

.. code-block:: console

    $ sudo nvidia-docker run --gpus=all --rm nvcr.io/nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi
    /bin/nvidia-docker: line 34: /bin/docker: Permission denied
    /bin/nvidia-docker: line 34: /bin/docker: Success

With SELinux reporting the following error:

.. code-block:: console

    SELinux is preventing /usr/bin/bash from entrypoint access on the file /usr/bin/docker. For complete SELinux messages run: sealert -l 43932883-bf2e-4e4e-800a-80584c62c218
    SELinux is preventing /usr/bin/bash from entrypoint access on the file /usr/bin/docker.

    *****  Plugin catchall (100. confidence) suggests   **************************

    If you believe that bash should be allowed entrypoint access on the docker file by default.
    Then you should report this as a bug.
    You can generate a local policy module to allow this access.
    Do
    allow this access for now by executing:
    # ausearch -c 'nvidia-docker' --raw | audit2allow -M my-nvidiadocker
    # semodule -X 300 -i my-nvidiadocker.pp

This occurs because ``nvidia-docker`` forwards the command line arguments with minor modifications to the ``docker`` executable.

To address this it is recommeded that the ``docker`` command be used directly specifying the ``nvidia`` runtime:

.. code-block:: console

    $ sudo docker run --gpus=all --runtime=nvidia --rm nvcr.io/nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi

Alternatively a local SELinux policy can be generated as suggested:

.. code-block:: console

    $ ausearch -c 'nvidia-docker' --raw | audit2allow -M my-nvidiadocker
    $ semodule -X 300 -i my-nvidiadocker.pp
