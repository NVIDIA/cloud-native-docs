<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Kata Containers Detailed Prerequisites

## Hardware and BIOS

* Ensure hosts are configured to enable hardware virtualization and Access Control Services (ACS).
  With some AMD CPUs and BIOSes, ACS might be grouped under Advanced Error Reporting (AER).
  Enabling these features is typically performed by configuring the host BIOS.

* Configure hosts to support IOMMU.
  You can check if your host is configured for IOMMU by running the following command:

  ```console
  $ ls /sys/kernel/iommu_groups
  ```

  If the output of this command includes 0, 1, and so on, then your host is configured for IOMMU.

  If the host is not configured or if you are unsure, add the `intel_iommu=on` (or `amd_iommu=on` for AMD CPUs) Linux kernel command-line argument.
  For most Linux distributions, add the argument to the `/etc/default/grub` file:

  ```text
  ...
  GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on modprobe.blacklist=nouveau"
  ...
  ```

  On Ubuntu systems, run `sudo update-grub` after making the change to configure the bootloader.
  On other systems, you might need to run `sudo dracut` after making the change.
  Refer to the documentation for your operating system.
  Reboot the host after configuring the bootloader.

  > [!NOTE]
  > After configuring IOMMU, you might see QEMU warnings about PCI P2P DMA when running GPU workloads.
  > These are expected and can be safely ignored.
  > * Ensure that no NVIDIA GPU drivers are installed on the host.
  > Kata Containers uses VFIO to pass GPUs directly to the VM, and host-level GPU drivers interfere with VFIO device binding.

  To check if NVIDIA GPU drivers are installed, run the following command:

  ```console
  $ lsmod | grep nvidia
  ```

  If the output is empty, no NVIDIA GPU drivers are loaded.
  If modules such as `nvidia`, `nvidia_uvm`, or `nvidia_modeset` are listed, NVIDIA GPU drivers are present and must be removed before proceeding.
  Refer to [Removing the Driver](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/removing-the-driver.html) in the NVIDIA Driver Installation Guide.

## Kubernetes Cluster

* A Kubernetes cluster with cluster administrator privileges.

* Helm installed on your cluster.
  Use the command below to install Helm or refer to the [Helm documentation](https://helm.sh/docs/intro/install/) for installation instructions.

  ```console
  $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
        && chmod 700 get_helm.sh \
        && ./get_helm.sh
  ```

* Enable the `KubeletPodResourcesGet` Kubelet feature gate on your cluster.
  The Kata runtime uses this feature gate to query the Kubelet Pod Resources API and discover allocated GPU devices during sandbox creation.

  * For Kubernetes v1.34 and later, the `KubeletPodResourcesGet` feature gate is enabled by default.

  * For Kubernetes versions older than v1.34, you must explicitly enable the `KubeletPodResourcesGet` feature gate.
    Add the feature gate to your Kubelet configuration (typically `/var/lib/kubelet/config.yaml`):

    ```yaml
    apiVersion: kubelet.config.k8s.io/v1beta1
    kind: KubeletConfiguration
    featureGates:
      KubeletPodResourcesGet: true
    ```

    If your `config.yaml` already has a `featureGates` section, add the gate to the existing section rather than creating a duplicate.

    Restart the Kubelet service to apply the changes:

    ```console
    $ sudo systemctl restart kubelet
    ```

  Refer to the [Kata Containers documentation](https://github.com/kata-containers/kata-containers/blob/main/docs/use-cases/NVIDIA-GPU-passthrough-and-Kata-QEMU.md#kata-runtime) for more details on the Kata runtime and VFIO cold-plug.
