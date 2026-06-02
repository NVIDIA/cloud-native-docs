<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# About Air-Gapped Installations

This page describes how to successfully deploy the GPU Operator in clusters with restricted internet access.
By default, The GPU Operator requires internet access for the following reasons:

    1) Container images need to be pulled during GPU Operator installation.
    2) The `driver` container needs to download several OS packages prior to driver installation.

       > [!TIP]
       > Using precompiled-drivers removes the need for the `driver` containers to
       > download operating system packages and removes the need to create a local package repository.
       > To address these requirements, it may be necessary to create a local image registry and/or a local package repository
       > so that the necessary images and packages are available for your cluster. In subsequent sections, we detail how to
       > configure the GPU Operator to use local image registries and local package repositories. If your cluster is behind
       > a proxy, also follow the steps from install-gpu-operator-proxy.

Different steps are required for different environments with varying levels of internet connectivity.
The supported use cases/environments are listed in the below table:

+--------------------------+-----------------------------------------+
                           Network Flow                            |
+--------------------------+--------------------+--------------------+
 Use Case                  Pulling Images      Pulling Packages
+========+=================+====================+====================+
 **1**   HTTP Proxy with  K8s node --> HTTP   Driver container   |
         full Internet    Proxy --> Internet  --> HTTP Proxy --> |
         access           Image Registry      Internet Package   |
                                              Repository         |
+--------+-----------------+--------------------+--------------------+
 **2**   HTTP Proxy with  K8s node --> HTTP   Driver container   |
         limited Internet Proxy --> Internet  --> HTTP Proxy --> |
         access           Image Registry      Local Package      |
                                              Repository         |
+--------+-----------------+--------------------+--------------------+
 **3a**  Full Air-Gapped  K8s node --> Local  Driver container   |
         (w/ HTTP Proxy)  Image Registry      --> HTTP Proxy --> |
                                              Local Package      |
                                              Repository         |
+--------+-----------------+--------------------+--------------------+
 **3b**  Full Air-Gapped  K8s node --> Local  Driver container-->|
         (w/o HTTP Proxy) Image Registry      Local Package      |
                                              Repository         |
+--------+-----------------+--------------------+--------------------+

> [!NOTE]
> For Red Hat Openshift deployments in air-gapped environments (use cases 2, 3a and 3b),
> refer to [Mirror GPU Operator images for disconnected OpenShift](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/mirror-gpu-ocp-disconnected.html).
> [!NOTE]
> Ensure that Kubernetes nodes can successfully reach the local DNS server(s).
> Public name resolution for image registry and package repositories are
> mandatory for use cases 1 and 2.
> Before proceeding to the next sections, get the `values.yaml` file used for GPU Operator configuration.

```console
$ curl -sO https://raw.githubusercontent.com/NVIDIA/gpu-operator/v1.7.0/deployments/gpu-operator/values.yaml
```

> [!NOTE]
> Replace `v1.7.0` in the above command with the version you want to use.
