<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Approaches for Working with Azure AKS

## Create AKS Cluster with a Node Pool to Skip GPU Driver installation

Azure Kubernetes Service has a preview feature that enables a `--skip-gpu-driver-install`
command-line argument to the `az aks nodepool add` command.
This argument prevents installing
the NVIDIA GPU Driver in the stock Ubuntu operating system.

This approach enables you to take advantage of the lifecycle management
that the NVIDIA GPU Operator provides for managing your cluster.

```console
$ az aks nodepool add --resource-group <rg-name> --name gpunodes --cluster-name <cluster-name> \
     --node-count <n> \
     --skip-gpu-driver-install \
     ...
```

When you follow this approach, you can install the Operator without any special
considerations or arguments.
Refer to Install NVIDIA GPU Operator.

For more information about this feature, see
[Skip GPU driver installation](https://learn.microsoft.com/en-us/azure/aks/use-nvidia-gpu?source=recommendations&tabs=add-ubuntu-gpu-node-pool#skip-gpu-driver-installation)
in the Azure Kubernetes Service documentation.

## Default AKS configuration without the GPU Operator

By default, you can run Azure AKS images on GPU-enabled virtual machines with NVIDIA GPUs,
and not use the NVIDIA GPU Operator.

AKS images include a preinstalled NVIDIA GPU Driver and preinstalled NVIDIA Container Toolkit.

Using the default configuration, without the Operator, has the following limitations:

* Metrics are not collected or reported with NVIDIA DCGM Exporter.
* Validating the container runtime is manual rather than automatic with the Operator.
* Multi-Instance GPU (MIG) profiles must be set when you create the node pool and you
  cannot change the profile at run time.

If these limitations are acceptable to you, refer to
[Use GPUs for compute-intensive workloads on Azure Kubernetes Services](https://learn.microsoft.com/en-us/azure/aks/gpu-cluster)
in the Microsoft Azure product documentation for information about configuring your cluster.

## GPU Operator with Preinstalled Driver and Container Toolkit

The images that are available in AKS always include a preinstalled NVIDIA GPU driver
and a preinstalled NVIDIA Container Toolkit.
These images reduce the primary benefit of installing the Operator so that it can
manage the lifecycle of these software components and others.

However, using the Operator can overcome the limitations identified in the preceding section.
