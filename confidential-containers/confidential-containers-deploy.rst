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

##############################
Deploy Confidential Containers
##############################

This page describes deploying Kata Containers and the NVIDIA GPU Operator.
These are key pieces of the NVIDIA Confidential Containers Reference Architecture used to manage GPU resources on your cluster and deploy workloads into Confidential Containers.

Before you begin, refer to the :doc:`Confidential Containers Reference Architecture <overview>` for details on the reference architecture and the :doc:`Supported Platforms <supported-platforms>` page for the supported platforms.

This guide assumes you are familiar with the NVIDIA GPU Operator, Kata Containers, and Kubernetes cluster administration.
Refer to the :doc:`NVIDIA GPU Operator <gpuop:overview>` and `Kata Containers <https://katacontainers.io/docs/>`_ documentation for more information on these software components.
Refer to the `Kubernetes documentation <https://kubernetes.io/docs/home/>`_ for more information on Kubernetes cluster administration.

********
Overview
********

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

.. _installation-and-configuration:

.. _coco-label-nodes:

***********
Label Nodes
***********

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

**************************************
Install the Kata Containers Helm Chart
**************************************

Install Kata Containers using the ``kata-deploy`` Helm chart.
The ``kata-deploy`` chart installs all required components from the Kata Containers project including the Kata Containers runtime binary, runtime configuration, UVM kernel, and images that NVIDIA uses for Confidential Containers and native Kata containers.

The minimum required version is 3.29.0.

#. Set the chart version and registry path:

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
      It can take a 2-3 minutes to return output.

      There is a `known Helm issue <https://github.com/helm/helm/issues/8660>`_ on single node clusters, that may result in the Helm command finishing before all deployed pods are finished initializing.
      If you are deploying to a single node cluster, you may need to wait for an additional few minutes after the Helm command completes for the ``kata-deploy`` pod to be in the Running state.

   .. note::

      Both ``kata-deploy`` and the GPU Operator deploy Node Feature Discovery (NFD) by default.
      The install command includes ``--set nfd.enabled=false`` to prevent ``kata-deploy`` from deploying NFD.
      The GPU Operator will deploy and manage NFD in the next step.


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

#. Optional: If you have an issue deploying the ``kata-deploy`` pod or are not seeing the expected runtime classes, get the pod name and view the logs:

   .. code-block:: console

      $ kubectl get pods -n kata-system | grep kata-deploy
      $ kubectl logs -n kata-system <pod-name>

   Replace ``<pod-name>`` with the name of the ``kata-deploy`` pod from the first command's output.

.. _coco-install-gpu-operator:

*******************************
Install the NVIDIA GPU Operator
*******************************

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

      $ helm install --generate-name \
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
      nvidia-sandbox-validator-6xnzc                                    1/1     Running   0          30s
      nvidia-vfio-manager-h229x                                         1/1     Running   0          62s

   For more details on each of the GPU Operator components, refer to the :ref:`GPU Operator Cluster Topology Considerations <coco-gpu-operator-components>` section in the architecture overview.

   .. note::
      It can take several minutes for all GPU Operator pods to be in the Running state.
      If you are not seeing the expected output, you can view the logs for the GPU Operator pods:
      
      .. code-block:: console

         $ kubectl logs -n gpu-operator <pod-name>

      Replace ``<pod-name>`` with the name of the GPU Operator pod from ``kubectl get pods -n gpu-operator``.

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

Common GPU Operator Configuration Settings
==========================================

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
===============================================

By default, the NVIDIA GPU Operator creates a resource type for GPUs and NVSwitches, ``nvidia.com/pgpu`` and ``nvidia.com/nvswitch``.
You can reference this name in your manifests to request GPU or NVSwitch resources for your workload.
If you want to use a different name, you can set the ``P_GPU_ALIAS`` or ``NVSWITCH_ALIAS`` environment variables in the Kata device plugin to your preferred name.
In clusters where all GPUs are the same model, a single resource type is typically sufficient.

In heterogeneous clusters, where you have different GPU types on your nodes, you might want to use specific GPU types for your workload.
To do this, specify an empty ``P_GPU_ALIAS`` environment variable in the Kata sandbox device plugin by adding the following to your GPU Operator installation:
``--set kataSandboxDevicePlugin.env[0].name=P_GPU_ALIAS`` and
``--set kataSandboxDevicePlugin.env[0].value=""``.

When this variable is set to ``""``, the Kata device plugin creates GPU model-specific resource types, for example ``nvidia.com/GH100_H200_141GB``, instead of the default ``nvidia.com/pgpu`` type.
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

   "nvidia.com/GH100_H200_141GB": "1"

**********
Next Steps
**********

* :doc:`Run a Sample Workload <run-sample-workload>` to verify your deployment.
* :doc:`Configure <configure>` additional options for your environment, including attestation, the confidential computing mode, and :ref:`multi-GPU passthrough <coco-multi-gpu-passthrough>`.
* To help manage the lifecycle of Kata Containers, install the `Kata Lifecycle Manager <https://github.com/kata-containers/lifecycle-manager>`_.
  This Argo Workflows-based tool manages Kata Containers upgrades and day-two operations.
