<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# HTTP Proxy Configuration for Openshift

For Openshift, it is recommended to use the cluster-wide Proxy object to provide proxy information for the cluster.
Follow the procedure described in [Configuring the cluster-wide proxy](https://docs.openshift.com/container-platform/latest/networking/enable-cluster-wide-proxy.html)
from Red Hat Openshift public documentation. The GPU Operator will automatically inject proxy related ENV into the `driver` container
based on information present in the cluster-wide Proxy object.
