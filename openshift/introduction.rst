.. Date: Oct 24 2022
.. Author: kquinn

.. _essug: https://docs.nvidia.com/enterprise-support-and-services-user-guide/about-this-user-guide/index.html
.. |essug| replace:: *NVIDIA Enterprise Support and Services User Guide*

.. _openshift-introduction:

************************************************
Introduction to NVIDIA GPU Operator on OpenShift
************************************************

Kubernetes is an open-source platform for automating the deployment, scaling, and managing of containerized applications.

Red Hat OpenShift Container Platform is a security-centric and enterprise-grade hardened Kubernetes platform for deploying and managing Kubernetes clusters at scale, developed and supported by Red Hat.
Red Hat OpenShift Container Platform includes enhancements to Kubernetes so users can easily configure and use GPU resources for accelerating workloads like deep learning.

The NVIDIA GPU Operator uses the operator framework within Kubernetes to automate the management of all NVIDIA software components needed to provision GPU. These components include the NVIDIA drivers (to enable CUDA),
Kubernetes device plugin for GPUs, the `NVIDIA Container Toolkit <https://github.com/NVIDIA/nvidia-container-toolkit>`_,
automatic node labeling using `GFD <https://github.com/NVIDIA/gpu-feature-discovery>`_, `DCGM <https://developer.nvidia.com/dcgm>`_-based monitoring, and others.

For guidance on the specific NVIDIA support entitlement needs,
refer |essug|_ if you have an NVIDIA AI Enterprise entitlement.
Otherwise, refer to the `Obtaining Support from NVIDIA <https://access.redhat.com/solutions/5174941>`_
Red Hat Knowledgebase article.
