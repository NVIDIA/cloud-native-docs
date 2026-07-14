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


.. _coco-install-quickstart:

##################
Quickstart Install
##################

As a :ref:`Kubernetes Cluster Administrator <coco-persona-kubernetes-cluster-administrator>`, use these steps to install Kata Containers and the NVIDIA GPU Operator with minimal steps.
For additional configuration options and install details, refer to the :doc:`Detailed Install Guide <confidential-containers-deploy>`.

This quickstart will configure every node in your cluster for Confidential Containers workloads.
This is ideal for evaluation or dedicated Confidential Containers clusters.
If you need to run Confidential Containers on only some nodes while keeping traditional GPU workloads on others, or you want more control over the installation, use the :ref:`Label Nodes for Confidential Containers Components <coco-label-nodes>` section in the :doc:`Detailed Install Guide <confidential-containers-deploy>`.

This quickstart takes approximately 10 minutes to complete.

.. note::

   Before starting, make sure your cluster meets the :doc:`Prerequisites <prerequisites>`.

What You Will Build
-------------------

By the end of this quickstart, you will have:

* Kata Containers running on your cluster.
* The NVIDIA GPU Operator installed and configured for Confidential Containers.
* All cluster nodes configured for Confidential Containers workloads.

.. _quickstart-install-kata:

**************************************
Install the Kata Containers Helm Chart
**************************************

#. Set the chart version and registry path:

   .. code-block:: console

      $ export VERSION="3.29.0"
      $ export CHART="oci://ghcr.io/kata-containers/kata-deploy-charts/kata-deploy"

#. Install the ``kata-deploy`` Helm chart:

   .. code-block:: console

      $ helm install kata-deploy "${CHART}" \
         --namespace kata-system --create-namespace \
         --set nfd.enabled=false \
         --wait --timeout 10m \
         --version "${VERSION}"

   *Example Output:*

   .. code-block:: output

      Pulled: ghcr.io/kata-containers/kata-deploy-charts/kata-deploy:3.29.0
      Digest: sha256:aea41018779716ce2e0bf406d701637d10fb5a0792db51a08dfd3f76701eb933
      LAST DEPLOYED: Wed Apr  1 17:03:00 2026
      NAMESPACE: kata-system
      STATUS: deployed
      REVISION: 1
      DESCRIPTION: Install complete
      TEST SUITE: None

   It can take 2 to 3 minutes for the command to return and all output to be printed.

   .. note::

      There is a `known Helm issue <https://github.com/helm/helm/issues/8660>`_ on single-node clusters that may result in the Helm command finishing before all pods are done initializing.
      If you are deploying to a single-node cluster, wait a few additional minutes after the command completes.

#. Verify that the ``kata-deploy`` pod is running:

   .. code-block:: console

      $ kubectl get pods -n kata-system | grep kata-deploy

   *Example Output:*

   .. code-block:: output

      kata-deploy-b2lzs       1/1     Running   0             6m37s

   A ``READY`` value of ``1/1`` and a ``STATUS`` of ``Running`` mean the ``kata-deploy`` pod installed the Kata components on the node.
   If the pod does not reach ``Running``, refer to :ref:`View Kata Containers Logs <coco-view-kata-logs>` in :doc:`Troubleshooting <troubleshooting>`.

#. Verify the ``kata-qemu-nvidia-gpu-snp`` and ``kata-qemu-nvidia-gpu-tdx`` runtime classes are available:

   After ``helm install`` completes, the ``kata-deploy`` chart creates the Kata ``RuntimeClass`` resources on the cluster.
   This usually happens within 1-2 minutes after the ``kata-deploy`` pod reaches ``Running``.
   Confirm SNP and TDX classes are present before you continue to :ref:`Install the NVIDIA GPU Operator <quickstart-install-gpu-operator>`.

   .. code-block:: console

      $ kubectl get runtimeclass | grep kata-qemu-nvidia-gpu

   *Example Output:*

   .. code-block:: output

      NAME                       HANDLER                    AGE
      kata-qemu-nvidia-gpu       kata-qemu-nvidia-gpu       40s
      kata-qemu-nvidia-gpu-snp   kata-qemu-nvidia-gpu-snp   40s
      kata-qemu-nvidia-gpu-tdx   kata-qemu-nvidia-gpu-tdx   40s

   If the SNP and TDX runtime classes are not listed immediately, the chart may still be initializing rather than failing.
   Wait 1-2 minutes and re-run the command.
   If they are still missing after the ``kata-deploy`` pod reports ``Running``, the install did not complete correctly.
   On a single-node cluster, retry after a few minutes only if Helm returned before the ``kata-deploy`` pod reaches ``Running`` (refer to the note above).
   Otherwise, refer to :doc:`Troubleshooting <troubleshooting>`.

**Success criteria:** Helm reports ``STATUS: deployed`` and both SNP and TDX runtime classes appear in the output above.

.. _quickstart-install-gpu-operator:

*******************************
Install the NVIDIA GPU Operator
*******************************

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

#. Install the GPU Operator configured for Confidential Containers on all nodes:

   .. code-block:: console

      $ helm install --wait --timeout 10m --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --set sandboxWorkloads.enabled=true \
         --set sandboxWorkloads.defaultWorkload=vm-passthrough \
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

   It may take 3 to 5 minutes for the Helm release to complete and for all GPU Operator pods to reach the Running state.

   The ``sandboxWorkloads.defaultWorkload=vm-passthrough`` flag in the Helm install command sets the default cluster workload type for Confidential Containers.

#. Verify that all GPU Operator pods are running:

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

**Success criteria:** All GPU Operator pods are ``Running`` or ``Completed``.

Your cluster is now configured to deploy GPU workloads into the SNP and TDX runtime classes on all nodes.

**********
Next Steps
**********

* Continue to :doc:`Run a Sample Workload <run-sample-workload>` to confirm the deployment.


