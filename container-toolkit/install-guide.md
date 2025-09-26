% headings (h1/h2/h3/h4/h5) are # * = -

(toolkit-install)=

# Installing the NVIDIA Container Toolkit

## Installation

(pre-requisites)=

### Prerequisites

1. Read [this section](./supported-platforms.md) about platform support.

2. Install the NVIDIA GPU driver for your Linux distribution.
NVIDIA recommends installing the driver by using the package manager for your distribution.
For information about installing the driver with a package manager, refer to
the [_NVIDIA Driver Installation Quickstart Guide_](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html).
Alternatively, you can install the driver by [downloading](https://www.nvidia.com/en-us/drivers/) a `.run` installer.

```{note}
There is a [known issue](troubleshooting.md#containers-losing-access-to-gpus-with-error-failed-to-initialize-nvml-unknown-error) on systems
where `systemd` cgroup drivers are used that cause containers to lose access to requested GPUs when
`systemctl daemon reload` is run. Please see the troubleshooting documentation for more information.
```

(installing-with-apt)=

### With `apt`: Ubuntu, Debian

   ```{note}
   These instructions [should work](./supported-platforms.md) for any Debian-derived distribution.
   ```

1. Configure the production repository:

   ```console
   $ curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
     && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
       sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
       sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
   ```

   Optionally, configure the repository to use experimental packages:

   ```console
   $ sudo sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list
   ```

1. Update the packages list from the repository:

   ```console
   $ sudo apt-get update
   ```

   <!--
   TODO:
   - [ ] If running `apt-get update` after configuring repositories raises an error regarding a conflict in the Signed-By option, see the :ref:`troubleshooting section <conflicting_signed_by>`.
   -->

1. Install the NVIDIA Container Toolkit packages:

   ```console
   $ export NVIDIA_CONTAINER_TOOLKIT_VERSION=${version}-1
     sudo apt-get install -y \
         nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
         nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
         libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
         libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}
   ```

(installing-with-yum-or-dnf)=

### With `dnf`: RHEL/CentOS, Fedora, Amazon Linux


   ```{note}
   These instructions [should work](./supported-platforms.md) for many RPM-based distributions.
   ```

1. Configure the production repository:

   ```console
   $ curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
     sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
   ```

   Optionally, configure the repository to use experimental packages:

   ```console
   $ sudo dnf-config-manager --enable nvidia-container-toolkit-experimental
   ```

1. Install the NVIDIA Container Toolkit packages:

   ```console
   $ export NVIDIA_CONTAINER_TOOLKIT_VERSION=${version}-1
     sudo dnf install -y \
         nvidia-container-toolkit-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
         nvidia-container-toolkit-base-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
         libnvidia-container-tools-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
         libnvidia-container1-${NVIDIA_CONTAINER_TOOLKIT_VERSION}
   ```

(installing-with-zypper)=

### With `zypper`: OpenSUSE, SLE

1. Configure the production repository:

   ```console
   $ sudo zypper ar https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
   ```

   Optionally, configure the repository to use experimental packages:

   ```console
   $ sudo zypper modifyrepo --enable nvidia-container-toolkit-experimental
   ```

1. Install the NVIDIA Container Toolkit packages:

   ```console
   $  export NVIDIA_CONTAINER_TOOLKIT_VERSION=${version}-1
      sudo zypper --gpg-auto-import-keys install -y \
         nvidia-container-toolkit-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
         nvidia-container-toolkit-base-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
         libnvidia-container-tools-${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
         libnvidia-container1-${NVIDIA_CONTAINER_TOOLKIT_VERSION}
   ```

## Configuration

### Prerequisites

* You installed a supported container engine (Docker, Containerd, CRI-O, Podman).
* You installed the NVIDIA Container Toolkit.

(setting-up-docker)=

### Configuring Docker

1. Configure the container runtime by using the `nvidia-ctk` command:

   ```console
   $ sudo nvidia-ctk runtime configure --runtime=docker
   ```

   The `nvidia-ctk` command modifies the `/etc/docker/daemon.json` file on the host.
   The file is updated so that Docker can use the NVIDIA Container Runtime.

1. Restart the Docker daemon:

   ```console
   $ sudo systemctl restart docker
   ```

#### Rootless mode

To configure the container runtime for Docker running in [Rootless mode](https://docs.docker.com/engine/security/rootless/),
follow these steps:

1. Configure the container runtime by using the `nvidia-ctk` command:

   ```console
   $ nvidia-ctk runtime configure --runtime=docker --config=$HOME/.config/docker/daemon.json
   ```

2. Restart the Rootless Docker daemon:

   ```console
   $ systemctl --user restart docker
   ```

3. Configure `/etc/nvidia-container-runtime/config.toml` by using the `sudo nvidia-ctk` command:

   ```console
   $ sudo nvidia-ctk config --set nvidia-container-cli.no-cgroups --in-place
   ```

### Configuring containerd (for Kubernetes)

1. Configure the container runtime by using the `nvidia-ctk` command:

   ```console
   $ sudo nvidia-ctk runtime configure --runtime=containerd
   ```

   The `nvidia-ctk` command modifies the `/etc/containerd/config.toml` file on the host.
   The file is updated so that containerd can use the NVIDIA Container Runtime.

1. Restart containerd:

   ```console
   $ sudo systemctl restart containerd
   ```

### Configuring containerd (for nerdctl)

No additional configuration is needed.
You can just run `nerdctl run --gpus=all`, with root or without root.
You do not need to run the `nvidia-ctk` command mentioned above for Kubernetes.

See also the [nerdctl documentation](https://github.com/containerd/nerdctl/blob/main/docs/gpu.md).

### Configuring CRI-O

1. Configure the container runtime by using the `nvidia-ctk` command:

   ```console
   $ sudo nvidia-ctk runtime configure --runtime=crio
   ```

   The `nvidia-ctk` command modifies the `/etc/crio/crio.conf` file on the host.
   The file is updated so that CRI-O can use the NVIDIA Container Runtime.

1. Restart the CRI-O daemon:

   ```console
   $ sudo systemctl restart crio
   ```

   <!--
   TODO:
   - [ ] Sample CUDA container run with nvidia-smi.
   -->

### Configuring Podman

For Podman, NVIDIA recommends using [CDI](./cdi-support.md) for accessing NVIDIA devices in containers.


## Next Steps

- [](./sample-workload.md)