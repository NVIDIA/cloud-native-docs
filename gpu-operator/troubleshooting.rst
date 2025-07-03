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

****************************************************************
Pods stuck in Pending state in mixed MIG + full GPU environments
****************************************************************

.. rubric:: Issue
   :class: h4

For drivers 570.124.06, 570.133.20, 570.148.08, and 570.158.01,
GPU workloads cannot be scheduled on nodes that have a mix of MIG slices and full GPUs.
For more detailed information, see GitHub issue https://github.com/NVIDIA/gpu-operator/issues/1361.

.. rubric:: Observation
   :class: h4

When a GPU pod is created on a node that has a mix of MIG slices and full GPUs, 
the GPU pod gets stuck indefinitely in the ``Pending`` state. 

.. rubric:: Root Cause
   :class: h4

This is due to a regression in NVML introduced in the R570 drivers starting from 570.124.06.

.. rubric:: Action
   :class: h4

It's recommended that you downgrade to driver version 570.86.15 to work around this issue.

****************************************************
GPU Operator Validator: Failed to Create Pod Sandbox
****************************************************

.. rubric:: Issue
   :class: h4

On some occasions, the driver container is unable to unload the ``nouveau`` Linux kernel module.

.. rubric:: Observation
   :class: h4

- Running ``kubectl describe pod -n gpu-operator -l app=nvidia-operator-validator`` includes the following event:

  .. code-block:: console

     Events:
       Type     Reason                  Age                 From     Message
       ----     ------                  ----                ----     -------
       Warning  FailedCreatePodSandBox  8s (x21 over 9m2s)  kubelet  Failed to create pod sandbox: rpc error: code = Unknown desc = failed to get sandbox runtime: no runtime for "nvidia" is configured

- Running one of the following commands on the node indicates that the ``nouveau`` Linux kernel module is loaded:

  .. code-block:: console

     $ lsmod | grep -i nouveau
     $ dmesg | grep -i nouveau
     $ journalctl -xb | grep -i nouveau

.. rubric:: Root Cause
   :class: h4

The ``nouveau`` Linux kernel module is loaded and the driver container is unable to unload the module.
Because the ``nouveau`` module is loaded, the driver container cannot load the ``nvidia`` module.

.. rubric:: Action
   :class: h4

On each node, run the following commands to prevent loading the ``nouveau`` Linux kernel module on boot:

.. code-block:: console

   $ sudo tee /etc/modules-load.d/ipmi.conf <<< "ipmi_msghandler" \
       && sudo tee /etc/modprobe.d/blacklist-nouveau.conf <<< "blacklist nouveau" \
       && sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf <<< "options nouveau modeset=0"

   $ sudo update-initramfs -u

   $ sudo init 6

*************************************
No GPU Driver or Operand Pods Running
*************************************

.. rubric:: Issue
   :class: h4

On some clusters, taints are applied to nodes with a taint effect of ``NoSchedule``.

.. rubric:: Observation
   :class: h4

- Running ``kubectl get ds -n gpu-operator`` shows ``0`` for ``DESIRED``, ``CURRENT``, ``READY`` and so on.

  .. code-block:: console

     NAME                              DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                                                                                                         AGE
     gpu-feature-discovery             0         0         0       0            0           nvidia.com/gpu.deploy.gpu-feature-discovery=true                                                                      11m
     ...

.. rubric:: Root Cause
   :class: h4

The ``NoSchedule`` taint prevents the Operator from deploying the GPU Driver and other Operand pods.

.. rubric:: Action
   :class: h4

Describe each node, identify the taints, and either remove the taints from the nodes or add the taints as tolerations to the daemon sets.


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
