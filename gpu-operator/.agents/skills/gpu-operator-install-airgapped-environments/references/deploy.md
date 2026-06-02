<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Deploy GPU Operator

> [!NOTE]
> Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases).

Download and deploy GPU Operator Helm Chart with the updated `values.yaml`.

Fetch the chart from the NGC repository:

```console
$ helm fetch https://helm.ngc.nvidia.com/nvidia/charts/gpu-operator-<gpu-operator-version>.tgz
```

Install the GPU Operator with the customized `values.yaml`:

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
