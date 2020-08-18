Installing on CentOS 8 
+++++++++++++++++++++++
The following steps can be used to setup the NVIDIA Container Toolkit on CentOS 8.

Setting up Docker on CentOS 8
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Setup the official Docker CE repository:

.. code-block:: bash

   sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
   sudo dnf repolist -v

Since CentOS 8 does not support specific versions of ``containerd.io`` packages that are required for newer versions 
of Docker-CE, one option is to manually install the ``containerd.io`` package and then proceed to install the ``docker-ce`` 
packages.

Install the ``containerd.io`` package:

.. code-block:: bash
   
   sudo dnf install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm

And now install the latest ``docker-ce`` package:

.. code-block:: bash

   sudo dnf install docker-ce -y

Ensure the Docker service is running with the following command:

.. code-block:: bash

   sudo systemctl start docker && sudo systemctl enable docker

And finally, test your Docker installation by running the ``hello-world`` container:

.. code-block:: bash

   sudo docker run --rm hello-world
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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Setup the ``stable`` repository and the GPG key:

.. code-block:: bash

   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-docker.repo


Install the NVIDIA Container Toolkit packages (and their dependencies) after updating the package listing:

.. code-block:: bash

   sudo dnf repolist -v
   sudo dnf clean expire-cache --refresh

   sudo dnf install -y nvidia-docker2

Restart the Docker daemon to complete the installation after setting the default runtime:

.. code-block:: bash

   sudo systemctl restart docker

At this point, a working setup can be tested by running a base CUDA container:

.. code-block:: bash

   sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

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
