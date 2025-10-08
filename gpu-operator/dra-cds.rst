.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

##########################
NVIDIA DRA Driver for GPUs
##########################

.. _dra_docs_compute_domains:

********************************************
ComputeDomains: Multi-Node NVLink simplified
********************************************

Motivation
==========

NVIDIA's `GB200 NVL72 <https://www.nvidia.com/en-us/data-center/gb200-nvl72/>`_ and comparable systems are designed specifically around Multi-Node NVLink (`MNNVL <https://docs.nvidia.com/multi-node-nvlink-systems/mnnvl-user-guide/overview.html>`_) to turn a rack of GPU machines -- each with a small number of GPUs -- into a supercomputer with a large number of GPUs communicating at high bandwidth (1.8 TB/s chip-to-chip, and over `130 TB/s cumulative bandwidth <https://docs.nvidia.com/multi-node-nvlink-systems/multi-node-tuning-guide/overview.html#fifth-generation-nvlink>`_ on a GB200 NVL72).

NVIDIA's DRA Driver for GPUs enables MNNVL for Kubernetes workloads by introducing a new concept -- the **ComputeDomain**:
when a workload requests a ComputeDomain, NVIDIA's DRA Driver for GPUs performs all the heavy lifting required for sharing GPU memory **securely** via NVLink among all pods that comprise the workload.

.. note::

   Users may appreciate to know that -- under the hood -- NVIDIA Internode Memory Exchange (`IMEX <https://docs.nvidia.com/multi-node-nvlink-systems/mnnvl-user-guide/overview.html#internode-memory-exchange-service>`_) primitives need to be orchestrated for mapping GPU memory over NVLink *securely*: IMEX provides an access control system to lock down GPU memory even between GPUs on the same NVLink partition.

   A design goal of this DRA driver is to make IMEX, as much as possible, an implementation detail that workload authors and cluster operators do not need to be concerned with: the driver launches and/or reconfigures IMEX daemons and establishes and injects `IMEX channels <https://docs.nvidia.com/multi-node-nvlink-systems/imex-guide/imexchannels.html>`_ into containers as needed.


.. _dra-docs-cd-guarantees:

Guarantees
==========

By design, an individual ComputeDomain guarantees

#. **MNNVL-reachability** between pods that are in the domain.
#. **secure isolation** from other pods that are not in the domain and in a different Kubernetes namespace.

In terms of lifetime, a ComputeDomain is ephemeral: its lifetime is bound to the lifetime of the consuming workload.
In terms of placement, our design choice is that a ComputeDomain follows the workload.

That means: once workload pods get scheduled onto specific nodes, if they request a ComputeDomain, that domain automatically forms around them.
Upon workload completion, all ComputeDomain-associated resources get torn down automatically.

For more detail on the security properties of a ComputeDomain, see `Security <dra-docs-cd-security_>`__.


A deeper dive: related resources
================================

For more background on how ComputeDomains facilitate orchestrating MNNVL workloads on Kubernetes, refer to the `Kubernetes support for GH200 / GB200 <https://docs.google.com/document/d/1PrdDofsPFVJuZvcv-vtlI9n2eAh-YVf_fRQLIVmDwVY/edit?tab=t.0#heading=h.nfp9friarxam>`_ document
and the `Supporting GB200 on Kubernetes <https://docs.google.com/presentation/d/1Xupr8IZVAjs5bNFKJnYaK0LE7QWETnJjkz6KOfLu87E/edit?pli=1&slide=id.g373e0ebfa8e_1_142#slide=id.g373e0ebfa8e_1_142>`_ slide deck.
For an outlook on planned improvements on the ComputeDomain concept, please refer to `this document <https://github.com/NVIDIA/k8s-dra-driver-gpu/releases/tag/v25.3.0-rc.3>`_.

Details about IMEX and its relationship to NVLink may be found in `NVIDIA's IMEX guide <https://docs.nvidia.com/multi-node-nvlink-systems/imex-guide/overview.html>`_, and in `NVIDIA's NVLink guide <https://docs.nvidia.com/multi-node-nvlink-systems/mnnvl-user-guide/overview.html#internode-memory-exchange-service>`_.
CUDA API documentation for `cuMemCreate <https://docs.nvidia.com/cuda/cuda-driver-api/group__CUDA__VA.html#group__CUDA__VA_1g899d69a862bba36449789c64b430dc7c>`_ provides a starting point to learn about how to share GPU memory via IMEX/NVLink.
If you are looking for a higher-level GPU communication library, `NVIDIA's NCCL <https://docs.nvidia.com/multi-node-nvlink-systems/multi-node-tuning-guide/nccl.html>`_ newer than version 2.25 supports MNNVL.


Usage example: a multi-node nvbandwidth test
============================================

This example demonstrates how to run an MNNVL workload across multiple nodes using a ComputeDomain (CD).
As example CUDA workload that performs MNNVL communication, we have picked `nvbandwidth <https://github.com/NVIDIA/nvbandwidth>`_.
Since nvbandwidth requires MPI, below we also install the `Kubeflow MPI Operator <https://github.com/kubeflow/mpi-operator>`_.

**Steps:**

#. Install the MPI Operator.

   .. code-block:: console

      $ kubectl create -f https://github.com/kubeflow/mpi-operator/releases/download/v0.6.0/mpi-operator.yaml

#. Create a test job file called ``nvbandwidth-test-job.yaml``.
   To do that, follow `this part of the CD validation instructions <https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki/Validate-setup-for-ComputeDomain-allocation#create-the-spec-file>`_.
   This example is configured to run across two nodes, using four GPUs per node.
   If you want to use different numbers, please adjust the parameters in the spec according to the table below:

    .. list-table::
      :header-rows: 1

      * - Parameter
        - Value (in example)

      * - ``ComputeDomain.spec.numNodes``
        - Total number of nodes to use in the test (2).

      * - ``MPIJob.spec.slotsPerWorker``
        - Number of GPUs per node to use -- this must match the ``ppr`` number below (4).

      * - ``MPIJob.spec.mpiReplicaSpecs.Worker.replicas``
        - Also set this to the number of nodes (2).

      * - ``mpirun`` command argument ``-ppr:4:node``
        - Set this to the number of GPUs to use per node (4)

      * - ``mpirun`` command argument ``-np`` value
        - Set this to the total number of GPUs in the test (8).

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

#. Verify the nvbandwidth test output.

   .. code-block:: console

      $ kubectl logs --tail=-1 -l job-name=nvbandwidth-test-launcher

   *Example Output*

   .. code-block:: output

      Warning: Permanently added '[nvbandwidth-test-worker-0.nvbandwidth-test.default.svc]:2222' (ECDSA) to the list of known hosts.
      Warning: Permanently added '[nvbandwidth-test-worker-1.nvbandwidth-test.default.svc]:2222' (ECDSA) to the list of known hosts.
      [nvbandwidth-test-worker-0:00025] MCW rank 0 bound to socket 0[core 0[hwt 0]]:

      [...]

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

#. Clean up.

   .. code-block:: console

      $ kubectl delete -f nvbandwidth-test-job.yaml

.. _dra-docs-cd-security:

Security
========

As indicated in `Guarantees <dra-docs-cd-guarantees_>`__, the ComputeDomain primitive provides a *security boundary.* This section helps clarify why that boundary is needed, and how it works.

NVLink enables mapping a remote GPU's memory to "local" GPU's memory (so that it can be read from and written to with regular CUDA API calls).
From a security point of view, that begs the question: can a process running on a GPU in a certain NVLink partition freely read and mutate the memory of other GPUs in the same NVLink partition -- or is there some notion of access control layer inbetween?

IMEX has been introduced specifically as that layer of access control.
It is a means for providing secure isolation between GPUs that are in the same NVLink partition.
With IMEX, every individual GPU memory export/import operation is subject to fine-grained access control.

To understand ComputeDomains, we additionally need to know:

- The ComputeDomain security boundary is implemented with IMEX.
- A job submitted to Kubernetes namespace `A` cannot be part of a ComputeDomain created for namespace `B`.


That is, ComputeDomains (only) promise robust IMEX-based isolation between jobs that are **not** part of the same Kubernetes namespace.
If a bad actor has access to a Kubernetes namespace, they may be able to mutate ComputeDomains (and, as such, IMEX primitives) in that Kubernetes namespace.
That, in turn, may allow for disabling or trivially working around IMEX access control.

With ComputeDomains, the overall ambition is that the security isolation between jobs in different Kubernetes namespaces is strong enough to responsibly allow for multi-tenant environments where compute jobs that conceptually cannot trust each other are "only" separated by the Kubernetes namespace boundary.


Additional remarks
==================

We are planning to extend the documentation for ComputeDomains, with a focus on API reference documentation and known limitations as well as best practices and security.

As we iterate on design and implementation, we are particularly interested and open to receiving your feedback -- please reach out via the issue tracker or discussion forum in the `GitHub repository <https://github.com/NVIDIA/k8s-dra-driver-gpu>`_.
