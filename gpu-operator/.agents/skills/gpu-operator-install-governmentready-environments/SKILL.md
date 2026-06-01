---
name: "gpu-operator-install-governmentready-environments"
description: "Guides users through government-ready GPU Operator installation considerations. Use when deploying in hardened or regulated Kubernetes environments."
triggers:
  - NVIDIA GPU Operator
  - government-ready
  - installation
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - government-ready
  - installation
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# NVIDIA GPU Operator Government Ready

## Prerequisites

- A running Kubernetes cluster with NVIDIA GPU worker nodes.
- The `kubectl` and `helm` CLIs available on a client machine.
- An NVIDIA AI Enterprise subscription. Government-ready components are available to NVIDIA AI Enterprise customers for FedRAMP High or equivalent sovereign use cases.

## Overview

The NVIDIA GPU Operator now offers government-ready components for NVIDIA AI Enterprise customers.
Government ready is NVIDIA's designation for software that meets applicable security requirements for deployment in your FedRAMP High or equivalent sovereign use case.
For more information on NVIDIA's government-ready support, refer to the white paper [AI Software for Regulated Environments](https://docs.nvidia.com/ai-enterprise/planning-resource/ai-software-regulated-environments-white-paper/latest/index.html).

## Supported GPU Operator Components

Refer to the [GPU Operator Component Matrix](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/life-cycle-policy.html#gpu-operator-component-matrix) for a full list of supported government-ready GPU Operator components.

Artifacts for these components are available from the [NVIDIA NGC Catalog](https://registry.ngc.nvidia.com/orgs/nvstaging/teams/cloud-native/containers/gpu-driver-stig-fips).

> [!NOTE]
> Not all GPU Operator components and features are available as government-ready containers in this release.
> For example, NVIDIA GDS Driver, NVIDIA Confidential Computing Manager, and NVIDIA GDRCopy Driver are not yet supported.

## Validated Kubernetes Distributions

The government-ready NVIDIA GPU Operator has been validated on the following Kubernetes distributions:

- Canonical Kubernetes 1.34 with Ubuntu Pro 24.04 and FIPS-compliant kernel
- Red Hat OpenShift 4.19 in FIPS mode
- Rancher Kubernetes Engine 2 with Ubuntu 24.04
- VMware VKS with Ubuntu 24.04

## Install Government-Ready NVIDIA GPU Operator

Once you have your gov-ready-prerequisites configured, use the following steps to install the NVIDIA GPU Operator on Canonical Kubernetes distributions:

1. install-nfd
1. create-ngc-api-pull-secret
1. create-ubuntu-pro-token-secret
1. deploy-nvidia-gpu-operator-gov-ready

> [!NOTE]
> For deployment on OpenShift, refer to [Install GPU Operator (government-ready) on OpenShift](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/install-gpu-operator-gov-ready-openshift.html).
### Prerequisites

- An active NVIDIA AI Enterprise subscription and NGC API token to access GPU Operator government-ready containers.
  Refer to [Generating Your NGC API Key](https://docs.nvidia.com/ngc/gpu-cloud/ngc-user-guide/index.html#generating-api-key) in the NVIDIA NGC User Guide for more information on NGC API tokens.

- An Ubuntu Pro token for Canonical Kubernetes deployments.
  This token is required for the driver container to download kernel headers and other necessary packages from the Canonical repository when using the FIPS-enabled kernel on Ubuntu 24.04.
  Refer to the [Ubuntu Pro documentation](https://documentation.ubuntu.com/pro-client/en/v30/howtoguides/get_token_and_attach/) for more information on accessing Ubuntu Pro tokens.

- The `helm` CLI installed on a client machine.

  You can run the following commands to install the Helm CLI:

  ```console
  $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
      && chmod 700 get_helm.sh \
      && ./get_helm.sh
  ```

- A namespace to deploy the NVIDIA GPU Operator.
  The example install commands below use `gpu-operator` as the namespace.

- Optionally, Service Mesh for intra-cluster traffic encryption.
  By default, the NVIDIA GPU Operator does not encrypt traffic between its controller (and operands) and the Kubernetes API server.
  If you wish to encrypt this communication, you should deploy and maintain a service mesh application within the Kubernetes cluster to enable secure traffic.

### Install Node Feature Discovery (NFD)

NFD is an open-source project that is a dependency for the Operator on each node in your cluster.
It must be deployed before installing the NVIDIA GPU Operator.

GPU Operator does not maintain a government ready version of NFD, it is recommended that you install the upstream NFD version that aligns with the operator-component-matrix.
The NFD container is built on top of a scratch image, providing a highly secure container environment.
For information on NFD CVEs and security updates, refer to the [NFD GitHub repository](https://github.com/kubernetes-sigs/node-feature-discovery/security).

Refer to the NFD documentation for [installation instructions](https://kubernetes-sigs.github.io/node-feature-discovery/stable/get-started/index.html).

### Create NGC API Pull Secret

Add a Docker registry secret for downloading the GPU Operator artifacts from NVIDIA NGC in the same namespace where you are planning to deploy the NVIDIA GPU Operator.
Update `ngc-api-key` in the command below with your NGC API key.

```console
$ kubectl create secret -n gpu-operator docker-registry ngc-secret \
    --docker-server=nvcr.io \
    --docker-username='$oauthtoken' \
    --docker-password=<ngc-api-key>
```

### Create Ubuntu Pro Token Secret

Create a Kubernetes secret to hold the value of your Ubuntu Pro token secret.
This secret will be used in the install command in the next step.

The Ubuntu Pro Token is required for the driver container to download kernel headers and other necessary packages from the Canonical repository when using the FIPS-enabled kernel on Ubuntu 24.04.

1. Get the Ubuntu Pro token:

   ```console
   $ echo UBUNTU_PRO_TOKEN=<your Ubuntu Pro token> > ubuntu-fips.env
   ```

   Replace `<your Ubuntu Pro token>` with your actual Ubuntu Pro token.

2. Create Ubuntu Pro token Secret:

   ```console
   $ kubectl create secret generic ubuntu-fips-secret \
       --from-env-file=./ubuntu-fips.env --namespace gpu-operator
   ```

   Note that the namespace in the above command is `gpu-operator`.
   Update this to the namespace you are planning to use for the NVIDIA GPU Operator.

### Install NVIDIA GPU Operator Government-Ready Components

1. Label your `gpu-operator` namespace for the Operator to set the enforcement policy to privilege.

   ```console
   $ kubectl label --overwrite ns gpu-operator pod-security.kubernetes.io/enforce=privileged
   ```

1. Add the NVIDIA Helm repository:

   ```console
   $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
       && helm repo update
   ```

1. Install the NVIDIA GPU Operator.

   ```console
   $  helm install gpu-operator nvidia/gpu-operator \
        --namespace gpu-operator \
        --set driver.secretEnv=ubuntu-fips-secret \
        --set driver.repository=nvcr.io/nvidia \
        --set driver.version=580.95.05-stig-fips \
        --set driver.image=gpu-driver-stig-fips \
        --set driver.imagePullSecrets={ngc-secret} \
        --set nfd.enabled=false
   ```

Refer to [Common Chart Customization Options](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#common-chart-customization-options) for more information about installation options.

## Update Ubuntu Pro Token in ClusterPolicy

You can update your Ubuntu Pro Token after installation by editing your Ubuntu Pro Token secret.
This secret name is set as value of `driver.secretEnv` of the GPU Operator ClusterPolicy.

Edit your Ubuntu Pro Token secret.

```console
$ kubectl edit secrets <ubuntu-fips-secret>
```

Then update the secret with your new Ubuntu Pro Token.
This token is required for the driver container to download kernel headers and other necessary packages from the Canonical repository when using the FIPS-enabled kernel on Ubuntu 24.04.
