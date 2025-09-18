.. Date: September 01 2021
.. Author: kquinn

.. _clean-up:

*****************************************
Cleanup
*****************************************
This section describes how to clean up (remove) the GPU Operator if it is no longer needed.

#. Delete the NVIDIA GPU Operator from the cluster following the guidance outlined in `Deleting Operators from a cluster <https://docs.openshift.com/container-platform/latest/operators/admin/olm-deleting-operators-from-cluster.html>`_.

#. Delete the cluster policy by using the OpenShift Container Platform CLI.

   .. code-block:: console

      $ oc delete crd clusterpolicies.nvidia.com

   .. code-block:: console

      customresourcedefinition.apiextensions.k8s.io "clusterpolicies.nvidia.com" deleted
