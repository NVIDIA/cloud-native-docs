.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

.. headings # #, * *, =, -, ^, "

#############################
Uninstalling the GPU Operator
#############################

Perform the following steps to uninstall the Operator.

#. If a ``GPUCluster`` resource exists, delete user workloads and user-created ResourceClaims for NVIDIA GPUs.
   Wait for the workload pods to terminate and the claims to be unprepared.

   .. code-block:: console

      $ kubectl get gpucluster gpu-cluster
      $ kubectl get resourceclaim --all-namespaces

   The Helm uninstall command later in this procedure runs a ``pre-delete`` hook that deletes ``gpu-cluster``.
   The hook waits for the GPUCluster finalizer to remove Operator-managed ResourceClaim consumers before Helm removes the Operator.

#. Optional: List and delete NVIDIA driver custom resources.

   If you use ``GPUCluster``, skip this optional step unless you first delete ``gpu-cluster`` and wait for its finalizer to complete:

   .. code-block:: console

      $ kubectl delete gpucluster gpu-cluster
      $ kubectl wait --for=delete gpucluster/gpu-cluster --timeout=5m

   The chart-managed default ``NVIDIADriver`` resource does not need to be deleted separately.

   .. code-block:: console

      $ kubectl get nvidiadrivers

   *Example Output*

   .. code-block:: output

      NAME          STATUS   AGE
      demo-gold     ready    2023-10-16T17:57:12Z
      demo-silver   ready    2023-10-16T17:57:12Z

   .. code-block:: console

      $ kubectl delete nvidiadriver demo-gold
      $ kubectl delete nvidiadriver demo-silver

   .. code-block:: console

      $ kubectl delete crd nvidiadrivers.nvidia.com

#. Delete the Operator:

   .. code-block:: console

      $ helm delete -n gpu-operator $(helm list -n gpu-operator | grep gpu-operator | awk '{print $1}')

#. Optional: List the pods in the Operator namespace to confirm the pods are deleted or in the process of deleting:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator

   *Example Output*

   .. code-block:: output

      No resources found.

By default, Helm does not `support deleting existing CRDs <https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations>`__
when you delete the chart.
As a result, the ``clusterpolicy`` CRD and ``nvidiadrivers`` CRD will still remain, by default.

The ``gpuclusters.nvidia.com``, ``computedomains.resource.nvidia.com``, and
``computedomaincliques.resource.nvidia.com`` CRDs also remain after a ``GPUCluster`` installation.

.. code-block:: console

   $ kubectl get crd clusterpolicies.nvidia.com

To overcome this, the Operator uses a `pre-delete hook <https://helm.sh/docs/topics/charts_hooks/#the-available-hooks>`__
to perform the CRD cleanup.
The ``operator.cleanupCRD`` chart parameter is added to enable this hook.
This parameter is disabled by default.
You can enable the hook by specifying ``--set operator.cleanupCRD=true`` during install or upgrade to perform automatic CRD cleanup on chart deletion.

The cleanup hook removes the ``gpuclusters.nvidia.com`` CRD, but does not remove the two ComputeDomain CRDs.
After verifying that no ComputeDomain resources remain, you can remove those definitions manually:

.. code-block:: console

   $ kubectl delete crd computedomains.resource.nvidia.com
   $ kubectl delete crd computedomaincliques.resource.nvidia.com

Alternatively, you can delete the custom resource definition:

.. code-block:: console

   $ kubectl delete crd clusterpolicies.nvidia.com

.. note::

   * After uninstalling the Operator, the NVIDIA driver modules might still be loaded.
     Either reboot the node or unload them using the following command:

     .. code-block:: console

        $ sudo rmmod nvidia_modeset nvidia_uvm nvidia

   * Helm hooks used with the GPU Operator use the Operator image itself.
     If the Operator image cannot be pulled successfully (either due to network error or an invalid NGC registry secret in case of NVAIE), hooks will fail.
     In this case, delete the chart and specify the ``--no-hooks`` argument to avoid hanging on hook failures.

     If a ``GPUCluster`` resource exists, do not specify ``--no-hooks``.
     Doing so can remove the Operator before the GPUCluster finalizer completes ordered teardown of ResourceClaim-consuming operands.
     First resolve the hook failure, or delete ``gpu-cluster`` and wait for it to disappear while the Operator is still running.
