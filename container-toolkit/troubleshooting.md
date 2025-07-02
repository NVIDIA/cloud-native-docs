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

When using the NVIDIA Container Runtime Hook (i.e. the Docker `--gpus` flag or
the NVIDIA Container Runtime in `legacy` mode) to inject requested GPUs and driver
libraries into a container, the hook makes modifications, including setting up cgroup access, to the container without the low-level runtime (e.g. `runc`) being aware of these changes. 
The result is that updates to the container may remove access to the requested GPUs.

When the container loses access to the GPU, you will see the following error message from the console output:

```console
Failed to initialize NVML: Unknown Error
```

The message may differ depending on the type of application that is running in
the container.

The container needs to be deleted once the issue occurs.
When it is restarted, manually or automatically depending if you are using a container orchestration platform, it will regain access to the GPU.

### Affected environments

On certain systems this behavior is not limited to *explicit* container updates
such as adjusting CPU and Memory limits for a container. 
On systems where `systemd` is used to manage the cgroups of the container, reloading the `systemd` unit files (`systemctl daemon-reload`) is sufficient to trigger container updates and cause a loss of GPU access.

### Mitigations and  Workarounds

```{warning}
Certain `runc` versions show similar behavior with the `systemd` cgroup driver when `/dev/char` symlinks for the required devices are missing on the system. 
Refer to [GitHub disccusion #1133](https://github.com/NVIDIA/nvidia-container-toolkit/discussions/1133) for more details around this issue.
It should be noted that the behavior persisted even if device nodes were requested on the command line. 
Newer `runc` versions do not show this behavior and newer NVIDIA driver versions ensure that the required symlinks are present, reducing the likelihood of the specific issue occurring for affected `runc` versions.
```

Use the following workarounds to prevent containers from losing access to requested GPUs when a `systemctl daemon-reload` command is run:

* Explicitly request the device nodes associated with the requested GPU(s) and any control device nodes when starting the container. 
  For the Docker CLI, this is done by adding the relevant `--device` flags. 
  In the case of the NVIDIA Kubernetes Device Plugin the `compatWithCPUManager= true` [Helm option](https://github.com/NVIDIA/k8s-device-plugin?tab=readme-ov-file#setting-other-helm-chart-values) will ensure the same thing.
* Use the Container Device Interface (CDI) to inject devices into a container. 
  When CDI is used to inject devices into a container, the required device nodes are included in the modifications made to the container config. 
  This means that even if the container is updated it will still have access to the required devices.
* For Docker, use cgroupfs as the cgroup driver for containers. 
  This will ensure that the container will not lose access to devices when `systemctl daemon-reload` is run. 
  This approach does not change the behavior for explicit container updates and a container will still lose access to devices in this case.
