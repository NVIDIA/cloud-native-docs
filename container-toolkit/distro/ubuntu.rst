Installing on Ubuntu and Debian
-------------------------------
The following steps can be used to setup NVIDIA Container Toolkit on Ubuntu LTS (18.04, 20.04, and 22.04) and Debian (Stretch, Buster) distributions.

Setting up Docker
+++++++++++++++++
Docker-CE on Ubuntu can be setup using Docker's official convenience script:

.. code-block:: console

   $ curl https://get.docker.com | sh \
     && sudo systemctl --now enable docker

.. seealso::

   Follow the official `instructions <https://docs.docker.com/engine/install/ubuntu/>`_ for more details and `post-install actions <https://docs.docker.com/engine/install/linux-postinstall/>`_.

Setting up NVIDIA Container Toolkit
+++++++++++++++++++++++++++++++++++

..  include:: install/repo-apt.rst

Install the ``nvidia-docker2`` package (and dependencies) after updating the package listing:

.. code-block:: console

   $ sudo apt-get update

.. code-block:: console

   $ sudo apt-get install -y nvidia-docker2

Restart the Docker daemon to complete the installation after setting the default runtime:

.. code-block:: console

   $ sudo systemctl restart docker

At this point, a working setup can be tested by running a base CUDA container:

.. code-block:: console

   $ sudo docker run --rm --gpus all nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi

This should result in a console output shown below:

.. code-block:: console

   +-----------------------------------------------------------------------------+
   | NVIDIA-SMI 450.51.06    Driver Version: 450.51.06    CUDA Version: 11.0     |
   |-------------------------------+----------------------+----------------------+
   | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
   | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
   |                               |                      |               MIG M. |
   |===============================+======================+======================|
   |   0  Tesla T4            On   | 00000000:00:1E.0 Off |                    0 |
   | N/A   34C    P8     9W /  70W |      0MiB / 15109MiB |      0%      Default |
   |                               |                      |                  N/A |
   +-------------------------------+----------------------+----------------------+

   +-----------------------------------------------------------------------------+
   | Processes:                                                                  |
   |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
   |        ID   ID                                                   Usage      |
   |=============================================================================|
   |  No running processes found                                                 |
   +-----------------------------------------------------------------------------+
