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

..
   lingo:

   It is "Kata Containers" when referring to the software component.
   It is "Kata container" when it is a container that uses the Kata Containers runtime.
   Treat our operands as proper nouns and use title case.

#################################
GPU Operator with Kata Containers
#################################


***************************************
About the Operator with Kata Containers
***************************************

.. note:: Technology Preview features are not supported in production environments
          and are not functionally complete.
          Technology Preview features provide early access to upcoming product features,
          enabling customers to test functionality and provide feedback during the development process.
          These releases may not have any documentation, and testing is limited.

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


To enable Kata Containers for GPUs, install the upstream kata-deploy Helm chart, which deploys all Kata runtime classes, including NVIDIA-specific runtime classes.

* The ``kata-qemu-nvidia-gpu`` runtime class is used with Kata Containers.

* The ``kata-qemu-nvidia-gpu-snp`` runtime class is used with Confidential Containers and is installed by default even though it is not used with this configuration.

Then configure the GPU Operator to use Kata mode for sandbox workloads and, optionally, the Kata device plugin.


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

* Uninstalling the GPU Operator does not remove the files
  that are downloaded and installed in the ``/opt/nvidia-gpu-operator/artifacts/runtimeclasses/kata-qemu-nvidia-gpu/``
  directory on the worker nodes.

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
       * ``Node Feature Discovery`` -- to detect CPU, kernel, and host features and label worker nodes.
       * ``NVIDIA GPU Feature Discovery`` -- to detect NVIDIA GPUs and label worker nodes.
     - * ``NVIDIA Sandbox Device Plugin`` -- to discover and advertise the passthrough GPUs to kubelet.
       * ``NVIDIA VFIO Manager`` -- to load the vfio-pci device driver and bind it to all GPUs on the node.
       * ``Node Feature Discovery`` -- to detect CPU security features, NVIDIA GPUs, and label worker nodes.


**********************************************
Configure the GPU Operator for Kata Containers
**********************************************

Prerequisites
=============

* Your hosts are configured to enable hardware virtualization and Access Control Services (ACS).
  With some AMD CPUs and BIOSes, ACS might be grouped under Advanced Error Reporting (AER).
  Enabling these features is typically performed by configuring the host BIOS.

* Your hosts are configured to support IOMMU.

  If the output from running ``ls /sys/kernel/iommu_groups`` includes ``0``, ``1``, and so on,
  then your host is configured for IOMMU.

  If a host is not configured or you are unsure, add the ``intel_iommu=on`` Linux kernel command-line argument.
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

* It is recommended that you configure your Kubelet with a higher ``runtimeRequestTimeout`` timeout value than the two minute default timeout. 
  Using the guest-pull mechanism, pulling large images may take a significant amount of time and may delay container start, possibly leading your Kubelet to de-allocate your pod before it transitions from the container created to the container running state.

* The NVIDIA GPU runtime classes use VFIO cold-plug which requires the Kata runtime to query Kubelet's Pod Resources API to discover allocated GPU devices during sandbox creation. 
  For Kubernetes versions older than 1.34, you must explicitly enable the ``KubeletPodResourcesGet`` feature gate in your Kubelet configuration. 
  For Kubernetes 1.34 and later, the ``KubeletPodResourcesGet`` feature gate is enabled by default.


Overview of Installation and Configuration
===========================================

Installing and configuring your cluster to support the NVIDIA GPU Operator with Kata Containers is as follows:

#. Label the worker nodes that you want to use with Kata Containers.

   .. code-block:: console

      $ kubectl label node <node-name> nvidia.com/gpu.workload.config=vm-passthrough

   This step ensures that you can continue to run traditional container workloads with GPU or vGPU workloads on some nodes in your cluster.
   Alternatively, if you want to run confidential containers on all your worker nodes, set the default sandbox workload to ``vm-passthrough`` when you install the GPU Operator.

#. Install kata-deploy Helm chart.

#. Install the NVIDIA GPU Operator.

   You install the Operator and specify options to deploy the operands that are required for Kata Containers.

After installation, you can run a sample workload.


Install Kata-deploy
===================

Install the kata-deploy Helm chart. 
Minimum required version is 3.24.0.

#. Get the latest version of the kata-deploy Helm chart:

   .. code-block:: console

      $ export VERSION="3.26.0"
      $ export CHART="oci://ghcr.io/kata-containers/kata-deploy-charts/kata-deploy"


#. Install the kata-deploy Helm chart:

   .. code-block:: console

     $ helm install kata-deploy "${CHART}" \
       --namespace kata-system --create-namespace \
       --version "${VERSION}"


#. Optional: Verify that the kata-deploy pod is running:

   .. code-block:: console

      $ kubectl get pods -n kata-system | grep kata-deploy

   *Example Output*

   .. code-block:: output

      NAME                    READY   STATUS    RESTARTS      AGE
      kata-deploy-b2lzs       1/1     Running   0             6m37s

#. Optional, verify that the ``kata-qemu-nvidia-gpu`` and ``kata-qemu-nvidia-gpu-snp`` runtime classes are available:

   .. code-block:: console

      $ kubectl get runtimeclass

   *Example Output*

   .. code-block:: output
      :emphasize-lines: 6, 10,11,12

      NAME                       HANDLER                    AGE
      kata-clh                        kata-clh                        53s
      kata-cloud-hypervisor           kata-cloud-hypervisor           53s
      kata-dragonball                 kata-dragonball                 53s
      kata-fc                         kata-fc                         53s
      kata-qemu                       kata-qemu                       53s
      kata-qemu-cca                   kata-qemu-cca                   53s
      kata-qemu-coco-dev              kata-qemu-coco-dev              53s
      kata-qemu-coco-dev-runtime-rs   kata-qemu-coco-dev-runtime-rs   53s
      kata-qemu-nvidia-gpu            kata-qemu-nvidia-gpu            53s
      kata-qemu-nvidia-gpu-snp        kata-qemu-nvidia-gpu-snp        53s
      kata-qemu-nvidia-gpu-tdx        kata-qemu-nvidia-gpu-tdx        53s
      kata-qemu-runtime-rs            kata-qemu-runtime-rs            53s
      kata-qemu-se                    kata-qemu-se                    53s
      kata-qemu-se-runtime-rs         kata-qemu-se-runtime-rs         53s
      kata-qemu-snp                   kata-qemu-snp                   53s
      kata-qemu-snp-runtime-rs        kata-qemu-snp-runtime-rs        53s
      kata-qemu-tdx                   kata-qemu-tdx                   53s
      kata-qemu-tdx-runtime-rs        kata-qemu-tdx-runtime-rs        53s



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
         --set sandboxWorkloads.mode=kata 


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
      :emphasize-lines: 5,8

      NAME                                                         READY   STATUS      RESTARTS   AGE
      gpu-operator-779cff6c69-9v7tv                                 1/1     Running             0          23m
      gpu-operator-node-feature-discovery-gc-775976dc9d-742cw       1/1     Running             0          23m
      gpu-operator-node-feature-discovery-master-6c86bc9c69-v2vvf   1/1     Running             0          23m
      gpu-operator-node-feature-discovery-worker-jhr6m              1/1     Running             0          23m
      nvidia-cc-manager-4d5xl                                       1/1     Running             0          19m
      nvidia-cuda-validator-sk27m                                   0/1     Completed           0          20m
      nvidia-kata-sandbox-device-plugin-daemonset-4mhf2             1/1     Running             0          19m
      nvidia-sandbox-validator-w9bdg                                1/1     Running             0          19m
      nvidia-vfio-manager-5phzl                                     1/1     Running             0          19m

#. Verify that the ``kata-qemu-nvidia-gpu`` and ``kata-qemu-nvidia-gpu-snp`` runtime classes are available:

   .. code-block:: console

      $ kubectl get runtimeclass

   *Example Output*

   .. code-block:: output
      :emphasize-lines: 10, 11

      NAME                       HANDLER                    AGE
      kata-clh                        kata-clh                        53s
      kata-cloud-hypervisor           kata-cloud-hypervisor           53s
      kata-dragonball                 kata-dragonball                 53s
      kata-fc                         kata-fc                         53s
      kata-qemu                       kata-qemu                       53s
      kata-qemu-cca                   kata-qemu-cca                   53s
      kata-qemu-coco-dev              kata-qemu-coco-dev              53s
      kata-qemu-coco-dev-runtime-rs   kata-qemu-coco-dev-runtime-rs   53s
      kata-qemu-nvidia-gpu            kata-qemu-nvidia-gpu            53s
      kata-qemu-nvidia-gpu-snp        kata-qemu-nvidia-gpu-snp        53s
      kata-qemu-nvidia-gpu-tdx        kata-qemu-nvidia-gpu-tdx        53s
      kata-qemu-runtime-rs            kata-qemu-runtime-rs            53s
      kata-qemu-se                    kata-qemu-se                    53s
      kata-qemu-se-runtime-rs         kata-qemu-se-runtime-rs         53s
      kata-qemu-snp                   kata-qemu-snp                   53s
      kata-qemu-snp-runtime-rs        kata-qemu-snp-runtime-rs        53s
      kata-qemu-tdx                   kata-qemu-tdx                   53s
      kata-qemu-tdx-runtime-rs        kata-qemu-tdx-runtime-rs        53s


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

   #. Confirm that NVIDIA Kata Manager installed the ``kata-qemu-nvidia-gpu`` runtime class files:

      .. code-block:: console

         $ ls -1 /opt/nvidia-gpu-operator/artifacts/runtimeclasses/kata-qemu-nvidia-gpu/

      *Example Output*

      .. code-block:: output

         configuration-nvidia-gpu-qemu.toml
         kata-ubuntu-jammy-nvidia-gpu.initrd
         vmlinuz-5.xx.x-xxx-nvidia-gpu
         ...


*********************
Run a Sample Workload
*********************

A pod specification for a Kata container requires the following:

* Specify a Kata runtime class.

* Specify a passthrough GPU resource.

#. Determine the passthrough GPU resource names:

   .. code-block:: console

      $ kubectl get nodes -l nvidia.com/gpu.present -o json | \
          jq '.items[0].status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'

   *Example Output*

   .. code-block:: output

      {
         "nvidia.com/GA102GL_A10": "1"
      }

#. Create a file, such as ``cuda-vectoradd-kata.yaml``, with the following content:

   .. code-block:: yaml
      :emphasize-lines: 6,8,15

      apiVersion: v1
      kind: Pod
      metadata:
        name: cuda-vectoradd-kata
        annotations:
          cdi.k8s.io/gpu: "nvidia.com/pgpu=0"
          io.katacontainers.config.hypervisor.default_memory: "16384"
      spec:
        runtimeClassName: kata-qemu-nvidia-gpu
        restartPolicy: OnFailure
        containers:
        - name: cuda-vectoradd
          image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda11.7.1-ubuntu20.04"
          resources:
            limits:
              "nvidia.com/GA102GL_A10": 1

   The ``io.katacontainers.config.hypervisor.default_memory`` annotation starts the VM with 16 GB of memory.
   Modify the value to accommodate your workload.

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


************************
About the Pod Annotation
************************

The ``cdi.k8s.io/gpu: "nvidia.com/pgpu=0"`` annotation is used when the pod sandbox is created.
The annotation ensures that the virtual machine created by the Kata runtime is created with
the correct PCIe topology so that GPU passthrough succeeds.

The annotation refers to a Container Device Interface (CDI) device, ``nvidia.com/pgpu=0``.
The ``pgpu`` indicates passthrough GPU and the ``0`` indicates the device index.
The index is defined by the order that the GPUs are enumerated on the PCI bus.
The index does not correlate to a CUDA index.

The NVIDIA Kata Manager creates a CDI specification on the GPU nodes.
The file includes a device entry for each passthrough device.

The following sample ``/var/run/cdi/nvidia.com-pgpu.yaml`` shows one GPU bound to the VFIO PCI driver:

.. code-block:: yaml

   cdiVersion: 0.5.0
   containerEdits: {}
   devices:
   - name: "0"
     containerEdits:
       deviceNodes:
       - path: /dev/vfio/10
     kind: nvidia.com/pgpu