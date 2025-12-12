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
NVIDIA DRA Driver for GPUs
##########################

Dynamic Resource Allocation (DRA) is a Kubernetes concept for flexibly requesting, configuring, and sharing specialized devices like GPUs.
DRA puts device configuration and scheduling into the hands of device vendors through drivers such as the DRA Driver for GPUs.
This page outlines how to install the NVIDIA DRA Driver for GPUs v25.12.0 and later with the NVIDIA GPU Operator.

Before using the DRA Driver for GPUs, it is recommended that you are familiar with the following concepts:

* `Upstream Kubernetes DRA documentation <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/>`_.
* `DRA Driver repository documentation <https://github.com/NVIDIA/k8s-dra-driver-gpu>`__

*****************
Overview
*****************

With NVIDIA's DRA Driver for GPUs, your Kubernetes workload can allocate and consume the following two types of resources:

* GPU allocation: for controlled sharing and dynamic reconfiguration of GPUs. This functionality is a replacement for the traditional GPU allocation method used by the NVIDIA Kubernetes Device Plugin. 
* ComputeDomains: An abstraction for robust and secure `Multi-Node NVLink (MNNVL) <https://docs.nvidia.com/multi-node-nvlink-systems/index.html>`_ for NVIDIA GB200 and similar systems.

You can use the NVIDIA DRA Driver for GPUs with the NVIDIA GPU Operator to deploy and manage your GPUs and ComputeDomains.

*************
Prerequisites
*************

.. tip::
   You can use both NVIDIA DRA Driver for GPUs ComputeDomain and GPU allocation independently or together in the same cluster. 
   However, they have different prerequisites.
   If you plan to use both features together, you must configure your cluster with the minimum prerequisites for both GPU allocation and ComputeDomains.

.. tab-set::
   :sync-group: dra

   .. tab-item:: GPU Allocation
      :sync: gpu-allocation

      Using the NVIDIA DRA Driver for GPUs allocation with the GPU Operator requires the following:

      * Kubernetes v1.34.2 or newer.

        .. note::
           If you plan to use traditional extended resource requests such as `nvidia.com/gpu` with the DRA driver, you must enable the [DRAExtendedResource](https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/#extended-resource) feature gate. This feature allows the scheduler to automatically translate extended resource requests into ResourceClaims, which are then allocated by the DRA driver.

      * GPU Operator v25.10.0 or later with the NVIDIA Kubernetes Device Plugin disabled to avoid conflicts with the DRA Driver for GPUs.

        The DRA Driver requires Container Device Interface (CDI) to be enabled in the underlying container runtime (such as containerd or CRI-O) and NVIDIA Driver version 580 or later.
        These are both default in GPU Operator v25.10.0 and later.

      * Label nodes you plan to use for GPU allocation with something like ``nvidia.com/dra-kubelet-plugin=true`` and use them as nodeSelectors in the DRA driver helm chart.
        Steps for labeling nodes are provided in the next section.

        There is a known issue where the NVIDIA Driver Manager is not aware of the DRA driver kubelet plugin, and will not correctly evict it on pod restarts.
        You must label the nodes you plan to use with DRA GPU allocation and pass the node label in the GPU Operator Helm command in the ``driver.manager.env`` flag.
        This enables the NVIDIA Driver Manager to evict the GPU kubelet plugin correctly on driver container upgrades.

   .. tab-item:: ComputeDomain
      :sync: computedomain

      * Kubernetes v1.32 or later.

        * DRA is enabled by default in Kubernetes v1.34 and later.
        * If you are using Kubernetes v1.32 or v1.33, you must enable DRA and corresponding API groups on your cluster. Refer to the `Kubernetes DRA documentation <https://kubernetes.io/docs/tasks/configure-pod-container/assign-resources/set-up-dra-cluster/#enable-dra>`_ for details on enabling the correct DRA API groups for your version of Kubernetes.

        .. note::
           It is recommended that you use Kubernetes v1.34.2 or later with the DRA Driver to avoid a `known issue <https://github.com/kubernetes/kubernetes/issues/133920>`_.

      * GPU Operator v25.10.0 or later.
        The DRA Driver requires Container Device Interface (CDI) to be enabled in the underlying container runtime (such as containerd or CRI-O) and NVIDIA Driver version 580 or later.
        These are both default in GPU Operator v25.10.0 and later.

      * NVIDIA Grace Blackwell GPUs with Multi-Node NVLink (MNNVL) available on your cluster.
        For example, NVIDIA HGX GB200 NVL72 or NVIDIA HGX GB300 NVL72.
        Refer to the `NVIDIA Multi-Node NVLink Systems documentation <https://docs.nvidia.com/multi-node-nvlink-systems/index.html>`_ for details on Multi-Node NVLink systems.



*******************************
Install the NVIDIA GPU Operator
*******************************

.. tab-set::
   :sync-group: dra

   .. tab-item:: GPU Allocation
      :sync: gpu-allocation

      1. Create a node selector label on all the nodes in your cluster that support GPU allocation through DRA:

         .. code-block:: console

            kubectl label node $HOSTNAME nvidia.com/dra-kubelet-plugin=true

      2. Add the Helm repo:

         .. code-block:: console

            helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
            && helm repo update

      3. Install the GPU Operator with the NVIDIA Kubernetes Device Plugin disabled:

         .. code-block:: console

            helm upgrade --install gpu-operator nvidia/gpu-operator \
              --version=${version} \
              --create-namespace \
              --namespace gpu-operator \
              --set devicePlugin.enabled=false \
              --set driver.manager.env[0].name=NODE_LABEL_FOR_GPU_POD_EVICTION \
              --set driver.manager.env[0].value="nvidia.com/dra-kubelet-plugin"

         Make sure that the value of ``driver.manager.env`` matches the node selector label that was used when installing the DRA driver helm chart.

   .. tab-item:: ComputeDomain
      :sync: computedomain

      1. Add the Helm repo:

      .. code-block:: console

         helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
         && helm repo update

      2. Install the GPU Operator with the device plugin disabled:

      .. code-block:: console

         helm upgrade --install gpu-operator nvidia/gpu-operator \
           --version=${version} \
           --create-namespace \
           --namespace gpu-operator 


Refer to the `GPU Operator installation guide <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-install.html>`_ for additional configuration options when installing the GPU Operator.

***************************
Install DRA Driver for GPUs
***************************

.. note::
    The ``gpuResourcesEnabledOverride=true`` is an additional flag that is required to fully enable GPU allocation support. 
    Include it in the Helm command if you want to enable GPU allocation support.

    If you want to disable either functionality:

    * To disable GPU allocation support, include ``--set resources.gpus.enabled=false`` in the Helm command.
    * To disable ComputeDomain support, include ``--set resources.computeDomains.enabled=false`` in the Helm command.
    

.. note::
    The ``nvidiaDriverRoot`` flag sets the root directory for the NVIDIA GPU driver.
    The default value is ``/``, which is the typical value for drivers installed directly on the host.
    If you are using GPU Operator managed drivers (default), the drivers are installed to ``/run/nvidia/driver`` by default.
    If you are using `pre-installed drivers <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#pre-installed-nvidia-gpu-drivers>`_, you can remove the ``nvidiaDriverRoot`` flag or set it to ``/`` in the command above.

.. tab-set::
   :sync-group: dra

   .. tab-item:: GPU Allocation
      :sync: gpu-allocation

      1. Create a custom ``dra-values.yaml`` file for installing the DRA driver helm chart.

         .. tab-set::

            .. tab-item:: values.yaml file

             Specifies the node selector label for nodes that will support GPU allocation through the DRA Driver.

             .. code-block:: yaml

                image:
                  pullPolicy: IfNotPresent
                kubeletPlugin:
                  nodeSelector:
                    nvidia.com/dra-kubelet-plugin: "true"

            .. tab-item:: GKE values.yaml file

             Google Kubernetes Engine requires some specific values to be set in the ``values.yaml`` file, including the driver root on the host in ``nvidiaDriverRoot`` as well as the node selector label for nodes that will support GPU allocation through the DRA Driver.

             .. code-block:: yaml

                # Specify the driver root on the host in nvidiaDriverRoot.
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

      2. Add the Helm repo:

         .. code-block:: console

            helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
            && helm repo update

      3. Install the DRA driver:

         .. tab-set::

            .. tab-item:: install command

               .. code-block:: console

                  helm upgrade -i nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
                    --version="${dra_version}" \
                    --namespace nvidia-dra-driver-gpu \
                    --create-namespace \
                    --set nvidiaDriverRoot=/run/nvidia/driver \
                    --set gpuResourcesEnabledOverride=true \
                    -f dra-values.yaml

            .. tab-item:: GKE install command

               .. code-block:: console

                  helm upgrade -i nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
                    --version="${dra_version}" \
                    --namespace nvidia-dra-driver-gpu \
                    --create-namespace \
                    --set gpuResourcesEnabledOverride=true \
                    -f dra-values.yaml

   .. tab-item:: ComputeDomain
      :sync: computedomain

      1. Add the NVIDIA NGC Catalog's Helm chart repository:

         .. code-block:: console

            helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update

      2. Install the DRA driver.

         Example for Operator-provided GPU driver:

         .. code-block:: console

            helm upgrade -i nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
              --version="${dra_version}" \
              --create-namespace \
              --namespace nvidia-dra-driver-gpu \
              --set resources.gpus.enabled=false \
              --set nvidiaDriverRoot=/run/nvidia/driver

         Example for host-provided GPU driver:

         .. code-block:: console

            helm upgrade -i nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
              --version="${dra_version}" \
              --create-namespace \
              --namespace nvidia-dra-driver-gpu \
              --set resources.gpus.enabled=false


*********************
Validate Installation
*********************

1. Confirm that the DRA driver components are running:

   .. code-block:: console

      kubectl get pods -n nvidia-dra-driver-gpu

   *Example Output*

   .. code-block:: output

      NAME                                                READY   STATUS    RESTARTS   AGE
      nvidia-dra-driver-gpu-controller-67cb99d84b-5q7kj   1/1     Running   0          7m26s
      nvidia-dra-driver-gpu-kubelet-plugin-h5xsn          1/1     Running   0          7m27s

2. Verify that GPU DeviceClasses are available:

   .. code-block:: console

      kubectl get deviceclass

   *Example Output*

   .. code-block:: output

      NAME              AGE
      compute-domain-daemon.nvidia.com            55s
      compute-domain-default-channel.nvidia.com   55s
      gpu.nvidia.com                              55s
      mig.nvidia.com                              55s
      vfio.gpu.nvidia.com                         55s

The ``compute-domain-daemon.nvidia.com`` and ``compute-domain-default-channel.nvidia.com`` DeviceClasses are installed when ComputeDomain support is enabled.
The ``gpu.nvidia.com``, ``mig.nvidia.com``, and ``vfio.gpu.nvidia.com`` DeviceClasses are installed when GPU allocation support is enabled.

Additional validation steps are available in the DRA Driver repository documentation:

* `Validate setup for ComputeDomain allocation <https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki/Validate-setup-for-ComputeDomain-allocation>`_
* `Validate setup for GPU allocation <https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki/Validate-setup-for-GPU-allocation>`_


