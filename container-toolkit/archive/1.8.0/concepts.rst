.. Date: August 10 2020
.. Author: pramarao

.. _concepts-1.8.0:

*****************************************
Concepts
*****************************************

What is Docker?
=================

From the official `Docker pages <https://www.docker.com/what-docker>`_::

    Docker containers wrap a piece of software in a complete filesystem that contains everything needed to run: code, 
    runtime, system tools, system libraries – anything that can be installed on a server. This guarantees that the software 
    will always run the same, regardless of its environment.

More high-level information about Docker can be found on the Moby project `README <https://github.com/moby/moby/blob/master/README.md>`_. 
Technical documentation can be found on the Docker documentation `repository <https://docs.docker.com/>`_.

Motivation
=================

Benefits of GPU containerization
---------------------------------

Containerizing GPU applications provides several benefits, among them:

* Ease of deployment
* Isolation of individual devices
* Run across heterogeneous driver/toolkit environments
* Requires only the NVIDIA driver to be installed on the host
* Facilitate collaboration: reproducible builds, reproducible performance, reproducible results.

Background
-----------

Docker® containers are often used to seamlessly deploy CPU-based applications on multiple machines. With this use case, containers 
are both hardware-agnostic and platform-agnostic. This is obviously not the case when using NVIDIA GPUs since it is using specialized 
hardware and it requires the installation of the NVIDIA driver. As a result, Docker Engine does not natively support NVIDIA GPUs with containers.

To solve this problem, one of the early solutions that emerged was to fully reinstall the NVIDIA driver inside the container and then pass the 
character devices corresponding to the NVIDIA GPUs (e.g. ``/dev/nvidia0``) when starting the container. However, this solution was brittle: the version of 
the host driver had to exactly match driver version installed in the container. The Docker images could not be shared and had to be built locally 
on each machine, defeating one of the main advantages of Docker.

To make the Docker images portable while still leveraging NVIDIA GPUs, the container images must be agnostic of the NVIDIA driver. 
The NVIDIA Container Toolkit provides utilities to enable GPU support inside the container runtime.

