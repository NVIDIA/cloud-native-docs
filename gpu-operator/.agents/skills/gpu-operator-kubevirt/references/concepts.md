<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# KubeVirt with the GPU Operator: Concepts

## About the Operator with KubeVirt

[KubeVirt](https://kubevirt.io/) is a virtual machine management add-on to Kubernetes that allows you to run and manage virtual machines in a Kubernetes cluster.
It eliminates the need to manage separate clusters for virtual machine and container workloads because both can now coexist in a single Kubernetes cluster.

In addition to the GPU Operator being able to provision worker nodes for running GPU-accelerated containers, the GPU Operator can also be used to provision worker nodes for running GPU-accelerated virtual machines with KubeVirt.

There are some different prerequisites required when running virtual machines with GPUs compared to running containers with GPUs.
The primary difference is the drivers required.
For example, the datacenter driver is needed for containers, the vfio-pci driver is needed for GPU passthrough, and the [NVIDIA vGPU Manager](https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#installing-configuring-grid-vgpu) is needed for creating vGPU devices.

## Configure Worker Nodes for GPU Operator components

The GPU Operator can now be configured to deploy different software components on worker nodes depending on what GPU workload is configured to run on those nodes.
This is configured by adding a `nvidia.com/gpu.workload.config` label to the worker node with the value of `container`, `vm-passthrough`, or `vm-vgpu` depending on if you are planning to use vGPU or not.
The GPU Operator will use the label to determine which software components to deploy on the worker nodes.

Given the following node configuration:

* Node A is configured with the label `nvidia.com/gpu.workload.config=container` and configured to run containers.
* Node B is configured with the label `nvidia.com/gpu.workload.config=vm-passthrough` and configured to run virtual machines with Passthrough GPU.
* Node C is configured with the label `nvidia.com/gpu.workload.config=vm-vgpu` and configured to run virtual machines with vGPU.

The GPU Operator will deploy the following software components on each node:

* Node A receives the following software components:
   * `NVIDIA Datacenter Driver` - to install the driver
   * `NVIDIA Container Toolkit` - to ensure containers can properly access GPUs
   * `NVIDIA Kubernetes Device Plugin` - to discover and advertise GPU resources to kubelet
   * `NVIDIA DCGM and DCGM Exporter` - to monitor the GPU(s)

* Node B receives the following software components:
   * `VFIO Manager` - to load `vfio-pci` and bind it to all GPUs on the node
   * `Sandbox Device Plugin` - to discover and advertise the passthrough GPUs to kubelet

* Node C receives the following software components:
   * `NVIDIA vGPU Manager` - to install the driver
   * `NVIDIA vGPU Device Manager` - to create vGPU devices on the node
   * `Sandbox Device Plugin` - to discover and advertise the vGPU devices to kubelet

If the node label `nvidia.com/gpu.workload.config` does not exist on the node, the GPU Operator will assume the default GPU workload configuration, `container`, and will deploy the software components needed to support this workload type.
To override the default GPU workload configuration, set the following value in `ClusterPolicy`: `sandboxWorkloads.defaultWorkload=<config>`.

## Assumptions, constraints, and dependencies

* A GPU worker node can run GPU workloads of a particular type, such as containers, virtual machines with GPU Passthrough, or virtual machines with vGPU, but not a combination of any of them.

* The cluster admin or developer has knowledge about their cluster ahead of time and can properly label nodes to indicate what types of GPU workloads they will run.

* Worker nodes running GPU accelerated virtual machines (with GPU passthrough or vGPU) are assumed to be bare metal.

* The GPU Operator will not automate the installation of NVIDIA drivers inside KubeVirt virtual machines with GPUs/vGPUs attached.

* Users must manually add all passthrough GPU and vGPU resources to the `permittedDevices` list in the KubeVirt CR before assigning them to KubeVirt virtual machines. Refer to the [KubeVirt documentation](https://kubevirt.io/user-guide/compute/host-devices/#listing-permitted-devices) for more information.

## Workflow Overview

After configuring the prerequisites, the high level workflow for using the GPU Operator with KubeVirt is as follows:

* Label worker nodes based on the GPU workloads they will run.
* Install the GPU Operator and set `sandboxWorkloads.enabled=true`

If you are planning to deploy VMs with vGPU, the workflow is as follows:

* Build the NVIDIA vGPU Manager image (see [references/build-vgpu-manager.md](build-vgpu-manager.md))
* Label the node for the vGPU configuration
* Add vGPU resources to KubeVirt CR
* Create a virtual machine with vGPU

If you are planning to deploy VMs with GPU passthrough, the workflow is as follows:

* Add GPU passthrough resources to KubeVirt CR
* Create a virtual machine with GPU passthrough

The term *sandboxing* refers to running software in a separate isolated environment, typically for added security (that is, a virtual machine).
We use the term `sandbox workloads` to signify workloads that run in a virtual machine, irrespective of the virtualization technology used.
