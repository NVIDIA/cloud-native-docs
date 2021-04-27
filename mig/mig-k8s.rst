.. Date: April 26 2021
.. Author: pramarao

.. # * - =

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

Running Sample CUDA Workloads
------------------------------

CUDA VectorAdd
================

Let's run a simple CUDA sample, in this case ``vectorAdd`` by requesting a GPU resource as you would 
normally do in Kubernetes. In this case, Kubernetes will schedule the pod on a single MIG device and 
we use a ``nodeSelector`` to direct the pod to be scheduled on the node with the MIG devices. 

.. code-block:: console

    $ cat << EOF | kubectl create -f -
    apiVersion: v1
    kind: Pod
    metadata:
    name: cuda-vectoradd
    spec:
    restartPolicy: OnFailure
    containers:
    - name: vectoradd
        image: nvidia/samples:vectoradd-cuda11.2.1
        resources:
        limits:
            nvidia.com/gpu: 1
    nodeSelector:
        nvidia.com/gpu.product: A100-PCIE-40GB-MIG-1g.5gb
    EOF    

Concurrent Job Launch
=======================

Now, let's try a more complex example. In this example, we will use Argo Workflows to launch concurrent 
jobs on MIG devices. In this example, the A100 has been configured into 2 MIG devices using the: ``3g.20gb`` profile.

First, `install <https://argoproj.github.io/argo-workflows/quick-start/#install-argo-workflows>`_ the Argo Workflows 
components into your Kubernetes cluster. 

.. code-block:: console

    $ kubectl create ns argo \
        && kubectl apply -n argo \
        -f https://raw.githubusercontent.com/argoproj/argo-workflows/stable/manifests/quick-start-postgres.yaml

Next, download the latest Argo CLI from the `releases page <https://github.com/argoproj/argo-workflows/releases>`_ and 
follow the instructions to install the binary.        

Now, we will craft an Argo example that launches multiple CUDA containers onto the MIG devices on the GPU. 
We will reuse the same ``vectorAdd`` example from before. Here is the job description, saved as ``vector-add.yaml``:

.. code-block:: yaml

    $ cat << EOF > vector-add.yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Workflow
    metadata:
    generateName: argo-mig-example-
    spec:
    entrypoint: argo-mig-result-example
    templates:
    - name: argo-mig-result-example
        steps:
        - - name: generate
            template: gen-mig-device-list
        # Iterate over the list of numbers generated by the generate step above
        - - name: argo-mig
            template: argo-mig
            arguments:
            parameters:
            - name: argo-mig
                value: "{{item}}"
            withParam: "{{steps.generate.outputs.result}}"

    # Generate a list of numbers in JSON format
    - name: gen-mig-device-list
        script:
        image: python:alpine3.6
        command: [python]
        source: |
            import json
            import sys
            json.dump([i for i in range(0, 2)], sys.stdout)

    - name: argo-mig
        retryStrategy:
        limit: 10
        retryPolicy: "Always"
        inputs:
        parameters:
        - name: argo-mig
        container:
        image: nvidia/samples:vectoradd-cuda11.2.1
        resources:
            limits:
            nvidia.com/gpu: 1
        nodeSelector:
        nvidia.com/gpu.product: A100-PCIE-40GB-MIG-3g.20gb
    EOF


Launch the workflow:

.. code-block:: console

    $ argo submit -n argo --watch vector-add.yaml

Argo will print out the pods that have been launched:

.. code-block:: console

    Name:                argo-mig-example-z6mqd
    Namespace:           argo
    ServiceAccount:      default
    Status:              Succeeded
    Conditions:
    Completed           True
    Created:             Wed Mar 24 14:44:51 -0700 (20 seconds ago)
    Started:             Wed Mar 24 14:44:51 -0700 (20 seconds ago)
    Finished:            Wed Mar 24 14:45:11 -0700 (now)
    Duration:            20 seconds
    Progress:            3/3
    ResourcesDuration:   9s*(1 cpu),9s*(100Mi memory),1s*(1 nvidia.com/gpu)

    STEP                       TEMPLATE                 PODNAME                           DURATION  MESSAGE
    ✔ argo-mig-example-z6mqd  argo-mig-result-example
    ├───✔ generate            gen-mig-device-list      argo-mig-example-z6mqd-562792713  8s
    └─┬─✔ argo-mig(0:0)(0)    argo-mig                 argo-mig-example-z6mqd-845918106  2s
    └─✔ argo-mig(1:1)(0)    argo-mig                 argo-mig-example-z6mqd-870679174  2s


If you observe the logs, you can see that the ``vector-add`` sample has completed on both devices:

.. code-block:: console

    $ argo logs -n argo @latest

.. code-block:: console

    argo-mig-example-z6mqd-562792713: [0, 1]
    argo-mig-example-z6mqd-870679174: [Vector addition of 50000 elements]
    argo-mig-example-z6mqd-870679174: Copy input data from the host memory to the CUDA device
    argo-mig-example-z6mqd-870679174: CUDA kernel launch with 196 blocks of 256 threads
    argo-mig-example-z6mqd-870679174: Copy output data from the CUDA device to the host memory
    argo-mig-example-z6mqd-870679174: Test PASSED
    argo-mig-example-z6mqd-870679174: Done
    argo-mig-example-z6mqd-845918106: [Vector addition of 50000 elements]
    argo-mig-example-z6mqd-845918106: Copy input data from the host memory to the CUDA device
    argo-mig-example-z6mqd-845918106: CUDA kernel launch with 196 blocks of 256 threads
    argo-mig-example-z6mqd-845918106: Copy output data from the CUDA device to the host memory
    argo-mig-example-z6mqd-845918106: Test PASSED
    argo-mig-example-z6mqd-845918106: Done

