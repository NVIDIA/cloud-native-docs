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

.. headings (h1/h2/h3/h4/h5) are # * = -

..
   lingo:

   It is "Kata Containers" when referring to the software component.
   It is "Kata container" when it is a container that uses the Kata Containers runtime.
   Treat our operands as proper nouns and use title case.

###########################   
Deploy with Kata Containers
###########################


***************************************
About the Operator with Kata Containers
***************************************

`Kata Containers <https://katacontainers.io/>`_ is an open source project that creates lightweight Virtual Machines (VMs) that feel and perform like containers. 
Kata Containers are similar, but subtly different from traditional containers such as a Docker container.

A traditional container packages software for user-space isolation from the host,
but the container runs on the host and shares the operating system kernel with the host.
Sharing the operating system kernel is a potential vulnerability.

A Kata container runs in a virtual machine on the host.
The virtual machine has a separate operating system and operating system kernel.
Hardware virtualization and a separate kernel provide improved workload isolation
in comparison with traditional containers.

The NVIDIA GPU Operator works with the Kata container runtime.
Kata uses a hypervisor, such as QEMU, to provide a lightweight virtual machine with a single purpose: to run a Kubernetes pod.

The following diagram shows the software components that Kubernetes uses to run a Kata container.

.. mermaid::
   :caption: Software Components with Kata Container Runtime
   :alt: Logical diagram of software components between Kubelet and containers when using Kata Containers.

   flowchart LR
     a[Kubelet] --> b[CRI] --> c[Kata\nRuntime] --> d[Lightweight\nQEMU VM] --> e[Lightweight\nGuest OS] --> f[Pod] --> g[Container]


To enable Kata Containers for GPUs, install the upstream ``kata-deploy`` Helm chart, which deploys all Kata runtime classes, including NVIDIA-specific runtime classes. 
The ``kata-qemu-nvidia-gpu`` runtime class is used with Kata Containers.
Other runtime classes like, ``kata-qemu-nvidia-gpu-snp`` and ``kata-qemu-nvidia-gpu-tdx``, are also installed with ``kata-deploy``, but are used to deploy Confidential Containers.

Then configure the GPU Operator to use Kata mode for sandbox workloads and, optionally, the Kata device plugin.

.. tip::
   This page describes deploying with Kata containers.
   Refer to the `Confidential Containers documentation <https://docs.nvidia.com/datacenter/cloud-native/confidential-containers/latest/confidential-containers-deploy.html>`_ if you are interested in deploying Confidential Containers with Kata Containers.

*********************************
Benefits of Using Kata Containers
*********************************

The primary benefits of Kata Containers are as follows:

* Running untrusted workloads in a container.
  The virtual machine provides a layer of defense against the untrusted code.

* Limiting access to hardware devices such as NVIDIA GPUs.
  The virtual machine is provided access to specific devices.
  This approach ensures that the workload cannot access additional devices.

* Transparent deployment of unmodified containers.

****************************
Limitations and Restrictions
****************************

* GPUs are available to containers as a single GPU in passthrough mode only.
  Multi-GPU passthrough and vGPU are not supported.

* Support is limited to initial installation and configuration only.
  Upgrade and configuration of existing clusters for Kata Containers is not supported.

* Support for Kata Containers is limited to the implementation described on this page.
  The Operator does not support Red Hat OpenShift sandbox containers.

* NVIDIA supports the Operator and Kata Containers with the containerd runtime only.


*******************************
Cluster Topology Considerations
*******************************

You can configure all the worker nodes in your cluster for Kata Containers or you can configure some
nodes for Kata Containers and others for traditional containers.
Consider the following example where node A is configured to run traditional containers and node B is configured to run Kata Containers.

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Node A - Traditional Containers receives the following software components
     - Node B - Kata Containers receives the following software components
   * - * ``NVIDIA Driver Manager for Kubernetes`` -- to install the data-center driver.
       * ``NVIDIA Container Toolkit`` -- to ensure that containers can access GPUs.
       * ``NVIDIA Device Plugin for Kubernetes`` -- to discover and advertise GPU resources to kubelet.
       * ``NVIDIA DCGM and DCGM Exporter`` -- to monitor GPUs.
       * ``NVIDIA MIG Manager for Kubernetes`` -- to manage MIG-capable GPUs.
       * ``Node Feature Discovery (NFD)`` -- to detect CPU, kernel, and host features and label worker nodes.
       * ``NVIDIA GPU Feature Discovery`` -- to detect NVIDIA GPUs and label worker nodes.
     - * ``NVIDIA Kata Sandbox Device Plugin`` -- to discover and advertise the passthrough GPUs to kubelet.
       * ``NVIDIA VFIO Manager`` -- to load the vfio-pci device driver and bind it to all GPUs on the node.
       * ``Node Feature Discovery`` -- to detect CPU security features, NVIDIA GPUs, and label worker nodes.
       

.. note::

   If your nodes are capable of running confidential containers, the NVIDIA Confidential Computing Manager for Kubernetes will also be deployed on the node. 
   Deploying the Confidential Computing Manager is determined by NFD.
   This manager sets the confidential computing (CC) mode on the NVIDIA GPUs.
   
   To make sure Confidential Computing mode is disabled on your cluster, refer to `Managing the Confidential Computing Mode <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/confidential-containers-deploy.html#managing-the-confidential-computing-mode>`_.

**********************************************
Configure the GPU Operator for Kata Containers
**********************************************

Overview of Installation and Configuration
===========================================

Installing and configuring your cluster to support the NVIDIA GPU Operator with Kata Containers is as follows:

#. Configure prerequisites.

#. Label the worker nodes that you want to use with Kata Containers.

   .. code-block:: console

      $ kubectl label node <node-name> nvidia.com/gpu.workload.config=vm-passthrough

   The GPU Operator uses this label to determine what software components to deploy to a node. 
   You can use this label on nodes for Kata workloads, and run traditional container workloads with GPU on other nodes in your cluster.

   Alternatively, if you want to run Kata containers on all your worker nodes, set the default sandbox workload to ``vm-passthrough`` when you install the GPU Operator.

#. Install kata-deploy Helm chart.

#. Install the NVIDIA GPU Operator.

   You install the Operator and specify options to deploy the operands that are required for Kata Containers.

After installation, you can run a sample workload that uses the Kata runtime class.

Prerequisites
=============

* Your hosts are configured to enable hardware virtualization and Access Control Services (ACS).
  With some AMD CPUs and BIOSes, ACS might be grouped under Advanced Error Reporting (AER).
  Enabling these features is typically performed by configuring the host BIOS.

* Your hosts are configured to support IOMMU.

  If the output from running ``ls /sys/kernel/iommu_groups`` includes ``0``, ``1``, and so on,
  then your host is configured for IOMMU.

  If a host is not configured or you are unsure, add the ``intel_iommu=on`` (or ``amd_iommu=on`` for AMD CPUs) Linux kernel command-line argument.
  For most Linux distributions, you add the argument to the ``/etc/default/grub`` file:

  .. code-block:: text

     ...
     GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on modprobe.blacklist=nouveau"
     ...

  On Ubuntu systems, run ``sudo update-grub`` after making the change to configure the bootloader.
  On other systems, you might need to run ``sudo dracut`` after making the change.
  Refer to the documentation for your operating system.
  Reboot the host after configuring the bootloader.

* You have a Kubernetes cluster and you have cluster administrator privileges.

* The NVIDIA GPU runtime classes use VFIO cold-plug which requires the Kata runtime to query Kubelet's Pod Resources API to discover allocated GPU devices during sandbox creation. 
  For Kubernetes versions older than 1.34, you must explicitly enable the ``KubeletPodResourcesGet`` feature gate in your Kubelet configuration. 
  For Kubernetes 1.34 and later, the ``KubeletPodResourcesGet`` feature gate is enabled by default.


Install Kata-deploy
===================

Install the kata-deploy Helm chart. 
Minimum required version is 3.24.0.

#. Get the latest version of the ``kata-deploy`` Helm chart:

   .. code-block:: console

      $ export VERSION="3.26.0"
      $ export CHART="oci://ghcr.io/kata-containers/kata-deploy-charts/kata-deploy"


#. Install the kata-deploy Helm chart:

   .. code-block:: console

     $ helm install kata-deploy "${CHART}" \
       --namespace kata-system --create-namespace \
       --set nfd.enabled=false \
       --wait --timeout 10m \
       --version "${VERSION}"


#. Optional: Verify that the kata-deploy pod is running:

   .. code-block:: console

      $ kubectl get pods -n kata-system | grep kata-deploy

   *Example Output*

   .. code-block:: output

      NAME                    READY   STATUS    RESTARTS      AGE
      kata-deploy-b2lzs       1/1     Running   0             6m37s

#. Optional, verify that the ``kata-qemu-nvidia-gpu`` runtime class is available:

   .. code-block:: console

      $ kubectl get runtimeclass | grep kata-qemu-nvidia-gpu

   *Example Output*

   .. code-block:: output

      NAME                            HANDLER                         AGE
      kata-qemu-nvidia-gpu            kata-qemu-nvidia-gpu            53s

   ``kata-deploy`` installs several runtime classes. The  ``kata-qemu-nvidia-gpu`` runtime class is used with Kata Containers.
   Other runtime classes like ``kata-qemu-nvidia-gpu-snp`` and ``kata-qemu-nvidia-gpu-tdx`` are used to deploy :ref:`Confidential Containers <confidential-containers-deploy>`.


Install the NVIDIA GPU Operator
===============================

Perform the following steps to install the Operator for use with Kata Containers:

#. Add and update the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
         && helm repo update

#. Specify at least the following options when you install the Operator.
   If you want to run Kata Containers by default on all worker nodes, also specify ``--set sandboxWorkloads.defaultWorkload=vm-passthrough``.

   .. code-block:: console

      $ helm install --wait --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --set sandboxWorkloads.enabled=true \
         --set sandboxWorkloads.defaultWorkload=vm-passthrough \
         --set sandboxWorkloads.mode=kata \
         --set nfd.enabled=true \
         --set nfd.nodefeaturerules=true 


   *Example Output*

   .. code-block:: output

      NAME: gpu-operator
      LAST DEPLOYED: Tue Mar 10 17:58:12 2026
      NAMESPACE: gpu-operator
      STATUS: deployed
      REVISION: 1
      TEST SUITE: None

Verification
============

#. Verify that the Kata and VFIO Manager operands are running:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator

   *Example Output*

   .. code-block:: output

      NAME                                                         READY   STATUS      RESTARTS   AGE
      gpu-operator-5b69cf449c-mjmhv                                     1/1     Running   0          78s
      gpu-operator-v26-1773935562-node-feature-discovery-gc-95b4pnpbh   1/1     Running   0          78s
      gpu-operator-v26-1773935562-node-feature-discovery-master-kxzxg   1/1     Running   0          78s
      gpu-operator-v26-1773935562-node-feature-discovery-worker-8bx68   1/1     Running   0          78s
      nvidia-cc-manager-bnmlh                                           1/1     Running   0          62s
      nvidia-kata-sandbox-device-plugin-daemonset-df7jt                 1/1     Running   0          63s
      nvidia-sandbox-validator-4bxgl                                    1/1     Running   0          53s
      nvidia-vfio-manager-cxlz5                                         1/1     Running   0          63s


   .. note::

      If your nodes are capable of running confidential containers, the NVIDIA Confidential Computing Manager for Kubernetes `nvidia-cc-manager` will also be deployed on the node. 
      Deploying the Confidential Computing Manager is determined by NFD.
      This manager sets the confidential computing (CC) mode on the NVIDIA GPUs.
      
      To make sure Confidential Computing mode is disabled on your cluster, refer to `Managing the Confidential Computing Mode <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/confidential-containers-deploy.html#managing-the-confidential-computing-mode>`_.

#. Verify that the ``kata-qemu-nvidia-gpu`` runtime class is available:

   .. code-block:: console

      $ kubectl get runtimeclass | grep kata-qemu-nvidia-gpu

   *Example Output*

   .. code-block:: output


      NAME                            HANDLER                         AGE
      kata-qemu-nvidia-gpu            kata-qemu-nvidia-gpu            53s

   ``kata-deploy`` installs several runtime classes. The  ``kata-qemu-nvidia-gpu`` runtime class is used with Kata Containers.
   Other runtime classes like ``kata-qemu-nvidia-gpu-snp`` and ``kata-qemu-nvidia-gpu-tdx`` are used to deploy :ref:`Confidential Containers <confidential-containers-deploy>`.

#. Optional: If you have host access to the worker node, you can perform the following steps:

   #. Confirm that the host uses the ``vfio-pci`` device driver for GPUs:

      .. code-block:: console

         $ lspci -nnk -d 10de:

      *Example Output*

      .. code-block:: output
         :emphasize-lines: 3

         65:00.0 3D controller [0302]: NVIDIA Corporation GA102GL [A10] [10de:2236] (rev a1)
                 Subsystem: NVIDIA Corporation GA102GL [A10] [10de:1482]
                 Kernel driver in use: vfio-pci
                 Kernel modules: nvidiafb, nouveau

*********************
Run a Sample Workload
*********************

A pod specification for a Kata container requires the following:

* Specify a Kata runtime class.

* Specify a passthrough GPU resource.


#. Create a file, such as ``cuda-vectoradd-kata.yaml``, with the following content:

   .. code-block:: yaml
      :emphasize-lines: 6,13

      apiVersion: v1
      kind: Pod
      metadata:
        name: cuda-vectoradd-kata
      spec:
        runtimeClassName: kata-qemu-nvidia-gpu
        restartPolicy: OnFailure
        containers:
          - name: cuda-vectoradd
            image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0-ubuntu22.04"
            resources:
              limits:
                nvidia.com/pgpu: "1"
                memory: 16Gi

#. Create the pod:

   .. code-block:: console

      $ kubectl apply -f cuda-vectoradd-kata.yaml

#. View the pod logs:

   .. code-block:: console

      $ kubectl logs -n default cuda-vectoradd-kata

   *Example Output*

   .. code-block:: output

      [Vector addition of 50000 elements]
      Copy input data from the host memory to the CUDA device
      CUDA kernel launch with 196 blocks of 256 threads
      Copy output data from the CUDA device to the host memory
      Test PASSED
      Done

#. Delete the pod:

   .. code-block:: console

      $ kubectl delete -f cuda-vectoradd-kata.yaml


Troubleshooting Workloads
=========================

If the sample workload does not run, confirm that you labelled nodes to run virtual machines in containers:

.. code-block:: console

   $ kubectl get nodes -l nvidia.com/gpu.workload.config=vm-passthrough

*Example Output*

.. code-block:: output

   NAME               STATUS   ROLES    AGE   VERSION
   kata-worker-1      Ready    <none>   10d   v1.27.3
   kata-worker-2      Ready    <none>   10d   v1.27.3
   kata-worker-3      Ready    <none>   10d   v1.27.3

You mays have also configured ``vm-passthrough`` as the default sandbox workload in the ClusterPolicy. 
That will deploy all workloads on your cluster in Kata containers. 
Also check that the GPU Operator is configured to deploy Kata containers in the ClusterPolicy. 

.. code-block:: console

   $ kubectl describe clusterpolicy | grep sandboxWorkloads

*Example Output*

.. code-block:: output

   sandboxWorkloads:
     enabled: true
     defaultWorkload: vm-passthrough
     mode: kata

