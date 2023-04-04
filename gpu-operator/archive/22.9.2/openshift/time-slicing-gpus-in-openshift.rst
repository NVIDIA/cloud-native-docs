.. Date: June 27 2022
.. Author: stesmith

.. headings are # * - =

.. _time-slicing-nvidia-gpus-in-openshift-22.9.2

#####################################
Time-slicing NVIDIA GPUs in OpenShift
#####################################

************
Introduction
************

The latest generations of NVIDIA GPUs provide a mode of operation called Multi-Instance GPU (MIG).
MIG allows you to partition a GPU into several smaller, predefined instances, each of which looks like a mini-GPU that
provides memory and fault isolation at the hardware layer. Users can share access to a GPU by running their workloads
on one of these predefined instances instead of the full GPU.

This document describes a new mechanism for enabling time-sharing of GPUs in OpenShift. It allows a cluster
administrator to define a set of replicas for a GPU, each of which can be handed out independently to a pod
to run workloads on.

Unlike MIG, there is no memory or fault-isolation between replicas, but for some workloads this is better than not
being able to share at all. Under the hood, Compute Unified Device Architecture (CUDA) time-slicing is used to multiplex workloads from replicas of the
same underlying GPU.

**********************************
Configuring GPUs with time slicing
**********************************

The following sections show you how to configure NVIDIA Tesla T4 GPUs, as they do not support MIG, but can easily accept multiple small jobs.

----------------------------
Enabling GPU Feature Discovery
----------------------------

The feature release on GPU Feature Discovery (GFD) exposes the GPU types as labels and allows users to create node selectors based on these labels to help the scheduler place the pods. By default, when you create a ``ClusterPolicy``
custom resource, GFD is enabled. In case, you disabled it, you can re-enable it with the following command:

.. code-block:: console

   $ oc patch clusterpolicy gpu-cluster-policy -n nvidia-gpu-operator \
       --type json \
       --patch '[{"op": "replace", "path": "/spec/gfd/enable", "value": true}]'

-----------------------------------
Creating the slicing configurations
-----------------------------------

#. Before enabling a time slicing configuration, you need to tell the device plugin what are the possible configurations.

   .. code-block:: yaml

      ---
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: device-plugin-config
        namespace: nvidia-gpu-operator
      data:
        A100-SXM4-40GB: |-
          version: v1
          sharing:
            timeSlicing:
              resources:
                - name: nvidia.com/gpu
                  replicas: 8
                - name: nvidia.com/mig-1g.5gb
                  replicas: 1
                - name: nvidia.com/mig-2g.10gb
                  replicas: 2
                - name: nvidia.com/mig-3g.20gb
                  replicas: 3
                - name: nvidia.com/mig-7g.40gb
                  replicas: 7
        A100-SXM4-80GB: |-
          version: v1
          sharing:
            timeSlicing:
              resources:
                - name: nvidia.com/gpu
                  replicas: 8
                - name: nvidia.com/mig-1g.10gb
                  replicas: 1
                - name: nvidia.com/mig-2g.20gb
                  replicas: 2
                - name: nvidia.com/mig-3g.40gb
                  replicas: 3
                - name: nvidia.com/mig-7g.80gb
                  replicas: 7
        Tesla-T4: |-
          version: v1
          sharing:
            timeSlicing:
              resources:
                - name: nvidia.com/gpu
                  replicas: 8


#. Create the ConfigMap:

   .. code-block:: console

      $ oc create -f device-plugin-config.yaml

#. Tell the GPU Operator which ConfigMap to use for the device plugin configuration. You can simply patch the ``ClusterPolicy`` custom resource.

   .. code-block:: console

      $ oc patch clusterpolicy gpu-cluster-policy \
          -n nvidia-gpu-operator --type merge \
          -p '{"spec": {"devicePlugin": {"config": {"name": "device-plugin-config"}}}}'

#. Apply the configuration to all the nodes you have with Tesla TA GPUs. GFD, labels the nodes with the GPU product, in this example ``Tesla-T4``, so you can use a node selector to label all of the nodes at once.

   You can also set ``devicePlugin.config.default=Tesla-T4``, which applies the configuration across the cluster by default without requiring node specific labels.

   .. code-block:: console

      $ oc label --overwrite node \
          --selector=nvidia.com/gpu.product=Tesla-T4 \
          nvidia.com/device-plugin.config=Tesla-T4

#. After a few seconds, the configuration is applied and you can verify that GPU resource replicas have been created. The following configuration creates eight replicas for Tesla T4 GPUs, so the ``nvidia.com/gpu`` external resource is set to ``8``.

   .. code-block:: console

      $ oc get node --selector=nvidia.com/gpu.product=Tesla-T4-SHARED -o json | jq '.items[0].status.capacity'

   **Example output**

   .. code-block:: console

      {
        "attachable-volumes-aws-ebs": "39",
        "cpu": "4",
        "ephemeral-storage": "125293548Ki",
        "hugepages-1Gi": "0",
        "hugepages-2Mi": "0",
        "memory": "16105592Ki",
        "nvidia.com/gpu": "8",
        "pods": "250"
      }

#. Note that a -SHARED suffix has been added to the ``nvidia.com/gpu.product`` label to reflect that time slicing is enabled. You can disable this in the configuration. For example, the Tesla T4 configuration would look like this:

   .. code-block:: yaml

        version: v1
        sharing:
          timeSlicing:
            renameByDefault: false
            resources:
              - name: nvidia.com/gpu
                replicas: 8

#. Verify that GFD labels have been added to indicate time-sharing.

   .. code-block:: console

      $ oc get node --selector=nvidia.com/gpu.product=Tesla-T4-SHARED -o json \
       | jq '.items[0].metadata.labels' | grep nvidia

   **Example Output**

   .. code-block:: console

       "nvidia.com/cuda.driver.major": "510",
       "nvidia.com/cuda.driver.minor": "73",
       "nvidia.com/cuda.driver.rev": "08",
       "nvidia.com/cuda.runtime.major": "11",
       "nvidia.com/cuda.runtime.minor": "7",
       "nvidia.com/device-plugin.config": "Tesla-T4",
       "nvidia.com/gfd.timestamp": "1655482336",
       "nvidia.com/gpu.compute.major": "7",
       "nvidia.com/gpu.compute.minor": "5",
       "nvidia.com/gpu.count": "1",
       "nvidia.com/gpu.deploy.container-toolkit": "true",
       "nvidia.com/gpu.deploy.dcgm": "true",
       "nvidia.com/gpu.deploy.dcgm-exporter": "true",
       "nvidia.com/gpu.deploy.device-plugin": "true",
       "nvidia.com/gpu.deploy.driver": "true",
       "nvidia.com/gpu.deploy.gpu-feature-discovery": "true",
       "nvidia.com/gpu.deploy.node-status-exporter": "true",
       "nvidia.com/gpu.deploy.nvsm": "",
       "nvidia.com/gpu.deploy.operator-validator": "true",
       "nvidia.com/gpu.family": "turing",
       "nvidia.com/gpu.machine": "g4dn.xlarge",
       "nvidia.com/gpu.memory": "16106127360",
       "nvidia.com/gpu.present": "true",
       "nvidia.com/gpu.product": "Tesla-T4-SHARED",
       "nvidia.com/gpu.replicas": "8",
       "nvidia.com/mig.strategy": "single",

   If you remove the label, the node configuration is reset to its default.

******************************************
Applying the configuration to a MachineSet
******************************************

With OpenShift, you can leverage the `Machine Management <https://docs.openshift.com/container-platform/4.10/machine_management/index.html>`_ feature to dynamically provision nodes on
platforms that support it.

For example, an administrator can create a MachineSet for nodes with Tesla T4 GPUs configured with time-slicing enabled.
This provides a pool of replicas for workloads that don't require a full T4 GPU.

Consider a MachineSet named ``worker-gpu-nvidia-t4-us-east-1``, with
`Machine Autoscaler <https://docs.openshift.com/container-platform/4.10/machine_management/applying-autoscaling.html#machine-autoscaler-about_applying-autoscaling>`_ configured.
You want to ensure the new nodes will have time slicing enabled automatically, that is, you want to apply the
label to every new node. This can be done by setting the label in the MachineSet template.

   .. code-block:: console

      $ oc patch machineset worker-gpu-nvidia-t4-us-east-1a \
          -n openshift-machine-api --type merge \
          --patch '{"spec": {"template": {"spec": {"metadata": {"labels": {"nvidia.com/device-plugin.config": "Tesla-T4"}}}}}}'

Now, any new machine created by the Machine Autoscaler for this MachineSet will have the label, and time-slicing enabled.


***********************
Sample ConfigMap values
***********************

The following table shows sample values for a ConfigMap that contains
multiple ``config.yaml`` files (small, medium, and large).

+--------------------------------+-------------------------+-------+--------+-------+
|   Field                        | Description             | Small | Medium | Large |
+================================+=========================+=======+========+=======+
| ``replicas``                   | The number of replicas  |   2   |   5    |  10   |
|                                | that can be specified   |       |        |       |
|                                | for each named resource.|       |        |       |
+--------------------------------+-------------------------+-------+--------+-------+
| ``renameByDefault``            | When ``false``, the     | false | false  | false |
|                                | ``SHARED`` suffix is    |       |        |       |
|                                | added to the product    |       |        |       |
|                                | label.                  |       |        |       |
+--------------------------------+-------------------------+-------+--------+-------+
| ``failRequestsGreaterThanOne`` | This flag is ``false``  | false | false  | false |
|                                | for backward            |       |        |       |
|                                | compatibility.          |       |        |       |
+--------------------------------+-------------------------+-------+--------+-------+

.. note::
   Unlike with standard GPU requests, requesting more than one shared GPU does not guarantee that you will have access to a proportional amount of compute power. It only specifies that you will have access to a GPU that is shared by other clients, each of which has the freedom to run as many processes on the underlying GPU as they want. Internally, the GPU will simply give an equal share of time to all GPU processes across all of the clients. The ``failRequestsGreaterThanOne`` flag is meant to help users understand this subtlety, by treating a request of 1 as an access request rather than an exclusive resource request. Setting ``failRequestsGreaterThanOne=true`` is recommended, but it is set to false by default to retain backwards compatibility.
