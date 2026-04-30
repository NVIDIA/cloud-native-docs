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

As a :ref:`Kubernetes Cluster Administrator <coco-persona-kubernetes-cluster-administrator>`, use this page to verify your installation and run a sample workload.
:ref:`Container User <coco-persona-container-user>` personas can also run the sample workload to confirm the cluster is ready before deploying applications.
For persona responsibilities and documentation structure, see :doc:`Personas <personas>`.

Verify your confidential Container setup by running a basic single-GPU sample workload inside a Confidential Container.

This page assumes that you have completed :doc:`Prerequisites <prerequisites>` and either :doc:`Quickstart Install <install-quickstart>` or :doc:`Detailed Install Guide <confidential-containers-deploy>`.
Your cluster should have ``kata-qemu-nvidia-gpu-snp`` and ``kata-qemu-nvidia-gpu-tdx`` runtime classes installed, and GPU Operator operands (including the Confidential Computing Manager, Kata Sandbox Device Plugin, and VFIO Manager) running on your nodes.

This page intentionally uses the simplest possible manifest so that you can confirm the deployment end-to-end.
It is not a production workload template.
For runtime class selection, resource type naming, multi-GPU passthrough, and additional manifest patterns, refer to :doc:`Configuring Workloads <configure-workloads>`.

#. Create a file named ``cuda-vectoradd-kata.yaml`` with a sample manifest for your system:

   .. tab-set::

      .. tab-item:: AMD-based system (SNP)
         :sync: amd-snp

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
                      nvidia.com/pgpu: "1" # for single GPU passthrough
                      memory: 16Gi

      .. tab-item:: Intel-based system (TDX)
         :sync: intel-tdx

         .. code-block:: yaml
            :emphasize-lines: 7,14

            apiVersion: v1
            kind: Pod
            metadata:
              name: cuda-vectoradd-kata
              namespace: default
            spec:
              runtimeClassName: kata-qemu-nvidia-gpu-tdx
              restartPolicy: Never
              containers:
                - name: cuda-vectoradd
                  image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0-ubuntu22.04"
                  resources:
                    limits:
                      nvidia.com/pgpu: "1" # for single GPU passthrough
                      memory: 16Gi

   The following is a brief list of the options available for the manifest:

   * Runtime class: Use ``kata-qemu-nvidia-gpu-snp`` on AMD-based systems or ``kata-qemu-nvidia-gpu-tdx`` on Intel-based systems.
   * GPU resource type: The sample requests ``nvidia.com/pgpu``, which is the default resource name advertised by the NVIDIA Kata Sandbox Device Plugin.
     If your cluster was installed with the ``P_GPU_ALIAS=""`` setting, replace it with the model-specific name advertised on your node, for example ``nvidia.com/GH100_H200_141GB``.

   Refer to :doc:`Configuring Confidential Container Workloads <configure-workloads>` for additional guidance on each option.

#. Create the pod:

   .. code-block:: console

      $ kubectl apply -f cuda-vectoradd-kata.yaml

   *Example Output:*

   .. code-block:: output

      pod/cuda-vectoradd-kata created

#. Verify the pod is running:

   .. code-block:: console

      $ kubectl get pod cuda-vectoradd-kata

   *Example Output:*

   .. code-block:: output

      NAME                  READY   STATUS    RESTARTS   AGE
      cuda-vectoradd-kata   1/1     Running   0          10s

   The pod could also say ``Completed`` if the container already completed successfully.
   
   If the pod stays ``Pending`` for more than a few minutes, see :doc:`Troubleshooting Workload Deployment Issues <troubleshooting>` before continuing.

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

    The output should include ``Test PASSED`` if the container completed successfully.

    If you aren't seeing any log output, make sure the pod is running and the container is started.

#. Delete the pod:

   .. code-block:: console

      $ kubectl delete -f cuda-vectoradd-kata.yaml



**********
Next Steps
**********

* Refer to the :doc:`Advanced Setup Overview <configure>` section for more information on managing the Confidential Computing mode and configuring workloads.
