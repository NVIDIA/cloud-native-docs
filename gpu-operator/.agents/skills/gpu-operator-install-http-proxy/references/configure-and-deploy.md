<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# HTTP Proxy Configuration (non-Openshift) and Deploy

> [!NOTE]
> Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases).

First, get the `values.yaml` file used for GPU Operator configuration:

```console
$ curl -sO https://raw.githubusercontent.com/NVIDIA/gpu-operator/<gpu-operator-version>/deployments/gpu-operator/values.yaml
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

> [!NOTE]
> * Proxy related ENV are automatically injected by GPU Operator into the `driver` container to indicate proxy information used when downloading necessary packages.
> * If HTTPS Proxy server is setup then change the values of HTTPS_PROXY and https_proxy to use `https` instead.

## Deploy GPU Operator

Download and deploy GPU Operator Helm Chart with the updated `values.yaml`.

Fetch the chart from the NGC repository:

```console
$ helm fetch https://helm.ngc.nvidia.com/nvidia/charts/gpu-operator-<gpu-operator-version>.tgz
```

Install the GPU Operator with updated `values.yaml`:

```console
$ helm install --wait gpu-operator \
     -n gpu-operator --create-namespace \
     gpu-operator-<gpu-operator-version>.tgz \
     -f values.yaml
```

Check the status of the pods to ensure all the containers are running:

```console
$ kubectl get pods -n gpu-operator
```
