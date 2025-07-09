% Date: November 11 2022

% Author: elezar (elezar@nvidia.com)
% Author: ArangoGutierrez (eduardoa@nvidia.com)

% headings (h1/h2/h3/h4/h5) are # * = -

(cdi-support)=

# Support for Container Device Interface

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

### Automatic CDI Specification Generation

As of NVIDIA Container Toolkit `v1.18.0`, the CDI specification is automatically generated and updated by a systemd service called `nvidia-cdi-refresh`. This service:

- Automatically generates the CDI specification at `/var/run/cdi/nvidia.yaml` when NVIDIA drivers are installed or upgraded
- Runs automatically on system boot to ensure the specification is up to date

```{note}
The automatic CDI refresh service does not handle:
- Driver removal (the CDI file is intentionally preserved)
- MIG device reconfiguration

For these scenarios, you may still need to manually regenerate the CDI specification. See [Manual CDI Specification Generation](#manual-cdi-specification-generation) for instructions.
```

#### Customizing the Automatic CDI Refresh Service

You can customize the behavior of the `nvidia-cdi-refresh` service by adding environment variables to `/etc/nvidia-container-toolkit/cdi-refresh.env`. This file is read by the service and allows you to modify the `nvidia-ctk cdi generate` command behavior.

Example configuration file:
```bash
# /etc/nvidia-container-toolkit/cdi-refresh.env
NVIDIA_CTK_DEBUG=1
# Add other nvidia-ctk environment variables as needed
```

For a complete list of available environment variables, run `nvidia-ctk cdi generate --help` to see the command's documentation.

```{important}
After modifying the environment file, you must reload the systemd daemon and restart the service for changes to take effect:

```console
$ sudo systemctl daemon-reload
$ sudo systemctl restart nvidia-cdi-refresh.service
```

#### Managing the CDI Refresh Service

The `nvidia-cdi-refresh` service consists of two systemd units:

- `nvidia-cdi-refresh.path` - Monitors for changes to driver files and triggers the service
- `nvidia-cdi-refresh.service` - Executes the CDI specification generation

You can manage these services using standard systemd commands:

```console
# Check service status
$ sudo systemctl status nvidia-cdi-refresh.path
● nvidia-cdi-refresh.path - Trigger CDI refresh on NVIDIA driver install / uninstall events
     Loaded: loaded (/etc/systemd/system/nvidia-cdi-refresh.path; enabled; preset: enabled)
     Active: active (waiting) since Fri 2025-06-27 06:04:54 EDT; 1h 47min ago
   Triggers: ● nvidia-cdi-refresh.service

$ sudo systemctl status nvidia-cdi-refresh.service
○ nvidia-cdi-refresh.service - Refresh NVIDIA CDI specification file
     Loaded: loaded (/etc/systemd/system/nvidia-cdi-refresh.service; enabled; preset: enabled)
     Active: inactive (dead) since Fri 2025-06-27 07:17:26 EDT; 34min ago
TriggeredBy: ● nvidia-cdi-refresh.path
    Process: 1317511 ExecStart=/usr/bin/nvidia-ctk cdi generate --output=/var/run/cdi/nvidia.yaml (code=exited, status=0/SUCCESS)
   Main PID: 1317511 (code=exited, status=0/SUCCESS)
        CPU: 562ms

Jun 27 00:04:30 ipp2-0502 nvidia-ctk[1623461]: time="2025-06-27T00:04:30-04:00" level=info msg="Selecting /usr/bin/nvidia-smi as /usr/bin/nvidia-smi"
Jun 27 00:04:30 ipp2-0502 nvidia-ctk[1623461]: time="2025-06-27T00:04:30-04:00" level=info msg="Selecting /usr/bin/nvidia-debugdump as /usr/bin/nvidia-debugdump"
Jun 27 00:04:30 ipp2-0502 nvidia-ctk[1623461]: time="2025-06-27T00:04:30-04:00" level=info msg="Selecting /usr/bin/nvidia-persistenced as /usr/bin/nvidia-persistenced"
Jun 27 00:04:30 ipp2-0502 nvidia-ctk[1623461]: time="2025-06-27T00:04:30-04:00" level=info msg="Selecting /usr/bin/nvidia-cuda-mps-control as /usr/bin/nvidia-cuda-mps-control"
Jun 27 00:04:30 ipp2-0502 nvidia-ctk[1623461]: time="2025-06-27T00:04:30-04:00" level=info msg="Selecting /usr/bin/nvidia-cuda-mps-server as /usr/bin/nvidia-cuda-mps-server"
Jun 27 00:04:30 ipp2-0502 nvidia-ctk[1623461]: time="2025-06-27T00:04:30-04:00" level=warning msg="Could not locate nvidia-imex: pattern nvidia-imex not found"
Jun 27 00:04:30 ipp2-0502 nvidia-ctk[1623461]: time="2025-06-27T00:04:30-04:00" level=warning msg="Could not locate nvidia-imex-ctl: pattern nvidia-imex-ctl not found"
Jun 27 00:04:30 ipp2-0502 nvidia-ctk[1623461]: time="2025-06-27T00:04:30-04:00" level=info msg="Generated CDI spec with version 1.0.0"
Jun 27 00:04:30 ipp2-0502 systemd[1]: nvidia-cdi-refresh.service: Succeeded.
Jun 27 00:04:30 ipp2-0502 systemd[1]: Started Refresh NVIDIA CDI specification file.
```

You can enable/disable the automatic CDI refresh service using the following commands:

```console
$ sudo systemctl enable --now nvidia-cdi-refresh.path
$ sudo systemctl enable --now nvidia-cdi-refresh.service
$ sudo systemctl disable nvidia-cdi-refresh.service
$ sudo systemctl disable nvidia-cdi-refresh.path
```

You can also view the service logs to see the output of the CDI generation process.

```console
# View service logs
$ sudo journalctl -u nvidia-cdi-refresh.service
```

### Manual CDI Specification Generation

If you need to manually generate a CDI specification, for example, after MIG configuration changes or if you are using a Container Toolkit version before v1.18.0, follow this procedure:

Two common locations for CDI specifications are `/etc/cdi/` and `/var/run/cdi/`.
The contents of the `/var/run/cdi/` directory are cleared on boot.

However, the path to create and use can depend on the container engine that you use.

1. Generate the CDI specification file:

   ```console
   $ sudo nvidia-ctk cdi generate --output=/var/run/cdi/nvidia.yaml
   ```

   The sample command uses `sudo` to ensure that the file at `/var/run/cdi/nvidia.yaml` is created.
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
- You use a location such as `/var/run/cdi` that is cleared on boot.

A configuration change can occur when MIG devices are created or removed, or when the driver is upgraded.

**Note**: As of NVIDIA Container Toolkit v1.18.0, the automatic CDI refresh service handles most of these scenarios automatically.
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