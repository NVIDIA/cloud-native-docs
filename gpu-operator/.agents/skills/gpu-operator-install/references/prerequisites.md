<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# GPU Operator Install Prerequisites

1. You have the `kubectl` and `helm` CLIs available on a client machine.

   You can run the following commands to install the Helm CLI:

   ```console
   $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
       && chmod 700 get_helm.sh \
       && ./get_helm.sh
   ```

1. If you are planning to use ClusterPolicy for driver configuration, all worker nodes or node groups to run GPU workloads in the Kubernetes cluster must run the same operating system version to use the NVIDIA GPU Driver container.
   Alternatively, if you pre-install the NVIDIA GPU Driver on the nodes, then you can run different operating systems.

   For worker nodes or node groups that run CPU workloads only, the nodes can run any operating system because the GPU Operator does not perform any configuration or management of nodes for CPU-only workloads.

   If you are planning to use the NVIDIA GPU Driver Custom Resource Definition, you can use a mix of operating system versions on CPU and GPU nodes. Refer to the NVIDIA GPU Driver Custom Resource Definition (use the `gpu-operator-nvidia-driver` skill) page for more information.

1. Nodes must be configured with a container engine such as CRI-O or containerd.

1. If your cluster uses Pod Security Admission (PSA) to restrict the behavior of pods, label the namespace for the Operator to set the enforcement policy to privileged:

   ```console
   $ kubectl create ns gpu-operator
   $ kubectl label --overwrite ns gpu-operator pod-security.kubernetes.io/enforce=privileged
   ```

1. Node Feature Discovery (NFD) is a dependency for the Operator on each node.
   By default, NFD master and worker are automatically deployed by the Operator.
   If NFD is already running in the cluster, then you must disable deploying NFD when you install the Operator.

   One way to determine if NFD is already running in the cluster is to check for an NFD label on your nodes:

   ```console
   $ kubectl get nodes -o json | jq '.items[].metadata.labels | keys | any(startswith("feature.node.kubernetes.io"))'
   ```

   If the command output is `true`, then NFD is already running in the cluster.
