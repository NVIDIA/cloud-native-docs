% Date: August 10 2020

% Author: pramarao

# Specialized Configurations with Docker

```{contents}
---
depth: 2
local: true
backlinks: none
---
```

## Environment variables (OCI spec)

Users can control the behavior of the NVIDIA container runtime using environment variables - especially for
enumerating the GPUs and the capabilities of the driver.
Each environment variable maps to an command-line argument for `nvidia-container-cli` from [libnvidia-container](https://github.com/NVIDIA/libnvidia-container).
These variables are already set in the NVIDIA provided base [CUDA images](https://ngc.nvidia.com/catalog/containers/nvidia:cuda).

### GPU Enumeration

GPUs can be specified to the Docker CLI using either the `--gpus` option starting with Docker `19.03` or using the environment variable
`NVIDIA_VISIBLE_DEVICES`. This variable controls which GPUs will be made accessible inside the container.

The possible values of the `NVIDIA_VISIBLE_DEVICES` variable are:

```{eval-rst}
.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Possible values
      - Description

    * - ``0,1,2,`` or ``GPU-fef8089b``
      - a comma-separated list of GPU UUID(s) or index(es).

    * - ``all``
      - all GPUs will be accessible, this is the default value in base CUDA container images.

    * - ``none``
      - no GPU will be accessible, but driver capabilities will be enabled.

    * - ``void`` or `empty` or `unset`
      - ``nvidia-container-runtime`` will have the same behavior as ``runc`` (i.e. neither GPUs nor capabilities are exposed)
```

:::{note}
When using the `--gpus` option to specify the GPUs, the `device` parameter should be used. This is shown in the examples below.
The format of the `device` parameter should be encapsulated within single quotes, followed by double quotes for the devices you
want enumerated to the container. For example: `'"device=2,3"'` will enumerate GPUs 2 and 3 to the container.

When using the NVIDIA_VISIBLE_DEVICES variable, you may need to set `--runtime` to `nvidia` unless already set as default.
:::

Some examples of the usage are shown below:

1. Starting a GPU enabled CUDA container; using `--gpus`

   ```console
   $ docker run --rm --gpus all nvidia/cuda nvidia-smi
   ```

2. Using `NVIDIA_VISIBLE_DEVICES` and specify the nvidia runtime

   ```console
   $ docker run --rm --runtime=nvidia \
       -e NVIDIA_VISIBLE_DEVICES=all nvidia/cuda nvidia-smi
   ```

3. Start a GPU enabled container on two GPUs

   ```console
   $ docker run --rm --gpus 2 nvidia/cuda nvidia-smi
   ```

4. Starting a GPU enabled container on specific GPUs

   ```console
   $ docker run --gpus '"device=1,2"' \
       nvidia/cuda nvidia-smi --query-gpu=uuid --format=csv
   ```

   ```console
   uuid
   GPU-ad2367dd-a40e-6b86-6fc3-c44a2cc92c7e
   GPU-16a23983-e73e-0945-2095-cdeb50696982
   ```

5. Alternatively, you can also use `NVIDIA_VISIBLE_DEVICES`

   ```console
   $ docker run --rm --runtime=nvidia \
       -e NVIDIA_VISIBLE_DEVICES=1,2 \
       nvidia/cuda nvidia-smi --query-gpu=uuid --format=csv
   ```

   ```console
   uuid
   GPU-ad2367dd-a40e-6b86-6fc3-c44a2cc92c7e
   GPU-16a23983-e73e-0945-2095-cdeb50696982
   ```

6. Query the GPU UUID using `nvidia-smi` and then specify that to the container

   ```console
   $ nvidia-smi -i 3 --query-gpu=uuid --format=csv
   ```

   ```console
   uuid
   GPU-18a3e86f-4c0e-cd9f-59c3-55488c4b0c24
   ```

   ```console
   $ docker run --gpus device=GPU-18a3e86f-4c0e-cd9f-59c3-55488c4b0c24 \
        nvidia/cuda nvidia-smi
   ```

### Driver Capabilities

The `NVIDIA_DRIVER_CAPABILITIES` controls which driver libraries/binaries will be mounted inside the container.

The possible values of the `NVIDIA_DRIVER_CAPABILITIES` variable are:

```{eval-rst}
.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Possible values
      - Description

    * - ``compute,video`` or ``graphics,utility``
      - a comma-separated list of driver features the container needs.

    * - ``all``
      - enable all available driver capabilities.

    * - `empty` or `unset`
      - use default driver capability: ``utility``, ``compute``
```

The supported driver capabilities are provided below:

```{eval-rst}
.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Driver Capability
      - Description

    * - ``compute``
      - required for CUDA and OpenCL applications.

    * - ``compat32``
      - required for running 32-bit applications.

    * - ``graphics``
      - required for running OpenGL and Vulkan applications.

    * - ``utility``
      - required for using ``nvidia-smi`` and NVML.

    * - ``video``
      - required for using the Video Codec SDK.

    * - ``display``
      - required for leveraging X11 display.
```

For example, specify the `compute` and `utility` capabilities, allowing usage of CUDA and NVML

> ```console
> $ docker run --rm --runtime=nvidia \
>     -e NVIDIA_VISIBLE_DEVICES=2,3 \
>     -e NVIDIA_DRIVER_CAPABILITIES=compute,utility \
>     nvidia/cuda nvidia-smi
> ```
>
> ```console
> $ docker run --rm --gpus 'all,"capabilities=compute,utility"' \
>     nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi
> ```

### Constraints

The NVIDIA runtime also provides the ability to define constraints on the configurations supported by the container.

#### NVIDIA_REQUIRE_* Constraints

This variable is a logical expression to define constraints on the software versions or GPU architectures on the container.

The supported constraints are provided below:

```{eval-rst}
.. list-table::
    :widths: 20 80
    :header-rows: 1

    * - Constraint
      - Description

    * - ``cuda``
      - constraint on the CUDA driver version.

    * - ``driver``
      - constraint on the driver version.

    * - ``arch``
      - constraint on the compute architectures of the selected GPUs.

    * - ``brand``
      - constraint on the brand of the selected GPUs (e.g. GeForce, Tesla, GRID).
```

Multiple constraints can be expressed in a single environment variable: space-separated constraints are ORed,
comma-separated constraints are ANDed.
Multiple environment variables of the form `NVIDIA_REQUIRE_*` are ANDed together.

For example, the following constraints can be specified to the container image for constraining the supported CUDA and
driver versions:

```console
NVIDIA_REQUIRE_CUDA "cuda>=11.0 driver>=450"
```

#### NVIDIA_DISABLE_REQUIRE Environment Variable

Single switch to disable all the constraints of the form `NVIDIA_REQUIRE_*`.

:::{note}
If you are running CUDA-base images older than CUDA 11.7 (and unable to update to the new base images with updated constraints),
CUDA compatibility checks can be disabled by setting `NVIDIA_DISABLE_REQUIRE` to `true`.
:::

#### NVIDIA_REQUIRE_CUDA Constraint

The version of the CUDA toolkit used by the container. It is an instance of the
generic `NVIDIA_REQUIRE_*` case and it is set by official CUDA images. If the version of the NVIDIA driver
is insufficient to run this version of CUDA, the container will not be started. This variable
can be specified in the form `major.minor`

The possible values for this variable: `cuda>=7.5`, `cuda>=8.0`, `cuda>=9.0` and so on.

### Dockerfiles

Capabilities and GPU enumeration can be set in images via environment variables. If the environment variables are
set inside the Dockerfile, you don't need to set them on the `docker run` command-line.

For instance, if you are creating your own custom CUDA container, you should use the following:

```console
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
```

These environment variables are already set in the NVIDIA provided CUDA images.
