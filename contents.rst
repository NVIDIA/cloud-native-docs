.. NVIDIA Cloud Native Technologies documentation master file, created by
   sphinx-quickstart on Mon Jul 27 23:51:30 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

NVIDIA Cloud Native Technologies
================================
This documentation repository contains the product documentation for the
:ref:`NVIDIA Container Toolkit <container-toolkit/overview>`, the :ref:`NVIDIA GPU Operator <gpu-operator/overview>`, and
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
   container-toolkit/troubleshooting.rst
   container-toolkit/user-guide.rst
   container-toolkit/release-notes.rst
   container-toolkit/archive.rst

.. toctree::
   :maxdepth: 2
   :caption: NVIDIA GPU Operator:

   gpu-operator/overview.rst
   gpu-operator/getting-started.rst
   gpu-operator/platform-support.rst
   gpu-operator/release-notes.rst
   gpu-operator/gpu-driver-upgrades.rst
   gpu-operator/install-gpu-operator-vgpu.rst
   gpu-operator/install-gpu-operator-nvaie.rst
   GPU Operator on OpenShift <gpu-operator/openshift/contents.rst>
   gpu-operator/gpu-operator-mig.rst
   gpu-operator/gpu-sharing.rst
   gpu-operator/gpu-operator-rdma.rst
   gpu-operator/gpu-operator-kubevirt.rst
   gpu-operator/appendix.rst
   gpu-operator/archive.rst

.. toctree::
   :maxdepth: 2
   :caption: Kubernetes with GPUs:

   kubernetes/install-k8s.rst
   kubernetes/mig-k8s.rst
   kubernetes/anthos-guide.rst

.. toctree::
   :titlesonly:
   :caption: NVIDIA GPUs and Red Hat Device Edge

   edge/nvidia-gpu-with-device-edge.rst

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
