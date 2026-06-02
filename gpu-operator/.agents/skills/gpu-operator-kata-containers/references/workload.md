<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Run a Sample Kata Workload and Troubleshoot

## Run a Sample Workload

A pod specification for a Kata container requires the following:

* Specify a Kata runtime class.

* Specify a passthrough GPU resource.

1. Create a file, such as `cuda-vectoradd-kata.yaml`, with the following content:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: cuda-vectoradd-kata
     namespace: default
   spec:
     runtimeClassName: kata-qemu-nvidia-gpu
     restartPolicy: OnFailure
     containers:
       - name: cuda-vectoradd
         image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0-ubuntu22.04"
         resources:
           limits:
             nvidia.com/pgpu: "1"
             memory: 16Gi
   ```

1. Create the pod:

   ```console
   $ kubectl apply -f cuda-vectoradd-kata.yaml
   ```

   *Example Output:*

   ```output
   pod/cuda-vectoradd-kata created
   ```

1. Optional: Verify the pod is running:

   ```console
   $ kubectl get pod cuda-vectoradd-kata
   ```

   *Example Output:*

   ```output
   NAME                  READY   STATUS    RESTARTS   AGE
   cuda-vectoradd-kata   1/1     Running   0          10s
   ```

1. View the pod logs:

   ```console
   $ kubectl logs -n default cuda-vectoradd-kata
   ```

   *Example Output:*

   ```output
   [Vector addition of 50000 elements]
   Copy input data from the host memory to the CUDA device
   CUDA kernel launch with 196 blocks of 256 threads
   Copy output data from the CUDA device to the host memory
   Test PASSED
   Done
   ```

1. Delete the pod:

   ```console
   $ kubectl delete -f cuda-vectoradd-kata.yaml
   ```

## Troubleshooting Workloads

If the sample workload does not run, confirm that you labeled nodes to run virtual machines in containers:

```console
$ kubectl get nodes -l nvidia.com/gpu.workload.config=vm-passthrough
```

*Example Output:*

```output
NAME               STATUS   ROLES    AGE   VERSION
kata-worker-1      Ready    <none>   10d   v1.35.3
kata-worker-2      Ready    <none>   10d   v1.35.3
kata-worker-3      Ready    <none>   10d   v1.35.3
```

You might have configured `vm-passthrough` as the default sandbox workload in the ClusterPolicy resource.
That setting applies the default sandbox workload cluster-wide, including for Kata when `mode` is `kata`.
Also confirm in the ClusterPolicy that `sandboxWorkloads` is configured for Kata as shown in the following example.

```console
$ kubectl describe clusterpolicy | grep sandboxWorkloads
```

*Example Output:*

```output
sandboxWorkloads:
  enabled: true
  defaultWorkload: vm-passthrough
  mode: kata
```
