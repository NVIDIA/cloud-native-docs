<!--
  SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0
-->

# Platform Support

````{only} not publish_bsp
```{contents}
:depth: 2
:backlinks: none
:local: true
```
````

## Operating Systems and Kubernetes Platforms

```{list-table}
:header-rows: 1
:stub-columns: 1

* - Operating System
  - Kubernetes
  - Red Hat OpenShift
  - VMware vSphere with Tanzu

* - Ubuntu 22.04
  - 1.29---1.31
  -
  - 8.0 Update 2

* - Red Hat Core OS
  -
  - 4.16
  - 
```

## Container Runtimes

```{list-table}
:header-rows: 1

* - Operating System
  - containerd
  - CRI-O

* - Ubuntu 22.04
  - 1.6, 1.7
  - 1.30

* - Red Hat Core OS
  - None
  - Yes [{sup}`1`](cri-o-ocp)
```

(cri-o-ocp)=
{sup}`1` The CRI-O version supported by OpenShift Container Platform is supported.

## Command-Line Tools

```{list-table}
:header-rows: 1
:widths: 30 70

* - Tool
  - Installation Documentation

* - kubectl (match cluster version)
  - Refer to
    [Install Tools](https://kubernetes.io/docs/tasks/tools/)
    in the Kubernetes documentation for more information.

* - Helm v3 and higher
  - Refer to
    [Install Helm](https://helm.sh/docs/intro/install/)
    in the Helm documentation for more information.
```