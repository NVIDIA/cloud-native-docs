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

######################
Detailed Install Guide
######################

This page lists the steps for a :ref:`Kubernetes Cluster Administrator <coco-persona-kubernetes-cluster-administrator>` to deploy Kata Containers and the NVIDIA GPU Operator to your cluster and configure it for Confidential Containers.
For persona responsibilities and documentation structure, see :doc:`Personas <personas>`.

.. _overview:

****************
Install Overview
****************

This guide assumes you completed :doc:`Prerequisites <prerequisites>` on an existing Kubernetes cluster with GPU worker nodes.

Install workflow:

#. :doc:`Prerequisites <prerequisites>`: prepare worker hosts and cluster software.
#. :ref:`Label nodes to deploy Confidential Containers components <coco-label-nodes>`:select GPU workers for Confidential Containers workloads.
#. :ref:`Install Kata Containers <coco-install-kata-chart>`:install runtime classes and node-level Kata components.
#. :ref:`Install the NVIDIA GPU Operator <coco-install-gpu-operator>`:deploy Confidential Containers operands on target nodes.
#. :doc:`Run a Sample Workload <run-sample-workload>`:confirm the deployment end to end.

**Success criteria:** Helm releases report ``STATUS: deployed``, the ``kata-deploy`` pod is ``Running``, SNP and TDX runtime classes are available, GPU Operator operands are healthy on target nodes, and the sample workload logs include ``Test PASSED``.

When you finish this page, nodes are labeled for Confidential Container component deployment, Kata runtime classes are available, and GPU Operator operands are running on those nodes.
Continue to :doc:`Run a Sample Workload <run-sample-workload>` if you have not run it yet.

.. _installation-and-configuration:

.. _coco-label-nodes:

**************************************************
Label Nodes for Confidential Containers Components
**************************************************

The GPU Operator reads labels to determine what software components to deploy to a node. 
To configure a node for Confidential Container workloads, you label the node with the ``nvidia.com/gpu.workload.config=vm-passthrough`` label.
Then, when the GPU Operator is installed in a subsequent step, it will deploy the software components needed to run Confidential Containers to the node.

A node can only run one container runtime at a time, so a node configured for Confidential Container workloads cannot run traditional GPU container workloads.
The labeling approach is useful if you want to run Confidential Containers workloads on some nodes and traditional GPU container workloads on other nodes in your cluster.

For more details on how the GPU Operator deploys components to your cluster, refer to the :ref:`GPU Operator Cluster Topology Considerations <coco-gpu-operator-cluster-topology>` section in the architecture overview.

.. tip::

   Skip this section if you plan to use all nodes in your cluster to run Confidential Containers and instead set ``sandboxWorkloads.defaultWorkload=vm-passthrough`` when installing the GPU Operator.

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

   .. note::

      If the command prints ``<node-name> not labeled``, the label may already be set.
      Continue to the next step to verify the label was added.

#. Verify the node label was added:

   .. code-block:: console

      $ kubectl describe node $NODE_NAME | grep nvidia.com/gpu.workload.config

   *Example Output:*

   .. code-block:: output

      nvidia.com/gpu.workload.config: vm-passthrough

**Success criteria:** All nodes labeled for Confidential Container workloads are configured to run Confidential Container workloads.
By labeling the nodes in your cluster that you want to run Confidential Container workloads, you are signaling to the GPU Operator to deploy the software components needed to run Confidential Containers to the node and configuring the node to only run a Confidential runtime.

Once all your desired nodes are labeled, you can continue to the next step to install Kata Containers.


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

   *Example Output immediately after running the command:*

   .. code-block:: output

      Pulled: ghcr.io/kata-containers/kata-deploy-charts/kata-deploy:3.29.0
      Digest: sha256:aea41018779716ce2e0bf406d701637d10fb5a0792db51a08dfd3f76701eb933

   The ``--wait`` flag in the install command instructs Helm to wait until the release is deployed before returning.
   It can take a 2-3 minutes to return output.

   .. note::

      There is a `known Helm issue <https://github.com/helm/helm/issues/8660>`_ on single node clusters, that may result in the Helm command finishing before all deployed pods are finished initializing.
      If you are deploying to a single node cluster, you may need to wait for an additional few minutes after the Helm command completes for the ``kata-deploy`` pod to be in the Running state.
 
 
   *Example Output when the release is deployed:*

   .. code-block:: output

      Pulled: ghcr.io/kata-containers/kata-deploy-charts/kata-deploy:3.29.0
      Digest: sha256:aea41018779716ce2e0bf406d701637d10fb5a0792db51a08dfd3f76701eb933
      LAST DEPLOYED: Wed Apr  1 17:03:00 2026
      NAMESPACE: kata-system
      STATUS: deployed
      REVISION: 1
      DESCRIPTION: Install complete
      TEST SUITE: None

   .. note::

      Both ``kata-deploy`` and the GPU Operator deploy Node Feature Discovery (NFD) by default.
      The install command includes ``--set nfd.enabled=false`` to prevent ``kata-deploy`` from deploying NFD.
      The GPU Operator will deploy and manage NFD in the next step.


#. Verify that the ``kata-deploy`` pod is running:

   .. code-block:: console

      $ kubectl get pods -n kata-system | grep kata-deploy

   *Example Output:*

   .. code-block:: output

      kata-deploy-b2lzs       1/1     Running   0             6m37s

#. Verify that the ``kata-qemu-nvidia-gpu-snp`` and ``kata-qemu-nvidia-gpu-tdx`` runtime classes are available:

   After ``helm install`` completes with ``STATUS: deployed``, the ``kata-deploy`` chart has created the Kata ``RuntimeClass`` resources on the cluster.
   This check is the required checkpoint before you continue to :ref:`Install the NVIDIA GPU Operator <coco-install-gpu-operator>`.

   .. code-block:: console

      $ kubectl get runtimeclass | grep kata-qemu-nvidia-gpu

   *Example Output:*

   .. code-block:: output

      NAME                       HANDLER                    AGE
      kata-qemu-nvidia-gpu       kata-qemu-nvidia-gpu       40s
      kata-qemu-nvidia-gpu-snp   kata-qemu-nvidia-gpu-snp   40s
      kata-qemu-nvidia-gpu-tdx   kata-qemu-nvidia-gpu-tdx   40s

   Several runtimes are installed by the ``kata-deploy`` chart.
   The ``kata-qemu-nvidia-gpu`` runtime class is used with Kata 
   Containers, in a non-Confidential Containers scenario.
   The ``kata-qemu-nvidia-gpu-snp`` for AMD-based systems or 
   ``kata-qemu-nvidia-gpu-tdx`` for Intel-based systems runtime 
   classes are used to deploy Confidential Containers workloads.

   If SNP or TDX runtime classes are not listed, the install did not complete correctly.
   On a single-node cluster, retry after a few minutes only if Helm returned before the ``kata-deploy`` pod reaches ``Running`` (see the note above).
   Otherwise, see the log steps below.

**Success criteria:** Helm reports ``STATUS: deployed``, the ``kata-deploy`` pod is ``Running``, and both ``kata-qemu-nvidia-gpu-snp`` and ``kata-qemu-nvidia-gpu-tdx`` are available on the cluster.
Once all checks pass, continue to :ref:`Install the NVIDIA GPU Operator <coco-install-gpu-operator>`.

If you have an issue deploying the ``kata-deploy`` pod or are not seeing the expected runtime classes, use the following steps to view the logs:

#. Get the kata-deploy pod name:

   .. code-block:: console

      $ kubectl get pods -n kata-system | grep kata-deploy

   *Example Output:*

   .. code-block:: output

      NAME                       READY   STATUS    RESTARTS      AGE
      kata-deploy-<pod-name>       1/1     Running   0             6m37s

#. View the logs for the kata-deploy pod:

   .. code-block:: console

      $ kubectl logs -n kata-system kata-deploy-<pod-name>  

   Replace ``<pod-name>`` with the name of the ``kata-deploy`` pod from the first command's output.

   *Example Output:*

   .. code-block:: output

      Install completed
      daemonset mode: waiting for SIGTERM

   If logs show ``CrashLoopBackOff``, repeated errors, or runtime classes are missing after a successful Helm deploy, collect the log output and check for similar reports in the `Kata Containers GitHub repository <https://github.com/kata-containers/kata-containers/issues>`_.
   If no existing issue matches your problem, `open a new issue <https://github.com/kata-containers/kata-containers/issues/new/choose>`_ in that repository with your ``kata-deploy`` logs, chart version (``3.29.0``), and cluster details.

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

   .. tip::

      Add ``--set sandboxWorkloads.defaultWorkload=vm-passthrough`` to configure every worker node for Confidential Containers workloads.
      Refer to the :ref:`Label Nodes for Confidential Containers Components <coco-label-nodes>` section for more details on this use case.

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

   The ``--wait`` flag instructs Helm to wait until the release is deployed before returning.
   It may take 3-5 minutes for the Helm command to complete and for all GPU Operator pods to be in the Running state.

   For additional installation settings,

   * Refer to the :ref:`Common GPU Operator Configuration Settings <coco-configuration-settings>` section on this page for more details on the Confidential Containers-specific configuration options you can specify when installing the GPU Operator. 

   * Refer to the :ref:`Common chart customization options <gpuop:gpu-operator-helm-chart-options>` in :doc:`Installing the NVIDIA GPU Operator <gpuop:getting-started>` for more details on the additional general configuration options you can specify when installing the GPU Operator.

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

**Success criteria:** All GPU Operator pods are ``Running`` or ``Completed``.
Your cluster is now configured to deploy workloads in Kata Containers.
Continue to :doc:`Run a Sample Workload <run-sample-workload>` to confirm everything is working as expected.

If you are not seeing the expected output, view the logs for the GPU Operator pods:

.. code-block:: console

   $ kubectl logs -n gpu-operator <pod-name>

Replace ``<pod-name>`` with the name of the GPU Operator pod from ``kubectl get pods -n gpu-operator``.

.. tip::

   For general GPU Operator issues such as driver or toolkit failures, refer to the :doc:`NVIDIA GPU Operator troubleshooting guide <gpuop:troubleshooting>`.
   For Confidential Containers-specific deploy failures, refer to :doc:`Troubleshooting Deploy Failures <troubleshooting>`.

.. _coco-configuration-settings:

******************************************
Common GPU Operator Configuration Settings
******************************************

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

       Set to ``vm-passthrough`` if you plan to run all or mostly virtual machines in your cluster.
     - ``container``

   * - ``sandboxWorkloads.mode``
     - Specifies the sandbox mode to use when deploying sandbox workloads.
       Accepted values are ``kubevirt`` (default) and ``kata``.
       Set to ``kata`` to run Confidential Containers workloads in Kata Containers.
     - ``kubevirt``

   * - ``kataSandboxDevicePlugin.env``
     - Optional list of environment variables passed to the NVIDIA Kata
       Device Plugin pod. Each list item is an ``EnvVar`` object with required
       ``name`` and optional ``value`` fields.
       Use the setting to configure ``P_GPU_ALIAS`` or ``NVSWITCH_ALIAS`` for the Kata sandbox device plugin.
       Refer to the :ref:`Configuring GPU or NVSwitch Resource Types Name <coco-configuration-heterogeneous-clusters>` section for more details.
     - ``[]`` (empty list)

.. _coco-configuration-heterogeneous-clusters:

***********************************************
Configuring GPU or NVSwitch Resource Types Name
***********************************************

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

You should see the resource type information for the GPUs and NVSwitches on the node.


**********
Next Steps
**********

* :doc:`Run a Sample Workload <run-sample-workload>` to verify your deployment.
* To help manage the lifecycle of Kata Containers, install the `Kata Lifecycle Manager <https://github.com/kata-containers/lifecycle-manager>`_.
  This Argo Workflows-based tool manages Kata Containers upgrades and day-two operations.
