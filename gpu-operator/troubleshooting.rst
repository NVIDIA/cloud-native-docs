.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
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

.. headings (h1/h2/h3/h4/h5) are # * = -

#######################################
Troubleshooting the NVIDIA GPU Operator
#######################################

*************************************
GPU Operator Pods Stuck in Crash Loop
*************************************

.. rubric:: Issue
   :class: h4

On large clusters, such as 300 or more nodes, the GPU Operator pods
can get stuck in a crash loop.

.. rubric:: Observation
   :class: h4

- The GPU Operator pod is not running:

  .. code-block:: console

     $ kubectl get pod -n gpu-operator -l app=gpu-operator

  *Example Output*

  .. code-block:: output

     NAME                            READY   STATUS             RESTARTS      AGE
     gpu-operator-568c7ff7f6-chg5b   0/1     CrashLoopBackOff   4 (85s ago)   4m42s

- The node that is running the GPU Operator pod has sufficient resources and the node is ``Ready``:

  .. code-block:: console

     $ kubectl describe node <node-name>

  *Example Output*

  .. code-block:: output

     Conditions:
       Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
       ----                 ------  -----------------                 ------------------                ------                       -------
       MemoryPressure       False   Tue, 26 Dec 2023 14:01:31 +0000   Tue, 12 Dec 2023 19:47:47 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
       DiskPressure         False   Tue, 26 Dec 2023 14:01:31 +0000   Thu, 14 Dec 2023 19:15:03 +0000   KubeletHasNoDiskPressure     kubelet has no disk pressure
       PIDPressure          False   Tue, 26 Dec 2023 14:01:31 +0000   Tue, 12 Dec 2023 19:47:47 +0000   KubeletHasSufficientPID      kubelet has sufficient PID available
       Ready                True    Tue, 26 Dec 2023 14:01:31 +0000   Thu, 14 Dec 2023 19:15:13 +0000   KubeletReady                 kubelet is posting ready status

- The logs from the pod include a fatal error:

  .. code-block:: console

     $ kubectl logs -n gpu-operator -l app=gpu-operator

  *Partial Output*

  .. code-block:: output
     :emphasize-lines: 1

     fatal error: concurrent map read and map write

     goroutine 676 [running]:
     k8s.io/apimachinery/pkg/runtime.(*Scheme).ObjectKinds(0xc0001fc000, {0x1ea20f0?, 0xc0008b4770})
	     /workspace/vendor/k8s.io/apimachinery/pkg/runtime/scheme.go:264 +0xce
     sigs.k8s.io/controller-runtime/pkg/client/apiutil.GVKForObject({0x1ea20f0?, 0xc0008b4770}, 0xc00133d4e0?)
	     /workspace/vendor/sigs.k8s.io/controller-runtime/pkg/client/apiutil/apimachinery.go:98 +0x245
     sigs.k8s.io/controller-runtime/pkg/cache.(*informerCache).objectTypeForListObject(0xc0000123c0, {0x1ebe020?, 0xc0008b4770})
	     /workspace/vendor/sigs.k8s.io/controller-runtime/pkg/cache/informer_cache.go:94 +0x87
     sigs.k8s.io/controller-runtime/pkg/cache.(*informerCache).List(0xc0000123c0, {0x1eb5ca8, 0xc000618cd0}, {0x1ebe020, 0xc0008b4770}, {0x2c7cf70, 0x0, 0x0})
	     /workspace/vendor/sigs.k8s.io/controller-runtime/pkg/cache/informer_cache.go:73 +0x71
     sigs.k8s.io/controller-runtime/pkg/client.(*delegatingReader).List(0xc000c4b480, {0x1eb5ca8, 0xc000618cd0}, {0x1ebe020?, 0xc0008b4770?}, {0x2c7cf70, 0x0, 0x0})
	     /workspace/vendor/sigs.k8s.io/controller-runtime/pkg/client/split.go:140 +0x114
     github.com/NVIDIA/gpu-operator/controllers.addWatchNewGPUNode.func1({0x199a6a0?, 0xc002873b30?})
	     /workspace/controllers/clusterpolicy_controller.go:228 +0x9a
     sigs.k8s.io/controller-runtime/pkg/handler.(*enqueueRequestsFromMapFunc).mapAndEnqueue(0x44?, {0x1ebf938, 0xc000158660}, {0x1ecc6c0?, 0xc001c04fc0?}, 0xa8?)
	     /workspace/vendor/sigs.k8s.io/controller-runtime/pkg/handler/enqueue_mapped.go:80 +0x46
     sigs.k8s.io/controller-runtime/pkg/handler.(*enqueueRequestsFromMapFunc).Create(0xc000095900?, {{0x1ecc6c0?, 0xc001c04fc0?}}, {0x1ebf938, 0xc000158660})
	     /workspace/vendor/sigs.k8s.io/controller-runtime/pkg/handler/enqueue_mapped.go:57 +0xd2
     sigs.k8s.io/controller-runtime/pkg/source/internal.EventHandler.OnAdd({{0x1eb66b8, 0xc000012498}, {0x1ebf938, 0xc000158660}, {0xc000b891f0, 0x1, 0x1}}, {0x1bea560?, 0xc001c04fc0})
	     /workspace/vendor/sigs.k8s.io/controller-runtime/pkg/source/internal/eventsource.go:63 +0x295
     k8s.io/client-go/tools/cache.(*processorListener).run.func1()
	     /workspace/vendor/k8s.io/client-go/tools/cache/shared_informer.go:818 +0x134
     k8s.io/apimachinery/pkg/util/wait.BackoffUntil.func1(0x30?)
	     /workspace/vendor/k8s.io/apimachinery/pkg/util/wait/wait.go:157 +0x3e
     k8s.io/apimachinery/pkg/util/wait.BackoffUntil(0xc0006fc738?, {0x1e9eae0, 0xc0014c48a0}, 0x1, 0xc000b1a540)
	     /workspace/vendor/k8s.io/apimachinery/pkg/util/wait/wait.go:158 +0xb6
     k8s.io/apimachinery/pkg/util/wait.JitterUntil(0x1ebcb18?, 0x3b9aca00, 0x0, 0x51?, 0xc0006fc7b0?)
	     /workspace/vendor/k8s.io/apimachinery/pkg/util/wait/wait.go:135 +0x89
     k8s.io/apimachinery/pkg/util/wait.Until(...)
	     /workspace/vendor/k8s.io/apimachinery/pkg/util/wait/wait.go:92
     k8s.io/client-go/tools/cache.(*processorListener).run(0xc000766f80)
	     /workspace/vendor/k8s.io/client-go/tools/cache/shared_informer.go:812 +0x6b
     k8s.io/apimachinery/pkg/util/wait.(*Group).Start.func1()
	     /workspace/vendor/k8s.io/apimachinery/pkg/util/wait/wait.go:75 +0x5a
     created by k8s.io/apimachinery/pkg/util/wait.(*Group).Start
	/workspace/vendor/k8s.io/apimachinery/pkg/util/wait/wait.go:73 +0x85



.. rubric:: Root Cause
   :class: h4

The memory resource limit for the GPU Operator is too low for the cluster size.

.. rubric:: Action
   :class: h4

Increase the memory request and limit for the GPU Operator pod:

- Set the memory request to a value that matches the average memory consumption over an large time window.
- Set the memory limit to match the spikes in memory consumption that occur occasionally.

#. Increase the memory resource limit for the GPU Operator pod:

   .. code-block:: console

      $ kubectl patch deployment gpu-operator -n gpu-operator --type='json' \
          -p='[{"op":"replace", "path":"/spec/template/spec/containers/0/resources/limits/memory", "value":"1400Mi"}]'

#. Optional: Increase the memory resource request for the pod:

   .. code-block:: console

      $ kubectl patch deployment gpu-operator -n gpu-operator --type='json' \
          -p='[{"op":"replace", "path":"/spec/template/spec/containers/0/resources/requests/memory", "value":"600Mi"}]'

Monitor the GPU Operator pod.
Increase the memory request and limit again if the pod remains stuck in a crash loop.


************************************************
infoROM is corrupted (nvidia-smi return code 14)
************************************************


.. rubric:: Issue
   :class: h4

The nvidia-operator-validator pod fails and nvidia-driver-daemonsets fails as well.


.. rubric:: Observation
   :class: h4


The output from the driver validation container indicates that the infoROM is corrupt:

.. code-block:: console

   $ kubectl logs -n gpu-operator nvidia-operator-validator-xxxxx -c driver-validation

*Example Output*

.. code-block:: output

        | NVIDIA-SMI 470.82.01    Driver Version: 470.82.01    CUDA Version: 11.4     |
        |-------------------------------+----------------------+----------------------+
        | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
        | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
        |                               |                      |               MIG M. |
        |===============================+======================+======================|
        |   0  Tesla P100-PCIE...  On   | 00000000:0B:00.0 Off |                    0 |
        | N/A   42C    P0    29W / 250W |      0MiB / 16280MiB |      0%      Default |
        |                               |                      |                  N/A |
        +-------------------------------+----------------------+----------------------+
                                                                                    
        +-----------------------------------------------------------------------------+
        | Processes:                                                                  |
        |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
        |        ID   ID                                                   Usage      |
        |=============================================================================|
        |  No running processes found                                                 |
        +-----------------------------------------------------------------------------+
        WARNING: infoROM is corrupted at gpu 0000:0B:00.0
        14

The GPU emits some warning messages related to infoROM.
The return values for the ``nvidia-smi`` command are listed below.

.. code-block:: console

        RETURN VALUE

        Return code reflects whether the operation succeeded or failed and what
        was the reason of failure.

        Â·      Return code 0 - Success

        Â·      Return code 2 - A supplied argument or flag is invalid
        Â·      Return code 3 - The requested operation is not available on target device
        Â·      Return code 4 - The current user does  not  have permission  to access this device or perform this operation
        Â·      Return code 6 - A query to find an object was unsuccessful
        Â·      Return code 8 - A device's external power cables are not properly attached
        Â·      Return code 9 - NVIDIA driver is not loaded
        Â·      Return code 10 - NVIDIA Kernel detected an interrupt issue  with a GPU
        Â·      Return code 12 - NVML Shared Library couldn't be found or loaded
        Â·      Return code 13 - Local version of NVML  doesn't  implement  this function
        Â·      Return code 14 - infoROM is corrupted
        Â·      Return code 15 - The GPU has fallen off the bus or has otherwise become inaccessible
        Â·      Return code 255 - Other error or internal driver error occurred


.. rubric:: Root Cause
   :class: h4

The ``nvidi-smi`` command should return a success code (return code 0) for the driver-validator container to pass and GPU operator to successfully deploy driver pod on the node.

.. rubric:: Action
   :class: h4

Replace the faulty GPU.


*********************
EFI + Secure Boot
*********************


.. rubric:: Issue
   :class: h4

GPU Driver pod fails to deploy.

.. rubric:: Root Cause
   :class: h4

EFI Secure Boot is currently not supported with GPU Operator

.. rubric:: Action
   :class: h4

Disable EFI Secure Boot on the server.
