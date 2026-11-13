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

.. headings (h1/h2/h3/h4/h5) are # * = -

.. _operator-upgrades:

=================================
Upgrading the NVIDIA GPU Operator
=================================

*************
Prerequisites
*************

- If your cluster uses Pod Security Admission (PSA) to restrict the behavior of pods,
  label the namespace for the Operator to set the enforcement policy to privileged:

  .. code-block:: console

     $ kubectl label --overwrite ns gpu-operator pod-security.kubernetes.io/enforce=privileged

- If CDI is enabled, review any ``DEVICE_LIST_STRATEGY`` override in ``devicePlugin.env`` before upgrading.
  Remove legacy overrides to use the Operator's default CDI strategies, or explicitly set the value to ``cdi-cri,cdi-annotations``.
  The Operator reports an error during cluster policy reconciliation if the override includes neither CDI strategy.
  Refer to :doc:`cdi` for more information.

- Changing the Driver Manager image triggers a :ref:`driver upgrade <gpu-driver-upgrades>` and can evict GPU workloads even when the NVIDIA driver version is unchanged.
  Review the target release's known issues in the :doc:`release-notes` before overriding the image.

.. _upgrading-dcgm-and-exporter:

*******************************
DCGM and DCGM Exporter Versions
*******************************

Refer to the :ref:`operator-component-matrix` for the default DCGM and DCGM Exporter versions.
If you override ``dcgm.version`` or ``dcgmExporter.version``, select compatible versions and upgrade both images together.
DCGM Exporter 4.9.0 requires a DCGM 4.7 or later host engine and cannot start against a standalone DCGM 4.6.x host engine.
This requirement applies when ``dcgm.enabled=true``, including the default OpenShift configuration, or when the exporter connects to a host engine installed on the node.
When upgrading a standalone DCGM deployment, the exporter can restart during the transition until the host engine has been upgraded.

DCGM Exporter renames the driver-version label from ``DCGM_FI_DRIVER_VERSION`` to ``DCGM_FI_SYSTEM_DRIVER_VERSION``.
Update dashboards, alerts, and queries that reference the previous label name; filters using that name can return no data after upgrading.

If you roll back these overrides, roll back both images together.
When rolling back the Operator, also restore compatible DCGM and DCGM Exporter versions.
Otherwise, OpenShift dashboards and alerts can lose GPU metrics because the older monitoring rules do not recognize the renamed metrics.


**********
Using Helm
**********

The GPU Operator supports dynamic updates to existing resources.
This ability enables the GPU Operator to ensure settings from the cluster policy specification are always applied and current.

Because Helm `does not support <https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations>`_ automatic upgrade of existing CRDs,
you can upgrade the GPU Operator chart manually or by enabling a Helm hook.

Option 1: Manually Upgrading CRDs
=================================

   .. mermaid::

      flowchart LR

         A["Update CRD from
           the latest chart"]
         -->
         B["Upgrade by
           using Helm"]

With this procedure, all existing GPU Operator resources are updated inline and the cluster policy resource is patched with updates from ``values.yaml``.

#. Specify the Operator release tag in an environment variable:

   .. code-block:: console

      $ export RELEASE_TAG=${version}

#. Apply the custom resource definitions for the cluster policy, NVIDIA driver, and GPU cluster:

   .. code-block:: console

      $ kubectl apply -f \
          https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/$RELEASE_TAG/deployments/gpu-operator/crds/nvidia.com_clusterpolicies.yaml

      $ kubectl apply -f \
          https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/$RELEASE_TAG/deployments/gpu-operator/crds/nvidia.com_nvidiadrivers.yaml

      $ kubectl apply -f \
          https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/$RELEASE_TAG/deployments/gpu-operator/crds/nvidia.com_gpuclusters.yaml

   *Example Output*

   .. code-block:: output

      customresourcedefinition.apiextensions.k8s.io/clusterpolicies.nvidia.com configured
      customresourcedefinition.apiextensions.k8s.io/nvidiadrivers.nvidia.com created
      customresourcedefinition.apiextensions.k8s.io/gpuclusters.nvidia.com created

#. If you use :doc:`DRA Driver for NVIDIA GPUs <dra-intro-install>`, apply the ComputeDomain custom resource definitions:

   .. code-block:: console

      $ kubectl apply -f \
          https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/$RELEASE_TAG/deployments/gpu-operator/crds/resource.nvidia.com_computedomains.yaml

      $ kubectl apply -f \
          https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/$RELEASE_TAG/deployments/gpu-operator/crds/resource.nvidia.com_computedomaincliques.yaml

   Apply both definitions before upgrading, including when ComputeDomain support is currently disabled.

#. Apply the custom resource definition for Node Feature Discovery:

   .. code-block:: console

      $ kubectl apply -f \
          https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/$RELEASE_TAG/deployments/gpu-operator/charts/node-feature-discovery/crds/nfd-api-crds.yaml

   *Example Output*

   .. code-block:: output

      customresourcedefinition.apiextensions.k8s.io/nodefeaturerules.nfd.k8s-sigs.io configured

#. Update the information about the Operator chart:

   .. code-block:: console

      $ helm repo update nvidia

   *Example Output*

   .. code-block:: output

      Hang tight while we grab the latest from your chart repositories...
      ...Successfully got an update from the "nvidia" chart repository
      Update Complete. ⎈Happy Helming!⎈

#. Fetch the values from the chart:

   .. code-block:: console

      $ helm show values nvidia/gpu-operator --version=$RELEASE_TAG > values-$RELEASE_TAG.yaml

#. Update the values file as needed.

#. Upgrade the Operator:

   .. code-block:: console

      $ helm upgrade gpu-operator nvidia/gpu-operator -n gpu-operator -f values-$RELEASE_TAG.yaml --version $RELEASE_TAG

   *Example Output*

   .. code-block:: output

      Release "gpu-operator" has been upgraded. Happy Helming!
      NAME: gpu-operator
      LAST DEPLOYED: Thu Apr 20 15:05:52 2023
      NAMESPACE: gpu-operator
      STATUS: deployed
      REVISION: 2
      TEST SUITE: None


Option 2: Automatically Upgrading CRDs Using a Helm Hook
========================================================

Starting with GPU Operator v22.09, a ``pre-upgrade`` Helm `hook <https://helm.sh/docs/topics/charts_hooks/#the-available-hooks>`_ can automatically upgrade to latest CRD.

Starting with GPU Operator v24.9.0, the upgrade CRD Helm hook is enabled by default and runs an upgrade CRD job when you upgrade using Helm.

.. important::

   For a ``GPUCluster`` installation, manually apply the ``computedomains.resource.nvidia.com`` and
   ``computedomaincliques.resource.nvidia.com`` custom resource definitions by using the commands in Option 1 before you upgrade.
   The automatic hook upgrades the ``GPUCluster`` custom resource definition but does not upgrade the ComputeDomain custom resource definitions.

#. Specify the Operator release tag in an environment variable:

   .. code-block:: console

      $ export RELEASE_TAG=${version}

#. Update the information about the Operator chart:

   .. code-block:: console

      $ helm repo update nvidia

   *Example Output*

   .. code-block:: output

      Hang tight while we grab the latest from your chart repositories...
      ...Successfully got an update from the "nvidia" chart repository
      Update Complete. ⎈Happy Helming!⎈

#. Fetch the values from the chart:

   .. code-block:: console

      $ helm show values nvidia/gpu-operator --version=$RELEASE_TAG > values-$RELEASE_TAG.yaml

#. Update the values file as needed.

#. Upgrade the Operator:

   .. code-block:: console

      $ helm upgrade gpu-operator nvidia/gpu-operator -n gpu-operator \
          --disable-openapi-validation -f values-$RELEASE_TAG.yaml --version $RELEASE_TAG

   .. note::

      * Option ``--disable-openapi-validation`` is required in this case so that Helm will not try to validate if CR instance from the new chart is valid as per old CRD.
        Since CR instance in the Chart is valid for the upgraded CRD, this will be compatible.

      * Helm hooks used with the GPU Operator use the operator image itself. If operator image itself cannot be pulled successfully (either due to network error or an invalid NGC registry secret in case of NVAIE), hooks will fail.
        In this case, chart needs to be deleted using ``--no-hooks`` option to avoid deletion to be hung on hook failures.

**********************
Cluster Policy Updates
**********************

The GPU Operator also supports dynamic updates to the ``ClusterPolicy`` CustomResource using ``kubectl``:

.. code-block:: console

   $ kubectl edit clusterpolicy

After the edits are complete, Kubernetes will automatically apply the updates to cluster.

.. note::

   For NVIDIA AI Enterprise vGPU deployments, the ``configMap`` (``configMapName``) for the NLS
   licensing configuration is **deprecated** and will be removed in a future release. It is recommended to migrate to use Secret based licensing when you upgrade to GPU Operator v25.10.0 or later.
   Refer to :ref:`updating-nls-secret-based` in the NVIDIA AI Enterprise install guide for details on migrating.

***************************************
Additional Controls for Driver Upgrades
***************************************

While most of the GPU Operator managed daemonsets can be upgraded seamlessly, the NVIDIA driver daemonset has special considerations.
Refer to :ref:`GPU Driver Upgrades` for more information.

***************************************************
Using Operator Lifecycle Manager (OLM) in OpenShift
***************************************************

For upgrading the GPU Operator when running in OpenShift, refer to the official OpenShift documentation on `upgrading installed operators <https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/operators/administrator-tasks#olm-upgrading-operators>`_.
