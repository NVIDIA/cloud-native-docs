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

###################################
NVIDIA GPU Operator with Google GKE
###################################

.. contents::
   :depth: 2
   :local:
   :backlinks: none


****************************************
About Using the Operator with Google GKE
****************************************

You can use the NVIDIA GPU Operator with Google Kubernetes Engine (GKE),
but you must use an operating system that is supported by the Operator.

By default, Google GKE configures nodes with the Container-Optimized OS with Containerd from Google.
This operating system is not supported by the Operator.

To use a supported operating system, such as Ubuntu 22.04 or 20.04, configure your
GKE cluster entirely with Ubuntu containerd nodes images or with a node pool
that uses Ubuntu containerd node images.

By selecting a supported operating system rather than Container-Optimized OS with Containerd,
you can customize which NVIDIA software components are installed by the GPU Operator at deployment time.
For example, the Operator can deploy GPU driver containers and use the Operator
to manage the lifecycle of the NVIDIA software components.


*************
Prerequisites
*************

* You installed and initialized the Google Cloud CLI.
  Refer to
  `gcloud CLI overview <https://cloud.google.com/sdk/gcloud>`_
  in the Google Cloud documentation.
* You have a Google Cloud project to use for your GKE cluster.
  Refer to
  `Creating and managing projects <https://cloud.google.com/resource-manager/docs/creating-managing-projects>`_
  in the Google Cloud documentation.
* You have the project ID for your Google Cloud project.
  Refer to `Identifying projects <https://cloud.google.com/resource-manager/docs/creating-managing-projects#identifying_projects>`_
  in the Google Cloud documentation.
* You know the machine type for the node pool and that the machine type is supported
  in your region and zone.
  Refer to `GPU platforms <https://cloud.google.com/compute/docs/gpus>`_
  in the Google Cloud documentation.


*********
Procedure
*********

Perform the following steps to create a GKE cluster with the ``gcloud`` CLI.
The steps create the cluster with a node pool that uses a Ubuntu and containerd node image.

#. Create the cluster by running a command that is similar to the following example:

   .. code-block:: console

      $ gcloud beta container clusters create demo-cluster \
          --project <project-id> \
          --zone us-west1-a \
          --release-channel "regular" \
          --machine-type "n1-standard-4" \
          --accelerator "type=nvidia-tesla-t4,count=1" \
          --image-type "UBUNTU_CONTAINERD" \
          --disk-type "pd-standard" \
          --disk-size "1000" \
          --no-enable-intra-node-visibility \
          --metadata disable-legacy-endpoints=true \
          --max-pods-per-node "110" \
          --num-nodes "1" \
          --logging=SYSTEM,WORKLOAD \
          --monitoring=SYSTEM \
          --enable-ip-alias \
          --no-enable-intra-node-visibility \
          --default-max-pods-per-node "110" \
          --no-enable-master-authorized-networks \
          --tags=nvidia-ingress-all

    Creating the cluster requires several minutes.

#. Get the authentication credentials for the cluster:

   .. code-block:: console

      $ USE_GKE_GCLOUD_AUTH_PLUGIN=True \
          gcloud container clusters get-credentials demo-cluster --zone us-west1-a

#. Optional: Verify that you can connect to the cluster:

   .. code-block:: console

      $ kubectl get nodes -o wide

#. Create the namespace for the NVIDIA GPU Operator:

   .. code-block:: console

      $ kubectl create ns gpu-operator

#. Create a file, such as ``gpu-operator-quota.yaml``, with contents like the following example:

   .. literalinclude:: ./manifests/input/google-gke-gpu-operator-quota.yaml
      :language: yaml

#. Apply the resource quota:

   .. code-block:: console

      $ kubectl apply -n gpu-operator -f gpu-operator-quota.yaml

#. Optional: View the resource quota:

   .. code-block:: console

      $ kubectl get -n gpu-operator resourcequota

   *Example Output*

   .. code-block:: output

      NAME                  AGE     REQUEST
      gke-resource-quotas   6m56s   count/ingresses.extensions: 0/100, count/ingresses.networking.k8s.io: 0/100, count/jobs.batch: 0/5k, pods: 2/1500, services: 1/500
      gpu-operator-quota    38s     pods: 0/100


**********
Next Steps
**********

* You are ready to :ref:`install the NVIDIA GPU Operator <install-gpu-operator>`
  with Helm.


*******************
Related Information
*******************

* If you have an existing GKE cluster, refer to
  `Add and manage node pools <https://cloud.google.com/kubernetes-engine/docs/how-to/node-pools>`_
  in the Google Kubernetes Engine documentation.