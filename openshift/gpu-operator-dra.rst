.. _openshift-gpu-operator-dra:

################################################
Using Operator-Managed DRA on Red Hat OpenShift
################################################

The GPU Operator can deploy the DRA Driver for NVIDIA GPUs as an operand of the ``ClusterPolicy`` resource.
This page describes the OpenShift-specific prerequisites and security configuration for this deployment model.
For an overview of Dynamic Resource Allocation (DRA), configuration options, and sample workloads, refer to
:external+gpuop:doc:`gpu-operator-dra`.

.. important::

   This page documents the DRA driver operand that is configured with ``ClusterPolicy.spec.draDriver``.
   This deployment model is distinct from the Technology Preview ``GPUCluster`` integration and from installing the
   DRA Driver for NVIDIA GPUs as a standalone Helm chart.
   Support information for one deployment model does not apply to the other deployment models.

*************
Prerequisites
*************

Before you enable the Operator-managed DRA driver, ensure that your environment meets the following requirements:

* The OpenShift Container Platform and GPU Operator versions are listed as a supported combination in the
  :external+gpuop:ref:`Container Platforms <container-platforms>` table.
* You have ``cluster-admin`` access.
  This access is required because the Operator creates cluster roles, cluster role bindings, and DRA resources.
* The cluster serves the Kubernetes DRA API and includes the cluster-scoped ``DeviceClass`` resource.
  Run the following command and confirm that ``deviceclasses`` is included in the output:

  .. code-block:: console

     $ oc api-resources --api-group=resource.k8s.io --namespaced=false

  The GPU Operator also checks for the ``DeviceClass`` resource.
  If the resource is not available, a ``ClusterPolicy`` that enables DRA remains ``notReady`` and reports a
  validation error.

Review the following configuration restrictions:

* ``draDriver.gpus.enabled`` and ``devicePlugin.enabled`` cannot both be ``true``.
  Both components would otherwise advertise the same GPUs for allocation.
* ``draDriver.computeDomains.enabled`` can be used with the NVIDIA device plugin because ComputeDomain resources are
  separate from GPU resources.
* ``sandboxWorkloads.enabled`` cannot be ``true`` when either DRA driver capability is enabled in the same
  ``ClusterPolicy``.
* The integrated configuration does not provide a per-node transition between DRA GPU allocation and device-plugin
  GPU allocation.
  Configure the allocation method before scheduling GPU workloads.

**********
Enable DRA
**********

Follow :ref:`install-nvidiagpu` to install the GPU Operator.
When you create the ``ClusterPolicy`` instance, add one of the following configurations to its ``spec``.

To use DRA for GPU allocation with resource claim objects, disable the NVIDIA device plugin and enable the GPU capability of the DRA driver:

.. code-block:: yaml

   spec:
     devicePlugin:
       enabled: false
     draDriver:
       gpus:
         enabled: true

To use traditional `nvidia.com/gpu` GPU allocation and add compute domain functionality from DRA, leave the NVIDIA device plugin enabled and enable the ComputeDomains capability:

.. code-block:: yaml

   spec:
     devicePlugin:
       enabled: true
     draDriver:
       computeDomains:
         enabled: true

You can enable both DRA capabilities in one ``ClusterPolicy``, but the NVIDIA device plugin must be disabled when
``draDriver.gpus.enabled`` is ``true``.

After you apply the configuration, verify that the ``ClusterPolicy`` is ready:

.. code-block:: console

   $ oc get clusterpolicy

Verify that the DRA kubelet plugin pods are running:

.. code-block:: console

   $ oc get pods -n nvidia-gpu-operator -l app=nvidia-dra-driver-kubelet-plugin

Verify that the DRA resources are available:

.. code-block:: console

   $ oc get deviceclasses,resourceslices

If you installed the Operator in a different namespace, replace ``nvidia-gpu-operator`` in the preceding commands
with that namespace.

***************************
Security and SCC Management
***************************

The DRA kubelet plugin requires privileged access to GPU devices and to kubelet plugin directories on each GPU node.
On OpenShift, the GPU Operator detects the platform and creates the required cluster role bindings to the built-in
Security Context Constraints (SCC) roles.

.. list-table:: OpenShift SCC bindings for Operator-managed DRA
   :header-rows: 1
   :widths: 34 28 38

   * - Service account
     - SCC cluster role
     - Purpose
   * - ``nvidia-dra-driver-kubeletplugin``
     - ``system:openshift:scc:privileged``
     - Runs the DRA kubelet plugin containers with privileged access and the required host-path mounts.
   * - ``compute-domain-daemon-service-account``
     - ``system:openshift:scc:anyuid``
     - Binds the ComputeDomain daemon service account to the ``anyuid`` SCC.

The Operator sets the service account namespace in these bindings to the namespace where the Operator is installed.
Do not manually add the service accounts to the SCCs.

You can verify that the Operator created the bindings:

.. code-block:: console

   $ oc get clusterrolebinding nvidia-dra-driver-openshift-privileged-role-binding-kubeletplugin

.. code-block:: console

   $ oc get clusterrolebinding compute-domain-daemon-openshift-anyuid-role-binding

The GPU Operator service account receives RBAC permissions to create and reconcile ``DeviceClass`` resources.
The DRA service accounts receive the permissions they require for ``ResourceClaim``, ``ResourceClaimTemplate``,
``ResourceSlice``, ``ComputeDomain``, and ``ComputeDomainClique`` resources, as well as leases for controller leader
election.
