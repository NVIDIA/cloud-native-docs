.. Date: Jun 21 2022
.. Author: smerla

.. headings (h1/h2/h3/h4/h5) are # * = -

.. _gpu-sharing-22.9.2:

###############################
Time-Slicing GPUs in Kubernetes
###############################


*******************************
Understanding Time-Slicing GPUs
*******************************

The NVIDIA GPU Operator enables oversubscription of GPUs through a set
of extended options for the `NVIDIA Kubernetes Device Plugin <https://catalog.ngc.nvidia.com/orgs/nvidia/containers/k8s-device-plugin>`_.
GPU time-slicing enables workloads that are scheduled on oversubscribed GPUs to
interleave with one another.

This mechanism for enabling *time-slicing* of
GPUs in Kubernetes enables a system administrator to define a set of
*replicas* for a GPU, each of which can be handed out independently to a
pod to run workloads on. Unlike Multi-Instance GPU (MIG), there is no memory or
fault-isolation between replicas, but for some workloads this is better
than not being able to share at all. Internally, GPU
time-slicing is used to multiplex workloads from
replicas of the same underlying GPU.

.. note::

    A typical resource request provides exclusive access to GPUs.
    A request for a time-sliced GPU provides shared access.
    A request for more than one time-sliced GPU does not guarantee that the pod
    receives access to a proportional amount of GPU compute power.

    A request for more than one time-sliced GPU only specifies that the pod
    receives access to a GPU that is shared by other pods.
    Each pod can run as many processes on the underlying GPU without a limit.
    The GPU simply provides an equal share of time to all GPU processes, across
    all of the pods.

You can apply a cluster-wide default time-slicing configuration.
You can also apply node-specific configurations.
For example, you can apply a time-slicing configuration to nodes with Tesla-T4 GPUs only
and not modify nodes with other GPU models.

You can combine the two approaches by applying a cluster-wide default configuration
and then label nodes so that those nodes receive a node-specific configuration.

Comparison: Time-Slicing and Multi-Instance GPU
===============================================

The latest generations of NVIDIA GPUs provide an operation mode called
Multi-Instance GPU (MIG). MIG allows you to partition a GPU
into several smaller, predefined instances, each of which looks like a
mini-GPU that provides memory and fault isolation at the hardware layer.
You can share access to a GPU by running workloads on one of
these predefined instances instead of the full native GPU.

MIG support was added to Kubernetes in 2020. Refer to `Supporting MIG in Kubernetes <https://www.google.com/url?q=https://docs.google.com/document/d/1mdgMQ8g7WmaI_XVVRrCvHPFPOMCm5LQD5JefgAh6N8g/edit&sa=D&source=editors&ust=1655578433019961&usg=AOvVaw1F-OezvM-Svwr1lLsdQmu3>`_
for details on how this works.

Time-slicing trades the memory and fault-isolation that is provided by MIG
for the ability to share a GPU by a larger number of users.
Time-slicing also provides a way to provide shared access to a GPU for
older generation GPUs that do not support MIG.
However, you can combine MIG and time-slicing to provide shared access to
MIG instances.


Support Platforms and Resource Types
====================================

GPU time-slicing can be used with bare-metal applications, virtual machines
with GPU passthrough, and virtual machines with NVIDIA vGPU.

Currently, the only supported resource types are ``nvidia.com/gpu``
and any of the resource types that emerge from configuring a node with
the mixed MIG strategy.


Changes to Node Labels
======================

In addition to the standard node labels that GPU Feature Discovery (GFD)
applies to nodes, the following label is also applied after you configure
GPU time-slicing for a node:

.. code-block:: yaml

   nvidia.com/<resource-name>.replicas = <replicas-count>

Where ``<replicas-count>`` is the factor by which each resource of ``<resource-name>`` is oversubscribed.

Additionally, by default, the ``nvidia.com/<resource-name>.product`` label is modified:

.. code-block:: yaml

   nvidia.com/<resource-name>.product = <product-name>-SHARED

For example, on an NVIDIA DGX A100 machine, depending on the time-slicing configuration,
the labels can be similar to the following example:

.. code-block:: yaml

   nvidia.com/gpu.replicas = 8
   nvidia.com/gpu.product = A100-SXM4-40GB-SHARED

Using these labels, you can request time-sliced access to a GPU or exclusive access to a GPU
in the same way that you traditionally specify a node selector to request one GPU model over another.
That is, the ``-SHARED`` product name suffix ensures that you can specify a
node selector to assign pods to nodes with time-sliced GPUs.

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

About Configuring GPU Time-Slicing
==================================

You configure GPU time-slicing by performing the following high-level steps:

* Add a config map to the namespace that is used by the GPU operator.
* Configure the cluster policy so that the device plugin uses the config map.
* Apply a label to the nodes that you want to configure for GPU time-slicing.

On a machine with one GPU, the following config map configures Kubernetes so that
the node advertises four GPU resources.
A machine with two GPUs advertises eight GPUs, and so on.

.. rubric:: Sample Config Map

.. literalinclude:: ./manifests/input/time-slicing-config-sample.yaml
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
       In the preceding example, the value for ``key`` is ``any``.

   * - ``flags.migStrategy``
     - string
     - Specifies how to label MIG devices for the nodes that receive the time-slicing configuration.
       Specify one of ``none``, ``single``, or ``mixed``.

       The default value is ``none``.

   * - ``renameByDefault``
     - boolean
     - When set to ``true``, each resource is advertised under the name ``<resource-name>.shared``
       instead of ``<resource-name>``.

       For example, if this field is set to ``true`` and the resource is typically ``nvidia.com/gpu``,
       the nodes that are configured for time-sliced GPU access then advertise the resource as
       ``nvidia.com/gpu.shared``.
       Setting this field to true can be helpful if you want to schedule pods on GPUs with shared
       access by specifying ``<resource-name>.shared`` in the resource request.

       When this field is set to ``false``, the advertised resource name, such as ``nvidia.com/gpu``,
       is not modified.
       However, label for the product name is suffixed with ``-SHARED``.
       For example, if the output of ``kubectl describe node`` shows the node label
       ``nvidia.com/gpu.product=Tesla-T4``, then after the node is configured for time-sliced
       GPU access, the label becomes ``nvidia.com/gpu.product=Tesla-T4-SHARED``.
       In this case, you can specify a node selector that includes the ``-SHARED`` suffix to
       schedule pods on GPUs with shared access.

       The default value is ``false``.

   * - ``failRequestsGreaterThanOne``
     - boolean
     - The purpose of this field is to enforce awareness that requesting more than one GPU replica does not
       result in receiving more proportional access to the GPU.

       For example, if ``4`` GPU replicas are available and two pods request ``1`` GPU each and a third pod
       requests ``2`` GPUs, the applications in the three pods have an equal share of GPU compute time.
       Specifically, the pod that requests ``2`` GPUs does not receive twice as much compute time as the pods
       that request ``1`` GPU.

       When set to ``true``, a resource request for more than one GPU fails with an ``UnexpectedAdmissionError``.
       In this case, you must manually delete the pod, update the resource request, and redeploy.

   * - ``resources.name``
     - string
     - Specifies the resource type to make available with time-sliced access, such as ``nvidia.com/gpu``,
       ``nvidia.com/mig-1g.5gb``, and so on.

   * - ``resources.replicas``
     - integer
     - Specifies the number of time-sliced GPU replicas to make available for shared access to GPUs of the
       specified resource type.


.. _time-slicing-cluster-wide-config-22.9.2:

Applying One Cluster-Wide Configuration
=======================================

Perform the following steps to configure GPU time-slicing if you already installed the GPU operator
and want to apply the same time-slicing configuration on all nodes in the cluster.

#. Create a file, such as ``time-slicing-config-all.yaml``, with contents like the following example:

   .. literalinclude:: ./manifests/input/time-slicing-config-all.yaml
      :language: yaml

#. Add the config map to the same namespace as the GPU operator:

   .. code-block:: console

      $ kubectl create -n gpu-operator -f time-slicing-config-all.yaml

#. Configure the device plugin with the config map and set the default time-slicing configuration:

   .. code-block:: console

      $ kubectl patch clusterpolicy/cluster-policy \
          -n gpu-operator --type merge \
          -p '{"spec": {"devicePlugin": {"config": {"name": "time-slicing-config-all", "default": "any"}}}}'

#. (Optional) Confirm that the ``gpu-feature-discovery`` and
   ``nvidia-device-plugin-daemonset`` pods restart.

   .. code-block:: console

      $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'

   *Example Output*

   .. literalinclude:: ./manifests/output/time-slicing-get-events.txt
      :language: output

Refer to :ref:`time-slicing-verify-22.9.2`.

.. _time-slicing-node-specific-config-22.9.2:

Applying Multiple Node-Specific Configurations
==============================================

An alternative to applying one cluster-wide configuration is to specify multiple
time-slicing configurations in the config map and to apply labels node-by-node to
control which configuration is applied to which nodes.

#. Create a file, such as ``time-slicing-config-fine.yaml``, with contents like the following example:

   .. literalinclude:: ./manifests/input/time-slicing-config-fine.yaml
      :language: yaml

#. Add the config map to the same namespace as the GPU operator:

   .. code-block:: console

      $ kubectl create -n gpu-operator -f time-slicing-config-fine.yaml

#. Configure the device plugin with the config map and set the default time-slicing configuration:

   .. code-block:: console

      $ kubectl patch clusterpolicy/cluster-policy \
          -n gpu-operator --type merge \
          -p '{"spec": {"devicePlugin": {"config": {"name": "time-slicing-config-fine"}}}}'

   Because the specification does not include the ``devicePlugin.config.default`` field,
   when the device plugin pods redeploy, they do not automatically apply the time-slicing
   configuration to all nodes.

#. (Optional) Confirm that the ``gpu-feature-discovery`` and
   ``nvidia-device-plugin-daemonset`` pods restart.

   .. code-block:: console

      $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'

   *Example Output*

   .. literalinclude:: ./manifests/output/time-slicing-get-events.txt
      :language: output

#. Apply a label to the nodes by running one or more of the following commands:

   * Apply a label to nodes one-by-one by specifying the node name:

     .. code-block:: console

        $ kubectl label node <node-name> nvidia.com/device-plugin.config=tesla-t4

   * Apply a label to several nodes at one time by specifying a label selector:

     .. code-block:: console

        $ kubectl label node \
            --selector=nvidia.com/gpu.product=Tesla-T4 \
            nvidia.com/device-plugin.config=tesla-t4

Refer to :ref:`time-slicing-verify-22.9.2`.


Configuring Time-Slicing Before Installing the NVIDIA GPU Operator
==================================================================

You can enable time-slicing with the NVIDIA GPU Operator by passing the
``devicePlugin.config.name=<config-map-name>`` parameter during installation.

Perform the following steps to configure time-slicing before installing the operator:

#. Create the namespace for the operator:

   .. code-block:: console

      $ kubectl create namespace gpu-operator

#. Create a file, such as ``time-slicing-config.yaml``, with the config map contents.

   Refer to the :ref:`time-slicing-cluster-wide-config-22.9.2` or
   :ref:`time-slicing-node-specific-config-22.9.2` sections.

#. Add the config map to the same namespace as the GPU operator:

   .. code-block:: console

      $ kubectl create -f time-slicing-config.yaml

#. Install the operator with Helm:

   .. code-block:: console

      $ helm install gpu-operator nvidia/gpu-operator \
          -n gpu-operator \
          --set devicePlugin.config.name=time-slicing-config

#. Refer to either :ref:`time-slicing-cluster-wide-config-22.9.2` or
   :ref:`time-slicing-node-specific-config-22.9.2` and perform the following tasks:

   * Configure the device plugin by running the ``kubectl patch`` command.
   * Apply labels to nodes if you added a config map with node-specific configurations.

After installation, refer to :ref:`time-slicing-verify-22.9.2`.


.. _time-slicing-verify-22.9.2:

********************************************
Verifying the GPU Time-Slicing Configuration
********************************************

Perform the following steps to verify that the time-slicing configuration is applied successfully:

#. Confirm that the node advertises additional GPU resources:

   .. code-block:: console

      $ kubectl describe node <node-name>

   *Example Output*

   The example output varies according to the GPU in your node and the configuration
   that you apply.

   The following output applies when ``renameByDefault`` is set to ``false``,
   the default value.
   The key considerations are as follows:

   * The ``nvidia.com/gpu.count`` label reports the number of physical GPUs in the machine.
   * The ``nvidia.com/gpu.product`` label includes a ``-SHARED`` suffix to the product name.
   * The ``nvidia.com/gpu.replicas`` label matches the reported capacity.

   .. code-block:: output
      :emphasize-lines: 3,4,5,7

      ...
      Labels:
                        nvidia.com/gpu.count=4
                        nvidia.com/gpu.product=Tesla-T4-SHARED
                        nvidia.com/gpu.replicas=4
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

   .. code-block:: output
      :emphasize-lines: 3,7,8

      ...
      Labels:
                        nvidia.com/gpu.count=4
                        nvidia.com/gpu.product=Tesla-T4
                        nvidia.com/gpu.replicas=4
      Capacity:
        nvidia.com/gpu:        0
        nvidia.com/gpu.shared: 16
        ...
      Allocatable:
        nvidia.com/gpu:        0
        nvidia.com/gpu.shared: 16
        ...

#. (Optional) Deploy a workload to validate GPU time-slicing:

   * Create a file, such as ``time-slicing-verification.yaml``, with contents like the following:

     .. literalinclude:: ./manifests/input/time-slicing-verification.yaml
        :language: yaml

   * Create the deployment with multiple replicas:

     .. code-block:: console

        $ kubectl apply -f time-slicing-verification.yaml

   * Verify that all five replicas are running:

     .. code-block:: console

        $ kubectl get pods

     *Example Output*

     .. literalinclude:: ./manifests/output/time-slicing-get-pods.txt
        :language: output

   * View the logs from one of the pods:

     .. code-block:: console

        $ kubectl logs deploy/time-slicing-verification

     *Example Output*

     .. literalinclude:: ./manifests/output/time-slicing-logs-pods.txt
        :language: output

   * Stop the deployment:

     .. code-block:: console

        $ kubectl delete -f time-slicing-verification.yaml

    *Example Output*

    .. code-block:: output

       deployment.apps "time-slicing-verification" deleted

**********************
Example Configurations
**********************

***********
References
***********

1) `Blog post on GPU sharing in Kubernetes <https://developer.nvidia.com/blog/improving-gpu-utilization-in-kubernetes>`_.
2) `NVIDIA Kubernetes Device Plugin <https://github.com/NVIDIA/k8s-device-plugin#shared-access-to-gpus-with-cuda-time-slicing>`_.
