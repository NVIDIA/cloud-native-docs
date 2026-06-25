---
name: "gpu-operator-uninstalling-nvidia"
description: "Guides users through uninstalling the NVIDIA GPU Operator and cleaning up related resources. Use when removing the Operator from a Kubernetes cluster. Trigger keywords - NVIDIA GPU Operator, uninstall, removal, Kubernetes."
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Uninstalling the GPU Operator

Perform the following steps to uninstall the Operator.

1. Optional: List and delete NVIDIA driver custom resources.

   ```console
   $ kubectl get nvidiadrivers
   ```

   *Example Output*

   ```output
   NAME          STATUS   AGE
   demo-gold     ready    2023-10-16T17:57:12Z
   demo-silver   ready    2023-10-16T17:57:12Z
   ```

   ```console
   $ kubectl delete nvidiadriver demo-gold
   $ kubectl delete nvidiadriver demo-silver
   ```

   ```console
   $ kubectl delete crd nvidiadrivers.nvidia.com
   ```

1. Delete the Operator:

   ```console
   $ helm delete -n gpu-operator $(helm list -n gpu-operator | grep gpu-operator | awk '{print $1}')
   ```

1. Optional: List the pods in the Operator namespace to confirm the pods are deleted or in the process of deleting:

   ```console
   $ kubectl get pods -n gpu-operator
   ```

   *Example Output*

   ```output
   No resources found.
   ```

By default, Helm does not [support deleting existing CRDs](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations)
when you delete the chart.
As a result, the `clusterpolicy` CRD and `nvidiadrivers` CRD will still remain, by default.

```console
$ kubectl get crd clusterpolicies.nvidia.com
```

To overcome this, the Operator uses a [post-delete hook](https://helm.sh/docs/topics/charts_hooks/#the-available-hooks)
to perform the CRD cleanup.
The `operator.cleanupCRD` chart parameter is added to enable this hook.
This parameter is disabled by default.
You can enable the hook by specifying `--set operator.cleanupCRD=true` during install or upgrade to perform automatic CRD cleanup on chart deletion.

Alternatively, you can delete the custom resource definition:

```console
$ kubectl delete crd clusterpolicies.nvidia.com
```

**Note:**

* After uninstalling the Operator, the NVIDIA driver modules might still be loaded.
  Either reboot the node or unload them using the following command:

  ```console
  $ sudo rmmod nvidia_modeset nvidia_uvm nvidia
  ```

* Helm hooks used with the GPU Operator use the Operator image itself.
  If the Operator image cannot be pulled successfully (either due to network error or an invalid NGC registry secret in case of NVAIE), hooks will fail.
  In this case, delete the chart and specify the `--no-hooks` argument to avoid hanging on hook failures.
