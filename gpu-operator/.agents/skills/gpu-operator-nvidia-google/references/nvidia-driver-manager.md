<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Using NVIDIA Driver Manager

Perform the following steps to create a GKE cluster with the `gcloud` CLI and use the Operator and NVIDIA Driver Manager to manage the GPU driver.
The steps create the cluster with a node pool that uses a Ubuntu and containerd node image.

1. Create the cluster by running a command that is similar to the following example:

   ```console
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
   ```

   Creating the cluster requires several minutes.

1. Get the authentication credentials for the cluster:

   ```console
   $ USE_GKE_GCLOUD_AUTH_PLUGIN=True \
       gcloud container clusters get-credentials demo-cluster --zone us-west1
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
   gke-resource-quotas   6m56s   count/ingresses.extensions: 0/100, count/ingresses.networking.k8s.io: 0/100, count/jobs.batch: 0/5k, pods: 2/1500, services: 1/500
   gpu-operator-quota    38s     pods: 0/100
   ```

1. Install the Operator (use the `gpu-operator-install` skill).

## Verification

After installing the Operator, confirm that the GPU nodes are managed and operands are healthy:

1. Confirm the GPU nodes advertise GPU capacity:

   ```console
   $ kubectl get nodes -o json | jq '.items[].status.capacity."nvidia.com/gpu"'
   ```

1. Confirm the GPU Operator pods are running:

   ```console
   $ kubectl get pods -n gpu-operator
   ```

   The `nvidia-operator-validator` pod should report `Completed`.
