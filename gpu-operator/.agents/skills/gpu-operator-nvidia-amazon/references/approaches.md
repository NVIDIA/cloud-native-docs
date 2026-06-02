<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Approaches for Working with Amazon EKS

You can approach running workloads in Amazon EKS with NVIDIA GPUs in at least two ways.

## Default EKS configuration without the GPU Operator

By default, you can run Amazon EKS optimized Amazon Linux AMIs on instance types
that support NVIDIA GPUs.

Using the default configuration has the following limitations:

* The pre-installed NVIDIA GPU driver version and NVIDIA container runtime version
  lags the release schedule from NVIDIA.
* You must deploy the NVIDIA device plugin and you assume responsibility for
  upgrading the plugin.

If these limitations are acceptable to you, refer to
[Amazon EKS optimized Amazon Linux AMIs](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html)
in the Amazon EKS documentation for information about configuring your cluster.
You do not need to install the NVIDIA GPU Operator.

## EKS Node Group with the GPU Operator

To overcome the limitations with the first approach, you can create a node group for your cluster.
Configure the node group with instance types that have
NVIDIA GPUs and use an AMI with an operating system that the GPU Operator supports.
The Operator does not support a mix of some nodes running Amazon Linux 2 and others
running a supported operating system in the same cluster.

In this case, the Operator manages the lifecycle of all the operands, including
the NVIDIA GPU driver containers.
This approach enables you to run the most recent NVIDIA GPU drivers and use the
Operator to manage upgrades of the driver and other software components such as
the NVIDIA device plugin, NVIDIA Container Toolkit, and NVIDIA MIG Manager.

This approach provides the most up-to-date software and the Operator reduces
the administrative overhead.

## EKS Node Groups in Brief and Client Applications

When you configure an Amazon EKS node group, you can configure
[self-managed nodes](https://docs.aws.amazon.com/eks/latest/userguide/worker.html)
or [managed nodes groups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html).

Amazon EKS supports many clients for creating a node group.

For self-managed nodes, you can use the `eksctl` CLI or Amazon Management Console.
Refer to the preceding URL for concepts and procedures.

For managed node groups, you can use the Amazon Management Console.
The Amazon EKS documentation describes how to use the `eksctl` CLI,
but the CLI does not support operating systems other than Amazon Linux 2 and
the Operator does not support that operating system.
Refer to the preceding URL for concepts and procedures.

Terraform supports creating self-managed and managed node groups.
Refer to
[AWS EKS Terraform module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
in the Terraform Registry for more information.

## About Using the Operator with Amazon EKS

To use the NVIDIA GPU Operator with Amazon Elastic Kubernetes Service (EKS)
without any limitations, you perform the following high-level actions:

* Create a self-managed or managed node group with instance types that have NVIDIA GPUs.

  Refer to the following resources in the Amazon EC2 documentation to help you choose
  the instance type to meet your needs:

  * Table of accelerated computing
    [instance types](https://aws.amazon.com/ec2/instance-types/accelerated-computing/)
    for information about GPU model and count, RAM, and storage.

  * [Maximum IP addresses per network interface](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AvailableIpPerENI.html)
    for accelerated computing instance types.
    Make sure the instance type supports enough IP addresses for your workload.
    For example, the `g4dn.xlarge` instance type supports `29` IP addresses for pods on the node.

* Use an Amazon EKS optimized Amazon Machine Image (AMI) with a supported operating system (use the `gpu-operator-references` skill) on the nodes in the node group.

  AMIs support are specific to an AWS region and Kubernetes version.
  See https://cloud-images.ubuntu.com/aws-eks/ for the AMI values such as `ami-00687acd80b7a620a`.

* Use your preferred client application to create the node group.
