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

*************
Prerequisites
*************

Complete the following prerequisites before deploying Confidential Containers.
Refer to the :doc:`Supported Platforms <supported-platforms>` page for validated hardware and software versions.

Hardware and BIOS
=================

* Use a supported platform configured for Confidential Computing.
  For more information on machine setup, refer to :doc:`Supported Platforms <supported-platforms>`.

* Ensure hosts are configured to enable hardware virtualization and Access Control Services (ACS). With some AMD CPUs and BIOSes, ACS might be grouped under Advanced Error Reporting (AER). Enable these features in the host BIOS.

* Configure hosts to support IOMMU. 
  You can check if your host is configured for IOMMU by running the following command:

  .. code-block:: console

     $ ls /sys/kernel/iommu_groups

  If the output of this command includes 0, 1, and so on, then your host is configured for IOMMU.

  If the host is not configured or if you are unsure, add the ``amd_iommu=on`` Linux kernel command-line argument. For most Linux distributions, add the argument to the ``/etc/default/grub`` file, for instance::

      ...
      GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on modprobe.blacklist=nouveau"
      ...

  After making the change, configure the bootloader

  .. code-block:: console

     $ sudo update-grub

  *Example Output:*

  .. code-block:: output

     Sourcing file `/etc/default/grub'
     Generating grub configuration file ...
     Found linux image: /boot/vmlinuz-5.15.0-generic
     Found initrd image: /boot/initrd.img-5.15.0-generic
     done

  Reboot the host after configuring the bootloader.

  .. note::

      After configuring IOMMU, you might see QEMU warnings about PCI P2P DMA when running GPU workloads.
      These are expected and can be safely ignored.
      Refer to :ref:`coco-limitations` for details.

* Ensure that no NVIDIA GPU drivers are installed on the host.
  Confidential Containers uses VFIO to pass GPUs directly to the confidential VM, and host-level GPU drivers interfere with VFIO device binding.

  To check if NVIDIA GPU drivers are installed, run the following command:

  .. code-block:: console

     $ lsmod | grep nvidia

  If the output is empty, no NVIDIA GPU drivers are loaded.
  If modules such as ``nvidia``, ``nvidia_uvm``, or ``nvidia_modeset`` are listed, NVIDIA GPU drivers are present and must be removed before proceeding.
  Refer to `Removing the Driver <https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/removing-the-driver.html>`_ in the NVIDIA Driver Installation Guide.

Kubernetes Cluster
==================

* A Kubernetes cluster with cluster administrator privileges.
  Refer to the :ref:`Supported Software Components <coco-supported-software-components>` table for supported Kubernetes versions.

* Helm installed on your cluster.
  Refer to the `Helm documentation <https://helm.sh/docs/intro/install/>`_ for installation instructions.

* Enable the ``KubeletPodResourcesGet`` and ``RuntimeClassInImageCriApi`` Kubelet feature gates on your cluster.

  * ``KubeletPodResourcesGet``: Enabled by default on Kubernetes v1.34 and later.
    On older versions, you must enable it explicitly.
    The Kata runtime uses this feature gate to query the Kubelet Pod Resources API and discover allocated GPU devices during sandbox creation.

  * ``RuntimeClassInImageCriApi``: Alpha since Kubernetes v1.29 and is not enabled by default.
    This feature gate is required to support pod deployments that use multiple snapshotters side-by-side.

  Add both feature gates to your Kubelet configuration (typically ``/var/lib/kubelet/config.yaml``):

  .. code-block:: yaml

     apiVersion: kubelet.config.k8s.io/v1beta1
     kind: KubeletConfiguration
     featureGates:
       KubeletPodResourcesGet: true
       RuntimeClassInImageCriApi: true

  If your ``config.yaml`` already has a ``featureGates`` section, add the gates to the existing section rather than creating a duplicate.

  Restart the Kubelet service to apply the changes:

  .. code-block:: console

     $ sudo systemctl restart kubelet

Next Steps
==========

After completing the prerequisites, proceed to :doc:`Deploy Confidential Containers <confidential-containers-deploy>`.
