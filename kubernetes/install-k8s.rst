Install Kubernetes
==================
For simplicity, this section will walk through the steps for installing a single node Kubernetes cluster (where we untaint the control plane 
so it can run GPU pods). These instructions use `kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/>`_ 
but there are many other ways to install Kubernetes. 

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

Now, setup networking with Calico:

.. code-block:: console

   $ kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

Untaint the control plane, so it can be used to schedule GPU pods in our simplistic single-node cluster:

.. code-block:: console

   $ kubectl taint nodes --all node-role.kubernetes.io/master-
