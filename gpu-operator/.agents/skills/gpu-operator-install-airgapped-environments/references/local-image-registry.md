<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Local Image Registry

Without internet access, the GPU Operator requires all images to be hosted in a local image registry that is accessible
to all nodes in the cluster. To allow the GPU Operator to work with a local registry, users can specify local
repository, image, tag along with pull secrets in `values.yaml`.

To pull the correct images from the NVIDIA registry, you can leverage the fields `repository`, `image` and `version`
specified in the file `values.yaml`.

The general syntax for the container image is `<repository>/<image>:<version>`.

If the version is not specified, you can retrieve the information from the NVIDIA NGC catalog at https://catalog.ngc.nvidia.com/containers.
Search for an image, such as `gpu-operator` and then check the available tags for the image.

> [!NOTE]
> Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases).

An example is shown below with the Operator container image:

```yaml
operator:
  repository: nvcr.io/nvidia
  image: gpu-operator
  version: "<gpu-operator-version>"
```

For instance, to pull the gpu-operator image version <gpu-operator-version>, use the following instruction:

```console
$ docker pull nvcr.io/nvidia/gpu-operator:<gpu-operator-version>
```

There is one caveat with regards to the driver image. The version field must be appended by the OS name running on the worker node.

```yaml
driver:
  repository: nvcr.io/nvidia
  image: driver
  version: "${recommended}"
```

To pull the driver image for Ubuntu 20.04:

```console
$ docker pull nvcr.io/nvidia/driver:${recommended}-ubuntu20.04
```

To push the images to the local registry, simply tag the pulled images by prefixing the image with the image registry information.

Using the above examples, this will result in:

```console
$ docker tag nvcr.io/nvidia/gpu-operator:<gpu-operator-version> <local-registry>/<local-path>/gpu-operator:<gpu-operator-version>
$ docker tag nvcr.io/nvidia/driver:${recommended}-ubuntu20.04 <local-registry>/<local-path>/driver:${recommended}-ubuntu20.04
```

Finally, push the images to the local registry:

```console
$ docker push <local-registry>/<local-path>/gpu-operator:<gpu-operator-version>
$ docker push <local-registry>/<local-path>/driver:${recommended}-ubuntu20.04
```

Update `values.yaml` with local registry information in the repository field.

> [!NOTE]
> Replace <repo.example.com:port> below with your local image registry URL and port.
> Sample of `values.yaml` for GPU Operator v1.9.0:

```yaml
operator:
  repository: <repo.example.com:port>
  image: gpu-operator
  version: 1.9.0
  imagePullSecrets: []
  initContainer:
    image: cuda
    repository: <repo.example.com:port>
    version: 11.4.2-base-ubi8

 validator:
   image: gpu-operator-validator
   repository: <repo.example.com:port>
   version: 1.9.0
   imagePullSecrets: []

 driver:
   repository: <repo.example.com:port>
   image: driver
   version: "470.82.01"
   imagePullSecrets: []
   manager:
     image: k8s-driver-manager
     repository: <repo.example.com:port>
     version: v0.2.0

 toolkit:
   repository: <repo.example.com:port>
   image: container-toolkit
   version: 1.7.2-ubuntu18.04
   imagePullSecrets: []

 devicePlugin:
   repository: <repo.example.com:port>
   image: k8s-device-plugin
   version: v0.10.0-ubi8
   imagePullSecrets: []

 dcgmExporter:
   repository: <repo.example.com:port>
   image: dcgm-exporter
   version: 2.3.1-2.6.0-ubuntu20.04
   imagePullSecrets: []

 gfd:
   repository: <repo.example.com:port>
   image: gpu-feature-discovery
   version: v0.4.1
   imagePullSecrets: []

 nodeStatusExporter:
   enabled: false
   repository: <repo.example.com:port>
   image: gpu-operator-validator
   version: "1.9.0"

 migManager:
   enabled: true
   repository: <repo.example.com:port>
   image: k8s-mig-manager
   version: v0.2.0-ubuntu20.04

 node-feature-discovery:
   image:
     repository: <repo.example.com:port>
     pullPolicy: IfNotPresent
     # tag, if defined will use the given image tag, else Chart.AppVersion will be used
     # tag:
   imagePullSecrets: []
```
