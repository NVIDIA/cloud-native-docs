% Date: May 12 2022

% Author: elezar

(toolkit-troubleshooting)=

# Troubleshooting

## Troubleshooting with Docker

### Generating Debugging Logs

For most common issues, you can generate debugging logs to help identify the root cause of the problem.
To generate debug logs :

- Edit your runtime configuration under `/etc/nvidia-container-runtime/config.toml` and uncomment the `debug=...` line.
- Run your container again to reproduce the issue and generate the logs.

### Generating Core Dumps

In the event of a critical failure, core dumps can be automatically generated and can help troubleshoot issues.
Refer to [core(5)](http://man7.org/linux/man-pages/man5/core.5.html) to generate these.
In particular make check the following items:

- `/proc/sys/kernel/core_pattern` is correctly set and points somewhere with write access.
- `ulimit -c` is set to a sensible default.

In case the `nvidia-container-cli` process becomes unresponsive, [gcore(1)](http://man7.org/linux/man-pages/man1/gcore.1.html) can also be used.

### Sharing Your Debugging Information

You can attach a particular output to your issue with a [drag and drop](https://help.github.com/articles/file-attachments-on-issues-and-pull-requests/)
into the comment section.

(conflicting-signed-by)=

## Conflicting values set for option Signed-By error when running apt update

When following the installation instructions on Ubuntu or Debian-based systems and updating the package repository, the following error could be triggered:

```console
$ sudo apt-get update
E: Conflicting values set for option Signed-By regarding source https://nvidia.github.io/libnvidia-container/stable/ubuntu18.04/amd64/ /: /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg !=
E: The list of sources could not be read.
```

This is caused by the combination of two things:

1. A recent update to the installation instructions to create a repo list file `/etc/apt/sources.list.d/nvidia-container-toolkit.list`
2. The deprecation of `apt-key` meaning that the `signed-by` directive is included in the repo list file

If this error is triggered it means that another reference to the same repository exists that does not specify the `signed-by` directive.
The most likely candidates would be one or more of the files `libnvidia-container.list`, `nvidia-docker.list`, or `nvidia-container-runtime.list` in the
folder `/etc/apt/sources.list.d/`.

The conflicting repository references can be obtained by running and inspecting the output:

```console
$ grep "nvidia.github.io" /etc/apt/sources.list.d/*
```

The list of files with possibly conflicting references can be obtained by running:

```console
$ grep -l "nvidia.github.io" /etc/apt/sources.list.d/* | grep -vE "/nvidia-container-toolkit.list\$"
```

Deleting the listed files should resolve the original error.

## Permission denied error when running the nvidia-docker wrapper under SELinux

When running the `nvidia-docker` wrapper (provided by the `nvidia-docker2` package) on SELinux environments
one may see the following error

```console
$ sudo nvidia-docker run --gpus=all --rm nvcr.io/nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi
/bin/nvidia-docker: line 34: /bin/docker: Permission denied
/bin/nvidia-docker: line 34: /bin/docker: Success
```

With SELinux reporting the following error:

```console
SELinux is preventing /usr/bin/bash from entrypoint access on the file /usr/bin/docker. For complete SELinux messages run: sealert -l 43932883-bf2e-4e4e-800a-80584c62c218
SELinux is preventing /usr/bin/bash from entrypoint access on the file /usr/bin/docker.

*****  Plugin catchall (100. confidence) suggests   **************************

If you believe that bash should be allowed entrypoint access on the docker file by default.
Then you should report this as a bug.
You can generate a local policy module to allow this access.
Do
allow this access for now by executing:
# ausearch -c 'nvidia-docker' --raw | audit2allow -M my-nvidiadocker
# semodule -X 300 -i my-nvidiadocker.pp
```

This occurs because `nvidia-docker` forwards the command line arguments with minor modifications to the `docker` executable.

To address this, specify the NVIDIA runtime in the the `docker` command:

```console
$ sudo docker run --gpus=all --runtime=nvidia --rm nvcr.io/nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi
```

Alternatively a local SELinux policy can be generated as suggested:

```console
$ ausearch -c 'nvidia-docker' --raw | audit2allow -M my-nvidiadocker
$ semodule -X 300 -i my-nvidiadocker.pp
```

## NVML: Insufficient Permissions and SELinux

Depending on how your Red Hat Enterprise Linux system is configured with SELinux, you might have to
specify ``--security-opt=label=disable`` on the Docker or Podman command line to share parts of the
host OS that can not be relabeled.
Without this option, you might observe this error when running GPU containers:
``Failed to initialize NVML: Insufficient Permissions``.
However, using this option disables SELinux separation in the container and the container is executed
in an unconfined type.
Review the SELinux policies on your system.


## Containers losing access to GPUs with error: "Failed to initialize NVML: Unknown Error"

Under specific conditions, it’s possible that containerized GPU workloads may suddenly lose access to their GPUs. 
This situation occurs when `systemd` is used to manage the cgroups of the container and it is triggered to reload any Unit files that have references to NVIDIA GPUs (e.g. with something as simple as a systemctl daemon-reload).

When the container loses access to the GPU, you will see the following error message from the console output:

```console
Failed to initialize NVML: Unknown Error
```

The container needs to be deleted once the issue occurs.
When it is restarted (manually or automatically depending if you are using a container orchestration platform), it will regain access to the GPU.

The issue originates from the fact that recent versions of `runc` require that symlinks be present under `/dev/char` to any device nodes being injected into a container. Unfortunately, these symlinks are not present for NVIDIA devices, and the NVIDIA GPU driver does not provide a means for them to be created automatically.

A fix will be present in the next patch release of all supported NVIDIA GPU drivers.

### Affected environments

You many be affected by this issue if you are use `runc` and enable `systemd cgroup` management at the high-level container runtime.

```{note}
If the system is NOT using `systemd` to manage `cgroups`, then it is NOT subject to this issue.
```

Below is a full list of affected environments:

- Docker environment using `containerd` / `runc` and you have the following configurations:
    - `cgroup driver` enabled with `systemd`.
    For example, parameter `"exec-opts": ["native.cgroupdriver=systemd"]` set in /etc/docker/daemon.json.
    - Newer docker version is used where `systemd cgroup` management is the default, like on Ubuntu 22.04.

   To check if Docker uses systemd cgroup management, run the following command (the output below indicates that systemd cgroup driver is enabled) :

    ```console 
    $ docker info  
    ...  
    Cgroup Driver: systemd  
    Cgroup Version: 1
    ```

- K8s environment using `containerd` / `runc` with the following configruations:
  - `SystemdCgroup = true` in the containerd configuration file (usually located in `/etc/containerd/config.toml`) as shown below:

    ```console
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
    BinaryName = "/usr/local/nvidia/toolkit/nvidia-container-runtime"
    ...
    SystemdCgroup = true
    ```

    To check if containerd uses systemd cgroup management, issue the following command:

    ```console
    $ sudo crictl info  
    ```

    *Example output:*

    ```output
    ...  
    "runtimes": {
        "nvidia": {
            "runtimeType": "io.containerd.runc.v2",
            ...
            "options": {
            "BinaryName": "/usr/local/nvidia/toolkit/nvidia-container-runtime",
            ...
            "ShimCgroup": "",
            "SystemdCgroup": true
    ```

- K8s environment (including OpenShift) using `cri-o` / `runc` with the following configurations:
  - `cgroup_manager` enabled with systemd in the cri-o configuration file usually located in `/etc/crio/crio.conf` or `/etc/crio/crio.conf.d/00-default` as shown below (sample with OpenShift):

    ```console
    [crio.runtime]
    ...
    cgroup_manager = "systemd"

    hooks_dir = [
    "/etc/containers/oci/hooks.d",
    "/run/containers/oci/hooks.d",
    "/usr/share/containers/oci/hooks.d",
    ]
    ```

    Podman environments use `crun` by default and are not subject to this issue unless runc is configured as the low-level container runtime to be used.

```{warning}
If you are using the container runtime in [legacy mode](https://github.com/NVIDIA/nvidia-container-toolkit/tree/main/cmd/nvidia-container-runtime#legacy-mode), the container updates (or `cgroup` changes) that are triggered when running `systemctl daemon-reload` will always cause the container to lose access to the injected devices when the `systemd cgroup driver` is used and the device nodes are not requested on the docker command line.  
This will happen even if you implement the required symlinks described in the [workaround section](#workarounds). 
```

### How to check if you are affected

You can use the following steps to confirm that your system is affected. After you implement one of the workarounds (mentioned in the next section), you can repeat the steps to confirm that the error is no longer reproducible.

#### For Docker environments

1. Run a test container:

    ```console
    $ docker run -d --rm --runtime=nvidia --gpus all \
        --device=/dev/nvidia-uvm \
        --device=/dev/nvidia-uvm-tools \
        --device=/dev/nvidia-modeset \
        --device=/dev/nvidiactl \
        --device=/dev/nvidia0 \
        nvcr.io/nvidia/cuda:12.0.0-base-ubuntu20.04 bash -c "while [ true ]; do nvidia-smi -L; sleep 5; done"  

        bc045274b44bdf6ec2e4cc10d2968d1d2a046c47cad0a1d2088dc0a430add24b
    ```

     Make sure to mount the different devices as shown above. They are needed to narrow the problem down to this specific issue.

   If your system has more than 1 GPU, append the above command with the additional --device mount. Example with a system that has 2 GPUs:

    ```console
    $ docker run -d --rm --runtime=nvidia --gpus all \
        ...
        --device=/dev/nvidia0 \
        --device=/dev/nvidia1 \
        ...
    ```

1. Check the logs from the container:

    ```console
    $ docker logs  bc045274b44bdf6ec2e4cc10d2968d1d2a046c47cad0a1d2088dc0a430add24b
    ```

    *Example output:*

    ```output
    GPU 0: Tesla K80 (UUID: GPU-05ea3312-64dd-a4e7-bc72-46d2f6050147)
    GPU 0: Tesla K80 (UUID: GPU-05ea3312-64dd-a4e7-bc72-46d2f6050147)
    ```

1. Initiate a daemon-reload:

    ```console
    $ sudo systemctl daemon-reload
    ```

1. Check the logs from the container:

    ```console
    $ docker logs bc045274b44bdf6ec2e4cc10d2968d1d2a046c47cad0a1d2088dc0a430add24b
    ```

    *Example output:*

    ```output
    GPU 0: Tesla K80 (UUID: GPU-05ea3312-64dd-a4e7-bc72-46d2f6050147)
    GPU 0: Tesla K80 (UUID: GPU-05ea3312-64dd-a4e7-bc72-46d2f6050147)
    GPU 0: Tesla K80 (UUID: GPU-05ea3312-64dd-a4e7-bc72-46d2f6050147)
    GPU 0: Tesla K80 (UUID: GPU-05ea3312-64dd-a4e7-bc72-46d2f6050147)
    Failed to initialize NVML: Unknown Error
    Failed to initialize NVML: Unknown Error
    ```

#### For Kubernetes environments

1. Run a test pod:

    ```console
    $ cat nvidia-smi-loop.yaml

    apiVersion: v1
    kind: Pod
    metadata:
    name: cuda-nvidia-smi-loop
    spec:
    restartPolicy: OnFailure
    containers:
    - name: cuda
        image: "nvcr.io/nvidia/cuda:12.0.0-base-ubuntu20.04"
        command: ["/bin/sh", "-c"]
        args: ["while true; do nvidia-smi -L; sleep 5; done"]
        resources:
        limits:
            nvidia.com/gpu: 1


    $ kubectl apply -f nvidia-smi-loop.yaml  
    ```

1. Check the logs from the pod:

    ```console
    $ kubectl logs cuda-nvidia-smi-loop
    ```

    *Example output:*

    ```console output
    GPU 0: NVIDIA A100-PCIE-40GB (UUID: GPU-551720f0-caf0-22b7-f525-2a51a6ab478d)
    GPU 0: NVIDIA A100-PCIE-40GB (UUID: GPU-551720f0-caf0-22b7-f525-2a51a6ab478d)
    ```

1. Initiate a `daemon-reload`:

    ```console
    $ sudo systemctl daemon-reload
    ```

1. Check the logs from the pod:

    ```console
    $ kubectl logs cuda-nvidia-smi-loop
    ```

    *Example output:

    ```output
    GPU 0: NVIDIA A100-PCIE-40GB (UUID: GPU-551720f0-caf0-22b7-f525-2a51a6ab478d)
    GPU 0: NVIDIA A100-PCIE-40GB (UUID: GPU-551720f0-caf0-22b7-f525-2a51a6ab478d)
    Failed to initialize NVML: Unknown Error
    Failed to initialize NVML: Unknown Error
    ```

### Workarounds

The following workarounds are available for both standalone docker environments and Kubernetes environments. 

### For Docker environments

The recommended workaround for Docker environments is to **use the `nvidia-ctk` utility.** 
The NVIDIA Container Toolkit v1.12.0 and later includes this utility for creating symlinks in `/dev/char` for all possible NVIDIA device nodes required for using GPUs in containers. 
This can be run as follows:

1. Run `nvidia-ctk`: 

    ```console
    $ sudo nvidia-ctk system create-dev-char-symlinks \
        --create-all
    ```
  
    In cases where the NVIDIA GPU Driver Container is used, the path to the driver installation must be specified. In this case the command should be modified to:

    ```console
    $ sudo nvidia-ctk system create-dev-symlinks \
        --create-all \
        --driver-root={{NVIDIA_DRIVER_ROOT}}
    ```

    Where {{NVIDIA_DRIVER_ROOT}} is the path to which the NVIDIA GPU Driver container installs the NVIDIA GPU driver and creates the NVIDIA Device Nodes.

1. Configure this command to run at boot on each node where GPUs will be used in containers.
  The command requires that the NVIDIA driver kernel modules have been loaded at the point where it is run.

    A simple `udev` rule to enforce this can be seen below:

    ```console
    # This will create /dev/char symlinks to all device nodes
    ACTION=="add", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="/usr/bin/nvidia-ctk system 	create-dev-char-symlinks --create-all"
    ```

    A good place to install this rule would be in `/lib/udev/rules.d/71-nvidia-dev-char.rules`

Some additional workarounds for Docker environments:

- **Explicitly disabling systemd cgroup management in Docker.**
  - Set the parameter `"exec-opts": ["native.cgroupdriver=cgroupfs"]` in the `/etc/docker/daemon.json` file and restart docker.
- **Downgrading to `docker.io` packages where `systemd` is not the default `cgroup` manager.**

#### For K8s environments

The recommended workaround is to deploy GPU Operator 22.9.2 or later to automatically fix the issue on all K8s nodes of the cluster.
The fix is integrated inside the validator pod which will run when a new node is deployed or at every reboot of the node. 

Some additional workarounds for Kubernets environments:

- For deployments using the standalone  k8s-device-plugin    (i.e. not through the use of the operator), installation of a `udev` rule as described in the previous section can be made to work around this issue. Be sure to pass the correct `{{NVIDIA_DRIVER_ROOT}}` in cases where the driver container is also in use.

- Explicitly disabling `systemd cgroup` management in `containerd` or `cri-o`:
  - Remove the parameter `cgroup_manager = "systemd"` from `cri-o` configuration file (usually located here: `/etc/crio/crio.conf` or `/etc/crio/crio.conf.d/00-default`) and restart `cri-o`.
- Downgrading to a version of the `containerd.io` package where `systemd` is not the default `cgroup` manager (and not overriding that, of course).