.. headings (h1/h2/h3/h4/h5) are # * = -

.. _gpu-mps:

###################################
Multi-Process Service in Kubernetes
###################################

.. contents::
   :depth: 2
   :local:
   :backlinks: none


***************************
About Multi-Process Service
***************************

NVIDIA Multi-Process Service (MPS) provides the ability to share a GPU with multiple containers.

The NVIDIA GPU Operator enables configuring MPS on a node by using
options for the `NVIDIA Kubernetes Device Plugin <https://catalog.ngc.nvidia.com/orgs/nvidia/containers/k8s-device-plugin>`_.
Using MPS, you can configure the number of *replicas* to create for each GPU on a node.
Each replica is allocatable by the kubelet to a container. 

You can apply a cluster-wide default MPS configuration and you can apply node-specific configurations.
For example, a cluster-wide configuration could create two replicas for each GPU on each node.
A node-specific configuration could be to create two replicas on some nodes and four replicas on other nodes.

You can combine the two approaches by applying a cluster-wide default configuration
and then label nodes so that those nodes receive a node-specific configuration.

Refer to :ref:`comparison-ts-mps-mig` for information about the available GPU sharing technologies.


Support Platforms and Resource Types
====================================

MPS is supported on bare-metal applications, virtual machines
with GPU passthrough, and virtual machines with NVIDIA vGPU.

The only supported resource type is ``nvidia.com/gpu``.


Limitations
===========

- DCGM-Exporter does not support associating metrics to containers when MPS is enabled with the NVIDIA Kubernetes Device Plugin.
- The Operator does not monitor changes to the config map that configures the device plugin.
- The maximum number of replicas that you can request is ``16`` for pre-Volta devices and ``48`` for newer devices.
- MPS is not supported on GPU instances from Multi-Instance GPU (MIG) devices.
- MPS does not support requesting more than one GPU device.
  Only one device resource request is supported:

  .. code-block:: yaml

     ...
       spec:
         containers:
           resources:
             limits:
               nvidia.com/gpu: 1


Changes to Node Labels
======================

In addition to the standard node labels that GPU Feature Discovery (GFD)
applies to nodes, the following label is also applied after you configure
MPS for a node:

.. code-block:: yaml

   nvidia.com/<resource-name>.replicas = <replicas-count>

Where ``<replicas-count>`` is the factor by which each resource of ``<resource-name>`` is equally divided.

Additionally, by default, the ``nvidia.com/<resource-name>.product`` label is modified:

.. code-block:: yaml

   nvidia.com/<resource-name>.product = <product-name>-SHARED

For example, on an NVIDIA DGX A100 machine, depending on the MPS configuration,
the labels can be similar to the following example:

.. code-block:: yaml

   nvidia.com/gpu.replicas = 8
   nvidia.com/gpu.product = A100-SXM4-40GB-SHARED

Using these labels, you can request access to a GPU replica or exclusive access to a GPU
in the same way that you traditionally specify a node selector to request one GPU model over another.
The ``-SHARED`` product name suffix ensures that you can specify a
node selector to assign pods to nodes with GPU replicas.

The ``migStrategy`` configuration option has an effect on the node label for the product name.
When ``renameByDefault=false``, the default value, and ``migStrategy=single``, both the MIG profile name
and the ``-SHARED`` suffix are appended to the product name, such as the following example:

.. code-block:: yaml

    nvidia.com/gpu.product = A100-SXM4-40GB-MIG-1g.5gb-SHARED

If you set ``renameByDefault=true``, then the value of the ``nvidia.com/gpu.product`` node
label is not modified.

*************
Configuration
*************

About Configuring Multi-Process Service
=======================================

You configure Multi-Process Service (MPS) by performing the following high-level steps:

* Add a config map to the namespace that is used by the GPU Operator.
* Configure the cluster policy so that the device plugin uses the config map.
* Apply a label to the nodes that you want to configure for MPS.

On a machine with one GPU, the following config map configures Kubernetes so that
the node advertises either two or four GPU resources.

.. rubric:: Sample Config Map

.. literalinclude:: ./manifests/input/mps-config-all.yaml
   :language: yaml

The following table describes the key fields in the config map.

.. list-table::
   :header-rows: 1
   :widths: 15 10 75

   * - Field
     - Type
     - Description

   * - ``data.<key>``
     - string
     - Specifies the time-slicing configuration name.

       You can specify multiple configurations if you want to assign node-specific configurations.
       In the preceding example, the values for ``key`` are ``mps-two`` and ``mps-four``.

   * - ``flags.migStrategy``
     - string
     - Specifies how to label MIG devices for the nodes that receive the MPS configuration.
       Specify one of ``none``, ``single``, or ``mixed``.

       The default value is ``none``.

   * - ``renameByDefault``
     - boolean
     - When set to ``true``, each resource is advertised under the name ``<resource-name>.shared``
       instead of ``<resource-name>``.

       For example, if this field is set to ``true`` and the resource is typically ``nvidia.com/gpu``,
       the nodes that are configured for MPS then advertise the resource as
       ``nvidia.com/gpu.shared``.
       Setting this field to true can be helpful if you want to schedule pods on GPUs with shared
       access by specifying ``<resource-name>.shared`` in the resource request.

       When this field is set to ``false``, the advertised resource name, such as ``nvidia.com/gpu``,
       is not modified.
       However, the label for the product name is suffixed with ``-SHARED``.
       For example, if the output of ``kubectl describe node`` shows the node label
       ``nvidia.com/gpu.product=Tesla-T4``, then after the node is configured for MPS,
       the label becomes ``nvidia.com/gpu.product=Tesla-T4-SHARED``.
       In this case, you can specify a node selector that includes the ``-SHARED`` suffix to
       schedule pods on GPUs with shared access.

       The default value is ``false``.

   * - ``failRequestsGreaterThanOne``
     - boolean
     - This field is used with time-slicing GPUs and is ignored for MPS.

       For MPS, resource requests for GPUs must be set to ``1``.
       Refer to the manifest examples or :ref:`Limitations`.

   * - ``resources.name``
     - string
     - Specifies the resource type to make available with MPS, ``nvidia.com/gpu``.

   * - ``resources.replicas``
     - integer
     - Specifies the number of MPS GPU replicas to make available for shared access to GPUs of the
       specified resource type.


.. _mps-cluster-wide-config:

Applying One Cluster-Wide Configuration
=======================================

Perform the following steps to configure GPU sharing with MPS if you already installed the GPU operator
and want to apply the same MPS configuration on all nodes in the cluster.

#. Create a file, such as ``mps-config-all.yaml``, with contents like the following example:

   .. literalinclude:: ./manifests/input/mps-config-all.yaml
      :language: yaml

#. Add the config map to the same namespace as the GPU operator:

   .. code-block:: console

      $ kubectl create -n gpu-operator -f mps-config-all.yaml

#. Configure the device plugin with the config map and set the default GPU sharing configuration:

   .. code-block:: console

      $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
          -n gpu-operator --type merge \
          -p '{"spec": {"devicePlugin": {"config": {"name": "mps-config-all", "default": "mps-any"}}}}'

#. Optional: Confirm that the ``gpu-feature-discovery`` and
   ``nvidia-device-plugin-daemonset`` pods restart:

   .. code-block:: console

      $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'

   *Example Output*

   .. literalinclude:: ./manifests/output/mps-all-get-events.txt
      :language: output

#. Optional: After a few minutes, confirm that the Operator starts an MPS control daemon pod for each
   node in the cluster that has a GPU.

   .. code-block:: console

      $ kubectl get pods -n gpu-operator -l app=nvidia-device-plugin-mps-control-daemon

   *Example Output*

   .. code-block:: output

      NAME                                            READY   STATUS    RESTARTS   AGE
      nvidia-device-plugin-mps-control-daemon-9pq7z   2/2     Running   0          4m20s
      nvidia-device-plugin-mps-control-daemon-kbwgp   2/2     Running   0          4m20s

Refer to :ref:`mps-verify`.

.. _mps-node-specific-config:

Applying Multiple Node-Specific Configurations
==============================================

An alternative to applying one cluster-wide configuration is to specify multiple
MPS configurations in the config map and to apply labels node-by-node to
control which configuration is applied to which nodes.

#. Create a file, such as ``mps-config-fine.yaml``, with contents like the following example:

   .. literalinclude:: ./manifests/input/mps-config-fine.yaml
      :language: yaml

#. Add the config map to the same namespace as the GPU operator:

   .. code-block:: console

      $ kubectl create -n gpu-operator -f mps-config-fine.yaml

#. Configure the device plugin with the config map:

   .. code-block:: console

      $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
          -n gpu-operator --type merge \
          -p '{"spec": {"devicePlugin": {"config": {"name": "mps-config-fine"}}}}'

   Because the specification does not include the ``devicePlugin.config.default`` field,
   when the device plugin pods redeploy, they do not automatically apply the MPS
   configuration to all nodes.

#. Optional: Confirm that the ``gpu-feature-discovery`` and
   ``nvidia-device-plugin-daemonset`` pods restart.

   .. code-block:: console

      $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'

   *Example Output*

   .. literalinclude:: ./manifests/output/mps-all-get-events.txt
      :language: output

#. Optional: After a few minutes, confirm that the Operator starts an MPS control daemon pod for each
   node in the cluster that has a GPU.

   .. code-block:: console

      $ kubectl get pods -n gpu-operator -l app=nvidia-device-plugin-mps-control-daemon

   *Example Output*

   .. code-block:: output

      NAME                                            READY   STATUS    RESTARTS   AGE
      nvidia-device-plugin-mps-control-daemon-9pq7z   2/2     Running   0          4m20s
      nvidia-device-plugin-mps-control-daemon-kbwgp   2/2     Running   0          4m20s

#. Apply a label to the nodes by running one or more of the following commands:

   * Apply a label to nodes one-by-one by specifying the node name:

     .. code-block:: console

        $ kubectl label node <node-name> nvidia.com/device-plugin.config=mps-two

   * Apply a label to several nodes at one time by specifying a label selector:

     .. code-block:: console

        $ kubectl label node \
            --selector=nvidia.com/gpu.product=Tesla-T4 \
            nvidia.com/device-plugin.config=mps-two

Refer to :ref:`mps-verify`.


Configuring Multi-Process Server Before Installing the NVIDIA GPU Operator
==========================================================================

You can enable MPS with the NVIDIA GPU Operator by passing the
``devicePlugin.config.name=<config-map-name>`` parameter during installation.

Perform the following steps to configure MPS before installing the Operator:

#. Create the namespace for the Operator:

   .. code-block:: console

      $ kubectl create namespace gpu-operator

#. Create a file, such as ``mps-config.yaml``, with the config map contents.

   Refer to the :ref:`mps-cluster-wide-config` or
   :ref:`mps-node-specific-config` sections.

#. Add the config map to the same namespace as the Operator:

   .. code-block:: console

      $ kubectl create -f mps-config.yaml -n gpu-operator

#. Install the operator with Helm:

   .. code-block:: console

      $ helm install gpu-operator nvidia/gpu-operator \
          -n gpu-operator \
          --set devicePlugin.config.name=mps-config

#. Refer to either :ref:`mps-cluster-wide-config` or
   :ref:`mps-node-specific-config` and perform the following tasks:

   * Configure the device plugin by running the ``kubectl patch`` command.
   * Apply labels to nodes if you added a config map with node-specific configurations.

After installation, refer to :ref:`mps-verify`.


.. _mps-update-config-map:

Updating an MPS Config Map
==========================

The Operator does not monitor the config map with the MPS configuration.
As a result, if you modify a config map, the device plugin pods do not restart and do not apply the modified configuration.

#. To apply the modified config map, manually restart the device plugin pods:

   .. code-block:: console

      $ kubectl rollout restart -n gpu-operator daemonset/nvidia-device-plugin-daemonset

#. Manually restart the MPS control daemon pods:

   .. code-block:: console

      $ kubectl rollout restart -n gpu-operator daemonset/nvidia-device-plugin-mps-control-daemon

Currently running workloads are not affected and continue to run, though NVIDIA recommends performing the restart during a maintenance period.


.. _mps-verify:

*******************************
Verifying the MPS Configuration
*******************************

Perform the following steps to verify that the MPS configuration is applied successfully:

#. Confirm that the node advertises additional GPU resources:

   .. code-block:: console

      $ kubectl describe node <node-name>

   *Example Output*

   The example output varies according to the GPU in your node and the configuration
   that you apply.

   The following output applies when ``renameByDefault`` is set to ``false``, the default value.
   The key considerations are as follows:

   * The ``nvidia.com/gpu.count`` label reports the number of physical GPUs in the machine.
   * The ``nvidia.com/gpu.product`` label includes a ``-SHARED`` suffix to the product name.
   * The ``nvidia.com/gpu.replicas`` label matches the reported capacity.
   * The ``nvidia.com/gpu.sharing-strategy`` label is set to ``mps``.

   .. code-block:: output
      :emphasize-lines: 3-6,8

      ...
      Labels:
                        nvidia.com/gpu.count=4
                        nvidia.com/gpu.product=Tesla-T4-SHARED
                        nvidia.com/gpu.replicas=4
                        nvidia.com/gpu.sharing-strategy=mps
      Capacity:
        nvidia.com/gpu: 16
        ...
      Allocatable:
        nvidia.com/gpu: 16
        ...

   The following output applies when ``renameByDefault`` is set to ``true``.
   The key considerations are as follows:

   * The ``nvidia.com/gpu.count`` label reports the number of physical GPUs in the machine.
   * The ``nvidia.com/gpu`` capacity reports ``0``.
   * The ``nvidia.com/gpu.shared`` capacity equals the number of physical GPUs multiplied by the
     specified number of GPU replicas to create.
   * The ``nvidia.com/gpu.sharing-strategy`` label is set to ``mps``.

   .. code-block:: output
      :emphasize-lines: 4,9

      ...
      Labels:
                        nvidia.com/gpu.count=4
                        nvidia.com/gpu.product=Tesla-T4
                        nvidia.com/gpu.replicas=4
                        nvidia.com/gpu.sharing-strategy=mps
      Capacity:
        nvidia.com/gpu:        0
        nvidia.com/gpu.shared: 16
        ...
      Allocatable:
        nvidia.com/gpu:        0
        nvidia.com/gpu.shared: 16
        ...

#. Optional: Deploy a workload to validate GPU sharing:

   * Create a file, such as ``mps-verification.yaml``, with contents like the following:

     .. literalinclude:: ./manifests/input/mps-verification.yaml
        :language: yaml

   * Create the deployment with multiple replicas:

     .. code-block:: console

        $ kubectl apply -f mps-verification.yaml

   * Verify that all five replicas are running:

     .. code-block:: console

        $ kubectl get pods

     *Example Output*

     .. literalinclude:: ./manifests/output/mps-get-pods.txt
        :language: output

   * View the logs from one of the pods:

     .. code-block:: console

        $ kubectl logs deploy/mps-verification

     *Example Output*

     .. literalinclude:: ./manifests/output/mps-logs-pods.txt
        :language: output

   * View the default active thread percentage from one of the pods:

     .. code-block:: console

        $ kubectl exec deploy/mps-verification -- bash -c "echo get_default_active_thread_percentage | nvidia-cuda-mps-control"

     *Example Output*

     .. code-block:: output

        25.0

   * View the default pinned memory limit from one of the pods:

     .. code-block:: console

        $ kubectl exec deploy/mps-verification -- bash -c "echo get_default_device_pinned_mem_limit | nvidia-cuda-mps-control"

     *Example Output*

     .. code-block:: output

        3G

   * Stop the deployment:

     .. code-block:: console

        $ kubectl delete -f mps-verification.yaml

     *Example Output*

     .. code-block:: output

        deployment.apps "mps-verification" deleted


***********
References
***********

- `Multi-Process Service <https://docs.nvidia.com/deploy/mps/index.html>`__ documentation.
