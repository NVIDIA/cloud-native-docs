.. Date: Jan 30 2023
.. Author: cdesiniotis

.. _gpu-driver-upgrades-22.9.2:

GPU Driver Upgrades
###################

Introduction
************

The NVIDIA driver daeamonset requires special consideration for upgrades because the driver kernel modules must be unloaded and loaded again on each driver container restart.
Consequently, the following steps must occur across a driver upgrade:

#. Disable all clients to the GPU driver.
#. Unload the current GPU driver kernel modules.
#. Start the updated GPU driver pod.
#. Install the updated GPU driver and load the updated kernel modules.
#. Enable the clients of the GPU driver.

The GPU Operator supports several methods for managing and automating this driver upgrade process.

.. note::

   The GPU Operator only manages the lifecycle of containerized drivers.
   Drivers which are pre-installed on the host are not managed by the GPU Operator.


Upgrades with the Upgrade Controller
******************************************

NVIDIA recommends upgrading by using the upgrade controller and the controller is enabled by default in the GPU Operator.
The controller automates the upgrade process and generates metrics and events so that you can monitor the upgrade process.

.. rubric:: Procedure

1. Upgrade the driver by changing ``driver.version`` value in ClusterPolicy:

   .. code-block:: console

      $ kubectl patch clusterpolicy/cluster-policy --type='json' -p='[{"op": "replace", "path": "/spec/driver/version", "value":"510.85.02"}]'

2. (Optional) For each node, monitor the upgrade status:

   .. code-block:: console

      $ kubectl get node -l nvidia.com/gpu.present \
         -ojsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.nvidia\.com/gpu-driver-upgrade-state}{"\n"}{end}'

.. rubric:: Example Output

   .. code-block:: console

      $ kubectl patch clusterpolicy/cluster-policy --type='json' -p='[{"op": "replace", "path": "/spec/driver/version", "value":"510.85.02"}]'
      clusterpolicy.nvidia.com/cluster-policy patched

      $ kubectl get node -l nvidia.com/gpu.present \
          -ojsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.nvidia\.com/gpu-driver-upgrade-state}{"\n"}{end}'
      k8s-node-1 upgrade-required
      k8s-node-2 upgrade-required
      k8s-node-3 upgrade-required

      // Wait for upgrades to complete
      $ kubectl get node -l nvidia.com/gpu.present \
          -ojsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.nvidia\.com/gpu-driver-upgrade-state}{"\n"}{end}'
      k8s-node-1 upgrade-done
      k8s-node-2 upgrade-done
      k8s-node-3 upgrade-done


Configuration options
=====================

The following fields in ClusterPolicy are available to configure the upgrade controller:

.. code-block:: yaml

   driver:

     upgradePolicy:
       # autoUpgrade (default=true): Switch which enables / disables the driver upgrade controller.
       #     If set to false all other options are ignored.
       autoUpgrade: true
       # maxParallelUpgrades (default=1): Number of nodes that can be upgraded in parallel. 0 means infinite.
       maxParallelUpgrades: 1

       # waitForCompletion: Options for the 'wait-for-completion' state, which will wait for a user-defined group of pods
       #    to complete before upgrading the driver on a node.
       waitForCompletion:
         # timeoutSeconds (default=0): The length of time to wait before giving up. 0 means infinite.
         timeoutSeconds: 0
         # podSelector (default=""): The label selector defining the group of pods to wait for completion of. "" means to wait on none.
         podSelector: ""

       # gpuPodDeletion: Options for the 'pod-deletion' state, which will evict all pods on the node allocated a GPU.
       gpuPodDeletion:
         # force (default=false): Delete pods even if they are not managed by a controller (e.g. ReplicationController, ReplicaSet,
         #    Job, DaemonSet or StatefulSet).
         force: false
         # timeoutSeconds (default=300): The length of time to wait before giving up. 0 means infinite. When the timeout is met,
         #    the GPU  pod(s) will be forcefully deleted.
         timeoutSeconds: 300
         # deleteEmptyDir (default=false): Delete pods even if they are using emptyDir volumes (local data will be deleted).
         deleteEmptyDir: false

       # drain: Options for the 'drain' state, which will drain the node (i.e. 'kubectl drain'). This is only performed if
       #    enabled and the 'pod-deletion' state cannot successfully remove all pods using GPU.
       drain:
         # enable (default=false): Switch for allowing node drain during the upgrade process
         enable: false
         # force (default=false): Delete pods even if they are not managed by a controller (e.g. ReplicationController, ReplicaSet,
         #    Job, DaemonSet or StatefulSet).
         force: false
         # podSelector (default=""): The label selector to filter pods on the node. "" will drain all pods.
         podSelector: ""
         # timeoutSeconds (default=300): The length of time to wait before giving up. 0 means infinite. When the timeout is met,
         #    the GPU  pod(s) will be forcefully deleted.
         timeoutSeconds: 300
         # deleteEmptyDir (default=false): Delete pods even if they are using emptyDir volumes (local data will be deleted).
         deleteEmptyDir: false

Upgrade State Machine
=====================

The upgrade controller manages driver upgrades through a well-defined state machine.
The node label, ``nvidia.com/gpu-driver-upgrade-state``, indicates the state a node is currently in.
The set of possible states are:

* Unknown (empty): The upgrade controller is disabled or the node has not been processed yet.
* ``upgrade-required``: NVIDIA driver pod is not up-to-date and requires an upgrade. No actions are performed at this stage.
* ``cordon-required``: Node will be marked Unschedulable in preparation for the driver upgrade.
* ``wait-for-jobs-required``: Node will wait on the completion of a group of pods/jobs before proceeding.
* ``pod-deletion-required``: Pods allocated GPU will be deleted from the node. If pod deletion fails, node moves to ``drain-required``
  if drain is enabled in ClusterPolicy.
* ``drain-required``: Node will be drained. This state is skipped if all GPU pods are successfully deleted from the node.
* ``pod-restart-required``: The NVIDIA driver pod running on the node will be restarted and upgraded to the new version.
* ``validation-required``: Validation of the new driver deployed on the node is required before proceeding. The GPU Operator
  performs validations in the pod named ``operator-validator``.
* ``uncordon-required``: Node will be marked Schedulable to complete the upgrade process.
* ``upgrade-done``: NVIDIA driver pod is up-to-date and running on the node.
* ``upgrade-failed``: A failure occurred during the driver upgrade.

The complete state machine is depicted in the diagram below.

.. image:: graphics/upgrade-controller-state-machine.png
   :width: 600

Pausing Driver Upgrades
=======================

If you desire to pause the automatic driver upgrade process in the cluster, toggle ``driver.upgradePolicy.autoUpgrade`` flag
in ClusterPolicy.
The entire state machine will pause and effectively disable any pending nodes from being upgraded.
This flag can be dynamically toggled again to re-enable the upgrade controller and resume any pending upgrades.

Skipping Driver Upgrades
========================

If you desire to skip driver upgrades on a certain node, label the node with ``nvidia.com/gpu-driver-upgrade.skip=true``.

Metrics and Events
==================

The GPU Operator will generate the following metrics during the upgrade process which can be scraped by Prometheus.

* ``gpu_operator_auto_upgrade_enabled``: 1 if driver auto upgrade is enabled; 0 if not.
* ``gpu_operator_nodes_upgrades_in_progress``: Total number of nodes in which a driver pod is being upgraded on.
* ``gpu_operator_nodes_upgrades_done``: Total number of nodes in which a driver pod has been successfully upgraded.
* ``gpu_operator_nodes_upgrades_failed``: Total number of nodes in which a driver pod upgrade has failed.
* ``gpu_operator_nodes_upgrades_available``: Total number of nodes in which a driver pod upgrade can start on.
* ``gpu_operator_nodes_upgrades_pending``: Total number of nodes in which driver pod upgrades are pending.

The GPU Operator will generate events during the upgrade process.
The most common events are for state transitions or failures at a particular state.
Below are an example set of events generated for the upgrade of one node.

.. code:: console

   $ kubectl get events --sort-by='.lastTimestamp' | grep GPUDriverUpgrade
   10m         Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [upgrade-required]
   10m         Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [cordon-required]
   10m         Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [wait-for-jobs-required]
   10m         Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [pod-deletion-required]
   10m         Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [pod-restart-required]
   7m          Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [validation-required]
   6m          Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [uncordon-required]
   6m          Normal   GPUDriverUpgrade     node/localhost.localdomain   Successfully updated node state label to [upgrade-done]

Troubleshooting
===============

If the upgrade fails for a particular node, the node will be marked in the ``upgrade-failed`` state.

.. code:: console

   $ kubectl get node -l nvidia.com/gpu.present \
       -ojsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.nvidia\.com/gpu-driver-upgrade-state}{"\n"}{end}'
   k8s-node-1 upgrade-done
   k8s-node-2 upgrade-done
   k8s-node-3 upgrade-failed

Check events to better understand at which stage the ugprade failed:

.. code:: console

   $ kubectl get events --sort-by='.lastTimestamp' | grep GPUDriverUpgrade

Optionally, you can check the gpu-operator logs generated for the upgrade controller:

.. code:: console

   $ kubectl logs -n gpu-operator gpu-operator-xxxxx | grep controllers.Upgrade

After resolving the upgrade failures for a particular node, you can restart the upgrade process on the node by placing it in the ``upgrade-required`` state:

.. code:: console

   $ kubectl label node <node-name>  nvidia.com/gpu-driver-upgrade-state=upgrade-required --overwrite

Upgrades without the Upgrade Controller
********************************************

If the upgrade controller is disabled or not supported for your GPU Operator version, a component called ``k8s-driver-manager`` is responsible
for executing the driver upgrade process.
The ``k8s-driver-manager`` is an `initContainer` within the driver Daemonset, which ensures all existing GPU driver clients are disabled before
unloading the current driver modules and continuing with the new driver installation.
This method still automates the core driver upgrade process, but lacks the observability that the upgrade controller provides as well as additional
controls such as pausing/skipping upgrades.
In addition, no new features will be added to the ``k8s-driver-manager`` moving forward in favor of the upgrade controller.

.. rubric:: Procedure

1. Upgrade the driver by changing ``driver.version`` value in ClusterPolicy:

   .. code-block:: console

      $ kubectl patch clusterpolicy/cluster-policy --type='json' -p='[{"op": "replace", "path": "/spec/driver/version", "value":"510.85.02"}]'

2. (Optional) To monitor the status of the upgrade, watch the deployment of the new driver pod on GPU worker nodes:

   .. code-block:: console

      kubectl get pods -n gpu-operator -lapp=nvidia-driver-daemonset -w

Configuration Options
=====================

The following configuration options are available for ``k8s-driver-manager``. The options allow users to control the
GPU pod eviction / node drain behavior.

.. code-block:: yaml

   driver:
     manager:
       env:
       - name: ENABLE_GPU_POD_EVICTION
         value: "true"
       - name: ENABLE_AUTO_DRAIN
         value: "true"
       - name: DRAIN_USE_FORCE
         value: "false"
       - name: DRAIN_POD_SELECTOR_LABEL
         value: ""
       - name: DRAIN_TIMEOUT_SECONDS
         value: "0s"
       - name: DRAIN_DELETE_EMPTYDIR_DATA
         value: "false"

* The *ENABLE_GPU_POD_EVICTION* env allows ``k8s-driver-manager`` to attempt evicting only GPU pods from the node before attempting a node drain. Only if this fails and
  *ENABLE_AUTO_DRAIN* is enabled will the node ever be drained.
* The *DRAIN_USE_FORCE* env needs to be enabled for evicting GPU pods that are not managed by any of the replication controllers (Deployment, Daemonset, StatefulSet, ReplicaSet).
* The *DRAIN_DELETE_EMPTYDIR_DATA* env needs to be enabled to allow deletion of GPU pods using emptyDir volume.

.. note::

   Since GPU pods get evicted whenever the NVIDIA Driver Daemonset spec is updated, it may not always be desirable to allow this to happen automatically.
   To prevent this ``daemonsets.updateStrategy`` parameter in the ``ClusterPolicy`` can be set to `OnDelete <https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/#daemonset-update-strategy>`_ .
   With ``OnDelete`` update strategy, a new driver pod with the updated spec will only get deployed on a node once the old driver pod is manually deleted. 
  Thus, admins can control when to rollout spec updates to driver pods on any given node. 
  For more information on DaemonSet update strategies, refer to the `Kubernetes documentation <https://kubernetes.io/docs/tasks/manage-daemon/update-daemon-set/#daemonset-update-strategy>`_.

