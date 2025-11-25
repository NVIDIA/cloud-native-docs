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


****************************************
About Using the Operator with Google GKE
****************************************

There are two ways to use NVIDIA GPU Operator with Google Kubernetes Engine (GKE).
You can use Google driver installer to install and manage NVIDIA GPU Driver on the nodes
or you can use the Operator and driver manager to manage the driver and other NVIDIA software components.

The choice depends on the operating system and whether you prefer to have the Operator manage all the software components.

.. list-table::
   :header-rows: 1
   :stub-columns: 1
   :widths: 1 2 5

   * -
     - Supported OS
     - Summary

   * - | Google
       | Driver
       | Installer
     -
       - Container-Optimized OS
       - Ubuntu with containerd
     - The Google driver installer manages the NVIDIA GPU Driver.
       NVIDIA GPU Operator manages other software components.

   * - | NVIDIA
       | Driver
       | Manager
     -
       - Ubuntu with containerd
     - NVIDIA GPU Operator manages the lifecycle and upgrades of the driver and other NVIDIA software.

The preceding information relates to using GKE Standard node pools.
For Autopilot Pods, using the GPU Operator is not supported, and you can refer to
`Deploy GPU workloads in Autopilot <https://cloud.google.com/kubernetes-engine/docs/how-to/autopilot-gpus>`__.

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

.. note::

   When installing NVIDIA GPU Operator on GKE 1.33+, there is a known issue where NVIDIA Container Toolkit will misconfigure the containerd `config.toml` file and prevent GPU Operator containers from starting up correctly.

   To resolve this issue, set the ``RUNTIME_CONFIG_SOURCE=file`` environment variable in the toolkit container. 
   You can set this environment variable by setting the below in the ClusterPolicy CR:

   .. code-block:: yaml

      toolkit:
        env:
        - name: RUNTIME_CONFIG_SOURCE
          value: "file"


*********************************
Using the Google Driver Installer
*********************************

Perform the following steps to create a GKE cluster with the ``gcloud`` CLI and use Google driver installer to manage the GPU driver.
You can create a node pool that uses a Container-Optimized OS node image or a Ubuntu node image.

#. Create the node pool.
   Refer to `Running GPUs in GKE Standard clusters <https://cloud.google.com/kubernetes-engine/docs/how-to/gpus#create>`__
   in the GKE documentation.

   When you create the node pool, specify the following additional ``gcloud`` command-line options to disable GKE features that are not supported with the Operator:

   - ``--node-labels="gke-no-default-nvidia-gpu-device-plugin=true"``

     The node label disables the GKE GPU device plugin daemon set on GPU nodes.

   - ``--accelerator type=...,gpu-driver-version=disabled``

     This argument disables automatically installing the GPU driver on GPU nodes.

#. Get the authentication credentials for the cluster:

   .. code-block:: console

      $ gcloud container clusters get-credentials demo-cluster --location us-west1

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
      gpu-operator-quota    38s     pods: 0/100

#. Install the Google driver installer daemon set.

   For Container-Optimized OS:

   .. code-block:: console

      $ kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/cos/daemonset-preloaded.yaml

   For Ubuntu, the manifest to apply depends on GPU model and node version.
   Refer to the **Ubuntu** tab at
   `Manually install NVIDIA GPU drivers <https://cloud.google.com/kubernetes-engine/docs/how-to/gpus#installing_drivers>`__
   in the GKE documentation.

#. Install the Operator using Helm:

   .. code-block:: console

      $ helm install --wait --generate-name \
          -n gpu-operator \
          nvidia/gpu-operator \
          --version=${version} \
          --set hostPaths.driverInstallDir=/home/kubernetes/bin/nvidia \
          --set toolkit.installDir=/home/kubernetes/bin/nvidia \
          --set cdi.enabled=true \
          --set cdi.default=true \
          --set driver.enabled=false

   Set the NVIDIA Container Toolkit and driver installation path to ``/home/kubernetes/bin/nvidia``.
   On GKE node images, this directory is writable and is a stateful location for storing the NVIDIA runtime binaries.

   To configure MIG with NVIDIA MIG Manager, specify the following additional Helm command arguments:

   .. code-block:: console

      --set migManager.env[0].name=WITH_REBOOT \
      --set-string migManager.env[0].value=true


***************************
Using NVIDIA Driver Manager
***************************

Perform the following steps to create a GKE cluster with the ``gcloud`` CLI and use the Operator and NVIDIA Driver Manager to manage the GPU driver.
The steps create the cluster with a node pool that uses a Ubuntu and containerd node image.

#. Create the cluster by running a command that is similar to the following example:

   .. code-block:: console

      $ gcloud beta container clusters create demo-cluster \
          --project <project-id> \
          --location us-west1 \
          --release-channel "regular" \
          --machine-type "n1-standard-4" \
          --accelerator "type=nvidia-tesla-t4,count=1" \
          --image-type "UBUNTU_CONTAINERD" \
          --node-labels="gke-no-default-nvidia-gpu-device-plugin=true" \
          --disk-type "pd-standard" \
          --disk-size "1000" \
          --no-enable-intra-node-visibility \
          --metadata disable-legacy-endpoints=true \
          --max-pods-per-node "110" \
          --num-nodes "1" \
          --logging=SYSTEM,WORKLOAD \
          --monitoring=SYSTEM \
          --enable-ip-alias \
          --default-max-pods-per-node "110" \
          --no-enable-master-authorized-networks \
          --tags=nvidia-ingress-all

   Creating the cluster requires several minutes.

#. Get the authentication credentials for the cluster:

   .. code-block:: console

      $ USE_GKE_GCLOUD_AUTH_PLUGIN=True \
          gcloud container clusters get-credentials demo-cluster --zone us-west1

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


#. Install the Operator.
   Refer to :ref:`install the NVIDIA GPU Operator <install-gpu-operator>`.


*******************
Related Information
*******************

* If you have an existing GKE cluster, refer to
  `Add and manage node pools <https://cloud.google.com/kubernetes-engine/docs/how-to/node-pools>`_
  in the GKE documentation.
* When you create new node pools, specify the
  ``--node-labels="gke-no-default-nvidia-gpu-device-plugin=true"`` and
  ``--accelerator type=...,gpu-driver-version=disabled`` CLI arguments
  to disable the GKE GPU device plugin daemon set and automatic driver installation on GPU nodes.
