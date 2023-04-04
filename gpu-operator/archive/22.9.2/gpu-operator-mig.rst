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

.. _install-gpu-operator-22.9.2-mig:

#######################
GPU Operator with MIG
#######################

.. contents::
   :depth: 2
   :local:
   :backlinks: none


************************
About Multi-Instance GPU
************************

Multi-Instance GPU (MIG) allows GPUs based on the NVIDIA Ampere architecture
(such as NVIDIA A100) to be securely partitioned into separate GPU Instances for
CUDA applications. Refer to the
`MIG User Guide <https://docs.nvidia.com/datacenter/tesla/mig-user-guide/index.html>`_
for more details on MIG.

This documents provides an overview of how to use the GPU Operator with nodes that support
MIG.


********************************
Enabling MIG During Installation
********************************

In this example workflow, we start with a MIG strategy of ``single``. The ``mixed`` strategy can also be
specified and used in a similar manner.

.. note::

    In a CSP IaaS environment such as Google Cloud, ensure that the ``mig-manager`` variable
    ``WITH_REBOOT`` is set to "true".
    Refer to the `note <https://docs.nvidia.com/datacenter/tesla/mig-user-guide/index.html#enable-mig-mode>`_
    in the MIG User Guide for more information on the constraints with enabling MIG mode.

We can use the following option to install the GPU Operator:

.. code-block:: console

    $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set mig.strategy=single

.. note::

   ``mig.strategy`` should be set to ``mixed`` when MIG mode is not enabled on all GPUs on a node.

.. note::

   Starting with v1.9, MIG Manager supports preinstalled drivers. If drivers are preinstalled, use
   an additional option during installation ``--set driver.enabled=false``. See :ref:`mig-with-preinstalled-drivers-22.9.2`
   for more details.

At this point, all the pods, including the ``nvidia-mig-manager`` will be deployed on nodes that have MIG capable GPUs:

.. code-block:: console

    $ kubectl get pods -n gpu-operator

.. code-block:: console

    NAME                                                          READY   STATUS      RESTARTS   AGE
    gpu-operator-d6ccd4d8d-9cgzr                                  1/1     Running     2          6m58s
    gpu-operator-node-feature-discovery-master-867c4f7bfb-4nlq7   1/1     Running     0          6m58s
    gpu-operator-node-feature-discovery-worker-6rvr2              1/1     Running     1          6m58s
    gpu-feature-discovery-sclxr                                   1/1     Running     0          6m39s
    nvidia-container-toolkit-daemonset-tnh82                      1/1     Running     0          6m39s
    nvidia-cuda-validator-qt6wq                                   0/1     Completed   0          3m11s
    nvidia-dcgm-exporter-dh46q                                    1/1     Running     0          6m39s
    nvidia-device-plugin-daemonset-t6qkz                          1/1     Running     0          6m39s
    nvidia-device-plugin-validator-sd5f7                          0/1     Completed   0          105s
    nvidia-driver-daemonset-f7ktr                                 1/1     Running     0          6m40s
    nvidia-mig-manager-gzg8n                                      1/1     Running     0          79s
    nvidia-operator-validator-vsccj                               1/1     Running     0          6m39s

You can also check the labels applied to the node:

.. code-block:: console

    $ kubectl get node -o json | jq '.items[].metadata.labels'

.. code-block:: console

    "nvidia.com/cuda.driver.major": "460",
    "nvidia.com/cuda.driver.minor": "73",
    "nvidia.com/cuda.driver.rev": "01",
    "nvidia.com/cuda.runtime.major": "11",
    "nvidia.com/cuda.runtime.minor": "2",
    "nvidia.com/gfd.timestamp": "1621375725",
    "nvidia.com/gpu.compute.major": "8",
    "nvidia.com/gpu.compute.minor": "0",
    "nvidia.com/gpu.count": "1",
    "nvidia.com/gpu.deploy.container-toolkit": "true",
    "nvidia.com/gpu.deploy.dcgm-exporter": "true",
    "nvidia.com/gpu.deploy.device-plugin": "true",
    "nvidia.com/gpu.deploy.driver": "true",
    "nvidia.com/gpu.deploy.gpu-feature-discovery": "true",
    "nvidia.com/gpu.deploy.mig-manager": "true",
    "nvidia.com/gpu.deploy.operator-validator": "true",
    "nvidia.com/gpu.family": "ampere",
    "nvidia.com/gpu.machine": "Google-Compute-Engine",
    "nvidia.com/gpu.memory": "40536",
    "nvidia.com/gpu.present": "true",
    "nvidia.com/gpu.product": "A100-SXM4-40GB",
    "nvidia.com/mig.strategy": "single"

.. warning::

    The MIG Manager currently requires that all user workloads on the GPUs being configured be stopped.
    In some cases, the node may need to be rebooted (esp. in CSP IaaS), so the node may need to be cordoned
    before changing the MIG mode or the MIG geometry on the GPUs.

    This requirement may be relaxed in future releases.


************************
Configuring MIG Profiles
************************

Now, let's configure the GPU into a supported by setting the ``mig.config`` label on the
GPU node.

.. note::

    The ``mig-manager`` uses a `ConfigMap` called ``mig-parted-config`` in the GPU Operator
    namespace in the daemonset to include supported MIG profiles. Refer to the `ConfigMap` to use when
    changing the label below or modify the `ConfigMap` appropriately for your use-case.

In this example, we use the ``1g.5gb`` profile:

.. code-block:: console

    $ kubectl label nodes $NODE nvidia.com/mig.config=all-1g.5gb

The MIG manager will proceed to apply a ``mig.config.state`` label to the GPU and then terminate all
the GPU pods in preparation to enable MIG mode and configure the GPU into the desired MIG geometry:

.. code-block:: console

    "nvidia.com/mig.config": "all-1g.5gb",
    "nvidia.com/mig.config.state": "pending"

.. code-block:: console

    kube-system              kube-scheduler-a100-mig-k8s                                   1/1     Running       1          45m
    gpu-operator             nvidia-dcgm-exporter-dh46q                                    1/1     Terminating   0          13m
    gpu-operator             gpu-feature-discovery-sclxr                                   1/1     Terminating   0          13m
    gpu-operator             nvidia-device-plugin-daemonset-t6qkz                          1/1     Terminating   0          13m

.. note::

    As described above, if the ``WITH_REBOOT`` option is set then the MIG manager will proceed to reboot the node:

    .. code-block:: console

        "nvidia.com/mig.config": "all-1g.5gb",
        "nvidia.com/mig.config.state": "rebooting"

Once the MIG manager has completed applying the configuration changes (including a node reboot if required), the node
labels should appear as shown below:

.. code-block:: console

    "nvidia.com/cuda.driver.major": "460",
    "nvidia.com/cuda.driver.minor": "73",
    "nvidia.com/cuda.driver.rev": "01",
    "nvidia.com/cuda.runtime.major": "11",
    "nvidia.com/cuda.runtime.minor": "2",
    "nvidia.com/gfd.timestamp": "1621442537",
    "nvidia.com/gpu.compute.major": "8",
    "nvidia.com/gpu.compute.minor": "0",
    "nvidia.com/gpu.count": "7",
    "nvidia.com/gpu.deploy.container-toolkit": "true",
    "nvidia.com/gpu.deploy.dcgm-exporter": "true",
    "nvidia.com/gpu.deploy.device-plugin": "true",
    "nvidia.com/gpu.deploy.driver": "true",
    "nvidia.com/gpu.deploy.gpu-feature-discovery": "true",
    "nvidia.com/gpu.deploy.mig-manager": "true",
    "nvidia.com/gpu.deploy.operator-validator": "true",
    "nvidia.com/gpu.engines.copy": "1",
    "nvidia.com/gpu.engines.decoder": "0",
    "nvidia.com/gpu.engines.encoder": "0",
    "nvidia.com/gpu.engines.jpeg": "0",
    "nvidia.com/gpu.engines.ofa": "0",
    "nvidia.com/gpu.family": "ampere",
    "nvidia.com/gpu.machine": "Google-Compute-Engine",
    "nvidia.com/gpu.memory": "4864",
    "nvidia.com/gpu.multiprocessors": "14",
    "nvidia.com/gpu.present": "true",
    "nvidia.com/gpu.product": "A100-SXM4-40GB-MIG-1g.5gb",
    "nvidia.com/gpu.slices.ci": "1",
    "nvidia.com/gpu.slices.gi": "1",
    "nvidia.com/mig.config": "all-1g.5gb",
    "nvidia.com/mig.config.state": "success",
    "nvidia.com/mig.strategy": "single"

The labels ``gpu.count`` and ``gpu.slices`` indicate that the devices are configured. We can also run ``nvidia-smi``
in the driver container to verify that the GPU has been configured:

.. code-block:: console

    $ sudo docker exec 629b93e200d9eea35be35a1b30991d007e48497d52a38e18a472945e44e52a8e nvidia-smi -L
    GPU 0: A100-SXM4-40GB (UUID: GPU-5c89852c-d268-c3f3-1b07-005d5ae1dc3f)
      MIG 1g.5gb Device 0: (UUID: MIG-GPU-5c89852c-d268-c3f3-1b07-005d5ae1dc3f/7/0)
      MIG 1g.5gb Device 1: (UUID: MIG-GPU-5c89852c-d268-c3f3-1b07-005d5ae1dc3f/8/0)
      MIG 1g.5gb Device 2: (UUID: MIG-GPU-5c89852c-d268-c3f3-1b07-005d5ae1dc3f/9/0)
      MIG 1g.5gb Device 3: (UUID: MIG-GPU-5c89852c-d268-c3f3-1b07-005d5ae1dc3f/11/0)
      MIG 1g.5gb Device 4: (UUID: MIG-GPU-5c89852c-d268-c3f3-1b07-005d5ae1dc3f/12/0)
      MIG 1g.5gb Device 5: (UUID: MIG-GPU-5c89852c-d268-c3f3-1b07-005d5ae1dc3f/13/0)
      MIG 1g.5gb Device 6: (UUID: MIG-GPU-5c89852c-d268-c3f3-1b07-005d5ae1dc3f/14/0)

Finally, verify that the GPU Operator pods are in running state:


.. code-block:: console

    NAME                                                          READY   STATUS      RESTARTS   AGE
    gpu-operator-d6ccd4d8d-hhhq4                                  1/1     Running     4          38m
    gpu-operator-node-feature-discovery-master-867c4f7bfb-jt95x   1/1     Running     1          38m
    gpu-operator-node-feature-discovery-worker-rjpfb              1/1     Running     3          38m
    gpu-feature-discovery-drzft                                   1/1     Running     0          97s
    nvidia-container-toolkit-daemonset-885b5                      1/1     Running     1          38m
    nvidia-cuda-validator-kh4tv                                   0/1     Completed   0          94s
    nvidia-dcgm-exporter-6d5kd                                    1/1     Running     0          97s
    nvidia-device-plugin-daemonset-kspv5                          1/1     Running     0          97s
    nvidia-device-plugin-validator-mpgv9                          0/1     Completed   0          83s
    nvidia-driver-daemonset-mgmdb                                 1/1     Running     3          38m
    nvidia-mig-manager-svv7b                                      1/1     Running     1          35m
    nvidia-operator-validator-w44q8                               1/1     Running     0          97s


**************************
Reconfiguring MIG Profiles
**************************

The MIG manager supports dynamic reconfiguration of the MIG geometry. In this example, let's reconfigure the
GPU into a ``3g.20gb`` profile:

.. code-block:: console

    $ kubectl label nodes $NODE nvidia.com/mig.config=all-3g.20gb --overwrite

We can see from the logs of the MIG manager that it has reconfigured the GPU into the new MIG geometry:

.. code-block:: console

    Applying the selected MIG config to the node
    time="2021-05-19T16:42:14Z" level=debug msg="Parsing config file..."
    time="2021-05-19T16:42:14Z" level=debug msg="Selecting specific MIG config..."
    time="2021-05-19T16:42:14Z" level=debug msg="Running apply-start hook"
    time="2021-05-19T16:42:14Z" level=debug msg="Checking current MIG mode..."
    time="2021-05-19T16:42:14Z" level=debug msg="Walking MigConfig for (devices=all)"
    time="2021-05-19T16:42:14Z" level=debug msg="  GPU 0: 0x20B010DE"
    time="2021-05-19T16:42:14Z" level=debug msg="    Asserting MIG mode: Enabled"
    time="2021-05-19T16:42:14Z" level=debug msg="    MIG capable: true\n"
    time="2021-05-19T16:42:14Z" level=debug msg="    Current MIG mode: Enabled"
    time="2021-05-19T16:42:14Z" level=debug msg="Checking current MIG device configuration..."
    time="2021-05-19T16:42:14Z" level=debug msg="Walking MigConfig for (devices=all)"
    time="2021-05-19T16:42:14Z" level=debug msg="  GPU 0: 0x20B010DE"
    time="2021-05-19T16:42:14Z" level=debug msg="    Asserting MIG config: map[1g.5gb:7]"
    time="2021-05-19T16:42:14Z" level=debug msg="Running pre-apply-config hook"
    time="2021-05-19T16:42:14Z" level=debug msg="Applying MIG device configuration..."
    time="2021-05-19T16:42:14Z" level=debug msg="Walking MigConfig for (devices=all)"
    time="2021-05-19T16:42:14Z" level=debug msg="  GPU 0: 0x20B010DE"
    time="2021-05-19T16:42:14Z" level=debug msg="    MIG capable: true\n"
    time="2021-05-19T16:42:14Z" level=debug msg="    Updating MIG config: map[1g.5gb:7]"
    time="2021-05-19T16:42:14Z" level=debug msg="Running apply-exit hook"
    MIG configuration applied successfully
    Restarting all GPU clients previouly shutdown by reenabling their component-specific nodeSelector labels
    node/pramarao-a100-mig-k8s labeled
    Changing the 'nvidia.com/mig.config.state' node label to 'success'

And the node labels have been updated appropriately:

.. code-block:: console

    "nvidia.com/gpu.product": "A100-SXM4-40GB-MIG-3g.20gb",
    "nvidia.com/gpu.slices.ci": "3",
    "nvidia.com/gpu.slices.gi": "3",
    "nvidia.com/mig.config": "all-3g.20gb",


*******************************************
Verification: Running Sample CUDA Workloads
*******************************************

.. include:: /mig/mig-examples.rst
   :start-line: 11


*************
Disabling MIG
*************

You can disable MIG on a node by setting the ``nvidia.con/mig.config`` label
to ``all-disabled``:

.. code-block:: console

   $ kubectl label nodes $NODE nvidia.com/mig.config=all-disabled --overwrite


.. _mig-with-preinstalled-drivers-22.9.2:

**************************************
MIG Manager with Preinstalled Drivers
**************************************

Starting with v1.9, MIG Manager supports preinstalled drivers. Everything detailed in this document
still applies, however there are a few additional details to consider.

=======
Install
=======

During GPU Operator installation, ``driver.enabled=false`` must be set. The following options
can be used to install the GPU Operator:

.. code-block:: console

    $ helm install gpu-operator \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set driver.enabled=false

=========================
Managing Host GPU Clients
=========================

The MIG Manager stops all operator-managed pods that have access to GPUs when applying a MIG reconfiguration.
When drivers are preinstalled, there may be GPU clients on the host that also need to be stopped.

When drivers are preinstalled, the MIG Manager will try stopping and restarting a list of systemd services on the host across
a MIG reconfiguration. The list of services are specified in a ``ConfigMap`` to the MIG Manager daemonset. By default,
the GPU Operator creates a ``ConfigMap``, named ``default-gpu-clients``, containing a default list of systemd services.

Below is a sample GPU clients file, ``clients.yaml``, used when creating the ``default-gpu-clients`` ``ConfigMap``:

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

In the future, the GPU clients file will be extended to allow specifying more than just systemd services.

The user may modify the default list by directly editing the ``default-gpu-clients`` ``ConfigMap`` post-install. The user can also create their own
custom ``ConfigMap`` to be used by the MIG Manager by performing the following steps:

* Create the ``gpu-operator`` namespace:

  .. code-block:: console

     $ kubectl create namespace gpu-operator

* Create a ``ConfigMap`` containing the custom `clients.yaml` file with a list of GPU clients:

  .. code-block:: console

     $ kubectl create configmap -n gpu-operator gpu-clients --from-file=clients.yaml

* Install the GPU Operator:

  .. code-block:: console

    $ helm install gpu-operator \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set migManager.gpuClientsConfig.name=gpu-clients
        --set driver.enabled=false

*****************
Architecture
*****************

The MIG manager is designed as a controller within Kubernetes. It watches for changes to the
``nvidia.com/mig.config`` label on the node and then applies the user requested MIG configuration
When the label changes, the MIG Manager first stops all GPU pods (including the `device plugin`, `gfd`
and `dcgm-exporter`). It then stops all host GPU clients listed in the ``clients.yaml`` ConfigMap
if drivers are preinstalled. Finally, it applies the MIG reconfiguration and restarts the GPU pods (and possibly host GPU clients).
The MIG reconfiguration may also involve a node reboot if required for enabling MIG mode.

The available MIG profiles are specified in a ``ConfigMap`` to the MIG manager daemonset. The user may
choose one of these profiles to apply to the ``mig.config`` label to trigger a reconfiguration of the
MIG geometry.

The MIG manager relies on the `mig-parted <https://github.com/NVIDIA/mig-parted>`_ tool to apply the configuration
changes to the GPU, including enabling MIG mode (with a node reboot as required by some scenarios).

.. blockdiag::

   blockdiag admin {
      group mm_group {
        label = "MIG Manager";
        fontsize = 14; //default is 11
        color = "#00CC00";
        orientation = portrait;
      }
      A [label = "controller", group = mm_group];
      B [label = "mig-parted", group = mm_group];

      A <-> B;
      group reconfig {
        label = "Reconfiguration";
        fontsize = 14;
        color = pink;
      }

      A -> C [label = "changed", fontsize = 9];
      C [label = "Config is \n Pending/Rebooting", group = reconfig];
      D [label = "Stop operator pods", group = reconfig];
      E [label = "Enable MIG mode \n Reboot if required", group = reconfig];
      F [label = "Use mig-parted to \n configure MIG geometry", group = reconfig];
      G [label = "Restart operator pods", group = reconfig];

      C -> D -> E -> F;
      E -> F [folded];
      F -> G;
      H [label = "Set mig.config label \n to success", color = "#10a4de"];
      G -> H [folded];

      I [label = "Set mig.config label \n to failed", color = "#87232d", textcolor = "#f5f5f5"];
      G -> I [style = dashed, color = "#87232d", folded, label ="on failure", fontsize = 9];

    }
