Installing on RHEL 7
--------------------
The following steps can be used to setup the NVIDIA Container Toolkit on RHEL 7.

Setting up Docker on RHEL 7
+++++++++++++++++++++++++++++

RHEL includes Docker in the ``Extras`` repository. To install Docker on RHEL 7, first enable this repository:

.. code:: bash

   sudo subscription-manager repos --enable rhel-7-server-extras-rpms

Docker can then be installed using ``yum``

.. code::bash

   sudo yum install docker -y   

.. seealso:: 

   More information is available in the KB `article <https://access.redhat.com/solutions/3727511>`_. 

Ensure the Docker service is running with the following command:

.. code-block:: bash

   sudo systemctl start docker && sudo systemctl enable docker


And finally, test your Docker installation by running the ``hello-world`` container:

.. code-block:: bash

   sudo docker -v
   Docker version 1.13.1, build 64e9980/1.13.1

   sudo docker run --rm hello-world
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

Setup the ``stable`` repository and the GPG key:

.. code-block:: bash

   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.repo | sudo tee /etc/yum.repos.d/nvidia-docker.repo


On RHEL 7, install the ``nvidia-container-toolkit`` package (and dependencies) after updating the package listing:

.. code-block:: bash

   sudo yum clean expire-cache

   sudo yum install nvidia-container-toolkit -y

.. note::

   On POWER (``ppc64le``) platforms, the following package should be used: ``nvidia-container-hook`` instead of ``nvidia-container-toolkit``

Restart the Docker daemon to complete the installation after setting the default runtime:

.. code-block:: bash

   sudo systemctl restart docker

At this point, a working setup can be tested by running a base CUDA container:

.. code-block:: bash

   sudo docker run --rm -e NVIDIA_VISIBLE_DEVICES=all nvidia/cuda:11.0-base nvidia-smi
   
   +-----------------------------------------------------------------------------+
   | NVIDIA-SMI 450.51.06    Driver Version: 450.51.06    CUDA Version: 11.0     |
   |-------------------------------+----------------------+----------------------+
   | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
   | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
   |                               |                      |               MIG M. |
   |===============================+======================+======================|
   |   0  Tesla T4            Off  | 00000000:00:1E.0 Off |                    0 |
   | N/A   43C    P0    20W /  70W |      0MiB / 15109MiB |      0%      Default |
   |                               |                      |                  N/A |
   +-------------------------------+----------------------+----------------------+

   +-----------------------------------------------------------------------------+
   | Processes:                                                                  |
   |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
   |        ID   ID                                                   Usage      |
   |=============================================================================|
   |  No running processes found                                                 |
   +-----------------------------------------------------------------------------+

.. note::
   
   Depending on how your RHEL 7 system is configured with SELinux, you may have to use ``--security-opt=label=disable`` on 
   the Docker command line to share parts of the host OS that can not be relabeled. Without this option, you may observe this 
   error when running GPU containers: ``Failed to initialize NVML: Insufficient Permissions``. However, using this option disables 
   SELinux separation in the container and the container is executed in an unconfined type. Review the SELinux policies 
   on your system.