.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

.. headings (h1/h2/h3/h4/h5) are # * = -

###################################
NVIDIA GPU Operator with Amazon EKS
###################################

.. contents::
   :depth: 2
   :local:
   :backlinks: none


**************************************
Approaches for Working with Amazon EKS
**************************************

You can approach running workloads in Amazon EKS with NVIDIA GPUs in at least two ways.


Default EKS configuration without the GPU Operator
==================================================

By default, you can run Amazon EKS optimized Amazon Linux AMIs on instance types
that support NVIDIA GPUs.

Using the default configuration has the following limitations:

* The pre-installed NVIDIA GPU driver version and NVIDIA container runtime version
  lags the release schedule from NVIDIA.
* You must deploy the NVIDIA device plugin and you assume responsibility for
  upgrading the plugin.

If these limitations are acceptable to you, refer to
`Amazon EKS optimized Amazon Linux AMIs <https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html>`_
in the Amazon EKS documentation for information about configuring your cluster.
You do not need to install the NVIDIA GPU Operator.

EKS Node Group with the GPU Operator
====================================

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


EKS Node Groups in Brief and Client Applications
================================================

When you configure an Amazon EKS node group, you can configure
`self-managed nodes <https://docs.aws.amazon.com/eks/latest/userguide/worker.html>`_
or `managed nodes groups <https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html>`_.

Amazon EKS supports many clients for creating a node group.

For self-managed nodes, you can use the ``eksctl`` CLI or Amazon Management Console.
Refer to the preceding URL for concepts and procedures.

For managed node groups, you can use the Amazon Management Console.
The Amazon EKS documentation describes how to use the ``eksctl`` CLI,
but the CLI does not support operating systems other than Amazon Linux 2 and
the Operator does not support that operating system.
Refer to the preceding URL for concepts and procedures.

Terraform supports creating self-managed and managed node groups.
Refer to
`AWS EKS Terraform module <https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest>`_
in the Terraform Registry for more information.


****************************************
About Using the Operator with Amazon EKS
****************************************

To use the NVIDIA GPU Operator with Amazon Elastic Kubernetes Service (EKS)
without any limitations, you perform the following high-level actions:

* Create a self-managed or managed node group with instance types that have NVIDIA GPUs.

  Refer to the following resources in the Amazon EC2 documentation to help you choose
  the instance type to meet your needs:

  * Table of accelerated computing
    `instance types <https://aws.amazon.com/ec2/instance-types/#Accelerated_Computing>`_
    for information about GPU model and count, RAM, and storage.

  * Table of
    `maximum network interfaces <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#enis-acceleratedcomputing>`_
    for accelerated computing instance types.
    Make sure the instance type supports enough IP addresses for your workload.
    For example, the ``g4dn.xlarge`` instance type supports ``29`` IP addresses for pods on the node.

* Use an Amazon EKS optimized Amazon Machine Image (AMI) with Ubuntu 20.04 or 22.04 on the nodes in the node group.

  AMIs support are specific to an AWS region and Kubernetes version.
  See https://cloud-images.ubuntu.com/aws-eks/ for the AMI values such as ``ami-00687acd80b7a620a``.

* Use your preferred client application to create the node group.


*****************************************************
Example: Create a Self-Managed Node Group with eksctl
*****************************************************

Prerequisites
=============

* You have access to the Amazon Management Console or you installed and configured the AWS CLI.
  Refer to
  `Installing or updating to the latest version of the AWS CLI <https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html>`_
  and `Configuring the AWS CLI <https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html>`_
  in the AWS CLI documentation.
* You installed the ``eksctl`` CLI if you prefer it as your client application.
  The CLI is available from https://eksctl.io/introduction/#installation.
* You have the AMI value from https://cloud-images.ubuntu.com/aws-eks/.
* You have the EC2 instance type to use for your nodes.


Procedure
=========

The following steps show how to create an Amazon EKS cluster with the ``eksctl`` CLI.
The steps create a self-managed node group that uses an Amazon EKS optimized AMI.

#. Create a file, such as ``cluster-config.yaml``, with contents like the following example:

   .. literalinclude:: ./manifests/input/amazon-eks-cluster-config.yaml
      :language: yaml

   Replace the values for the cluster name, Kubernetes version, and so on.
   To resolve the environment variables in the override bootstrap command, you must source the bootstrap helper script.

   .. tip::

      The default volume size for each node is 20 GB.
      In many cases, containers with frameworks for AI/ML workloads are often very large.
      The sample YAML file specifies a 100 GB volume to ensure enough local disk space for containers.

#. Create the Amazon EKS cluster with the node group:

   .. code-block:: console

      $ eksctl create cluster -f cluster-config.yaml

   Creating the cluster requires several minutes.

   *Example Output*

   .. code-block:: output

      2022-08-19 17:51:04 [i]  eksctl version 0.105.0
      2022-08-19 17:51:04 [i]  using region us-west-2
      2022-08-19 17:51:04 [i]  setting availability zones to [us-west-2d us-west-2c us-west-2a]
      2022-08-19 17:51:04 [i]  subnets for us-west-2d - public:192.168.0.0/19 private:192.168.96.0/19
      ...
      [✓]  EKS cluster "demo-cluster" in "us-west-2" region is ready

#. Optional: View the cluster name:

   .. code-block:: console

      $ eksctl get cluster

   *Example Output*

   .. code-block:: output

      NAME          REGION     EKSCTL CREATED
      demo-cluster  us-west-2  True


**********
Next Steps
**********

* By default, the ``eksctl`` CLI adds the Kubernetes configuration information to your
  ``~/.kube/config`` file.
  You can run ``kubectl get nodes -o wide`` to view the nodes in the Amazon EKS cluster.

* You are ready to :ref:`install the NVIDIA GPU Operator <install-gpu-operator>`
  with Helm.

  If you specified a Kubernetes version less than ``1.25``, then specify ``--set psp.enabled=true``
  when you run the ``helm install`` command.


*******************
Related Information
*******************

* The preceding procedure is derived from
  `Getting started with Amazon EKS - eksctl <https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html>`_
  in the Amazon EKS documentation.
* If you have an existing Amazon EKS cluster, you can refer to
  `Launching self-managed Amazon Linux nodes <https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html>`_
  in the Amazon EKS documentation to add a self-managed node group to your cluster.
  However, all nodes in the cluster must run Ubuntu 20.04 or 22.04.
  This documentation includes steps for using the AWS Management Console.