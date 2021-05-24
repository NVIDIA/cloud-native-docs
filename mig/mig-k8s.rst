.. Date: April 26 2021
.. Author: pramarao

.. headings are # * - =

.. _mig-kubernetes:

##########################
MIG Support in Kubernetes
##########################

This document provides steps on getting started and running some example CUDA workloads 
on MIG-enabled GPUs in a Kubernetes cluster.

************************
Software Pre-requisites
************************

The deployment workflow requires these prerequisites. Once these prerequisites have been met, 
you can proceed to deploy a MIG capable version of the NVIDIA ``k8s-device-plugin`` and 
the ``gpu-feature-discovery`` component in your cluster, so that Kubernetes can schedule 
pods on the available MIG devices.


#. You already have a Kubernetes deployment up and running with access to at least one NVIDIA A100 GPU.
#. The node with the NVIDIA A100 GPU is running the following versions of NVIDIA software:

    * NVIDIA `datacenter driver <https://docs.nvidia.com/datacenter/tesla/drivers/index.html>`_ >= 450.80.02
    * NVIDIA Container Toolkit (``nvidia-docker2``) >= 2.5.0 (and corresponding ``libnvidia-container`` >= 1.3.3)
  
#. NVIDIA `k8s-device-plugin <https://github.com/NVIDIA/k8s-device-plugin/tree/v0.7.0>`_: v0.7.0+
#. NVIDIA `gpu-feature-discovery <https://github.com/NVIDIA/gpu-feature-discovery/tree/v0.2.0>`_: v0.2.0+


****************
Getting Started
****************

Install Kubernetes
--------------------

As a first step, ensure that you have a Kubernetes deployment set up with a control plane and nodes joined to the 
cluster. Follow the :ref:`install-k8s` guide for getting started with setting up a Kubernetes cluster.

Configuration Strategy
------------------------

TBD.

Setting up MIG Geometry
--------------------------

You can either use NVML (or its command-line interface ``nvidia-smi``) to configure the desired MIG geometry. For automation, 
we recommend using tooling such as `mig-parted <https://github.com/nvidia/mig-parted>`_ that allows configuring MIG mode 
and creating the desired profiles on the GPUs.

In this step, let's use ``mig-parted`` to configure the A100 into 7 GPUs (using the ``1g.5gb`` profile): 

.. code-block:: console

    $ sudo nvidia-mig-parted apply -f config.yaml -c all-1g.5gb

Now, the A100 should be configured into 7 MIG devices:

.. code-block:: console

    $ sudo nvidia-smi mig -lgi
    +----------------------------------------------------+
    | GPU instances:                                     |
    | GPU   Name          Profile  Instance   Placement  |
    |                       ID       ID       Start:Size |
    |====================================================|
    |   0  MIG 1g.5gb       19        7          0:1     |
    +----------------------------------------------------+
    |   0  MIG 1g.5gb       19        8          1:1     |
    +----------------------------------------------------+
    |   0  MIG 1g.5gb       19        9          2:1     |
    +----------------------------------------------------+
    |   0  MIG 1g.5gb       19       10          3:1     |
    +----------------------------------------------------+
    |   0  MIG 1g.5gb       19       11          4:1     |
    +----------------------------------------------------+
    |   0  MIG 1g.5gb       19       12          5:1     |
    +----------------------------------------------------+
    |   0  MIG 1g.5gb       19       13          6:1     |
    +----------------------------------------------------+

Deploying the NVIDIA Device Plugin and GFD
---------------------------------------------

NVIDIA Device Plugin
=====================

Depending on the MIG configuration strategy used for the cluster, deploy the NVIDIA device plugin with the right options. 
In this example, we assume that the user has chosen a ``single`` MIG strategy for the cluster. 

.. code-block:: console

    $ helm install \
       --generate-name \
       --set migStrategy=single \
       nvdp/nvidia-device-plugin

At this point, the `nvidia-device-plugin` daemonset should be deployed and enumerated the MIG devices to Kubernetes: 

.. code-block:: console

    2021/04/26 23:19:15 Loading NVML
    2021/04/26 23:19:15 Starting FS watcher.
    2021/04/26 23:19:15 Starting OS watcher.
    2021/04/26 23:19:15 Retreiving plugins.
    2021/04/26 23:19:16 Starting GRPC server for 'nvidia.com/gpu'
    2021/04/26 23:19:16 Starting to serve 'nvidia.com/gpu' on /var/lib/kubelet/device-plugins/nvidia-gpu.sock
    2021/04/26 23:19:16 Registered device plugin for 'nvidia.com/gpu' with Kubelet

GPU Feature Discovery
======================

Next, we deploy the `GPU Feature Discovery (GFD) <https://github.com/NVIDIA/gpu-feature-discovery>`_ plugin to label the GPU nodes 
so that users can specific MIG devices as resources in their podspec. Note that the GFD Helm chart also deploys the Node Feature Discovery 
(NFD) as a prerequisite:

.. code-block:: console

    $ helm repo add nvgfd https://nvidia.github.io/gpu-feature-discovery \
        && helm repo update

.. code-block:: console

    $ helm install \
       --generate-name \
       --set migStrategy=single \
       nvgfd/gpu-feature-discovery

At this point, we can verify that all pods are running:

.. code-block:: console

    NAMESPACE                NAME                                       READY   STATUS    RESTARTS   AGE
    kube-system              calico-kube-controllers-6d8ccdbf46-wjst8   1/1     Running   1          4h58m
    kube-system              calico-node-qp5wf                          1/1     Running   1          4h58m
    kube-system              coredns-558bd4d5db-c6nhk                   1/1     Running   1          4h59m
    kube-system              coredns-558bd4d5db-cgjr7                   1/1     Running   1          4h59m
    kube-system              etcd-ipp1-0552                             1/1     Running   1          5h
    kube-system              kube-apiserver-ipp1-0552                   1/1     Running   1          5h
    kube-system              kube-controller-manager-ipp1-0552          1/1     Running   1          5h
    kube-system              kube-proxy-d7tqd                           1/1     Running   1          4h59m
    kube-system              kube-scheduler-ipp1-0552                   1/1     Running   1          5h
    kube-system              nvidia-device-plugin-1619479152-646qm      1/1     Running   0          115m
    node-feature-discovery   gpu-feature-discovery-1619479450-f7rvv     1/1     Running   0          110m
    node-feature-discovery   nfd-master-74f76f6c68-zgt9d                1/1     Running   0          110m
    node-feature-discovery   nfd-worker-pkdn2                           1/1     Running   0          110m


And the node has been labeled:

.. code-block:: console

    $ kubectl get node -o json | jq '.items[].metadata.labels'

with labels:

.. code-block:: json

    ...
    "node-role.kubernetes.io/master": "",
    "node.kubernetes.io/exclude-from-external-load-balancers": "",
    "nvidia.com/cuda.driver.major": "460",
    "nvidia.com/cuda.driver.minor": "73",
    "nvidia.com/cuda.driver.rev": "01",
    "nvidia.com/cuda.runtime.major": "11",
    "nvidia.com/cuda.runtime.minor": "2",
    "nvidia.com/gfd.timestamp": "1619479472",
    "nvidia.com/gpu.compute.major": "8",
    "nvidia.com/gpu.compute.minor": "0",
    "nvidia.com/gpu.count": "7",
    "nvidia.com/gpu.engines.copy": "1",
    "nvidia.com/gpu.engines.decoder": "0",
    "nvidia.com/gpu.engines.encoder": "0",
    "nvidia.com/gpu.engines.jpeg": "0",
    "nvidia.com/gpu.engines.ofa": "0",
    "nvidia.com/gpu.family": "ampere",
    "nvidia.com/gpu.machine": "SYS-1019GP-TT-02-NC24B",
    "nvidia.com/gpu.memory": "4864",
    "nvidia.com/gpu.multiprocessors": "14",
    "nvidia.com/gpu.product": "A100-PCIE-40GB-MIG-1g.5gb",
    "nvidia.com/gpu.slices.ci": "1",
    "nvidia.com/gpu.slices.gi": "1",
    "nvidia.com/mig.strategy": "single"
    }

We can now proceed to run some sample workloads.

.. include:: ../mig/mig-examples.rst
