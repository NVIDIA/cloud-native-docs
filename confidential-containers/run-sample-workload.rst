.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
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


.. _coco-run-sample-workload:

*********************
Run a Sample Workload
*********************

After completing the :doc:`deployment steps <confidential-containers-deploy>`, you can verify your installation by running a sample GPU workload in a confidential container.

A pod manifest for a confidential container GPU workload requires that you specify the ``kata-qemu-nvidia-gpu-snp`` runtime class for SEV-SNP or ``kata-qemu-nvidia-gpu-tdx`` for TDX.

1. Create a file, such as the following ``cuda-vectoradd-kata.yaml`` sample, specifying the kata-qemu-nvidia-gpu-snp runtime class:

   .. code-block:: yaml
      :emphasize-lines: 7,14

      apiVersion: v1
      kind: Pod
      metadata:
        name: cuda-vectoradd-kata
        namespace: default
      spec:
        runtimeClassName: kata-qemu-nvidia-gpu-snp
        restartPolicy: Never
        containers:
          - name: cuda-vectoradd
            image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0-ubuntu22.04"
            resources:
              limits:
                nvidia.com/pgpu: "1"
                memory: 16Gi

   The following are Confidential Containers configurations in the sample manifest:

   * Set the runtime class to ``kata-qemu-nvidia-gpu-snp`` for SEV-SNP or ``kata-qemu-nvidia-gpu-tdx`` for TDX, depending on the node type where the workloads should run.

   * In the sample above, ``nvidia.com/pgpu`` is the default resource type for GPUs.
     If you are deploying on a heterogeneous cluster, you might want to update the default behavior by specifying the ``P_GPU_ALIAS`` environment variable for the sandbox device plugin.
     Refer to the :ref:`Configuring the Sandbox Device Plugin to Use GPU or NVSwitch Specific Resource Types <coco-configuration-heterogeneous-clusters>` for more details.

   * If you have machines that support multi-GPU passthrough, refer to the :doc:`Configuring Multi-GPU Passthrough <configure-multi-gpu>` page for a complete workload example and architecture-specific CC mode requirements.


2. Create the pod:

   .. code-block:: console

      $ kubectl apply -f cuda-vectoradd-kata.yaml
   
   *Example Output:*

   .. code-block:: output

      pod/cuda-vectoradd-kata created


   Optional: Verify the pod is running.

   .. code-block:: console 

      $ kubectl get pod cuda-vectoradd-kata

   *Example Output:*

   .. code-block:: output

      NAME                  READY   STATUS    RESTARTS   AGE
      cuda-vectoradd-kata   1/1     Running   0          10s

3. View the logs from the pod after the container starts:

   .. code-block:: console

      $ kubectl logs -n default cuda-vectoradd-kata

   *Example Output:*

   .. code-block:: output

      [Vector addition of 50000 elements]
      Copy input data from the host memory to the CUDA device
      CUDA kernel launch with 196 blocks of 256 threads
      Copy output data from the CUDA device to the host memory
      Test PASSED
      Done

4. Delete the pod:

   .. code-block:: console

      $ kubectl delete -f cuda-vectoradd-kata.yaml


Next Steps
==========

* Configure :doc:`Attestation <attestation>` with the Trustee framework to enable remote verification of your confidential environment.
* Set up :doc:`multi-GPU passthrough <configure-multi-gpu>` for NVSwitch-based HGX systems.
* Tune :doc:`image pull timeouts <configure-image-pull-timeouts>` if you are pulling large container images.
* Manage the :doc:`confidential computing mode <configure-cc-mode>` on your GPUs.
