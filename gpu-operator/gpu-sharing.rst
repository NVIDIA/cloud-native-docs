.. Date: Jun 21 2022
.. Author: smerla

.. headings (h1/h2/h3/h4/h5) are # * = -

.. _gpu-sharing:

###############################
Time-Slicing GPUs in Kubernetes
###############################


************
Introduction
************

The latest generations of NVIDIA GPUs provide an operation mode called
Multi-Instance GPU, or MIG. MIG allows you to partition a GPU
into several smaller, predefined instances, each of which looks like a
mini-GPU that provides memory and fault isolation at the hardware layer.
You can share access to a GPU by running workloads on one of
these predefined instances instead of the full native GPU.

MIG support was added to Kubernetes in 2020. Refer to `Supporting MIG in Kubernetes <https://www.google.com/url?q=https://docs.google.com/document/d/1mdgMQ8g7WmaI_XVVRrCvHPFPOMCm5LQD5JefgAh6N8g/edit&sa=D&source=editors&ust=1655578433019961&usg=AOvVaw1F-OezvM-Svwr1lLsdQmu3>`_
for details on how this works.

What if you don't need the memory and fault-isolation provided by
MIG? What if you're willing to trade the isolation provided by MIG for
the ability to share a GPU by a larger number of users. Or what if you don't 
have access to a GPU that supports MIG? Should they not be able
to provide shared access to their GPUs so long as memory and
fault-isolation are not a concern?

The NVIDIA GPU Operator allows oversubscription of GPUs through a set 
of extended options for the `NVIDIA Kubernetes Device Plugin <https://catalog.ngc.nvidia.com/orgs/nvidia/containers/k8s-device-plugin>`_.
Internally, GPU time-slicing is used to allow workloads that land 
on oversubscribed GPUs to interleave with one another. This page covers 
ways to enable this in Kubernetes using the GPU Operator.

This mechanism for enabling “time-sharing” of
GPUs in Kubernetes allows a system administrator to define a set of
“replicas” for a GPU, each of which can be handed out independently to a
pod to run workloads on. Unlike MIG, there is no memory or
fault-isolation between replicas, but for some workloads this is better
than not being able to share at all. Internally, GPU
time-slicing is used to multiplex workloads from
replicas of the same underlying GPU.

GPU time-slicing can be used with bare-metal applications, virtual machines 
with GPU passthrough, and virtual machines with NVIDIA vGPU.
The following sections describe how to make use of the GPU
time-slicing feature in Kubernetes.


*************
Configuration
*************


Configuration for Shared Access to GPUs with GPU Time-Slicing
=============================================================

You can provide time-slicing configurations for the NVIDIA Kubernetes Device Plugin as a ``ConfigMap``:

.. code-block:: yaml

    version: v1
    sharing:
    timeSlicing:
        renameByDefault: <bool>
        failRequestsGreaterThanOne: <bool>
        resources:
        - name: <resource-name>
        replicas: <num-replicas>
        ...

For each named resource under ``sharing.timeSlicing.resources``, a number of 
replicas can be specified for that resource type. These replicas represent 
the number of shared accesses that will be granted for a GPU represented by that resource type.
If ``renameByDefault=true``, then each resource will be advertised under the 
name ``<resource-name>.shared`` instead of simply ``<resource-name>``.
If ``failRequestsGreaterThanOne=true``, then the plugin will fail to allocate 
any shared resources to a container if they request more than one. The 
container’s pod will fail with an ``UnexpectedAdmissionError`` and must then be manually 
deleted, updated, and redeployed.

.. note::

    Unlike with "normal" GPU requests, requesting more than one shared GPU 
    does not guarantee that you will get
    access to a proportional amount of compute power. It only specifies that 
    you will get access to a GPU that is shared
    by other clients, each of which has the freedom to run as many processes 
    on the underlying GPU as they want. 
    Internally, the GPU will simply give an equal share of time to 
    all GPU processes across all of the clients. 
    The ``failRequestsGreaterThanOne`` flag is meant to help users 
    understand this subtlety, by treating a request of 1 as an 
    access request rather than an exclusive resource request. Setting 
    ``failRequestsGreaterThanOne=true`` is recommended,
    but it is set to ``false`` by default to retain backwards compatibility.

You can specify multiple configurations in a ``ConfigMap`` as in the following 
example.

.. code-block:: yaml

    cat << EOF >> time-slicing-config.yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
    name: time-slicing-config
    namespace: nvidia-gpu-operator
    data:
        a100-40gb: |-
            version: v1
            sharing:
            timeSlicing:
                resources:
                - name: nvidia.com/gpu
                  replicas: 8
                - name: nvidia.com/mig-1g.5gb
                  replicas: 1
                - name: nvidia.com/mig-2g.10gb
                  replicas: 2
                - name: nvidia.com/mig-3g.20gb
                  replicas: 3
                - name: nvidia.com/mig-7g.40gb
                  replicas: 7
        tesla-t4: |-
            version: v1
            sharing:
            timeSlicing:
                resources:
                - name: nvidia.com/gpu
                  replicas: 4
    EOF

Create a ``ConfigMap`` in the operator namespace. In this example, it is ``gpu-operator``:

.. code-block:: console

    $ kubectl create namespace gpu-operator

.. code-block:: console

    $ kubectl create -f time-slicing-config.yaml


Enabling Shared Access to GPUs with the NVIDIA GPU Operator
===========================================================

You can enable time-slicing with the NVIDIA GPU Operator by passing the
``devicePlugin.config.name=<config-map-name>`` parameter, 
where ``<config-map-name>``
is the name of the ``ConfigMap`` created for the time-slicing 
configuration as described in the previous section.

Install the NVIDIA GPU Operator with time-slicing enabled (e.g. ``time-slicing-config``):

.. code-block:: console

    $ helm install gpu-operator nvidia/gpu-operator \
         -n gpu-operator \
         --set devicePlugin.config.name=time-slicing-config


Applying the Default Configuration Across the Cluster
=====================================================

The time-slicing configuration can be applied either at cluster level 
or per node. By default, the GPU Operator will **not** apply the time-slicing
configuration to any GPU node in the cluster. The user would have to 
explicitly specify it with the ``devicePlugin.config.default=<config-name>`` parameter.

Install the GPU Operator by passing the time-slicing ``ConfigMap`` name and the
**default** configuration (e.g. a100-40gb):

.. code-block:: console

    $ helm install gpu-operator nvidia/gpu-operator \
         -n gpu-operator \
         --set devicePlugin.config.name=time-slicing-config \
         --set devicePlugin.config.default=a100-40gb

Verify that the time-slicing configuration is applied successfully to all 
GPU nodes in the cluster:

.. code-block:: console

    $ kubectl describe node <node-name>
    ...
    Capacity:
    nvidia.com/gpu: 8
    ...
    Allocatable:
    nvidia.com/gpu: 8
    ...

.. note::
    In this example it is assumed that node ``<node-name>`` has one GPU.


Applying a Time-Slicing Configuration Per Node
==============================================

To enable a time-slicing configuration per node, the user would need to 
apply the ``nvidia.com/device-plugin.config=<config-name>`` node label after 
installing the GPU Operator. On applying this label, the
NVIDIA Kubernetes Device Plugin will configure node GPU resources accordingly.

Install the GPU Operator by passing a time-slicing ``ConfigMap``:

.. code-block:: console

    $ helm install gpu-operator nvidia/gpu-operator \
         -n gpu-operator \
         --set devicePlugin.config.name=time-slicing-config

Label the node with the required time-slicing configuration (e.g. ``a100-40gb``) in the ``ConfigMap``:

.. code-block:: console

    $ kubectl label node <node-name> nvidia.com/device-plugin.config=a100-40gb

Verify that the time-slicing configuration is applied successfully:

.. code-block:: console

    $ kubectl describe node <node-name>
    ...
    Capacity:
    nvidia.com/gpu: 8
    ...
    Allocatable:
    nvidia.com/gpu: 8
    ...

.. note::
    In this example it is assumed that node ``<node-name>`` has one GPU.


Changes to Node Labels by the GPU Feature Discovery Plugin
==========================================================

In addition to the standard node labels applied by the GPU Feature
Discovery Plugin (GFD), the following label 
is also included when deploying 
the plugin with the time-slicing configurations described above.

.. code-block:: text

    nvidia.com/<resource-name>.replicas = <num-replicas>

where ``<num-replicas>`` is the factor by which each resource of ``<resource-name>`` is oversubscribed.

Additionally, ``nvidia.com/<resource-name>.product`` is modified as follows if ``renameByDefault=false``:

.. code-block:: text

    nvidia.com/<resource-name>.product = <product name>-SHARED

Using these labels, you can select a shared vs. non-shared GPU 
in the same way as traditionally 
selecting one GPU model over another. That is, the ``SHARED`` annotation ensures that 
the ``nodeSelector`` can be used to attract 
pods to nodes with shared GPUs.

Because having ``renameByDefault=true`` already encodes the fact that the 
resource is shared on the resource name,
there is no need to annotate the product name with ``SHARED``. You can already 
find needed shared resources by simply requesting it in the pod specification.

When running with ``renameByDefault=false`` and ``migStrategy=single``,
both the MIG profile name and the new ``SHARED`` annotation 
are appended to the product name, like this:

.. code-block:: text

    nvidia.com/gpu.product = A100-SXM4-40GB-MIG-1g.5gb-SHARED


Examples
========

Consider the following configuration file:

.. code-block:: yaml

      version: v1
      sharing:
      timeSlicing:
         resources:
         - name: nvidia.com/gpu
            replicas: 10
         ...


When applying this configuration to a node with 8 GPUs on it, 
the plugin advertises 80 ``nvidia.com/gpu`` resources to 
Kubernetes instead of 8, because there are 10 replicas.

Likewise, when applying the following configuration to a node, 
then 80 ``nvidia.com/gpu.shared`` resources would be advertised to 
Kubernetes instead of 8 ``nvidia.com/gpu`` resources.

.. code-block:: yaml

      version: v1
      sharing:
      timeSlicing:
         renameByDefault: true
         resources:
         - name: nvidia.com/gpu
            replicas: 10
         ...


In both cases, the plugin simply creates 10 references to each GPU and
indiscriminately hands them out to anyone that asks for them. Internally, 
GPU time-slicing is used to allow workloads that execute on the same
GPU to interleave with one another. However, nothing special is done to
isolate workloads that are granted replicas from the same underlying
GPU, and each workload has access to the GPU memory and runs in the same
fault domain as all of the others, meaning that if one workload crashes, they
all do.

.. _h.yirkus4krhkp:

Labels Applied by gpu-feature-discovery
=======================================

For ``gpu-feature-discovery``, the labels that get applied depend on 
whether ``renameByDefault=true``.

When ``renameByDefault=false`` then the following label is added:

.. code-block:: console

    nvidia.com/<resource-name>.replicas = <num-replicas>


``nvidia.com/<resource-name>.product`` is modified as follows if ``renameByDefault=false``:

.. code-block:: text

    nvidia.com/<resource-name>.product = <product name>-SHARED


In the example above on a DGX-A100 machine, the labels that would 
be applied are:

.. code-block:: console

      nvidia.com/gpu.replicas = 10
      nvidia.com/gpu.product = A100-SXM4-40GB-SHARED


When running with ``renameByDefault=false`` and 
``migStrategy=single`` both the MIG profile name and the 
new ``SHARED`` annotation 
will be appended to the product name. For example: 

.. code-block:: console

      nvidia.com/gpu.product = A100-SXM4-40GB-MIG-1g.5gb-SHARED


On the other hand, when ``renameByDefault=true`` then only the 
following label is added, and the product name remains unchanged:

.. code-block:: console

      nvidia.com/<resource-name>.replicas = <num-replicas>


Because ``renameByDefault=true`` already encodes the fact 
that the resource is shared on the resource name itself, there is 
no need to annotate the product name with ``SHARED``. You can already 
find the needed shared resources by simply requesting it in the 
pod specification.

.. _h.7wfh7klm2fy0:

Supported Resource Types
========================

Currently, the only supported resource types are ``nvidia.com/gpu`` 
and any of the resource types that emerge from configuring a node with
the mixed MIG strategy.

For example, the full set of time-sliceable resources on a T4 card would
be:

.. code-block:: console

      nvidia.com/gpu


And the full set of time-sliceable resources on an A100 40GB card would be:

.. code-block:: console

      nvidia.com/gpu
      nvidia.com/mig-1g.5gb
      nvidia.com/mig-2g.10gb
      nvidia.com/mig-3g.20gb
      nvidia.com/mig-7g.40gb


Likewise, on an A100 80GB card, they would be:

.. code-block:: console

      nvidia.com/gpu
      nvidia.com/mig-1g.10gb
      nvidia.com/mig-2g.20gb
      nvidia.com/mig-3g.40gb
      nvidia.com/mig-7g.80gb


.. _h.zhys08yprw2d:

A Complete Example
==================

Build a configuration called ``default.yaml`` to apply by default to all nodes:

.. code-block:: yaml

      version: v1
      flags:
      migStrategy: none


Build a configuration called ``t4-config.yaml`` for nodes with a T4 card:

.. code-block:: yaml

      version: v1
      flags:
      migStrategy: none
      sharing:
      timeSlicing:
         resources:
         - name: nvidia.com/gpu
            replicas: 8


Build a configuration called ``a100-40gb-config.yaml`` for nodes with 
a 40GB A100 card:

.. code-block:: yaml

      version: v1
      flags:
      migStrategy: mixed
      sharing:
      timeSlicing:
         resources:
         - name: nvidia.com/gpu
            replicas: 8
         - name: nvidia.com/mig-1g.5gb
            replicas: 1
         - name: nvidia.com/mig-2g.10gb
            replicas: 2
         - name: nvidia.com/mig-3g.20gb
            replicas: 3
         - name: nvidia.com/mig-7g.40gb
            replicas: 7


Build a configuration called ``a100-80gb-config.yaml`` for nodes 
with an 80GB A100 card:

.. code-block:: yaml

      version: v1
      flags:
      migStrategy: mixed
      sharing:
      timeSlicing:
         resources:
         - name: nvidia.com/gpu
            replicas: 8
         - name: nvidia.com/mig-1g.10gb
            replicas: 1
         - name: nvidia.com/mig-2g.20gb
            replicas: 2
         - name: nvidia.com/mig-3g.40gb
            replicas: 3
         - name: nvidia.com/mig-7g.80gb
            replicas: 7


Install the plugin and GFD referencing these configurations:

.. code-block:: console

      $ helm upgrade -i nvdp nvdp/nvidia-device-plugin \
         --version=0.12.2 \
         --namespace nvidia-device-plugin \
         --create-namespace \
         --set gfd.enable = true \
         --set config.map.default=default.yaml \
         --set config.map.t4-config=t4-config.yaml \
         --set config.map.a100-40gb-config=a100-40gb.config.yaml \
         --set config.map.a100-80gb-config=a100-80gb.config.yaml


Update the configuration for each node, based on the type of GPU 
they contain:

.. code-block:: console

      $ kubectl label node \
         --overwrite \
         --selector=nvidia.com/gpu.product=TESLA-T4 \
         nvidia.com/device-plugin.config=t4-config
         
      $ kubectl label node \
         --overwrite \
         --selector=nvidia.com/gpu.product=A100-SXM4-40GB \
         nvidia.com/device-plugin.config=a100-40gb-config

      $ kubectl label node \
         --overwrite \
         --selector=nvidia.com/gpu.product=A100-SXM4-80GB \
         nvidia.com/device-plugin.config=a100-80gb-config


References
==========

You can find more information about GPU time-slicing at the following resources.

1) `Blog post on GPU time-slicing in Kubernetes <https://developer.nvidia.com/blog/improving-gpu-utilization-in-kubernetes>`_.
2) `NVIDIA Kubernetes Device Plugin <https://github.com/NVIDIA/k8s-device-plugin#shared-access-to-gpus-with-cuda-time-slicing>`_.

*****************************************************
Testing GPU Time-Slicing with the NVIDIA GPU Operator
*****************************************************


This section covers a workload test scenario to validate GPU time-slicing with GPU resources.


#. Create a workload test file ``plugin-test.yaml`` as follows:

.. code:: yaml

      apiVersion: apps/v1
      kind: Deployment
      metadata:
      name: nvidia-plugin-test
      labels:
         app: nvidia-plugin-test
      spec:
      replicas: 5
      selector:
         matchLabels:
            app: nvidia-plugin-test
      template:
         metadata:
            labels:
            app: nvidia-plugin-test
         spec:
            tolerations:
            - key: nvidia.com/gpu
               operator: Exists
               effect: NoSchedule
            containers:
            - name: dcgmproftester11
               image: nvidia/samples:dcgmproftester-2.0.10-cuda11.0-ubuntu18.04
               command: ["/bin/sh", "-c"]
               args:
                  - while true; do /usr/bin/dcgmproftester11 --no-dcgm-validation -t 1004 -d 300; sleep 30; done
               resources:
               limits:
                  nvidia.com/gpu: 1
               securityContext:
               capabilities:
                  add: ["SYS_ADMIN"]

2. Create a deployment with multiple replicas:

.. code:: console

      kubectl apply -f plugin-test.yaml

3. Verify that all five replicas are running:

.. code:: console

      kubectl get pods
      sudo chroot /run/nvidia/driver nvidia-smi

Your output should look something like this:

.. code:: console
   
      NAME                                  READY   STATUS    RESTARTS   AGE
      nvidia-plugin-test-8479c8f7c8-4tnsn   1/1     Running   0          6s
      nvidia-plugin-test-8479c8f7c8-cdgdb   1/1     Running   0          6s
      nvidia-plugin-test-8479c8f7c8-q2vn7   1/1     Running   0          6s
      nvidia-plugin-test-8479c8f7c8-t9d4b   1/1     Running   0          6s
      nvidia-plugin-test-8479c8f7c8-xggls   1/1     Running   0          6s


.. code:: console

      $ sudo chroot /run/nvidia/driver nvidia-smi  

Your output should look something like this:

.. code:: console

      +-----------------------------------------------------------------------------+
      | NVIDIA-SMI 510.73.08    Driver Version: 510.73.08    CUDA Version: 11.6     |
      |-------------------------------+----------------------+----------------------+
      | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
      | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
      |                               |                      |               MIG M. |
      |===============================+======================+======================|
      |   0  Tesla T4            On   | 00000000:00:1E.0 Off |                    0 |
      | N/A   44C    P0    70W /  70W |   1577MiB / 15360MiB |    100%      Default |
      |                               |                      |                  N/A |
      +-------------------------------+----------------------+----------------------+
                                                                                    
      +-----------------------------------------------------------------------------+
      | Processes:                                                                  |
      |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
      |        ID   ID                                                   Usage      |
      |=============================================================================|
      |    0   N/A  N/A      3666      C   /usr/bin/dcgmproftester11         315MiB |
      |    0   N/A  N/A      3679      C   /usr/bin/dcgmproftester11         315MiB |
      |    0   N/A  N/A      3992      C   /usr/bin/dcgmproftester11         315MiB |
      |    0   N/A  N/A      4119      C   /usr/bin/dcgmproftester11         315MiB |
      |    0   N/A  N/A      4324      C   /usr/bin/dcgmproftester11         315MiB |
      +-----------------------------------------------------------------------------+


****************
More Information
****************

You can find more information in the following document:

`Improving GPU Utilization in Kubernetes <https://docs.google.com/document/d/1N0crA5BrqguvjPm5t00uoxA827d1ZomoGU0WwQ0e2CU/>`_

