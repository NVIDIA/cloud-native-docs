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

To make best use of NVIDIA's DRA Driver for GPUs, we recommend for you to become familiar with DRA by working through the `official DRA documentation <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/>`_.


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

Motivation
==========

NVIDIA's `GB200 NVL72 <https://www.nvidia.com/en-us/data-center/gb200-nvl72/>`_ and comparable systems are designed specifically around Multi-Node NVLink (MNNVL) to turn a rack of GPU machines -- each with a small number of GPUs -- into a giant supercomputer with a large number of GPUs communicating all-to-all at full NVLink bandwidth.

NVIDIA's DRA Driver for GPUs enables MNNVL for Kubernetes workloads by introducing a new concept: the ``ComputeDomain``.

When workload is created that references a specific ``ComputeDomain``, NVIDIA's DRA Driver for GPUs orchestrates the underlying primitives required for establishing a shared NVLink communication channel among all pods that comprise the workload.

Advanced users may appreciate to know that -- under the hood -- NVIDIA's DRA Driver for GPUs launches and/or reconfigures IMEX daemons as needed, and establishes and injects a shared  IMEX channel into the relevant containers of the workload.
A design goal of this DRA driver is to make IMEX be, as much as possible, an implementation detail that workload authors and cluster operators do not need to be concerned with.

Guarantees
==========

At a high level, an individual ComputeDomain guarantees

- MNNVL-**reachability** between pods that are in the ``ComputeDomain``.
- secure **isolation** from other pods that are not in the ``ComputeDomain``.

In terms of lifetime, a ``ComputeDomain`` is ephemeral: its lifetime is bound to the lifetime of the consuming workload.
In terms of placement, a design choice is that a ``ComputeDomain`` follows the workload.

That means: only once workload pods get scheduled onto specific nodes, the ``ComputeDomain`` they request automatically forms around them.
Upon workload completion, all ``ComputeDomain``-associated resources get torn down automatically.

A deeper dive: related resources
================================

For more background on how ``ComputeDomain``\s facilitate orchestrating MNNVL workloads on Kubernetes (and on NVIDIA GB200 systems in particular), see `this doc <https://docs.google.com/document/d/1PrdDofsPFVJuZvcv-vtlI9n2eAh-YVf_fRQLIVmDwVY/edit?tab=t.0#heading=h.qkogm924v5so>`_ and `this slide deck <https://docs.google.com/presentation/d/1Xupr8IZVAjs5bNFKJnYaK0LE7QWETnJjkz6KOfLu87E/edit?pli=1&slide=id.g28ac369118f_0_1647#slide=id.g28ac369118f_0_1647>`_.

For an outlook on improvements on the ``ComputeDomain`` concept that we have planned to release in the future, please refer to `this document <https://github.com/NVIDIA/k8s-dra-driver-gpu/releases/tag/v25.3.0-rc.3>`_.

Details about IMEX and its relationship to NVLink may be found in `NVIDIA's IMEX guide <https://docs.nvidia.com/multi-node-nvlink-systems/imex-guide/overview.html>`_.

CUDA API documentation for `cuMemCreate <https://docs.nvidia.com/cuda/cuda-driver-api/group__CUDA__VA.html#group__CUDA__VA_1g899d69a862bba36449789c64b430dc7c>`_ provides a starting point to learn about exporting GPU memory though IMEX/NVLink.

If you are looking for a higher-level communication library, `NVIDIA's NCCL <https://docs.nvidia.com/multi-node-nvlink-systems/multi-node-tuning-guide/nccl.html>_` newer than version 2.25 supports MNNVL.


Usage example: a multi-node nvbandwidth test
============================================

This example demonstrates how to run a MNNVL workload across multiple nodes using a ComputeDomain.

Notes:

- This example uses `Kubeflow MPI Operator <https://www.kubeflow.org/docs/components/trainer/legacy-v1/user-guides/mpi/#installationr>`__.




**Steps:**

#. Install Kubeflow MPI Operator.

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
      - Set this tot he number of GPUs to use per node (4)

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

****
GPUs
****

The GPU allocation side of this DRA driver enables various critical scenarios, such as

- controlled sharing of individual GPUs between multiple pods and/or containers.
- GPU selection via complex constraints expressed via `CEL <https://kubernetes.io/docs/reference/using-api/cel/>`_.

To learn more about this part of the DRA driver and about what we are planning to build in the future (such as dynamic allocation of MIG devices), please have a look at `these release notes <https://github.com/NVIDIA/k8s-dra-driver-gpu/releases/tag/v25.3.0-rc.3>`_.

While the GPU allocation features of this driver can be tried out, they are not yet officially supported.
Hence, the GPU kubelet plugin is currently disabled by default in the Helm chart installation.

For documentation on how to use and test the current set of GPU allocation features, please head over to the `demo section <https://github.com/NVIDIA/k8s-dra-driver-gpu?tab=readme-ov-file#a-kind-demo>`_ of the driver's README and to its `quickstart directory <https://github.com/NVIDIA/k8s-dra-driver-gpu/tree/main/demo/specs/quickstart>`_.

.. note::
  This part of the NVIDIA DRA Driver for GPUs is in **Technology Preview**.
  They are not yet supported in production environments and are not functionally complete.
  Technology Preview features provide early access to upcoming product features, enabling customers to test functionality and provide feedback during the development process.
  These releases may not have full documentation, and testing is limited.

