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

.. Date: May 11 2021
.. Author: pramarao

.. headings (h1/h2/h3/h4/h5) are # * = -

.. _install-gpu-operator-mig:

#####################
GPU Operator with MIG
#####################

.. contents::
   :depth: 2
   :local:
   :backlinks: none


************************
About Multi-Instance GPU
************************

Multi-Instance GPU (MIG) enables GPUs based on the NVIDIA Ampere and later architectures, such as NVIDIA A100, to be partitioned into separate and secure GPU instances for CUDA applications.
Refer to the `MIG User Guide <https://docs.nvidia.com/datacenter/tesla/mig-user-guide/index.html>`__ for more information about MIG.

GPU Operator deploys MIG Manager to manage MIG configuration on nodes in your Kubernetes cluster.


********************************
Enabling MIG During Installation
********************************

The following steps use the ``single`` MIG strategy.
Alternatively, you can specify the ``mixed`` strategy.

Perform the following steps to install the Operator and configure MIG:

#. Install the Operator:

   .. code-block:: console

      $ helm install --wait --generate-name \
          -n gpu-operator --create-namespace \
          nvidia/gpu-operator \
          --set mig.strategy=single

   Set ``mig.strategy`` to ``mixed`` when MIG mode is not enabled on all GPUs on a node.

   In a CSP environment such as Google Cloud, also specify
   ``--set migManager.env[0].name=WITH_REBOOT --set-string migManager.env[0].value=true``
   to ensure that the node reboots and can apply the MIG configuration.

   MIG Manager supports preinstalled drivers.
   If drivers are preinstalled, also specify ``--set driver.enabled=false``.
   Refer to :ref:`mig-with-preinstalled-drivers` for more details.

   After several minutes, all the pods, including the ``nvidia-mig-manager`` are deployed on nodes that have MIG capable GPUs.

#. Optional: Display the pods in the Operator namespace:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator

   *Example Output*

   .. literalinclude:: manifests/output/mig-get-pods.txt
      :language: output
      :emphasize-lines: 12

#. Optional: Display the labels applied to the node:

   .. code-block:: console

      $ kubectl get node -o json | jq '.items[].metadata.labels'

   *Partial Output*

   .. literalinclude:: manifests/output/mig-node-labels.json
      :language: json
      :start-after: nvidia.com/gpu.memory

   .. important::

      MIG Manager requires that no user workloads are running on the GPUs being configured.
      In some cases, the node may need to be rebooted, such as a CSP, so the node might need to be cordoned
      before changing the MIG mode or the MIG geometry on the GPUs.


************************
Configuring MIG Profiles
************************

By default, nodes are labeled with ``nvidia.com/mig.config: all-disabled`` and you must specify the MIG configuration to apply.

MIG Manager uses the ``default-mig-parted-config`` config map in the GPU Operator namespace to identify supported MIG profiles.
Refer to the config map when you label the node or customize the config map.

Example: Single MIG Strategy
============================

The following steps show how to use the single MIG strategy and configure the ``1g.10gb`` profile on one node.

#. Configure the MIG strategy to ``single`` if you are unsure of the current strategy:

   .. code-block:: console

      $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
          --type='json' \
          -p='[{"op":"replace", "path":"/spec/mig/strategy", "value":"single"}]'

#. Label the nodes with the profile to configure:

   .. code-block:: console

      $ kubectl label nodes <node-name> nvidia.com/mig.config=all-1g.10gb --overwrite

   MIG Manager proceeds to apply a ``mig.config.state`` label to the node and terminates all
   the GPU pods in preparation to enable MIG mode and configure the GPU into the desired MIG geometry.

#. Optional: Display the node labels:

   .. code-block:: console

      $ kubectl get node <node-name> -o=jsonpath='{.metadata.labels}' | jq .

   *Partial Output*

   .. code-block:: json
      :emphasize-lines: 5,6

        "nvidia.com/gpu.product": "NVIDIA-H100-80GB-HBM3",
        "nvidia.com/gpu.replicas": "1",
        "nvidia.com/gpu.sharing-strategy": "none",
        "nvidia.com/mig.capable": "true",
        "nvidia.com/mig.config": "all-1g.10gb",
        "nvidia.com/mig.config.state": "pending",
        "nvidia.com/mig.strategy": "single"
      }

   As described above, if the ``WITH_REBOOT`` option is set then MIG Manager sets the label to ``nvidia.com/mig.config.state: rebooting``.

#. Confirm that MIG Manager completed the configuration by checking the node labels:

   .. code-block:: console

      $ kubectl get node <node-name> -o=jsonpath='{.metadata.labels}' | jq .

   Check for the following labels:

   * ``nvidia.com/gpu.count: 7``, this value differs according to the GPU model.
   * ``nvidia.com/gpu.slices.ci: 1``
   * ``nvidia.com/gpu.slices.gi: 1``
   * ``nvidia.com/mig.config.state: success``

   *Partial Output*

   .. code-block:: json

     "nvidia.com/gpu.count": "7",
     "nvidia.com/gpu.present": "true",
     "nvidia.com/gpu.product": "NVIDIA-H100-80GB-HBM3-MIG-1g.10gb",
     "nvidia.com/gpu.slices.ci": "1",
     "nvidia.com/gpu.slices.gi": "1",
     "nvidia.com/mig.capable": "true",
     "nvidia.com/mig.config": "all-1g.10gb",
     "nvidia.com/mig.config.state": "success",
     "nvidia.com/mig.strategy": "single"

#. Optional: Run the ``nvidia-smi`` command in the driver container to verify that the MIG configuration:

   .. code-block:: console

      $ kubectl exec -it -n gpu-operator ds/nvidia-driver-daemonset -- nvidia-smi -L

   *Example Output*

   .. literalinclude:: manifests/output/mig-nvidia-smi.txt
      :language: output


Example: Mixed MIG Strategy
===========================

The following steps show how to use the ``mixed`` MIG strategy and configure the ``all-balanced`` profile on one node.

#. Configure the MIG strategy to ``mixed`` if you are unsure of the current strategy:

   .. code-block:: console

      $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
          --type='json' \
          -p='[{"op":"replace", "path":"/spec/mig/strategy", "value":"mixed"}]'

#. Label the nodes with the profile to configure:

   .. code-block:: console

      $ kubectl label nodes <node-name> nvidia.com/mig.config=all-balanced --overwrite

   MIG Manager proceeds to apply a ``mig.config.state`` label to the node and terminates all
   the GPU pods in preparation to enable MIG mode and configure the GPU into the desired MIG geometry.

#. Confirm that MIG Manager completed the configuration by checking the node labels:

   .. code-block:: console

      $ kubectl get node <node-name> -o=jsonpath='{.metadata.labels}' | jq .

   Check for labels like the following.
   The profiles and GPU counts differ according to the GPU model.

   * ``nvidia.com/mig-1g.10gb.count: 2``
   * ``nvidia.com/mig-2g.20gb.count: 1``
   * ``nvidia.com/mig-3g.40gb.count: 1``
   * ``nvidia.com/mig.config.state: success``

   *Partial Output*

   .. literalinclude:: manifests/output/mig-mixed-node-labels.json
      :language: json
      :start-after: nvidia.com/gpu.memory

#. Optional: Run the ``nvidia-smi`` command in the driver container to verify that the GPU has been configured:

   .. code-block:: console

      $ kubectl exec -it -n gpu-operator ds/nvidia-driver-daemonset -- nvidia-smi -L

   *Example Output*

   .. literalinclude:: manifests/output/mig-mixed-nvidia-smi.txt
      :language: output


Example: Reconfiguring MIG Profiles
===================================

MIG Manager supports dynamic reconfiguration of the MIG geometry.
The following steps show how to update a GPU on a node to the ``3g.40gb`` profile with the single MIG strategy.

#. Label the node with the profile:

   .. code-block:: console

      $ kubectl label nodes <node-name> nvidia.com/mig.config=all-3g.40gb --overwrite

#. Optional: Monitor the MIG Manager logs to confirm the new MIG geometry is applied:

   .. code-block:: console

      $ kubectl logs -n gpu-operator -l app=nvidia-mig-manager -c nvidia-mig-manager

   *Example Output*

   .. code-block:: console

      Applying the selected MIG config to the node
      time="2024-05-14T18:31:26Z" level=debug msg="Parsing config file..."
      time="2024-05-14T18:31:26Z" level=debug msg="Selecting specific MIG config..."
      time="2024-05-14T18:31:26Z" level=debug msg="Running apply-start hook"
      time="2024-05-14T18:31:26Z" level=debug msg="Checking current MIG mode..."
      time="2024-05-14T18:31:26Z" level=debug msg="Walking MigConfig for (devices=all)"
      time="2024-05-14T18:31:26Z" level=debug msg="  GPU 0: 0x233010DE"
      time="2024-05-14T18:31:26Z" level=debug msg="    Asserting MIG mode: Enabled"
      time="2024-05-14T18:31:26Z" level=debug msg="    MIG capable: true\n"
      time="2024-05-14T18:31:26Z" level=debug msg="    Current MIG mode: Enabled"
      time="2024-05-14T18:31:26Z" level=debug msg="Checking current MIG device configuration..."
      time="2024-05-14T18:31:26Z" level=debug msg="Walking MigConfig for (devices=all)"
      time="2024-05-14T18:31:26Z" level=debug msg="  GPU 0: 0x233010DE"
      time="2024-05-14T18:31:26Z" level=debug msg="    Asserting MIG config: map[3g.40gb:2]"
      time="2024-05-14T18:31:26Z" level=debug msg="Running pre-apply-config hook"
      time="2024-05-14T18:31:26Z" level=debug msg="Applying MIG device configuration..."
      time="2024-05-14T18:31:26Z" level=debug msg="Walking MigConfig for (devices=all)"
      time="2024-05-14T18:31:26Z" level=debug msg="  GPU 0: 0x233010DE"
      time="2024-05-14T18:31:26Z" level=debug msg="    MIG capable: true\n"
      time="2024-05-14T18:31:26Z" level=debug msg="    Updating MIG config: map[3g.40gb:2]"
      MIG configuration applied successfully
      time="2024-05-14T18:31:27Z" level=debug msg="Running apply-exit hook"
      Restarting validator pod to re-run all validations
      pod "nvidia-operator-validator-kmncw" deleted
      Restarting all GPU clients previously shutdown in Kubernetes by reenabling their component-specific nodeSelector labels
      node/node-name labeled
      Changing the 'nvidia.com/mig.config.state' node label to 'success'

#. Optional: Display the node labels to confirm the GPU count (``2``), slices (``3``), and profile are set:

   .. code-block:: console

      $ kubectl get node <node-name> -o=jsonpath='{.metadata.labels}' | jq .

   *Partial Output*

   .. code-block:: json

        "nvidia.com/gpu.count": "2",
        "nvidia.com/gpu.present": "true",
        "nvidia.com/gpu.product": "NVIDIA-H100-80GB-HBM3-MIG-3g.40gb",
        "nvidia.com/gpu.replicas": "1",
        "nvidia.com/gpu.sharing-strategy": "none",
        "nvidia.com/gpu.slices.ci": "3",
        "nvidia.com/gpu.slices.gi": "3",
        "nvidia.com/mig.capable": "true",
        "nvidia.com/mig.config": "all-3g.40gb",
        "nvidia.com/mig.config.state": "success",
        "nvidia.com/mig.strategy": "single",
        "nvidia.com/mps.capable": "false"
      }


Example: Custom MIG Configuration During Installation
=====================================================

By default, the Operator creates the ``default-mig-parted-config`` config map and MIG Manager is configured to read profiles from that config map.

You can use the ``values.yaml`` file when you install or upgrade the Operator to create a config map with a custom configuration.

#. In your ``values.yaml`` file, add the data for the config map, like the following example:

   .. literalinclude:: manifests/input/mig-cm-values.yaml
      :language: yaml

#. If the custom configuration specifies more than one instance profile, set the strategy to ``mixed``:

   .. code-block:: console

      $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
          --type='json' \
          -p='[{"op":"replace", "path":"/spec/mig/strategy", "value":"mixed"}]'

#. Label the nodes with the profile to configure:

   .. code-block:: console

      $ kubectl label nodes <node-name> nvidia.com/mig.config=custom-mig --overwrite


Example: Custom MIG Configuration
=================================

By default, the Operator creates the ``default-mig-parted-config`` config map and MIG Manager is configured to read profiles from that config map.

You can create a config map with a custom configuration if the default profiles do not meet your business needs.

#. Create a file, such as ``custom-mig-config.yaml``, with contents like the following example:

   .. literalinclude:: manifests/input/custom-mig-config.yaml
      :language: yaml

#. Apply the manifest:

   .. code-block:: console

      $ kubectl apply -n gpu-operator -f custom-mig-config.yaml

#. If the custom configuration specifies more than one instance profile, set the strategy to ``mixed``:

   .. code-block:: console

      $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
          --type='json' \
          -p='[{"op":"replace", "path":"/spec/mig/strategy", "value":"mixed"}]'

#. Patch the cluster policy so MIG Manager uses the custom config map:

   .. code-block:: console

      $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
          --type='json' \
          -p='[{"op":"replace", "path":"/spec/migManager/config/name", "value":"custom-mig-config"}]'

#. Label the nodes with the profile to configure:

   .. code-block:: console

      $ kubectl label nodes <node-name> nvidia.com/mig.config=five-1g-one-2g --overwrite

#. Optional: Monitor the MIG Manager logs to confirm the new MIG geometry is applied:

   .. code-block:: console

      $ kubectl logs -n gpu-operator -l app=nvidia-mig-manager -c nvidia-mig-manager

   *Example Output*

   .. code-block:: console

      Applying the selected MIG config to the node
      time="2024-05-15T13:40:08Z" level=debug msg="Parsing config file..."
      time="2024-05-15T13:40:08Z" level=debug msg="Selecting specific MIG config..."
      time="2024-05-15T13:40:08Z" level=debug msg="Running apply-start hook"
      time="2024-05-15T13:40:08Z" level=debug msg="Checking current MIG mode..."
      time="2024-05-15T13:40:08Z" level=debug msg="Walking MigConfig for (devices=all)"
      time="2024-05-15T13:40:08Z" level=debug msg="  GPU 0: 0x233010DE"
      time="2024-05-15T13:40:08Z" level=debug msg="    Asserting MIG mode: Enabled"
      time="2024-05-15T13:40:08Z" level=debug msg="    MIG capable: true\n"
      time="2024-05-15T13:40:08Z" level=debug msg="    Current MIG mode: Enabled"
      time="2024-05-15T13:40:08Z" level=debug msg="Checking current MIG device configuration..."
      time="2024-05-15T13:40:08Z" level=debug msg="Walking MigConfig for (devices=all)"
      time="2024-05-15T13:40:08Z" level=debug msg="  GPU 0: 0x233010DE"
      time="2024-05-15T13:40:08Z" level=debug msg="    Asserting MIG config: map[1g.10gb:5 2g.20gb:1]"
      time="2024-05-15T13:40:08Z" level=debug msg="Running pre-apply-config hook"
      time="2024-05-15T13:40:08Z" level=debug msg="Applying MIG device configuration..."
      time="2024-05-15T13:40:08Z" level=debug msg="Walking MigConfig for (devices=all)"
      time="2024-05-15T13:40:08Z" level=debug msg="  GPU 0: 0x233010DE"
      time="2024-05-15T13:40:08Z" level=debug msg="    MIG capable: true\n"
      time="2024-05-15T13:40:08Z" level=debug msg="    Updating MIG config: map[1g.10gb:5 2g.20gb:1]"
      time="2024-05-15T13:40:09Z" level=debug msg="Running apply-exit hook"
      MIG configuration applied successfully


*******************************************
Verification: Running Sample CUDA Workloads
*******************************************

.. include:: ../mig/mig-examples.rst
   :start-line: 11


*************
Disabling MIG
*************

You can disable MIG on a node by setting the ``nvidia.con/mig.config`` label to ``all-disabled``:
.. code-block:: console

   $ kubectl label nodes <node-name> nvidia.com/mig.config=all-disabled --overwrite


.. _mig-with-preinstalled-drivers:

**************************************
MIG Manager with Preinstalled Drivers
**************************************

MIG Manager supports preinstalled drivers.
Information in the preceding sections still applies, however there are a few additional details to consider.


Install
=======

During GPU Operator installation, ``driver.enabled=false`` must be set. The following options
can be used to install the GPU Operator:

.. code-block:: console

    $ helm install gpu-operator \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set driver.enabled=false


Managing Host GPU Clients
=========================

MIG Manager stops all operator-managed pods that have access to GPUs when applying a MIG reconfiguration.
When drivers are preinstalled, there may be GPU clients on the host that also need to be stopped.

When drivers are preinstalled, MIG Manager attempts to stop and restart a list of systemd services on the host across a MIG reconfiguration.
The list of services are specified in the ``default-gpu-clients`` config map.

The following sample GPU clients file, ``clients.yaml``, is used to create the ``default-gpu-clients`` config map:

.. code-block:: yaml

    version: v1
    systemd-services:
      - nvsm.service
      - nvsm-mqtt.service
      - nvsm-core.service
      - nvsm-api-gateway.service
      - nvsm-notifier.service
      - nv_peer_mem.service
      - nvidia-dcgm.service
      - dcgm.service
      - dcgm-exporter.service

You can modify the list by editing the config map after installation.
Alternatively, you can create a custom config map for use by MIG Manager by performing the following steps:

#. Create the ``gpu-operator`` namespace:

   .. code-block:: console

      $ kubectl create namespace gpu-operator

#. Create a ``ConfigMap`` containing the custom `clients.yaml` file with a list of GPU clients:

   .. code-block:: console

      $ kubectl create configmap -n gpu-operator gpu-clients --from-file=clients.yaml

#. Install the GPU Operator:

   .. code-block:: console

     $ helm install gpu-operator \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --set migManager.gpuClientsConfig.name=gpu-clients
         --set driver.enabled=false

*****************
Architecture
*****************

MIG Manager is designed as a controller within Kubernetes. It watches for changes to the
``nvidia.com/mig.config`` label on the node and then applies the user-requested MIG configuration
When the label changes, MIG Manager first stops all GPU pods, including device plugin, GPU feature discovery,
and DCGM exporter.
MIG Manager then stops all host GPU clients listed in the ``clients.yaml`` config map if drivers are preinstalled.
Finally, it applies the MIG reconfiguration and restarts the GPU pods and possibly, host GPU clients.
The MIG reconfiguration can also involve rebooting a node if a reboot is required to enable MIG mode.

The default MIG profiles are specified in the ``default-mig-parted-config`` config map.
You can specify one of these profiles to apply to the ``mig.config`` label to trigger a reconfiguration of the MIG geometry.

MIG Manager uses the `mig-parted <https://github.com/NVIDIA/mig-parted>`__ tool to apply the configuration
changes to the GPU, including enabling MIG mode, with a node reboot as required by some scenarios.

.. mermaid::

   flowchart

   subgraph mig[MIG Manager]
     direction TB
     A[Controller] <--> B[MIG-Parted]
   end

   A -- on change --> C

   subgraph recon[Reconfiguration]
     C["Config is Pending
        or Rebooting"]
     -->
     D["Stop Operator Pods"]
     -->
     E["Enable MIG Mode and
        Reboot if Required"]
     -->
     F["Use mig-parted to
        Configure MIG Geometry"]
     -->
     G["Restart Operator Pods"]
   end

   H["Set mig.config label
      to Success"]
   I["Set mig.config label
      to Failed"]

   G --> H
   G -- on failure --> I
