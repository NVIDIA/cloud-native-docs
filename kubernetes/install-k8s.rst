.. Date: November 10 2020
.. Author: pramarao

.. _install-k8s:

####################
Install Kubernetes
####################

*************
Introduction
*************

Kubernetes is an open-source platform for automating deployment, scaling and managing containerized applications. Kubernetes includes support 
for GPUs and enhancements to Kubernetes so users can easily configure and use GPU resources for accelerating AI and HPC workloads.

There are many ways to install upstream Kubernetes with NVIDIA supported components, such as drivers, plugins and runtime. This document 
describes a few methods for getting started with Kubernetes. Click on the links below to map out the options that you would like to follow:

#. Option 1: Using `DeepOps <https://github.com/NVIDIA/deepops>`_ 
#. Option 2: Using `Kubeadm <https://kubernetes.io/docs/reference/setup-tools/kubeadm/>`_ to install Kubernetes

   * Option 2-a: Use the :ref:`NVIDIA GPU Operator<gpu-operator>` to automate/manage the deployment of the NVIDIA software components 
   * Option 2-b: Set up the NVIDIA software components as :ref:`pre-requisites<nvdp>` before running applications

.. blockdiag:: 

   blockdiag admin {
      A [label = "Install K8s with GPUs", color = "#00CC00"];
      B [label = "Use DeepOps"];
      C [label = "Use Kubeadm", color = pink];
      D [label = "Use GPU Operator"];
      E [label = "Set up \n NVIDIA components", color = "#FF9933"];

      A -> B;
      A -> C;
      C -> D;
      C -> E;
   }

**********************************************
Option 1: Installing Kubernetes Using DeepOps
**********************************************

Use DeepOps to automate deployment, especially for a cluster of many worker nodes. DeepOps is a modular collection 
of ansible scripts which automate the deployment of Kubernetes, Slurm, or a hybrid combination of the two across 
your nodes. It also installs the necessary GPU drivers, NVIDIA Container Toolkit for Docker (``nvidia-docker2``), 
and various other dependencies for GPU-accelerated work. Encapsulating best practices for NVIDIA GPUs, it can be 
customized or run as individual components, as needed.


Use the following procedure to install Kubernetes using DeepOps:

#. Pick a provisioning node to deploy from.
   This is where the DeepOps Ansible scripts run from and is often a development laptop that has a connection to the target cluster. On this provisioning node, 
   clone the DeepOps repository with the following command:

   .. code-block:: console

      $ git clone https://github.com/NVIDIA/deepops.git

#. Optionally, check out a recent release tag with the following command:

   .. code-block:: console

      $ cd deepops \
         && git checkout tags/20.10

   If you do not explicitly use a release tag, then the latest development code is used, and not an official release.

#. Follow the instructions in the `DeepOps Kubernetes Deployment Guide <https://github.com/NVIDIA/deepops/blob/master/docs/k8s-cluster>`_ to install Kubernetes.

***********************************************
Option 2: Installing Kubernetes Using Kubeadm
***********************************************

.. note::

   The method described in this section is an alternative to using DeepOps. If you have deployed using DeepOps, then skip this section.

For a less scripted approach, especially for smaller clusters or where there is a desire to learn the components that make up a Kubernetes cluster, use Kubeadm.

A Kubernetes cluster is composed of master nodes and worker nodes. The master nodes run the control plane components of Kubernetes which allows your 
cluster to function properly. These components include the API Server (front-end to the ``kubectl`` CLI), **etcd** (stores the cluster state) and others.

Use CPU-only (GPU-free) master nodes, which run the control plane components: Scheduler, API-server, and Controller Manager. Control plane components can 
have some impact on your CPU intensive tasks and conversely, CPU or HDD/SSD intensive components can have an impact on your control plane components.

With ``kubeadm``, this document will walk through the steps for installing a single node Kubernetes cluster (where we untaint the control plane 
so it can run GPU pods), but the cluster can be scaled easily with additional nodes.

Step 0: Before You Begin
============================

Before proceeding to install the components, check that all Kubernetes `prerequisites <https://kubernetes.io/docs/setup/independent/install-kubeadm/#before-you-begin>`_ 
have been satisfied. These prerequisites include:

* Check network adapters and required ports
* Disable swap on the nodes so that kubelet can work correctly
* Install a supported container runtime such as Docker, containerd or CRI-O

Depending on your Linux distribution, refer to the steps below:

* :ref:`Ubuntu LTS<ubuntu-k8s>`
* :ref:`CentOS<centos-k8s>`


.. _ubuntu-k8s:

Ubuntu LTS
============
This section provides steps for setting up K8s on Ubuntu 18.04 and 20.04 LTS distributions.

Step 1: Install a Container Engine
-------------------------------------

NVIDIA supports running GPU containers with Docker and other CRI compliant runtimes such as `containerd` or CRI-O.

.. tabs:: 

   .. tab:: Docker

      Follow the steps in this `guide <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#installing-on-ubuntu-and-debian>`_ 
      to install Docker.

   .. tab:: containerd

      First, install some pre-requisites for ``containerd``: 

      .. code-block:: console

         $ sudo apt-get update \
            && sudo apt-get install -y apt-transport-https \
               ca-certificates curl software-properties-common

      The ``overlay`` and ``br_netfilter`` modules are required to be loaded: 

      .. code-block:: console

         $ cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
         overlay
         br_netfilter
         EOF

      .. code-block:: console

         $ sudo modprobe overlay \
            && sudo modprobe br_netfilter

      Setup the required ``sysctl`` parameters and make them persistent:

      .. code-block:: console

         $ cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
         net.bridge.bridge-nf-call-iptables  = 1
         net.ipv4.ip_forward                 = 1
         net.bridge.bridge-nf-call-ip6tables = 1
         EOF

      .. code-block:: console

         $ sudo sysctl --system

      Now proceed to setup the Docker repository:

      .. code-block:: console

         $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -

      .. code-block:: console

         $ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable"

      Install ``containerd``:

      .. code-block:: console

         $ sudo apt-get update \
            && sudo apt-get install -y containerd.io

      Create a default ``config.toml``:

      .. code-block:: console

         $ sudo mkdir -p /etc/containerd \
            && sudo containerd config default | sudo tee /etc/containerd/config.toml

      Configure ``containerd`` to use the ``systemd`` cgroup driver with ``runc`` by editing the configuration file and adding this line:

      .. code-block:: console

         [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true

      Now restart the daemon:

      .. code-block:: console

         $ sudo systemctl restart containerd

Step 2: Install Kubernetes Components
--------------------------------------

First, install some dependencies:

.. code-block:: console

   $ sudo apt-get update \
      && sudo apt-get install -y apt-transport-https curl

Add the package repository keys:

.. code-block:: console

   $ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

And the repository: 

.. code-block:: console

   $ cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
   deb https://apt.kubernetes.io/ kubernetes-xenial main
   EOF

Update the package listing and install `kubelet`:

.. code-block:: console

   $ sudo apt-get update \
      && sudo apt-get install -y -q kubelet kubectl kubeadm

.. note::

   If you're using ``containerd`` as the CRI runtime, then follow these steps:

   #. Configure the cgroup driver for ``kubelet``:

      .. code-block:: console

         $ sudo mkdir -p  /etc/systemd/system/kubelet.service.d/

      .. code-block:: console

         $ sudo cat << EOF | sudo tee  /etc/systemd/system/kubelet.service.d/0-containerd.conf
         [Service]                                                 
         Environment="KUBELET_EXTRA_ARGS=--container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint=unix:///run/containerd/containerd.sock --cgroup-driver='systemd'"
         EOF

   #. Restart kubelet:

      .. code-block:: console

         $ sudo systemctl daemon-reload \
            && sudo systemctl restart kubelet

Disable swap

.. code-block:: console

   $ sudo swapoff -a

And ``init`` using ``kubeadm``:

.. code-block:: console

   $ sudo kubeadm init --pod-network-cidr=192.168.0.0/16

Finish the configuration setup with Kubeadm:

.. code-block:: console

   $ mkdir -p $HOME/.kube \
      && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config \
      && sudo chown $(id -u):$(id -g) $HOME/.kube/config

Step 3: Configure Networking
------------------------------

Now, setup networking with Calico:

.. code-block:: console

   $ kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

Untaint the control plane, so it can be used to schedule GPU pods in our simplistic single-node cluster:

.. code-block:: console

   $ kubectl taint nodes --all node-role.kubernetes.io/master-

Your cluster should now be ready to schedule containerized applications.

.. _centos-k8s:

CentOS 
==========

Follow the steps in this section for setting up K8s on CentOS 7/8.

.. note::

   If you're using CentOS 7/8 on a cloud IaaS platform such as EC2, then you may need to do some additional setup as listed here:

   #. Choose an official CentOS image for your EC2 region: `https://wiki.centos.org/Cloud/AWS <https://wiki.centos.org/Cloud/AWS>`_
   #. Install some of the prerequisites:

      .. tabs::

         .. tab:: CentOS 8

            .. code-block:: console

               $ sudo dnf install -y tar bzip2 make automake gcc gcc-c++ \
                  pciutils elfutils-libelf-devel libglvnd-devel \
                  iptables firewalld bind-utils \
                  vim wget
      
         .. tab:: CentOS 7

            .. code-block:: console

               $ sudo yum install -y tar bzip2 make automake gcc gcc-c++ \
                  pciutils elfutils-libelf-devel libglvnd-devel \
                  iptables firewalld bind-utils \
                  vim wget      

   #. Update the running kernel to ensure you're running the latest updates

      .. tabs:: 
      
         .. tab:: CentOS 8

            .. code-block:: console

               $ sudo dnf update -y

         .. tab:: CentOS 7
      
            .. code-block:: console

               $ sudo yum update -y

   #. Reboot your VM 

      .. code-block:: console

         $ sudo reboot

Step 0: Configuring the System
--------------------------------

Disable Nouveau
^^^^^^^^^^^^^^^^^

For a successful install of the NVIDIA driver, the Nouveau drivers must first be disabled. 

Determine if the ``nouveau`` driver is loaded:

.. code-block:: console

   $ lsmod | grep -i nouveau

Create a file at ``/etc/modprobe.d/blacklist-nouveau.conf`` with the following contents:

.. code-block:: console

   blacklist nouveau
   options nouveau modeset=0

Regenerate the kernel initramfs:

.. code-block:: console

   $ sudo dracut --force

Reboot the system before proceeding with the next step.

For the remaining part of this section, we will follow the general steps for using `kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/>`_.
Also, for convenience, let's enter into an interactive ``sudo`` session since most of the remaining commands require root privileges: 

.. code-block:: console

   $ sudo -i

Disable SELinux
^^^^^^^^^^^^^^^^^^^

.. code-block:: console

   $ setenforce 0 \
      && sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

Bridged traffic and iptables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As mentioned in the ``kubedadm`` documentation, ensure that the ``br_netfilter`` module is loaded: 

.. code-block:: console

   $ modprobe br_netfilter

Ensure ``net.bridge.bridge-nf-call-iptables`` is configured correctly:

.. code-block:: console

   $ cat <<EOF > /etc/sysctl.d/k8s.conf
   net.bridge.bridge-nf-call-ip6tables = 1
   net.bridge.bridge-nf-call-iptables = 1
   EOF

and restart the ``sysctl`` config:

.. code-block:: console

   $ sysctl --system

Firewall and required ports
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The network plugin requires certain ports to be open on the control plane and worker nodes. See this 
`table <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports>`_ for more information on 
the purpose of these port numbers.

Ensure that ``firewalld`` is running:

.. code-block:: console

   $ systemctl status firewalld

and if required, start ``firewalld``:

.. code-block:: console

   $ systemctl --now enable firewalld

Now open the ports:

.. code-block:: console

   $ firewall-cmd --permanent --add-port=6443/tcp \
      && firewall-cmd --permanent --add-port=2379-2380/tcp \
      && firewall-cmd --permanent --add-port=10250/tcp \
      && firewall-cmd --permanent --add-port=10251/tcp \
      && firewall-cmd --permanent --add-port=10252/tcp \
      && firewall-cmd --permanent --add-port=10255/tcp

Its also required to add the ``docker0`` interface to the public zone and allow for ``docker0`` ingress and egress:

.. tabs:: 

   .. tab:: CentOS 8

      .. code-block:: console

         $ nmcli connection modify docker0 connection.zone public \
            && firewall-cmd --zone=public --add-masquerade --permanent \
            && firewall-cmd --zone=public --add-port=443/tcp

   .. tab:: CentOS 7

      .. code-block:: console

         $ firewall-cmd --zone=public --add-masquerade --permanent \
            && firewall-cmd --zone=public --add-port=443/tcp


Reload the ``firewalld`` configuration and ``dockerd`` for the settings to take effect:

.. code-block:: console

   $ firewall-cmd --reload \
      && systemctl restart docker

Optionally, before we install the Kubernetes control plane, test your container networking using a simple ``ping`` command:

.. code-block:: console

   $ docker run busybox ping google.com

Disable swap
^^^^^^^^^^^^^^

For performance, disable swap on your system:

.. code-block:: console

   $ swapoff -a

Step 1: Install Docker
------------------------

Follow the steps in this `guide <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#setting-up-docker-on-centos-7-8>`_ to install Docker on CentOS 7/8.

Step 2: Install Kubernetes Components
---------------------------------------

Add the network repository listing to the package manager configuration:

.. code-block:: console

   $ cat <<EOF > /etc/yum.repos.d/kubernetes.repo
   [kubernetes]
   name=Kubernetes
   baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
   enabled=1
   gpgcheck=1
   repo_gpgcheck=1
   gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
   EOF

Install the components:

.. tabs:: 

   .. tab:: CentOS 8

      .. code-block:: console

         $ dnf install -y kubelet kubectl kubeadm

   .. tab:: CentOS 7

      .. code-block:: console

         $ yum install -y kubelet kubectl kubeadm

Ensure that ``kubelet`` is started across system reboots:

.. code-block:: console

   $ systemctl --now enable kubelet

Now use ``kubeadm`` to initialize the control plane:

.. code-block:: console

   $ kubeadm init --pod-network-cidr=192.168.0.0/16

At this point, feel free to exit from the interactive ``sudo`` session that we started with. 

Configure Directories
^^^^^^^^^^^^^^^^^^^^^^^

To start using the cluster, run the following as a regular user:

.. code-block:: console

   $ mkdir -p $HOME/.kube \
      && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config \
      && sudo chown $(id -u):$(id -g) $HOME/.kube/config

If you're using a simplistic cluster (or just testing), you can untaint the control plane node so that it can also run containers:

.. code-block:: console

   $ kubectl taint nodes --all node-role.kubernetes.io/master-

At this point, your cluster would look like below:

.. code-block:: console

   $ kubectl get pods -A

.. code-block:: console

   NAMESPACE     NAME                                                    READY   STATUS    RESTARTS   AGE
   kube-system   coredns-f9fd979d6-46hmf                                 0/1     Pending   0          23s
   kube-system   coredns-f9fd979d6-v7v4d                                 0/1     Pending   0          23s
   kube-system   etcd-ip-172-31-54-109.ec2.internal                      0/1     Running   0          38s
   kube-system   kube-apiserver-ip-172-31-54-109.ec2.internal            1/1     Running   0          38s
   kube-system   kube-controller-manager-ip-172-31-54-109.ec2.internal   0/1     Running   0          37s
   kube-system   kube-proxy-xd5zg                                        1/1     Running   0          23s
   kube-system   kube-scheduler-ip-172-31-54-109.ec2.internal            0/1     Running   0          37s


Step 3: Configure Networking
-------------------------------

For the purposes of this document, we will use Calico as a network plugin to configure networking in our Kubernetes cluster. Due to an 
`issue <https://github.com/projectcalico/calico/issues/2322>`_ with Calico and iptables on CentOS, let's modify the configuration before deploying the plugin.

Download the ``calico`` configuration:

.. code-block:: console

   $ curl -fOSsL https://docs.projectcalico.org/manifests/calico.yaml

And add the following configuration options to the environment section:

.. code-block:: console

   - name: FELIX_IPTABLESBACKEND
     value: "NFT"

Save the modified file and then deploy the plugin:

.. code-block:: console

   $ kubectl apply -f ./calico.yaml

After a few minutes, you can see that the networking has been configured:

.. code-block:: console

   NAMESPACE     NAME                                                    READY   STATUS    RESTARTS   AGE
   kube-system   calico-kube-controllers-5c6f6b67db-wmts9                1/1     Running   0          99s
   kube-system   calico-node-fktnf                                       1/1     Running   0          100s
   kube-system   coredns-f9fd979d6-46hmf                                 1/1     Running   0          3m22s
   kube-system   coredns-f9fd979d6-v7v4d                                 1/1     Running   0          3m22s
   kube-system   etcd-ip-172-31-54-109.ec2.internal                      1/1     Running   0          3m37s
   kube-system   kube-apiserver-ip-172-31-54-109.ec2.internal            1/1     Running   0          3m37s
   kube-system   kube-controller-manager-ip-172-31-54-109.ec2.internal   1/1     Running   0          3m36s
   kube-system   kube-proxy-xd5zg                                        1/1     Running   0          3m22s
   kube-system   kube-scheduler-ip-172-31-54-109.ec2.internal            1/1     Running   0          3m36s

To verify that networking has been setup successfully, let's use the ``multitool`` container:

.. code-bLock:: console

   $ kubectl run multitool --image=praqma/network-multitool --restart Never

and then run a simple ``ping`` command to ensure that the DNS servers can be detected correctly: 

.. code-block:: console

   $ kubectl exec multitool -- sh -c 'ping google.com'

.. code-block:: console

   PING google.com (172.217.9.206) 56(84) bytes of data.
   64 bytes from iad30s14-in-f14.1e100.net (172.217.9.206): icmp_seq=1 ttl=53 time=0.569 ms
   64 bytes from iad30s14-in-f14.1e100.net (172.217.9.206): icmp_seq=2 ttl=53 time=0.548 ms

Step 4: Setup NVIDIA Software
====================================

At this point in our journey, you should have a working Kubernetes control plane and worker nodes attached to your cluster.
We can proceed to configure the NVIDIA software on the worker nodes. As described at the beginning of the document, there are 
two options:

.. _gpu-operator:

NVIDIA GPU Operator
----------------------

Use the `NVIDIA GPU Operator <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/getting-started.html#install-nvidia-gpu-operator>`_ 
to automatically setup and manage the NVIDIA software components on the worker nodes.

This is the preferred way as it provides a 1-click install experience. 

.. _nvdp:

Install NVIDIA Dependencies
------------------------------

The GPU worker nodes in the Kubernetes cluster need to be enabled with the following components:

#. NVIDIA drivers
#. NVIDIA Container Toolkit
#. NVIDIA Kubernetes Device Plugin (and optionally GPU Feature Discovery plugin)
#. (Optional) DCGM-Exporter to gather GPU telemetry and integrate into a monitoring stack such as Prometheus

Let's walk through these steps. 

Install NVIDIA Drivers
^^^^^^^^^^^^^^^^^^^^^^^^

This section provides a summary of the steps for installing the driver using the ``apt`` package manager on Ubuntu LTS.

.. note::

   For complete instructions on setting up NVIDIA drivers, visit the quickstart guide at https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html.
   The guide covers a number of pre-installation requirements and steps on supported Linux distributions for a successful install of the driver. 


Install the kernel headers and development packages for the currently running kernel:

.. code-block:: console

   $ sudo apt-get install linux-headers-$(uname -r)

Setup the CUDA network repository and ensure packages on the CUDA network repository have priority over the Canonical repository:

.. code-block:: console

   $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g') \
      && wget https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/cuda-$distribution.pin \
      && sudo mv cuda-$distribution.pin /etc/apt/preferences.d/cuda-repository-pin-600

Install the CUDA repository GPG key:

.. code-block:: console

   $ sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/7fa2af80.pub \
      && echo "deb http://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64 /" | sudo tee /etc/apt/sources.list.d/cuda.list

Update the ``apt`` repository cache and install the driver using the ``cuda-drivers`` or ``cuda-drivers-<branch-number>`` meta-package. 
Use the ``--no-install-recommends`` option for a lean driver install without any dependencies on X packages. This is particularly useful 
for headless installations on cloud instances:

.. code-block:: console

   $ sudo apt-get update \
      && sudo apt-get -y install cuda-drivers

Install NVIDIA Container Toolkit (``nvidia-docker2``)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First, setup the ``stable`` repository for the NVIDIA runtime and the GPG key:

.. code-block:: console

   $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
      && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

Depending on the container engine, you would need to use different packages. 

.. tabs::

   .. tab:: Docker

      Install the ``nvidia-docker2`` package (and its dependencies) after updating the package listing:

      .. code-block:: console

         $ sudo apt-get update \
            && sudo apt-get install -y nvidia-docker2

      Since Kubernetes does not support the ``--gpus`` option with Docker yet, the ``nvidia`` runtime should be setup as the 
      default container runtime for Docker on the GPU node. This can be done by adding the ``default-runtime`` line into the Docker daemon 
      config file, which is usually located on the system at ``/etc/docker/daemon.json``:

      .. code-block:: console

         {
            "default-runtime": "nvidia",
            "runtimes": {
               "nvidia": {
                     "path": "/usr/bin/nvidia-container-runtime",
                     "runtimeArgs": []
               }
            }
         }

      Restart the Docker daemon to complete the installation after setting the default runtime:

      .. code-block:: console

         $ sudo systemctl restart docker

      At this point, a working setup can be tested by running a base CUDA container:

      .. code-block:: console

         $ sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

      You should observe an output as shown below:

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

   .. tab:: containerd

      Install the ``nvidia-container-runtime`` package (and its dependencies) after updating the package listing:

      .. code-block:: console

         $ sudo apt-get update \
            && sudo apt-get install -y nvidia-container-runtime

      Next, ``containerd``'s configuration file (``config.toml``) needs to be updated to set the default runtime to *nvidia*. 
      The new configuration changes are shown in the patch below:

      .. code-block:: bash

         --- config.toml 2020-12-17 19:13:03.242630735 +0000
         +++ /etc/containerd/config.toml 2020-12-17 19:27:02.019027793 +0000
         @@ -70,7 +70,7 @@
            ignore_image_defined_volumes = false
            [plugins."io.containerd.grpc.v1.cri".containerd]
               snapshotter = "overlayfs"
         -      default_runtime_name = "runc"
         +      default_runtime_name = "nvidia"
               no_pivot = false
               disable_snapshot_annotations = true
               discard_unpacked_layers = false
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

      Finally, restart ``containerd``: 

      .. code-block:: bash

         $ sudo systemctl restart containerd

Install NVIDIA Device Plugin
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To use GPUs in Kubernetes, the `NVIDIA Device Plugin <https://github.com/NVIDIA/k8s-device-plugin/>`_ is required. 
The NVIDIA Device Plugin is a daemonset that automatically enumerates the number of GPUs on each node of the cluster 
and allows pods to be run on GPUs.

The preferred method to deploy the device plugin is as a daemonset using ``helm``. First, install Helm:

.. code-block:: console

   $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
      && chmod 700 get_helm.sh \
      && ./get_helm.sh

Add the ``nvidia-device-plugin`` ``helm`` repository:

.. code-block:: console

   $ helm repo add nvdp https://nvidia.github.io/k8s-device-plugin \
      && helm repo update

Deploy the device plugin:

.. code-block:: console

   $ helm install --generate-name nvdp/nvidia-device-plugin

For more user configurable options while deploying the daemonset, refer to the `documentation <https://github.com/NVIDIA/k8s-device-plugin/#deployment-via-helm>`_ 

At this point, all the pods should be deployed:

.. code-block:: console

   $ kubectl get pods -A

.. code-block:: console

   NAMESPACE     NAME                                       READY   STATUS      RESTARTS   AGE
   kube-system   calico-kube-controllers-5fbfc9dfb6-2ttkk   1/1     Running     3          9d
   kube-system   calico-node-5vfcb                          1/1     Running     3          9d
   kube-system   coredns-66bff467f8-jzblc                   1/1     Running     4          9d
   kube-system   coredns-66bff467f8-l85sz                   1/1     Running     3          9d
   kube-system   etcd-ip-172-31-81-185                      1/1     Running     4          9d
   kube-system   kube-apiserver-ip-172-31-81-185            1/1     Running     3          9d
   kube-system   kube-controller-manager-ip-172-31-81-185   1/1     Running     3          9d
   kube-system   kube-proxy-86vlr                           1/1     Running     3          9d
   kube-system   kube-scheduler-ip-172-31-81-185            1/1     Running     4          9d
   kube-system   nvidia-device-plugin-1595448322-42vgf      1/1     Running     2          9d

To test whether CUDA jobs can be deployed, run a sample CUDA ``vectorAdd`` application:

The pod spec is shown for reference below, which requests 1 GPU:

.. code-block:: yaml

   apiVersion: v1
   kind: Pod
   metadata:
     name: gpu-operator-test
   spec:
     restartPolicy: OnFailure
     containers:
     - name: cuda-vector-add
       image: "nvidia/samples:vectoradd-cuda10.2"
       resources:
         limits:
            nvidia.com/gpu: 1


Save this podspec as ``gpu-pod.yaml``. Now, deploy the application:

.. code-block:: console

   $ kubectl apply -f gpu-pod.yaml

Check the logs to ensure the app completed successfully: 

.. code-block:: console

   $ kubectl get pods gpu-operator-test

.. code-block:: console
   
   NAME                READY   STATUS      RESTARTS   AGE
   gpu-operator-test   0/1     Completed   0          9d

And check the logs of the ``gpu-operator-test`` pod: 

.. code-block:: console

   $ kubectl logs gpu-operator-test

.. code-block:: console

   [Vector addition of 50000 elements]
   Copy input data from the host memory to the CUDA device
   CUDA kernel launch with 196 blocks of 256 threads
   Copy output data from the CUDA device to the host memory
   Test PASSED
   Done

GPU Telemetry
^^^^^^^^^^^^^^

Refer to the `DCGM-Exporter <https://docs.nvidia.com/datacenter/cloud-native/gpu-telemetry/dcgm-exporter.html#integrating-gpu-telemetry-into-kubernetes.html>`_ documentation 
to get started with integrating GPU metrics into a Prometheus monitoring system.
