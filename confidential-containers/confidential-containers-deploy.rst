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

This guide assumes you are familiar with the NVIDIA GPU Operator, and Kata Containers, and Kubernetes cluster administration.
Refer to the :doc:`NVIDIA GPU Operator <gpuop:overview>` and `Kata Containers <https://katacontainers.io/docs/>`_ documentation for more information on these software components.
Refer to the `Kubernetes documentation <https://kubernetes.io/docs/home/>`_ for more information on Kubernetes cluster administration.


Overview
========

The high-level workflow for configuring Confidential Containers is as follows:

#. Configure the :doc:`Prerequisites <prerequisites>`.

#. :ref:`Label Nodes <coco-label-nodes>` that you want to use with Confidential Containers.

#. Install the :ref:`latest Kata Containers Helm chart <coco-install-kata-chart>`.
   This installs the Kata Containers runtime binaries, UVM images and kernels, and TEE-specific shims (such as ``kata-qemu-nvidia-gpu-snp`` or ``kata-qemu-nvidia-gpu-tdx``) onto the cluster's worker nodes.

#. Install the :ref:`NVIDIA GPU Operator configured for Confidential Containers <coco-install-gpu-operator>`.
   This installs the NVIDIA GPU Operator components that are required to deploy GPU passthrough workloads.
   The GPU Operator uses the node labels to determine what software components to deploy to a node.

After installation, you can :doc:`run a sample GPU workload <run-sample-workload>` in a confidential container.
You can also configure :doc:`Attestation <attestation>` with the Trustee framework. 
The Trustee attestation service is typically deployed on a separate, trusted environment.

After configuration, you can schedule workloads that request GPU resources and use the ``kata-qemu-nvidia-gpu-tdx`` or ``kata-qemu-nvidia-gpu-snp`` runtime classes for secure deployment.

.. _coco-label-nodes:

Label Nodes
===========

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
   For more details on GPU Operator cluster topology, refer to the :ref:`GPU Operator Cluster Topology Considerations <coco-gpu-operator-cluster-topology>` section in the architecture overview.

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
======================================

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


.. _coco-install-gpu-operator:

Install the NVIDIA GPU Operator
================================

Install the NVIDIA GPU Operator and configure it to deploy Confidential Container components.

#. Add and update the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
         && helm repo update

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

   Refer to the :ref:`Confidential Containers Configuration Settings <coco-configuration-settings>` section on this page for more details on the Confidential Containers configuration options you can specify when installing the GPU Operator.

   Refer to the :ref:`Common chart customization options <gpuop:gpu-operator-helm-chart-options>` in :doc:`Installing the NVIDIA GPU Operator <gpuop:getting-started>` for more details on the additional general configuration options you can specify when installing the GPU Operator.

#. Optional: Verify that all GPU Operator pods, especially the Confidential Computing Manager, Sandbox Device Plugin and VFIO Manager operands, are running:

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

.. _coco-configuration-settings:

Optional: Confidential Containers Configuration Settings
========================================================

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

   * - ``sandboxDevicePlugin.env``
     - Optional list of environment variables passed to the NVIDIA Sandbox
       Device Plugin pod. Each list item is an ``EnvVar`` object with required
       ``name`` and optional ``value`` fields.
     - ``[]`` (empty list)

.. _coco-configuration-heterogeneous-clusters:

Optional: Configuring the Sandbox Device Plugin to Use GPU or NVSwitch Specific Resource Types
==============================================================================================

By default, the NVIDIA GPU Operator creates a single resource type for GPUs, ``nvidia.com/pgpu``.
In clusters where all GPUs are the same model, a single resource type is sufficient.

In heterogeneous clusters, where you have different GPU types on your nodes, you might want to use specific GPU types for your workload.
To do this, specify an empty ``P_GPU_ALIAS`` environment variable in the sandbox device plugin by adding the following to your GPU Operator installation:
``--set sandboxDevicePlugin.env[0].name=P_GPU_ALIAS`` and
``--set sandboxDevicePlugin.env[0].value=""``.

When this variable is set to ``""``, the sandbox device plugin creates GPU model-specific resource types, for example ``nvidia.com/GH100_H100L_94GB``, instead of the default ``nvidia.com/pgpu`` type.
Use the exposed device resource types in pod specs by specifying respective resource limits.

Similarly, NVSwitches are exposed as resources of type ``nvidia.com/nvswitch`` by default. 
You can include ``--set sandboxDevicePlugin.env[0].name=NVSWITCH_ALIAS`` and
``--set sandboxDevicePlugin.env[0].value=""`` for the device plugin environment variable when installing the GPU Operator to configure advertising behavior similar to ``P_GPU_ALIAS``.

Next Steps
==========

* :doc:`Run a Sample Workload <run-sample-workload>` to verify your deployment.
* To help manage the lifecycle of Kata Containers, install the `Kata Lifecycle Manager <https://github.com/kata-containers/lifecycle-manager>`_.
  This Argo Workflows-based tool manages Kata Containers upgrades and day-two operations.
* Refer to the `NVIDIA Confidential Computing documentation <https://docs.nvidia.com/confidential-computing>`_ for additional information.