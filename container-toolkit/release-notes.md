% Date: September 21 2021

% Author: elezar

(toolkit-release-notes)=

# Release Notes

This document describes the new features, improvements, fixed and known issues for the NVIDIA Container Toolkit.

______________________________________________________________________

## NVIDIA Container Toolkit 1.14

This release of the NVIDIA Container Toolkit `v1.14` is a feature release.

The following packages are included:

- `libnvidia-container 1.14.0`
- `nvidia-container-toolkit 1.14.0`
- `nvidia-container-runtime 3.14.0`
- `nvidia-docker2 2.14.0`

   ```{note}
   This is the last release that includes the `nvidia-container-runtime`
   and `nvidia-docker2` packages.
   All required functionality is included in the `nvidia-container-toolkit` package.
   This toolkit package includes a utility to configure the Docker daemon to use the NVIDIA Container Runtime.
   ```

The following `container-toolkit` containers are included:

- `nvcr.io/nvidia/k8s/container-toolkit:v1.14.0-centos7`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.14.0-ubi8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.14.0-ubuntu20.04`

### Fixes and Features

- Improved support for the Container Device Interface (CDI) on Tegra-based systems.

- Simplified the packaging and distribution of the toolkit.

  Beginning with this release, unified `.deb` and `.rpm` packages are distributed.
  These packages are compatible with all supported distributions.
  This enhancement simplifies the installation process instead of releasing distributions-specific packages.

#### Enhancements to libnvidia-container

- Added logic to generate the `nvc.h` header file automatically so that the version does not need to be updated explicitly.
- Added the Shared Compiler Library, `libnvidia-gpucomp.so`, to the list of included compute libraries.
- Added OpenSSL 3 support to the Encrypt / Decrypt library.

#### Enhancements to container-toolkit container images

- Updated the CUDA base image version to 12.2.0.
- Standardized the environment variable names that are used to configure container engines.
- Removed installation of the `nvidia-experimental` runtime.
  This runtime is superceded by the NVIDIA Container Runtime in CDI mode.
- Set `NVIDIA_VISIBLE_DEVICES=void` to prevent injection of NVIDIA devices and drivers into the NVIDIA Container Toolkit container.

## NVIDIA Container Toolkit 1.13.5

This release of the NVIDIA Container Toolkit `v1.13.5` is a bugfix release.

The following packages are included:

- `nvidia-container-toolkit 1.13.5`
- `libnvidia-container-tools 1.13.5`
- `libnvidia-container1 1.13.5`

The following `container-toolkit` containers are included:

- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.5-centos7`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.5-ubi8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.5-ubuntu20.04` (also as `nvcr.io/nvidia/k8s/container-toolkit:v1.13.5`)

### Fixes and Features

* Removed the dependency on `coreutils` when installing the NVIDIA Container Toolkit on RPM-based systems. Now the packages can be installed on clean systems using, for example, Anaconda.
* Added support for detecting GSP firmware at custom paths when generating CDI specifications.

#### specific to libnvidia-container

- Added the Shared Compiler Library, `libnvidia-gpucomp.so`, to the list of included compute libaries.

## NVIDIA Container Toolkit 1.13.4

This release of the NVIDIA Container Toolkit `v1.13.4` is a bugfix release.

The following packages are included:

- `nvidia-container-toolkit 1.13.4`
- `libnvidia-container-tools 1.13.4`
- `libnvidia-container1 1.13.4`

The following `container-toolkit` containers are included:

- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.4-centos7`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.4-ubi8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.4-ubuntu20.04` (also as `nvcr.io/nvidia/k8s/container-toolkit:v1.13.4`)

### Fixes and Features
#### specific to container-toolkit container images

- Bumped the CUDA base image version to 12.1.0

## NVIDIA Container Toolkit 1.13.3

This release of the NVIDIA Container Toolkit `v1.13.3` is a bugfix release.

The following packages are included:

- `nvidia-container-toolkit 1.13.3`
- `libnvidia-container-tools 1.13.3`
- `libnvidia-container1 1.13.3`

The following `container-toolkit` containers are included:

- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.3-centos7`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.3-ubi8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.3-ubuntu20.04` (also as `nvcr.io/nvidia/k8s/container-toolkit:v1.13.3`)

### Fixes and Features

- Fixed permissions in generated CDI specification files. Specifications files are now generated with `644` permissions to allow non-root users to read these. This means that rootless applications such as Podman can also read the specifications to inject CDI devices.
- Fixed a bug that created an incorrect symlink to `nvidia-smi` on WSL2 systems with multiple driver stores. The bug was triggered sometimes when a system had an integrated GPU and a discrete NVIDIA GPU, for example.
- Fixed a that caused CDI specification generation for managment containers to fail. The bug was triggered when the driver version did not include a patch component its semantic version number.
- Fixed a bug where additional modifications -- such as the injection of graphics libraries and devices -- were applied in CDI mode.
- Fixed loading of kernel modules and creation of device nodes in containerized use cases when using the `nvidia-ctk system create-dev-char-symlinks` command.

#### specific to container-toolkit container images

- Added support for specifying options using the same environment variable across supported container runtimes. This simplifies integration with the GPU Operator.

## NVIDIA Container Toolkit 1.13.2

This release of the NVIDIA Container Toolkit `v1.13.2` is a bugfix release.

The following packages are included:

- `nvidia-container-toolkit 1.13.2`
- `libnvidia-container-tools 1.13.2`
- `libnvidia-container1 1.13.2`

The following `container-toolkit` containers are included:

- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.2-centos7`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.2-ubi8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.2-ubuntu20.04` (also as `nvcr.io/nvidia/k8s/container-toolkit:v1.13.2`)

### Fixes and Features

- Added `nvidia-container-runtime-hook.path` config option to specify NVIDIA Container Runtime Hook path explicitly.
- Fixed a bug in creation of `/dev/char` symlinks by failing operation if kernel modules are not loaded.
- Added an option to load kernel modules when creating device nodes
- Added option to create device nodes when creating `/dev/char` symlinks
- Fixed a bug where failures to open debug log files were considered fatal errors. This could cause failures in rootless environments when the user had insufficient permissions to open the log file.

#### specific to libnvidia-container

- Added OpenSSL 3 support to the Encrypt / Decrypt library.

#### specific to container-toolkit container images

- Bumped CUDA base image version to 12.1.1.

## NVIDIA Container Toolkit 1.13.1

This release of the NVIDIA Container Toolkit `v1.13.1` is a bugfix release.

The following packages are included:

- `nvidia-container-toolkit 1.13.1`
- `libnvidia-container-tools 1.13.1`
- `libnvidia-container1 1.13.1`

The following `container-toolkit` containers are included:

- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.1-centos7`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.1-ubi8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.1-ubuntu20.04` (also as `nvcr.io/nvidia/k8s/container-toolkit:v1.13.1`)

### Fixes and Features

- Fixed a bug which would cause the update of an ldcache in the container to fail for images that do no use ldconfig (e.g. `busybox`).
- Fixed a bug where a failure to determine the CUDA driver version would cause the container to fail to start if `NVIDIA_DRIVER_CAPABILITIES` included `graphics` or `display` on Debian systems.
- Fixed CDI specification generation on Debian systems.

## NVIDIA Container Toolkit 1.13.0

This release of the NVIDIA Container Toolkit `v1.13.0` adds the following major features:

- Improved support for the Container Device Interface (CDI) specifications for GPU devices when using the NVIDIA Container Toolkit in the context of the GPU Operator.
- Added the generation CDI specifications on WSL2-based systems using the `nvidia-ctk cdi generate` command. This is now the recommended mechanism for using GPUs on WSL2 and `podman` is the recommended container engine.

The following packages are included:

- `nvidia-container-toolkit 1.13.0`
- `libnvidia-container-tools 1.13.0`
- `libnvidia-container1 1.13.0`

The following `container-toolkit` containers are included:

- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.0-centos7`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.0-ubi8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.13.0-ubuntu20.04` (also as `nvcr.io/nvidia/k8s/container-toolkit:v1.13.0`)

The following packages have also been updated to depend on `nvidia-container-toolkit` of at least `1.13.0`:

- `nvidia-container-runtime 3.13.0`
- `nvidia-docker2 2.13.0`

:::{note}
This will be the last release that updates the `nvidia-container-runtime` and `nvidia-docker2` packages. All required functionality is now included in the `nvidia-container-toolkit` package. This includes a utility to configure the Docker daemon to use the NVIDIA Container Runtime.
:::

### Packaging Changes

- Fixed a bug in the uninstall scriplet on RPM-based systems that would issue an error due to a missing `nvidia-container-runtime-hook` symlink. This did not prevent the uninstallation of the package.
- Removed `fedora35` as a packaging target. Use the `centos8` packages instead.

### Fixes and Features

- Fixed a bug when running containers using a generated CDI specification or when `NVIDIA_DRIVER_CAPABILITIES` includes `graphics` or `display` or is set to `all`. Now, containers no longer fail with an error message indicating a missing `/dev/dri` or `/dev/nvidia-caps` path.
- Added support for detecting and injecting multiple GSP firmware files as required by the `525.x` versions of the NVIDIA GPU drivers.
- Fixed an issue that caused the `nvidia-ctk` path to be blank in generated CDI specifications.
- Fixed missing NVML symbols for `nvidia-ctk` on some platforms.  For more information, see [issue #49](https://github.com/NVIDIA/nvidia-container-toolkit/issues/49).

#### specific to libnvidia-container

- Added support for detecting and injecting multiple GSP firmware files as required by the `525.x` versions of the NVIDIA GPU drivers.
- Fixed a segmentation fault when RPC initialization fails.
- Changed the centos variants of the NVIDIA Container Library to use a static libtirpc v1.3.2 to prevent errors when using RPC internally.
- Removed `fedora35` as a packaging target. Use the `centos8` packages instead.

#### specific to container-toolkit container images

- Added `--cdi-enabled` flag to toolkit config. When this is set, a CDI specification for use in management containers will be generated.
- Fixed bug where `nvidia-ctk` was not installed onto the host when installing the rest of the toolkit components.
- Updated the NVIDIA Container Toolkit config to use the installed `nvidia-ctk` path.
- Updated the installation of the experimental runtime to use `nvidia-container-runtime.experimental` as an executable name instead of `nvidia-container-runtime-experimental`. This aligns with the executables added for the mode-specific runtimes.
- Added the installation and configuration of mode-specific runtimes for `cdi` and `legacy` modes.
- Updated the CUDA base images to `12.1.0`.
- Added an `nvidia-container-runtime.modes.cdi.annotation-prefixes` config option that allows the CDI annotation prefixes that are read to be overridden. This setting is used to update the `containerd` config to allow these annotations to be visible by the low-level runtime.
- Added tooling to create device nodes when generating CDI specification for management containers. This ensures that the CDI specification for management containers has access to the required control devices.
- Added an `nvidia-container-runtime.runtimes` config option to set the low-level runtime for the NVIDIA Container Runtime. This can be used on Crio-based systems where `crun` is the configured default low-level runtime.

### Known Issues

## NVIDIA Container Toolkit 1.12.1

This release of the NVIDIA Container Toolkit `v1.12.1` is primarily a bugfix release.

### Packaging Changes

- Fixed a bug in the uninstall scriplet on RPM-based systems that would issue an error due to a missing `nvidia-container-runtime-hook` symlink. This did not prevent the uninstallation of the package.
- Removed `fedora35` as a packaging target. Use the `centos8` packages instead.

### Fixes and Features

- Fixed a bug when running containers using a generated CDI specification or when `NVIDIA_DRIVER_CAPABILITIES` includes `graphics` or `display` or is set to `all`. Now, containers no longer fail with an error message indicating a missing `/dev/dri` or `/dev/nvidia-caps` path.
- Added support for detecting and injecting multiple GSP firmware files as required by the `525.x` versions of the NVIDIA GPU drivers.
- Fixed an issue that caused the `nvidia-ctk` path to be blank in generated CDI specifications.
- Fixed missing NVML symbols for `nvidia-ctk` on some platforms.  For more information, see [issue #49](https://github.com/NVIDIA/nvidia-container-toolkit/issues/49).

#### specific to libnvidia-container

- Added support for detecting and injecting multiple GSP firmware files as required by the `525.x` versions of the NVIDIA GPU drivers.

#### specific to container-toolkit container images

- Updated CUDA base images to `12.1.0`.

## NVIDIA Container Toolkit 1.12.0

This release of the NVIDIA Container Toolkit `v1.12.0` adds the following major features:

- Improved support for headless Vulkan applications in containerized environments.
- Tooling to generate Container Device Interface (CDI) specifications for GPU devices. The use of CDI is now the recommended mechanism for using GPUs in `podman`.

The following packages are included:

- `nvidia-container-toolkit 1.12.0`
- `libnvidia-container-tools 1.12.0`
- `libnvidia-container1 1.12.0`

The following `container-toolkit` containers are included:

- `nvcr.io/nvidia/k8s/container-toolkit:v1.12.0-centos7`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.12.0-ubi8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.12.0-ubuntu18.04`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.12.0-ubuntu20.04` (also as `nvcr.io/nvidia/k8s/container-toolkit:v1.12.0`)

The following packages have also been updated to depend on `nvidia-container-toolkit` of at least `1.12.0`:

- `nvidia-container-runtime 3.12.0`
- `nvidia-docker2 2.12.0`

:::{note}
This will be the last release that updates the `nvidia-container-runtime` and `nvidia-docker2` packages. All required functionality is now included in the `nvidia-container-toolkit` package. This includes a utility to configure the Docker daemon to use the NVIDIA Container Runtime.
:::

### Packaging Changes

- The `nvidia-container-toolkit` packages was updated to allow upgrades from pre-`v1.11.0` versions of the package without removing the `nvidia-container-runtime-hook` executable.
- On certain distributions, full mirrors have been removed. The links to the `.list` and `.repo` files for Debian and RPM-based distributions respectively have been maintained to ensure that the official installation instructions continue to function. This change serves to further optimize the size of our package repository.

### Fixes and Features

- Add `nvidia-ctk cdi generate` command to generate CDI specifications for available NVIDIA devices. The generated CDI specification can be used to provide access to NVIDIA devices in CDI-enabled container engines such as `podman` -- especially in the rootless case.
- Add full support for headless Vulkan applications in containerized environments when `NVIDIA_DRIVER_CAPABILITIES` includes
  `graphics` or `display`. This includes the injection of Vulkan ICD loaders as well as direct rendering devices.
- Improve the logging of errors in the NVIDIA Container Runtime.

#### specific to libnvidia-container

- Include the NVVM compiler library in the set of injected compute libraries
- Skip the creation of files that are already mounted to allow paths such as `/var/run` to be mounted into containers.
- Add `nvcubins.bin` to DriverStore components under WSL2

#### specific to container-toolkit container images

- Update CUDA base images to `12.0.1`

### Known Issues

- When running a container using CDI or if `NVIDIA_DRIVER_CAPABILITIES` includes `graphics` or `display`, and error may be raised citing missing
  `/dev/dri` and / or `/dev/nvidia-caps` paths in container if the selected device does not have such nodes associated with it.

```console
$ docker run -it --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=nvidia.com/gpu=0 nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi -L
    docker: Error response from daemon: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: error running hook #1: error running hook: exit status 1, stdout: , stderr: chmod: cannot access '/var/lib/docker/overlay2/9069fafcb6e39ccf704fa47b52ca92a1d48ca5ccfedd381f407456fb6cd3f9f0/merged/dev/dri': No such file or directory: unknown.
    ERRO[0000] error waiting for container: context canceled
```

This issue has been addressed in the `v1.12.1` release.

## NVIDIA Container Toolkit 1.11.0

This release of the NVIDIA Container Toolkit `v1.11.0` is primarily targeted at adding support for injection of GPUDirect Storage and MOFED devices into containerized environments.

The following packages are included:

- `nvidia-container-toolkit 1.11.0`
- `libnvidia-container-tools 1.11.0`
- `libnvidia-container1 1.11.0`

The following `container-toolkit` containers are included:

- `nvcr.io/nvidia/k8s/container-toolkit:v1.11.0-centos7`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.11.0-ubi8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.11.0-ubuntu18.04`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.11.0-ubuntu20.04` (also as `nvcr.io/nvidia/k8s/container-toolkit:v1.11.0`)

The following packages have also been updated to depend on `nvidia-container-toolkit` of at least `1.11.0`:

- `nvidia-container-runtime 3.11.0`

Note that this release does not include an update to `nvidia-docker2` and is compatible with `nvidia-docker2 2.11.0`.

### Packaging Changes

- An `nvidia-container-toolkit-base` package has been introduced that allows for the higher-level components to be
  installed in cases where the NVIDIA Container Runtime Hook, NVIDIA Container CLI, and NVIDIA Container Library are not required.
  This includes Tegra-based systems where the CSV mode of the NVIDIA Container Runtime is used.
- The package repository includes support for Fedora 35 packages.
- The package repository includes support for RHEL 8.6. This redirects to the Centos 8 packages.
- Mirrors for older distributions have been removed to limit the size of the package repository.

### Fixes and Features

- Fix bug in CSV mode where libraries listed as `sym` entries in mount specification are not added to the LDCache.
- Rename the `nvidia-container-toolkit` executable to `nvidia-container-runtime-hook` to better indicate intent.
  A symlink named `nvidia-container-toolkit` is created that points to the `nvidia-container-runtime-hook` executable.
- Inject platform files into container on Tegra-based systems to allow for future support of these systems in the GPU Device Plugin.
- Add `cdi` mode to NVIDIA Container Runtime
- Add discovery of GPUDirect Storage (`nvidia-fs*`) devices if the `NVIDIA_GDS` environment variable of the container is set to `enabled`
- Add discovery of MOFED Infiniband devices if the `NVIDIA_MOFED` environment variable of the container is set to `enabled`
- Add `nvidia-ctk runtime configure` command to configure the Docker config file (e.g. `/etc/docker/daemon.json`) for use with the NVIDIA Container Runtime.

#### specific to libnvidia-container

- Fix bug where LDCache was not updated when the `--no-pivot-root` option was specified
- Preload `libgcc_s.so.1` on arm64 systems

#### specific to container-toolkit container images

- Update CUDA base images to `11.7.1`
- Allow `accept-nvidia-visible-devices-*` config options to be set by toolkit container

### Known Issues

- When upgrading from an earlier version of the NVIDIA Container Toolkit on RPM-based systems, a package manager such as `yum` may remove
  the installed `/usr/bin/nvidia-container-runtime-hook` executable due to the post-uninstall hooks defined in the older package version. To avoid this
  problem either remove the older version of the `nvidia-container-toolkit` before installing `v1.11.0` or **reinstall** the `v1.11.0` package if the
  `/usr/bin/nvidia-container-runtime-hook` file is missing. For systems where the `v1.11.0` version of the package has already been installed and left
  in an unusable state, running `yum reinstall -y nvidia-container-toolkit-1.11.0-1` should address this issue.

- The `container-toolkit:v1.11.0` images have been released with the following known HIGH Vulnerability CVEs. These are from the base images and are not in libraries used by the components included in the container image as part of the NVIDIA Container Toolkit:

  - `nvcr.io/nvidia/k8s/container-toolkit:v1.11.0-centos7`:

    - `systemd` - [CVE-2022-2526](https://access.redhat.com/security/cve/CVE-2022-2526)
    - `systemd-libs` - [CVE-2022-2526](https://access.redhat.com/security/cve/CVE-2022-2526)

  - `nvcr.io/nvidia/k8s/container-toolkit:v1.11.0-ubi8`:

    - `systemd` - [CVE-2022-2526](https://access.redhat.com/security/cve/CVE-2022-2526)
    - `systemd-libs` - [CVE-2022-2526](https://access.redhat.com/security/cve/CVE-2022-2526)
    - `systemd-pam` - [CVE-2022-2526](https://access.redhat.com/security/cve/CVE-2022-2526)

  - `nvcr.io/nvidia/k8s/container-toolkit:v1.11.0-ubuntu18.04`:

    - `libsystemd0` - [CVE-2022-2526](http://people.ubuntu.com/~ubuntu-security/cve/CVE-2022-2526)
    - `libudev1` - [CVE-2022-2526](http://people.ubuntu.com/~ubuntu-security/cve/CVE-2022-2526)

## NVIDIA Container Toolkit 1.10.0

This release of the NVIDIA Container Toolkit `v1.10.0` is primarily targeted at improving support for Tegra-based systems.
It sees the introduction of a new mode of operation for the NVIDIA Container Runtime that makes modifications to the incoming OCI runtime
specification directly instead of relying on the NVIDIA Container CLI.

The following packages are included:

- `nvidia-container-toolkit 1.10.0`
- `libnvidia-container-tools 1.10.0`
- `libnvidia-container1 1.10.0`

The following `container-toolkit` containers are included:

- `nvcr.io/nvidia/k8s/container-toolkit:v1.10.0-centos7`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.10.0-ubi8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.10.0-ubuntu18.04`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.10.0-ubuntu20.04` (also as `nvcr.io/nvidia/k8s/container-toolkit:v1.10.0`)

The following packages have also been updated to depend on `nvidia-container-toolkit` of at least `1.10.0`:

- `nvidia-container-runtime 3.10.0`
- `nvidia-docker2 2.11.0`

### Packaging Changes

- The package repository includes support for Ubuntu 22.04. This redirects to the Ubuntu 18.04 packages.
- The package repository includes support for RHEL 9.0. This redirects to the Centos 8 packages.
- The package repository includes support for OpenSUSE 15.2 and 15.3. These redirect to the OpenSUSE 15.1 packages.
- The `nvidia-docker2` Debian packages were updated to allow installation with `moby-engine` instead of requiring `docker-ce`, `docker-ee`, or `docker.io`.

### Fixes and Features

- Add `nvidia-ctk` CLI to provide utilities for interacting with the NVIDIA Container Toolkit
- Add a new mode to the NVIDIA Container Runtime targeted at Tegra-based systems using CSV-file based mount specifications.
- Use default config instead of raising an error if config file cannot be found
- Switch to debug logging to reduce log verbosity
- Support logging to logs requested in command line
- Allow low-level runtime path to be set explicitly as `nvidia-container-runtime.runtimes` option
- Fix failure to locate low-level runtime if PATH envvar is unset
- Add `--version` flag to all CLIs

#### specific to libnvidia-container

- Bump `libtirpc` to `1.3.2`
- Fix bug when running host ldconfig using glibc compiled with a non-standard prefix
- Add `libcudadebugger.so` to list of compute libraries
- \[WSL2\] Fix segmentation fault on WSL2s system with no adpaters present (e.g. `/dev/dxg` missing)
- Ignore pending MIG mode when checking if a device is MIG enabled
- \[WSL2\] Fix bug where `/dev/dxg` is not mounted when `NVIDIA_DRIVER_CAPABILITIES` does not include "compute"

#### specific to container-toolkit container images

- Fix a bug in applying runtime configuratin to containerd when version 1 config files are used
- Update base images to CUDA 11.7.0
- Multi-arch images for Ubuntu 18.04 are no longer available. (For multi-arch support for the container toolkit images at least Ubuntu 20.04 is required)
- Centos 8 images are no longer available since the OS is considered EOL and no CUDA base image updates are available
- Images are no longer published to Docker Hub and the NGC images should be used instead

### Known Issues

- The `container-toolkit:v1.10.0` images have been released with the following known HIGH Vulnerability CVEs. These are from the base images and are not in libraries used by the components included in the container image as part of the NVIDIA Container Toolkit:

  - `nvcr.io/nvidia/k8s/container-toolkit:v1.10.0-centos7`:

    - `xz` - [CVE-2022-1271](https://access.redhat.com/security/cve/CVE-2022-1271)
    - `xz-libs` - [CVE-2022-1271](https://access.redhat.com/security/cve/CVE-2022-1271)

  - `nvcr.io/nvidia/k8s/container-toolkit:v1.10.0-ubi8`:

    - `xz-libs` - [CVE-2022-1271](https://access.redhat.com/security/cve/CVE-2022-1271)

## NVIDIA Container Toolkit 1.9.0

This release of the NVIDIA Container Toolkit `v1.9.0` is primarily targeted at adding multi-arch support for the `container-toolkit` images.
It also includes enhancements for use on Tegra-systems and some notable bugfixes.

The following packages are included:

- `nvidia-container-toolkit 1.9.0`
- `libnvidia-container-tools 1.9.0`
- `libnvidia-container1 1.9.0`

The following `container-toolkit` containers are included (note these are also available on Docker Hub as `nvidia/container-toolkit`):

- `nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-centos7`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-centos8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-ubi8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.9.0` and `nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-ubuntu18.04`

The following packages have also been updated to depend on `nvidia-container-toolkit` of at least `1.9.0`:

- `nvidia-container-runtime 3.9.0`
- `nvidia-docker2 2.10.0`

### Fixes and Features

#### specific to libnvidia-container

- Add additional check for Tegra in `/sys/.../family` file in CLI
- Update jetpack-specific CLI option to only load Base CSV files by default
- Fix bug (from `v1.8.0`) when mounting GSP firmware into containers without `/lib` to `/usr/lib` symlinks
- Update `nvml.h` to CUDA 11.6.1 nvML_DEV 11.6.55
- Update switch statement to include new brands from latest `nvml.h`
- Process all `--require` flags on Jetson platforms
- Fix long-standing issue with running ldconfig on Debian systems

#### specific to container-toolkit container images

- Publish an `nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-ubuntu20.04` image based on `nvidia/cuda:11.6.0-base-ubuntu20.04`

- The following images are available as multi-arch images including support for `linux/amd64` and `linux/arm64` platforms:

  - `nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-centos8`
  - `nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-ubi8`
  - `nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-ubuntu18.04` (and `nvcr.io/nvidia/k8s/container-toolkit:v1.9.0`)
  - `nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-ubuntu20.04`

### Known Issues

- The `container-toolkit:v1.9.0` images have been released with the following known HIGH Vulnerability CVEs. These are from the base images and are not in libraries used by the components included in the container image as part of the NVIDIA Container Toolkit:

  - `nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-centos7`:

    - `expat` - [CVE-2022-25235](https://access.redhat.com/security/cve/CVE-2022-25235)
    - `expat` - [CVE-2022-25236](https://access.redhat.com/security/cve/CVE-2022-25236)
    - `expat` - [CVE-2022-25315](https://access.redhat.com/security/cve/CVE-2022-25315)

  - `nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-centos8`:

    - `cyrus-sasl-lib` - [CVE-2022-24407](https://access.redhat.com/security/cve/CVE-2022-24407)
    - `openssl`, `openssl-libs` - [CVE-2022-0778](https://access.redhat.com/security/cve/CVE-2022-0778)
    - `expat` - [CVE-2022-25235](https://access.redhat.com/security/cve/CVE-2022-25235)
    - `expat` - [CVE-2022-25236](https://access.redhat.com/security/cve/CVE-2022-25236)
    - `expat` - [CVE-2022-25315](https://access.redhat.com/security/cve/CVE-2022-25315)

  - `nvcr.io/nvidia/k8s/container-toolkit:v1.9.0-ubi8`:

    - `openssl-libs` - [CVE-2022-0778](https://access.redhat.com/security/cve/CVE-2022-0778)

## NVIDIA Container Toolkit 1.8.1

This version of the NVIDIA Container Toolkit is a bugfix release and fixes issue with `cgroup` support found in
NVIDIA Container Toolkit `1.8.0`.

The following packages are included:

- `nvidia-container-toolkit 1.8.1`
- `libnvidia-container-tools 1.8.1`
- `libnvidia-container1 1.8.1`

The following `container-toolkit` containers have are included (note these are also available on Docker Hub as `nvidia/container-toolkit`):

- `nvcr.io/nvidia/k8s/container-toolkit:v1.8.1-centos7`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.8.1-centos8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.8.1-ubi8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.8.1` and `nvcr.io/nvidia/k8s/container-toolkit:v1.8.1-ubuntu18.04`

The following packages have also been updated to depend on `nvidia-container-toolkit` of at least `1.8.1`:

- `nvidia-container-runtime 3.8.1`
- `nvidia-docker2 2.9.1`

### Fixes and Features

#### specific to libnvidia-container

- Fix bug in determining cgroup root when running in nested containers
- Fix permission issue when determining cgroup version under certain conditions

## NVIDIA Container Toolkit 1.8.0

This version of the NVIDIA Container Toolkit adds `cgroupv2` support and removes packaging support for Amazon Linux 1.

The following packages are included:

- `nvidia-container-toolkit 1.8.0`
- `libnvidia-container-tools 1.8.0`
- `libnvidia-container1 1.8.0`

The following `container-toolkit` containers have are included (note these are also available on Docker Hub as `nvidia/container-toolkit`):

- `nvcr.io/nvidia/k8s/container-toolkit:v1.8.0-centos7`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.8.0-centos8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.8.0-ubi8`
- `nvcr.io/nvidia/k8s/container-toolkit:v1.8.0` and `nvcr.io/nvidia/k8s/container-toolkit:v1.8.0-ubuntu18.04`

The following packages have also been updated to depend on `nvidia-container-toolkit` of at least `1.8.0`:

- `nvidia-container-runtime 3.8.0`
- `nvidia-docker2 2.9.0`

### Packaging Changes

- Packages for Amazon Linux 1 are no longer built or published
- The `container-toolkit` container is built and released from the same repository as the NVIDIA Container Toolkit packages.

### Fixes and Features

#### specific to libnvidia-container

- Add `cgroupv2` support
- Fix a bug where the GSP firmware path was mounted with write permissions instead of read-only
- Include the GSP firmware path (if present) in the output of the `nvidia-container-cli list` command
- Add support for injecting PKS libraries into a container

## NVIDIA Container Toolkit 1.7.0

This version of the NVIDIA Container Toolkit allows up to date packages to be installed on Jetson devices.
The following packages are included:

- `nvidia-container-toolkit 1.7.0`
- `libnvidia-container-tools 1.7.0`
- `libnvidia-container1 1.7.0`

The following packages have also been updated to depend on `nvidia-container-toolkit` of at least `1.7.0`:

- `nvidia-container-runtime 3.7.0`
- `nvidia-docker2 2.8.0`

### Packaging Changes

- On Ubuntu `arm64` distributions the `libnvidia-container-tools` package depends on both `libnvidia-container0` and `libnvidia-container1` to support Jetson devices

### Fixes and Features

- Add a `supported-driver-capabilities` config option to allow for a subset of all driver capabilities to be specified
- Makes the fixes from `v1.6.0` to addresses an incompatibility with recent docker.io and containerd.io updates on Ubuntu installations (see [NVIDIA/nvidia-container-runtime#157](https://github.com/NVIDIA/nvidia-container-runtime/issues/157)) available on Jetson devices.

#### specific to libnvidia-container

- Filter command line options based on `libnvidia-container` library version
- Include `libnvidia-container` version in CLI version output
- Allow for `nvidia-container-cli` to load `libnvidia-container.so.0` dynamically on Jetson platforms

## NVIDIA Container Toolkit 1.6.0

This version of the NVIDIA Container Toolkit moves to unify the packaging of the components of the NVIDIA container stack.
The following packages are included:

- `nvidia-container-toolkit 1.6.0`
- `libnvidia-container-tools 1.6.0`
- `libnvidia-container1 1.6.0`

The following packages have also been updated to depend on `nvidia-container-toolkit` of at least `1.6.0`:

- `nvidia-container-runtime 3.6.0`
- `nvidia-docker2 2.7.0`

:::{note}
All the above packages are published to the [libnvidia-container](https://nvidia.github.io/libnvidia-container/) repository.
:::

:::{note}
As of version `2.7.0` the `nvidia-docker2` package depends directly on `nvidia-container-toolkit`.
This means that the `nvidia-container-runtime` package is no longer required and may be uninstalled as part of the upgrade process.
:::

### Packaging Changes

- The `nvidia-container-toolkit` package now provides the `nvidia-container-runtime` executable
- The `nvidia-docker2` package now depends directly on the `nvidia-container-toolkit` directly
- The `nvidia-container-runtime` package is now an architecture-independent meta-package serving only to define a dependency on the `nvidia-container-toolkit` for workflows that require this
- Added packages for Amazon Linux 2 on AARC64 platforms for all components

### Fixes and Features

- Move OCI and command line checks for the NVIDIA Container Runtime to an internal go package (`oci`)
- Update OCI runtime specification dependency to [opencontainers/runtime-spec@a3c33d6](https://github.com/opencontainers/runtime-spec/commit/a3c33d663ebc/) to fix compatibility with docker when overriding clone3 syscall return value \[fixes [NVIDIA/nvidia-container-runtime#157](https://github.com/NVIDIA/nvidia-container-runtime/issues/157)\]
- Use relative path to OCI specification file (`config.json`) if bundle path is not specified as an argument to the nvidia-container-runtime

#### specific to libnvidia-container

- Bump `nvidia-modprobe` dependency to `495.44` in the NVIDIA Container Library to allow for non-root monitoring of MIG devices
- Fix bug that lead to unexpected mount error when `/proc/driver/nvidia` does not exist on the host

### Known Issues

#### Dependency errors when installing older versions of `nvidia-container-runtime` on Debian-based systems

With the release of the `1.6.0` and `3.6.0` versions of the `nvidia-container-toolkit` and
`nvidia-container-runtime` packages, respectively, some files were reorganized and the package
dependencies updated accordingly. (See case 10 in the [Debian Package Transition](https://wiki.debian.org/PackageTransition) documentation).

Due to these new constraints a package manager may not correctly resolve the required version of `nvidia-container-toolkit` when
pinning to versions of the `nvidia-container-runtime` prior to `3.6.0`.

This means that if a command such as:

```console
sudo apt-get install nvidia-container-runtime=3.5.0-1
```

is used to install a specific version of the `nvidia-container-runtime` package, this may fail with the following error message:

```console
Some packages could not be installed. This may mean that you have
requested an impossible situation or if you are using the unstable
distribution that some required packages have not yet been created
or been moved out of Incoming.
The following information may help to resolve the situation:

The following packages have unmet dependencies:
nvidia-container-runtime : Depends: nvidia-container-toolkit (>= 1.5.0) but it is not going to be installed
                            Depends: nvidia-container-toolkit (< 2.0.0) but it is not going to be installed
E: Unable to correct problems, you have held broken packages.
```

In order to address this, the versions of the `nvidia-container-toolkit` package should be specified explicitly to be at most `1.5.1`

```console
sudo apt-get install \
    nvidia-container-runtime=3.5.0-1 \
    nvidia-container-toolkit=1.5.1-1
```

In general, it is suggested that all components of the NVIDIA container stack be pinned to their required versions.

For the `nvidia-container-runtime` `3.5.0` these are:

- `nvidia-container-toolkit 1.5.1`
- `libnvidia-container-tools 1.5.1`
- `libnvidia-container1 1.5.1`

To pin all the package versions above, run:

```console
sudo apt-get install \
    nvidia-container-runtime=3.5.0-1 \
    nvidia-container-toolkit=1.5.1-1 \
    libnvidia-container-tools=1.5.1-1 \
    libnvidia-container1==1.5.1-1
```

## Toolkit Container 1.7.0

### Known issues

- The `container-toolkit:1.7.0-ubuntu18.04` image contains the [CVE-2021-3711](http://people.ubuntu.com/~ubuntu-security/cve/CVE-2021-3711). This CVE affects `libssl1.1` and `openssl` included in the ubuntu-based CUDA `11.4.1` base image. The components of the NVIDIA Container Toolkit included in the container do not use `libssl1.1` or `openssl` and as such this is considered low risk if the container is used as intended; that is to install and configure the NVIDIA Container Toolkit in the context of the NVIDIA GPU Operator.
