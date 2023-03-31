.. Date: November 11 2022
.. Author: elezar

As of the ``v1.12.0`` release the NVIDIA Container Toolkit includes support for generating `Container Device Interface <https://github.com/container-orchestrated-devices/container-device-interface>_` (CDI) specificiations
for use with CDI-enabled container engines and CLIs. These include:

* `cri-o <https://github.com/container-orchestrated-devices/container-device-interface#cri-o-configuration>`_
* `containerd <https://github.com/container-orchestrated-devices/container-device-interface#containerd-configuration>`_
* `podman <https://github.com/container-orchestrated-devices/container-device-interface#podman-configuration>`_

The use of CDI greatly improves the compatibility of the NVIDIA container stack with certain features such as rootless containers.

Step 1: Install NVIDIA Container Toolkit
-------------------------------------------

In order to generate CDI specifications for the NVIDIA devices available on a system, only the base components of the NVIDIA Container Toolkit are required.

This means that the instructions for configuring the NVIDIA Container Toolkit repositories should be followed as normal, but instead of
installing the ``nvidia-container-toolkit`` package, the ``nvidia-container-toolkit-base`` package should be installed instead:

.. tabs::

    .. tab:: Ubuntu LTS

        .. code-block:: console

            $ sudo apt-get update \
                && sudo apt-get install -y nvidia-container-toolkit-base

    .. tab:: CentOS / RHEL

        .. code-block:: console

            $ sudo dnf clean expire-cache \
                && sudo dnf install -y nvidia-container-toolkit-base

This should include the NVIDIA Container Toolkit CLI (``nvidia-ctk``) and the version can be confirmed by running:

.. code-block:: console

    $ nvidia-ctk --version


Step 2: Generate a CDI specification
-------------------------------------------

In order to generate a CDI specification that refers to all devices, the following command is used:

.. code-block:: console

    $ sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

To check the names of the generated devices the following command can be run:

.. code-block:: console

    $ grep "  name:" /etc/cdi/nvidia.yaml

.. note::

    This is run as ``sudo`` to ensure that the file at ``/etc/cdi/nvidia.yaml`` can be created.
    If an ``--output`` is not specified, the generated specification will be printed to ``STDOUT``.

.. note::

    Two typical locations for CDI specifications are ``/etc/cdi/`` and ``/var/run/cdi``, but the exact paths may depend on the CDI consumers (e.g. container engines) being used.

.. note::

    If the device or CUDA driver configuration is changed a new CDI specification must be generated. A configuration change could occur when MIG devices are created or removed, or when the driver is upgraded.


Step 3: Using the CDI specification
-------------------------------------------

.. note::

    The use of CDI to inject NVIDIA devices may conflict with the use of the NVIDIA Container Runtime hook. This means that if a ``/usr/share/containers/oci/hooks.d/oci-nvidia-hook.json`` file exists, it should be deleted or care should be taken to not run containers with the ``NVIDIA_VISIBLE_DEVICES`` environment variable set.


The use of the CDI specification is dependent on the CDI-enabled container engine or CLI being used. In the case of ``podman``, for example, releases as of ``v4.1.0`` include support for specifying CDI devices in the ``--device`` flag. Assuming that the specification has been generated as above, running a container with access to all NVIDIA GPUs would require the following command:

    .. code-block:: console

        $ podman run --rm --device nvidia.com/gpu=all ubuntu nvidia-smi -L

which should show the same output as ``nvidia-smi -L`` run on the host.

The CDI specification also contains references to individual GPUs or MIG devices and these can be requested as desired by specifying their names when launching a container as follows:

    .. code-block:: console

        $ podman run --rm --device nvidia.com/gpu=gpu0 --device nvidia.com/gpu=mig1:0 ubuntu nvidia-smi -L

Where the full GPU with index 0 and the first MIG device on GPU 1 is requested. The output should show only the UUIDs of the requested devices.
