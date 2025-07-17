.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

##########################
NVIDIA DRA Driver for GPUs
##########################

************
Introduction
************

With NVIDIA's DRA Driver for GPUs, your Kubernetes workload can allocate and consume the following two types of resources:

* **GPUs**: for controlled sharing and dynamic reconfiguration of GPUs. A modern replacement for the traditional GPU allocation method (using `NVIDIA's device plugin <https://github.com/NVIDIA/k8s-device-plugin>`_). We are excited about this part of the driver; it is however not yet fully supported (Technology Preview).
* **ComputeDomains**: for robust and secure Multi-Node NVLink (MNNVL) for NVIDIA GB200 and similar systems. Fully supported.

A primer on DRA
===============

Dynamic Resource Allocation (DRA) is a novel concept in Kubernetes for flexibly requesting, configuring, and sharing specialized devices like GPUs.
DRA puts device configuration and scheduling into the hands of device vendors via drivers like this one.
For NVIDIA devices, there are two particularly benefical characteristics provided by DRA:

#. A clean way to allocate **cross-node resources** in Kubernetes (leveraged here for providing NVLink connectivity across pods running on multiple nodes).
#. Mechanisms to explicitly **share, partition, and reconfigure** devices **on-the-fly** based on user requests (leveraged here for advanced GPU allocation).

To understand and make best use of NVIDIA's DRA Driver for GPUs, we recommend becoming familiar with DRA by working through the `official documentation <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/>`_.


The two parts of this driver
============================

NVIDIA's DRA Driver for GPUs is comprised of two subsystems that are largely independent of each other: one manages GPUs, and the other one manages ComputeDomains.

The next documentation chapter contains instructions for how to install both parts or just one of them.
Additionally, we have prepared two separate documentation chapters, providing more in-depth information for each of the two subsystems:

- `Documentation for ComputeDomain support <foo2>`_
- `Documentation for GPU support <foo1>`_
