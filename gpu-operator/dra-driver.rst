.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

##################################################
NVIDIA Dynamic Resource Allocation Driver for GPUs 
##################################################

GPU Operator 25.3.0 and later supports the NVIDIA Dynamic Resource Allocation (DRA) Driver for GPUs.
This is an additional component that can be installed after the NVIDIA GPU Operator which enables allocating compute domains for multi-node workload jobs on NVIDIA HGX GB200 NVL GPUs with Multi-Node NVLink (MNNVL) support.
Before GPU Operator 25.3.0, GPU allocation was handled through NVIDIA k8s-device plugin as the default and only mode of GPU resource management.
While the device-plugin is still the default for GPU resource management in the GPU Operator, the DRA Driver for GPUs provides additional capabilities for managing specialized resources like GPUs.

The DRA Driver for GPUs leverages the Kubernetes Dynamic Resource Allocation (DRA) API to manage GPU resources and allocation on your cluster.
Kuberntes DRA, available as Beta in 1.32, enables you to treat specialize hardward resources, like GPUs, on your cluster similarly to volume provisioning.
Using DRA, you can create templates for your specialized resources that can be references in your workload templates, giving you more flexible and sophisticated resource management capabilities for resources compared to the traditional device-pulgin based approach.

This page provides an overview of the DRA Driver for GPUs, its supported functionality, installing the component with the GPU Operator, and examples of using the DRA Driver for GPUs with supported use cases.

Before continuing, you should be familiar with the components of the `Kubernetes DRA feature <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/>`_.

*******************
Supported Use Cases
*******************

NVIDIA DRA Driver for GPUs v25.3.0 supports the following use cases:

* Full support for Multi-Node NVLink (MNNVL) with NVIDIA HGX GB200 NVL GPUs 
* Technology Preview support for GPU resource allocation.

Multi-Node NVLink Support with NVIDIA HGX GB200 NVL GPUs 
========================================================

NVIDIA HGX GB200 NVL systems are designed specifically to leverage the use Multi-Node NVLinks (MNNVL) to turn a rack of GPU machines, each with a small number of GPUs, into a giant supercomputer with up to 72 GPUs communicating at full NVLink bandwidth.
MNNVL allows you to get the most use out of your available GPUs without any additional latency overhead.

The NVIDIA DRA Driver for GPUs supports Multi-Node NVLink (MNNVL) by introducing a new custom resource called ``ComputeDomain``.
This allows you to define resource requirements for multi-node workloads as a compute domain on your cluster. 
When a workload is created that references a ``ComputeDomain``, the NVIDIA DRA Driver for GPUs will handle establishing an IMEX channel to run multinode workloads across a set of NVIDIA HGX GB200 NVL GPUs.

GPU resource allocation (Technology Preview)
============================================

.. note:: NVIDIA DRA Driverw features are not supported in production environments
          and are not functionally complete.
          Technology Preview features provide early access to upcoming product features,
          enabling customers to test functionality and provide feedback during the development process.
          These releases may not have any documentation, and testing is limited.

Full support for defining and allocating GPU resources using DRA

**************************************
Install the NVIDIA DRA Driver for GPUs
**************************************

The NVIDIA DRA Driver for GPUs is an additional component that can be installed alongside the GPU Operator on your Kubernetes cluster.

Prerequisites
=============

- A Mult-Node NVIDIA HGX GB200 NVL GPUs with at least 2 GPUs Multi-Node NVLink support.

- A Kubernetes v1.32 cluster with the `DynamicResourceAllocation` feature gate enabled and the `resource.k8s.io` API group enabled.

  The following is a sample for enabling the required feature gates and API groups. 
  Refer to the Kubernetes documentation for full details on `enabling DRA on your cluster <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/#enabling-dynamic-resource-allocation>`__.

  .. literalinclude:: ./manifests/input/kubeadm-init-config.yaml
    :language: yaml
    :caption: Sample Kubeadm Init Config with DRA Feature Gates Enabled

- The NVIDIA GPU Operator v25.3.0 or later installed with CDI enabled on all nodes and NVIDIA GPU Driver 565 or later.
  
  A sample Helm install command below includes enabling CDI with ``cdi.enabled=true``.
  Refer to the install documentation for details on `enabling CDI <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#common-chart-customization-options>`__.

  .. code-block:: console

      $ helm install --wait --generate-name \
              -n gpu-operator --create-namespace \
              nvidia/gpu-operator \
              --version=${version} \
              --set cdi.enabled=true

  If you want to install the DRA Driver for GPUs using pre-installed drivers, you must install NVIDIA GPU Driver 565 or later, the corresponding IMEX packages on GPU nodes, and disable the IMEX systemd service before installing the GPU Operator.
  Refer to the documentation on `installing the GPU Operator with pre-installed drivers <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#pre-installed-nvidia-gpu-drivers>`__ for more details.

  NVIDIA DRA Driver for GPUs also requires the NVIDIA Container Toolkit (nvidia-ctk) v1.17.5 or later, which is installed by default with the NVIDIA GPU Operator v25.3.0 and later.
  Refer to the `NVIDIA Container Toolkit documentation <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html>`__ for installation instructions. 

Install the NVIDIA DRA Driver for GPUs with Helm
================================================

#. Add the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
          && helm repo update

#. Install NVIDIA DRA Driver:

   .. code-block:: console

      $ helm install nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
            --version="25.3.0" \
            --create-namespace \
            --namespace nvidia-dra-driver-gpu \
            --set nvidiaDriverRoot=/run/nvidia/driver \
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
       For GPU Operator-managed drivers (recommended), use ``/run/nvidia/driver``.
       For pre-installed drivers, use ``/``.
     - ``/``

   * - ``nvidiaCtkPath``
     - Specifies the path of the NVIDIA Container Toolkit CLI binary (nvidia-ctk) on the host.
       For GPU Operator-installed NVIDIA Container Toolkit (recommended), use ``/usr/local/nvidia/toolkit/nvidia-ctk``.
       For a pre-installed NVIDIA Container Toolkit, use ``/usr/bin/nvidia-ctk``.
     - ``/usr/bin/nvidia-ctk`` 

   * - ``resources.gpus.enabled``
     - Specifies whether to enable the NVIDIA DRA Driver for GPUs to manage GPU resource allocation.
       This feature is in Technolody Preview and only recommended for testing, not production enviroments.
       To use with MNNVL, set to ``false``.
     - ``true``


Verify installation
===================

#. Validate that the NVIDIA DRA Driver for GPUs components are running and in a Ready state.

   .. code-block:: console

      $ kubectl get pod -n nvidia-dra-driver-gpu

   *Example Output*

   .. code-block:: output
    
      NAME                                                           READY   STATUS    RESTARTS   AGE
      nvidia-dra-driver-k8s-dra-driver-controller-67cb99d84b-5q7kj   1/1     Running   0          7m26s
      nvidia-dra-driver-k8s-dra-driver-kubelet-plugin-7kdg9          1/1     Running   0          7m27s
      nvidia-dra-driver-k8s-dra-driver-kubelet-plugin-bd6gn          1/1     Running   0          7m27s
      nvidia-dra-driver-k8s-dra-driver-kubelet-plugin-bzm6p          1/1     Running   0          7m26s
      nvidia-dra-driver-k8s-dra-driver-kubelet-plugin-xjm4p          1/1     Running   0          7m27s


#. Confirm that all GPU nodes are labeled with clique ids.
   The following command used `jq <https://jqlang.org/>`_ to format the output.

   .. code-block:: console

      $ (echo -e "NODE\tLABEL\tCLIQUE"; kubectl get nodes -o json | \
        jq -r '.items[] | [.metadata.name, "nvidia.com/gpu.clique", .metadata.labels["nvidia.com/gpu.clique"]] | @tsv') | \
        column -t

   *Example Output*

   .. code-block:: output
    
      NODE                  LABEL                  CLIQUE
      node1                 nvidia.com/gpu.clique  9277d399-0674-44a9-b64e-d85bb19ce2b0.32766
      node2                 nvidia.com/gpu.clique  9277d399-0674-44a9-b64e-d85bb19ce2b0.32766

The `NVIDIA GPU Feature Discovery <https://github.com/NVIDIA/k8s-device-plugin/tree/main/docs/gpu-feature-discovery>`_ adds a Clique ID to each GPU node. 
This is a unique identifier within an NVLink domain (physically connected GPUs over NVLink) that indicates which GPUs within that domain are physically capable of talking to each other. 

The partitioning of GPUs into a set of cliques is done at the NVSwitch layer, not at the individual node layer. All GPUs on a given node are guaranteed to have the same <ClusterUUID.Clique ID> pair. 

The ClusterUUID is a unique identifier for a given NVLink Domain. 
It can be queried on a GPU by GPU basis via the ``nvidia-smi`` commandline tool. 
All GPUs on a given node are guaranteed to have the same Cluster UUID. 


***************************************
About the ComputeDomain Custom Resource
***************************************

The NVIDIA DRA Driver for GPUs introduces a Kubernetes custom resource named ``ComputeDomain`` which you use to define multi-node resource requirements.
As you deploy multi-node workloads, you can reference the ComputeDomain and the DRA Driver for GPUs will handle automtically provisioning the required resources to allow a set of GPUs to directly read and write each other's memory over a high-bandwidth NVLink.
The ComputeDomain custom resource defines a `Kubernetes DRA ResourceClaimTemplate <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/#api>`_ and ``numNodes`` needed to run your multi-node workload on Multi-Node NVLink (MNNVL) capable GPUs.


.. literalinclude:: ./manifests/input/dra-compute-domain-crd.yaml
   :language: yaml
   :caption: Sample NVIDIA DRA Driver ComputeDomain Custom Resource Manifest

You can then reference the ResourceClaimTemplate in your workload specs as a ``resourceClaims.resourceClaimTemplateName``. 

.. code-block:: yaml
  :emphasize-lines: 12-17

  apiVersion: v1
  kind: Pod
  metadata:
    name: imex-channel-injection
  spec:
    ...
    containers:
    - name: ctr
      image: ubuntu:22.04
      command: ["bash", "-c"]
      args: ["ls -la /dev/nvidia-caps-imex-channels; trap 'exit 0' TERM; sleep 9999 & wait"]
      resources:
        claims:
        - name: imex-channel-0
    resourceClaims:
    - name: imex-channel-0
      resourceClaimTemplateName: imex-channel-0

If a subset of the nodes associated with a ComputeDomain are capable of communicating over MNNVL, the NVIDIA DRA Driver for GPUs will set up a one-off IMEX domain to allow GPUs to communicate over their multi-node NVLink connections. 
Multiple IMEX domains will be created as necessary depending on the number and availability of nodes allocated to the ComputeDomain. 

A multi-node workload should run in its own compute domain.
When you create the compute domain you can specify how many nodes you want to be a part of it in the ``numNodes`` field. 
This can be any number, less than a rack, equal to a rack, more than a rack. 
The compute domain controller is able to create 0-or-more IMEX domains depending on where the workers of a multi-node job that reference the compute domain actually land in your cluster

When a worker for a multi-node job that references a ComputeDomain's ResourceClaimTemplate is scheduled on your cluster, the DRA Driver for GPUs triggers an IMEX daemon to started on the node the worker lands on and will block the worker from running until the compute domain is ready.
Once the number of IMEX daemons running equals the number of nodes specified in the compute domain, the DRA Driver for GPUs will mark the compute domain as ready and will release the worker pods themselves, allowing them to start running. 
Since the compute domain is per workload, only one channel is needed to link all of the worker pods of the workload. 

The value of the <cluster-uuid, clique-id> tuple associated with the node where a workload lands determines which IMEX domain it will be a part of. 
Nodes with the same <cluster-uuid, clique-id> values will be part of the same IMEX domain and will be able to communicate over MNNVL with each other. 
Nodes with different <cluster-uuid, clique-id> values will be associated with different IMEX domains and will not be able to communicate over MNNVL with each other. 
Nodes without a <cluster-uuid, clique-id> setting at all are still allowed, but no IMEX daemon will be started on such nodes and no MNNVL communication with them is possible from any other nodes in the compute domain. 
The nodes are still be able to communicate over IB or Ethernet.

Once all workloads running in a ComputeDomain have run to completion, the label gets removed even if the ComputeDomain itself hasn't been deleted yet.
This allows these nodes to be reused for other ComputeDomains.

Configuration Options for ComputeDomain
=======================================

The following table describes some of the fields in the ComputeDomain custom resource.

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
     - Specifies the number of nodes in the ComputeDomain.
     - None

Node and Pod Affinity Strategies
=================================

For the DRA Driver for GPUs, a ComputeDomain means running workloads across a group of compute nodes. 
This means even if some nodes are not MNNVL capable, they can still be part of the same ComputeDomain.
You must apply NodeAffinity and PodAffinity rules to your nodes and pods to make sure your workloads run on MNNVL capable nodes.

For example you could set PodAffinity with a required topologyKey set to ``nvidia.com/gpu.clique`` when you require all workloads deployed into the same NVLink domain, but don't care which one. 
Or use a preferred topologyKey set to ``nvidia.com/gpu.clique`` for workloads to span MNNVL domains but want them packed as tightly as possible. 

Example: Create a ComputeDomain and Run a Workload
==================================================

#. Create a file like ``imex-channel-injection.yaml`` below.

   .. code-block:: yaml

    ---
    apiVersion: resource.nvidia.com/v1beta1
    kind: ComputeDomain
    metadata:
      name: imex-channel-injection
    spec:
      numNodes: 1
      channel:
        resourceClaimTemplate:
          name: imex-channel-0
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: imex-channel-injection
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: nvidia.com/gpu.clique
                operator: Exists
      containers:
      - name: ctr
        image: ubuntu:22.04
        command: ["bash", "-c"]
        args: ["ls -la /dev/nvidia-caps-imex-channels; trap 'exit 0' TERM; sleep 9999 & wait"]
        resources:
          claims:
          - name: imex-channel-0
      resourceClaims:
      - name: imex-channel-0
        resourceClaimTemplateName: imex-channel-0

#. Apply the manifest.

   .. code-block:: console

     $ kubectl apply -f imex-channel-injection.yaml


#. Optional: View the ``imex-channel-injection`` pod.

   .. code-block:: console

      $ kubectl get pods

   *Example Output*

   .. code-block:: output

      NAME                     READY   STATUS    RESTARTS   AGE
      imex-channel-injection   1/1     Running   0          3s

#. Optional: View logs for the ``imex-channel-injection`` pod, where the IMEX channel was injected.

   .. code-block:: console

      $ kubectl logs imex-channel-injection

   *Example Output*

   .. code-block:: output

      total 0
      drwxr-xr-x 2 root root     60 Feb 19 10:43 .
      drwxr-xr-x 6 root root    380 Feb 19 10:43 ..
      crw-rw-rw- 1 root root 507, 0 Feb 19 10:43 channel0

#. Optional: View the ComputeDomain pod.

   .. code-block:: console

      $ kubectl get pods -n nvidia-dra-driver-gpu -l resource.nvidia.com/computeDomain

   *Example Output*

   .. code-block:: output

      NAME                                 READY   STATUS    RESTARTS   AGE
      imex-channel-injection-6k9sx-ffgpf   1/1     Running   0          3s

#. Optional: View IMEX channel creation logs.

   .. code-block:: console

      $ kubectl logs -n nvidia-dra-driver-gpu -l resource.nvidia.com/computeDomain --tail=-1

   *Example Output*

   .. code-block:: output 

      /etc/nvidia-imex/nodes_config.cfg:
      10.115.131.8
      IMEX Log initializing at: 3/27/2025 15:47:10.092
      [Mar 27 2025 15:47:10] [INFO] [tid 39] IMEX version 570.124.06 is running with the following configuration options

      [Mar 27 2025 15:47:10] [INFO] [tid 39] Logging level = 4

      [Mar 27 2025 15:47:10] [INFO] [tid 39] Logging file name/path = /var/log/nvidia-imex.log

      [Mar 27 2025 15:47:10] [INFO] [tid 39] Append to log file = 0

      [Mar 27 2025 15:47:10] [INFO] [tid 39] Max Log file size = 1024 (MBs)

      [Mar 27 2025 15:47:10] [INFO] [tid 39] Use Syslog file = 0

      [Mar 27 2025 15:47:10] [INFO] [tid 39] IMEX Library communication bind interface =

      [Mar 27 2025 15:47:10] [INFO] [tid 39] IMEX library communication bind port = 50000

      [Mar 27 2025 15:47:10] [INFO] [tid 39] Identified this node as ID 0, using bind IP of '10.115.131.8', and network interface of enP5p9s0
      [Mar 27 2025 15:47:10] [INFO] [tid 39] nvidia-imex persistence file /var/run/nvidia-imex/persist.dat does not exist.  Assuming no previous importers.
      [Mar 27 2025 15:47:10] [INFO] [tid 39] NvGpu Library version matched with GPU Driver version
      [Mar 27 2025 15:47:10] [INFO] [tid 63] Started processing of incoming messages.
      [Mar 27 2025 15:47:10] [INFO] [tid 64] Started processing of incoming messages.
      [Mar 27 2025 15:47:10] [INFO] [tid 65] Started processing of incoming messages.
      [Mar 27 2025 15:47:10] [INFO] [tid 39] Creating gRPC channels to all peers (nPeers = 1).
      [Mar 27 2025 15:47:10] [INFO] [tid 66] Started processing of incoming messages.
      [Mar 27 2025 15:47:10] [INFO] [tid 39] IMEX_WAIT_FOR_QUORUM != FULL, continuing initialization without waiting for connections to all nodes.
      [Mar 27 2025 15:47:10] [INFO] [tid 67] Connection established to node 0 with ip address 10.115.131.8. Number of times connected: 1
      [Mar 27 2025 15:47:10] [INFO] [tid 39] GPU event successfully subscribed

  
#. Delete ``imex-channel-injection`` example.

   .. code-block:: console

      $ kubectl delete -f imex-channel-injection.yaml

   *Example Output*

   .. code-block:: output

      computedomain.resource.nvidia.com "imex-channel-injection" deleted
      pod "imex-channel-injection" deleted


******************************************************************
Run a Multi-node nvbandwidth Test Requiring IMEX Channels with MPI
******************************************************************

This example demonstrates how to run a workload across multiple nodes using a ComputeDomain. 
The nvbandwidth test will measure the bandwidth between GPUs across different nodes using IMEX channels, helping you verify that your MNNVL setup is working correctly.

**Example notes:** 

- This example uses `Kubeflow MPI Operator <https://www.kubeflow.org/docs/components/trainer/legacy-v1/user-guides/mpi/#installationr>`__.

- This example is configured for a 2 node cluster with 4 GPUs per node.

  If you are using a cluster with a different number of nodes and GPUs per node, you must adjust the following parameters in the sample files:


.. list-table::
   :widths: 15 55 30
   :header-rows: 1

   * - Parameter to update
     - Description
     - Value in example

   * - ``ComputeDomain.spec.numNodes``
     - Total number of nodes in the cluster
     - 2

   * - ``MPIJob.spec.slotsPerWorker``
     - Number of GPUs per node, this should match the ppr number
     - 4

   * - ``MPIJob.spec.mpiReplicaSpecs.Worker.replicas``
     - Number of worker nodes
     - 2

   * - ``mpirun`` command argument ``-ppr:4:node``

     -
       * Number of GPUs per node as the process-per-resource number
     - 4

   * - ``mpirun`` command argument ``-np`` value
     - Total processes to be the number of GPU per node * the number of nodes in the cluster
     - 8


**Example Steps:** 

#. Install Kubeflow MPI Operator.

   .. code-block:: console

      $ kubectl create -f https://github.com/kubeflow/mpi-operator/releases/download/v0.6.0/mpi-operator.yaml

#. Create a nvbandwidth test job file called ``nvbandwidth-test-job.yaml``.

   .. code-block:: yaml

      ---
      apiVersion: resource.nvidia.com/v1beta1
      kind: ComputeDomain
      metadata:
        name: nvbandwidth-test-compute-domain
      spec:
        # Update numNodes to match the total number of nodes in your cluster
        numNodes: 2
        channel:
          resourceClaimTemplate:
            name: nvbandwidth-test-compute-domain-channel

      ---
      apiVersion: kubeflow.org/v2beta1
      kind: MPIJob
      metadata:
        name: nvbandwidth-test
      spec:
        # Update slotsPerWorker to match the number of GPUs per node
        slotsPerWorker: 4
        launcherCreationPolicy: WaitForWorkersReady
        runPolicy:
          cleanPodPolicy: Running
        sshAuthMountPath: /home/mpiuser/.ssh
        mpiReplicaSpecs:
          Launcher:
            replicas: 1
            template:
              metadata:
                labels:
                  nvbandwidth-test-replica: mpi-launcher
              spec:
                affinity:
                  nodeAffinity:
                    requiredDuringSchedulingIgnoredDuringExecution:
                      nodeSelectorTerms:
                      - matchExpressions:
                        - key: node-role.kubernetes.io/control-plane
                          operator: Exists
                containers:
                - image: ghcr.io/nvidia/k8s-samples:nvbandwidth-v0.7-8d103163
                  name: mpi-launcher
                  securityContext:
                    runAsUser: 1000
                  command:
                  - mpirun
                  args:
                  - --bind-to
                  - core
                  - --map-by
                  # Update the number (4) to match the number of GPUs per node
                  - ppr:4:node
                  - -np
                  # Update the number (8) to match the total number of GPUs in the cluster, this example has 2 nodes * 4 GPUs per node
                  - "8"
                  - --report-bindings
                  - -q
                  - nvbandwidth
                  - -t
                  - multinode_device_to_device_memcpy_read_ce
          Worker:
            # Update replicas to match the number of worker nodes
            replicas: 2
            template:
              metadata:
                labels:
                  nvbandwidth-test-replica: mpi-worker
              spec:
                affinity:
                  podAffinity:
                    requiredDuringSchedulingIgnoredDuringExecution:
                    - labelSelector:
                        matchExpressions:
                        - key: nvbandwidth-test-replica
                          operator: In
                          values:
                          - mpi-worker
                      topologyKey: nvidia.com/gpu.clique
                containers:
                - image: ghcr.io/nvidia/k8s-samples:nvbandwidth-v0.7-8d103163
                  name: mpi-worker
                  securityContext:
                    runAsUser: 1000
                  env:
                  command:
                  - /usr/sbin/sshd
                  args:
                  - -De
                  - -f
                  - /home/mpiuser/.sshd_config
                  resources:
                    limits:
                      nvidia.com/gpu: 4
                    claims:
                    - name: compute-domain-channel
                resourceClaims:
                - name: compute-domain-channel
                  resourceClaimTemplateName: nvbandwidth-test-compute-domain-channel

#. Apply the manifest.

   .. code-block:: console

      $ kubectl apply -f nvbandwidth-test-job.yaml

   *Example Output*

   .. code-block:: output

      computedomain.resource.nvidia.com/nvbandwidth-test-compute-domain configured
      mpijob.kubeflow.org/nvbandwidth-test configured

#. Verify that the nvbandwidth pods were created.

   .. code-block:: console

      $ kubectl get pods

   *Example Output*

   .. code-block:: output

      NAME                              READY   STATUS    RESTARTS   AGE
      nvbandwidth-test-launcher-lzv84   1/1     Running   0          8s
      nvbandwidth-test-worker-0         1/1     Running   0          15s
      nvbandwidth-test-worker-1         1/1     Running   0          15s
  

#. Verify that the ComputeDomain pods were created for each node. 

   .. code-block:: console

      $ kubectl get pods -n nvidia-dra-driver-gpu -l resource.nvidia.com/computeDomain

   *Example Output*

   .. code-block:: output
    
      NAME                                          READY   STATUS    RESTARTS   AGE
      nvbandwidth-test-compute-domain-ht24d-9jhmj   1/1     Running   0          20s
      nvbandwidth-test-compute-domain-ht24d-rcn2c   1/1     Running   0          20s

#. Verify the nvbandwidth test results.

   .. code-block:: console

      $ kubectl logs --tail=-1 -l job-name=nvbandwidth-test-launcher

   *Example Output*

   .. code-block:: output

      Warning: Permanently added '[nvbandwidth-test-worker-0.nvbandwidth-test.default.svc]:2222' (ECDSA) to the list of known hosts.
      Warning: Permanently added '[nvbandwidth-test-worker-1.nvbandwidth-test.default.svc]:2222' (ECDSA) to the list of known hosts.
      [nvbandwidth-test-worker-0:00025] MCW rank 0 bound to socket 0[core 0[hwt 0]]: [B/././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.][./././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.]
      [nvbandwidth-test-worker-0:00025] MCW rank 1 bound to socket 0[core 1[hwt 0]]: [./B/./././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.][./././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.]
      [nvbandwidth-test-worker-0:00025] MCW rank 2 bound to socket 0[core 2[hwt 0]]: [././B/././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.][./././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.]
      [nvbandwidth-test-worker-0:00025] MCW rank 3 bound to socket 0[core 3[hwt 0]]: [./././B/./././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.][./././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.]
      [nvbandwidth-test-worker-1:00025] MCW rank 4 bound to socket 0[core 0[hwt 0]]: [B/././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.][./././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.]
      [nvbandwidth-test-worker-1:00025] MCW rank 5 bound to socket 0[core 1[hwt 0]]: [./B/./././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.][./././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.]
      [nvbandwidth-test-worker-1:00025] MCW rank 6 bound to socket 0[core 2[hwt 0]]: [././B/././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.][./././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.]
      [nvbandwidth-test-worker-1:00025] MCW rank 7 bound to socket 0[core 3[hwt 0]]: [./././B/./././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.][./././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././././.]
      nvbandwidth Version: v0.7
      Built from Git version: v0.7

      MPI version: Open MPI v4.1.4, package: Debian OpenMPI, ident: 4.1.4, repo rev: v4.1.4, May 26, 2022
      CUDA Runtime Version: 12080
      CUDA Driver Version: 12080
      Driver Version: 570.124.06

      Process 0 (nvbandwidth-test-worker-0): device 0: HGX GB200 (00000008:01:00)
      Process 1 (nvbandwidth-test-worker-0): device 1: HGX GB200 (00000009:01:00)
      Process 2 (nvbandwidth-test-worker-0): device 2: HGX GB200 (00000018:01:00)
      Process 3 (nvbandwidth-test-worker-0): device 3: HGX GB200 (00000019:01:00)
      Process 4 (nvbandwidth-test-worker-1): device 0: HGX GB200 (00000008:01:00)
      Process 5 (nvbandwidth-test-worker-1): device 1: HGX GB200 (00000009:01:00)
      Process 6 (nvbandwidth-test-worker-1): device 2: HGX GB200 (00000018:01:00)
      Process 7 (nvbandwidth-test-worker-1): device 3: HGX GB200 (00000019:01:00)

      Running multinode_device_to_device_memcpy_read_ce.
      memcpy CE GPU(row) -> GPU(column) bandwidth (GB/s)
                0         1         2         3         4         5         6         7
      0       N/A    798.02    798.25    798.02    798.02    797.88    797.73    797.95
      1    798.10       N/A    797.80    798.02    798.02    798.25    797.88    798.02
      2    797.95    797.95       N/A    797.73    797.80    797.95    797.95    797.65
      3    798.10    798.02    797.95       N/A    798.02    798.10    797.88    797.73
      4    797.80    798.02    798.02    798.02       N/A    797.95    797.80    798.02
      5    797.80    797.95    798.10    798.10    797.95       N/A    797.95    797.88
      6    797.73    797.95    798.10    798.02    797.95    797.88       N/A    797.80
      7    797.88    798.02    797.95    798.02    797.88    797.95    798.02       N/A

      SUM multinode_device_to_device_memcpy_read_ce 44685.29

      NOTE: The reported results may not reflect the full capabilities of the platform.

#. Delete test.

   .. code-block:: console

      $ kubectl delete -f nvbandwidth-test-job.yaml

   *Example Output*

   .. code-block:: output

      computedomain.resource.nvidia.com "nvbandwidth-test-compute-domain" deleted
      mpijob.kubeflow.org "nvbandwidth-test" deleted




