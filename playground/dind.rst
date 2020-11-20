.. Date: November 13 2020
.. Author: pramarao

.. _dind:

##################
Docker-in-Docker
##################

You can also run GPU containers with Docker-in-Docker (dind). Just mount in the Docker socket to the container and then 
specify the CUDA container that you want to run: 

.. code-block:: console

   $ sudo docker run -v /var/run/docker.sock:/var/run/docker.sock \
       docker run --rm --gpus all \
       nvidia/cuda:11.0-base \
       nvidia-smi

With the resulting output:

.. code-block:: console

   +-----------------------------------------------------------------------------+
   | NVIDIA-SMI 455.45.01    Driver Version: 455.45.01    CUDA Version: 11.1     |
   |-------------------------------+----------------------+----------------------+
   | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
   | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
   |                               |                      |               MIG M. |
   |===============================+======================+======================|
   |   0  Tesla T4            On   | 00000000:00:1E.0 Off |                    0 |
   | N/A   31C    P8     9W /  70W |      0MiB / 15109MiB |      0%      Default |
   |                               |                      |                  N/A |
   +-------------------------------+----------------------+----------------------+

   +-----------------------------------------------------------------------------+
   | Processes:                                                                  |
   |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
   |        ID   ID                                                   Usage      |
   |=============================================================================|
   |  No running processes found                                                 |
   +-----------------------------------------------------------------------------+

Or launch an interactive session within an interactive session, Inception style! 

.. code-block:: console

   $ sudo docker run -ti -v /var/run/docker.sock:/var/run/docker.sock docker

.. code-block:: console

   / # docker run -it --gpus all nvidia/cuda:11.1-base
   Unable to find image 'nvidia/cuda:11.1-base' locally
   11.1-base: Pulling from nvidia/cuda
   6a5697faee43: Pull complete
   ba13d3bc422b: Pull complete
   a254829d9e55: Pull complete
   f853e5702a31: Pull complete
   29cfce72a460: Pull complete
   4bb689f629d3: Pull complete
   Digest: sha256:6007208f8a1f626c0175260ebd46b1cbde10aab67e6d810fa593357b8199bfbe
   Status: Downloaded newer image for nvidia/cuda:11.1-base
   root@f29740c58731:/# nvidia-smi

   +-----------------------------------------------------------------------------+
   | NVIDIA-SMI 455.45.01    Driver Version: 455.45.01    CUDA Version: 11.1     |
   |-------------------------------+----------------------+----------------------+
   | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
   | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
   |                               |                      |               MIG M. |
   |===============================+======================+======================|
   |   0  Tesla T4            On   | 00000000:00:1E.0 Off |                    0 |
   | N/A   31C    P8     9W /  70W |      0MiB / 15109MiB |      0%      Default |
   |                               |                      |                  N/A |
   +-------------------------------+----------------------+----------------------+

   +-----------------------------------------------------------------------------+
   | Processes:                                                                  |
   |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
   |        ID   ID                                                   Usage      |
   |=============================================================================|
   |  No running processes found                                                 |
   +-----------------------------------------------------------------------------+

What other cool stuff can you do? Send us details via GitHub `issues <https://github.com/NVIDIA/nvidia-docker/issues>`_! 

