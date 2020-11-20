.. Date: November 13 2020
.. Author: pramarao

.. _x-arch:

##########################################
Running Cross-Architecture Containers
##########################################

For many reasons, it is desirable to build and run containers for one CPU architecture (e.g. ``x86_64``) 
on another CPU architecture (e.g. ``Arm64``).

************************
Emulation Environment
************************

One solution would be to use an emulation environment using the `QEMU <https://www.qemu.org/>`_ emulator and Docker. 
Using **QEMU**, `binfmt_misc <https://en.wikipedia.org/wiki/Binfmt_misc>`_ and the registration scripts via the 
`multiarch/qemu-user-static <https://github.com/multiarch/qemu-user-static>`_ project, we can run containers built for 
either *Arm64* or *POWER* architectures on *x86_64* servers or workstations. 

Installing QEMU
-----------------

Install the *qemu*, *binfmt-support*, and *qemu-user-static* packages. The *binfmt-support* contains scripts to register binary 
formats with the kernel using the *binfmt_misc* module; and the *qemu-user-static* package registers binary formats that emulators can handle. 

.. code-block:: console

   $ sudo apt-get install -y qemu \
      && binfmt-support \
      && qemu-user-static

Run the ``multiarch/qemu-user-static`` container to register:

.. code-block:: console

   $ sudo docker run --rm --privileged \
      multiarch/qemu-user-static \
      --reset \
      -p yes

Now, verify that the *binfmt* entries were registered on the system:

.. code-block:: console

   $ update-binfmts --display

.. code-block:: console

   ...
   qemu-aarch64 (enabled):
     package = qemu-user-static
        type = magic
      offset = 0
       magic = \x7f\x45\x4c\x46\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00
        mask = \xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff
    interpreter = /usr/bin/qemu-aarch64-static
      detector =
   ...

Running Containers
--------------------

The community maintains a number of Docker containers on DockerHub under `arm64v8 <https://hub.docker.com/r/arm64v8>`_. 
Without an emulator, if you try running an ``arm64`` Alpine container on ``x86_64``, you will observe a format error from Docker.

This can be seen in the example below:

.. code-block:: console

   $ uname -m
   x86_64

.. code-block:: console

   $ sudo docker run --rm arm64v8/alpine uname -m

.. code-block:: console

   standard_init_linux.go:211: exec user process caused "exec format error"

After installing the QEMU emulator and registering: 

.. code-block:: console

   $ sudo docker run --rm arm64v8/alpine uname -m

.. code-block:: console

   aarch64



