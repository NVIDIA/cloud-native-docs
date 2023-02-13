.. Date: July 30 2020
.. Author: pramarao

*****************************
About the NVIDIA GPU Operator
*****************************

.. image:: graphics/nvidia-gpu-operator-image.jpg
   :width: 600

Kubernetes provides access to special hardware resources such as NVIDIA GPUs, NICs, Infiniband adapters and other devices
through the `device plugin framework <https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/>`_.
However, configuring and managing nodes with these hardware resources requires
configuration of multiple software components such as drivers, container runtimes or other libraries which are difficult
and prone to errors. The NVIDIA GPU Operator uses the `operator framework <https://coreos.com/blog/introducing-operator-framework>`_
within Kubernetes to automate the management of all NVIDIA software components needed to provision GPU. These components include the NVIDIA drivers (to enable CUDA),
Kubernetes device plugin for GPUs, the `NVIDIA Container Toolkit <https://github.com/NVIDIA/nvidia-docker>`_,
automatic node labelling using `GFD <https://github.com/NVIDIA/gpu-feature-discovery>`_, `DCGM <https://developer.nvidia.com/dcgm>`_ based monitoring and others.

The NVIDIA GPU Operator automates the lifecycle management of the software required to use GPUs with Kubernetes.
The Operator takes care of the complexity that arises from managing the lifecycle of GPU resources and also handles all the
configuration steps for provisioning NVIDIA GPUs so they can scale like other resources.
Advanced features of the NVIDIA GPU Operator enable better performance, higher utilization, and access to GPU telemetry.
Certified and validated for compatibility with industry-leading Kubernetes solutions, the Operator enables organizations
to focus on building applications rather than managing the Kubernetes infrastructure.
