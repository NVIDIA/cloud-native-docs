<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Local Package Repository

The `driver` container deployed as part of the GPU Operator requires certain packages to be available as part of the
driver installation. In restricted internet access or air-gapped installations, users are required to create a
local mirror repository for their OS distribution and make the following packages available:

> [!NOTE]
> KERNEL_VERSION is the underlying running kernel version on the GPU node
> GCC_VERSION is the gcc version matching the one used for building underlying kernel

Configuring a local package repository is not necessary for clusters that
can run precompiled-drivers.

## Required Packages

```yaml
ubuntu:
   linux-headers-${KERNEL_VERSION}
   linux-image-${KERNEL_VERSION}
   linux-modules-${KERNEL_VERSION}

centos:
   elfutils-libelf.x86_64
   elfutils-libelf-devel.x86_64
   kernel-headers-${KERNEL_VERSION}
   kernel-devel-${KERNEL_VERSION}
   kernel-core-${KERNEL_VERSION}
   gcc-${GCC_VERSION}

rhel/rhcos:
   kernel-headers-${KERNEL_VERSION}
   kernel-devel-${KERNEL_VERSION}
   kernel-core-${KERNEL_VERSION}
   gcc-${GCC_VERSION}
```

For example, for Ubuntu, these packages can be found at `archive.ubuntu.com`.
This is the mirror to be replicate locally for your cluster.
You can use `apt-mirror` to mirror these packages to your local package repository server.

For CentOS, `reposync` can be used to create the local mirror.

After all the required packages are mirrored to the local repository, repo lists need to be created following
distribution specific documentation. A `ConfigMap` containing the repo list file needs to be created in
the namespace where the GPU Operator gets deployed.

An example of repo list is shown below for Ubuntu 22.04 (access to local package repository via HTTP):

`custom-repo.list`:

```text
deb [arch=amd64] http://<local pkg repository>/ubuntu/mirror/archive.ubuntu.com/ubuntu jammy main universe
deb [arch=amd64] http://<local pkg repository>/ubuntu/mirror/archive.ubuntu.com/ubuntu jammy-updates main universe
deb [arch=amd64] http://<local pkg repository>/ubuntu/mirror/archive.ubuntu.com/ubuntu jammy-security main universe
```

An example of repo list is shown below for Ubuntu 20.04 (access to local package repository via HTTP):

`custom-repo.list`:

```text
deb [arch=amd64] http://<local pkg repository>/ubuntu/mirror/archive.ubuntu.com/ubuntu focal main universe
deb [arch=amd64] http://<local pkg repository>/ubuntu/mirror/archive.ubuntu.com/ubuntu focal-updates main universe
deb [arch=amd64] http://<local pkg repository>/ubuntu/mirror/archive.ubuntu.com/ubuntu focal-security main universe
```

An example of repo list is shown below for CentOS 8 (access to local package repository via HTTP):

`custom-repo.repo`:

```text
[baseos]
name=CentOS Linux $releasever - BaseOS
baseurl=http://<local pkg repository>/repos/centos/$releasever/$basearch/os/baseos/
gpgcheck=0
enabled=1

[appstream]
name=CentOS Linux $releasever - AppStream
baseurl=http://<local pkg repository>/repos/centos/$releasever/$basearch/os/appstream/
gpgcheck=0
enabled=1

[extras]
name=CentOS Linux $releasever - Extras
baseurl=http://<local pkg repository>/repos/centos/$releasever/$basearch/os/extras/
gpgcheck=0
enabled=1
```

Create a `ConfigMap` object from the file:

```console
$ kubectl create configmap repo-config -n gpu-operator --from-file=<path-to-repo-list-file>
```

Update the `custom-repo.list` file and config map as appropriate if the containerization software platform, such as Tanzu, upgrades the Kubernetes cluster nodes to a newer operating system version.

After the config map is created, update `values.yaml` with this information to let the GPU Operator mount the repo configuration
within the `driver` container to pull required packages. Based on the OS distribution the GPU Operator automatically mounts this config map into the appropriate directory.

```yaml
driver:
   repoConfig:
      configMapName: repo-config
```

If self-signed certificates are used for an HTTPS based internal repository then you must add a config map for those certificates.
You then specify the config map during the GPU Operator install.
Based on the OS distribution the GPU Operator automatically mounts this config map into the appropriate directory.
Similarly, the certificate file format and suffix, such as `.crt` or `.pem`, also depends on the OS distribution.

```console
$ kubectl create configmap cert-config -n gpu-operator --from-file=<path-to-cert-file-1> --from-file=<path-to-cert-file-2>
```

```yaml
driver:
   certConfig:
      name: cert-config
```
