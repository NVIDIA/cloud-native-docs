.. Date: August 10 2020
.. Author: pramarao

.. _docker:

Docker
-------

The NVIDIA Container Toolkit provides different options for enumerating GPUs and the capabilities that are supported 
for CUDA containers. 

Adding the NVIDIA Runtime
++++++++++++++++++++++++++
.. warning::
    Do not follow this section if you installed the ``nvidia-docker2`` package, it already registers the runtime.

To register the ``nvidia`` runtime, use the method below that is best suited to your environment.
You might need to merge the new argument with your existing configuration. Three options are available: 

Systemd drop-in file
`````````````````````
.. code:: bash

    sudo mkdir -p /etc/systemd/system/docker.service.d
    sudo tee /etc/systemd/system/docker.service.d/override.conf <<EOF
    [Service]
    ExecStart=
    ExecStart=/usr/bin/dockerd --host=fd:// --add-runtime=nvidia=/usr/bin/nvidia-container-runtime
    EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker

Daemon configuration file
`````````````````````````

The ``nvidia`` runtime can also be registered with Docker using the ``daemon.json`` configuration file:

.. code:: bash

    sudo tee /etc/docker/daemon.json <<EOF
    {
        "runtimes": {
            "nvidia": {
                "path": "/usr/bin/nvidia-container-runtime",
                "runtimeArgs": []
            }
        }
    }
    EOF
    sudo pkill -SIGHUP dockerd

You can optionally reconfigure the default runtime by adding the following to ``/etc/docker/daemon.json``:

.. code:: bash

    "default-runtime": "nvidia"

Command Line
`````````````

Use ``dockerd`` to add the ``nvidia`` runtime:

.. code:: bash

    sudo dockerd --add-runtime=nvidia=/usr/bin/nvidia-container-runtime [...]

Environment variables (OCI spec)
++++++++++++++++++++++++++++++++

Users can control the behavior of the NVIDIA container runtime using environment variables - especially for 
enumerating the GPUs and the capabilities of the driver. 
Each environment variable maps to an command-line argument for ``nvidia-container-cli`` from `libnvidia-container <https://github.com/NVIDIA/libnvidia-container>`_. 
These variables are already set in the NVIDIA provided base `CUDA images <https://ngc.nvidia.com/catalog/containers/nvidia:cuda>`_.

GPU Enumeration
````````````````

GPUs can be specified to the Docker CLI using either the ``--gpus`` option starting with Docker ``19.03`` or using the environment variable 
``NVIDIA_VISIBLE_DEVICES``. This variable controls which GPUs will be made accessible inside the container.

The possible values of the ``NVIDIA_VISIBLE_DEVICES`` variable are:

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

.. note::
    
    When using the ``--gpus`` option to specify the GPUs, the ``device`` parameter should be used. This is shown in the examples below. 
    The format of the ``device`` parameter should be encapsulated within single quotes, followed by double quotes for the devices you 
    want enumerated to the container. For example: ``'"device=2,3"'`` will enumerate GPUs 2 and 3 to the container. 

    When using the NVIDIA_VISIBLE_DEVICES variable, you may need to set ``--runtime`` to ``nvidia`` unless already set as default.

Some examples of the usage are shown below: 

#. Starting a GPU enabled CUDA container; using ``--gpus``

   .. code:: bash

        docker run --rm --gpus all nvidia/cuda nvidia-smi

#. Using ``NVIDIA_VISIBLE_DEVICES`` and specify the nvidia runtime

   .. code:: bash

      docker run --rm --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=all nvidia/cuda nvidia-smi
    
#. Start a GPU enabled container on two GPUs

   .. code:: bash

      docker run --rm --gpus 2 nvidia/cuda nvidia-smi

#. Starting a GPU enabled container on specific GPUs

  .. code:: bash
    
      docker run --gpus '"device=1,2"' nvidia/cuda nvidia-smi --query-gpu=uuid --format-csv
      uuid
      GPU-ad2367dd-a40e-6b86-6fc3-c44a2cc92c7e
      GPU-16a23983-e73e-0945-2095-cdeb50696982

#. Alternatively, you can also use ``NVIDIA_VISIBLE_DEVICES``

  .. code::bash

      docker run --rm --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=1,2 nvidia/cuda nvidia-smi --query-gpu=uuid --format=csv
      uuid
      GPU-ad2367dd-a40e-6b86-6fc3-c44a2cc92c7e
      GPU-16a23983-e73e-0945-2095-cdeb50696982

#. Query the GPU UUID using ``nvidia-smi`` and then specify that to the container
  
  .. code::bash
  
      nvidia-smi -i 3 --query-gpu=uuid --format=csv
      uuid
      GPU-18a3e86f-4c0e-cd9f-59c3-55488c4b0c24
      
      docker run --gpus device=GPU-18a3e86f-4c0e-cd9f-59c3-55488c4b0c24 nvidia/cuda nvidia-smi


Driver Capabilities
```````````````````

The ``NVIDIA_DRIVER_CAPABILITIES`` controls which driver libraries/binaries will be mounted inside the container.

The possible values of the ``NVIDIA_DRIVER_CAPABILITIES`` variable are:

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
      - use default driver capability: ``utility``

The supported driver capabilities are provided below:

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
