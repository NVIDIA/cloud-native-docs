---
name: "ocp-get-started"
description: "Overviews of the NVIDIA GPU Operator on Red Hat OpenShift Container Platform. Trigger keywords - GPU Operator, OpenShift, introduction, overview, OCP, entitlement, driver build, deprecated."
license: "Apache-2.0"
---

# Introduction to NVIDIA GPU Operator on OpenShift

---
substitutions:
  essug: '*NVIDIA Enterprise Support and Services User Guide*'
---

<a id="openshift-introduction"></a>

# Introduction to NVIDIA GPU Operator on OpenShift

Kubernetes is an open-source platform for automating the deployment, scaling, and managing of containerized applications.

Red Hat OpenShift Container Platform is a security-centric and enterprise-grade hardened Kubernetes platform for deploying and managing Kubernetes clusters at scale, developed and supported by Red Hat.
Red Hat OpenShift Container Platform includes enhancements to Kubernetes so users can easily configure and use GPU resources for accelerating workloads like deep learning.

The NVIDIA GPU Operator uses the operator framework within Kubernetes to automate the management of all NVIDIA software components needed to provision GPU. These components include the NVIDIA drivers (to enable CUDA),
Kubernetes device plugin for GPUs, the [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-container-toolkit),
automatic node labeling using [GFD](https://github.com/NVIDIA/gpu-feature-discovery), [DCGM](https://developer.nvidia.com/dcgm)-based monitoring, and others.

For guidance on the specific NVIDIA support entitlement needs,
refer [essug] if you have an NVIDIA AI Enterprise entitlement.
Otherwise, refer to the [Obtaining Support from NVIDIA](https://access.redhat.com/solutions/5174941)
Red Hat Knowledgebase article.

[essug]: https://docs.nvidia.com/enterprise-support-and-services-user-guide/about-this-user-guide/index.html

## References

- **[references/get-entitlement.md](references/get-entitlement.md)** — Information about the deprecation of entitled NVIDIA driver builds on OpenShift.
