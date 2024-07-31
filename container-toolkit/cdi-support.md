% Date: November 11 2022

% Author: elezar

% headings (h1/h2/h3/h4/h5) are # * = -

(cdi-support)=

# Support for Container Device Interface

```{contents}
---
depth: 2
local: true
backlinks: none
---
```

## About the Container Device Interface

As of the `v1.12.0` release the NVIDIA Container Toolkit includes support for generating Container Device Interface (CDI) specifications.

CDI is an open specification for container runtimes that abstracts what *access* to a device, such as an NVIDIA GPU, means, and standardizes access across container runtimes.
Popular container runtimes can read and process the specification to ensure that a device is available in a container.
CDI simplifies adding support for devices such as NVIDIA GPUs because the specification is applicable to all container runtimes that support CDI.

CDI also improves the compatibility of the NVIDIA container stack with certain features such as rootless containers.

## Generating a CDI specification

### Prerequisites

- You installed either the NVIDIA Container Toolkit or you installed the `nvidia-container-toolkit-base` package.
  The base package includes the container runtime and the `nvidia-ctk` command-line interface, but avoids
  installing the container runtime hook and transitive dependencies.
  The hook and dependencies are not needed on machines that use CDI exclusively.

- You installed an NVIDIA GPU Driver.

### Procedure

Two typical locations for CDI specifications are `/etc/cdi/` and `/var/run/cdi`.
However, the path to create and use can depend on the container engine that you use.

1. Generate the CDI specification file:

   ```console
   $ sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
   ```

   The sample command uses `sudo` to ensure that the file at `/etc/cdi/nvidia.yaml` is created.
   You can omit the `--output` argument to print the generated specification to `STDOUT`.

   *Example Output*

   ```output
   INFO[0000] Auto-detected mode as "nvml"
   INFO[0000] Selecting /dev/nvidia0 as /dev/nvidia0
   INFO[0000] Selecting /dev/dri/card1 as /dev/dri/card1
   INFO[0000] Selecting /dev/dri/renderD128 as /dev/dri/renderD128
   INFO[0000] Using driver version xxx.xxx.xx
   ...
   ```

1. (Optional) Check the names of the generated devices:

   ```console
   $ nvidia-ctk cdi list
   ```

   The following example output is for a machine with a single GPU that does not support MIG.

   ```output
   INFO[0000] Found 9 CDI devices
   nvidia.com/gpu=all
   nvidia.com/gpu=0
   ```

```{important}
You must generate a new CDI specification after any of the following changes:

- You change the device or CUDA driver configuration.
- You upgrade the Linux kernel.

A configuration change can occur when MIG devices are created or removed, or when the driver is upgraded.
```

## Running a Workload with CDI

Using CDI to inject NVIDIA devices can conflict with using the NVIDIA Container Runtime hook.
This means that if a `/usr/share/containers/oci/hooks.d/oci-nvidia-hook.json` file exists, delete it
or ensure that you do not run containers with the `NVIDIA_VISIBLE_DEVICES` environment variable set.

The use of the CDI specification is dependent on the CDI-enabled container engine or CLI that you use.
In the case of `podman`, for example, releases as of `v4.1.0` include support for specifying CDI devices in the `--device` argument.
Assuming that you generated a CDI specification as in the preceding section, running a container with access to all NVIDIA GPUs would require the following command:

```console
$ podman run --rm --device nvidia.com/gpu=all --security-opt=label=disable ubuntu nvidia-smi -L
```

The preceding sample command should show the same output as running `nvidia-smi -L` on the host.

The CDI specification also contains references to individual GPUs or MIG devices.
You can request these by specifying their names when launching a container, such as the following example:

```console
$ podman run --rm \
    --device nvidia.com/gpu=0 \
    --device nvidia.com/gpu=1:0 \
    --security-opt=label=disable \
    ubuntu nvidia-smi -L
```

The preceding sample command requests the full GPU with index 0 and the first MIG device on GPU 1.
The output should show only the UUIDs of the requested devices.

## Using CDI with Non-CDI-Enabled Runtimes

To support runtimes that do not natively support CDI, you can configure the NVIDIA Container Runtime in a `cdi` mode.
In this mode, the NVIDIA Container Runtime does not inject the NVIDIA Container Runtime Hook into the incoming OCI runtime specification.
Instead, the runtime performs the injection of the requested CDI devices.

The NVIDIA Container Runtime automatically uses `cdi` mode if you request devices by their CDI device names.

Using Docker as an example of a non-CDI-enabled runtime, the following command uses CDI to inject the requested devices into the container:

```console
$ docker run --rm -ti --runtime=nvidia \
    -e NVIDIA_VISIBLE_DEVICES=nvidia.com/gpu=all \
      ubuntu nvidia-smi -L
```

The `NVIDIA_VISIBLE_DEVICES` environment variable indicates which devices to inject into the container and is explicitly set to `nvidia.com/gpu=all`.

### Setting the CDI Mode Explicitly

You can force CDI mode by explicitly setting the `nvidia-container-runtime.mode` option in the NVIDIA Container Runtime config to `cdi`:

```console
$ sudo nvidia-ctk config --in-place --set nvidia-container-runtime.mode=cdi
```

In this case, the `NVIDIA_VISIBLE_DEVICES` environment variable is still used to select the
devices to inject into the container, but the `nvidia-container-runtime.modes.cdi.default-kind`
(with a default value of `nvidia.com/gpu`) is used to construct a fully-qualified CDI device name
only when you specify a device index such as `all`, `0`, or `1`, and so on.

This means that if CDI mode is explicitly enabled, the following sample command has the same effect as
specifying `NVIDIA_VISIBLE_DEVICES=nvidia.com/gpu=all`.

```console
$ docker run --rm -ti --runtime=nvidia \
    -e NVIDIA_VISIBLE_DEVICES=all \
      ubuntu nvidia-smi -L
```


## Related Information

- [Container Device Interface](https://github.com/cncf-tags/container-device-interface) (CDI) specification from the Container Device Interface repository on GitHub.
- [How to configure CDI](https://github.com/cncf-tags/container-device-interface#how-to-configure-cdi) from the GitHub repository provides an overview
  of manual configuration for CRI-O, containerd, and Podman.
  The NVIDIA Container Toolkit performs the configuration for you.