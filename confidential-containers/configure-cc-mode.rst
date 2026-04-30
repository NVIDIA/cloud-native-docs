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


.. _managing-confidential-computing-mode:

*****************************************
Managing the Confidential Computing Mode
*****************************************

You can set the default confidential computing mode of the NVIDIA GPUs by setting the ``ccManager.defaultMode=<on|off>`` option.
The default value of ``ccManager.defaultMode`` is ``on``.
You can set this option when you install NVIDIA GPU Operator or afterward by modifying the cluster-policy instance of the ClusterPolicy object.

When you change the mode, the manager performs the following actions:

* Evicts the other GPU Operator operands from the node.

  However, the manager does not drain user workloads. You must make sure that no user workloads are running on the node before you change the mode.

* Unbinds the GPU from the VFIO PCI device driver.
* Changes the mode and resets the GPU.
* Reschedules the other GPU Operator operands.

The supported modes are:

.. list-table::
   :widths: 15 55 30
   :header-rows: 1

   * - Mode
     - Description
     - Configuration Method
   * - ``on``
     - Enable Confidential Computing.
     - cluster-wide default, node-level override
   * - ``off``
     - Disable Confidential Computing.
     - cluster-wide default, node-level override
   * - ``ppcie``
     - Enable Confidential Computing on NVIDIA Hopper GPUs.

       On the NVIDIA Hopper architecture multi-GPU passthrough uses protected PCIe (PPCIE)
       which claims exclusive use of the NVSwitches for a single Confidential Container
       virtual machine. 
       If you are using NVIDIA Hopper GPUs for multi-GPU passthrough,
       set the GPU mode to ``ppcie`` mode. 
       
       The NVIDIA Blackwell architecture uses NVLink
       encryption which places the switches outside of the Trusted Computing Base (TCB),
       meaning the ``ppcie`` mode is not required. Use ``on`` mode in this case.
     - node-level override
     
You can set a cluster-wide default mode, and you can set the mode on individual nodes.
The mode that you set on a node has higher precedence than the cluster-wide default mode.

Setting a Cluster-Wide Default Mode
====================================

To set a cluster-wide mode, specify the ``ccManager.defaultMode`` field like the following example:

.. code-block:: console

   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
         --type=merge \
         -p '{"spec": {"ccManager": {"defaultMode": "on"}}}'

*Example Output:*

.. code-block:: output

   clusterpolicy.nvidia.com/cluster-policy patched

.. note::

   The ``ppcie`` mode cannot be set as a cluster-wide default, it can only be set as a node label value.

Setting a Node-Level Mode
==========================

To set a node-level mode, apply the ``nvidia.com/cc.mode=<on|off|ppcie>`` label on the node.

Set the ``NODE_NAME`` environment variable to the name of the node you want to configure:

.. code-block:: console

   $ export NODE_NAME="<node-name>"

Then apply the label:

.. code-block:: console

   $ kubectl label node $NODE_NAME nvidia.com/cc.mode=on --overwrite

The mode that you set on a node has higher precedence than the cluster-wide default mode.

Verifying a Mode Change
========================

To verify that a mode change was successful, view the ``nvidia.com/cc.mode``,
``nvidia.com/cc.mode.state``, and ``nvidia.com/cc.ready.state`` node labels:

.. code-block:: console

   $ kubectl get node $NODE_NAME -o json | \
       jq '.metadata.labels | with_entries(select(.key | startswith("nvidia.com/cc")))'

*Example Output (CC mode disabled):*

.. code-block:: json

   {
     "nvidia.com/cc.mode": "off",
     "nvidia.com/cc.mode.state": "off",
     "nvidia.com/cc.ready.state": "false"
   }

*Example Output (CC mode enabled):*

.. code-block:: json

   {
     "nvidia.com/cc.mode": "on",
     "nvidia.com/cc.mode.state": "on",
     "nvidia.com/cc.ready.state": "true"
   }

* The ``nvidia.com/cc.mode`` label is the desired state.

* The ``nvidia.com/cc.mode.state`` label reflects the mode that was last successfully applied to the GPU hardware by the Confidential Computing Manager. 
  Its value mirrors the applied mode ``on``, ``off``, or ``ppcie``, after the transition is complete on the node.
  A value of ``failed`` indicates that the last mode transition encountered an error.

* The ``nvidia.com/cc.ready.state`` label indicates whether the node is ready to run Confidential Container workloads. 
  It is set to ``true`` when ``cc.mode.state`` is ``on`` or ``ppcie``, and ``false`` when ``cc.mode.state`` is ``off``.

.. note::

   It can take one to two minutes for GPU state transitions to complete and the labels to be updated.
   A mode change is complete and successful when ``nvidia.com/cc.mode`` and
   ``nvidia.com/cc.mode.state`` have the same value.
