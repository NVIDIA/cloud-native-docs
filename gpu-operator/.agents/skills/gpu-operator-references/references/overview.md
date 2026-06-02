<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->
# About the NVIDIA GPU Operator

![NVIDIA GPU Operator architecture](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/_images/nvidia-gpu-operator-image.jpg)

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

> [!TIP]
> For Red Hat OpenShift Container Platform, refer to [NVIDIA GPU Operator on Red Hat OpenShift](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/index.html) for information about installing, managing, and upgrading the Operator.

### Getting Started

For installing the GPU Operator in a Kubernetes cluster, use the `gpu-operator-install` skill.

### Release Notes

For information about releases, see the release notes (use the `gpu-operator-references` skill and load `references/release-notes.md`).

### Platform Support

For the supported platform configurations, see platform support (use the `gpu-operator-references` skill and load `references/platform-support.md`).

## Licenses and Contributing

The NVIDIA GPU Operator source code is licensed under [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) and
contributions are accepted with a DCO. Refer to the [contributing](https://github.com/NVIDIA/gpu-operator/blob/master/CONTRIBUTING.md) document for
more information on how to contribute and the release artifacts.

The base images used by the software might include software that is licensed under open-source licenses such as GPL.
The source code for these components is archived on the CUDA opensource [index](https://developer.download.nvidia.com/compute/cuda/opensource/).

The following table identifies the licenses for the Operator and software components.
By installing and using the GPU Operator, you accept the terms and conditions of these licenses.

| Component | Artifact Type | Artifact Licenses |
| --- | --- | --- |
| NVIDIA GPU Operator | Helm Chart | [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) |
| NVIDIA GPU Operator | Image | [Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| NVIDIA GPU Feature Discovery | Image | [Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| NVIDIA GPU Driver | Image | [License for Customer Use of NVIDIA Software](http://www.nvidia.com/content/DriverDownload-March2009/licence.php?lang=us)<br>[Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| NVIDIA Container Toolkit | Image | [Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| NVIDIA Kubernetes Device Plugin | Image | [Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| NVIDIA MIG Manager for Kubernetes | Image | [Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| Validator for NVIDIA GPU Operator | Image | [Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| NVIDIA DCGM | Image | [Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| NVIDIA DCGM Exporter | Image | [Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| NVIDIA Driver Manager for Kubernetes | Image | [Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| NVIDIA KubeVirt GPU Device Plugin | Image | [Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| NVIDIA vGPU Device Manager | Image | [Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| NVIDIA GDS Driver | Image | [License for Customer Use of NVIDIA Software](http://www.nvidia.com/content/DriverDownload-March2009/licence.php?lang=us)<br>[Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| NVIDIA Confidential Computing Manager for Kubernetes | Image | [Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| NVIDIA Kata Manager for Kubernetes | Image | [Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
| NVIDIA GDRCopy Driver | Image | [Product-Specific Terms for NVIDIA AI Products](https://www.nvidia.com/en-us/agreements/enterprise-software/product-specific-terms-for-ai-products/) |
