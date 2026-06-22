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

.. _coco-deploy-troubleshooting:

###############
Troubleshooting 
###############

Use this page when Confidential Containers installation or workload deployment steps fail.

Refer to the :doc:`NVIDIA GPU Operator troubleshooting guide <gpuop:troubleshooting>` for general operator issues such as driver daemonsets, the container toolkit, and validator pods.
The sections below cover Confidential Containers-specific deploy failures: CC node labels, Kata runtime installation, and host prerequisites.

If these steps do not resolve your issue, refer to :ref:`Getting Help <coco-getting-help>`.

.. list-table::
   :header-rows: 1
   :widths: 38 35 27

   * - Symptom
     - Cause
     - Fix
   * - :ref:`Pod stuck in Pending with Insufficient nvidia.com/pgpu <coco-pending-pod>`
     - Node not labeled for Confidential Containers, GPUs not bound to ``vfio-pci``, or all GPUs already allocated.
     - Check operands running, verify ``vm-passthrough`` label, confirm ``vfio-pci`` binding.
   * - :ref:`Pod stuck in ContainerCreating with device cold plug failed <coco-container-creating-cold-plug>`
     - ``KubeletPodResourcesGet`` feature gate not enabled on worker node.
     - Enable feature gate per :doc:`Prerequisites <prerequisites>`
   * - :ref:`nvidia.com/cc.mode.state not matching nvidia.com/cc.mode <coco-cc-mode-troubleshoot>`
     - Mode transition still in progress, or blocked by a workload using a GPU on the node.
     - Wait 1-2 minutes, check cc.mode labels. If GPU Operator pods, specifically the vfio-manager are stuck in terminating, make sure that no user workloads are running on the node.
   * - :ref:`nvidia.com/cc.mode.state is failed <coco-cc-mode-failed>`
     - Workload running during mode change, or BIOS/ACS misconfigured.
     - Drain workloads, re-apply mode label, confirm ACS enabled in BIOS.

.. _coco-gpu-operator-logs:

**********************
View GPU Operator Logs
**********************

Use this section to collect GPU Operator pod logs when an operand is not running or reporting errors.

#. Get the list of GPU Operator pods:

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

#. Get specific logs for a pod:

   .. code-block:: console

      $ kubectl logs -n gpu-operator <pod-name>

   Replace ``<pod-name>`` with the name of the GPU Operator pod from ``kubectl get pods -n gpu-operator``.


.. _coco-view-kata-logs:

*************************
View Kata Containers Logs
*************************

Use this section to collect Kata Containers logs and confirm runtime classes are installed.

#. Confirm the expected runtime classes are registered:

   .. code-block:: console

      $ kubectl get runtimeclass

   After a successful Kata Containers deployment, you should see ``kata-qemu-snp`` (AMD SEV-SNP) and ``kata-qemu-tdx`` (Intel TDX) in the output.
   If these are missing, continue to the next steps.

#. Get the list of Kata Containers pod:

   .. code-block:: console

      $ kubectl get pods -n kata-system

   *Example Output:*

   .. code-block:: output

      NAME                       READY   STATUS    RESTARTS   AGE
      kata-deploy-<pod-name>       1/1     Running   0          6m37s

#. View the logs for the Kata Containers pod:

   .. code-block:: console

      $ kubectl logs -n kata-system <pod-name>

   Replace ``<pod-name>`` with the name of the Kata Containers pod.

   *Example Output:*

   .. code-block:: output

      Install completed
      daemonset mode: waiting for SIGTERM

If the logs show errors or runtime classes are still missing after a successful Helm deploy, collect the log output and refer to :ref:`Getting Help <coco-getting-help>` for Kata-specific troubleshooting resources.


.. _coco-cc-mode-troubleshoot:

******************************************************************
``nvidia.com/cc.mode.state`` Not Matching ``nvidia.com/cc.mode`` 
******************************************************************

When changing the Confidential Computing mode (refer to :doc:`Managing the Confidential Computing Mode <configure-cc-mode>`), the Confidential Computing Manager updates the ``nvidia.com/cc.mode.state`` label to reflect the current state of the Confidential Computing mode.
If the ``nvidia.com/cc.mode.state`` does not match the desired CC mode (``on``, ``off``, or ``ppcie``), it could mean the following:

* The GPU is still updating to the Confidential Computing mode.
   Wait a few more minutes, then check the labels again.
* The transition is blocked by a user workload with a resource claim for a GPU on the node.
   This is usually accompanied by the VFIO manager stuck in Terminating state or CC Manager logs showing the mode transition is still in progress.
   Remove the workload to unblock the mode transition.

**Checks:**

#. Check the cc.mode labels:

   .. code-block:: console

      $ export NODE_NAME="<node-name>"
      $ kubectl get node $NODE_NAME -o json | \
            jq '.metadata.labels | with_entries(select(.key | startswith("nvidia.com/cc")))'

   *Example Output:*

   .. code-block:: json

      {
         "nvidia.com/cc.mode": "on",
         "nvidia.com/cc.mode.state": "on",
         "nvidia.com/cc.ready.state": "false"
      }

#. Get the list of GPU Operator pods:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator

   *Example Output:*

   .. code-block:: output

      NAME                                                          READY   STATUS        RESTARTS      AGE
      gpu-operator-6474ddf79d-s4gcb                                 1/1     Running       0             10m
      gpu-operator-node-feature-discovery-gc-8fb8d5d8d-mvvfz        1/1     Running       0             10m
      gpu-operator-node-feature-discovery-master-5bbc6d887b-66wrs   1/1     Running       0             10m
      gpu-operator-node-feature-discovery-worker-9xbb8              1/1     Running       0             10m
      nvidia-cc-manager-tqdc6                                       1/1     Running       0             10m
      nvidia-kata-sandbox-device-plugin-daemonset-b5tp7             1/1     Running       0             10m
      nvidia-vfio-manager-b7jtv                                     0/1     Terminating   0             10m

#. Get the logs for the nvidia-cc-manager pod:

   .. code-block:: console

      $ kubectl logs -n gpu-operator nvidia-cc-manager-<pod-name>

   Replace ``<pod-name>`` with the name of the nvidia-cc-manager pod from ``kubectl get pods -n gpu-operator``.

   *Example Output:*

   .. code-block:: output

      2026-06-18 19:47:26,095 - k8s-cc-manager - INFO - Resetting 2 GPU(s) to apply CC mode
      2026-06-18 19:47:26,095 - k8s-cc-manager - INFO - Resetting GPU 0000:0d:00.0
      2026-06-18 19:47:26,475 - k8s-cc-manager - INFO - Resetting GPU 0000:b5:00.0

   If the CC Manager logs show the mode transition is still in progress, it means the GPU is still updating to the Confidential Computing mode.
   CC Manager logs show ``Successfully set CC mode to '<off|on|ppcie>' on all GPUs`` when the mode transition is complete.

#. Check which pods have a passthrough GPU allocated on the node:

   .. code-block:: console

      $ kubectl get pods -A --field-selector spec.nodeName=$NODE_NAME -o json | \
          jq -r '.items[] | select(any(.spec.containers[]; .resources.requests["nvidia.com/pgpu"] // empty)) | "\(.metadata.namespace)/\(.metadata.name)"'

   *Example Output:*

   .. code-block:: output

      default/cuda-vectoradd-kata

   Any pods returned have a passthrough GPU allocated and are blocking the mode transition.

#. Delete the pod(s) to unblock the mode transition.

   .. code-block:: console

      $ kubectl delete pod <pod-name> -n <namespace>

   *Example Output:*

   .. code-block:: output

      pod "<pod-name>" deleted
   
   Repeat this step for each pod that is blocking the mode transition.
   Once all user pods are deleted, the mode transition will resume automatically.

#. Confirm the mode transition is complete:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator 

   *Example Output:*

   .. code-block:: output

      NAME                                                          READY   STATUS    RESTARTS   AGE
      gpu-operator-6474ddf79d-s4gcb                                 1/1     Running   0             10m
      gpu-operator-node-feature-discovery-gc-8fb8d5d8d-mvvfz        1/1     Running   0             10m
      gpu-operator-node-feature-discovery-master-5bbc6d887b-66wrs   1/1     Running   0             10m
      gpu-operator-node-feature-discovery-worker-9xbb8              1/1     Running   0             10m
      nvidia-cc-manager-tqdc6                                       1/1     Running   0             10m
      nvidia-kata-sandbox-device-plugin-daemonset-b5tp7             1/1     Running   0             10m
      nvidia-vfio-manager-b7jtv                                     1/1     Running   0              1m



.. _coco-cc-mode-failed:

******************************************
``nvidia.com/cc.mode.state`` is ``failed`` 
******************************************

When the ``nvidia.com/cc.mode.state`` is ``failed``, it means there was a problem updating the Confidential Computing mode on the GPU.
This typicall indicates that your GPU does not support Confidential Computing mode or there is a hardware error.
You may need to contact your :ref:`Hardware IT Administrator <coco-persona-hardware-it-administrator>` to confirm the GPU is supported and the hardware is functioning correctly.
Refer to the :doc:`Prerequisites <prerequisites>` for more information on required hardware.

**Checks:**

#. Confirm no user workloads are running on the node before changing CC mode.
   List pods scheduled on the node:

   .. code-block:: console

      $ export NODE_NAME="<node-name>"
      $ kubectl get pods -A --field-selector spec.nodeName=$NODE_NAME -o wide

   This lists pods on ``$NODE_NAME``.
   ``kube-system`` DaemonSets (for example CNI or ``kube-proxy``) are expected on every worker node.
   ``gpu-operator`` and ``kata-system`` pods are expected only if this node is configured for Confidential Containers (labeled ``nvidia.com/gpu.workload.config=vm-passthrough`` or cluster-wide ``sandboxWorkloads.defaultWorkload=vm-passthrough``).
   Delete or reschedule any other ``Running`` pods (especially GPU workloads) before changing CC mode.

#. View ``nvidia-cc-manager`` pod logs:

   .. code-block:: console

      $ kubectl logs -n gpu-operator nvidia-cc-manager-<pod-name>

   Replace ``<pod-name>`` with the name of the ``nvidia-cc-manager`` pod from ``kubectl get pods -n gpu-operator``.

#. Confirm hardware virtualization and ACS are enabled in the host BIOS.
   One way to do this is to check for ``vmx`` (Intel) or ``svm`` (AMD) in ``/proc/cpuinfo``.
   For ACS, coordinate with your :ref:`Hardware IT Administrator <coco-persona-hardware-it-administrator>` if needed.

#. Re-apply the desired mode label to retry the transition:

   .. code-block:: console

      $ kubectl label node $NODE_NAME nvidia.com/cc.mode=on --overwrite

#. Confirm the mode transition is complete by checking the CC mode labels:

   .. code-block:: console

      $ kubectl get node $NODE_NAME -o json | \
            jq '.metadata.labels | with_entries(select(.key | startswith("nvidia.com/cc")))'

   The ``nvidia.com/cc.mode.state`` label should match the desired mode when the transition is complete.
   If the state is still ``failed``, refer to :ref:`Getting Help <coco-getting-help>`.

For mode configuration options, refer to :doc:`Managing the Confidential Computing Mode <configure-cc-mode>`.

.. _coco-container-creating-cold-plug:

*************************************************************************
Pod Stuck in ``ContainerCreating`` with ``device cold plug failed`` error
*************************************************************************

If you see the following error when ``kubectl describe pod <pod-name> -n <namespace>`` and the pod is stuck in the ``ContainerCreating`` state, it means the ``KubeletPodResourcesGet`` feature gate is not enabled on the worker node.
Refer to the Kubelet Configuration section in :doc:`Prerequisites <prerequisites>` for more information on setting the feature gate.

.. code-block:: output

   Events:
     Type     Reason                  Age                 From     Message
     ----     ------                  ----                ----     -------
      Warning  FailedCreatePodSandBox  19s (x16 over 34s)  kubelet            (combined from similar events): Failed to create pod sandbox: rpc error: code = Unknown desc = failed to start sandbox "d0a43b5d3c6c433f011efbfacb6de3f7ac448f3d09a272cef8d43249712b12b1": failed to create containerd task: failed to create shim task: device cold plug failed: cold plug: GetPodResources failed for pod(cuda-vectoradd-kata) in namespace(default): rpc error: code = Unknown desc = PodResources API Get method disabled

.. _coco-pending-pod:

**************************************************************************
Pod Stuck in ``Pending`` State with ``Insufficient nvidia.com/pgpu`` Error
**************************************************************************

If ``kubectl describe pod <pod-name> -n <namespace>`` shows the pod stuck in the ``Pending`` state, the scheduler cannot place the pod on a node with available passthrough GPU capacity.

.. code-block:: output

   Events:
     Type     Reason   Age   From      Message
     ----     ------   ---   ----      -------
     Warning  FailedScheduling  ...  default-scheduler   0/1 nodes are available: 1 Insufficient nvidia.com/pgpu.

**Common causes:**

* The worker node is not configured for Confidential Containers workloads.
* GPU Operator Confidential Containers operands are missing or not ``Running`` on the worker node.
* ``nvidia.com/pgpu`` capacity on the node is zero because GPUs are not bound to ``vfio-pci`` on the host.
* All passthrough GPUs on eligible nodes are already allocated to other pods.

**Resolution:**

#. Confirm GPU Operator operands are ``Running`` on the worker node:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator -o wide --field-selector spec.nodeName=<node-name>

   Expected Confidential Containers operands include ``nvidia-cc-manager``, ``nvidia-vfio-manager``, ``nvidia-kata-sandbox-device-plugin``, and ``nvidia-sandbox-validator``.
   If an operand is not ``Running``, refer to :ref:`View GPU Operator Logs <coco-gpu-operator-logs>`.

#. Confirm the node is configured for Confidential Containers workloads:

   .. code-block:: console

      $ kubectl describe node <node-name> | grep nvidia.com/gpu.workload.config

   *Example Output:*

   .. code-block:: output

      nvidia.com/gpu.workload.config: vm-passthrough

   If the label is missing, add it:

   .. code-block:: console

      $ kubectl label node <node-name> nvidia.com/gpu.workload.config=vm-passthrough

   If you set the cluster-wide default during installation instead of per-node labeling, confirm ``sandboxWorkloads.defaultWorkload`` is ``vm-passthrough``.
   Refer to :ref:`Common GPU Operator Configuration Settings <coco-configuration-settings>` in :doc:`Detailed Install Guide <confidential-containers-deploy>`.

#. Check ``nvidia.com/pgpu`` capacity on the node:

   .. code-block:: console

      $ kubectl describe node <node-name> | grep nvidia.com/pgpu

   *Example Output:*

   .. code-block:: output

      nvidia.com/pgpu:  8
      nvidia.com/pgpu:  8

   If capacity and allocatable are zero, GPUs are not available for scheduling.
   On the worker host, confirm VFIO binding (``10de`` is the NVIDIA PCI vendor ID):

   .. code-block:: console

      $ lspci -nnk -d 10de:

   *Example Output (expected):*

   .. code-block:: output

      65:00.0 3D controller [0302]: NVIDIA Corporation Device [10de:xxxx] (rev a1)
              Kernel driver in use: vfio-pci

   If the output shows ``Kernel driver in use: nvidia`` or ``nouveau``, remove host drivers as described in :ref:`Ensure No Host NVIDIA GPU Drivers Are Present <coco-prereq-no-host-drivers>`.
   Confirm IOMMU is enabled:

   .. code-block:: console

      $ ls /sys/kernel/iommu_groups

   If the directory is empty or missing, configure IOMMU as described in :ref:`Prerequisites <coco-prerequisites>`, then reboot the host.
   Review ``nvidia-vfio-manager`` pod logs on the affected node in :ref:`View GPU Operator Logs <coco-gpu-operator-logs>`.
   After fixing host prerequisites, wait for operand pods to reconcile and confirm ``nvidia.com/pgpu`` is non-zero.

#. If the node shows non-zero ``nvidia.com/pgpu`` capacity but the pod is still ``Pending``, all passthrough GPUs on eligible nodes may be allocated to other pods.
   Check which pods currently have a passthrough GPU allocated:

   .. code-block:: console

      $ kubectl get pods -A --field-selector spec.nodeName=<node-name> -o json | \
          jq -r '.items[] | select(any(.spec.containers[]; .resources.requests["nvidia.com/pgpu"] // empty)) | "\(.metadata.namespace)/\(.metadata.name)"'

   Wait for a workload to complete or free capacity before retrying.

Refer to the optional VFIO validation step in :doc:`Detailed Install Guide <confidential-containers-deploy>`.


.. _coco-getting-help:

************
Getting Help
************

If the steps on this page do not resolve your issue, use the resources below based on which component is failing.

NVIDIA GPU Operator and Confidential Computing Operands
=======================================================

For issues with GPU Operator pods or Confidential Containers operands (``nvidia-cc-manager``, ``nvidia-vfio-manager``, ``nvidia-kata-sandbox-device-plugin``, and ``nvidia-sandbox-validator``):

#. Review the :doc:`NVIDIA GPU Operator troubleshooting guide <gpuop:troubleshooting>`.
#. If the issue is not documented there, run the GPU Operator ``must-gather`` utility to collect cluster diagnostics:

   .. code-block:: console

      $ curl -o must-gather.sh -L https://raw.githubusercontent.com/NVIDIA/gpu-operator/main/hack/must-gather.sh
      $ chmod +x must-gather.sh
      $ ./must-gather.sh

   The utility produces an archive with manifests and logs from GPU Operator-managed components.

#. Prepare a bug report and file an issue in the `NVIDIA GPU Operator GitHub repository <https://github.com/NVIDIA/gpu-operator/issues>`_.

Kata Containers
===============

For issues with ``kata-deploy``, missing runtime classes, or Kata runtime failures:

#. Search the `Kata Containers GitHub issues <https://github.com/kata-containers/kata-containers/issues>`_ for similar reports.
#. If no existing issue matches your problem, `open a new issue <https://github.com/kata-containers/kata-containers/issues/new/choose>`_ in that repository.

   Include your environment details, Kata chart version, ``kata-deploy`` pod logs, and cluster configuration.

Attestation and Upstream Confidential Containers
================================================

For attestation, Trustee, sealed secrets, or other upstream Confidential Containers features, refer to the `Confidential Containers documentation <https://confidentialcontainers.org/docs/>`__ and the `Confidential Containers GitHub repository <https://github.com/confidential-containers>`_.

For NVIDIA Confidential Computing licensing requirements, refer to :doc:`Licensing <licensing>`.