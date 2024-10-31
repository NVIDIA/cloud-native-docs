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

.. contents::
   :depth: 2
   :local:
   :backlinks: none

*************
Prerequisites
*************

- If your cluster uses Pod Security Admission (PSA) to restrict the behavior of pods,
  label the namespace for the Operator to set the enforcement policy to privileged:

  .. code-block:: console

     $ kubectl label --overwrite ns gpu-operator pod-security.kubernetes.io/enforce=privileged


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

With this procedure, all existing GPU operator resources are updated inline and the cluster policy resource is patched with updates from ``values.yaml``.

#. Specify the Operator release tag in an environment variable:

   .. code-block:: console

      $ export RELEASE_TAG=v23.9.0

#. Apply the custom resource definitions for the cluster policy and NVIDIA driver:

   .. code-block:: console

      $ kubectl apply -f \
          https://gitlab.com/nvidia/kubernetes/gpu-operator/-/raw/$RELEASE_TAG/deployments/gpu-operator/crds/nvidia.com_clusterpolicies_crd.yaml

      $ kubectl apply -f \
          https://gitlab.com/nvidia/kubernetes/gpu-operator/-/raw/$RELEASE_TAG/deployments/gpu-operator/crds/nvidia.com_nvidiadrivers.yaml

   *Example Output*

   .. code-block:: output

      customresourcedefinition.apiextensions.k8s.io/clusterpolicies.nvidia.com configured
      customresourcedefinition.apiextensions.k8s.io/nvidiadrivers.nvidia.com created

#. Apply the custom resource definition for Node Feature Discovery:

   .. code-block:: console

      $ kubectl apply -f \
          https://gitlab.com/nvidia/kubernetes/gpu-operator/-/raw/$RELEASE_TAG/deployments/gpu-operator/charts/node-feature-discovery/crds/nfd-api-crds.yaml

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

      $ helm upgrade gpu-operator nvidia/gpu-operator -n gpu-operator -f values-$RELEASE_TAG.yaml

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

#. Specify the Operator release tag in an environment variable:

   .. code-block:: console

      $ export RELEASE_TAG=v23.9.0

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
          --disable-openapi-validation -f values-$RELEASE_TAG.yaml

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

***************************************
Additional Controls for Driver Upgrades
***************************************

While most of the GPU Operator managed daemonsets can be upgraded seamlessly, the NVIDIA driver daemonset has special considerations.
Refer to :ref:`GPU Driver Upgrades` for more information.

**********************
Using OLM in OpenShift
**********************

For upgrading the GPU Operator when running in OpenShift, refer to the official documentation on upgrading installed operators:
https://docs.openshift.com/container-platform/4.8/operators/admin/olm-upgrading-operators.html

