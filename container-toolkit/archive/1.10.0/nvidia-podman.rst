.. Date: April 08 2021
.. Author: pramarao

Getting Started
=======================

For installing podman, follow the official `instructions <https://podman.io/getting-started/installation>`_ for your supported Linux distribution.
For convenience, the documentation below includes instructions on installing podman on RHEL 8.

Step 1: Install podman
-------------------------------

On RHEL 8, check if the ``container-tools`` module is available:

.. code-block:: console

    $ sudo dnf module list | grep container-tools

This should return an output as shown below:

.. code-block:: console

    container-tools      rhel8 [d]          common [d]                               Most recent (rolling) versions of podman, buildah, skopeo, runc, conmon, runc, conmon, CRIU, Udica, etc as well as dependencies such as container-selinux built and tested together, and updated as frequently as every 12 weeks.
    container-tools      1.0                common [d]                               Stable versions of podman 1.0, buildah 1.5, skopeo 0.1, runc, conmon, CRIU, Udica, etc as well as dependencies such as container-selinux built and tested together, and supported for 24 months.
    container-tools      2.0                common [d]                               Stable versions of podman 1.6, buildah 1.11, skopeo 0.1, runc, conmon, etc as well as dependencies such as container-selinux built and tested together, and supported as documented on the Application Stream lifecycle page.
    container-tools      rhel8 [d]          common [d]                               Most recent (rolling) versions of podman, buildah, skopeo, runc, conmon, runc, conmon, CRIU, Udica, etc as well as dependencies such as container-selinux built and tested together, and updated as frequently as every 12 weeks.
    container-tools      1.0                common [d]                               Stable versions of podman 1.0, buildah 1.5, skopeo 0.1, runc, conmon, CRIU, Udica, etc as well as dependencies such as container-selinux built and tested together, and supported for 24 months.
    container-tools      2.0                common [d]                               Stable versions of podman 1.6, buildah 1.11, skopeo 0.1, runc, conmon, etc as well as dependencies such as container-selinux built and tested together, and supported as documented on the Application Stream lifecycle page.

Now, proceed to install the ``container-tools`` module, which will install ``podman``:

.. code-block:: console

    $ sudo dnf module install -y container-tools

Once, ``podman`` is installed, check the version:

.. code-block:: console

    $ podman version
    Version:      2.2.1
    API Version:  2
    Go Version:   go1.14.7
    Built:        Mon Feb  8 21:19:06 2021
    OS/Arch:      linux/amd64

Step 2: Install NVIDIA Container Toolkit
-------------------------------------------

After installing ``podman``, we can proceed to install the NVIDIA Container Toolkit. For ``podman``, we need to use
the ``nvidia-container-toolkit`` package. See the :ref:`architecture overview <arch-overview-1.10.0-1.10.0>`
for more details on the package hierarchy.

.. include:: install/nvidia-container-toolkit.rst

Step 2.1. Check the installation
--------------------------------

Once the package installation is complete, ensure that the ``hook`` has been added:

.. code-block:: console

    $ cat  /usr/share/containers/oci/hooks.d/oci-nvidia-hook.json

.. code-block:: json

    {
        "version": "1.0.0",
        "hook": {
            "path": "/usr/bin/nvidia-container-toolkit",
            "args": ["nvidia-container-toolkit", "prestart"],
            "env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ]
        },
        "when": {
            "always": true,
            "commands": [".*"]
        },
        "stages": ["prestart"]
    }


Step 3: Rootless Containers Setup
------------------------------------

To be able to run rootless containers with ``podman``, we need the following configuration change to the NVIDIA runtime:

.. code-block:: console

    $ sudo sed -i 's/^#no-cgroups = false/no-cgroups = true/;' /etc/nvidia-container-runtime/config.toml

.. note::
  If the user running the containers is a privileged user (e.g. ``root``) this change should not be made and will cause
  containers using the NVIDIA Container Toolkit to fail.

Step 4: Running Sample Workloads
------------------------------------

We can now run some sample GPU containers to test the setup.

#. Run ``nvidia-smi``

    .. code-block:: console

        $ podman run --rm --security-opt=label=disable \
             --hooks-dir=/usr/share/containers/oci/hooks.d/ \
             nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi

   which should produce the following output:

    .. code-block:: console

        +-----------------------------------------------------------------------------+
        | NVIDIA-SMI 460.32.03    Driver Version: 460.32.03    CUDA Version: 11.2     |
        |-------------------------------+----------------------+----------------------+
        | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
        | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
        |                               |                      |               MIG M. |
        |===============================+======================+======================|
        |   0  Tesla T4            Off  | 00000000:00:1E.0 Off |                    0 |
        | N/A   46C    P0    27W /  70W |      0MiB / 15109MiB |      0%      Default |
        |                               |                      |                  N/A |
        +-------------------------------+----------------------+----------------------+

        +-----------------------------------------------------------------------------+
        | Processes:                                                                  |
        |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
        |        ID   ID                                                   Usage      |
        |=============================================================================|
        |  No running processes found                                                 |
        +-----------------------------------------------------------------------------+

#. Run an FP16 GEMM workload on the GPU that can leverage the Tensor Cores when available:

    .. code-block:: console

        $ podman run --rm --security-opt=label=disable \
             --hooks-dir=/usr/share/containers/oci/hooks.d/ \
             --cap-add SYS_ADMIN nvidia/samples:dcgmproftester-2.0.10-cuda11.0-ubuntu18.04 \
             --no-dcgm-validation -t 1004 -d 30

    You should be able to see an output as shown below:

    .. code-block:: console

        Skipping CreateDcgmGroups() since DCGM validation is disabled
        CU_DEVICE_ATTRIBUTE_MAX_THREADS_PER_MULTIPROCESSOR: 1024
        CU_DEVICE_ATTRIBUTE_MULTIPROCESSOR_COUNT: 40
        CU_DEVICE_ATTRIBUTE_MAX_SHARED_MEMORY_PER_MULTIPROCESSOR: 65536
        CU_DEVICE_ATTRIBUTE_COMPUTE_CAPABILITY_MAJOR: 7
        CU_DEVICE_ATTRIBUTE_COMPUTE_CAPABILITY_MINOR: 5
        CU_DEVICE_ATTRIBUTE_GLOBAL_MEMORY_BUS_WIDTH: 256
        CU_DEVICE_ATTRIBUTE_MEMORY_CLOCK_RATE: 5001000
        Max Memory bandwidth: 320064000000 bytes (320.06 GiB)
        CudaInit completed successfully.

        Skipping WatchFields() since DCGM validation is disabled
        TensorEngineActive: generated ???, dcgm 0.000 (27334.5 gflops)
        TensorEngineActive: generated ???, dcgm 0.000 (27795.5 gflops)
        TensorEngineActive: generated ???, dcgm 0.000 (27846.0 gflops)
        TensorEngineActive: generated ???, dcgm 0.000 (27865.9 gflops)
        TensorEngineActive: generated ???, dcgm 0.000 (27837.6 gflops)
        TensorEngineActive: generated ???, dcgm 0.000 (27709.7 gflops)
        TensorEngineActive: generated ???, dcgm 0.000 (27615.3 gflops)
        TensorEngineActive: generated ???, dcgm 0.000 (27620.3 gflops)
        TensorEngineActive: generated ???, dcgm 0.000 (27530.7 gflops)
        TensorEngineActive: generated ???, dcgm 0.000 (27477.4 gflops)
        TensorEngineActive: generated ???, dcgm 0.000 (27461.1 gflops)
        TensorEngineActive: generated ???, dcgm 0.000 (27454.6 gflops)
        TensorEngineActive: generated ???, dcgm 0.000 (27381.2 gflops)
