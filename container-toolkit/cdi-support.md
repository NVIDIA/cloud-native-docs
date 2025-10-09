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

- Automatically generates the CDI specification at `/var/run/cdi/nvidia.yaml` when:
  - The NVIDIA Container Toolkit is installed or upgraded
  - The NVIDIA GPU drivers are installed or upgraded
  - The system is rebooted

This ensures that the CDI specifications are up to date for the current driver
and device configuration and that CDI Devices defined in these speciciations are
available when using native CDI support in container engines such as Docker or Podman.

Running the following command will give a list of availble CDI Devices:
```console
nvidia-ctk cdi list
```

#### Known limitations
The `nvidia-cdi-refresh` service does not currently handle the following situations:

- The removal of NVIDIA GPU drivers
- The reconfiguration of MIG devices

For these scenarios, the regeneration of CDI specifications must be [manually triggered](#manual-cdi-specification-generation).

#### Customizing the Automatic CDI Refresh Service
The behavior of the `nvidia-cdi-refresh` service can be customized by adding
environment variables to `/etc/nvidia-container-toolkit/cdi-refresh.env` to
affect the behavior of the `nvidia-ctk cdi generate` command.

As an example, to enable debug logging the configuration file should be updated
as follows:
```bash
# /etc/nvidia-container-toolkit/cdi-refresh.env
NVIDIA_CTK_DEBUG=1
```

For a complete list of available environment variables, run `nvidia-ctk cdi generate --help` to see the command's documentation.

```{important}
Modifications to the environment file required a systemd reload and restarting the
service to take effect
```

```console
$ sudo systemctl daemon-reload
$ sudo systemctl restart nvidia-cdi-refresh.service
```

#### Managing the CDI Refresh Service

The `nvidia-cdi-refresh` service consists of two systemd units:

- `nvidia-cdi-refresh.path`: Montiors for for changes to the system and triggers the service
- `nvidia-cdi-refresh.service`: Generates the CDI specifications for all available devices based on
  the default configuration and any overrides in the environment file.

These services can be managed using standard systemd commands.

When working as expected, the `nvidia-cdi-refresh.path` service will be enabled and active, and the
`nvidia-cdi-refresh.service` will be enabled and have run at least once. For example:

```console
$ sudo systemctl status nvidia-cdi-refresh.path
● nvidia-cdi-refresh.path - Trigger CDI refresh on NVIDIA driver install / uninstall events
     Loaded: loaded (/etc/systemd/system/nvidia-cdi-refresh.path; enabled; preset: enabled)
     Active: active (waiting) since Fri 2025-06-27 06:04:54 EDT; 1h 47min ago
   Triggers: ● nvidia-cdi-refresh.service
```

```console
$ sudo systemctl status nvidia-cdi-refresh.service
○ nvidia-cdi-refresh.service - Refresh NVIDIA CDI specification file
     Loaded: loaded (/etc/systemd/system/nvidia-cdi-refresh.service; enabled; preset: enabled)
     Active: inactive (dead) since Fri 2025-06-27 07:17:26 EDT; 34min ago
TriggeredBy: ● nvidia-cdi-refresh.path
    Process: 1317511 ExecStart=/usr/bin/nvidia-ctk cdi generate --output=/var/run/cdi/nvidia.yaml (code=exited, status=0/SUCCESS)
   Main PID: 1317511 (code=exited, status=0/SUCCESS)
        CPU: 562ms
...
```

If these are not enabled as expected, they can be enabled by running:

```console
$ sudo systemctl enable --now nvidia-cdi-refresh.path
$ sudo systemctl enable --now nvidia-cdi-refresh.service
```

#### Troubleshooting CDI Specification Generation and Resolution

If CDI specifications for available devices are not generated / updated as expected, it is
recommended that the logs for the `nvidia-cdi-refresh.service` be checked. This can be
done by running:

```console
$ sudo journalctl -u nvidia-cdi-refresh.service
```

In most cases, restarting the service should be sufficient to trigger the (re)generation
of CDI specifications:

```console
$ sudo systemctl restart nvidia-cdi-refresh.service
```

Running:

```console
$ nvidia-ctk --debug cdi list
```
will show a list of available CDI Devices as well as any errors that may have
occurred when loading CDI Specifications from `/etc/cdi` or `/var/run/cdi`.

### Manual CDI Specification Generation

As of the NVIDIA Container Toolkit `v1.18.0` the recommended mechanism to regenerate CDI specifications is to restart the `nvidia-cdi-refresh.service`:

```console
$ sudo systemctl restart nvidia-cdi-refresh.service
```

If this does not work, or more flexibility is required, the `nvidia-ctk cdi generate` command
can be used directly:

```console
$ sudo nvidia-ctk cdi generate --output=/var/run/cdi/nvidia.yaml
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