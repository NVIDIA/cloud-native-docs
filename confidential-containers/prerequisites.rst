.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

.. headings # #, * *, =, -, ^, "


.. _coco-prerequisites:

#############
Prerequisites
#############

As a :ref:`Kubernetes Cluster Administrator <coco-persona-kubernetes-cluster-administrator>`, prepare hosts and the Kubernetes cluster before you install Kata Containers and the NVIDIA GPU Operator.
You perform most steps in this section.
If you do not have access to host firmware, coordinate with your :ref:`Hardware IT Administrator <coco-persona-hardware-it-administrator>` or :ref:`Host OS Administrator <coco-persona-host-os-administrator>` to confirm or implement hardware prerequisites.

For validated hardware and software versions, refer to :doc:`Supported Platforms <supported-platforms>`.
Use the checklists below for an at-a-glance summary, then follow each linked section for verification steps.

**Hardware prerequisites**

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Prerequisite
     - Details
   * - :ref:`Use a supported platform <coco-prereq-supported-platform>`
     - CPU, GPU, and host OS match :doc:`Supported Platforms <supported-platforms>`
   * - :ref:`Hardware virtualization and ACS enabled <coco-prereq-hw-virtualization>`
     - Hardware virtualization and ACS enabled in host BIOS
   * - :ref:`IOMMU enabled <coco-prereq-iommu>`
     - IOMMU enabled on each host through the kernel command line (``amd_iommu=on`` or ``intel_iommu=on``)
   * - :ref:`No host NVIDIA GPU drivers <coco-prereq-no-host-drivers>`
     - No NVIDIA GPU drivers installed or loaded on worker hosts.

**Cluster prerequisites**

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Prerequisite
     - Details
   * - :ref:`A Kubernetes cluster and cluster administrator access <coco-prereq-cluster-admin>`
     - Cluster administrator access to a Kubernetes cluster running a supported version (refer to :ref:`Supported Software Components <coco-supported-software-components>`)
   * - :ref:`containerd 2.2.2 installed <coco-prereq-containerd>`
     - containerd 2.2.2 installed on each GPU worker node
   * - :ref:`Helm installed <coco-prereq-helm>`
     - Helm installed on your cluster administration system
   * - :ref:`Kubelet configured <coco-prereq-kubelet>`
     - Enable ``KubeletPodResourcesGet`` (required before Kubernetes v1.34) and ``RuntimeClassInImageCriApi`` feature gates; set ``runtimeRequestTimeout: 20m`` on GPU worker nodes

*****************
Hardware and BIOS
*****************

.. _coco-prereq-supported-platform:

Supported Platform
==================

Your hosts must use a platform validated for Confidential Computing in :doc:`Supported Platforms <supported-platforms>`.
Confirm with your :ref:`Hardware IT Administrator <coco-persona-hardware-it-administrator>` and :ref:`Host OS Administrator <coco-persona-host-os-administrator>` that any platform-specific BIOS, firmware, or OS steps are in place before continuing.

.. _coco-prereq-hw-virtualization:

Hardware Virtualization and ACS Enabled
=======================================

Confirm with your :ref:`Hardware IT Administrator <coco-persona-hardware-it-administrator>` that your hosts are configured to enable hardware virtualization and Access Control Services (ACS).
With some AMD CPUs and BIOSes, ACS might be grouped under Advanced Error Reporting (AER).
Enable these features in the host BIOS if they are not already enabled.

.. _coco-prereq-iommu:

IOMMU Enabled
=============

IOMMU must be enabled on all hosts that will run Confidential Containers workloads.

#. Check whether IOMMU is already enabled:

   .. code-block:: console

      $ ls /sys/kernel/iommu_groups

   If the output lists numbered groups (``0``, ``1``, and so on), IOMMU is enabled.

   If the output is empty or the directory is missing, IOMMU is not enabled.

#. If IOMMU is not enabled, add the appropriate kernel command-line argument to ``/etc/default/grub``:

   * ``amd_iommu=on`` for AMD CPUs
   * ``intel_iommu=on`` for Intel CPUs

   .. tab-set::

      .. tab-item:: AMD-based system (SNP)
         :sync: amd-snp

         .. code-block:: console

            ...
            GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on modprobe.blacklist=nouveau"
            ...

      .. tab-item:: Intel-based system (TDX)
         :sync: intel-tdx

         .. code-block:: console

            ...
            GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on modprobe.blacklist=nouveau"
            ...

#. Update the bootloader configuration:

   .. code-block:: console

      $ sudo update-grub

   *Example Output:*

   .. code-block:: output

      Sourcing file `/etc/default/grub'
      Generating grub configuration file ...
      Found linux image: /boot/vmlinuz-5.15.0-generic
      Found initrd image: /boot/initrd.img-5.15.0-generic
      done

#. Reboot the host.

.. note::

   After configuring IOMMU, you might see QEMU warnings about PCI P2P DMA when running GPU workloads.
   These are expected and can be safely ignored.
   Refer to :ref:`coco-limitations` for details.

.. _coco-prereq-no-host-drivers:

Ensure No Host NVIDIA GPU Drivers Are Present
=============================================

Confidential Containers pass GPUs to the confidential virtual machine through VFIO.
Host-installed NVIDIA drivers prevent VFIO from binding the devices and must not be present on those hosts.
In this architecture, the NVIDIA GPU Operator handles GPU driver installation and lifecycle management when you follow the :doc:`Detailed Install Guide <confidential-containers-deploy>`.

#. On each host, check whether NVIDIA GPU drivers are loaded:

   .. code-block:: console

      $ lsmod | grep nvidia

   If the command produces no output, no NVIDIA GPU drivers are loaded.

#. If drivers are installed or loaded on any host, remove them.

   Refer to `Removing the Driver <https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/removing-the-driver.html>`_ in the NVIDIA Driver Installation Guide.

******************
Kubernetes Cluster
******************

The following sections describe requirements for worker nodes and for the system you use for cluster administration.

.. _coco-prereq-cluster-admin:

Kubernetes Cluster and Cluster Administrator Access
===================================================

You must have cluster administrator access to a Kubernetes cluster running a supported Kubernetes version.
Refer to the :ref:`Supported Software Components <coco-supported-software-components>` section in :doc:`Supported Platforms <supported-platforms>` for supported Kubernetes and component versions.

.. _coco-prereq-containerd:

containerd 2.2.2
================

Verify the installed version on each GPU worker node:

.. code-block:: console

  $ containerd --version

*Example Output:*

.. code-block:: output

  containerd containerd.io 2.2.2 ...

If you are running a different version on any worker node, refer to the `containerd Getting Started guide <https://containerd.io/docs/2.2/getting-started/>`_ for installation instructions.

.. _coco-prereq-helm:

Helm
====

Helm is used to install the NVIDIA GPU Operator and Kata Containers.

Verify that Helm is installed on the system you use for cluster administration:

.. code-block:: console

  $ helm version

*Example Output:*

.. code-block:: output

  version.BuildInfo{Version:"v3.14.0", GitCommit:"...", GitTreeState:"clean", GoVersion:"go1.21.6"}

Your exact version details may vary.

If Helm is not installed or the command is not found, refer to the `Helm documentation <https://helm.sh/docs/intro/install/>`_ for installation instructions.

.. _coco-prereq-kubelet:
.. _configure-image-pull-timeouts:

Kubelet Configured
==================

On GPU worker nodes, the kubelet configuration (typically ``/var/lib/kubelet/config.yaml``) must include the required feature gates and an extended image pull timeout.

Confidential Containers require these kubelet feature gates:

* ``KubeletPodResourcesGet``: Allows the Kata runtime to query the kubelet Pod Resources API and discover GPUs allocated to a sandbox.

* ``RuntimeClassInImageCriApi``: Alpha since Kubernetes v1.29; required for pods that use multiple snapshotters side by side.

On Kubernetes v1.34 and later, ``KubeletPodResourcesGet`` is enabled by default.
On versions before v1.34, enable it explicitly.
``RuntimeClassInImageCriApi`` must be enabled explicitly on all supported versions.

Increase the ``runtimeRequestTimeout`` from the 2-minute default to ``20m`` to avoid timeouts when pulling large GPU workload images.
If a pull exceeds the timeout before the container is running, the kubelet de-allocates the pod.
Actual pull duration varies with image size and network throughput, so this guide uses 20 minutes as a conservative ceiling that accommodates most workload images.

Apply these settings as follows:

#. Open the kubelet configuration file:

   .. code-block:: console
      
      $ sudo nano /var/lib/kubelet/config.yaml

   This is typically located at ``/var/lib/kubelet/config.yaml``, but your configuration file may be in a different location.

#. Add the required settings to the kubelet configuration file.
   Select the tab that matches your Kubernetes version:

   .. tab-set::

      .. tab-item:: Kubernetes v1.34 and later
         :sync: k8s-1-34-plus

         .. code-block:: yaml

            apiVersion: kubelet.config.k8s.io/v1beta1
            kind: KubeletConfiguration
            featureGates:
              RuntimeClassInImageCriApi: true
            runtimeRequestTimeout: 20m

      .. tab-item:: Kubernetes earlier than v1.34
         :sync: k8s-pre-1-34

         .. code-block:: yaml

            apiVersion: kubelet.config.k8s.io/v1beta1
            kind: KubeletConfiguration
            featureGates:
              KubeletPodResourcesGet: true
              RuntimeClassInImageCriApi: true
            runtimeRequestTimeout: 20m

   If your kubelet configuration already defines ``featureGates`` or ``runtimeRequestTimeout``, merge these settings into the existing file instead of replacing it.

#. Restart the kubelet service:

   .. code-block:: console

      $ sudo systemctl restart kubelet

.. note::

   If you need a timeout longer than 1200 seconds (20 minutes), also adjust the Kata Agent ``image_pull_timeout``.
   This setting controls the Confidential Data Hub image pull API timeout in seconds.
   Add the ``agent.image_pull_timeout`` kernel parameter to your shim configuration, or pass a value in the pod annotation ``io.katacontainers.config.hypervisor.kernel_params``.

**********
Next Steps
**********

After completing the prerequisites, proceed to :doc:`Quickstart Install <install-quickstart>` for a minimal install, or :doc:`Detailed Install Guide <confidential-containers-deploy>` for full configuration details.
