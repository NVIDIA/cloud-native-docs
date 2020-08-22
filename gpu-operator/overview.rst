.. Date: July 30 2020
.. Author: pramarao

*****************************************
NVIDIA GPU Operator
*****************************************
Overview
=========

.. image:: graphics/nvidia-gpu-operator-image.jpg
   :width: 600

Kubernetes provides access to special hardware resources such as NVIDIA GPUs, NICs, Infiniband adapters and other devices 
through the `device plugin framework <https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/>`_. 
However, configuring and managing nodes with these hardware resources requires 
configuration of multiple software components such as drivers, container runtimes or other libraries which are difficult 
and prone to errors. The NVIDIA GPU Operator uses the `operator framework <https://coreos.com/blog/introducing-operator-framework>`_ 
within Kubernetes to automate the management of all NVIDIA software components needed to provision GPU. These components include the NVIDIA drivers (to enable CUDA), 
Kubernetes device plugin for GPUs, the NVIDIA Container Runtime, automatic node labelling, `DCGM <https://developer.nvidia.com/dcgm>`_ based monitoring and others.

----

Documentation
==============

Browse through the following documents for getting started, platform support and release notes.

Getting Started
---------------

The :ref:`operator-install-guide` guide includes information on installing the GPU Operator in a Kubernetes cluster.

Release Notes
---------------

Refer to :ref:`operator-release-notes` for information about releases.

Platform Support
---------------

The :ref:`operator-platform-support` describes the supported platform configurations.
