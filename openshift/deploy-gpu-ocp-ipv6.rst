.. headings are # * - =

.. _deploy-gpu-ocp-ipv6:

######################################
Deploy GPU Operator in an IPv6 Network
######################################

************
Introduction
************

You can deploy the NVIDIA GPU Operator on an OpenShift Container Platform cluster that uses IPv6-only networking.
The only component that requires IPv6-specific configuration is NVIDIA DCGM.

The default ``ClusterPolicy`` custom resource sets ``dcgm.enabled`` to ``true``.
With this setting, the Operator deploys DCGM as a separate ``nvidia-dcgm`` daemon set.
DCGM Exporter connects to the DCGM host engine, ``nv-hostengine``, through the ``nvidia-dcgm`` service on port ``5555``.

The DCGM container starts the host engine with the ``-b 0.0.0.0`` argument by default.
This argument binds the host engine to IPv4 addresses only.
In an IPv6-only cluster, DCGM Exporter cannot connect to the host engine and the exporter pods go into ``CrashLoopBackOff``.

***********************
Configure DCGM for IPv6
***********************

To bind the host engine to IPv6 addresses, set ``dcgm.args`` and specify ``::`` as the bind address.
The ``::`` value binds the host engine to all interfaces for IPv4 and IPv6.
The values in ``dcgm.args`` replace the default container arguments, so you must specify the complete argument list.

.. rubric:: Prerequisites

* GPU Operator v26.7.1 or later.
  Earlier versions include a DCGM Exporter that cannot resolve the ``nvidia-dcgm`` service name to an IPv6 address.

.. rubric:: Procedure

* If you create the cluster policy from the command line, add the following ``dcgm`` field to the ``spec`` object in the ``clusterpolicy.json`` file before you apply it:

  .. code-block:: json

     "dcgm": {
       "enabled": true,
       "args": ["-n", "-b", "::", "--log-level", "NONE", "-f", "-"]
     }

* If the cluster policy already exists, patch it:

  .. code-block:: console

     $ oc patch clusterpolicy gpu-cluster-policy --type=merge \
         -p '{"spec":{"dcgm":{"args":["-n","-b","::","--log-level","NONE","-f","-"]}}}'
