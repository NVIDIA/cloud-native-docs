---
name: "gpu-operator-install-service-mesh"
description: "Guides users through GPU Operator service mesh considerations. Use when deploying with Istio or troubleshooting sidecar injection and service mesh interactions."
triggers:
  - NVIDIA GPU Operator
  - service mesh
  - Istio
  - Kubernetes
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - service-mesh
  - istio
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Install GPU Operator with Service Mesh

## Special Considerations for Service Meshes

You can use NVIDIA GPU Operator in a cluster that uses a service mesh provided by Istio CNI or Linkerd CNI.

The typical consideration for using the Operator with a service mesh is that the `k8s-driver-manager` init container
for the `driver` container needs network access to the Kubernetes API server of the cluster.

The data plane---implemented by Istio CNI or Linkerd CNI as proxies running as sidecar containers---must be running for any pod networking to work.
The proxy sidecar containers start only after the init phase of the pod, so init containers are not able to communicate with the API server.

To address the connectivity challenge, NVIDIA recommends disabling injection for the GPU Operator namespace.
Refer to the following documentation for more information:

- [Controlling the injection policy](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#controlling-the-injection-policy)
  in the Istio documentation.
- [Overriding injection](https://linkerd.io/2.14/features/proxy-injection/#overriding-injection)
  in the Linkerd documentation.

## Label the Namespace to Disable Injection

- Label the Operator namespace to prevent automatic injection:

  ```console
  $ kubectl label namespace gpu-operator istio-injection=disabled
  ```

  Or, for Linkerd:

  ```console
  $ kubectl label namespace gpu-operator linkerd.io/inject=disabled
  ```

If the GPU Operator is not already installed, refer to
getting-started
for information about custom options and common installation scenarios.
