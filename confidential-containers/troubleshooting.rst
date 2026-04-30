.. _coco-deploy-troubleshooting:

###############
Troubleshooting 
###############

Use this page when Confidential Containers installation or workload deployment steps fail.

Refer to the :doc:`NVIDIA GPU Operator troubleshooting guide <gpuop:troubleshooting>` for general operator issues such as driver daemonsets, the container toolkit, and validator pods.
The sections below cover Confidential Containers-specific deploy failures: CC node labels, Kata runtime installation, VFIO binding, and host prerequisites.

If these steps do not resolve your issue, see :ref:`Getting Help <coco-getting-help>`.

**********************
View GPU Operator Logs
**********************

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


*************************
View Kata Containers Logs
*************************

#. Get the list of Kata Containers pods:

   .. code-block:: console

      $ kubectl get pods -n kata-system

   *Example Output:*

   .. code-block:: output

      NAME                       READY   STATUS    RESTARTS   AGE
      kata-deploy-<pod-name>       1/1     Running   0          6m37s

#. View the logs for the Kata Containers pod:

   .. code-block:: console

      $ kubectl logs -n kata-system <pod-name>

Replace ``<pod-name>`` with the name of the Kata Containers pod from ``kubectl get pods -n kata-system``.


.. _coco-cc-mode-troubleshoot:

**********************************
Confidential Computing Mode Issues
**********************************

``nvidia.com/cc.mode.state`` Does Not Match ``nvidia.com/cc.mode`` 
==================================================================


If the ``nvidia.com/cc.mode.state`` does not match the desired CC mode (``on``, ``off``, or ``ppcie``), it means the Confidential Computing update is still ongoing.
Wait a few more minutes, then check the labels again.

.. code-block:: console

   $ kubectl get node $NODE_NAME -o json | \
         jq '.metadata.labels | with_entries(select(.key | startswith("nvidia.com/cc")))'

   *Example Output:*

   .. code-block:: json

      {
         "nvidia.com/cc.mode": "on",
         "nvidia.com/cc.mode.state": "on",
         "nvidia.com/cc.ready.state": "true"
      }


``nvidia.com/cc.mode.state`` is ``failed`` 
==========================================

When the ``nvidia.com/cc.mode.state`` is ``failed``, it means there was a problem updating the Confidential Computing mode on the GPU.

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

      $ kubectl logs -n gpu-operator -l app=nvidia-cc-manager

#. Confirm hardware virtualization and ACS are enabled in the host BIOS.
   One way to do this is to check for ``vmx`` (Intel) or ``svm`` (AMD) in ``/proc/cpuinfo``.
   For ACS, coordinate with your :ref:`Hardware IT Administrator <coco-persona-hardware-it-administrator>` if needed.
#. Confirm no host NVIDIA GPU drivers are loaded:

   .. code-block:: console

      $ lsmod | grep nvidia

   Remove drivers as described in :ref:`Ensure No Host NVIDIA GPU Drivers Are Present <coco-prereq-no-host-drivers>`.
#. Re-apply the desired mode label to retry the transition:

   .. code-block:: console

      $ kubectl label node $NODE_NAME nvidia.com/cc.mode=on --overwrite

For mode configuration options, see :doc:`Managing the Confidential Computing Mode <configure-cc-mode>`.


**************************
Workload Deployment Issues
**************************

Use this section when a confidential GPU workload fails to schedule or start.

.. _coco-pending-pod:

The pod stays ``Pending``
=========================

Your workload pod does not schedule and remains in the ``Pending`` state.

The event message shows:

.. code-block:: output

   0/1 nodes are available: 1 Insufficient nvidia.com/pgpu.

Run ``kubectl describe pod <pod-name>`` and check **Events** for ``Insufficient nvidia.com/pgpu``.

This message means the scheduler cannot place the pod on a node with available passthrough GPU capacity.
Common causes:

* No worker nodes are configured for Confidential Containers workloads.
* ``nvidia.com/pgpu`` capacity on the cluster is zero, or there are no available GPUs on the worker nodes.
* A prerequisite from :doc:`Prerequisites <prerequisites>` is not met.

If the node lacks Confidential Containers configuration, see :ref:`Insufficient nvidia.com/pgpu and the node is not configured for Confidential Containers <coco-operands-not-running>`.
If operand pods are ``Running`` but the node still shows zero ``nvidia.com/pgpu`` capacity, see :ref:`PodResources API Get method disabled or nvidia.com/pgpu capacity is zero <coco-deploy-troubleshoot-kubelet>`.
Check the GPUs in your cluster to make sure they are healthy and available.


The pod is stuck in ``ContainerCreating``
=========================================

Your workload pod remains in the ``ContainerCreating`` state and does not start.

**Event message:**

.. code-block:: output

   Warning  FailedCreatePodSandBox  kubelet  Failed to create pod sandbox: ...
   GetPodResources failed for pod(cuda-vectoradd-kata) in namespace(default):
   rpc error: code = Unknown desc = PodResources API Get method disabled

This error means the ``KubeletPodResourcesGet`` feature gate is not enabled on the worker node.
Follow the steps in :ref:`Missing or Incorrect Kubelet Feature Gates <coco-deploy-troubleshoot-kubelet>`.


.. _coco-operands-not-running:

Insufficient ``nvidia.com/pgpu`` and the node is not configured for Confidential Containers
-------------------------------------------------------------------------------------------

**What you see:** ``kubectl describe pod <pod-name>`` shows ``Insufficient nvidia.com/pgpu`` in **Events**, and one or more of the following is true:

* ``kubectl describe node <node-name>`` does not show ``nvidia.com/gpu.workload.config=vm-passthrough``.
* ``nvidia.com/cc.ready.state`` is not ``true`` on the node.
* ``nvidia-cc-manager``, ``nvidia-vfio-manager``, ``nvidia-kata-sandbox-device-plugin``, or ``nvidia-sandbox-validator`` pods are missing or not ``Running`` on the GPU worker node.

The GPU Operator deploys Confidential Container operands only to nodes configured for passthrough sandbox workloads.
Use one of the following configuration paths.

#. Set the node name:

   .. code-block:: console

      $ export NODE_NAME="<node-name>"

#. **Per-node labeling:** Confirm the node has the Confidential Containers workload label:

   .. code-block:: console

      $ kubectl describe node $NODE_NAME | grep nvidia.com/gpu.workload.config

   *Example Output:*

   .. code-block:: output

      nvidia.com/gpu.workload.config: vm-passthrough

   If the label is missing, add it:

   .. code-block:: console

      $ kubectl label node $NODE_NAME nvidia.com/gpu.workload.config=vm-passthrough

   Refer to :ref:`Label Nodes for Confidential Containers Components <coco-label-nodes>` in :doc:`Detailed Install Guide <confidential-containers-deploy>`.

#. **Cluster-wide default:** If you skipped per-node labeling, confirm the GPU Operator ``sandboxWorkloads`` settings apply ``vm-passthrough`` to all worker nodes:

   .. code-block:: console

      $ kubectl get clusterpolicies.nvidia.com cluster-policy -o jsonpath=\
      '{.spec.sandboxWorkloads.enabled}{"\n"}{.spec.sandboxWorkloads.defaultWorkload}{"\n"}{.spec.sandboxWorkloads.mode}{"\n"}'

   *Example Output:*

   .. code-block:: output

      true
      vm-passthrough
      kata

   If values differ, update the ClusterPolicy or reinstall the GPU Operator with ``sandboxWorkloads.enabled=true``, ``sandboxWorkloads.defaultWorkload=vm-passthrough``, and ``sandboxWorkloads.mode=kata``.
   Refer to :ref:`Common GPU Operator Configuration Settings <coco-configuration-settings>` in :doc:`Detailed Install Guide <confidential-containers-deploy>`.

#. Wait up to 10 minutes after labeling or policy changes, then verify operands on the node are ``Running``:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator -o wide --field-selector spec.nodeName=$NODE_NAME

   Expected Confidential Containers operands include ``nvidia-cc-manager``, ``nvidia-vfio-manager``, ``nvidia-kata-sandbox-device-plugin``, and ``nvidia-sandbox-validator``.


.. _coco-deploy-troubleshoot-kubelet:

``PodResources API Get method disabled`` or ``nvidia.com/pgpu`` capacity is zero
--------------------------------------------------------------------------------

**What you see:** Either of the following:

* ``kubectl describe pod <pod-name>`` shows ``PodResources API Get method disabled`` in **Events** and the pod is stuck in ``ContainerCreating``.
* Kata runtime classes are installed, Confidential Containers operand pods are ``Running``, but ``kubectl describe node <node-name>`` shows zero ``nvidia.com/pgpu`` capacity and pods stay ``Pending`` with ``Insufficient nvidia.com/pgpu``.

These symptoms usually mean required kubelet feature gates are missing or misspelled on the worker host.

#. On the worker host, confirm both feature gates are enabled in ``/var/lib/kubelet/config.yaml`` (or your kubelet config path):

   .. code-block:: yaml

      featureGates:
        KubeletPodResourcesGet: true
        RuntimeClassInImageCriApi: true

   A common mistake is a misspelled gate name (for example ``KubeletPodResourceGet`` without the trailing ``s``) or enabling only one of the two gates.
#. Restart the kubelet after any change:

   .. code-block:: console

      $ sudo systemctl restart kubelet

Refer to the **Kubelet Configured** section on :doc:`Prerequisites <prerequisites>` for version-specific YAML examples.

**Logs:** ``nvidia-kata-sandbox-device-plugin`` pod logs and kubelet journal entries on the worker.


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

For NVIDIA Confidential Computing licensing requirements, see :doc:`Licensing <licensing>`.