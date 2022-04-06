.. Date: August 10 2020
.. Author: pramarao

.. _arch-overview-1.9.0:

*****************************************
Architecture Overview
*****************************************

The NVIDIA container stack is architected so that it can be targeted to support any container runtime in the ecosystem.
The components of the stack include:

* The ``nvidia-docker`` wrapper
* The NVIDIA Container Runtime (``nvidia-container-runtime``)
* The NVIDIA Container Runtime Hook (``nvidia-container-toolkit`` / ``nvidia-container-runtime-hook``)
* The NVIDIA Container Library and CLI (``libnvidia-container1``, ``nvidia-container-cli``)

With the exception of the ``nvidia-docker`` wrapper, the components of the NVIDIA container stack are packaged as the
NVIDIA Container Toolkit.

How these components are used depends on the container runtime being used. For Docker used with the ``nvidia-docker`` wrapper, the
flow through the various components is shown in the following diagram:

.. image:: graphics/nvidia-docker-arch-new.png
   :width: 800

Note that as long as the ``docker`` runtimes have been configured correctly, the use of the ``nvidia-docker`` wrapper is optional.

The flow through the components for ``containerd`` using the NVIDIA Container Runtime is similar and shown below:

.. image:: graphics/nvidia-containerd-arch.png
   :width: 800

The flow through components for ``cri-o`` and ``lxc`` are shown in the following diagram. It should be noted that in this
case the NVIDIA Container Runtime component is not required.

.. image:: graphics/nvidia-crio-lxc-arch.png
   :width: 800

Let's take a brief look at each of the components in the NVIDIA container stack, starting
with the lowest level component and working up

Components and Packages
========================

The main packages of the NVIDIA Container Toolkit are:

* ``nvidia-container-toolkit``
* ``libnvidia-container-tools``
* ``libnvidia-container1``

With the dedpendencies between these packages shown below:

.. code-block:: bash

    ├─ nvidia-container-toolkit (version)
    │    └─ libnvidia-container-tools (>= version)
    │
    ├─ libnvidia-container-tools (version)
    │    └─ libnvidia-container1 (>= version)
    └─ libnvidia-container1 (version)

where ``version`` is used to represent the NVIDIA Container Toolkit version.

In addition to these main packages, the following two packages are considered part of the NVIDIA container stack:

* ``nvidia-docker2``
* ``nvidia-container-runtime``

with their dependence on the ``nvidia-container-toolkit`` package shown below:

.. code-block:: bash

    ├─ nvidia-docker2
    │    ├─ docker-ce || docker-ee || docker.io
    │    └─ nvidia-container-toolkit (>= version)
    │
    └─ nvidia-container-runtime
         └─ nvidia-container-toolkit (>= version, << 2.0.0)

Once again ``version`` is used to indicate the version of the NVIDIA Container Toolkit.

Since the ``nvidia-docker2`` package contains docker-specifics, it also introduces a dependence on ``docker`` packages
that are determined by the platform where the package is being installed.

Note that as of version ``3.6.0``, the ``nvidia-container-runtime`` package is a meta package that only depends on the ``nvidia-container-toolkit``
package and does not provide any functionality of itself.

The NVIDIA Container Library and CLI
````````````````````````````````````

These components are packaged as the ``libnvidia-container-tools`` and ``libnvidia-container1`` packages, respectively.

These components provide a library and a simple CLI utility to automatically configure GNU/Linux containers leveraging NVIDIA GPUs.
The implementation relies on kernel primitives and is designed to be agnostic of the container runtime.

``libnvidia-container`` provides a well-defined API and a wrapper CLI (called ``nvidia-container-cli``) that different runtimes can invoke to
inject NVIDIA GPU support into their containers.

The NVIDIA Container Runtime Hook
```````````````````````````````````

This component is included in the ``nvidia-container-toolkit`` package.

This component includes a script that implements the interface required by a ``runC`` ``prestart`` hook. This script is invoked by ``runC``
after a container has been created, but before it has been started, and is given access to the ``config.json`` associated with the container
(e.g. this `config.json <https://github.com/opencontainers/runtime-spec/blob/master/config.md#configuration-schema-example=>`_ ). It then takes
information contained in the ``config.json`` and uses it to invoke the ``libnvidia-container`` CLI with an appropriate set of flags. One of the
most important flags being which specific GPU devices should be injected into the container.

The NVIDIA Container Runtime
`````````````````````````````

This component is included in the ``nvidia-container-toolkit`` package.

This component used to be a complete fork of ``runC`` with NVIDIA specific code injected into it. Since 2019, it is a thin wrapper around the native
``runC`` installed on the host system. ``nvidia-container-runtime`` takes a ``runC`` spec as input, injects the NVIDIA Container Runtime Hook as
a ``prestart`` hook into it, and then calls out to the native ``runC``, passing it the modified ``runC`` spec with that hook set.
It's important to note that this component is not necessarily specific to docker (but it is specific to ``runC``).

The ``nvidia-docker`` wrapper
`````````````````````````````

This component is provided by the ``nvidia-docker2`` package.

When the package is installed, the Docker ``daemon.json`` is updated to point to the binary as can be seen below:

.. code-block:: bash

    $ cat /etc/docker/daemon.json
    {
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }

The wrapper is the only docker-specific component of the hierarchy. When the package is installed, it takes the script
associated with the ``nvidia-container-runtime`` and installs it into docker's ``/etc/docker/daemon.json`` file.
This then allows you to run (for example) ``docker run --runtime=nvidia ...`` to automatically add GPU support to your containers.
The package also installs a wrapper script around the native docker CLI called ``nvidia-docker`` which lets you invoke docker without needing to specify ``--runtime=nvidia`` every single time.
It also lets you set an environment variable on the host (``NV_GPU``) to specify which GPUs should be injected into a container.

Which package should I use then?
=================================

As a general rule, installing the ``nvidia-container-toolkit`` package will be sufficient for most use cases. This
package is continuously being enhanced with additional functionality and tools that simplify working with containers and
NVIDIA devices.

However, if you want to use Kubernetes with Docker, you need to either configure the Docker ``daemon.json`` to include
a reference to the NVIDIA Container Runtime and set this runtime as the default or install the ``nvidia-docker2`` package
which would overwrite the ``daemon.json`` file on the host.

See the :ref:`install-guide-1.9.0` for more information on installing ``nvidia-docker-1.9.02`` on various Linux distributions.

Package Repository
```````````````````

The packages for the various components listed above are available in the ``gh-pages`` branch of the GitHub repos of these projects. This is particularly
useful for air-gapped deployments that may want to get access to the actual packages (``.deb`` and ``.rpm``) to support offline installs.

For the different components:

#. ``nvidia-docker2``

   * ``https://github.com/NVIDIA/nvidia-docker/tree/gh-pages/``

#. ``nvidia-container-toolkit``

   * ``https://github.com/NVIDIA/nvidia-container-runtime/tree/gh-pages/``

#. ``libnvidia-container``

   * ``https://github.com/NVIDIA/libnvidia-container/tree/gh-pages/``


.. note::
   As of the release of version ``1.6.0`` of the NVIDIA Container Toolkit the packages for all components are
   published to the ``libnvidia-container`` `repository <https://nvidia.github.io/libnvidia-container/>` listed above.

Releases of the software are also hosted on ``experimental`` branch of the repository and are graduated to ``stable`` after test/validation. To get access to the latest
``experimental`` features of the NVIDIA Container Toolkit, you may need to add the ``experimental`` branch to the ``apt`` or ``yum`` repository listing. The installation instructions
include information on how to add these repository listings for the package manager.
