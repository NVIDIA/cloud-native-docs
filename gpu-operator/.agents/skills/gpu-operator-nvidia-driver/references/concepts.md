<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# NVIDIA Driver Custom Resource: Concepts and Fields

## Overview of the GPU Driver Custom Resource Definition

You can create one or more instances of an NVIDIA driver (`NVIDIADriver`) custom resource
to specify the NVIDIA GPU driver type and driver version to configure on specific nodes.
You can specify labels in the node selector field to control which NVIDIA driver configuration is applied to specific nodes.

### Limitations

* This feature is recommended for new cluster installations only.
  Upgrades from ClusterPolicy managed drivers to NVIDIA driver custom resource managed drivers are not supported.
  Switching from ClusterPolicy to the NVIDIA driver custom resource will cause all existing driver pods to be terminated immediately and redeployed using the new NVIDIADriver configuration.
* You must either use the default NVIDIA driver custom resource that the Helm chart creates or create and manage your own custom NVIDIA driver custom resource.
* You can't use ClusterPolicy and the NVIDIA driver custom resource at the same time. You can only use one or the other in a cluster.

### Comparison: Managing the Driver with CRD versus the Cluster Policy

Before the introduction of the NVIDIA GPU Driver custom resource definition, you managed the driver by modifying
the driver field and subfields of the cluster policy custom resource definition.

The key differences between the two approaches are summarized in the following table.

| Cluster Policy CRD | NVIDIA Driver CRD * - | Supports a single driver type and version on all nodes. | Does not support multiple operating system versions. This limitation complicates performing an operating system upgrade on your nodes. - | Supports multiple driver types and versions on different nodes. | Supports multiple operating system versions on nodes. |
| --- | --- | --- | --- | --- | --- |

### Driver Daemon Sets

The NVIDIA GPU Operator starts a driver daemon set for each NVIDIA driver custom resource and each operating system version.

For example, if your cluster has one NVIDIA driver custom resource that specifies a 580 branch GPU driver and some
worker nodes run Ubuntu 20.04 and other worker nodes run Ubuntu 22.04, the Operator starts two driver daemon sets.
One daemon set configures the GPU driver on the Ubuntu 20.04 nodes and the other configures the driver on the Ubuntu 22.04 nodes.
All the nodes run the same 580 branch GPU driver.

![](../graphics/nvd-basics.svg)
If you choose to use precompiled driver containers, the Operator starts a driver daemon set for each Linux kernel version.

For example, if some nodes run Ubuntu 22.04 and the 5.15.0-84-generic kernel, and other nodes run the 5.15.0-78-generic kernel,
then the Operator starts two daemon sets.

### About the Default NVIDIA Driver Custom Resource

By default, the Helm chart configures a default NVIDIA driver custom resource during installation.
This custom resource does not include a node selector and as a result, the custom resource applies to every node in your cluster
that has an NVIDIA GPU.
The Operator starts a driver daemon set and pods for each operating system version in your cluster.

If you plan to configure your own driver custom resources to specify driver versions, types, and so on, then
you might prefer to avoid installing the default custom resource.
By preventing the installation, you can avoid node selector conflicts due to the default custom resource
matching all nodes and your custom resources matching some of the same nodes.

To prevent configuring the default custom resource, specify the `--set driver.nvidiaDriverCRD.deployDefaultCR=false`
argument when you install the Operator with Helm.

If the Operator is already installed with the default custom resource and you want to create your own
driver custom resources and apply them to specific nodes, delete the default custom resource.

> [!NOTE]
> After you delete the default custom resource, your custom resources might not reconcile
> automatically due to a known issue. Refer to the v26.3.0 known issues
> for the workaround.

### Feature Compatibility

Driver type
  Each NVIDIA driver custom resource specifies the driver type and is one of `gpu`, `vgpu`, or `vgpu-host-manager`.
  You can run the data-center driver (`gpu`) on some nodes and the vGPU driver on other nodes.

GPUDirect RDMA and GPUDirect Storage
  Each NVIDIA driver custom resource can specify how to configure GPUDirect RDMA and GPUDirect Storage (GDS).
  Refer to GPUDirect RDMA and GPUDirect Storage for the platform support and prerequisites.

GDRCopy
  Each NVIDIA driver custom resource can enable the GDRCopy sidecar container in the driver pod.

Precompiled and signed drivers
  You can run the default driver type that is compiled when the driver pod starts on some nodes
  and precompiled driver containers on other nodes.
  The precomp-limitations-restrictions for precompiled driver containers apply.

Preinstalled drivers on nodes
  If a node has an NVIDIA GPU driver installed in the operating system, then no driver container runs on the node.

Support for X86_64 and ARM64
  Each daemon set can run pods and driver containers for the X86_64 and ARM64 architectures.
  Refer to the [NVIDIA GPU Driver tags](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/driver/tags)
  web page to determine which driver version and operating system combinations support both architectures.

Custom Driver Parameters
  Each NVIDIA driver custom resource can specify custom kernel module parameters by using a ConfigMap.
  For more information, refer to Customizing NVIDIA GPU Driver Parameters during Installation (use the `gpu-operator-custom-driver` skill).

## About the NVIDIA Driver Custom Resource

An instance of the NVIDIA driver custom resource represents a specific NVIDIA GPU driver type and driver version to install and manage
on nodes.

The following table describes some of the fields in the custom resource.

| Field | Description | Default Value |  |  |  |
| --- | --- | --- | --- | --- | --- |
| `metadata.name` | Specifies the name of the NVIDIA driver custom resource. | None |  |  |  |
| `annotations` | Specifies a map of key and value pairs to add as custom annotations to the driver pod. | None |  |  |  |
| `driverType` | Specifies one of the following: | `gpu` to use the NVIDIA data-center GPU driver. | `vgpu` to use the NVIDIA vGPU guest driver. | `vgpu-host-manager` to use the NVIDIA vGPU Manager. | `gpu` |
| `env` | Specifies environment variables to pass to the driver container. | None |  |  |  |
| `gdrcopy.enabled` | Specifies whether to deploy the GDRCopy Driver. When set to `true` the GDRCopy Driver image runs as a sidecar container. | `false` |  |  |  |
| `gds.enabled` | Specifies whether to enable GPUDirect Storage. | `false` |  |  |  |
| `image` | Specifies the driver container image name. | `driver` |  |  |  |
| `imagePullPolicy` | Specifies the policy for kubelet to download the container image. Refer to the Kubernetes documentation for [image pull policy](https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy). | Refer to the Kubernetes documentation. |  |  |  |
| `imagePullSecrets` | Specifies the credentials to provide to the registry if the registry is secured. | None |  |  |  |
| `kernelModuleType` | Specifies the type of the NVIDIA GPU Kernel modules to use. Valid values are `auto` (default), `proprietary`, and `open`. `Auto` means that the recommended kernel module type is chosen based on the GPU devices on the host and the driver branch used. | `auto` |  |  |  |
| `labels` | Specifies a map of key and value pairs to add as custom labels to the driver pod. | None |  |  |  |
| `nodeSelector` | Specifies one or more node labels to match. The driver container is scheduled to nodes that match all the labels. | None. When you do not specify this field, the driver custom resource selects all nodes. |  |  |  |
| `priorityClassName` | Specifies the priority class for the driver pod. | `system-node-critical` |  |  |  |
| `rdma.enabled` | Specifies whether to enable GPUDirect RDMA. | `false` |  |  |  |
| `repository` | Specifies the container registry that contains the driver container. | `nvcr.io/nvidia` |  |  |  |
| `useOpenKernelModules` Deprecated. | This field is deprecated as of v25.3.0 and will be ignored. Use `kernelModuleType` instead. Specifies to use the NVIDIA Open GPU Kernel modules. | `false` |  |  |  |
| `tolerations` | Specifies a set of tolerations to apply to the driver pod. | None |  |  |  |
| `usePrecompiled` | When set to `true`, the Operator deploys a driver container image with a precompiled driver. | `false` |  |  |  |
| `version` | Specifies the GPU driver version to install. For a data-center driver, specify a value like `580.126.20`. If you set `usePrecompiled` to `true`, specify the driver branch, such as `580`. | Refer to the operator-component-matrix. |  |  |  |
