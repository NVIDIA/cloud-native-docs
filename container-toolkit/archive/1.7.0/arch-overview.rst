.. Date: August 10 2020
.. Author: pramarao

.. _arch-overview-1.7.0:

*****************************************
Architecture Overview
*****************************************

The NVIDIA Container Toolkit is architected so that it can be targeted to support any container runtime in the ecosystem. 
For Docker, the NVIDIA Container Toolkit is comprised of the following components (from top to bottom in the hierarchy):

* ``nvidia-docker2``
* ``nvidia-container-runtime``
* ``nvidia-container-toolkit``
* ``libnvidia-container``

The following diagram represents the flow through the various components: 

.. image:: graphics/nvidia-docker-arch.png
   :width: 800

The packaging of the NVIDIA Container Toolkit is also reflective of these dependencies. If you start with the top-level 
``nvidia-docker2`` package for Docker, the package dependencies can be seen below:

.. code-block:: bash

    ├─ nvidia-docker2
    │    ├─ docker-ce (>= 18.06.0~ce~3-0~ubuntu)
    │    ├─ docker-ee (>= 18.06.0~ce~3-0~ubuntu)
    │    ├─ docker.io (>= 18.06.0)
    │    └─ nvidia-container-runtime (>= 3.3.0)

    ├─ nvidia-container-runtime
    │    └─ nvidia-container-toolkit (<< 2.0.0)

    ├─ nvidia-container-toolkit
    │    └─ libnvidia-container-tools (<< 2.0.0)
    
    ├─ libnvidia-container-tools
    │    └─ libnvidia-container1 (>= 1.2.0~rc.3)
    └─ libnvidia-container1

Let's take a brief look at each of the components in the software hierarchy (and corresponding packages).

Components and Packages
========================

``libnvidia-container``
````````````````````````

This component provides a library and a simple CLI utility to automatically configure GNU/Linux containers leveraging NVIDIA GPUs.
The implementation relies on kernel primitives and is designed to be agnostic of the container runtime. 

``libnvidia-container`` provides a well-defined API and a wrapper CLI (called ``nvidia-container-cli``) that different runtimes can invoke to 
inject NVIDIA GPU support into their containers.

``nvidia-container-toolkit``
`````````````````````````````

This component includes a script that implements the interface required by a ``runC`` ``prestart`` hook. This script is invoked by ``runC`` 
after a container has been created, but before it has been started, and is given access to the ``config.json`` associated with the container 
(e.g. this `config.json <https://github.com/opencontainers/runtime-spec/blob/master/config.md#configuration-schema-example=>`_ ). It then takes 
information contained in the ``config.json`` and uses it to invoke the ``libnvidia-container`` CLI with an appropriate set of flags. One of the 
most important flags being which specific GPU devices should be injected into the container.

Note that the previous name of this component was ``nvidia-container-runtime-hook``. ``nvidia-container-runtime-hook`` is now simply a symlink to 
``nvidia-container-toolkit`` on the system. 

``nvidia-container-runtime``
`````````````````````````````

This component used to be a complete fork of ``runC`` with NVIDIA specific code injected into it. Since 2019, it is a thin wrapper around the native 
``runC`` installed on the host system. ``nvidia-container-runtime`` takes a ``runC`` spec as input, injects the ``nvidia-container-toolkit`` script as 
a ``prestart`` hook into it, and then calls out to the native ``runC``, passing it the modified ``runC`` spec with that hook set. 
It's important to note that this component is not necessarily specific to docker (but it is specific to ``runC``).

When the package is installed, the Docker ``daemon.json`` is updated to point to the binary as can be seen below:

.. code-block:: bash

    /etc/docker/daemon.json
    { 
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }


``nvidia-docker2``
```````````````````

This package is the only docker-specific package of the hierarchy. It takes the script associated with the ``nvidia-container-runtime`` and installs it 
into docker's ``/etc/docker/daemon.json`` file. This then allows you to run (for example) ``docker run --runtime=nvidia ...`` to automatically add GPU support to your containers. 
It also installs a wrapper script around the native docker CLI called ``nvidia-docker`` which lets you invoke docker without needing to specify ``--runtime=nvidia`` every single time. 
It also lets you set an environment variable on the host (``NV_GPU``) to specify which GPUs should be injected into a container.

Which package should I use then?
=================================

Given this hierarchy of components it's easy to see that if you only install ``nvidia-container-toolkit``, then you will not get 
``nvidia-container-runtime`` installed as part of it, and thus ``--runtime=nvidia`` will not be available to you. With Docker 19.03+, this is fine because Docker directly 
invokes ``nvidia-container-toolkit`` when you pass it the ``--gpus`` option instead of relying on the ``nvidia-container-runtime`` as a proxy.

However, if you want to use Kubernetes with Docker 19.03+, you actually need to continue using ``nvidia-docker2`` because Kubernetes doesn't support passing GPU information 
down to docker through the ``--gpus`` flag yet. It still relies on ``nvidia-container-runtime`` to pass GPU information down the runtime stack via a set of environment variables.

The same container runtime stack is used regardless of whether ``nvidia-docker2`` or ``nvidia-container-toolkit`` is used. Using ``nvidia-docker2`` will install a thin runtime 
that can proxy GPU information down to ``nvidia-container-toolkit`` via environment variables instead of relying on the ``--gpus`` flag to have Docker do it directly. 

For purposes of simplicity (and backwards compatibility), it is recommended to continue using ``nvidia-docker2`` as the top-level install package.

See the :ref:`install-guide-1.7.0` for more information on installing ``nvidia-docker-1.7.02`` on various Linux distributions.

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


Releases of the software are also hosted on ``experimental`` branch of the repository and are graduated to ``stable`` after test/validation. To get access to the latest 
``experimental`` features of the NVIDIA Container Toolkit, you may need to add the ``experimental`` branch to the ``apt`` or ``yum`` repository listing. The installation instructions 
include information on how to add these repository listings for the package manager.
