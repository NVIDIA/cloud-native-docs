<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Using the Google Driver Installer

Perform the following steps to create a GKE cluster with the `gcloud` CLI and use Google driver installer to manage the GPU driver.
You can create a node pool that uses a Container-Optimized OS node image or a Ubuntu node image.

1. Create the node pool.
   Refer to [Running GPUs in GKE Standard clusters](https://cloud.google.com/kubernetes-engine/docs/how-to/gpus#create)
   in the GKE documentation.

   When you create the node pool, specify the following additional `gcloud` command-line options to disable GKE features that are not supported with the Operator:

   - `--node-labels="gke-no-default-nvidia-gpu-device-plugin=true"`

     The node label disables the GKE GPU device plugin daemon set on GPU nodes.

   - `--accelerator type=...,gpu-driver-version=disabled`

     This argument disables automatically installing the GPU driver on GPU nodes.

1. Get the authentication credentials for the cluster:

   ```console
   $ gcloud container clusters get-credentials demo-cluster --location us-west1
   ```

1. Optional: Verify that you can connect to the cluster:

   ```console
   $ kubectl get nodes -o wide
   ```

1. Create the namespace for the NVIDIA GPU Operator:

   ```console
   $ kubectl create ns gpu-operator
   ```

1. Create a file, such as `gpu-operator-quota.yaml`, with contents like the following example:

   ```yaml
   apiVersion: v1
   kind: ResourceQuota
   metadata:
     name: gpu-operator-quota
   spec:
     hard:
       pods: 100
     scopeSelector:
       matchExpressions:
       - operator: In
         scopeName: PriorityClass
         values:
           - system-node-critical
           - system-cluster-critical
   ```

1. Apply the resource quota:

   ```console
   $ kubectl apply -n gpu-operator -f gpu-operator-quota.yaml
   ```

1. Optional: View the resource quota:

   ```console
   $ kubectl get -n gpu-operator resourcequota
   ```

   *Example Output*

   ```output
   NAME                  AGE     REQUEST
   gpu-operator-quota    38s     pods: 0/100
   ```

1. Install the Google driver installer daemon set.

   For Container-Optimized OS:

   ```console
   $ kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/cos/daemonset-preloaded.yaml
   ```

   For Ubuntu, the manifest to apply depends on GPU model and node version.
   Refer to the **Ubuntu** tab at
   [Manually install NVIDIA GPU drivers](https://cloud.google.com/kubernetes-engine/docs/how-to/gpus#installing_drivers)
   in the GKE documentation.

   > [!NOTE]
   > Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases).

1. Install the Operator using Helm:

   ```console
   $ helm install --wait --generate-name \
       -n gpu-operator \
       nvidia/gpu-operator \
       --version=<gpu-operator-version> \
       --set hostPaths.driverInstallDir=/home/kubernetes/bin/nvidia \
       --set toolkit.installDir=/home/kubernetes/bin/nvidia \
       --set cdi.enabled=true \
       --set cdi.default=true \
       --set driver.enabled=false
   ```

   Set the NVIDIA Container Toolkit and driver installation path to `/home/kubernetes/bin/nvidia`.
   On GKE node images, this directory is writable and is a stateful location for storing the NVIDIA runtime binaries.

   To configure MIG with NVIDIA MIG Manager, specify the following additional Helm command arguments:

   ```console
   --set migManager.env[0].name=WITH_REBOOT \
   --set-string migManager.env[0].value=true
   ```
