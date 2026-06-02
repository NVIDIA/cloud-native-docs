<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Example: Create a Self-Managed Node Group with eksctl

## Prerequisites

* You have access to the Amazon Management Console or you installed and configured the AWS CLI.
  Refer to
  [Installing or updating to the latest version of the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  and [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
  in the AWS CLI documentation.
* You installed the `eksctl` CLI if you prefer it as your client application.
  The CLI is available from https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html#eksctl-install-update.
* You have the AMI value from https://cloud-images.ubuntu.com/aws-eks/.
* You have the EC2 instance type to use for your nodes.

## Procedure

The following steps show how to create an Amazon EKS cluster with the `eksctl` CLI.
The steps create a self-managed node group that uses an Amazon EKS optimized AMI.

1. Create a file, such as `cluster-config.yaml`, with contents like the following example:

   ```yaml
   apiVersion: eksctl.io/v1alpha5
   kind: ClusterConfig
   metadata:
     name: demo-cluster
     region: us-west-2
     version: "1.25"
   nodeGroups:
     - name: demo-gpu-workers
       instanceType: g4dn.xlarge
       ami: ami-0770ab88ec35aa875
       amiFamily: Ubuntu2004
       minSize: 1
       desiredCapacity: 3
       maxSize: 3
       volumeSize: 100
       overrideBootstrapCommand: |
         #!/bin/bash
         source /var/lib/cloud/scripts/eksctl/bootstrap.helper.sh
         /etc/eks/bootstrap.sh ${CLUSTER_NAME} --container-runtime containerd --kubelet-extra-args "--node-labels=${NODE_LABELS}"
       ssh:
         allow: true
         publicKeyPath: ~/.ssh/id_rsa.pub
   ```

   Replace the values for the cluster name, Kubernetes version, and so on.
   To resolve the environment variables in the override bootstrap command, you must source the bootstrap helper script.

   > [!TIP]
   > The default volume size for each node is 20 GB.
   > In many cases, containers with frameworks for AI/ML workloads are often very large.
   > The sample YAML file specifies a 100 GB volume to ensure enough local disk space for containers.

   1. Create the Amazon EKS cluster with the node group:

   ```console
   $ eksctl create cluster -f cluster-config.yaml
   ```

   Creating the cluster requires several minutes.

   *Example Output*

   ```output
   2022-08-19 17:51:04 [i]  eksctl version 0.105.0
   2022-08-19 17:51:04 [i]  using region us-west-2
   2022-08-19 17:51:04 [i]  setting availability zones to [us-west-2d us-west-2c us-west-2a]
   2022-08-19 17:51:04 [i]  subnets for us-west-2d - public:192.168.0.0/19 private:192.168.96.0/19
   ...
   [✓]  EKS cluster "demo-cluster" in "us-west-2" region is ready
   ```

1. Optional: View the cluster name:

   ```console
   $ eksctl get cluster
   ```

   *Example Output*

   ```output
   NAME          REGION     EKSCTL CREATED
   demo-cluster  us-west-2  True
   ```

## Verification

After the node group is created and the GPU Operator is installed on the cluster (use the `gpu-operator-install` skill), confirm that the GPU nodes are managed:

1. Confirm the GPU nodes advertise GPU capacity:

   ```console
   $ kubectl get nodes -o json | jq '.items[].status.capacity."nvidia.com/gpu"'
   ```

   Each GPU node should report a non-null GPU count.

1. Confirm the GPU Operator pods are running:

   ```console
   $ kubectl get pods -n gpu-operator
   ```

   The `nvidia-operator-validator` pod should report `Completed`.

## Related Information

* The preceding procedure is derived from
  [Getting started with Amazon EKS - eksctl](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)
  in the Amazon EKS documentation.
* If you have an existing Amazon EKS cluster, you can refer to
  [Launching self-managed Amazon Linux nodes](https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html)
  in the Amazon EKS documentation to add a self-managed node group to your cluster.
  However, all nodes in the cluster must run Ubuntu 20.04 or 22.04.
  This documentation includes steps for using the AWS Management Console.
