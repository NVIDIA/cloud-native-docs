<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->
# About the NVIDIA GPU Operator

![](graphics/nvidia-gpu-operator-image.jpg)
Kubernetes provides access to special hardware resources such as NVIDIA GPUs, NICs, Infiniband adapters and other devices
through the [device plugin framework](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/).
However, configuring and managing nodes with these hardware resources requires
configuration of multiple software components such as drivers, container runtimes or other libraries which are difficult
and prone to errors. The NVIDIA GPU Operator uses the [operator framework](https://coreos.com/blog/introducing-operator-framework)
within Kubernetes to automate the management of all NVIDIA software components needed to provision GPU. These components include the NVIDIA drivers (to enable CUDA),
Kubernetes device plugin for GPUs, the [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-container-toolkit),
automatic node labeling using [GFD](https://github.com/NVIDIA/gpu-feature-discovery), [DCGM](https://developer.nvidia.com/dcgm) based monitoring and others.

## About This Documentation

Browse through the following documents for getting started, platform support and release notes for the NVIDIA GPU Operator.

**Red Hat OpenShift Container Platform:**

Refer to :external+ocpindex for information about installing, managing, and upgrading the Operator on Red Hat OpenShift Container Platform.
### Getting Started

The operator-install-guide guide includes information on installing the GPU Operator in a Kubernetes cluster.

### Release Notes

Refer to operator-release-notes for information about releases.

### Platform Support

The operator-platform-support describes the supported platform configurations.

## Licenses and Contributing

The NVIDIA GPU Operator source code is licensed under [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) and
contributions are accepted with a DCO. Refer to the [contributing](https://github.com/NVIDIA/gpu-operator/blob/master/CONTRIBUTING.md) document for
more information on how to contribute and the release artifacts.

The base images used by the software might include software that is licensed under open-source licenses such as GPL.
The source code for these components is archived on the CUDA opensource [index](https://developer.download.nvidia.com/compute/cuda/opensource/).

The following table identifieis the licenses for the Operator and software components.
By installing and using the GPU Operator, you accept the terms and conditions of these licenses.

| Component | Artifact Type | Artifact Licenses |
| --- | --- | --- |
| NVIDIA GPU Operator | Helm Chart | [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) |
| NVIDIA GPU Operator | Image | pstai_ |
| NVIDIA GPU Feature Discovery | Image | pstai_ |
| NVIDIA GPU Driver | Image | [License for Customer Use of NVIDIA Software](http://www.nvidia.com/content/DriverDownload-March2009/licence.php?lang=us) pstai_ |
| NVIDIA Container Toolkit | Image | pstai_ |
| NVIDIA Kubernetes Device Plugin | Image | pstai_ |
| NVIDIA MIG Manager for Kubernetes | Image | pstai_ |
| Validator for NVIDIA GPU Operator | Image | pstai_ |
| NVIDIA DCGM | Image | pstai_ |
| NVIDIA DCGM Exporter | Image | pstai_ |
| NVIDIA Driver Manager for Kubernetes | Image | pstai_ |
| NVIDIA KubeVirt GPU Device Plugin | Image | pstai_ |
| NVIDIA vGPU Device Manager | Image | pstai_ |
| NVIDIA GDS Driver | Image | [License for Customer Use of NVIDIA Software](http://www.nvidia.com/content/DriverDownload-March2009/licence.php?lang=us) pstai_ |
| NVIDIA Confidential Computing Manager for Kubernetes | Image | pstai_ |
| NVIDIA Kata Manager for Kubernetes | Image | pstai_ |
| NVIDIA GDRCopy Driver | Image | pstai_ |
