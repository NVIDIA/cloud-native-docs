.. Date: November 10 2020
.. Author: pramarao

.. _install-k8s:

####################
Install Kubernetes
####################

For simplicity, this document will walk through the steps for installing a single node Kubernetes cluster (where we untaint the control plane 
so it can run GPU pods). These instructions use `kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/>`_ 
but there are many other ways to install Kubernetes.

************
Ubuntu LTS
************
This section provides steps for setting up K8s on Ubuntu 18.04 and 20.04 LTS distributions.

Install Docker
=================

Follow the steps in this `guide <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#installing-on-ubuntu-and-debian>`_ to install Docker on Ubuntu.

Install Kubernetes components
===============================

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

Update the package listing and install the required packages, and ``init`` using ``kubeadm``:

.. code-block:: console

   $ sudo apt-get update \
      && sudo apt-get install -y -q kubelet kubectl kubeadm \
      && sudo kubeadm init --pod-network-cidr=192.168.0.0/16

Finish the configuration setup with Kubeadm:

.. code-block:: console

   $ mkdir -p $HOME/.kube \
      && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config \
      && sudo chown $(id -u):$(id -g) $HOME/.kube/config

Configure networking
=====================

Now, setup networking with Calico:

.. code-block:: console

   $ kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

Untaint the control plane, so it can be used to schedule GPU pods in our simplistic single-node cluster:

.. code-block:: console

   $ kubectl taint nodes --all node-role.kubernetes.io/master-

Your cluster should now be ready to schedule containerized applications.

**********
CentOS 8
**********
Follow the steps in this section for setting up K8s on CentOS 8.

.. note::

   If you're using CentOS 8 on a cloud IaaS platform such as EC2, then you may need to do some additional setup as listed here:

   #. Choose an official CentOS image for your EC2 region: `https://wiki.centos.org/Cloud/AWS <https://wiki.centos.org/Cloud/AWS>`_
   #. Install some of the prerequisites:

      .. code-block:: console

         $ sudo dnf install -y tar bzip2 make automake gcc gcc-c++ pciutils elfutils-libelf-devel libglvnd-devel iptables firewalld vim bind-utils wget

   #. Update the running kernel to ensure you're running the latest updates

      .. code-block:: console

         $ sudo dnf update -y

   #. Reboot your VM 

      .. code-block:: console

         $ sudo reboot

Install Docker
=================

Follow the steps in this `guide <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#setting-up-docker-on-centos-8>`_ to install Docker on CentOS 8.

Configuring the system
========================

For the remaining part of this section, we will follow the general steps for using `kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/>`_.
Also, for convenience, let's enter into an interactive ``sudo`` session since most of the remaining commands require root privileges: 

.. code-block:: console

   $ sudo -i

Disabling SELinux
-------------------

.. code-block:: console

   $ setenforce 0 \
      && sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

Bridged traffic and iptables
------------------------------

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
-----------------------------

The network plugin requires certain ports to be open on the control plane and worker nodes. See this 
`table <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports>`_ for more information on 
the purpose of these port numbers.

Ensure that ``firewalld`` is running:

.. code-block:: console

   $ systemctl status firewalld

and if required, start ``firewalld``:

.. code-block:: console

   $ systemctl start firewalld \
      && systemctl enable firewalld

Now open the ports:

.. code-block:: console

   $ firewall-cmd --permanent --add-port=6443/tcp \
      && firewall-cmd --permanent --add-port=2379-2380/tcp \
      && firewall-cmd --permanent --add-port=10250/tcp \
      && firewall-cmd --permanent --add-port=10251/tcp \
      && firewall-cmd --permanent --add-port=10252/tcp \
      && firewall-cmd --permanent --add-port=10255/tcp

Its also required to add the ``docker0`` interface to the public zone and allow for ``docker0`` ingress and egress:

.. code-block:: console

   $ nmcli connection modify docker0 connection.zone public \
      && firewall-cmd --zone=public --add-masquerade --permanent \
      && firewall-cmd --zone=public --add-port=443/tcp

Reload the ``firewalld`` configuration and ``dockerd`` for the settings to take effect:

.. code-block:: console

   $ firewall-cmd --reload \
      && systemctl restart docker

Optionally, before we install the Kubernetes control plane, test your container networking using a simple ``ping`` command:

.. code-block:: console

   $ docker run busybox ping google.com

Disable swap
---------------

For performance, disable swap on your system:

.. code-block:: console

   $ swapoff -a

Install Kubernetes components
===============================

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

.. code-block:: console

   $ dnf install -y kubelet kubectl kubeadm

Ensure that ``kubelet`` is started across system reboots:

.. code-block:: console

   $ systemctl enable kubelet \
      && systemctl start kubelet

Now use ``kubeadm`` to initialize the control plane:

.. code-block:: console

   $ kubeadm init --pod-network-cidr=192.168.0.0/16

At this point, feel free to exit from the interactive ``sudo`` session that we started with. 

Configure directories
-----------------------

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


Configure networking
----------------------

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

   $ kubectl exec -it multitool -- bash

   bash-5.0# ping google.com
   PING google.com (172.217.9.206) 56(84) bytes of data.
   64 bytes from iad30s14-in-f14.1e100.net (172.217.9.206): icmp_seq=1 ttl=53 time=0.569 ms
   64 bytes from iad30s14-in-f14.1e100.net (172.217.9.206): icmp_seq=2 ttl=53 time=0.548 ms


