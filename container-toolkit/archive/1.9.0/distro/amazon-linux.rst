Installing on Amazon Linux
----------------------------
The following steps can be used to setup the NVIDIA Container Toolkit on Amazon Linux 1 and Amazon Linux 2.

Setting up Docker on Amazon Linux
++++++++++++++++++++++++++++++++++
Amazon Linux is available on Amazon EC2 instances. For full install instructions, see `Docker basics for Amazon ECS <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html#install_docker>`_.

After launching the official Amazon Linux EC2 image, update the installed packages and install the most recent Docker CE packages:

.. code-block:: console

   $ sudo yum update -y

Install the ``docker`` package:

.. code-block:: console

   $ sudo amazon-linux-extras install docker

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

Install the ``nvidia-docker2`` package (and dependencies) after updating the package listing:

.. code-block:: console

   $ sudo yum clean expire-cache

.. code-block::bash

   $ sudo yum install nvidia-docker2 -y

Restart the Docker daemon to complete the installation after setting the default runtime:

.. code-block:: console

   $ sudo systemctl restart docker

At this point, a working setup can be tested by running a base CUDA container:

.. code-block:: console

   $ sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

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
