.. Date: December 18 2020
.. Author: pramarao

Getting Started
=======================

For installing containerd, follow the official `instructions <https://containerd.io/docs/getting-started/>`_ for your supported Linux distribution.
For convenience, the documentation below includes instructions on installing containerd for various Linux distributions supported by NVIDIA.

Step 0: Pre-Requisites
-------------------------

To install ``containerd`` as the container engine on the system, install some pre-requisite modules:

.. code-block:: console

    $ sudo modprobe overlay \
        && sudo modprobe br_netfilter

You can also ensure these are persistent:

.. code-block:: console

    $ cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
    overlay
    br_netfilter
    EOF

.. note::

    If you're going to use ``containerd`` as a CRI runtime with Kubernetes, configure the ``sysctl`` parameters:

    .. code-block:: console

        $ cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
        net.bridge.bridge-nf-call-iptables  = 1
        net.ipv4.ip_forward                 = 1
        net.bridge.bridge-nf-call-ip6tables = 1
        EOF

    And then apply the params:

    .. code-block:: console

        $ sudo sysctl --system

Step 1: Install containerd
-------------------------------

After the pre-requisities, we can proceed with installing *containerd* for your Linux distribution.

Setup the Docker repository:

.. tabs::

    .. tab:: Ubuntu LTS

        #. Install packages to allow ``apt`` to use a repository over HTTPS:

            .. code-block:: console

                $ sudo apt-get install -y \
                    apt-transport-https \
                    ca-certificates \
                    curl \
                    gnupg-agent \
                    software-properties-common

        #. Add the repository GPG key and the repo:

            .. code-block:: console

                $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

            .. code-block:: console

                $ sudo add-apt-repository \
                    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
                    $(lsb_release -cs) \
                    stable"

Now, install the ``containerd`` package:

.. tabs::

    .. tab:: Ubuntu LTS

        .. code-block:: console

            $ sudo apt-get update \
                && sudo apt-get install -y containerd.io

Configure ``containerd`` with a default ``config.toml`` configuration file:

.. code-block:: console

    $ sudo mkdir -p /etc/containerd \
        && sudo containerd config default | sudo tee /etc/containerd/config.toml

For using the NVIDIA runtime, additional configuration is required. The following options should be added to configure
``nvidia`` as a runtime and use ``systemd`` as the cgroup driver. A patch is provided below:

.. code-block:: console

    $ cat <<EOF > containerd-config.patch
    --- config.toml.orig    2020-12-18 18:21:41.884984894 +0000
    +++ /etc/containerd/config.toml 2020-12-18 18:23:38.137796223 +0000
    @@ -94,6 +94,15 @@
            privileged_without_host_devices = false
            base_runtime_spec = ""
            [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    +            SystemdCgroup = true
    +       [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
    +          privileged_without_host_devices = false
    +          runtime_engine = ""
    +          runtime_root = ""
    +          runtime_type = "io.containerd.runc.v1"
    +          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
    +            BinaryName = "/usr/bin/nvidia-container-runtime"
    +            SystemdCgroup = true
        [plugins."io.containerd.grpc.v1.cri".cni]
        bin_dir = "/opt/cni/bin"
        conf_dir = "/etc/cni/net.d"
    EOF

After apply the configuration patch, restart ``containerd``:

.. code-block:: console

    $ sudo systemctl restart containerd

You can test the installation by using the Docker ``hello-world`` container with the ``ctr`` tool:

.. code-block:: console

    $ sudo ctr image pull docker.io/library/hello-world:latest \
        && sudo ctr run --rm -t docker.io/library/hello-world:latest hello-world

.. code-block:: console

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


Step 2: Install NVIDIA Container Toolkit
-------------------------------------------

After installing containerd, we can proceed to install the NVIDIA Container Toolkit. For ``containerd``, we need to use
the ``nvidia-container-runtime`` package. See the :ref:`architecture overview <arch-overview-1.8.1>`
for more details on the package hierarchy.

First, setup the package repository and GPG key:

.. tabs::

    .. tab:: Ubuntu LTS

        .. code-block:: console

            $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
                && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
                && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

Now, install the NVIDIA runtime:

.. tabs::

    .. tab:: Ubuntu LTS

        .. code-block:: console

            $ sudo apt-get update \
                && sudo apt-get install -y nvidia-container-runtime

Then, we can test a GPU container:

.. code-block:: console

    $ sudo ctr image pull docker.io/nvidia/cuda:11.0-base

.. code-block:: console

    $ sudo ctr run --rm --gpus 0 -t docker.io/nvidia/cuda:11.0-base cuda-11.0-base nvidia-smi

You should see an output similar to the one shown below:

.. code-block:: console

    +-----------------------------------------------------------------------------+
    | NVIDIA-SMI 450.80.02    Driver Version: 450.80.02    CUDA Version: 11.0     |
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
