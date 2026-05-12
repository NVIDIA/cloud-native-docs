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

#####################
Run a Sample Workload
#####################

After completing the :doc:`deployment steps <confidential-containers-deploy>`, verify your
installation by running a basic single-GPU sample workload inside a Confidential Container.

This page intentionally uses the simplest possible manifest so that you can confirm the
deployment end-to-end.
For the full set of workload configuration options, including runtime class selection,
resource type naming, and multi-GPU passthrough, refer to
:doc:`Configuring Confidential Container Workloads <configure-multi-gpu>`.

#. Create a file named ``cuda-vectoradd-kata.yaml`` with the following sample manifest:

   .. code-block:: yaml
      :emphasize-lines: 7,14

      apiVersion: v1
      kind: Pod
      metadata:
        name: cuda-vectoradd-kata
        namespace: default
      spec:
        runtimeClassName: kata-qemu-nvidia-gpu-snp # or kata-qemu-nvidia-gpu-tdx
        restartPolicy: Never
        containers:
          - name: cuda-vectoradd
            image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0-ubuntu22.04"
            resources:
              limits:
                nvidia.com/pgpu: "1"
                memory: 16Gi

   Before applying the manifest, adjust the two highlighted lines for your environment:

   * **Runtime class.** Use ``kata-qemu-nvidia-gpu-snp`` on AMD SEV-SNP nodes or
     ``kata-qemu-nvidia-gpu-tdx`` on Intel TDX nodes.
   * **GPU resource type.** The sample requests ``nvidia.com/pgpu``, which is the default
     resource name advertised by the NVIDIA Kata sandbox device plugin.
     If your cluster was installed with the ``P_GPU_ALIAS=""`` setting, replace it with the
     model-specific name advertised on your node, for example ``nvidia.com/GH100_H200_141GB``.

   Refer to :doc:`Configuring Confidential Container Workloads <configure-multi-gpu>` for
   guidance on each option.

#. Create the pod:

   .. code-block:: console

      $ kubectl apply -f cuda-vectoradd-kata.yaml

   *Example Output:*

   .. code-block:: output

      pod/cuda-vectoradd-kata created

#. Optional: Verify the pod is running:

   .. code-block:: console

      $ kubectl get pod cuda-vectoradd-kata

   *Example Output:*

   .. code-block:: output

      NAME                  READY   STATUS    RESTARTS   AGE
      cuda-vectoradd-kata   1/1     Running   0          10s

#. View the logs from the pod after the container starts:

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

#. Delete the pod:

   .. code-block:: console

      $ kubectl delete -f cuda-vectoradd-kata.yaml


**********
Next Steps
**********

* :doc:`Configure Confidential Container workloads <configure-multi-gpu>` for runtime class
  selection, resource type naming, and single- or multi-GPU passthrough patterns.
* Configure :doc:`Attestation <attestation>` with the Trustee framework to enable remote
  verification of your confidential environment.
* Manage the :doc:`confidential computing mode <configure-cc-mode>` on your GPUs.
