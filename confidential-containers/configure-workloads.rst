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


.. _coco-configure-workloads:

############################################
Configuring Confidential Container Workloads
############################################

As a :ref:`Container User <coco-persona-container-user>`, use this page to configure confidential GPU workloads on a prepared cluster.
For persona responsibilities and documentation structure, see :doc:`Personas <personas>`.

A Confidential Container workload is a standard Kubernetes pod that runs inside a TEE-protected
virtual machine and requests one or more GPUs through the NVIDIA Kata sandbox device plugin.
Compared with a traditional GPU pod, a Confidential Container workload pod manifest differs in
three ways:

* It selects a TEE-aware Kata runtime class instead of the default ``runc``-based runtime.
* It requests GPU and NVSwitch resources using the resource types advertised by the NVIDIA
  Kata sandbox device plugin, which can be either default names or model-specific names.
* For NVSwitch-based HGX systems, it requests every GPU and NVSwitch on the node together so
  that all devices reside inside the same Confidential Container virtual machine.

This page is part of **Advanced Setup** and is the usual next step after a successful install.

**Before this page:** Complete the :doc:`Detailed Install Guide <confidential-containers-deploy>` and verify the cluster with :doc:`Run a Sample Workload <run-sample-workload>` (``Test PASSED`` in pod logs).
For install steps, see :doc:`Prerequisites <prerequisites>` and :doc:`Detailed Install Guide <confidential-containers-deploy>`.

This page describes each of these decisions and provides single-GPU and multi-GPU passthrough
manifest examples that you can copy and adapt to your environment.
The install sample uses a minimal manifest; use this page for production-style configuration.

********************************
Select a Container Runtime Class
********************************

A Confidential Container workload must set ``spec.runtimeClassName`` to a TEE-aware Kata
runtime that NVIDIA provides through the ``kata-deploy`` Helm chart.
Select the runtime class based on the CPU TEE on the target worker node:

.. list-table::
   :header-rows: 1
   :widths: 30 40 30

   * - Node TEE
     - Runtime class
     - Typical CPU vendor
   * - AMD SEV-SNP
     - ``kata-qemu-nvidia-gpu-snp``
     - AMD EPYC (Genoa or newer)
   * - Intel TDX
     - ``kata-qemu-nvidia-gpu-tdx``
     - Intel Xeon (Sapphire Rapids or newer)

The ``kata-deploy`` chart also installs a ``kata-qemu-nvidia-gpu`` runtime class.
That class is intended for non-confidential Kata workloads. You should not use it for Confidential
Container workloads because it does not start the GPU in CC mode.

.. _coco-resource-types:

*****************************************
Reference GPU and NVSwitch Resource Types
*****************************************

The NVIDIA Kata sandbox device plugin advertises GPUs and NVSwitches to Kubernetes as extended resources.
Your pod manifest requests those resources under ``resources.limits``. 
You can use either the default resource types or model-specific resource types.

By default, every passthrough GPU is advertised as ``nvidia.com/pgpu`` and every NVSwitch is advertised as ``nvidia.com/nvswitch``.
These names are stable across GPU models, which keeps manifests portable when every node in your cluster has the same GPU type.

A sample resource request using the default resource type is shown below:

.. code-block:: yaml

   resources:
     limits:
       nvidia.com/pgpu: "1"

In heterogeneous clusters, where worker nodes use different GPU models, you can configure the Kata sandbox device plugin to advertise resources under model-specific names by setting
``P_GPU_ALIAS=""`` (and optionally ``NVSWITCH_ALIAS=""``) on the plugin.
With this configuration, GPUs are exposed as resources such as ``nvidia.com/GH100_H200_141GB``,
which lets a workload pin itself to a specific accelerator model.

Refer to :ref:`Configuring GPU or NVSwitch Resource Types Name <coco-configuration-heterogeneous-clusters>`
for the GPU Operator install flags that enable this behavior.

Use the model-specific resource name in workloads that must target a specific accelerator:

.. code-block:: yaml

   resources:
     limits:
       nvidia.com/GH100_H200_141GB: "1"

To list the GPU and NVSwitch resource types advertised on a node, run:

.. code-block:: console

   $ kubectl get node $NODE_NAME -o json | grep nvidia.com

*Example Output:*

.. code-block:: output

   "nvidia.com/GH100_H200_141GB": "1"

.. _coco-single-gpu-workload:

**********************
Single-GPU Passthrough
**********************

A single-GPU workload requests one GPU and runs inside its own Confidential Container virtual
machine.
This pattern is the recommended starting point for verifying a deployment and for most
independent workloads that do not require NVLink between GPUs.

#. Create a file, such as ``cuda-vectoradd-kata.yaml``:

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

   .. note::

      If you configured the Kata sandbox device plugin to use model-specific resource types,
      replace ``nvidia.com/pgpu`` with the appropriate model-specific name, such as
      ``nvidia.com/GH100_H200_141GB``.

#. Create the pod:

   .. code-block:: console

      $ kubectl apply -f cuda-vectoradd-kata.yaml

#. Verify the workload completes successfully:

   .. code-block:: console

      $ kubectl logs cuda-vectoradd-kata

   *Example Output:*

   .. code-block:: output

      [Vector addition of 50000 elements]
      Copy input data from the host memory to the CUDA device
      CUDA kernel launch with 196 blocks of 256 threads
      Copy output data from the CUDA device to the host memory
      Test PASSED
      Done

Refer to :doc:`Run a Sample Workload <run-sample-workload>` for the end-to-end verification flow including
deletion and pending-pod guidance.

.. _coco-multi-gpu-prereqs:
.. _coco-multi-gpu-passthrough:

*********************
Multi-GPU Passthrough
*********************

Multi-GPU passthrough assigns every GPU and NVSwitch on a node to a single Confidential
Container virtual machine.
This configuration is required for NVSwitch (NVLink) based HGX systems running confidential
workloads.

.. important::

   You must assign all the GPUs and NVSwitches on the node to the same Confidential Container
   virtual machine.
   Configuring only a subset of GPUs for Confidential Computing on a single node is not
   supported.

NVIDIA Hopper PPCIE Mode
========================

For NVIDIA Hopper GPUs, multi-GPU passthrough requires protected PCIe (PPCIE) mode, which
claims exclusive use of the NVSwitches for a single Confidential Container.
The NVIDIA Confidential Computing Manager for Kubernetes transitions GPUs into the correct
mode based on the ``cc.mode`` label that you set.

#. Set the ``NODE_NAME`` environment variable to the node you want to configure:

   .. code-block:: console

      $ export NODE_NAME="<node-name>"

#. Apply the ``ppcie`` CC mode label to the node:

   .. code-block:: console

      $ kubectl label node $NODE_NAME nvidia.com/cc.mode=ppcie --overwrite

Refer to :doc:`Managing the Confidential Computing Mode <configure-cc-mode>` for full details
on setting the CC mode and verifying the change.

NVIDIA Blackwell GPUs use NVLink encryption, which places the switches outside of the
Trusted Computing Base (TCB), so the default CC mode of ``on`` is sufficient and no additional
configuration is required.

Run a Multi-GPU Workload
========================

#. Create a file, such as ``multi-gpu-kata.yaml``, with a pod manifest that requests every GPU
   and NVSwitch on the node:

   .. code-block:: yaml
      :emphasize-lines: 7,14-16

      apiVersion: v1
      kind: Pod
      metadata:
        name: multi-gpu-kata
        namespace: default
      spec:
        runtimeClassName: kata-qemu-nvidia-gpu-snp # or kata-qemu-nvidia-gpu-tdx
        restartPolicy: Never
        containers:
          - name: cuda-sample
            image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0-ubuntu22.04"
            resources:
              limits:
                nvidia.com/pgpu: "8"
                nvidia.com/nvswitch: "4" # Only for NVIDIA Hopper GPUs with PPCIE mode
                memory: 128Gi

   .. note::

      If you configured ``P_GPU_ALIAS`` or ``NVSWITCH_ALIAS`` for heterogeneous clusters,
      replace ``nvidia.com/pgpu`` and ``nvidia.com/nvswitch`` with the corresponding
      model-specific resource types.
      Refer to :ref:`Reference GPU and NVSwitch Resource Types <coco-resource-types>`
      for details.

#. Create the pod:

   .. code-block:: console

      $ kubectl apply -f multi-gpu-kata.yaml

   *Example Output:*

   .. code-block:: output

      pod/multi-gpu-kata created

#. Verify the pod is running:

   .. code-block:: console

      $ kubectl get pod multi-gpu-kata

   *Example Output:*

   .. code-block:: output

      NAME             READY   STATUS    RESTARTS   AGE
      multi-gpu-kata   1/1     Running   0          30s

#. Verify that all GPUs are visible inside the container:

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

#. Delete the pod:

   .. code-block:: console

      $ kubectl delete -f multi-gpu-kata.yaml
