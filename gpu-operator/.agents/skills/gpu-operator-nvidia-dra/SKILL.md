---
name: "gpu-operator-nvidia-dra"
description: "Explains how to install and use the NVIDIA DRA Driver for GPUs. Use when users ask about Dynamic Resource Allocation, DRA installation, or GPU resource claims."
triggers:
  - NVIDIA GPU Operator
  - DRA
  - Dynamic Resource Allocation
  - Kubernetes
  - installation
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - dra
  - dynamic-resource-allocation
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# NVIDIA DRA Driver for GPUs

Dynamic Resource Allocation (DRA) is a Kubernetes concept for flexibly requesting, configuring, and sharing specialized devices like GPUs.
DRA puts device configuration and scheduling into the hands of device vendors through drivers such as the DRA Driver for GPUs.
This page outlines how to install the NVIDIA DRA Driver for GPUs v25.12.0 and later with the NVIDIA GPU Operator.

Before using the DRA Driver for GPUs, it is recommended that you are familiar with the following concepts:

* [Upstream Kubernetes DRA documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/).
* [DRA Driver repository documentation](https://github.com/NVIDIA/k8s-dra-driver-gpu)

## Prerequisites

> [!TIP]
> You can use the NVIDIA DRA Driver for GPUs ComputeDomain and GPU allocation independently or together in the same cluster. They have different prerequisites; to use both features together, configure your cluster to meet the prerequisites for both.

For GPU allocation with the GPU Operator:

- Kubernetes v1.34.2 or newer. If you plan to use traditional extended resource requests such as `nvidia.com/gpu` with the DRA driver, enable the [`DRAExtendedResource`](https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/#extended-resource) feature gate.
- GPU Operator v25.10.0 or later with the NVIDIA Kubernetes Device Plugin disabled to avoid conflicts with the DRA Driver for GPUs. The DRA Driver requires Container Device Interface (CDI) enabled in the container runtime and NVIDIA Driver version 580 or later, both of which are default in GPU Operator v25.10.0 and later.
- Label the nodes you plan to use for GPU allocation (for example, `nvidia.com/dra-kubelet-plugin=true`) and use them as node selectors in the DRA driver Helm chart.

## Overview

With NVIDIA's DRA Driver for GPUs, your Kubernetes workload can allocate and consume the following two types of resources:

* GPU allocation: for controlled sharing and dynamic reconfiguration of GPUs. This functionality is a replacement for the traditional GPU allocation method used by the NVIDIA Kubernetes Device Plugin.
* ComputeDomains: An abstraction for robust and secure [Multi-Node NVLink (MNNVL)](https://docs.nvidia.com/multi-node-nvlink-systems/index.html) for NVIDIA GB200 and similar systems.

You can use the NVIDIA DRA Driver for GPUs with the NVIDIA GPU Operator to deploy and manage your GPUs and ComputeDomains.

### Known Issues

* There is a known issue where the NVIDIA Driver Manager is not aware of the DRA driver kubelet plugin, and will not correctly evict it on pod restarts.
  You must label the nodes you plan to use with DRA GPU allocation and pass the node label in the GPU Operator Helm command in the `driver.manager.env` flag.
  This enables the NVIDIA Driver Manager to evict the GPU kubelet plugin correctly on driver container upgrades.
* For A100 GPUs, the MIG manager does not automatically evict the DRA kubelet plugin during MIG configuration changes.
  If the DRA kubelet plugin is deployed before a MIG change, then you must manually restart the DRA kubelet plugin.

## Install the NVIDIA GPU Operator

### GPU Allocation

1. Create a node selector label on all the nodes in your cluster that support GPU allocation through DRA:

   ```console
   kubectl label node $HOSTNAME nvidia.com/dra-kubelet-plugin=true
   ```

2. Add the Helm repo:

   ```console
   helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
   && helm repo update
   ```

3. Install the GPU Operator with the NVIDIA Kubernetes Device Plugin disabled:

   ```console
   helm upgrade --install gpu-operator nvidia/gpu-operator \
     --version=v26.3.1 \
     --create-namespace \
     --namespace gpu-operator \
     --set devicePlugin.enabled=false \
     --set driver.manager.env[0].name=NODE_LABEL_FOR_GPU_POD_EVICTION \
     --set driver.manager.env[0].value="nvidia.com/dra-kubelet-plugin"
   ```

   Make sure that the value of `driver.manager.env` matches the node selector label that was used when installing the DRA driver helm chart.
### ComputeDomain

1. Add the Helm repo:

```console
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
&& helm repo update
```

2. Install the GPU Operator with the device plugin disabled:

```console
helm upgrade --install gpu-operator nvidia/gpu-operator \
  --version=v26.3.1 \
  --create-namespace \
  --namespace gpu-operator
```

Refer to the [GPU Operator installation guide](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-install.html) for additional configuration options when installing the GPU Operator.

If you are planning to use MIG devices, refer to the [NVIDIA GPU Operator MIG documentation](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-mig.html) to configure your cluster for MIG support.

## Install DRA Driver for GPUs

> [!NOTE]
> The `gpuResourcesEnabledOverride=true` is an additional flag that is required to fully enable GPU allocation support.
> Include it in the Helm command if you want to enable GPU allocation support.

If you want to disable either functionality:

* To disable GPU allocation support, include `--set resources.gpus.enabled=false` in the Helm command.
* To disable ComputeDomain support, include `--set resources.computeDomains.enabled=false` in the Helm command.
> [!NOTE]
> The `nvidiaDriverRoot` flag sets the root directory for the NVIDIA GPU driver.
> The default value is `/`, which is the typical value for drivers installed directly on the host.
> If you are using GPU Operator managed drivers (default), the drivers are installed to `/run/nvidia/driver` by default.
> If you are using [pre-installed drivers](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#pre-installed-nvidia-gpu-drivers), you can remove the `nvidiaDriverRoot` flag or set it to `/` in the command above.
### GPU Allocation

1. Create a custom `values.yaml` file for installing the DRA driver helm chart.

   ### values.yaml file

   Specifies the node selector label for nodes that will support GPU allocation through the DRA Driver.

   ```yaml
   image:
     pullPolicy: IfNotPresent
   kubeletPlugin:
     nodeSelector:
       nvidia.com/dra-kubelet-plugin: "true"
   ```

   ### GKE values.yaml file

   Google Kubernetes Engine requires some specific values to be set in the `values.yaml` file, including the driver root on the host in `nvidiaDriverRoot` as well as the node selector label for nodes that will support GPU allocation through the DRA Driver.

   ```yaml
   # Specify the driver root on the host in nvidiaDriverRoot.
   # "/home/kubernetes/bin/nvidia" is the default driver root on GKE.
   nvidiaDriverRoot: "/home/kubernetes/bin/nvidia"

   controller:
     priorityClassName: ""
     affinity: null
   image:
     pullPolicy: IfNotPresent
   kubeletPlugin:
     priorityClassName: ""
     tolerations:
       - effect: NoSchedule
         key: nvidia.com/gpu
         operator: Exists
     nodeSelector:
       nvidia.com/dra-kubelet-plugin: "true"
   ```

2. Add the Helm repo:

   ```console
   helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
   && helm repo update
   ```

3. Install the DRA driver:

   ### install command

   ```console
   helm upgrade -i nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
     --version="${dra_version}" \
     --namespace nvidia-dra-driver-gpu \
     --create-namespace \
     --set nvidiaDriverRoot=/run/nvidia/driver \
     --set gpuResourcesEnabledOverride=true \
     -f values.yaml
   ```

   ### GKE install command

   ```console
   helm upgrade -i nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
     --version="${dra_version}" \
     --namespace nvidia-dra-driver-gpu \
     --create-namespace \
     --set gpuResourcesEnabledOverride=true \
     -f values.yaml
   ```

### ComputeDomain

1. Add the NVIDIA NGC Catalog's Helm chart repository:

   ```console
   helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update
   ```

2. Install the DRA driver.

   Example for Operator-provided GPU driver:

   ```console
   helm upgrade -i nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
     --version="${dra_version}" \
     --create-namespace \
     --namespace nvidia-dra-driver-gpu \
     --set resources.gpus.enabled=false \
     --set nvidiaDriverRoot=/run/nvidia/driver
   ```

   Example for host-provided GPU driver:

   ```console
   helm upgrade -i nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
     --version="${dra_version}" \
     --create-namespace \
     --namespace nvidia-dra-driver-gpu \
     --set resources.gpus.enabled=false
   ```

## Validate Installation

1. Confirm that the DRA driver components are running:

   ```console
   kubectl get pods -n nvidia-dra-driver-gpu
   ```

   *Example Output*

   ```output
   NAME                                                READY   STATUS    RESTARTS   AGE
   nvidia-dra-driver-gpu-controller-67cb99d84b-5q7kj   1/1     Running   0          7m26s
   nvidia-dra-driver-gpu-kubelet-plugin-h5xsn          1/1     Running   0          7m27s
   ```

2. Verify that GPU DeviceClasses are available:

   ```console
   kubectl get deviceclass
   ```

   *Example Output*

   ```output
   NAME              AGE
   compute-domain-daemon.nvidia.com            55s
   compute-domain-default-channel.nvidia.com   55s
   gpu.nvidia.com                              55s
   mig.nvidia.com                              55s
   ```

The `compute-domain-daemon.nvidia.com` and `compute-domain-default-channel.nvidia.com` DeviceClasses are installed when ComputeDomain support is enabled.
The `gpu.nvidia.com` and `mig.nvidia.com` DeviceClasses are installed when GPU allocation support is enabled.

Additional validation steps are available in the DRA Driver repository documentation:

* [Validate setup for ComputeDomain allocation](https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki/Validate-setup-for-ComputeDomain-allocation)
* [Validate setup for GPU allocation](https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki/Validate-setup-for-GPU-allocation)

## Enable Health Checks

The NVIDIA DRA driver supports GPU health monitoring using the [NVIDIA Management Library (NVML)](https://developer.nvidia.com/management-library-nvml).
This feature uses NVML to check for [GPU XID errors](https://docs.nvidia.com/deploy/xid-errors/introduction.html) and determines if a GPU or MIG device is functioning properly.

Health checking is managed by the `NVMLDeviceHealthCheck` feature gate.
This is currently an alpha feature and is disabled by default.

When enabled, the DRA Driver for GPUs continuously monitors GPUs for XID errors and assigns health statuses:
* Healthy - GPU is functioning normally. The GPU may have a non-critical XID error but is still available for workloads.
* Unhealthy - GPU has a critical XID error and is not suitable for workloads.

To enable GPU health monitoring, deploy the DRA driver with the NVMLDeviceHealthCheck feature gate:

```console
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update
helm upgrade -i nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
  --namespace nvidia-dra-driver-gpu \
  --set gpuResourcesEnabledOverride=true \
  --set featureGates.NVMLDeviceHealthCheck=true
```

> [!NOTE]
> Unhealthy GPUs will not appear in the ResourceSlice list. After the device recovers and is marked healthy again, you must restart the DRA Driver for the device to be added back into the available resources pool.
> After enabling health checks, you can monitor health status in the kubelet logs.

1. Check kubelet plugin logs.
   Health status changes are logged in the kubelet plugin container. Run `kubectl get pods -n nvidia-dra-driver-gpu` and find the `nvidia-dra-driver-gpu-kubelet-plugin-<pod>` pod name. Replace `<pod>` with your actual pod name.

   ```console
   kubectl logs nvidia-dra-driver-gpu-kubelet-plugin-<pod> \
     -n nvidia-dra-driver-gpu \
     -c gpus
   ```

2. List all ResourceSlices.
   View all ResourceSlices in the cluster to see which devices are available:

   ```console
   kubectl get resourceslice
   ```

3. Inspect a specific ResourceSlice.
   View detailed information about a specific resource slice. Healthy devices are listed in the resource slice, while unhealthy devices are not listed:

   ```console
   kubectl get resourceslice <resourceslice-name> -o yaml
   ```

## Additional Documentation

Refer to the [DRA Driver for GPUs repository](https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki) for additional documentation, including

* [Upgrade Guide](https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki/Installation#upgrading)
* [Troubleshooting Guide](https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki/Troubleshooting)
