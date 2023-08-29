% Date: May 12 2022

% Author: elezar

(toolkit-troubleshooting)=

# Troubleshooting

```{contents}
---
depth: 2
local: true
backlinks: none
---
```

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

The list of files with (possibly)  conflicting references can be optained by running:

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

To address this it is recommeded that the `docker` command be used directly specifying the `nvidia` runtime:

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