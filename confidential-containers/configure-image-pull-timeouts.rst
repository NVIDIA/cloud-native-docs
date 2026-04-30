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


.. _configure-image-pull-timeouts:

*****************************
Configure Image Pull Timeouts
*****************************

The guest-pull mechanism pulls images inside the confidential VM, which means large images can take longer to download and delay container start.
Kubelet can de-allocate your pod if the image pull exceeds the configured timeout before the container transitions to the running state.

The timeout chain has three components that you might need to configure:

* **Kubelet** ``runtimeRequestTimeout``: Controls how long kubelet waits for the container runtime to respond. Default: ``2m``.
* **Kata shim** ``create_container_timeout``: Controls how long the NVIDIA shim allows a container to remain in container creating state. Default: ``1200s`` (20 minutes).
* **Kata Agent** ``image_pull_timeout``: Controls the agent-side timeout for guest-image pull. Default: ``1200s`` (20 minutes).

Configure the Kubelet Timeout
==============================

Configure your cluster's ``runtimeRequestTimeout`` in your `kubelet configuration <https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/>`_ with a higher timeout value than the two-minute default.
Set this value to ``20m`` to match the default values for the NVIDIA shim configurations in Kata Containers.

Add or update the ``runtimeRequestTimeout`` field in your kubelet configuration (typically ``/var/lib/kubelet/config.yaml``):

.. code-block:: yaml
   :emphasize-lines: 3

   apiVersion: kubelet.config.k8s.io/v1beta1
   kind: KubeletConfiguration
   runtimeRequestTimeout: 20m

Restart the kubelet service to apply the change:

.. code-block:: console

   $ sudo systemctl restart kubelet

Configure Timeouts Beyond 20 Minutes
======================================

If you need a timeout of more than 1200 seconds (20 minutes), you must also adjust the Kata Agent Policy's ``image_pull_timeout`` value.

You can set this value either through a pod annotation or by modifying the shim configuration.

Using a Pod Annotation
-----------------------

Add the ``io.katacontainers.config.hypervisor.kernel_params`` annotation to your pod manifest with the desired ``agent.image_pull_timeout`` value in seconds:

.. code-block:: yaml
   :emphasize-lines: 7

   apiVersion: v1
   kind: Pod
   metadata:
     name: large-model-kata
     namespace: default
     annotations:
       io.katacontainers.config.hypervisor.kernel_params: "agent.image_pull_timeout=1800"
   spec:
     runtimeClassName: kata-qemu-nvidia-gpu-snp
     restartPolicy: Never
     containers:
       - name: model-server
         image: "nvcr.io/nvidia/example-large-model:latest"
         resources:
           limits:
             nvidia.com/pgpu: "1"
             memory: 64Gi

In this example, ``agent.image_pull_timeout=1800`` sets the agent-side timeout to 30 minutes (1800 seconds).

Using the Shim Configuration
-----------------------------

To set the timeout globally, add the ``agent.image_pull_timeout`` kernel parameter to your Kata shim configuration file.
The shim configuration files are located in ``/opt/kata/share/defaults/kata-containers/`` on the worker nodes.

Add the parameter to the ``kernel_params`` field in the ``[hypervisor.qemu]`` section:

.. code-block:: toml
   :emphasize-lines: 2

   [hypervisor.qemu]
   kernel_params = "agent.image_pull_timeout=1800"

.. note::

   When setting timeouts beyond 20 minutes, ensure that all three timeout values in the chain are consistent:
   the kubelet ``runtimeRequestTimeout``, the Kata shim ``create_container_timeout``, and the
   agent ``image_pull_timeout`` should all be set to accommodate the expected image pull duration.
