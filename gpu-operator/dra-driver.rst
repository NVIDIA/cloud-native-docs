.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

#############################################################
Multi-Node NVLink support with the NVIDIA DRA Driver for GPUs 
#############################################################

The NVIDIA DRA Driver for GPUs is an additional component you can install alongside the GPU Operator that enables you to use the Kubernetes Dynamic Resource Allocation (DRA) feature to support Multi-Node NVLink in NVIDIA HGX GB200 NVL GPUs.
This page details more information about installing the DRA Driver for GPUs and examples of deploying workloads utilizing Multi-Node NVLink with NVIDIA HGX GB200 NVL systems.

NVIDIA HGX GB200 NVL systems are designed specifically to leverage the use of IMEX channels to turn a rack of GPU machines, each with a small number of GPUs, into a giant supercomputer with up to 72 GPUs communicating at full NVLink bandwidth.
This allows you to get the most use out of your available GPUs without any additional latency burdens.

For more information about Kubernetes Dynamic Resource Allocation (DRA), refer to the `Kubernetes DRA documentation <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/>`_.


************************************
About the NVIDIA DRA Driver for GPUs
************************************

The NVIDIA DRA Driver for GPUs leverages the Kubernetes Dynamic Resource Allocation (DRA) API to support NVIDIA Multi-Node NVLink available in NVIDIA HGX GB200 NVL GPUs.
The NVIDIA DRA Driver for GPUs introduces a Kubernetes custom resource named ComputeDomain where you can define your resource templates, and then reference the templates within your workload definitions. 

A ComputeDomain creates and manages an IMEX channel, a construct that allows a set of GPUs to directly read and write each other's memory over a high-bandwidth NVLink. 
The NVLink connection may either be directly between GPUs on the same node or between GPUs on separate nodes connected by an NVSwitch. 
Once a ComputeDomain has been established for a set of GPUs, through an IMEX channel, the GPUs are free to read and write each other's memory via extensions to the CUDA memory call APIs.

Kubernetes DRA, available as beta from Kubernetes v1.32, is an API for requesting and sharing resources between pods and containers inside a pod. 
This feature treats specialized hardware as a definable and reusable object and provides the necessary primitives to support cross-node resources such as IMEX channels. 
A ComputeDomain uses DRA features to define IMEX channel resources that can be managed by Kubernetes.

Refer to the `Kubernetes DRA documentation`_ for details on this feature. 

**************************************
Install the NVIDIA DRA Driver for GPUs
**************************************

The NVIDIA DRA Driver for GPUs is an additional component that can be installed alongside the GPU Operator on your Kubernetescluster.

Prerequisites
=============

- A Mult-iNode NVIDIA HGX GB200 NVL GPUs with at least 2 GPUs Multi-Node NVLink support.

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
     - Specifies the path of The NVIDIA Container Toolkit CLI binary (nvidia-ctk) on the host.
       For GPU Operator-installed NVIDIA Container Toolkit (recommended), use ``/usr/local/nvidia/toolkit/nvidia-ctk``.
       For a pre-installed NVIDIA Container Toolkit, use ``/usr/bin/nvidia-ctk``.
     - ``/usr/bin/nvidia-ctk`` 

   * - ``resources.gpus.enabled``
     - Specifies whether to enable the NVIDIA DRA Driver for GPUs to manage GPU resource allocation.
       This feature is not yet supported and you must set to ``false``.
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
This is an unique identifier within an NVLink domain (physically connected GPUs over NVLink) that indicates which GPUs within that domain are physically capable of talking to each other. 
The partitioning of GPUs into a set of cliques is done at the NVSwitch layer, not at the individual node layer. All GPUs on a given node are guaranteed to have the same <ClusterUUID.Clique ID> pair. 

The ClusterUUID is a unique identifier for a given NVLink Domain. 
It can be queried on a GPU by GPU basis via the ``nvidia-smi`` commandline tool. 
All GPUs on a given node are guaranteed to have the same Cluster UUID. 

***************************************
About the ComputeDomain Custom Resource
***************************************

The NVIDIA DRA Driver for GPUs introduces a new custom resource called ComputeDomain, which allows you to define resource templates for your workloads. 

With the v25.3.0 release, a ComputeDomain supports defining a resource template for a Multi-Node NVLink (MNNVL) using IMEX channels by defining a `Kubernetes DRA ResourceClaimTemplate <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/#api>`_.

If a subset of the nodes associated with a ComputeDomain are capable of communicating over MNNVL, the NVIDIA DRA Driver for GPUs will set up a one-off IMEX domain to allow GPUs to communicate over their multi-node NVLink connections. Multiple IMEX domains will be created as necessary depending on the number and availability of nodes allocated to the ComputeDomain. 

You can then reference the ResourceClaimTemplate in your workload specs as a ``resourceClaims.resourceClaimTemplateName``. 

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
     - Specifies the number of nodes in the ComputeDomain.
     - None


When you create a CustomDomain resource and configure a pod to reference it, the NVIDIA DRA Driver for GPUs will create the following resources on your cluster:

- A ComputeDomain resource. 

- A ResourceClaimTemplate to use for workload pods.

  This is used to request access to a unique IMEX channel on a set of compute nodes.
  Each worker of a multi-node job should reference this ResourceClaimTemplate to ensure that they have access to the same IMEX channel inside the appropriate ComputeDomain. 

- ResourceClaimTemplate for the DaemonSet.

  This is used to request access to a device that injects ComputeDomain-specific settings for an imex-daemon to run with (config.cfg, nodes_config.cfg, etc.). 
  Each worker of the DaemonSet mentioned below references this ResourceClaimTemplate to ensure they start up IMEX daemons associated with the appropriate ComputeDomain.

- A DaemonSet. 

  Depending on your workload requirements, this DaemonSet forms one (or more) IMEX domains by running IMEX daemons on the set of nodes in a ComputeDomain that requires them. 
  When your workload is deployed, these daemons "follow" the workload pods to the nodes where they have been scheduled. 
  Through DRA, these daemons are guaranteed to be fully up and running before the workload pods that triggered their creation are allowed to run.

As workload pods that reference a CustomDomain ResourceClaimTemplate get scheduled, they trigger the NVIDIA DRA Driver for GPUs to request access to the same IMEX channel on whatever node they land on. 

Once scheduled to a node, the NVIDIA DRA Driver for GPUs adds a Node label for the ComputeDomain to the node where the workload has been scheduled to indicate the node is part of that ComputeDomain.
This label is used as a NodeSelector on the DaemonSet mentioned above to trigger the scheduling of its pods to specific nodes.

The addition of this Node label triggers the DaemonSet to deploy an IMEX daemon to that node and start running it.

When all daemons have been fully started, the NVIDIA DRA Driver for GPUs unblocks each worker, injects its IMEX channel into the worker and allows it to start running.

Once all workloads running in a ComputeDomain have run to completion, the label gets removed even if the ComputeDomain itself hasn't been deleted yet.
This allows these nodes to be reused for other ComputeDomains.

Node and Pod Affinity Strategies
=================================

A ComputeDomain isn't strictly about MNNVL—it's about running workloads across a group of compute nodes. 
This means even if some nodes are not MNNVL capable, they can still be part of the same ComputeDomain.
You must apply NodeAffinity and PodAffinity rules to make sure your workloads run on MNNVL capable nodes.

For example you could set PodAffinity with a required topologyKey set to ``nvidia.com/gpu.clique`` when you require all workloads deployed into the same NVLink domain, but don't care which one. 
Or use a preferred topologyKey set to ``nvidia.com/gpu.clique`` for workloads to span MNNVL domains but want them packed as tightly as possible. 

Create a CustomDomain and run a workload
========================================

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

The following sample files use the following:

- `Kubeflow MPI Operator <https://www.kubeflow.org/docs/components/trainer/legacy-v1/user-guides/mpi/#installationr>`__  
- A 2 node cluster with all nodes capable of running GPU workloads and meets [NVIDIA DRA Driver for GPUs prerequisites](#prerequisites)


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
                  - ppr:4:node
                  - -np
                  - "8"
                  - --report-bindings
                  - -q
                  - nvbandwidth
                  - -t
                  - multinode_device_to_device_memcpy_read_ce
          Worker:
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




