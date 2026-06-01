<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Verifying the GPU Time-Slicing Configuration

Perform the following steps to verify that the time-slicing configuration is applied successfully:

1. Confirm that the node advertises additional GPU resources:

   ```console
   $ kubectl describe node <node-name>
   ```

   *Example Output*

   The example output varies according to the GPU in your node and the configuration
   that you apply.

   The following output applies when `renameByDefault` is set to `false`,
   the default value.
   The key considerations are as follows:

   * The `nvidia.com/gpu.count` label reports the number of physical GPUs in the machine.
   * The `nvidia.com/gpu.product` label includes a `-SHARED` suffix to the product name.
   * The `nvidia.com/gpu.replicas` label matches the reported capacity.

   ```output
   ...
   Labels:
                     nvidia.com/gpu.count=4
                     nvidia.com/gpu.product=Tesla-T4-SHARED
                     nvidia.com/gpu.replicas=4
   Capacity:
     nvidia.com/gpu: 16
     ...
   Allocatable:
     nvidia.com/gpu: 16
     ...
   ```

   The following output applies when `renameByDefault` is set to `true`.
   The key considerations are as follows:

   * The `nvidia.com/gpu.count` label reports the number of physical GPUs in the machine.
   * The `nvidia.com/gpu` capacity reports `0`.
   * The `nvidia.com/gpu.shared` capacity equals the number of physical GPUs multiplied by the
     specified number of GPU replicas to create.

   ```output
   ...
   Labels:
                     nvidia.com/gpu.count=4
                     nvidia.com/gpu.product=Tesla-T4
                     nvidia.com/gpu.replicas=4
   Capacity:
     nvidia.com/gpu:        0
     nvidia.com/gpu.shared: 16
     ...
   Allocatable:
     nvidia.com/gpu:        0
     nvidia.com/gpu.shared: 16
     ...
   ```

1. Optional: Deploy a workload to validate GPU time-slicing:

   * Create a file, such as `time-slicing-verification.yaml`, with contents like the following:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: time-slicing-verification
     labels:
       app: time-slicing-verification
   spec:
     replicas: 5
     selector:
       matchLabels:
         app: time-slicing-verification
     template:
       metadata:
         labels:
           app: time-slicing-verification
       spec:
         tolerations:
           - key: nvidia.com/gpu
             operator: Exists
             effect: NoSchedule
         hostPID: true
         containers:
           - name: cuda-sample-vector-add
             image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda11.7.1-ubuntu20.04"
             command: ["/bin/bash", "-c", "--"]
             args:
               - while true; do /cuda-samples/vectorAdd; done
             resources:
              limits:
                nvidia.com/gpu: 1
   ```

   * Create the deployment with multiple replicas:

     ```console
     $ kubectl apply -f time-slicing-verification.yaml
     ```

   * Verify that all five replicas are running:

     ```console
     $ kubectl get pods
     ```

     *Example Output*

   * View the logs from one of the pods:

     ```console
     $ kubectl logs deploy/time-slicing-verification
     ```

     *Example Output*

   * Stop the deployment:

     ```console
     $ kubectl delete -f time-slicing-verification.yaml
     ```

    *Example Output*

    ```output
    deployment.apps "time-slicing-verification" deleted
    ```

## References

- [Blog post on GPU sharing in Kubernetes](https://developer.nvidia.com/blog/improving-gpu-utilization-in-kubernetes).
- [NVIDIA Kubernetes Device Plugin](https://github.com/NVIDIA/k8s-device-plugin) repository on GitHub.
