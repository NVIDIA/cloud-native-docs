.. Date: Oct 24 2022
.. Author: kquinn

.. _openshift-introduction-22.9.2:

*****************************************
Introduction
*****************************************
Kubernetes is an open-source platform for automating the deployment, scaling, and managing of containerized applications.

Red Hat OpenShift Container Platform is a security-centric and enterprise-grade hardened Kubernetes platform for deploying and managing Kubernetes clusters at scale, developed and supported by Red Hat.
Red Hat OpenShift Container Platform includes enhancements to Kubernetes so users can easily configure and use GPU resources for accelerating workloads such as deep learning.

The NVIDIA GPU Operator uses the operator framework within Kubernetes to automate the management of all NVIDIA software components needed to provision GPU. These components include the NVIDIA drivers (to enable CUDA),
Kubernetes device plugin for GPUs, the `NVIDIA Container Toolkit <https://github.com/NVIDIA/nvidia-docker>`_,
automatic node labelling using `GFD <https://github.com/NVIDIA/gpu-feature-discovery>`_, `DCGM <https://developer.nvidia.com/dcgm>`_ based monitoring and others.

For guidance on the specific NVIDIA support entitlement needs, see `obtaining support from NVIDIA <https://access.redhat.com/solutions/5174941>`_.
