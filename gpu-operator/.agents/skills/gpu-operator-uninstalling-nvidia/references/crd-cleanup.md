<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# CRD Cleanup

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
