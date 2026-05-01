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


.. _confidential-containers-deploy:

******************************
Deploy Confidential Containers
******************************

This page describes deploying Kata Containers and the NVIDIA GPU Operator.
These are key pieces of the NVIDIA Confidential Containers Reference Architecture used to manage GPU resources on your cluster and deploy workloads into Confidential Containers.

Before you begin, refer to the :doc:`Confidential Containers Reference Architecture <overview>` for details on the reference architecture and the :doc:`Supported Platforms <supported-platforms>` page for the supported platforms.

This guide assumes you are familiar with the NVIDIA GPU Operator, Kata Containers, and Kubernetes cluster administration.
Refer to the :doc:`NVIDIA GPU Operator <gpuop:overview>` and `Kata Containers <https://katacontainers.io/docs/>`_ documentation for more information on these software components.
Refer to the `Kubernetes documentation <https://kubernetes.io/docs/home/>`_ for more information on Kubernetes cluster administration.


Overview
========

The high-level workflow for configuring Confidential Containers is as follows:

#. Configure the :ref:`Prerequisites <coco-prerequisites>`.

#. :ref:`Label Nodes <coco-label-nodes>` that you want to use with Confidential Containers.

#. Install the :ref:`latest Kata Containers Helm chart <coco-install-kata-chart>`.
   This installs the Kata Containers runtime binaries, UVM images and kernels, and TEE-specific shims (such as ``kata-qemu-nvidia-gpu-snp`` or ``kata-qemu-nvidia-gpu-tdx``) onto the cluster's worker nodes.

#. Install the :ref:`NVIDIA GPU Operator configured for Confidential Containers <coco-install-gpu-operator>`.
   This installs the NVIDIA GPU Operator components that are required to deploy GPU passthrough workloads.
   The GPU Operator uses the node labels to determine what software components to deploy to a node.

After installation, you can :ref:`run a sample GPU workload <coco-run-sample-workload>` in a confidential container.
You can also configure :doc:`Attestation <attestation>` with the Trustee framework.
The Trustee attestation service is typically deployed on a separate, trusted environment.

After configuration, you can schedule workloads that request GPU resources and use the ``kata-qemu-nvidia-gpu-tdx`` or ``kata-qemu-nvidia-gpu-snp`` runtime classes for secure deployment.

.. _coco-prerequisites:

Prerequisites
=============

Hardware and BIOS
-----------------

* Use a supported platform configured for Confidential Computing.
  For more information on machine setup, refer to :doc:`Supported Platforms <supported-platforms>`.

* Ensure hosts are configured to enable hardware virtualization and Access Control Services (ACS). With some AMD CPUs and BIOSes, ACS might be grouped under Advanced Error Reporting (AER). Enable these features in the host BIOS.

* Configure hosts to support IOMMU.
  You can check if your host is configured for IOMMU by running the following command:

  .. code-block:: console

     $ ls /sys/kernel/iommu_groups

  If the output of this command includes 0, 1, and so on, then your host is configured for IOMMU.

  If the host is not configured or if you are unsure, add the ``amd_iommu=on`` Linux kernel command-line argument for AMD CPUs, or ``intel_iommu=on`` for Intel CPUs. For most Linux distributions, add the argument to the ``/etc/default/grub`` file, for instance:

  .. code-block:: console

      ...
      GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on modprobe.blacklist=nouveau"
      ...

  After making the change, configure the bootloader.

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
------------------

* A Kubernetes cluster with cluster administrator privileges.
  Refer to the :ref:`Supported Software Components <coco-supported-software-components>` table for supported Kubernetes versions.

* Helm installed on your cluster.
  Use the command below to install Helm or refer to the `Helm documentation <https://helm.sh/docs/intro/install/>`_ for installation instructions.

  .. code-block:: console

      $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
            && chmod 700 get_helm.sh \
            && ./get_helm.sh


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

.. _installation-and-configuration:

Installation
============

.. _coco-label-nodes:

Label Nodes
-----------

#. Get a list of the nodes in your cluster:

   .. code-block:: console

      $ kubectl get nodes

   *Example Output:*

   .. code-block:: output

      NAME          STATUS   ROLES           AGE   VERSION
      node-01       Ready    <none>          10d   v1.34.0
      node-02       Ready    <none>          10d   v1.34.0

#. Set the ``NODE_NAME`` environment variable to the name of the node you want to configure:

   .. code-block:: console

      $ export NODE_NAME="<node-name>"

   .. note::

      Commands in this guide use the ``$NODE_NAME`` environment variable to reference this node.

#. Label the node for Confidential Containers:

   .. code-block:: console

      $ kubectl label node $NODE_NAME nvidia.com/gpu.workload.config=vm-passthrough

   The GPU Operator uses this label to determine what software components to deploy to a node.
   The ``nvidia.com/gpu.workload.config=vm-passthrough`` label specifies that the node should receive the software components to run Confidential Containers.

   A node can only run one container runtime at a time, so a labeled node runs only Confidential Container workloads and cannot run traditional GPU container workloads.
   The labeling approach is useful if you want to run Confidential Containers workloads on some nodes and traditional GPU container workloads on other nodes in your cluster.
   For more details on how the GPU Operator deploys components to your cluster, refer to the :ref:`GPU Operator Cluster Topology Considerations <coco-gpu-operator-cluster-topology>` section in the architecture overview.

   .. tip::

      Skip this section if you plan to use all nodes in your cluster to run Confidential Containers and instead set ``sandboxWorkloads.defaultWorkload=vm-passthrough`` when installing the GPU Operator.

#. Verify the node label was added:

   .. code-block:: console

      $ kubectl describe node $NODE_NAME | grep nvidia.com/gpu.workload.config

   *Example Output:*

   .. code-block:: output

      nvidia.com/gpu.workload.config: vm-passthrough

After labeling the node, you can continue to the next steps to install Kata Containers and the NVIDIA GPU Operator.

.. _coco-install-kata-chart:

Install the Kata Containers Helm Chart
--------------------------------------

Install Kata Containers using the ``kata-deploy`` Helm chart.
The ``kata-deploy`` chart installs all required components from the Kata Containers project including the Kata Containers runtime binary, runtime configuration, UVM kernel, and images that NVIDIA uses for Confidential Containers and native Kata containers.

The minimum required version is 3.29.0.

#. Get the latest version of the ``kata-deploy`` Helm chart:

   .. code-block:: console

      $ export VERSION="3.29.0"
      $ export CHART="oci://ghcr.io/kata-containers/kata-deploy-charts/kata-deploy"


#. Install the kata-deploy Helm chart:

   .. code-block:: console

      $ helm install kata-deploy "${CHART}" \
         --namespace kata-system --create-namespace \
         --set nfd.enabled=false \
         --wait --timeout 10m \
         --version "${VERSION}"

   *Example Output:*

   .. code-block:: output

      LAST DEPLOYED: Wed Apr  1 17:03:00 2026
      NAMESPACE: kata-system
      STATUS: deployed
      REVISION: 1
      DESCRIPTION: Install complete
      TEST SUITE: None

   .. note::

      The ``--wait`` flag in the install command instructs Helm to wait until the release is deployed before returning.
      It can take a few minutes to return output.

      There is a `known Helm issue <https://github.com/helm/helm/issues/8660>`_ on single node clusters, that may result in the Helm command finishing before all deployed pods are finished initializing.
      If you are deploying to a single node cluster, you may need to wait for an additional few minutes after the Helm command completes for the ``kata-deploy`` pod to be in the Running state.

   .. note::

      Node Feature Discovery (NFD) is deployed by both kata-deploy and the GPU Operator. Pass ``--set nfd.enabled=false`` to disable NFD in kata-deploy so that the GPU Operator manages NFD in the next step.


#. Optional: Verify that the ``kata-deploy`` pod is running:

   .. code-block:: console

      $ kubectl get pods -n kata-system | grep kata-deploy

   *Example Output:*

   .. code-block:: output

      NAME                    READY   STATUS    RESTARTS      AGE
      kata-deploy-b2lzs       1/1     Running   0             6m37s

#. Optional: Verify that the ``kata-qemu-nvidia-gpu``, ``kata-qemu-nvidia-gpu-snp``, and ``kata-qemu-nvidia-gpu-tdx`` runtime classes are available:

   .. code-block:: console

      $ kubectl get runtimeclass | grep kata-qemu-nvidia-gpu

   *Example Output:*

   .. code-block:: output

      NAME                       HANDLER                    AGE
      kata-qemu-nvidia-gpu       kata-qemu-nvidia-gpu       40s
      kata-qemu-nvidia-gpu-snp   kata-qemu-nvidia-gpu-snp   40s
      kata-qemu-nvidia-gpu-tdx   kata-qemu-nvidia-gpu-tdx   40s

   Several runtimes are installed by the ``kata-deploy`` chart.
   The ``kata-qemu-nvidia-gpu`` runtime class is used with Kata Containers, in a non-Confidential Containers scenario.
   The ``kata-qemu-nvidia-gpu-snp`` and ``kata-qemu-nvidia-gpu-tdx`` runtime classes are used to deploy Confidential Containers workloads.

   .. tip::

      If you have an issue deploying the ``kata-deploy`` pod, you can view the logs with the following command.
      Update the <pod-name> placeholder with the name of the ``kata-deploy`` pod.

      .. code-block:: console

         $ kubectl -n kata-system logs kata-deploy-<pod-name>


      This should return logs for your ``kata-deploy`` pod.


.. _coco-install-gpu-operator:

Install the NVIDIA GPU Operator
--------------------------------

Install the NVIDIA GPU Operator and configure it to deploy Confidential Container components.

#. Add and update the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
         && helm repo update

   *Example Output:*

   .. code-block:: output

      "nvidia" has been added to your repositories
      Hang tight while we grab the latest from your chart repositories...
      ...Successfully got an update from the "nvidia" chart repository
      Update Complete. ⎈Happy Helming!⎈

#. Install the GPU Operator with the following configuration:

   .. code-block:: console

      $ helm install --wait --timeout 10m --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --set sandboxWorkloads.enabled=true \
         --set sandboxWorkloads.mode=kata \
         --set nfd.enabled=true \
         --set nfd.nodefeaturerules=true \
         --version=v26.3.1

   *Example Output:*

   .. code-block:: output

      NAME: gpu-operator
      LAST DEPLOYED: Tue Mar 10 17:58:12 2026
      NAMESPACE: gpu-operator
      STATUS: deployed
      REVISION: 1
      TEST SUITE: None

   .. tip::

      Add ``--set sandboxWorkloads.defaultWorkload=vm-passthrough`` if every worker node should deploy Confidential Containers by default.

   .. note::
      The ``--wait`` flag in the install command instructs Helm to wait until the release is deployed before returning.
      It can take a few minutes to return output.

   Refer to the :ref:`Common GPU Operator Configuration Settings <coco-configuration-settings>` section on this page for more details on the configuration options you can specify when installing the GPU Operator.

   Refer to the :ref:`Common chart customization options <gpuop:gpu-operator-helm-chart-options>` in :doc:`Installing the NVIDIA GPU Operator <gpuop:getting-started>` for more details on the additional general configuration options you can specify when installing the GPU Operator.

#. Optional: Verify that all GPU Operator pods, especially the Confidential Computing Manager, Kata Device Plugin and VFIO Manager operands, are running:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator

   *Example Output:*

   .. code-block:: output

      NAME                                                              READY   STATUS    RESTARTS   AGE
      gpu-operator-1766001809-node-feature-discovery-gc-75776475sxzkp   1/1     Running   0          86s
      gpu-operator-1766001809-node-feature-discovery-master-6869lxq2g   1/1     Running   0          86s
      gpu-operator-1766001809-node-feature-discovery-worker-mh4cv       1/1     Running   0          86s
      gpu-operator-f48fd66b-vtfrl                                       1/1     Running   0          86s
      nvidia-cc-manager-7z74t                                           1/1     Running   0          61s
      nvidia-kata-sandbox-device-plugin-daemonset-d5rvg                 1/1     Running   0          30s
      nvidia-sandbox-validator-6xnzc                                    1/1     Running   1          30s
      nvidia-vfio-manager-h229x                                         1/1     Running   0          62s


#. Optional: If you have host access to the worker node, you can perform the following validation step:

   a. Confirm that the host uses the vfio-pci device driver for GPUs:

      .. code-block:: console

         $ lspci -nnk -d 10de:

      *Example Output:*

      .. code-block:: output

         65:00.0 3D controller [0302]: NVIDIA Corporation xxxxxxx [xxx] [10de:xxxx] (rev xx)
                 Subsystem: NVIDIA Corporation xxxxxxx [xxx] [10de:xxxx]
                 Kernel driver in use: vfio-pci
                 Kernel modules: nvidiafb, nouveau

   .. tip::

      If you have an issue deploying the GPU Operator, refer to the :doc:`NVIDIA GPU Operator troubleshooting guide <gpuop:troubleshooting>` for guidance on troubleshooting and resolving issues.

With Kata Containers and the GPU Operator installed, you can start using your cluster to run Confidential Containers workloads.
To run a sample workload, refer to the :ref:`Run a Sample Workload <coco-run-sample-workload>` section.

For further configuration settings, refer to the following sections:

* :ref:`Managing the Confidential Computing Mode <managing-confidential-computing-mode>`
* :ref:`Configuring Workloads to use Multi-GPU Passthrough <coco-configuration-multi-gpu-passthrough>`
* :ref:`Configuring GPU or NVSwitch Resource Types Name <coco-configuration-heterogeneous-clusters>`

.. _coco-run-sample-workload:

Run a Sample Workload
=====================

A pod manifest for a confidential container GPU workload requires that you specify the ``kata-qemu-nvidia-gpu-snp`` runtime class for SEV-SNP or ``kata-qemu-nvidia-gpu-tdx`` for TDX.

1. Create a file, such as the following ``cuda-vectoradd-kata.yaml`` sample, specifying the kata-qemu-nvidia-gpu-snp runtime class:

   .. code-block:: yaml
      :emphasize-lines: 7,14

      apiVersion: v1
      kind: Pod
      metadata:
        name: cuda-vectoradd-kata
        namespace: default
      spec:
        runtimeClassName: kata-qemu-nvidia-gpu-snp
        restartPolicy: Never
        containers:
          - name: cuda-vectoradd
            image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0-ubuntu22.04"
            resources:
              limits:
                nvidia.com/pgpu: "1"
                memory: 16Gi

   The following are Confidential Containers configurations in the sample manifest:

   * Set the runtime class to ``kata-qemu-nvidia-gpu-snp`` for SEV-SNP or ``kata-qemu-nvidia-gpu-tdx`` for TDX, depending on the node type where the workloads should run.

   * In the sample above, ``nvidia.com/pgpu`` is the default resource type for GPUs.
     If you are deploying on a heterogeneous cluster, you might want to update the default behavior by specifying the ``P_GPU_ALIAS`` environment variable for the Kata device plugin.
     Refer to the :ref:`Configuring GPU or NVSwitch Resource Types Name <coco-configuration-heterogeneous-clusters>` section on this page for more details.

   * If you have machines that support multi-GPU passthrough, use a pod deployment manifest that specifies 8 PGPU and 4 NVSwitch resources.

   .. code-block:: yaml

      limits:
         nvidia.com/pgpu: "8"
         nvidia.com/nvswitch: "4"

   .. note::
      If you are using NVIDIA Hopper GPUs for multi-GPU passthrough, also refer to :ref:`Managing the Confidential Computing Mode <managing-confidential-computing-mode>` for details on how to set the ``ppcie`` mode.


2. Create the pod:

   .. code-block:: console

      $ kubectl apply -f cuda-vectoradd-kata.yaml

   *Example Output:*

   .. code-block:: output

      pod/cuda-vectoradd-kata created


3. Verify the pod is running:

   .. code-block:: console

      $ kubectl get pod cuda-vectoradd-kata

   *Example Output:*

   .. code-block:: output

      NAME                  READY   STATUS    RESTARTS   AGE
      cuda-vectoradd-kata   1/1     Running   0          10s

4. View the logs from the pod after the container starts:

   .. code-block:: console

      $ kubectl logs -n default cuda-vectoradd-kata

   *Example Output:*

   .. code-block:: output

      [Vector addition of 50000 elements]
      Copy input data from the host memory to the CUDA device
      CUDA kernel launch with 196 blocks of 256 threads
      Copy output data from the CUDA device to the host memory
      Test PASSED
      Done

5. Delete the pod:

   .. code-block:: console

      $ kubectl delete -f cuda-vectoradd-kata.yaml


.. _coco-configuration-settings:

Common GPU Operator Configuration Settings
===========================================

The following are the available GPU Operator configuration settings to enable Confidential Containers:

.. list-table::
   :widths: 20 50 30
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``sandboxWorkloads.enabled``
     - Enables sandbox workload management in the GPU Operator for virtual
       machine-style workloads and related operands.
     - ``false``

   * - ``sandboxWorkloads.defaultWorkload``
     - Specifies the default type of workload for the cluster, one of ``container``, ``vm-passthrough``, or ``vm-vgpu``.

       Setting ``vm-passthrough`` or ``vm-vgpu`` can be helpful if you plan to run all or mostly virtual machines in your cluster.
     - ``container``

   * - ``sandboxWorkloads.mode``
     - Specifies the sandbox mode to use when deploying sandbox workloads.
       Accepted values are ``kubevirt`` (default) and ``kata``.
     - ``kubevirt``

   * - ``kataSandboxDevicePlugin.env``
     - Optional list of environment variables passed to the NVIDIA Kata
       Device Plugin pod. Each list item is an ``EnvVar`` object with required
       ``name`` and optional ``value`` fields.
       Use the setting to configure ``P_GPU_ALIAS`` or ``NVSWITCH_ALIAS`` for the Kata sandbox device plugin.
       Refer to the :ref:`Configuring GPU or NVSwitch Resource Types Name <coco-configuration-heterogeneous-clusters>` section for more details.
     - ``[]`` (empty list)

.. _coco-configuration-heterogeneous-clusters:

Configuring GPU or NVSwitch Resource Types Name
------------------------------------------------

By default, the NVIDIA GPU Operator creates a resource type for GPUs and NVSwitches, ``nvidia.com/pgpu`` and ``nvidia.com/nvswitch``.
You can reference this name in your manifests to request GPU or NVSwitch resources for your workload.
If you want to use a different name, you can set the ``P_GPU_ALIAS`` or ``NVSWITCH_ALIAS`` environment variables in the Kata device plugin to your preferred name.
In clusters where all GPUs are the same model, a single resource type is typically sufficient.

In heterogeneous clusters, where you have different GPU types on your nodes, you might want to use specific GPU types for your workload.
To do this, specify an empty ``P_GPU_ALIAS`` environment variable in the Kata sandbox device plugin by adding the following to your GPU Operator installation:
``--set kataSandboxDevicePlugin.env[0].name=P_GPU_ALIAS`` and
``--set kataSandboxDevicePlugin.env[0].value=""``.

When this variable is set to ``""``, the Kata device plugin creates GPU model-specific resource types, for example ``nvidia.com/GH100_H100L_94GB``, instead of the default ``nvidia.com/pgpu`` type.
Use the exposed device resource types in pod specs by specifying respective resource limits.

Similarly, you can set ``NVSWITCH_ALIAS`` to ``""`` to advertise model-specific NVSwitch resource types.

The following example installs the GPU Operator with both ``P_GPU_ALIAS`` and ``NVSWITCH_ALIAS`` configured:

.. code-block:: console

   $ helm install --wait --timeout 10m --generate-name \
      -n gpu-operator --create-namespace \
      nvidia/gpu-operator \
      --set sandboxWorkloads.enabled=true \
      --set sandboxWorkloads.mode=kata \
      --set nfd.enabled=true \
      --set nfd.nodefeaturerules=true \
      --set kataSandboxDevicePlugin.env[0].name=P_GPU_ALIAS \
      --set kataSandboxDevicePlugin.env[0].value="" \
      --set kataSandboxDevicePlugin.env[1].name=NVSWITCH_ALIAS \
      --set kataSandboxDevicePlugin.env[1].value="" \
      --version=v26.3.1

After installing the GPU Operator, you can view the GPU or NVSwitch resource types available on a node by running the following command:

.. code-block:: console

   $ kubectl get node $NODE_NAME -o json | grep nvidia.com

.. note::
   The ``NODE_NAME`` environment variable was set in the :ref:`Label Nodes <coco-label-nodes>` section.
   If you want to view the resource types for a different node, you can update the ``NODE_NAME`` environment variable and run the command again.

*Example Output:*

.. code-block:: output

   "nvidia.com/GH100_H100L_94GB": "1"



.. _managing-confidential-computing-mode:

Managing the Confidential Computing Mode
=========================================

You can set the default confidential computing mode of the NVIDIA GPUs by setting the ``ccManager.defaultMode=<on|off>`` option.
The default value of ``ccManager.defaultMode`` is ``on``.
You can set this option when you install NVIDIA GPU Operator or afterward by modifying the cluster-policy instance of the ClusterPolicy object.

When you change the mode, the manager performs the following actions:

* Evicts the other GPU Operator operands from the node.

  However, the manager does not drain user workloads. You must make sure that no user workloads are running on the node before you change the mode.

* Unbinds the GPU from the VFIO PCI device driver.
* Changes the mode and resets the GPU.
* Reschedules the other GPU Operator operands.

The supported modes are:

.. list-table::
   :widths: 15 55 30
   :header-rows: 1

   * - Mode
     - Description
     - Configuration Method
   * - ``on``
     - Enable Confidential Computing.
     - cluster-wide default, node-level override
   * - ``off``
     - Disable Confidential Computing.
     - cluster-wide default, node-level override
   * - ``ppcie``
     - Enable Confidential Computing on NVIDIA Hopper GPUs.

       On the NVIDIA Hopper architecture multi-GPU passthrough uses protected PCIe (PPCIE)
       which claims exclusive use of the NVSwitches for a single Confidential Container
       virtual machine.
       If you are using NVIDIA Hopper GPUs for multi-GPU passthrough,
       set the GPU mode to ``ppcie`` mode.

       The NVIDIA Blackwell architecture uses NVLink
       encryption which places the switches outside of the Trusted Computing Base (TCB),
       meaning the ``ppcie`` mode is not required. Use ``on`` mode in this case.
     - node-level override

You can set a cluster-wide default mode, and you can set the mode on individual nodes.
The mode that you set on a node has higher precedence than the cluster-wide default mode.

Setting a Cluster-Wide Default Mode
------------------------------------

To set a cluster-wide mode, specify the ``ccManager.defaultMode`` field like the following example:

.. code-block:: console

   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
         --type=merge \
         -p '{"spec": {"ccManager": {"defaultMode": "on"}}}'

*Example Output:*

.. code-block:: output

   clusterpolicy.nvidia.com/cluster-policy patched

.. note::

   The ``ppcie`` mode cannot be set as a cluster-wide default, it can only be set as a node label value.

Setting a Node-Level Mode
--------------------------

To set a node-level mode, apply the ``nvidia.com/cc.mode=<on|off|ppcie>`` label on the node.

.. note::

   The ``NODE_NAME`` environment variable was set in the :ref:`Label Nodes <coco-label-nodes>` section.
   If you want to set the mode for a different node, you can update the ``NODE_NAME`` environment variable and run the command again.

.. code-block:: console

   $ kubectl label node $NODE_NAME nvidia.com/cc.mode=on --overwrite

The mode that you set on a node has higher precedence than the cluster-wide default mode.

Verifying a Mode Change
------------------------

To verify that a mode change was successful, view the ``nvidia.com/cc.mode``,
``nvidia.com/cc.mode.state``, and ``nvidia.com/cc.ready.state`` node labels:

.. code-block:: console

   $ kubectl get node $NODE_NAME -o json | \
       jq '.metadata.labels | with_entries(select(.key | startswith("nvidia.com/cc")))'

*Example Output (CC mode disabled):*

.. code-block:: json

   {
     "nvidia.com/cc.mode": "off",
     "nvidia.com/cc.mode.state": "off",
     "nvidia.com/cc.ready.state": "false"
   }

*Example Output (CC mode enabled):*

.. code-block:: json

   {
     "nvidia.com/cc.mode": "on",
     "nvidia.com/cc.mode.state": "on",
     "nvidia.com/cc.ready.state": "true"
   }

* The ``nvidia.com/cc.mode`` label is the desired state.

* The ``nvidia.com/cc.mode.state`` label reflects the mode that was last successfully applied to the GPU hardware by the Confidential Computing Manager.
  Its value mirrors the applied mode ``on``, ``off``, or ``ppcie``, after the transition is complete on the node.
  A value of ``failed`` indicates that the last mode transition encountered an error.

* The ``nvidia.com/cc.ready.state`` label indicates whether the node is ready to run Confidential Container workloads.
  It is set to ``true`` when ``cc.mode.state`` is ``on`` or ``ppcie``, and ``false`` when ``cc.mode.state`` is ``off``.

.. note::

   It can take one to two minutes for GPU state transitions to complete and the labels to be updated.
   A mode change is complete and successful when ``nvidia.com/cc.mode`` and
   ``nvidia.com/cc.mode.state`` have the same value.


.. _coco-configuration-multi-gpu-passthrough:

Configuring Workloads to use Multi-GPU Passthrough
===================================================

To configure multi-GPU passthrough, you can specify the following resource limits in your manifests:

.. code-block:: yaml

   limits:
      nvidia.com/pgpu: "8"
      nvidia.com/nvswitch: "4"


You must assign all the GPUs and NVSwitches on the node in your manifest to the same Confidential Container virtual machine.

On the NVIDIA Hopper architecture, multi-GPU passthrough uses protected PCIe (PPCIE), which claims exclusive use of the NVSwitches for a single Confidential Container.
When using NVIDIA Hopper nodes for multi-GPU passthrough, transition your node's GPU Confidential Computing mode to ``ppcie`` by applying the ``nvidia.com/cc.mode=ppcie`` label.
Refer to the :ref:`Managing the Confidential Computing Mode <managing-confidential-computing-mode>` section for details.

The NVIDIA Blackwell architecture uses NVLink encryption which places the switches outside of the Trusted Computing Base (TCB) and only requires the GPU Confidential Computing mode to be set to ``on``.


.. _configure-image-pull-timeouts:

Configure Image Pull Timeouts
=============================

The guest-pull mechanism pulls images inside the confidential VM, which means large images can take longer to download and delay container start.
Kubelet can de-allocate your pod if the image pull exceeds the configured timeout before the container transitions to the running state.

If you plan to use large images, increase ``runtimeRequestTimeout`` in your `kubelet configuration <https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/>`_ to ``20m`` to match the default values for the NVIDIA shim configurations in Kata Containers.

Add or update the ``runtimeRequestTimeout`` field in your kubelet configuration (typically ``/var/lib/kubelet/config.yaml``):

.. code-block:: yaml
   :emphasize-lines: 3

   apiVersion: kubelet.config.k8s.io/v1beta1
   kind: KubeletConfiguration
   runtimeRequestTimeout: 20m

Restart the kubelet service to apply the change:

.. code-block:: console

   $ sudo systemctl restart kubelet

Additional timeouts to consider updating are the NVIDIA Shim and Kata Agent Policy timeouts.
The NVIDIA shim configurations in Kata Containers use a default ``create_container_timeout`` of 1200 seconds (20 minutes).
This controls the time the shim allows for a container to remain in container creating state.

If you need a timeout of more than 1200 seconds, you will also need to adjust Kata Agent Policy's ``image_pull_timeout`` value which controls the agent-side timeout for guest-image pull.
To do this, add the ``agent.image_pull_timeout`` kernel parameter to your shim configuration, or pass an explicit value in a pod annotation in the ``io.katacontainers.config.hypervisor.kernel_params: "..."`` annotation.


Next Steps
==========

* Refer to the :doc:`Attestation <attestation>` page for more information on configuring attestation.
* To help manage the lifecycle of Kata Containers, install the `Kata Lifecycle Manager <https://github.com/kata-containers/lifecycle-manager>`_.
  This Argo Workflows-based tool manages Kata Containers upgrades and day-two operations.
* Refer to the `NVIDIA Confidential Computing documentation <https://docs.nvidia.com/confidential-computing>`_ for additional information.
* Licensing information is available on the :doc:`Licensing <licensing>` page.