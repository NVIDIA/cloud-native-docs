
###################################
NVIDIA GPU DRA Driver
###################################

*******************************
About the NVIDIA GPU DRA Driver
*******************************

The NVIDIA GPU DRA Driver leverages the Kubernetes Dynamic Resource Allocation (DRA) API to support NVIDIA IMEX channels available in GH200 and GB200 GPUs.
The NVIDIA GPU DRA Driver creates and manages IMEX channels through the creation of a ComputeDomain custom resource. Use this custom resource to define your resource templates, and then reference the templates within your workload specs.

An IMEX channel is a construct that allows a set of GPUs to directly read and write each other's memory over a high-bandwidth NVLink. 
The NVLink connection may either be directly between GPUs on the same node or between GPUs on separate nodes connected by an NVSwitch. 
Once an IMEX channel has been established for a set of GPUs, they are free to read and write each other's memory via extensions to the CUDA memory call APIs.

The ability to support IMEX channels on GH200 and GB200 systems is essential, as they have been designed specifically to exploit the use of IMEX channels to turn a rack of GPU machines (each with a small number of GPUs) into a giant supercomputer with up to 72 GPUs communicating at full NVLink bandwidth. 
This allows you to get the most use out of your available GPUs without any additional latency burdens.  

Kubernetes Dynamic Resource Allocation (DRA), available as beta in Kubernetes v1.32, is an API for requesting and sharing resources between pods and containers inside a pod. 
This feature treats specialized hardware as a definable and reusable object and provides the necessary primitives to support cross-node resources such as IMEX channels. 
Along with the NVIDIA GPU DRA Driver, you are able to use DRA to define IMEX channel resources that can be managed by Kubernetes.

Refer to the `Kubernetes DRA documentation <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/>`__ for details on this feature. 

*************
Prerequisites
*************

- GH200 and GB200 GPUs with Mulit-Node NVLink connections between GPUs.

- 565 or later driver installed on all GPU nodes. 
  Drivers must be pre-installed on all GPU nodes before installing the NVIDIA GPU Operator as operator managed drivers are not supported at this time.

- IMEX packages installed on GPU nodes with systemd service disabled.
  The IMEX package verisons must match the installed driver version.

  The following example shows how to install IMEX drivers. 

  .. code-block:: console 

      $ curl -fsSL -o /tmp/nvidia-imex-${IMEX_DRIVER_VERSION}_${DRIVER_VERSION}-1_${TARGETARCH}.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/sbsa/nvidia-imex-${IMEX_DRIVER_VERSION}_${DRIVER_VERSION}-1_${TARGETARCH}.deb && dpkg -i /tmp/nvidia-imex-${IMEX_DRIVER_VERSION}_${DRIVER_VERSION}-1_${TARGETARCH}.deb && \
      nvidia-imex --version && \
      ls /etc/nvidia-imex && \
      rm -rf /tmp/nvidia-imex_${IMEX_DRIVER_VERSION}_${DRIVER_VERSION}-1_${TARGETARCH}.deb

  Then disable systemd service.

  .. code-block:: console 

    $ systemctl disable --now nvidia-imex.service && systemctl mask nvidia-imex.service

- Kubernetes v1.32 multi-node cluster with the DynaticResourceAllocation feature gate enabled. 

  The following is a sample for enabling DRA feature gates. 
  Refer to the Kubernetes documentation for full details on `enabling DRA on your cluster <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/#enabling-dynamic-resource-allocation>`__.

  .. literalinclude:: ./manifests/input/kubeadm-init-config.yaml
    :language: yaml
    :caption: Sample Kubeadm Init Config with DRA Feature Gates Enabled

- The NVIDIA GPU Operator v25.3.0 installed with CDI enabled on all nodes. 
  
  A sample Helm install command below includes enabling CDI with ``cdi.enabled=true`` and pre-installed drivers configured with ``drivers.enabled=false``. 
  Refer to the install documentation for details on `enabling CDI <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#common-chart-customization-options>`__ and `pre-installed drivers <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#pre-installed-nvidia-gpu-drivers>`__.

  .. code-block:: console

      $ helm install --wait --generate-name \
              -n gpu-operator --create-namespace \
              nvidia/gpu-operator \
              --version=${version} \
              --set driver.enabled=false
              --set cdi.enabled=true

*************************
Install NVIDIA DRA Driver
*************************

#. Add the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
          && helm repo update

#. Install NVIDIA DRA Driver:

   .. code-block:: console

      $ helm install nvidia-dra-driver-gpu nvidia-dra-driver-gpu-dev-repo/nvidia-dra-driver-gpu \
            --create-namespace \
            --namespace nvidia-dra-driver-gpu \
            --set image.repository=ghcr.io/nvidia/k8s-dra-driver-gpu \
            --set image.tag=d1fad7ed-ubi9 \
            --set nvidiaDriverRoot=/ \
            --set nvidiaCtkPath=/usr/local/nvidia/toolkit/nvidia-ctk \
            --set resources.gpus.enabled=false


Common Chart Customization Options
==================================

The following options are available when using the Helm chart.
These options can be used with ``--set`` when installing with Helm.

The following table identifies the most frequently used options.
To view all the options, run ``helm show values nvidia/nvidia-dra-driver-gpu``.

.. list-table::
   :widths: 20 50 30
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``nvidiaDriverRoot``
     - Specifies the driver root on the host.
       For driver installed directly on a host, use a value of `/`.
     - ``/``

   * - ``nvidiaCtkPath``
     - Specifies the path of The NVIDIA Container Tool Kit binary (nvidia-ctk) on the host, as it should appear in the the generated CDI specification.
       The path depends on the system that runs on the node.
     - ``/usr/bin/nvidia-ctk`` 


Verify installation
===================

#. Validate that the DRA Driver components are running and in a Ready state.

   .. code-block:: console

      $ kubectl get pod -n nvidia-dra-driver-gpu

   Example output:

   .. code-block:: console

      NAME                                                           READY   STATUS    RESTARTS   AGE
      nvidia-dra-driver-k8s-dra-driver-controller-67cb99d84b-5q7kj   1/1     Running   0          7m26s
      nvidia-dra-driver-k8s-dra-driver-kubelet-plugin-7kdg9          1/1     Running   0          7m27s
      nvidia-dra-driver-k8s-dra-driver-kubelet-plugin-bd6gn          1/1     Running   0          7m27s
      nvidia-dra-driver-k8s-dra-driver-kubelet-plugin-bzm6p          1/1     Running   0          7m26s
      nvidia-dra-driver-k8s-dra-driver-kubelet-plugin-xjm4p          1/1     Running   0          7m27s


#. Confirm that all GPU nodes are labeled with clique ids.

   .. code-block:: console

      $ (echo -e "NODE\tLABEL\tCLIQUE"; kubectl get nodes -o json | \
        jq -r '.items[] | [.metadata.name, "nvidia.com/gpu.clique", .metadata.labels["nvidia.com/gpu.clique"]] | @tsv') | \
        column -t

   Example output:

   .. code-block:: console

      NODE                  LABEL                  CLIQUE
      node1                 nvidia.com/gpu.clique  1fbed3a8-bd74-4c83-afcb-cfb75ebc9304.1
      node2                 nvidia.com/gpu.clique  1fbed3a8-bd74-4c83-afcb-cfb75ebc9304.1
      node3                 nvidia.com/gpu.clique  1fbed3a8-bd74-4c83-afcb-cfb75ebc9304.1
      node4                 nvidia.com/gpu.clique  1fbed3a8-bd74-4c83-afcb-cfb75ebc9304.1

The GPU DRA Driver adds a Clique ID to each GPU node. 
This is an unique identifier within an NVLink domain (physically connected GPUs over NVLink) that indicates which GPUs within that domain are physically capable of talking to each other. 
The partitioning of GPUs into a set of cliques is done at the NVSwitch layer, not at the individual node layer. All GPUs on a given node are guaranteed to have the same <ClusterUUID.Clique ID> pair. 

The ClusterUUID is a unique identifier for a given NVLink Domain. 
It can be queried on a GPU by GPU basis via nvidia-smi. 
All GPUs on a given node are guaranteed to have the same Cluster UUID. 



***************************************
About the ComputeDomain Custom Resource
***************************************

The NVIDIA GPU DRA Driver introduces a new custom resource called ComputeDomain, which creates a DRA ResourceClaimTemplate that you can reference in workloads. 
The ComputeDomain resources also creates a unique ResourceClaim for each worker that links it back to the ComputeDomain where the ResourceClaimTemplate is defined.

If a subset of the nodes associated with a ComputeDomain are capable of communicating over IMEX, the NVIDIA Kubernetes DRA will set up a one-off IMEX domain to allow GPUs to communicate over their multi-node NVLink connections. Multiple such IMEX domains will be created as necessary depending on the number (and availability) of nodes allocated to the ComputeDomain. 

.. literalinclude:: ./manifests/input/dra-compute-domain-crd.yaml
   :language: yaml
   :caption: Sample NVIDIA DRA Driver ComputeDomain Custom Resource Manifest

The following table describes some of the fields in the custom resource.

.. list-table::
   :header-rows: 1
   :widths: 20 60 20

   * - Field
     - Description
     - Default Value

   * - ``channel.resourceClaimTemplate.name`` (required)
     - Specifies the ``name`` of the ResourceClaimTemplate to create.
     - None

   * - ``numNodes`` (required)
     - Specifies the number of nodes in the IMEX domain.
     - None


Node and Pod Affitnity Strategies
=========================================

The ComputeDomain object is not tied directly to the notion of an IMEX channel. 
Instead, it is tied to the looser notion of running a multi-node workload on a set of compute nodes.
This means that nodes that are not capable of communicating over IMEX can still be allocated to the same ComputeDomain as IMEX capable nodes. 
Workloads should use NodeAffinity and PodAffinity rules to influence where they will be deployed on your cluster to ensure they are allocated to the exact set of nodes you want.

For example you could set PodAffinity with a preferred topologyKey set to ``nvidia.com/gpu.clique`` for workloads to span multiple NVLink domains but want them packed as tightly as possible. Or use a required topologyKey set to ``nvidia.con/gpu.clique`` when you require all workloads deployed into the same NVLink domain, but don't care which one. 

*****************************************
Create a Custom Domain and run a workload
*****************************************

To create IMEX domains on your GPUs, create a Custom Domain resource on your cluster. YOu can then reference the ResouceClaimTemplate in your workload specs as a ``resourceClaims.resourceClaimTemplateName``. The example manifest below, ``imex-channel-injection.yaml``, shows the creation of a CustomDomain, ``imex-channel-injection``, and a workload pod referencing the ResourceClaimTemplate, ``imex-channel-0``:

.. literalinclude:: ./manifests/input/imex-channel-injection.yaml
  :language: yaml

Apply the mainfest.

.. code-block:: console

    $ kubectl apply -f imex-channel-injection.yaml


This will create the following resources on your cluster.

- A ComputeDomain resourced named ``imex-channel-injection``.

- A ResourceClaimTemplate named ``imex-channel-0``.

  This is used to request access to a unique IMEX channel on a set of compute nodes.
  A reference to the ComputeDomain this ResourceClaimTemplate is associated with is passed along as part of a request.
  Each worker of a multi-node job should reference this ResourceClaimTemplate to ensure that they have access to the same IMEX channel inside the appropriate ComputeDomain

- ResourceClaimTemplate for the DaemonSet.

  This is used to request access to a device that injects ComputeDomain-specific settings for an imex-daemon to run with (config.cfg, nodes_config.cfg, etc.)
  A reference to the ComputeDomain this ResourceClaimTemplate is associated with is passed along as part of a request.
  Each worker of the daemonset mentioned below references this ResourceClaimTemplate to ensure they start up IMEX daemons associated with the appropriate ComputeDomain.

- A DaemonSet. 

  This forms one (or more) IMEX domains by running IMEX daemons on the set of nodes in a ComputeDomain that requires them.
  These daemons “follow” the workload pods to the nodes where they have been scheduled. 
  Through DRA, these daemons are guaranteed to be fully up and running before the workload pods that triggered their creation are allowed to run.

As the workload ``imex-channel-injection-pod`` referencing the ResourceClaimTemplate for workloads, ``imex-channel-0``, get scheduled, they trigger the DRA Driver to request access to the same IMEX channel on whatever node they land on. 

Once scheduled to a node, the DRA driver adds a Node label for the ComputeDomain to the node where the workload has been scheduled to indicate the node is part of that ComputeDomain.
This label is used as a NodeSelector on the DaemonSet mentioned above to trigger the scheduling of its pods to specific nodes.
Once all workloads running in a ComputeDomain have run to completion, the label gets removed (even if the ComputeDomain itself hasn't been deleted yet).
This allows these nodes to be reused for other ComputeDomains and blocks the workloads from running until the IMEX daemon on that node has been started.

The addition of this Node label triggers the DaemonSet to deploy an IMEX daemon to that node and start running it.


Once all daemons have been fully started, the DRA driver unblocks each worker, injects its IMEX channel into the worker and allows it to start running.


View the Compute Domain resources on your cluster
=================================================


View a ComputeDomain resource.

.. code-block:: console

  $ kubectl describe computedomain/imex-channel-injection

Sample output:

.. literalinclude:: ./manifests/output/compute-domain-channel-injection-crd.txt
  :language: yaml




View IMEX channel creation logs

.. code-block:: console

  $ kubectl logs -n nvidia-dra-driver-gpu -l resource.nvidia.com/computeDomain --tail=-1
  
Sample output:

.. literalinclude:: ./manifests/output/imex-logs.txt
    :language: yaml
  
  



