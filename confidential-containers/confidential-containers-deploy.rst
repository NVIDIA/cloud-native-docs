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
.. _coco-install-quickstart:

###############################
Install Confidential Containers
###############################

As a :ref:`Kubernetes Cluster Administrator <coco-persona-kubernetes-cluster-administrator>`, install Kata Containers and the NVIDIA GPU Operator to configure Kubernetes worker nodes for Confidential Containers.

The recommended steps configure all GPU worker nodes for Confidential Containers.
Alternatively, you can select individual GPU worker nodes if the cluster must also run traditional GPU container workloads.

*************
Prerequisites
*************

Complete :doc:`Prerequisites <prerequisites>` before you begin.
You need an existing Kubernetes cluster with supported GPU worker nodes, cluster administrator access, and the Helm CLI.

*********
Procedure
*********

#. Label the target nodes.
   Decide whether to configure all GPU worker nodes or only specific nodes to run Confidential Containers.

   .. tab-set::

      .. tab-item:: All GPU worker nodes
         :sync: all-gpu-workers

         NVIDIA recommendeds this option for evaluation, dedicated Confidential Containers clusters, and simplicity.

         This option requires no action.
         You do not label nodes at all.

         The GPU Operator installation in step 4 sets ``vm-passthrough`` as the default workload for every GPU worker node.

      .. tab-item:: Selected GPU worker nodes
         :sync: selected-gpu-workers

         Use this option to run Confidential Containers on some nodes and traditional GPU container workloads on other nodes.
         A node configured for Confidential Containers cannot also run traditional GPU container workloads.

         Get the node names:

         .. code-block:: console

            $ kubectl get nodes

         Label one or more worker nodes to run Confidential Containers:

         .. code-block:: console

            $ kubectl label node <node-01> <node-02> nvidia.com/gpu.workload.config=vm-passthrough

#. Install Kata Containers.

   Set the chart version and registry path:

   .. code-block:: console

      $ export VERSION="${kata_version}"
      $ export CHART="oci://ghcr.io/kata-containers/kata-deploy-charts/kata-deploy"

   Download the sample :download:`kata-nvidia-gpu-values <samples/kata-nvidia-gpu-values.yaml>` file.

   .. dropdown:: View the values file

      .. literalinclude:: ./samples/kata-nvidia-gpu-values.yaml
         :language: yaml

   Install the ``kata-deploy`` Helm chart:

   .. code-block:: console

      $ helm install kata-deploy "${CHART}" \
         --namespace kata-system --create-namespace \
         -f kata-nvidia-gpu-values.yaml \
         --wait --timeout 10m \
         --version "${VERSION}"

   *Example Output:*

   .. code-block:: output

      Pulled: ghcr.io/kata-containers/kata-deploy-charts/kata-deploy:${kata_version}
      Digest: sha256:aea41018779716ce2e0bf406d701637d10fb5a0792db51a08dfd3f76701eb933

   The ``--wait`` argument instructs Helm to wait until the release is deployed before returning.
   It can take a 2-3 minutes to return more output.

   .. code-block:: output

      LAST DEPLOYED: Wed Apr  1 17:03:00 2026
      NAMESPACE: kata-system
      STATUS: deployed
      REVISION: 1
      DESCRIPTION: Install complete
      TEST SUITE: None

   .. note::

      On a single-node cluster, a `known Helm issue <https://github.com/helm/helm/issues/8660>`_ can cause Helm to return before all pods finish initializing.
      Wait a few additional minutes if the ``kata-deploy`` pod is not yet running.

#. Verify that Kata is installed and runtime classes are available.

   Verify that the ``kata-deploy`` pod is running:

   .. code-block:: console

      $ kubectl get pods -n kata-system | grep kata-deploy

   *Example Output:*

   .. code-block:: output

      kata-deploy-b2lzs       1/1     Running   0             6m37s

   Verify that the NVIDIA GPU, SNP, and TDX runtime classes are available:

   .. code-block:: console

      $ kubectl get runtimeclass | grep kata-qemu-nvidia-gpu

   *Example Output:*

   .. code-block:: output

      NAME                       HANDLER                    AGE
      kata-qemu-nvidia-gpu       kata-qemu-nvidia-gpu       40s
      kata-qemu-nvidia-gpu-snp   kata-qemu-nvidia-gpu-snp   40s
      kata-qemu-nvidia-gpu-tdx   kata-qemu-nvidia-gpu-tdx   40s

   Runtime classes typically appear within 1 to 2 minutes after the ``kata-deploy`` pod reaches ``Running``.
   If the pod does not reach ``Running`` or the runtime classes remain unavailable, refer to :ref:`View Kata Containers Logs <coco-view-kata-logs>`.

#. Install the NVIDIA GPU Operator.

   Add and update the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
         && helm repo update

   Select the same node configuration option that you selected in step 1:

   .. tab-set::

      .. tab-item:: All GPU worker nodes
         :sync: all-gpu-workers

         Install the GPU Operator and set ``vm-passthrough`` as the default workload for all GPU worker nodes:

         .. code-block:: console

            $ helm install --wait --timeout 10m --generate-name \
               -n gpu-operator --create-namespace \
               nvidia/gpu-operator \
               --set sandboxWorkloads.enabled=true \
               --set sandboxWorkloads.defaultWorkload=vm-passthrough \
               --set sandboxWorkloads.mode=kata \
               --set nfd.enabled=true \
               --set nfd.nodefeaturerules=true \
               --version="${gpu_operator_version}"

      .. tab-item:: Selected GPU worker nodes
         :sync: selected-gpu-workers

         Install the GPU Operator without changing the default workload for unlabeled nodes:

         .. code-block:: console

            $ helm install --wait --timeout 10m --generate-name \
               -n gpu-operator --create-namespace \
               nvidia/gpu-operator \
               --set sandboxWorkloads.enabled=true \
               --set sandboxWorkloads.mode=kata \
               --set nfd.enabled=true \
               --set nfd.nodefeaturerules=true \
               --version="${gpu_operator_version}"

   *Example Output:*

   .. code-block:: output

      NAME: gpu-operator
      LAST DEPLOYED: Tue Mar 10 17:58:12 2026
      NAMESPACE: gpu-operator
      STATUS: deployed
      REVISION: 1
      TEST SUITE: None

   It can take 3 to 5 minutes for the Helm command to complete.

#. Verify the GPU Operator pods:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator

   Every pod must report ``Running`` or ``Completed``.
   On target nodes, verify that the output includes these Confidential Containers operands:

   * ``nvidia-cc-manager``
   * ``nvidia-kata-sandbox-device-plugin-daemonset``
   * ``nvidia-sandbox-validator``
   * ``nvidia-vfio-manager``

   Pods can briefly report ``Pending`` or ``Init`` while they start.
   If they do not become healthy, refer to :doc:`Troubleshooting <troubleshooting>`.

   .. dropdown:: Optional: Verify VFIO binding on a worker host

      If you have access to a target worker host, confirm that its GPUs use the ``vfio-pci`` driver:

      .. code-block:: console

         $ lspci -nnk -d 10de:

      *Example Output:*

      .. code-block:: output

         65:00.0 3D controller [0302]: NVIDIA Corporation xxxxxxx [xxx] [10de:xxxx] (rev xx)
                  Subsystem: NVIDIA Corporation xxxxxxx [xxx] [10de:xxxx]
                  Kernel driver in use: vfio-pci
                  Kernel modules: nvidiafb, nouveau

      ``Kernel driver in use: vfio-pci`` confirms that the GPU is ready for passthrough into a confidential virtual machine.
      If the driver is ``nvidia`` or ``nouveau``, confirm that the node meets :doc:`Prerequisites <prerequisites>`.

   **Success criteria:** Both Helm releases report ``STATUS: deployed``, the Kata pod and GPU Operator pods are healthy, and the SNP and TDX runtime classes are available.

The cluster is now ready to run Confidential Containers on the target GPU worker nodes.

**********************
Advanced Configuration
**********************

The preceding procedure uses the recommended settings for Confidential Containers.
For general GPU Operator chart options, refer to :ref:`Common chart customization options <gpuop:gpu-operator-helm-chart-options>` in :doc:`Installing the NVIDIA GPU Operator <gpuop:getting-started>`.

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

To configure both ``P_GPU_ALIAS`` and ``NVSWITCH_ALIAS``, add the following arguments to the GPU Operator command in step 4:

.. code-block:: console

   --set kataSandboxDevicePlugin.env[0].name=P_GPU_ALIAS \
   --set kataSandboxDevicePlugin.env[0].value="" \
   --set kataSandboxDevicePlugin.env[1].name=NVSWITCH_ALIAS \
   --set kataSandboxDevicePlugin.env[1].value=""

After installing the GPU Operator, you can view the GPU or NVSwitch resource types available on a node by running the following command:

.. code-block:: console

   $ kubectl get node <node-name> -o json | grep nvidia.com

*Example Output:*

.. code-block:: output

   "nvidia.com/GH100_H200_141GB": "1"

You should see the resource type information for the GPUs and NVSwitches on the node.


**********
Next Steps
**********

.. note::

   You now have a working Confidential Containers runtime.

   Attestation is what cryptographically verifies the TEE and releases secrets to a
   production workload. For attestation concepts and a local
   connectivity test, see the :doc:`Attestation <attestation>` quickstart. For production attestation
   deployment, refer to the upstream `Confidential Containers NVIDIA attestation guide
   <https://confidentialcontainers.org/docs/examples/nvidia-nim-confidential-gpu-attestation/>`__.

* :doc:`Run a Sample Workload <run-sample-workload>` to verify your deployment.
* To help manage the lifecycle of Kata Containers, install the `Kata Lifecycle Manager <https://github.com/kata-containers/lifecycle-manager>`_.
  This Argo Workflows-based tool manages Kata Containers upgrades and day-two operations.
