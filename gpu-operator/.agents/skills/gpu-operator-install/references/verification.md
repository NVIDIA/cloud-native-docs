<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Verification: Running Sample GPU Applications

## CUDA VectorAdd

In the first example, let's run a simple CUDA sample, which adds two vectors together:

1. Create a file, such as `cuda-vectoradd.yaml`, with contents like the following:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: cuda-vectoradd
   spec:
     restartPolicy: OnFailure
     containers:
     - name: cuda-vectoradd
       image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda11.7.1-ubuntu20.04"
       resources:
         limits:
           nvidia.com/gpu: 1
   ```

1. Run the pod:

   ```console
   $ kubectl apply -f cuda-vectoradd.yaml
   ```

   The pod starts, runs the `vectorAdd` command, and then exits.

1. View the logs from the container:

   ```console
   $ kubectl logs pod/cuda-vectoradd
   ```

   *Example Output*

   ```output
   [Vector addition of 50000 elements]
   Copy input data from the host memory to the CUDA device
   CUDA kernel launch with 196 blocks of 256 threads
   Copy output data from the CUDA device to the host memory
   Test PASSED
   Done
   ```

1. Remove the stopped pod:

   ```console
   $ kubectl delete -f cuda-vectoradd.yaml
   ```

   *Example Output*

   ```output
   pod "cuda-vectoradd" deleted
   ```

## Jupyter Notebook

You can perform the following steps to deploy Jupyter Notebook in your cluster:

1. Create a file, such as `tf-notebook.yaml`, with contents like the following example:

   ```yaml
   ---
   apiVersion: v1
   kind: Service
   metadata:
     name: tf-notebook
     labels:
       app: tf-notebook
   spec:
     type: NodePort
     ports:
     - port: 80
       name: http
       targetPort: 8888
       nodePort: 30001
     selector:
       app: tf-notebook
   ---
   apiVersion: v1
   kind: Pod
   metadata:
     name: tf-notebook
     labels:
       app: tf-notebook
   spec:
     securityContext:
       fsGroup: 0
     containers:
     - name: tf-notebook
       image: tensorflow/tensorflow:latest-gpu-jupyter
       resources:
         limits:
           nvidia.com/gpu: 1
       ports:
       - containerPort: 8888
         name: notebook
   ```

1. Apply the manifest to deploy the pod and start the service:

   ```console
   $ kubectl apply -f tf-notebook.yaml
   ```

1. Check the pod status:

   ```console
   $ kubectl get pod tf-notebook
   ```

   *Example Output*

   ```output
   NAMESPACE   NAME          READY   STATUS      RESTARTS   AGE
   default     tf-notebook   1/1     Running     0          3m45s
   ```

1. Because the manifest includes a service, get the external port for the notebook:

   ```console
   $ kubectl get svc tf-notebook
   ```

   *Example Output*

   ```output
   NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)       AGE
   tf-notebook   NodePort    10.106.229.20   <none>        80:30001/TCP  4m41s
   ```

1. Get the token for the Jupyter notebook:

   ```console
   $ kubectl logs tf-notebook
   ```

   *Example Output*

   ```output
   [I 21:50:23.188 NotebookApp] Writing notebook server cookie secret to /root/.local/share/jupyter/runtime/notebook_cookie_secret
   [I 21:50:23.390 NotebookApp] Serving notebooks from local directory: /tf
   [I 21:50:23.391 NotebookApp] The Jupyter Notebook is running at:
   [I 21:50:23.391 NotebookApp] http://tf-notebook:8888/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9
   [I 21:50:23.391 NotebookApp]  or http://127.0.0.1:8888/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9
   [I 21:50:23.391 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
   [C 21:50:23.394 NotebookApp]

   To access the notebook, open this file in a browser:
      file:///root/.local/share/jupyter/runtime/nbserver-1-open.html
   Or copy and paste one of these URLs:
      http://tf-notebook:8888/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9
   or http://127.0.0.1:8888/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9
   ```

The notebook should now be accessible from your browser at this URL:
[http://your-machine-ip:30001/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9](http://your-machine-ip:30001/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9).
