<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Updating NLS Client License Token

In case the NLS client license token needs to be updated, use the following procedure:

Create an empty vGPU license configuration file:

```console
$ sudo touch gridd.conf
```

Generate and download a new NLS client license token. Refer to Section 4.6 of the [NLS User Guide](https://docs.nvidia.com/license-system/latest/pdf/nvidia-license-system-user-guide.pdf) for instructions.

Rename the NLS client license token that you downloaded to `client_configuration_token.tok`.

> [!WARNING]
> The `configMap(configMapName)` is  **deprecated** and will be removed in a future release.
> Use `secrets(secretName)` instead.
> Create a new `licensing-config-new` Secret object in the `gpu-operator` namespace (make sure the name of the secret is not already used in the kubernetes cluster). Both the vGPU license configuration file and the NLS client license token will be added to this Secret:

```console
$ kubectl create secret generic licensing-config-new \
    -n gpu-operator --from-file=gridd.conf --from-file=<path>/client_configuration_token.tok
```

Edit the clusterpolicies by using the command:

```console
$ kubectl edit clusterpolicies.nvidia.com
```

Go to the driver section and replace the following argument:

```console
licensingConfig:
    secretName: licensing-config
```

with

```console
licensingConfig:
    secretName: licensing-config-new
```

Write and exit from the kubectl edit session (you can use :qw for instance if vi utility is used)

GPU Operator sequentially redeploys all the driver pods with this new licensing information.
