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


.. _coco-multi-gpu-passthrough:

*****************************************
Configuring Multi-GPU Passthrough Support
*****************************************

Multi-GPU passthrough assigns all GPUs and NVSwitches on a node to a single Confidential Container virtual machine.
This configuration is required for NVSwitch (NVLink) based HGX systems running confidential workloads.

You must assign all the GPUs and NVSwitches on the node to the same Confidential Container virtual machine.
Configuring only a subset of GPUs for Confidential Computing on a single node is not supported.

Prerequisites
=============

* Complete the :doc:`Confidential Containers deployment <confidential-containers-deploy>` steps.
* Verify that your node has multi-GPU hardware (NVSwitch-based HGX system).

Set the Confidential Computing Mode
====================================

The required CC mode depends on your GPU architecture.

Set the ``NODE_NAME`` environment variable to the name of the node you want to configure:

.. code-block:: console

   $ export NODE_NAME="<node-name>"

**NVIDIA Hopper architecture:**

Multi-GPU passthrough on Hopper uses protected PCIe (PPCIE), which claims exclusive use of the NVSwitches for a single Confidential Container.
Set the node's CC mode to ``ppcie``:

.. code-block:: console

   $ kubectl label node $NODE_NAME nvidia.com/cc.mode=ppcie --overwrite

**NVIDIA Blackwell architecture:**

The Blackwell architecture uses NVLink encryption which places the switches outside of the Trusted Computing Base (TCB).
The ``ppcie`` mode is not required. Use ``on`` mode:

.. code-block:: console

   $ kubectl label node $NODE_NAME nvidia.com/cc.mode=on --overwrite

Refer to :doc:`Managing the Confidential Computing Mode <configure-cc-mode>` for details on verifying the mode change.

Run a Multi-GPU Workload
========================

1. Create a file, such as ``multi-gpu-kata.yaml``, with a pod manifest that requests all GPUs and NVSwitches on the node:

   .. code-block:: yaml
      :emphasize-lines: 7,14-16

      apiVersion: v1
      kind: Pod
      metadata:
        name: multi-gpu-kata
        namespace: default
      spec:
        runtimeClassName: kata-qemu-nvidia-gpu-snp
        restartPolicy: Never
        containers:
          - name: cuda-sample
            image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0-ubuntu22.04"
            resources:
              limits:
                nvidia.com/pgpu: "8"
                nvidia.com/nvswitch: "4"
                memory: 128Gi

   Set the runtime class to ``kata-qemu-nvidia-gpu-snp`` for SEV-SNP or ``kata-qemu-nvidia-gpu-tdx`` for TDX, depending on the node type.

   .. note::

      If you configured ``P_GPU_ALIAS`` for heterogeneous clusters, replace ``nvidia.com/pgpu`` with the model-specific resource type.
      Refer to :ref:`Configuring the Sandbox Device Plugin to Use GPU or NVSwitch Specific Resource Types <coco-configuration-heterogeneous-clusters>` for details.

2. Create the pod:

   .. code-block:: console

      $ kubectl apply -f multi-gpu-kata.yaml

   *Example Output:*

   .. code-block:: output

      pod/multi-gpu-kata created

3. Verify the pod is running:

   .. code-block:: console

      $ kubectl get pod multi-gpu-kata

   *Example Output:*

   .. code-block:: output

      NAME             READY   STATUS    RESTARTS   AGE
      multi-gpu-kata   1/1     Running   0          30s

4. Verify that all GPUs are visible inside the container:

   .. code-block:: console

      $ kubectl exec multi-gpu-kata -- nvidia-smi -L

   *Example Output:*

   .. code-block:: output

      GPU 0: NVIDIA H100 (UUID: GPU-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
      GPU 1: NVIDIA H100 (UUID: GPU-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
      GPU 2: NVIDIA H100 (UUID: GPU-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
      GPU 3: NVIDIA H100 (UUID: GPU-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
      GPU 4: NVIDIA H100 (UUID: GPU-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
      GPU 5: NVIDIA H100 (UUID: GPU-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
      GPU 6: NVIDIA H100 (UUID: GPU-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
      GPU 7: NVIDIA H100 (UUID: GPU-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)

5. Delete the pod:

   .. code-block:: console

      $ kubectl delete -f multi-gpu-kata.yaml
