# Cleanup

<a id="clean-up"></a>

# Cleanup

This section describes how to clean up (remove) the GPU Operator if it is no longer needed.

1. Delete the NVIDIA GPU Operator from the cluster following the guidance outlined in [Deleting Operators from a cluster](https://docs.openshift.com/container-platform/latest/operators/admin/olm-deleting-operators-from-cluster.html).

2. Delete the cluster policy by using the OpenShift Container Platform CLI.

   ```console
   $ oc delete crd clusterpolicies.nvidia.com
   ```

   ```console
   customresourcedefinition.apiextensions.k8s.io "clusterpolicies.nvidia.com" deleted
   ```
