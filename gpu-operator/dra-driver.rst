.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

##########################
NVIDIA DRA Driver for GPUs
##########################

************
Introduction
************

With NVIDIA's DRA Driver for GPUs, your Kubernetes workload can allocate and consume the following two resource types:

* **ComputeDomains**: for robust and secure Multi-Node NVLink (MNNVL) for NVIDIA GB200 and similar systems. Fully supported.
* **GPUs**: for controlled sharing and reconfiguration of GPUs. This is a modern alternative to traditional device allocation via the `NVIDIA device plugin <https://github.com/NVIDIA/k8s-device-plugin>`_. This part of the driver is a Technology Preview and not yet fully supported.


A primer on DRA
===============

Dynamic Resource Allocation (DRA) is a novel concept in Kubernetes for flexibly requesting, configuring, and sharing specialized devices like GPUs.
It puts resource configuration and scheduling into the hands of device vendors (via drivers like this one) and provides

- a clean way to allocate cross-machine resources in Kubernetes (this driver leverages that for providing NVLink connectivity across pods running on different nodes).
- mechanisms to explicitly share, partition, and reconfigure devices on-the-fly based on user requests.

To make best use of use NVIDIA's DRA Driver for GPUs, we recommend for you to become familiar with DRA by working through the `official DRA documentation <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/>`_.


The two parts of this driver
============================

NVIDIA's DRA Driver for GPUs is comprised of two subsystems that are largely independent of each other: one manages GPUs, and the other one manages ComputeDomains.

Below, you can find instructions for how to install both parts or just one of them.
Additionally, we have prepared two separate documentation chapters, providing more in-depth information for each of the two subsystems:

- `Docs for GPU support in NVIDIA's DRA Driver for GPUs <foo1>`_
- `Docs for ComputeDomain support in NVIDIA's DRA Driver for GPUs <foo2>`_


************
Installation
************

Prerequisites
=============

- Kubernetes v1.32 or newer.
- DRA and corresponding API groups must be enabled (`see Kubernetes docs <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/#enabling-dynamic-resource-allocation>`_).
- GPU Driver 565 or later.
- NVIDIA's GPU Operator v25.3.0 or later, installed with CDI enabled (use the ``--set cdi.enabled=true`` commandline argument during ``helm install``). For reference, please refer to the GPU Operator `installation documentation <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#common-chart-customization-options>`__.

..
  For convenience, the following example shows how to enable CDI upon GPU Operator installation:
  .. code-block:: console
      $ helm install --wait --generate-name \
          -n gpu-operator --create-namespace \
          nvidia/gpu-operator \
          --version=${version} \
          --set cdi.enabled=true

.. note::

  If you want to use ComputeDomains and a pre-installed NVIDIA GPU Driver:

  - Make sure to have the corresponding ``nvidia-imex-*`` packages installed.
  - Disable the IMEX systemd service before installing the GPU Operator.
  - Refer to the `docs on installing the GPU Operator with a pre-installed GPU driver <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#pre-installed-nvidia-gpu-drivers>`__.


Configure and Helm-install the DRA driver
=========================================

#. Add the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
          && helm repo update

#. Install the driver, providing install-time configuration parameters. Example:

   .. code-block:: console

      $ helm install nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
            --version="25.3.0" \
            --create-namespace \
            --namespace nvidia-dra-driver-gpu \
            --set nvidiaDriverRoot=/run/nvidia/driver \
            --set resources.gpus.enabled=false

All install-time configuration parameters can be listed by running ``helm show values nvidia/nvidia-dra-driver-gpu``.

.. note::

  - A common mode of operation for now is to enable only the ComputeDomain subsystem (to have GPUs allocated using the traditional device plugin). The example above achieves that by setting ``resources.gpus.enabled=false``.
  - Setting  ``nvidiaDriverRoot=/run/nvidia/driver`` above expects a GPU Operator-provided GPU driver. That configuration parameter must be changed in case the GPU driver is installed straight on the host (typically at ``/``, which is the default value for ``nvidiaDriverRoot``).
  - In a future release, NVIDIA's DRA Driver for GPUs will be bundled with the NVIDIA GPU Operator (and does not need to be installed as a separate Helm chart anymore).


Validate Installation
=====================

We recommend to perform validation steps to confirm that your setup works as expected.
To that end, we have prepared separate documentation:

- `Testing ComputeDomain allocation <https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki/Validate-setup-for-ComputeDomain-allocation>`_
- [TODO] Testing GPU allocation


**************
ComputeDomains
**************

Overview
========

Motivation
**********

NVIDIA's `GB200 NVL72 <https://www.nvidia.com/en-us/data-center/gb200-nvl72/>`_ and comparable systems are designed specifically around Multi-Node NVLink (MNNVL) to turn a rack of GPU machines -- each with a small number of GPUs -- into a giant supercomputer with a large number of GPUs communicating all-to-all at full NVLink bandwidth.

NVIDIA's DRA Driver for GPUs enables MNNVL for Kubernetes workloads by introducing a new concept: the ``ComputeDomain``.

When workload is created that references a specific ``ComputeDomain``, NVIDIA's DRA Driver for GPUs orchestrates the underlying primitives required for establishing a shared NVLink communication channel among all pods that comprise the workload.

Advanced users may appreciate to know that -- under the hood -- NVIDIA's DRA Driver for GPUs launches and/or reconfigures IMEX daemons as needed, and establishes and injects a shared  IMEX channel into the relevant containers of the workload.
A design goal of this DRA driver is to make IMEX be, as much as possible, an implementation detail that workload authors and cluster operators do not need to be concerned with.

Guarantees
**********

At a high level, an individual ComputeDomain guarantees

- MNNVL-**reachability** between pods that are in the ``ComputeDomain``.
- secure **isolation** from other pods that are not in the ``ComputeDomain``.

In terms of lifetime, a ``ComputeDomain`` is ephemeral: its lifetime is bound to the lifetime of the consuming workload.
In terms of placement, a design choice is that a ``ComputeDomain`` follows the workload.

That means: only once workload pods get scheduled onto specific nodes, the ``ComputeDomain`` they request automatically forms around them.
Upon workload completion, all ``ComputeDomain``-associated resources get torn down automatically.

A deeper dive: related resources
********************************

For more background on how ``ComputeDomain``\s facilitate orchestrating MNNVL workloads on Kubernetes (and on NVIDIA GB200 systems in particular), see this doc and `this slide deck <https://docs.google.com/presentation/d/1Xupr8IZVAjs5bNFKJnYaK0LE7QWETnJjkz6KOfLu87E/edit?pli=1&slide=id.g28ac369118f_0_1647#slide=id.g28ac369118f_0_1647>`_.

For an outlook on improvements on the ``ComputeDomain`` concept that we have planned to release in the future, please refer to `this document <https://github.com/NVIDIA/k8s-dra-driver-gpu/releases/tag/v25.3.0-rc.3>`_.

Details about IMEX and its relationship to NVLink may be found in `NVIDIA's IMEX guide <https://docs.nvidia.com/multi-node-nvlink-systems/imex-guide/overview.html>`_.

CUDA API documentation for `cuMemCreate <https://docs.nvidia.com/cuda/cuda-driver-api/group__CUDA__VA.html#group__CUDA__VA_1g899d69a862bba36449789c64b430dc7c>`_ provides a starting point to learn about exporting GPU memory though IMEX/NVLink.

If you are looking for a higher-level communication library, `NVIDIA's NCCL <https://docs.nvidia.com/multi-node-nvlink-systems/multi-node-tuning-guide/nccl.html>_` newer than version 2.25 supports MNNVL.


Usage
=====

TODO: api fields, parameters

Example: Run a multi-node nvbandwidth test
******************************************

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





****
GPUs
****


.. note::
  The GPU allocation features of the NVIDIA DRA Driver for GPUs are in **Technology Preview**.
  They are not supported in production environments and are not functionally complete.
  Technology Preview features provide early access to upcoming product features, enabling customers to test functionality and provide feedback during the development process.
  These releases may not have full documentation, and testing is limited.

Dynamic resource allocation was imlpemented in Kubernetes to allow users to more esily define and request specialized reousrces for their workloads

Before DRA, requesting GPUs and other specilized resources handled by a device plugin, like the [NVIDIA Kubernetes Device plugin](https://github.com/NVIDIA/k8s-device-plugin).

The device-plugin along with a set of node labels added by GPU Feature Discovery, enabled users to allocate the desired number of GPUs on a node with desired type of GPUs.

The improvements made with Kuberntes DRA introduce an API that allows you to define resource claim templates for your GPUs resources that can be referenced in your workloads as a resource claim and allocated at deploy time.
This new API allows you to move away from the limited  "countable" API  provided by the previous implementation using device-plugins, to something much more flexible in terms of controlling which resources are consumed and where.

Full support and implementation of the DRA using the DRA Driver for GPUs is not yet available.
The current release offers a Technology Preview of DRA support with the GPU Operator.

