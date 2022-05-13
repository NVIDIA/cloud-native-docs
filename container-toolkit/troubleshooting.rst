.. Date: May 12 2022
.. Author: elezar

.. _toolkit-troubleshooting:

*****************************************
Troubleshooting
*****************************************
This document describes common issues and known workarounds or solutions

Permission denied error when running the ``nvidia-docker`` wrapper under SELinux
====================================

When running the ``nvidia-docker`` wrapper (provided by the ``nvidia-docker2`` package) on SELinux environments
one may see the following error

.. code-block:: console

    $ sudo nvidia-docker run --gpus=all --rm nvcr.io/nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
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

    $ sudo docker run --gpus=all --runtime=nvidia --rm nvcr.io/nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi

Alternatively a local SELinux policy can be generated as suggested:

.. code-block:: console

    $ ausearch -c 'nvidia-docker' --raw | audit2allow -M my-nvidiadocker
    $ semodule -X 300 -i my-nvidiadocker.pp
