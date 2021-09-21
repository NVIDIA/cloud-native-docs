.. NVIDIA Cloud Native Technologies documentation master file, created by
   sphinx-quickstart on Mon Jul 27 23:51:30 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

NVIDIA Cloud Native Technologies
================================
This documentation repository contains the product documentation for the
NVIDIA Container Toolkit (``nvidia-docker2``), the NVIDIA GPU Operator and
using NVIDIA GPUs with Kubernetes.

.. toctree::
   :hidden:

..   Documentation home <self>

.. toctree::
   :maxdepth: 2
   :caption: NVIDIA Container Toolkit:

   container-toolkit/overview.rst
   container-toolkit/concepts.rst
   container-toolkit/arch-overview.rst
   container-toolkit/install-guide.rst
   container-toolkit/user-guide.rst
   container-toolkit/release-notes.rst

.. toctree::
   :maxdepth: 2
   :caption: NVIDIA GPU Operator:

   gpu-operator/overview.rst
   gpu-operator/getting-started.rst
   gpu-operator/platform-support.rst
   gpu-operator/release-notes.rst
   gpu-operator/install-gpu-operator-vgpu.rst
   gpu-operator/install-gpu-operator-nvaie.rst
   gpu-operator/gpu-operator-mig.rst
   gpu-operator/gpu-operator-rdma.rst
   gpu-operator/appendix.rst

.. toctree::
   :maxdepth: 2
   :caption: OpenShift with GPUs:

   openshift/introduction.rst
   openshift/prerequisites.rst
   openshift/steps-overview.rst
   openshift/cluster-entitlement.rst
   openshift/install-nfd.rst
   openshift/install-gpu-ocp.rst
   openshift/clean-up.rst
   openshift/troubleshooting-gpu-ocp.rst

.. toctree::
   :maxdepth: 2
   :caption: Kubernetes with GPUs:

   kubernetes/install-k8s.rst
   kubernetes/mig-k8s.rst
   kubernetes/anthos-guide.rst
   kubernetes/dcgme2e

.. toctree::
   :maxdepth: 2
   :caption: GPU Telemetry:

   gpu-telemetry/dcgm-exporter.rst

.. toctree::
   :maxdepth: 2
   :caption: Multi-Instance GPU:

   mig/mig.rst
   mig/mig-k8s.rst

.. toctree::
   :maxdepth: 2
   :caption: Driver Containers:

   driver-containers/overview.rst

.. toctree::
   :maxdepth: 2
   :caption: Playground:

   playground/dind.rst
   playground/x-arch.rst

.. Indices and tables
.. ==================
..
.. * :ref:`genindex`
