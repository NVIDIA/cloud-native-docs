<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# MIG Manager with Preinstalled Drivers

MIG Manager supports preinstalled drivers.
Information in the preceding sections still applies, however there are a few additional details to consider.

Throughout, replace `<gpu-operator-version>` with your target GPU Operator release.

## Install

During GPU Operator installation, `driver.enabled=false` must be set. The following options
can be used to install the GPU Operator:

```console
$ helm install gpu-operator \
    -n gpu-operator --create-namespace \
    nvidia/gpu-operator \
    --version=<gpu-operator-version> \
    --set driver.enabled=false
```

## Managing Host GPU Clients

MIG Manager stops all operator-managed pods that have access to GPUs when applying a MIG reconfiguration.
When drivers are preinstalled, there can be GPU clients on the host that also need to be stopped.

When drivers are preinstalled, MIG Manager attempts to stop and restart a list of systemd services on the host across a MIG reconfiguration.
The list of services is specified in the `default-gpu-clients` ConfigMap.

The following sample GPU clients file, `clients.yaml`, is used to create the `default-gpu-clients` ConfigMap:

```yaml
version: v1
systemd-services:
  - nvsm.service
  - nvsm-mqtt.service
  - nvsm-core.service
  - nvsm-api-gateway.service
  - nvsm-notifier.service
  - nv_peer_mem.service
  - nvidia-dcgm.service
  - dcgm.service
  - dcgm-exporter.service
```

You can modify the list by editing the ConfigMap after installation.
Alternatively, you can create a custom ConfigMap for use by MIG Manager by performing the following steps:

1. Create the `gpu-operator` namespace:

   ```console
   $ kubectl create namespace gpu-operator
   ```

1. Create a `ConfigMap` containing the custom `clients.yaml` file with a list of GPU clients:

   ```console
   $ kubectl create configmap -n gpu-operator gpu-clients --from-file=clients.yaml
   ```

1. Install the GPU Operator:

   ```console
   $ helm install gpu-operator \
       -n gpu-operator --create-namespace \
       nvidia/gpu-operator \
       --version=<gpu-operator-version> \
       --set migManager.gpuClientsConfig.name=gpu-clients \
       --set driver.enabled=false
   ```
