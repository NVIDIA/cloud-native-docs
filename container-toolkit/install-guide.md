% headings (h1/h2/h3/h4/h5) are # * = -

(toolkit-install)=

# Installing the NVIDIA Container Toolkit

```{contents}
---
depth: 2
local: true
backlinks: none
---
```

## Installation

### Installing with Apt

1. Configure the production repository:

   ```console
   $ curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
     && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
       sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
       sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
   ```

   Optionally, configure the repository to use experimental packages:

   ```console
   $ sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list
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
   $ sudo apt-get install -y nvidia-container-toolkit
   ```

### Installing with Yum or Dnf

1. Configure the production repository:

   ```console
   $ curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
     sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
   ```

   Optionally, configure the repository to use experimental packages:

   ```console
   $ sudo yum-config-manager --enable nvidia-container-toolkit-experimental
   ```

1. Install the NVIDIA Container Toolkit packages:

   ```console
   $ sudo yum install -y nvidia-container-toolkit
   ```

### Installing with Zypper

1. Configure the production repository:

   ```console
   $ sudo zypper ar https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
   ```

   Optionally, configure the repository to use experimental packages:

   ```console
   $ sudo zypper modifyrepo --enable nvidia-container-toolkit-experimental
   ```

   <!--
   TODO:
   - [ ] Experimental repos: zypper modifyrepo --enable nvidia-container-toolkit-experimental
   -->

1. Install the NVIDIA Container Toolkit packages:

   ```console
   $ sudo zypper --gpg-auto-import-keys install -y nvidia-container-toolkit
   ```

## Configuration

### Prerequisites

* You installed a supported container engine (Docker, Containerd, CRI-O, Podman).
* You installed the NVIDIA Container Toolkit.

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

### Configuring containerd

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

- Install an NVIDIA GPU Driver if you do not already have one installed.
  You can install a driver by using the package manager for your distribution, but other installation
  methods, such as downloading a `.run` file intaller, are available.
  Refer to the
  _[NVIDIA Driver Installation Quickstart Guide](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html)_
  for more information.

- [](./sample-workload.md)