<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Special Considerations for Service Meshes

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
