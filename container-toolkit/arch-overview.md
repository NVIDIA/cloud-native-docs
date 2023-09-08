% Date: August 10 2020

% Author: pramarao

(arch-overview)=

# Architecture Overview

The NVIDIA container stack is architected so that it can be targeted to support any container runtime in the ecosystem.
The components of the stack include:

- The NVIDIA Container Runtime (`nvidia-container-runtime`)
- The NVIDIA Container Runtime Hook (`nvidia-container-toolkit` / `nvidia-container-runtime-hook`)
- The NVIDIA Container Library and CLI (`libnvidia-container1`, `nvidia-container-cli`)

The components of the NVIDIA container stack are packaged as the NVIDIA Container Toolkit.

How these components are used depends on the container runtime being used. For `docker` or `containerd`, the NVIDIA Container Runtime (`nvidia-container-runtime`) is
configured as an OCI-compliant runtime, with the flow through the various components is shown in the following diagram:

```{image} assets/runtime-architecture.png
:width: 800
```

The flow through components for `cri-o` and `lxc` are shown in the following diagram. It should be noted that in this
case the NVIDIA Container Runtime component is not required.

```{image} assets/nvidia-crio-lxc-arch.png
:width: 800
```

Let's take a brief look at each of the components in the NVIDIA container stack, starting
with the lowest level component and working up

## Components and Packages

The main packages of the NVIDIA Container Toolkit are:

- `nvidia-container-toolkit`
- `nvidia-cotnainer-toolkit-base`
- `libnvidia-container-tools`
- `libnvidia-container1`

With the dedpendencies between these packages shown below:

```bash
├─ nvidia-container-toolkit (version)
│    ├─ libnvidia-container-tools (>= version)
│    └─ nvidia-container-toolkit-base (version)
│
├─ libnvidia-container-tools (version)
│    └─ libnvidia-container1 (>= version)
└─ libnvidia-container1 (version)
```

where `version` is used to represent the NVIDIA Container Toolkit version.

:::{note}
In the past the `nvidia-docker2` and `nvidia-container-runtime` packages were also discussed as part of the NVIDIA container stack.
These **packages** should be considered deprecated as their functionality has been merged with the `nvidia-container-toolkit` package.
The packages may still be available to introduce dependencies on `nvidia-container-toolkit` and ensure that older workflows continue to function.
For more information on these packages see the documentation archive for version older than `v1.12.0`.
:::

### The NVIDIA Container Library and CLI

These components are packaged as the `libnvidia-container-tools` and `libnvidia-container1` packages, respectively.

These components provide a library and a simple CLI utility to automatically configure GNU/Linux containers leveraging NVIDIA GPUs.
The implementation relies on kernel primitives and is designed to be agnostic of the container runtime.

`libnvidia-container` provides a well-defined API and a wrapper CLI (called `nvidia-container-cli`) that different runtimes can invoke to
inject NVIDIA GPU support into their containers.

### The NVIDIA Container Runtime Hook

This component is included in the `nvidia-container-toolkit` package.

This component includes an executable that implements the interface required by a `runC` `prestart` hook. This script is invoked by `runC`
after a container has been created, but before it has been started, and is given access to the `config.json` associated with the container
(e.g. this [config.json](https://github.com/opencontainers/runtime-spec/blob/master/config.md#configuration-schema-example=) ). It then takes
information contained in the `config.json` and uses it to invoke the `nvidia-container-cli` CLI with an appropriate set of flags. One of the
most important flags being which specific GPU devices should be injected into the container.

### The NVIDIA Container Runtime

This component is included in the `nvidia-container-toolkit-base` package.

This component used to be a complete fork of `runC` with NVIDIA-specific code injected into it. Since 2019, it is a thin wrapper around the native
`runC` installed on the host system. `nvidia-container-runtime` takes a `runC` spec as input, injects the NVIDIA Container Runtime Hook as
a `prestart` hook into it, and then calls out to the native `runC`, passing it the modified `runC` spec with that hook set.
For versions of the NVIDIA Container Runtime from `v1.12.0`, this runtime also performs additional modifications to the OCI runtime spec to inject
specific devices and mounts not handled by the NVIDIA Container CLI.

It's important to note that this component is not necessarily specific to docker (but it is specific to `runC`).

### The NVIDIA Container Toolkit CLI

This component is included in the `nvidia-container-toolkit-base` package.

This component is a CLI that includes a number of utilities for interacting with the NVIDIA Container Toolkit. This functionality includes configuring
runtimes such as `docker` for use with the NVIDIA Container Toolkit or generating [Container Device Interface (CDI)](https://github.com/container-orchestrated-devices/container-device-interface) specifications.

## Which package should I use then?

Installing the `nvidia-container-toolkit` package is sufficient for all use cases. This
package is continuously being enhanced with additional functionality and tools that simplify working with containers and
NVIDIA devices.

To use Kubernetes with Docker, you need to configure the Docker `daemon.json` to include
a reference to the NVIDIA Container Runtime and set this runtime as the default. The NVIDIA Container Toolkit contains a utility to update this file
as highlighted in the `docker`-specific installation instructions.

See the {doc}`install-guide` for more information on installing the NVIDIA Container Toolkit on various Linux distributions.

### Package Repository

The packages for the various components listed above are available in the `gh-pages` branch of the GitHub repos of these projects. This is particularly
useful for air-gapped deployments that may want to get access to the actual packages (`.deb` and `.rpm`) to support offline installs.

For the different components:

1. `nvidia-container-toolkit`

   - `https://github.com/NVIDIA/libnvidia-container/tree/gh-pages/`

2. `libnvidia-container`

   - `https://github.com/NVIDIA/libnvidia-container/tree/gh-pages/`

:::{note}
As of the release of version `1.6.0` of the NVIDIA Container Toolkit the packages for all components are
published to the `libnvidia-container` `repository <https://nvidia.github.io/libnvidia-container/>` listed above. For older package versions please see the documentation archives.
:::

Releases of the software are also hosted on `experimental` branch of the repository and are graduated to `stable` after test/validation. To get access to the latest
`experimental` features of the NVIDIA Container Toolkit, you may need to add the `experimental` branch to the `apt` or `yum` repository listing. The installation instructions
include information on how to add these repository listings for the package manager.
