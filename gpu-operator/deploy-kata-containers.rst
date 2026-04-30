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

`Kata Containers <https://katacontainers.io/>`_ is an open source project that creates lightweight Virtual Machines (VMs) that feel and perform like traditional containers such as a Docker container. 
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


.. tip::
   This page describes deploying with Kata containers only.
   Refer to the :doc:`Confidential Containers documentation <cc:index>` if you are interested in deploying Confidential Containers with Kata Containers and the GPU Operator.

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

* GPUs are available to containers in passthrough mode only: either single-GPU passthrough
  or multi-GPU passthrough on NVSwitch-based systems.
  vGPU is not supported.

* Support for Kata Containers is limited to the implementation described on this page.
  The Operator offers Technology Preview support for Red Hat OpenShift Sandboxed Containers v1.12.

* NVIDIA supports the Operator and Kata Containers with the containerd runtime only.


.. _kata-containers-cluster-topology-considerations:

*******************************
Cluster Topology Considerations
*******************************

You can configure all the worker nodes in your cluster for Kata Containers or you can configure some nodes for Kata Containers and others for traditional containers.
Consider the following example where node A is configured to run traditional containers and node B is configured to run Kata Containers.

.. list-table::
   :widths: 50 50
   :header-rows: 1

   * - Node A - Traditional Container nodes receive the following software components
     - Node B - Kata Container nodes receive the following software components
   * - * ``NVIDIA Driver Manager for Kubernetes`` -- to install the data-center driver.
       * ``NVIDIA Container Toolkit`` -- to ensure that containers can access GPUs.
       * ``NVIDIA Device Plugin for Kubernetes`` -- to discover and advertise GPU resources to kubelet.
       * ``NVIDIA DCGM and DCGM Exporter`` -- to monitor GPUs.
       * ``NVIDIA MIG Manager for Kubernetes`` -- to manage MIG-capable GPUs.
       * ``Node Feature Discovery`` -- to detect CPU, kernel, and host features and label worker nodes.
       * ``NVIDIA GPU Feature Discovery`` -- to detect NVIDIA GPUs and label worker nodes.
     - * ``NVIDIA Confidential Computing Manager for Kubernetes`` -- to set the confidential computing (CC) mode on the NVIDIA GPUs.
         This component is deployed to all nodes configured for Kata Containers, even if you are not planning to run Confidential Containers.
         Refer to the :doc:`Confidential Containers <cc:index>` documentation for more details.
       * ``NVIDIA Sandbox Device Plugin`` -- to discover and advertise the passthrough GPUs to kubelet.
       * ``NVIDIA VFIO Manager`` -- to bind NVIDIA GPUs and NVIDIA NVSwitches to the vfio-pci driver for VFIO passthrough.
       * ``Node Feature Discovery`` -- to detect CPU security features, NVIDIA GPUs, and label worker nodes.

This configuration can be controlled through node labelling, as described in the :ref:`Label Nodes <label-nodes-kata-containers>` section.
You can also set ``sandboxWorkloads.defaultWorkload=vm-passthrough`` when you install the GPU Operator to configure all nodes to run Kata Containers by default.


**********************************************
Configure the GPU Operator for Kata Containers
**********************************************

To enable Kata Containers for GPUs on your cluster, you do the following:

#. Make sure your cluster meets the prerequisites.
#. Label the nodes you want to use for Kata Containers.
#. Install the upstream ``kata-deploy`` Helm chart, which deploys all Kata runtime classes, including NVIDIA-specific runtime classes. 
   The ``kata-qemu-nvidia-gpu`` runtime class is used with Kata Containers.
#. Install the NVIDIA GPU Operator with Kata sandbox mode enabled. 

After installation, you can run a sample workload that uses the Kata runtime class.

Prerequisites
=============

Hardware and BIOS
-----------------

* Ensure hosts are configured to enable hardware virtualization and Access Control Services (ACS).
  With some AMD CPUs and BIOSes, ACS might be grouped under Advanced Error Reporting (AER).
  Enabling these features is typically performed by configuring the host BIOS.

* Configure hosts to support IOMMU.
  You can check if your host is configured for IOMMU by running the following command:

  .. code-block:: console

     $ ls /sys/kernel/iommu_groups

  If the output of this command includes 0, 1, and so on, then your host is configured for IOMMU.

  If the host is not configured or if you are unsure, add the ``intel_iommu=on`` (or ``amd_iommu=on`` for AMD CPUs) Linux kernel command-line argument.
  For most Linux distributions, add the argument to the ``/etc/default/grub`` file:

  .. code-block:: text

     ...
     GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on modprobe.blacklist=nouveau"
     ...

  On Ubuntu systems, run ``sudo update-grub`` after making the change to configure the bootloader.
  On other systems, you might need to run ``sudo dracut`` after making the change.
  Refer to the documentation for your operating system.
  Reboot the host after configuring the bootloader.

  .. note::

     After configuring IOMMU, you might see QEMU warnings about PCI P2P DMA when running GPU workloads.
     These are expected and can be safely ignored.

* Ensure that no NVIDIA GPU drivers are installed on the host.
  Kata Containers uses VFIO to pass GPUs directly to the VM, and host-level GPU drivers interfere with VFIO device binding.

  To check if NVIDIA GPU drivers are installed, run the following command:

  .. code-block:: console

     $ lsmod | grep nvidia

  If the output is empty, no NVIDIA GPU drivers are loaded.
  If modules such as ``nvidia``, ``nvidia_uvm``, or ``nvidia_modeset`` are listed, NVIDIA GPU drivers are present and must be removed before proceeding.
  Refer to `Removing the Driver <https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/removing-the-driver.html>`_ in the NVIDIA Driver Installation Guide.

Kubernetes Cluster
------------------

* A Kubernetes cluster with cluster administrator privileges.

* Helm installed on your cluster.
  Refer to the `Helm documentation <https://helm.sh/docs/intro/install/>`_ for installation instructions.

* Enable the ``KubeletPodResourcesGet`` Kubelet feature gate on your cluster.
  The Kata runtime uses this feature gate to query the Kubelet Pod Resources API and discover allocated GPU devices during sandbox creation.

  * For Kubernetes v1.34 and later, the ``KubeletPodResourcesGet`` feature gate is enabled by default.

  * For Kubernetes versions older than v1.34, you must explicitly enable the ``KubeletPodResourcesGet`` feature gate.
    Add the feature gate to your Kubelet configuration (typically ``/var/lib/kubelet/config.yaml``):

    .. code-block:: yaml

       apiVersion: kubelet.config.k8s.io/v1beta1
       kind: KubeletConfiguration
       featureGates:
         KubeletPodResourcesGet: true

    If your ``config.yaml`` already has a ``featureGates`` section, add the gate to the existing section rather than creating a duplicate.

    Restart the Kubelet service to apply the changes:

    .. code-block:: console

       $ sudo systemctl restart kubelet

  Refer to the `Kata Containers documentation <https://github.com/kata-containers/kata-containers/blob/main/docs/use-cases/NVIDIA-GPU-passthrough-and-Kata-QEMU.md#kata-runtime>`_ for more details on the Kata runtime and VFIO cold-plug.

.. _label-nodes-kata-containers:

Label Nodes to use Kata Containers
==================================

#. Get a list of the nodes in your cluster:

   .. code-block:: console

      $ kubectl get nodes

   *Example Output:*

   .. code-block:: output

      NAME          STATUS   ROLES           AGE   VERSION
      node-01       Ready    <none>          10d   v1.34.0
      node-02       Ready    <none>          10d   v1.34.0

#. Label the nodes you want to use for Kata Containers:

   .. code-block:: console

      $ kubectl label node <node-name> nvidia.com/gpu.workload.config=vm-passthrough

   The GPU Operator uses this label to determine what software components to deploy to a node.
   The ``nvidia.com/gpu.workload.config=vm-passthrough`` label specifies that the node should receive the software components to run Kata Containers.
   A node can only run one container runtime at a time, so a labeled node runs only Kata container workloads and cannot run traditional GPU container workloads.
   The labeling approach is useful if you want to run Kata container workloads on some nodes and traditional GPU container workloads on other nodes in your cluster.
   Refer to the :ref:`GPU Operator Cluster Topology Considerations <kata-containers-cluster-topology-considerations>` section for more details on what gets deployed to a Kata Container node.

   .. tip::

      Skip this section if you plan to set ``sandboxWorkloads.defaultWorkload=vm-passthrough`` when you install the GPU Operator.

#. Verify the node label was added:

   .. code-block:: console

      $ kubectl describe node <node-name> | grep nvidia.com/gpu.workload.config

   *Example Output:*

   .. code-block:: output

      nvidia.com/gpu.workload.config: vm-passthrough

After labeling the nodes, you can continue to the next steps to install Kata Containers and the NVIDIA GPU Operator.

Install the Kata Containers Helm Chart
=======================================

Install Kata Containers using the ``kata-deploy`` Helm chart.
The ``kata-deploy`` chart installs all required components from the Kata Containers project including the Kata Containers runtime binary, runtime configuration, UVM kernel, and images that NVIDIA uses for Kata Containers.

The minimum required version is 3.29.0.

#. Get the latest version of the ``kata-deploy`` Helm chart:

   .. code-block:: console

      $ export VERSION="3.29.0"
      $ export CHART="oci://ghcr.io/kata-containers/kata-deploy-charts/kata-deploy"


#. Install the kata-deploy Helm chart:

   .. code-block:: console

      $ helm install kata-deploy "${CHART}" \
         --namespace kata-system --create-namespace \
         --set nfd.enabled=false \
         --wait --timeout 10m \
         --version "${VERSION}"

   *Example Output:*

   .. code-block:: output

      LAST DEPLOYED: Wed Apr  1 17:03:00 2026
      NAMESPACE: kata-system
      STATUS: deployed
      REVISION: 1
      DESCRIPTION: Install complete
      TEST SUITE: None

   .. note::

      The ``--wait`` flag in the install command instructs Helm to wait until the release is deployed before returning.
      It can take a few minutes to return output.

      There is a `known Helm issue <https://github.com/helm/helm/issues/8660>`_ on single node clusters, that may result in the Helm command finishing before all deployed pods are finished initializing.
      If you are deploying to a single node cluster, you may need to wait for an additional few minutes after the Helm command completes for the ``kata-deploy`` pod to be in the Running state.

   .. note::

      Node Feature Discovery (NFD) is deployed by both kata-deploy and the GPU Operator. Pass ``--set nfd.enabled=false`` to disable NFD in kata-deploy so that the GPU Operator manages NFD in the next step.


#. Optional: Verify that the ``kata-deploy`` pod is running:

   .. code-block:: console

      $ kubectl get pods -n kata-system | grep kata-deploy

   *Example Output:*

   .. code-block:: output

      NAME                    READY   STATUS    RESTARTS      AGE
      kata-deploy-b2lzs       1/1     Running   0             6m37s

#. Optional: Verify that the ``kata-qemu-nvidia-gpu`` runtime class is available:

   .. code-block:: console

      $ kubectl get runtimeclass | grep kata-qemu-nvidia-gpu

   *Example Output:*

   .. code-block:: output

      NAME                       HANDLER                    AGE
      kata-qemu-nvidia-gpu       kata-qemu-nvidia-gpu       40s
      kata-qemu-nvidia-gpu-snp   kata-qemu-nvidia-gpu-snp   40s
      kata-qemu-nvidia-gpu-tdx   kata-qemu-nvidia-gpu-tdx   40s

   Several runtime classes are installed by the ``kata-deploy`` chart.
   The ``kata-qemu-nvidia-gpu`` runtime class is used with Kata Containers.
   The ``kata-qemu-nvidia-gpu-snp`` and ``kata-qemu-nvidia-gpu-tdx`` runtime classes are used to deploy :doc:`Confidential Containers <cc:index>`.

   If you have an issue deploying the ``kata-deploy`` pod, you can view the logs with the following command.
   Update the <pod-name> placeholder with the name of the ``kata-deploy`` pod.

   .. code-block:: console

      $ kubectl -n kata-system logs kata-deploy-<pod-name>

   .. note::

      To manage the lifecycle of Kata Containers, including upgrades and day-two operations,
      install the `Kata Lifecycle Manager <https://github.com/kata-containers/lifecycle-manager>`__.
      This Argo Workflows-based tool is the recommended way to manage Kata Containers deployments.


Install the NVIDIA GPU Operator
===============================

Install the NVIDIA GPU Operator and configure it to deploy Kata Container components.

#. Add and update the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
         && helm repo update

#. Install the GPU Operator.
   The following configures the GPU Operator to deploy the operands that are required for Kata Containers.
   Refer to :ref:`Common Chart Customization Options <chart-customization-options>` for more details on the additional configuration options you can specify when installing the GPU Operator.

   .. code-block:: console

      $ helm install --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --version=${version} \
         --set sandboxWorkloads.enabled=true \
         --set sandboxWorkloads.mode=kata \
         --set nfd.enabled=true \
         --set nfd.nodefeaturerules=true

   *Example Output:*

   .. code-block:: output

      NAME: gpu-operator
      LAST DEPLOYED: Wed Mar 25 17:21:34 2026
      NAMESPACE: gpu-operator
      STATUS: deployed
      REVISION: 1
      DESCRIPTION: Install complete
      TEST SUITE: None

   .. tip::

      Add ``--set sandboxWorkloads.defaultWorkload=vm-passthrough`` if every worker node should use Kata by default.

#. Optional: Verify that all GPU Operator pods, especially the Sandbox Device Plugin and VFIO Manager operands, are running:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator

   *Example Output:*

   .. code-block:: output

      NAME                                                              READY   STATUS    RESTARTS   AGE
      gpu-operator-1766001809-node-feature-discovery-gc-75776475sxzkp   1/1     Running   0          86s
      gpu-operator-1766001809-node-feature-discovery-master-6869lxq2g   1/1     Running   0          86s
      gpu-operator-1766001809-node-feature-discovery-worker-mh4cv       1/1     Running   0          86s
      gpu-operator-f48fd66b-vtfrl                                       1/1     Running   0          86s
      nvidia-cc-manager-7z74t                                           1/1     Running   0          61s
      nvidia-kata-sandbox-device-plugin-daemonset-d5rvg                 1/1     Running   0          30s
      nvidia-sandbox-validator-6xnzc                                    1/1     Running   1          30s
      nvidia-vfio-manager-h229x                                         1/1     Running   0          62s


   .. note::

      The NVIDIA Confidential Computing (CC) Manager for Kubernetes (``nvidia-cc-manager``) is deployed to all nodes :ref:`configured to run Kata containers <label-nodes-kata-containers>`, even if you are not planning to run Confidential Containers.
      This manager sets the confidential computing mode on the NVIDIA GPUs, if your GPU is capable of Confidential Computing, but will not be used if you are deploying in Kata Containers only.
      Refer to :ref:`Confidential Containers <confidential-containers-deploy>` for more details.

#. Optional: If you have host access to the worker node, you can perform the following validation step:

   a. Confirm that the host uses the ``vfio-pci`` device driver for GPUs:

      .. code-block:: console

         $ lspci -nnk -d 10de:

      *Example Output:*

      .. code-block:: output

         65:00.0 3D controller [0302]: NVIDIA Corporation xxxxxxx [xxx] [10de:xxxx] (rev xx)
                 Subsystem: NVIDIA Corporation xxxxxxx [xxx] [10de:xxxx]
                 Kernel driver in use: vfio-pci
                 Kernel modules: nvidiafb, nouveau

.. _kata-configuration-heterogeneous-clusters:

Optional: Configuring the Sandbox Device Plugin to Use GPU or NVSwitch Specific Resource Types
==============================================================================================

By default, the NVIDIA GPU Operator creates a single resource type for GPUs, ``nvidia.com/pgpu``.
In clusters where all GPUs are the same model, a single resource type is sufficient.

In heterogeneous clusters, where you have different GPU types on your nodes, you might want to use specific GPU types for your workload.
To do this, specify an empty ``P_GPU_ALIAS`` environment variable in the sandbox device plugin by adding the following to your GPU Operator installation:
``--set sandboxDevicePlugin.env[0].name=P_GPU_ALIAS`` and
``--set sandboxDevicePlugin.env[0].value=""``.

When this variable is set to ``""``, the sandbox device plugin creates GPU model-specific resource types, for example ``nvidia.com/GH100_H100L_94GB``, instead of the default ``nvidia.com/pgpu`` type.
Use the exposed device resource types in pod specs by specifying respective resource limits.

Similarly, NVSwitches are exposed as resources of type ``nvidia.com/nvswitch`` by default.
You can include ``--set sandboxDevicePlugin.env[1].name=NVSWITCH_ALIAS`` and
``--set sandboxDevicePlugin.env[1].value=""`` for the device plugin environment variable when installing the GPU Operator to configure advertising behavior similar to ``P_GPU_ALIAS``.

For example, to configure both GPU and NVSwitch specific resource types:

.. code-block:: console

   $ helm install --generate-name \
      -n gpu-operator --create-namespace \
      nvidia/gpu-operator \
      --version=${version} \
      --set sandboxWorkloads.enabled=true \
      --set sandboxWorkloads.mode=kata \
      --set nfd.enabled=true \
      --set nfd.nodefeaturerules=true \
      --set sandboxDevicePlugin.env[0].name=P_GPU_ALIAS \
      --set sandboxDevicePlugin.env[0].value="" \
      --set sandboxDevicePlugin.env[1].name=NVSWITCH_ALIAS \
      --set sandboxDevicePlugin.env[1].value=""


*********************
Run a Sample Workload
*********************

A pod specification for a Kata container requires the following:

* Specify a Kata runtime class.

* Specify a passthrough GPU resource.


#. Create a file, such as ``cuda-vectoradd-kata.yaml``, with the following content:

   .. code-block:: yaml
      :emphasize-lines: 7,14

      apiVersion: v1
      kind: Pod
      metadata:
        name: cuda-vectoradd-kata
        namespace: default
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

   *Example Output:*

   .. code-block:: output

      pod/cuda-vectoradd-kata created

#. Optional: Verify the pod is running:

   .. code-block:: console

      $ kubectl get pod cuda-vectoradd-kata

   *Example Output:*

   .. code-block:: output

      NAME                  READY   STATUS    RESTARTS   AGE
      cuda-vectoradd-kata   1/1     Running   0          10s

#. View the pod logs:

   .. code-block:: console

      $ kubectl logs -n default cuda-vectoradd-kata

   *Example Output:*

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

If the sample workload does not run, confirm that you labeled nodes to run virtual machines in containers:

.. code-block:: console

   $ kubectl get nodes -l nvidia.com/gpu.workload.config=vm-passthrough

*Example Output:*

.. code-block:: output

   NAME               STATUS   ROLES    AGE   VERSION
   kata-worker-1      Ready    <none>   10d   v1.35.3 
   kata-worker-2      Ready    <none>   10d   v1.35.3 
   kata-worker-3      Ready    <none>   10d   v1.35.3

You might have configured ``vm-passthrough`` as the default sandbox workload in the ClusterPolicy resource.
That setting applies the default sandbox workload cluster-wide, including for Kata when ``mode`` is ``kata``.
Also confirm in the ClusterPolicy that ``sandboxWorkloads`` is configured for Kata as shown in the following example.

.. code-block:: console

   $ kubectl describe clusterpolicy | grep sandboxWorkloads

*Example Output:*

.. code-block:: output

   sandboxWorkloads:
     enabled: true
     defaultWorkload: vm-passthrough
     mode: kata

