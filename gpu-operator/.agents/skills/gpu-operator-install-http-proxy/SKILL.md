---
name: "gpu-operator-install-http-proxy"
description: "Guides users through installing the GPU Operator with HTTP proxy settings. Use when clusters require proxy configuration for image pulls or network access. Trigger keywords - NVIDIA GPU Operator, HTTP proxy, installation, Kubernetes."
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Prerequisites

* Kubernetes cluster is configured with HTTP proxy settings (container runtime should be enabled with HTTP proxy)

# Install GPU Operator in Proxy Environments

## Introduction

This page describes how to successfully deploy the GPU Operator in clusters behind an HTTP proxy.
By default, the GPU Operator requires internet access for the following reasons:

    1) Container images need to be pulled during GPU Operator installation.
    2) The `driver` container needs to download several OS packages prior to driver installation.

       **Tip:**

       Using precompiled-drivers removes the need for the `driver` containers to
       download operating system packages.
To address these requirements, all Kubernetes nodes as well as the `driver` container need proper configuration
in order to direct traffic through the proxy.

This document demonstrates how to configure the GPU Operator so that the `driver` container can successfully
download packages behind a HTTP proxy. Since configuring Kubernetes/container runtime components to use
a proxy is not specific to the GPU Operator, we do not include those instructions here.

The instructions for Openshift are different, so skip the section titled proxy_config_openshift if you are not running Openshift.

## Step 1: HTTP Proxy Configuration for Openshift

For Openshift, it is recommended to use the cluster-wide Proxy object to provide proxy information for the cluster.
Follow the procedure described in [Configuring the cluster-wide proxy](https://docs.openshift.com/container-platform/latest/networking/enable-cluster-wide-proxy.html)
from Red Hat Openshift public documentation. The GPU Operator will automatically inject proxy related ENV into the `driver` container
based on information present in the cluster-wide Proxy object.

## Step 2: HTTP Proxy Configuration

First, get the `values.yaml` file used for GPU Operator configuration:

```console
$ curl -sO https://raw.githubusercontent.com/NVIDIA/gpu-operator/${version}/deployments/gpu-operator/values.yaml
```

Specify `driver.env` in `values.yaml` with appropriate HTTP_PROXY, HTTPS_PROXY, and NO_PROXY environment variables
(in both uppercase and lowercase).

```yaml
driver:
   env:
   - name: HTTPS_PROXY
     value: http://<example.proxy.com:port>
   - name: HTTP_PROXY
     value: http://<example.proxy.com:port>
   - name: NO_PROXY
     value: <example.com>
   - name: https_proxy
     value: http://<example.proxy.com:port>
   - name: http_proxy
     value: http://<example.proxy.com:port>
   - name: no_proxy
     value: <example.com>
```

**Note:**

* Proxy related ENV are automatically injected by GPU Operator into the `driver` container to indicate proxy information used when downloading necessary packages.
* If HTTPS Proxy server is setup then change the values of HTTPS_PROXY and https_proxy to use `https` instead.

## Step 3: Deploy GPU Operator

Download and deploy GPU Operator Helm Chart with the updated `values.yaml`.

Fetch the chart from the NGC repository:

```console
$ helm fetch https://helm.ngc.nvidia.com/nvidia/charts/gpu-operator-${version}.tgz
```

Install the GPU Operator with updated `values.yaml`:

```console
$ helm install --wait gpu-operator \
     -n gpu-operator --create-namespace \
     gpu-operator-${version}.tgz \
     -f values.yaml
```

Check the status of the pods to ensure all the containers are running:

```console
$ kubectl get pods -n gpu-operator
```
