.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
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

##########################
DRA Driver for NVIDIA GPUs
##########################

Dynamic Resource Allocation (DRA) is a Kubernetes concept for flexibly requesting, configuring, and sharing specialized devices like GPUs.
This page describes how to install and upgrade the DRA Driver for NVIDIA GPUs v${dra_version} with the NVIDIA GPU Operator.

Before using the DRA Driver for NVIDIA GPUs, it is recommended that you are familiar with the following:

* `Upstream Kubernetes DRA documentation <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/>`_.
* `DRA Driver documentation <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/>`__.

*****************
Overview
*****************

With the DRA Driver for NVIDIA GPUs, your Kubernetes workloads can allocate and consume the following two types of resources:

* GPU allocation: for controlled sharing and dynamic reconfiguration of GPUs.
  This functionality replaces the traditional GPU allocation method used by the NVIDIA Kubernetes Device Plugin.
* ComputeDomains: an abstraction for secure `Multi-Node NVLink (MNNVL) <https://docs.nvidia.com/multi-node-nvlink-systems/index.html>`_ for NVIDIA GB200 and similar systems.

You can use these features independently or together in the same cluster.

.. _known-issues:

Known Issues
************

This section covers known issues for the DRA Driver when used with the NVIDIA GPU Operator.
For known issues specific to the DRA Driver itself, refer to the `DRA Driver v${dra_version} release notes <https://github.com/kubernetes-sigs/dra-driver-nvidia-gpu/releases/tag/v${dra_version}>`__.

* There is a known issue where the NVIDIA Driver Manager is not aware of the DRA driver kubelet plugin, and will not correctly evict it on pod restarts.
  You must label the nodes you plan to use with DRA GPU allocation and pass the node label in the GPU Operator Helm command in the ``driver.manager.env`` flag.
  This enables the NVIDIA Driver Manager to evict the GPU kubelet plugin correctly on driver container upgrades.
* For A100 GPUs, the MIG manager does not automatically evict the DRA kubelet plugin during MIG configuration changes.
  If the DRA kubelet plugin is deployed before a MIG change, then you must manually restart the DRA kubelet plugin.

*************
Prerequisites
*************


In addition to ensuring your GPUs and cluster align with the :ref:`GPU Operator support matrix <operator-platform-support>`, the following prerequisites must be met:

* Kubernetes v1.34.2 or later.

  .. note::
     If you plan to use traditional extended resource requests such as ``nvidia.com/gpu`` alongside the DRA driver, you must enable the `DRAExtendedResource <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/#extended-resource>`_ feature gate. 
     This enabled by default in Kubernetes v1.36.0 and later. 
     It allows the scheduler to translate extended resource requests into ResourceClaims for the DRA driver.

* For GPU allocation support, you must label nodes that will support GPU allocation with ``nvidia.com/dra-kubelet-plugin=true`` and use this label as a node selector in the DRA driver Helm chart.
  This is required to avoid the :ref:`known issue <known-issues>` when using the GPU Operator with the DRA Driver.
  Steps for labeling nodes are provided in the install section.
  The label is also passed to the GPU Operator Helm command via the ``driver.manager.env`` flag.

.. _computedomain-prereqs:

* For ComputeDomain ensure the following:

  * NVIDIA Grace Blackwell GPUs with Multi-Node NVLink (MNNVL) available on your cluster.
    For example, NVIDIA HGX GB200 NVL72 or NVIDIA HGX GB300 NVL72.
    Refer to the `NVIDIA Multi-Node NVLink Systems documentation <https://docs.nvidia.com/multi-node-nvlink-systems/index.html>`_ for details on Multi-Node NVLink systems.

  * For using ComputeDomains with a pre-installed GPU Driver:

    * The corresponding nvidia-imex-* packages installed through your Linux distribution's package manager.
    * The IMEX systemd service disabled before installing the GPU Operator (on all GPU nodes).
      For example:

      .. code-block:: console

         $ systemctl disable --now nvidia-imex.service && systemctl mask nvidia-imex.service


.. note::

   Installing GPU Operator ${version} configures some additional DRA Driver for NVIDIA GPUs prerequisites for you:

   * Container Device Interface (CDI) enabled in the underlying container runtime (such as containerd or CRI-O)
   * NVIDIA Driver version 580 or later.
   * Deploy Node Feature Discovery (NFD) and GPU Feature Discovery (GFD) on your cluster.


*******
Install
*******

This section covers fresh installs of the GPU Operator and DRA Driver for NVIDIA GPUs.
If you are upgrading an earlier version of the DRA Driver for NVIDIA GPUs, refer to the :ref:`Upgrade <upgrade>` section.

.. note::
   The ``nvidiaDriverRoot`` flag sets the root directory for the NVIDIA GPU driver.
   The default value is ``/``, which is typical for drivers installed directly on the host.
   With GPU Operator–managed drivers (default), drivers are installed to ``/run/nvidia/driver``.
   If you are using `pre-installed drivers <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#pre-installed-nvidia-gpu-drivers>`_, remove the ``nvidiaDriverRoot`` flag or set it to ``/``.


.. tab-set::
   :sync-group: dra

   .. tab-item:: GPU Allocation
      :sync: gpu-allocation

      1. Label every node that will support GPU allocation through DRA:

         .. code-block:: console

            $ kubectl label node $HOSTNAME nvidia.com/dra-kubelet-plugin=true

      2. Add the NVIDIA Helm repository:

         .. code-block:: console

            $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
                && helm repo update

      3. Install the GPU Operator with the NVIDIA Kubernetes Device Plugin disabled:

         .. code-block:: console

            $ helm upgrade --install gpu-operator nvidia/gpu-operator \
                --version=${version} \
                --create-namespace \
                --namespace gpu-operator \
                --set devicePlugin.enabled=false \
                --set driver.manager.env[0].name=NODE_LABEL_FOR_GPU_POD_EVICTION \
                --set driver.manager.env[0].value="nvidia.com/dra-kubelet-plugin"

         Make sure the value of ``driver.manager.env`` matches the node label applied in step 1.

         Make sure the ``devicePlugin.enabled`` flag is set to ``false`` to disable the NVIDIA Kubernetes Device Plugin.
         The DRA Driver for NVIDIA GPUs will be used to allocate GPUs.

         Refer to the `GPU Operator installation guide <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html>`_ for additional configuration options.
         If you plan to use MIG devices, refer to the `GPU Operator MIG documentation <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-mig.html>`_ to configure your cluster for MIG support.
         Restart the DRA driver pod to discover MIG devices created by the GPU Operator MIG Manager.

      4. Create a ``values.yaml`` file for the DRA driver:

         .. code-block:: yaml

            image:
              pullPolicy: IfNotPresent
            kubeletPlugin:
              nodeSelector:
                nvidia.com/dra-kubelet-plugin: "true"

         If you are using Google Kubernetes Engine (GKE), the DRA driver requires additional overrides for the driver root, controller affinity, and tolerations:

         .. code-block:: yaml

            # GKE helm values example
            # "/home/kubernetes/bin/nvidia" is the default driver root on GKE.
            nvidiaDriverRoot: "/home/kubernetes/bin/nvidia"

            controller:
              priorityClassName: ""
              affinity: null
            image:
              pullPolicy: IfNotPresent
            kubeletPlugin:
              priorityClassName: ""
              tolerations:
                - effect: NoSchedule
                  key: nvidia.com/gpu
                  operator: Exists
              nodeSelector:
                nvidia.com/dra-kubelet-plugin: "true"

      5. Install the DRA driver:

         .. code-block:: console

            $ helm upgrade -i dra-driver-nvidia-gpu nvidia/dra-driver-nvidia-gpu \
                --version=${dra_version} \
                --namespace nvidia-dra-driver-gpu \
                --create-namespace \
                --set nvidiaDriverRoot=/run/nvidia/driver \
                --set gpuResourcesEnabledOverride=true \
                -f values.yaml

         For GKE, omit ``--set nvidiaDriverRoot=/run/nvidia/driver``; the value comes from the GKE ``values.yaml`` file.

   .. tab-item:: ComputeDomain
      :sync: computedomain

      1. Add the NVIDIA Helm repository:

         .. code-block:: console

            $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update

      2. Install the GPU Operator:

         .. code-block:: console

            $ helm upgrade --install gpu-operator nvidia/gpu-operator \
                --version=${version} \
                --create-namespace \
                --namespace gpu-operator

         Refer to the `GPU Operator installation guide <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html>`_ for additional configuration options.

      3. Install the DRA driver.

         Example for a GPU Operator–managed driver:

         .. code-block:: console

            $ helm upgrade -i dra-driver-nvidia-gpu nvidia/dra-driver-nvidia-gpu \
                --version=${dra_version} \
                --namespace nvidia-dra-driver-gpu \
                --create-namespace \
                --set resources.gpus.enabled=false \
                --set nvidiaDriverRoot=/run/nvidia/driver

         Example for a pre-installed GPU driver:

         .. code-block:: console

            $ helm upgrade -i dra-driver-nvidia-gpu nvidia/dra-driver-nvidia-gpu \
                --version=${dra_version} \
                --namespace nvidia-dra-driver-gpu \
                --create-namespace \
                --set resources.gpus.enabled=false

*********************
Validate Installation
*********************

1. Confirm that the DRA driver components are running:

   .. code-block:: console

      $ kubectl get pods -n nvidia-dra-driver-gpu

   *Example Output*

   .. code-block:: output

      NAME                                                READY   STATUS    RESTARTS   AGE
      dra-driver-nvidia-gpu-controller-67cb99d84b-5q7kj   1/1     Running   0          7m26s
      dra-driver-nvidia-gpu-kubelet-plugin-h5xsn          2/2     Running   0          7m27s

   The controller pod runs the ComputeDomain controller (1 container). The kubelet-plugin pod runs two containers, one for GPU resources (gpus) and one for ComputeDomain resources (compute-domains), so it shows ``2/2`` when both are enabled. One kubelet-plugin pod appears per GPU node.

   If you installed with ``--set resources.computeDomains.enabled=false``, the controller pod is not present and the kubelet-plugin pod shows ``1/1``. The same is true if you disabled GPU allocation during install.

   .. note::
      If you upgraded an existing v25.x installation, the pod names retain the ``nvidia-dra-driver-gpu-`` prefix (for example, ``nvidia-dra-driver-gpu-controller-*``) because the upgrade preserves the original resource names through the ``nameOverride`` flag.

2. Verify that GPU DeviceClasses are available:

   .. code-block:: console

      $ kubectl get deviceclass

   *Example Output*

   .. code-block:: output


      NAME                                        AGE
      compute-domain-daemon.nvidia.com            55s
      compute-domain-default-channel.nvidia.com   55s
      gpu.nvidia.com                              55s
      mig.nvidia.com                              55s

The ``compute-domain-daemon.nvidia.com`` and ``compute-domain-default-channel.nvidia.com`` DeviceClasses are installed when ComputeDomain support is enabled.
The ``gpu.nvidia.com`` and ``mig.nvidia.com`` DeviceClasses are installed when GPU allocation support is enabled.

Additional validation steps are available in the upstream DRA Driver documentation:

* `Validate setup for ComputeDomain allocation <https://github.com/kubernetes-sigs/dra-driver-nvidia-gpu/wiki/Validate-setup-for-ComputeDomain-allocation>`_
* `Validate setup for GPU allocation <https://github.com/kubernetes-sigs/dra-driver-nvidia-gpu/wiki/Validate-setup-for-GPU-allocation>`_

.. _upgrade:

*******
Upgrade
*******

Starting with v0.4.0, the DRA Driver for NVIDIA GPUs moved to ``kubernetes-sigs/dra-driver-nvidia-gpu`` and adopted semantic versioning.
The Helm chart was renamed from ``nvidia-dra-driver-gpu`` to ``dra-driver-nvidia-gpu`` and is published to new NGC Helm and container registries.

When upgrading from v25.x you must explicitly set ``nameOverride`` and ``--version`` to avoid creating duplicate Kubernetes manifests under different names.
Without ``--set nameOverride=nvidia-dra-driver-gpu``, the upgrade creates new daemonsets and deployments under the new chart name instead of upgrading the existing resources in place.

.. important::
   After upgrading to v0.4.0, downgrading to v25.x is not supported.

Upgrade from v25.x to v0.4.0 or later
**************************************

1. Apply the v${dra_version} CRDs for ComputeDomains and ComputeDomainsCliques before upgrading the Helm chart.
   Refer to the `v${dra_version} release page <https://github.com/kubernetes-sigs/dra-driver-nvidia-gpu/releases/tag/v${dra_version}>`__ for the CRD manifests.

2. Run ``helm upgrade`` with ``nameOverride`` and ``--version``, preserving any original install flags such as ``gpuResourcesEnabledOverride`` and ``nvidiaDriverRoot``:

   .. code-block:: console

      $ helm upgrade -i nvidia-dra-driver-gpu nvidia/dra-driver-nvidia-gpu \
          --version=${dra_version} \
          --namespace nvidia-dra-driver-gpu \
          --set nameOverride=nvidia-dra-driver-gpu \
          --set gpuResourcesEnabledOverride=true \
          --set nvidiaDriverRoot=/run/nvidia/driver

3. Verify the upgrade:

   .. code-block:: console

      $ kubectl get pods -n nvidia-dra-driver-gpu

   All controller and kubelet-plugin pods should reach ``Running`` status, and existing ResourceClaims should remain in the ``allocated,reserved`` state.

Refer to the `upstream upgrade guide <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/upgrade/>`__ for additional detail.

************************
Additional Documentation
************************

For more details on the DRA Driver for NVIDIA GPUs, refer to the following resources:

* `DRA Driver for NVIDIA GPUs documentation <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/>`__
* `DRA Driver v${dra_version} release notes <https://github.com/kubernetes-sigs/dra-driver-nvidia-gpu/releases/tag/v${dra_version}>`__