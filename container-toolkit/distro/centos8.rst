Installing on CentOS 7/8
--------------------------
The following steps can be used to setup the NVIDIA Container Toolkit on CentOS 7/8.

Setting up Docker on CentOS 7/8
++++++++++++++++++++++++++++++++

.. note::

   If you're on a cloud instance such as EC2, then the official `CentOS images <https://wiki.centos.org/Cloud/AWS>`_ may not include
   tools such as ``iptables`` which are required for a successful Docker installation. Try this command to get a more functional VM,
   before proceeding with the remaining steps outlined in this document.

   .. code-block:: console

      $ sudo dnf install -y tar bzip2 make automake gcc gcc-c++ vim pciutils elfutils-libelf-devel libglvnd-devel iptables

Setup the official Docker CE repository:

.. tabs::

   .. tab:: CentOS 8

      .. code-block:: console

         $ sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

   .. tab:: CentOS 7

      .. code-block:: console

         $ sudo yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

Now you can observe the packages available from the `docker-ce` repo:

.. tabs::

   .. tab:: CentOS 8

      .. code-block:: console

         $ sudo dnf repolist -v

   .. tab:: CentOS 7

      .. code-block:: console

         $ sudo yum repolist -v

Since CentOS does not support specific versions of ``containerd.io`` packages that are required for newer versions
of Docker-CE, one option is to manually install the ``containerd.io`` package and then proceed to install the ``docker-ce``
packages.

Install the ``containerd.io`` package:

.. tabs::

   .. tab:: CentOS 8

      .. code-block:: console

         $ sudo dnf install -y https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.4.3-3.1.el7.x86_64.rpm

   .. tab:: CentOS 7

      .. code-block:: console

         $ sudo yum install -y https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.4.3-3.1.el7.x86_64.rpm


And now install the latest ``docker-ce`` package:

.. tabs::

   .. tab:: CentOS 8

      .. code-block:: console

         $ sudo dnf install docker-ce -y

   .. tab:: CentOS 7

      .. code-block:: console

         $ sudo yum install docker-ce -y

Ensure the Docker service is running with the following command:

.. code-block:: console

   $ sudo systemctl --now enable docker

And finally, test your Docker installation by running the ``hello-world`` container:

.. code-block:: console

   $ sudo docker run --rm hello-world

This should result in a console output shown below:

.. code-block:: console

   Unable to find image 'hello-world:latest' locally
   latest: Pulling from library/hello-world
   0e03bdcc26d7: Pull complete
   Digest: sha256:7f0a9f93b4aa3022c3a4c147a449bf11e0941a1fd0bf4a8e6c9408b2600777c5
   Status: Downloaded newer image for hello-world:latest

   Hello from Docker!
   This message shows that your installation appears to be working correctly.

   To generate this message, Docker took the following steps:
   1. The Docker client contacted the Docker daemon.
   2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
      (amd64)
   3. The Docker daemon created a new container from that image which runs the
      executable that produces the output you are currently reading.
   4. The Docker daemon streamed that output to the Docker client, which sent it
      to your terminal.

   To try something more ambitious, you can run an Ubuntu container with:
   $ docker run -it ubuntu bash

   Share images, automate workflows, and more with a free Docker ID:
   https://hub.docker.com/

   For more examples and ideas, visit:
   https://docs.docker.com/get-started/


Setting up NVIDIA Container Toolkit
+++++++++++++++++++++++++++++++++++

.. include:: install/repo-yum.rst

Install the ``nvidia-container-toolkit`` package (and dependencies) after updating the package listing:

.. tabs::

   .. tab:: CentOS 8

      .. code-block:: console

         $ sudo dnf clean expire-cache --refresh

   .. tab:: CentOS 7

      .. code-block:: console

         $ sudo yum clean expire-cache

.. tabs::

   .. tab:: CentOS 8

      .. code-block:: console

         $ sudo dnf install -y nvidia-container-toolkit

   .. tab:: CentOS 7

      .. code-block:: console

         $ sudo yum install -y nvidia-container-toolkit

Configure the Docker daemon to recognize the NVIDIA Container Runtime:

.. code-block:: console

   $ sudo nvidia-ctk runtime configure --runtime=docker

Restart the Docker daemon to complete the installation after setting the default runtime:

.. code-block:: console

   $ sudo systemctl restart docker

At this point, a working setup can be tested by running a base CUDA container:

.. code-block:: console

   $ sudo docker run --rm --runtime=nvidia --gpus all nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi

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
