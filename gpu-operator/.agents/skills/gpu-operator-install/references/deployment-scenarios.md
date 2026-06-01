<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Common Deployment Scenarios

The following common deployment scenarios and sample commands apply best to
bare metal hosts or virtual machines with GPU passthrough.

Throughout, replace `<gpu-operator-version>` with your target GPU Operator release.

## Specifying the Operator Namespace

Both the Operator and operands are installed in the same namespace.
The namespace is configurable and is specified during installation.
For example, to install the GPU Operator in the `nvidia-gpu-operator` namespace:

```console
$ helm install --wait --generate-name \
     -n nvidia-gpu-operator --create-namespace \
     nvidia/gpu-operator \
     --version=<gpu-operator-version> \
```

If you do not specify a namespace during installation, all GPU Operator components are installed in the `default` namespace.

## Preventing Installation of Operands on Some Nodes

By default, the GPU Operator operands are deployed on all GPU worker nodes in the cluster.
GPU worker nodes are identified by the presence of the label `feature.node.kubernetes.io/pci-10de.present=true`.
The value `0x10de` is the PCI vendor ID that is assigned to NVIDIA.

To disable operands from getting deployed on a GPU worker node, label the node with `nvidia.com/gpu.deploy.operands=false`.

```console
$ kubectl label nodes $NODE nvidia.com/gpu.deploy.operands=false
```

## Preventing Installation of NVIDIA GPU Driver on Some Nodes

By default, the GPU Operator deploys the driver on all GPU worker nodes in the cluster.
To prevent installing the driver on a GPU worker node, label the node like the following sample command.

```console
$ kubectl label nodes $NODE nvidia.com/gpu.deploy.driver=false
```

## Installation on Red Hat Enterprise Linux

In this scenario, use the NVIDIA Container Toolkit image that is built on UBI 8:

```console
$ helm install --wait --generate-name \
     -n gpu-operator --create-namespace \
     nvidia/gpu-operator \
     --version=<gpu-operator-version> \
     --set toolkit.version=v1.16.1-ubi8
```

Replace the `v1.16.1` value in the preceding command with the version that is supported
with the NVIDIA GPU Operator.
Refer to the [GPU Operator Component Matrix](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/life-cycle-policy.html#gpu-operator-component-matrix) on the platform support page.

When using RHEL8 with Kubernetes, SELinux must be enabled either in permissive or enforcing mode for use with the GPU Operator.
Additionally, when using RHEL8 with containerd as the runtime and SELinux is enabled (either in permissive or enforcing mode) at the host level, containerd must also be configured for SELinux, by setting the `enable_selinux=true` configuration option.
Network restricted environments are not supported.

## Pre-Installed NVIDIA GPU Drivers

In this scenario, the NVIDIA GPU driver is already installed on the worker nodes that have GPUs:

```console
$ helm install --wait --generate-name \
     -n gpu-operator --create-namespace \
     nvidia/gpu-operator \
     --version=<gpu-operator-version> \
     --set driver.enabled=false
```

The preceding command prevents the Operator from installing the GPU driver on any nodes in the cluster.

If you do not specify the `driver.enabled=false` argument and nodes in the cluster have a pre-installed GPU driver, the init container in the driver pod detects that the driver is preinstalled and labels the node so that the driver pod is terminated and does not get re-scheduled on to the node.
The Operator proceeds to start other pods, such as the container toolkit pod.

## Pre-Installed NVIDIA GPU Drivers and NVIDIA Container Toolkit

In this scenario, the NVIDIA GPU driver and the NVIDIA Container Toolkit are already installed on
the worker nodes that have GPUs.

> [!TIP]
> This scenario applies to NVIDIA DGX Systems that run NVIDIA Base OS.
> Before installing the Operator, ensure that the default runtime is set to `nvidia`.
> Refer to the [NVIDIA Container Toolkit configuration](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) documentation for more information.

Install the Operator with the following options:

```console
$ helm install --wait --generate-name \
     -n gpu-operator --create-namespace \
     nvidia/gpu-operator \
     --version=<gpu-operator-version> \
     --set driver.enabled=false \
     --set toolkit.enabled=false
```

## Pre-Installed NVIDIA Container Toolkit (but no drivers)

In this scenario, the NVIDIA Container Toolkit is already installed on the worker nodes that have GPUs.

1. Configure toolkit to use the `root` directory of the driver installation as `/run/nvidia/driver`, because this is the path mounted by driver container.

   ```console
   $ sudo sed -i 's/^#root/root/' /etc/nvidia-container-runtime/config.toml
   ```

1. Install the Operator with the following options (which will provision a driver):

   ```console
   $ helm install --wait --generate-name \
       -n gpu-operator --create-namespace \
       nvidia/gpu-operator \
       --version=<gpu-operator-version> \
       --set toolkit.enabled=false
   ```

## Running a Custom Driver Image

If you want to use custom driver container images, such as version 465.27, then
you can build a custom driver container image. Follow these steps:

- Rebuild the driver container by specifying the `$DRIVER_VERSION` argument when building the Docker image. For
  reference, the driver container Dockerfiles are available on the Git repository at https://github.com/NVIDIA/gpu-driver-container/.
- Build the container using the appropriate Dockerfile. For example:

  ```console
  $ docker build --pull -t \
      --build-arg DRIVER_VERSION=455.28 \
      nvidia/driver:455.28-ubuntu20.04 \
      --file Dockerfile .
  ```

  Ensure that the driver container is tagged as shown in the example by using the `driver:<version>-<os>` schema.
- Specify the new driver image and repository by overriding the defaults in
  the Helm install command. For example:

  ```console
  $ helm install --wait --generate-name \
       -n gpu-operator --create-namespace \
       nvidia/gpu-operator \
       --version=<gpu-operator-version> \
       --set driver.repository=docker.io/nvidia \
       --set driver.version="465.27"
  ```

These instructions are provided for reference and evaluation purposes.
Not using the standard releases of the GPU Operator from NVIDIA would mean limited
support for such custom configurations.
