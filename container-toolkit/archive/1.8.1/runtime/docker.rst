.. Date: August 10 2020
.. Author: pramarao

.. _docker-1.8.1:

Docker
-------

The NVIDIA Container Toolkit provides different options for enumerating GPUs and the capabilities that are supported 
for CUDA containers. This user guide demonstrates the following features of the NVIDIA Container Toolkit:

* Registering the NVIDIA runtime as a custom runtime to Docker
* Using environment variables to enable the following:

  * Enumerating GPUs and controlling which GPUs are visible to the container
  * Controlling which features of the driver are visible to the container using `capabilities`
  * Controlling the behavior of the runtime using constraints 


Adding the NVIDIA Runtime
++++++++++++++++++++++++++

.. warning::
    Do not follow this section if you installed the ``nvidia-docker2`` package, it already registers the runtime.

To register the ``nvidia`` runtime, use the method below that is best suited to your environment.
You might need to merge the new argument with your existing configuration. Three options are available: 

Systemd drop-in file
`````````````````````
.. code-block:: console

    $ sudo mkdir -p /etc/systemd/system/docker.service.d

.. code-block:: console

    $ sudo tee /etc/systemd/system/docker.service.d/override.conf <<EOF
    [Service]
    ExecStart=
    ExecStart=/usr/bin/dockerd --host=fd:// --add-runtime=nvidia=/usr/bin/nvidia-container-runtime
    EOF

.. code-block:: console

    $ sudo systemctl daemon-reload \
      && sudo systemctl restart docker

Daemon configuration file
`````````````````````````

The ``nvidia`` runtime can also be registered with Docker using the ``daemon.json`` configuration file:

.. code-block:: console

    $ sudo tee /etc/docker/daemon.json <<EOF
    {
        "runtimes": {
            "nvidia": {
                "path": "/usr/bin/nvidia-container-runtime",
                "runtimeArgs": []
            }
        }
    }
    EOF
  
.. code-block:: console

    sudo pkill -SIGHUP dockerd

You can optionally reconfigure the default runtime by adding the following to ``/etc/docker/daemon.json``:

.. code-block:: console

    "default-runtime": "nvidia"

Command Line
`````````````

Use ``dockerd`` to add the ``nvidia`` runtime:

.. code:: bash

    $ sudo dockerd --add-runtime=nvidia=/usr/bin/nvidia-container-runtime [...]

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

   .. code-block:: console

        $ docker run --rm --gpus all nvidia/cuda nvidia-smi

#. Using ``NVIDIA_VISIBLE_DEVICES`` and specify the nvidia runtime

   .. code-block:: console

      $ docker run --rm --runtime=nvidia \
          -e NVIDIA_VISIBLE_DEVICES=all nvidia/cuda nvidia-smi
    
#. Start a GPU enabled container on two GPUs

   .. code-block:: console

      $ docker run --rm --gpus 2 nvidia/cuda nvidia-smi

#. Starting a GPU enabled container on specific GPUs

   .. code-block:: console
    
      $ docker run --gpus '"device=1,2"' \
          nvidia/cuda nvidia-smi --query-gpu=uuid --format=csv

   .. code-block:: console

      uuid
      GPU-ad2367dd-a40e-6b86-6fc3-c44a2cc92c7e
      GPU-16a23983-e73e-0945-2095-cdeb50696982

#. Alternatively, you can also use ``NVIDIA_VISIBLE_DEVICES``

   .. code-block:: console

      $ docker run --rm --runtime=nvidia \
          -e NVIDIA_VISIBLE_DEVICES=1,2 \
          nvidia/cuda nvidia-smi --query-gpu=uuid --format=csv

   .. code-block:: console

      uuid
      GPU-ad2367dd-a40e-6b86-6fc3-c44a2cc92c7e
      GPU-16a23983-e73e-0945-2095-cdeb50696982

#. Query the GPU UUID using ``nvidia-smi`` and then specify that to the container
  
   .. code-block:: console
  
      $ nvidia-smi -i 3 --query-gpu=uuid --format=csv

   .. code-block:: console

      uuid
      GPU-18a3e86f-4c0e-cd9f-59c3-55488c4b0c24
   
   .. code-block:: console

      $ docker run --gpus device=GPU-18a3e86f-4c0e-cd9f-59c3-55488c4b0c24 \
           nvidia/cuda nvidia-smi


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
      - use default driver capability: ``utility``, ``compute``

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

For example, specify the ``compute`` and ``utility`` capabilities, allowing usage of CUDA and NVML

   .. code-block:: console

        $ docker run --rm --runtime=nvidia \
            -e NVIDIA_VISIBLE_DEVICES=2,3 \
            -e NVIDIA_DRIVER_CAPABILITIES=compute,utility \
            nvidia/cuda nvidia-smi

   .. code-block:: console 

        $ docker run --rm --gpus 'all,"capabilities=compute,utility"' \
            nvidia/cuda:11.0-base nvidia-smi

Constraints
```````````
The NVIDIA runtime also provides the ability to define constraints on the configurations supported by the container.

``NVIDIA_REQUIRE_*``
""""""""""""""""""""
This variable is a logical expression to define constraints on the software versions or GPU architectures on the container. 

The supported constraints are provided below:

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

Multiple constraints can be expressed in a single environment variable: space-separated constraints are ORed, 
comma-separated constraints are ANDed.
Multiple environment variables of the form ``NVIDIA_REQUIRE_*`` are ANDed together.

For example, the following constraints can be specified to the container image for constraining the supported CUDA and 
driver versions:

.. code-block:: console

  NVIDIA_REQUIRE_CUDA "cuda>=11.0 driver>=450"

``NVIDIA_DISABLE_REQUIRE``
""""""""""""""""""""""""""

Single switch to disable all the constraints of the form ``NVIDIA_REQUIRE_*``.

``NVIDIA_REQUIRE_CUDA``
"""""""""""""""""""""""

The version of the CUDA toolkit used by the container. It is an instance of the 
generic ``NVIDIA_REQUIRE_*`` case and it is set by official CUDA images. If the version of the NVIDIA driver 
is insufficient to run this version of CUDA, the container will not be started. This variable 
can be specified in the form ``major.minor``

The possible values for this variable: ``cuda>=7.5``, ``cuda>=8.0``, ``cuda>=9.0`` and so on.

Dockerfiles
````````````

Capabilities and GPU enumeration can be set in images via environment variables. If the environment variables are 
set inside the Dockerfile, you don't need to set them on the ``docker run`` command-line.

For instance, if you are creating your own custom CUDA container, you should use the following:

.. code-block:: console

  ENV NVIDIA_VISIBLE_DEVICES all
  ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

These environment variables are already set in the NVIDIA provided CUDA images.

Troubleshooting
++++++++++++++++

Generating debugging logs
``````````````````````````

For most common issues, debugging logs can be generated and can help us root cause the problem.
In order to generate these:

* Edit your runtime configuration under ``/etc/nvidia-container-runtime/config.toml`` and uncomment the ``debug=...`` line.
* Run your container again, thus reproducing the issue and generating the logs.

Generating core dumps
``````````````````````
In the event of a critical failure, core dumps can be automatically generated and can help us troubleshoot issues.
Refer to `core(5) <http://man7.org/linux/man-pages/man5/core.5.html>`_ in order to generate these, in particular make sure that:

* ``/proc/sys/kernel/core_pattern`` is correctly set and points somewhere with write access
* ``ulimit -c`` is set to a sensible default

In case the ``nvidia-container-cli`` process becomes unresponsive, `gcore(1) <http://man7.org/linux/man-pages/man1/gcore.1.html>`_ can also be used.

Sharing your debugging information
```````````````````````````````````

You can attach a particular output to your issue with a `drag and drop <https://help.github.com/articles/file-attachments-on-issues-and-pull-requests/>`_ 
into the comment section.
