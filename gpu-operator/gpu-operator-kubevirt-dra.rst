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

.. headings (h1/h2/h3/h4) are # * = -

.. _gpu-operator-kubevirt-dra:

##################################
GPU Operator with KubeVirt and DRA
##################################

KubeVirt can attach NVIDIA GPUs to virtual machines by using Kubernetes Dynamic Resource Allocation (DRA).
The NVIDIA DRA driver advertises GPUs and their attributes in ``ResourceSlice`` objects.
A ``ResourceClaimTemplate`` selects devices, Kubernetes schedules the virtual machine on a node that can access those devices, and the DRA driver prepares the allocation for VFIO passthrough.

With the DRA driver, you can run mixed workloads---containers and VMs---on the same node.
This is an important difference from the sandbox device plugin, where a node cannot run mixed workloads.

This workflow uses a GPU Operator-managed ``GPUCluster`` resource and DRA operands.
For passthrough with the sandbox device plugin, or for NVIDIA vGPU mediated devices, refer to :ref:`gpu-operator-kubevirt`.

****************************
Understanding GPU Assignment
****************************

With DRA, the device request specifies the required device type and attributes.
Kubernetes allocates devices that satisfy the request and schedules the virtual machine on the node that advertises them.
The DRA driver then binds each allocated GPU to ``vfio-pci`` while the claim is prepared and restores it when the claim is unprepared.
On supported systems, Fabric Manager partitioning can additionally constrain a multi-GPU claim to a valid NVSwitch fabric partition.

GPU Operator discovers GPU nodes and manages operand placement.

******************************************
Assumptions, Constraints, and Dependencies
******************************************

* The examples allocate full GPUs from the ``vfio.gpu.nvidia.com`` DeviceClass.
  MIG device allocation is outside the scope of this procedure.
* An allocated GPU cannot be used by another workload until the claim is unprepared.
* Host services and workloads must release open handles to a GPU before it can be bound to ``vfio-pci``.
* KubeVirt supports exactly one allocated device for each named request.
  Use one named request for each GPU, as shown in this procedure.
* Do not mix DRA and device-plugin GPU entries in the same virtual machine.
* Virtual machines with passthrough GPUs cannot be live migrated.
* With ``PassthroughSupport`` enabled, the DRA driver initially advertises each eligible physical GPU as both a GPU device and a VFIO device.
  These entries represent the same hardware.

  If a container GPU claim and a VFIO claim for the same GPU are allocated before either claim is prepared, Kubernetes can allocate both.
  The first preparation succeeds and the other fails.

  To avoid this race, submit container and VM workloads serially and wait for device preparation, or dedicate separate nodes to container and VFIO workloads.
  You could also use labels and node selectors to avoid the race condition.
  Refer to `Limitations and Considerations <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/guides/gpu-allocation/kubevirt-vfio-gpu-passthrough/#limitations-and-considerations>`__ in the DRA driver documentation for more information.

* DCGM and DCGM Exporter cannot be enabled on the KubeVirt nodes.
* GPU Operator does not install the NVIDIA driver in the guest operating system.

*************
Prerequisites
*************

Before you begin, verify the following prerequisites:

* Follow :ref:`DRA Driver for NVIDIA GPUs` to install GPU Operator with the ``GPUCluster`` custom resource and validate the installation.
  The ``gpu-cluster`` resource must be ready, and no ``ClusterPolicy`` resource can exist in the cluster.
* Use Kubernetes v1.34.2 or later, an NVIDIA GPU driver version 580 or later,
  and a Container Device Interface-compatible container runtime, as described in the DRA driver procedure.
* Install KubeVirt v1.8.0 or later.
  KubeVirt v1.8.x requires the ``GPUsWithDRA`` feature gate.
  The gate is enabled by default in KubeVirt v1.9.0 and later.

  .. note::

     On Kubernetes v1.34, KubeVirt's ``ImageVolume`` feature can prevent ``containerDisk``-backed virtual machines, including the example in this procedure, from starting.
     Disable ``ImageVolume`` in the KubeVirt custom resource, or use Kubernetes v1.35 or later.
     For more information, refer to `KubeVirt issue #17460 <https://github.com/kubevirt/kubevirt/issues/17460>`__.
* Use bare-metal GPU worker nodes with CPU virtualization and IOMMU enabled in the firmware.
  Boot the hosts with ``intel_iommu=on`` or ``amd_iommu=on``, as appropriate.
* Install the ``virtctl`` command-line tool for troubleshooting.
* Ensure that you use a guest operating system that has a supported NVIDIA driver.

Fabric Manager partitioning is optional and hardware-specific.
It applies only to supported HGX or single-node NVL systems with an NVSwitch-managed fabric and a supported partition topology.
The optional partitioning steps in this procedure apply to the systems with NVLink 5 or later.


***********************************************
Optional: Configure Fabric Manager Partitioning
***********************************************

Fabric Manager must run in partitioning mode and provide a UNIX socket that the DRA driver can access.
Skip this section on systems that do not support Fabric Manager partitioning or when you do not need topology-constrained allocation.
Use the procedure that matches how the NVIDIA driver is installed.

Operator-Managed Driver
=======================

#. Stop GPU workloads on the target nodes.
   Updating the ``NVIDIADriver`` resource restarts the driver pods and can reset GPUs when Fabric Manager partitioning is enabled.

#. List the ``NVIDIADriver`` resources and identify the resource that applies to the target nodes:

   .. code-block:: console

      $ kubectl get nvidiadriver

#. Edit the ``NVIDIADriver`` resource:

   .. code-block:: console
      :force:

      $ kubectl patch nvidiadriver <driver-name> \
          --type=merge -p '{
            "spec":{
              "env":[
                {"name":"NVFM_CONFIG_FABRIC_MODE","value":"1"},
                {"name":"NVFM_CONFIG_FM_CMD_UNIX_SOCKET_PATH","value":"/run/nvidia-fabricmanager/socket"}
              ]}}'

   The GPU Operator adds these variables to the driver container.
   The driver container configures and starts Fabric Manager.

#. Wait for the ``NVIDIADriver`` resource to return to the ready state:

   .. code-block:: console

      $ kubectl get nvidiadriver <driver-name>

Pre-Installed Driver
====================

#. Stop GPU workloads on the target nodes and stop Fabric Manager:

   .. code-block:: console

      $ sudo systemctl stop nvidia-fabricmanager

#. In the Fabric Manager configuration file, configure the following settings:

   .. code-block:: ini

      FABRIC_MODE=1
      FM_CMD_UNIX_SOCKET_PATH=/run/nvidia-fabricmanager/socket

   The configuration file is typically located at ``/usr/share/nvidia/nvswitch/fabricmanager.cfg``.

#. Optional: If stale partition state must be cleared, reset the GPUs while they are idle:

   .. code-block:: console

      $ sudo nvidia-smi --gpu-reset

   A GPU reset disrupts workloads that use the affected GPUs.

#. Start Fabric Manager and verify that the service is running:

   .. code-block:: console

      $ sudo systemctl start nvidia-fabricmanager
      $ sudo systemctl status nvidia-fabricmanager

******************************
Disable DCGM and DCGM Exporter
******************************

DCGM and DCGM Exporter are not supported on KubeVirt nodes that use VFIO passthrough.
Both operands keep NVIDIA client connections open and prevent the driver from rebinding a GPU to the VFIO driver.

Disable both operands in the ``GPUCluster`` resource before you enable VFIO support:

.. code-block:: console
   :force:

   $ kubectl patch gpucluster gpu-cluster \
       --type=merge -p '{"spec":{"dcgm":{"enabled":false},"dcgmExporter":{"enabled":false}}}'

****************************
Enable VFIO Support with DRA
****************************

Enable ``PassthroughSupport`` and ``DeviceMetadata`` in the ``GPUCluster`` resource.

#. Add the feature gates under ``spec.draDriver.featureGates``.
   Preserve any other DRA driver settings:

   .. code-block:: console
      :force:

      $ kubectl patch gpucluster gpu-cluster \
          --type=merge -p '{
              "spec":{
                "draDriver":{
                  "computeDomains":{"enabled":false},
                  "featureGates":{
                    "PassthroughSupport":true,
                    "DeviceMetadata":true
                  }}}}'

   ``PassthroughSupport`` enables allocation with ``VfioDeviceConfig``.
   ``DeviceMetadata`` provides KubeVirt with the PCI address for each allocated device and exposes the VFIO API device to the ``virt-launcher`` pod.
   GPU Operator continues to manage the DRA driver, DeviceClasses, RBAC, and operand lifecycle.

#. Optional: If you configured Fabric Manager partitioning, also enable the ``FabricManagerPartitioning`` feature gate.
   Perform this step only on supported HGX or single-node NVL systems with an NVSwitch-managed fabric:

   .. code-block:: console
      :force:

      $ kubectl patch gpucluster gpu-cluster \
          --type=merge -p '{
              "spec":{
                "draDriver":{
                  "featureGates":{
                    "FabricManagerPartitioning":true  # For NVLink 5 or later systems with NVSwitch-managed fabric.
                  }}}}'

#. Wait until GPU Operator finishes reconciling the change:

   .. code-block:: console

      $ kubectl get gpucluster gpu-cluster

   The ``STATUS`` column must show ``ready``.

*******************************
Configure KubeVirt for DRA GPUs
*******************************

#. For KubeVirt v1.8.x, add ``GPUsWithDRA`` to the existing feature-gate list in the ``KubeVirt`` custom resource:

   .. code-block:: console

      $ kubectl patch kubevirt kubevirt \
          --namespace kubevirt \
          --type=json \
          -p='[{"op": "add", "path": "/spec/configuration/developerConfiguration/featureGates/-", "value": "GPUsWithDRA"}]'

   The JSON patch appends ``GPUsWithDRA`` and leaves other feature gates unchanged.
   Skip this step with KubeVirt v1.9.0 and later, where ``GPUsWithDRA`` is enabled by default.

#. Wait for KubeVirt to become available:

   .. code-block:: console

      $ kubectl wait kubevirt/kubevirt \
          --namespace kubevirt \
          --for=condition=Available \
          --timeout=5m

For more information, refer to
`Assigning GPUs with Dynamic Resource Allocation <https://kubevirt.io/user-guide/compute/dra_gpu/>`__
in the KubeVirt documentation.

********************
Verify DRA Resources
********************

#. Verify that the VFIO DeviceClass exists:

   .. code-block:: console

      $ kubectl get deviceclass vfio.gpu.nvidia.com

#. List the ResourceSlices advertised by the DRA driver:

   .. code-block:: console

      $ kubectl get resourceslices

   Confirm that the target GPU node has a ResourceSlice for the ``gpu.nvidia.com``
   driver. The claim allocation later in this procedure verifies that the
   ``vfio.gpu.nvidia.com`` DeviceClass can select devices from the node.

#. Optional: If you enabled Fabric Manager partitioning on the target node,
   inspect the ResourceSlice in YAML format:

   .. code-block:: console

      $ kubectl get resourceslice <slice-name> -o yaml

   The driver publishes partition membership through attributes named ``partitionN``,
   where ``N`` is ``1``, ``2``, ``4``, or ``8`` and specifies the number of GPUs in the partition.
   The attribute value is the Fabric Manager partition ID.
   For example, ``partition2: 4`` indicates that the GPU belongs to two-GPU partition 4.

   Confirm that devices with the ``gpu.nvidia.com/type`` attribute set to
   ``vfio`` include a ``gpuModuleID`` attribute and the ``partitionN`` attributes
   reported for the hardware. For the two-GPU example in this procedure, at
   least two VFIO devices must advertise the same ``partition2`` value.

   Nodes without a supported NVSwitch-managed fabric do not advertise these
   attributes and do not require the remaining Fabric Manager-specific checks.
   If the target node has supported hardware and is configured for Fabric Manager
   partitioning, missing attributes indicate a configuration problem. Verify the
   Fabric Manager service, socket, and DRA kubelet-plugin logs before continuing.

***************************
Create a GPU Claim Template
***************************

#. Create a file named ``kubevirt-vfio-gpus.yaml`` with the following contents.
   The template requests two VFIO GPUs:

   .. code-block:: yaml

      apiVersion: resource.k8s.io/v1
      kind: ResourceClaimTemplate
      metadata:
        name: kubevirt-vfio-gpus
      spec:
        spec:
          devices:
            config:
            - requests:
              - gpu0
              - gpu1
              opaque:
                driver: gpu.nvidia.com
                parameters:
                  apiVersion: resource.nvidia.com/v1beta1
                  kind: VfioDeviceConfig
                  iommu:
                    backendPolicy: LegacyOnly
                    enableAPIDevice: true
            requests:
            - name: gpu0
              exactly:
                allocationMode: ExactCount
                count: 1
                deviceClassName: vfio.gpu.nvidia.com
            - name: gpu1
              exactly:
                allocationMode: ExactCount
                count: 1
                deviceClassName: vfio.gpu.nvidia.com

   ``backendPolicy: LegacyOnly`` selects the legacy VFIO IOMMU backend required by KubeVirt.
   ``enableAPIDevice: true`` exposes ``/dev/vfio/vfio`` to ``virt-launcher``.

#. Optional: If you enabled Fabric Manager partitioning and the target hardware advertises ``partition2``,
   add the following constraint under ``spec.spec.devices``:

   .. code-block:: yaml

      constraints:
      - requests:
        - gpu0
        - gpu1
        matchAttribute: gpu.nvidia.com/partition2

   The constraint requires both GPUs to have the same two-GPU partition ID.
   Combined with the two single-GPU requests, this selects a complete two-GPU partition.
   Use only a ``partitionN`` attribute that appears in the target node's ``ResourceSlice``.

#. Apply the manifest in the namespace where you will create the virtual machine:

   .. code-block:: console

      $ kubectl apply -f kubevirt-vfio-gpus.yaml

   The ``ResourceClaimTemplate`` is namespace-scoped.

************************************
Create a VM That Uses the GPU Claim
************************************

#. Create a file named ``dra-gpu-vm.yaml`` with the following contents.
   The virtual machine creates a claim from the template and maps one GPU to each named request:

   .. code-block:: yaml

      apiVersion: kubevirt.io/v1
      kind: VirtualMachine
      metadata:
        name: dra-gpu-vm
      spec:
        runStrategy: Always
        template:
          metadata:
            labels:
              kubevirt.io/domain: dra-gpu-vm
          spec:
            resourceClaims:
            - name: gpu-claim
              resourceClaimTemplateName: kubevirt-vfio-gpus
            domain:
              cpu:
                cores: 8
              devices:
                disks:
                - name: containerdisk
                  disk:
                    bus: virtio
                - name: cloudinitdisk
                  disk:
                    bus: virtio
                gpus:
                - name: gpu0
                  claimName: gpu-claim
                  requestName: gpu0
                - name: gpu1
                  claimName: gpu-claim
                  requestName: gpu1
              resources:
                requests:
                  memory: 64Gi
            volumes:
            - name: containerdisk
              containerDisk:
                image: quay.io/containerdisks/fedora:44
            - name: cloudinitdisk
              cloudInitNoCloud:
                userData: |-
                  #cloud-config
                  users:
                  - name: fedora
                    groups: wheel
                    sudo: ALL=(ALL) NOPASSWD:ALL
                    shell: /bin/bash
                    lock_passwd: false
                  chpasswd:
                    list: |
                      fedora:fedora
                    expire: false

#. Verify that the following names match between the virtual machine and claim template:

   * ``resourceClaimTemplateName`` matches the ``ResourceClaimTemplate`` name.
   * ``claimName`` matches the name under ``spec.template.spec.resourceClaims``.
   * Each ``requestName`` matches one request in the claim template.

#. Apply the manifest and wait for the virtual machine instance to become ready:

   .. code-block:: console

      $ kubectl apply -f dra-gpu-vm.yaml
      $ kubectl wait vmi/dra-gpu-vm --for=condition=Ready --timeout=10m

#. Access the guest through its serial console:

   .. code-block:: console

      $ virtctl console dra-gpu-vm

   Log in as ``fedora`` with the password ``fedora``.
   Change or remove these demonstration credentials before using the manifest in another environment.
   The writable layer of a ``containerDisk`` is ephemeral and does not survive VMI recreation.
   Use persistent guest storage for a long-running virtual machine.

****************************************
Install the Guest Driver and Verify GPUs
****************************************

The host driver and guest driver are separate installations.
Follow the `NVIDIA Driver Installation Guide for Fedora <https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/fedora.html>`__
to select a driver that is compatible with the guest kernel and the assigned GPUs.

Install the Guest Driver
========================

#. For the Fedora 44 image in the example, run the following commands in the guest:

   .. code-block:: console

      $ sudo dnf -y install kernel-devel-matched kernel-headers dnf-plugins-core
      $ sudo dnf config-manager addrepo \
          --from-repofile=https://developer.download.nvidia.com/compute/cuda/repos/fedora44/x86_64/cuda-fedora44.repo
      $ sudo dnf clean expire-cache
      $ sudo dnf -y install nvidia-driver-cuda kmod-nvidia-open-dkms
      $ sudo reboot

Verify the GPUs on Any Supported Host
=====================================

#. Verify that the generated claim is allocated and reserved:

   .. code-block:: console

      $ kubectl get resourceclaims

   The ``STATE`` column must show ``allocated,reserved``.

#. Reconnect to the console after the virtual machine reboots and verify GPU
   enumeration and topology:

   .. code-block:: console

      $ nvidia-smi -L
      $ nvidia-smi topo -m

   The first command must list both assigned GPUs.
   The topology output depends on the hardware and can show a PCIe connection on
   systems without NVLink or NVSwitch.

   This verification applies to every supported host. If you did not configure
   Fabric Manager partitioning, skip the Fabric Manager-specific verification
   that follows.

Optional: Verify Fabric Manager Partitioning
============================================

Perform these steps only when the target node has a supported NVSwitch-managed
fabric, Fabric Manager partitioning is configured, and the ResourceSlice
advertises the required ``partitionN`` attribute.

#. Inspect the generated claim's allocation:

   .. code-block:: console

      $ kubectl get resourceclaim <claim-name> -o yaml

   Compare the devices under ``status.allocation.devices.results`` with the
   target node's ResourceSlice. For the example in this procedure, the devices
   allocated for ``gpu0`` and ``gpu1`` must have the same ``partition2`` value.

#. In the guest, verify that the topology output shows the NVLink connection
   expected for the selected partition:

   .. code-block:: console

      $ nvidia-smi topo -m

#. Optional: Verification that relies on additional software.

   #. Build and run the ``list-partitions`` binary.

      Perform the build on a Linux system with Go 1.24 or later and the same CPU
      architecture as the target GPU node.

      #. Clone the `go-nvfm <https://github.com/NVIDIA/go-nvfm/tree/main/examples/list-partitions>`__ repository and build the example:

         .. code-block:: console

            $ git clone --depth 1 https://github.com/NVIDIA/go-nvfm.git
            $ cd go-nvfm
            $ make example-list-partitions

      #. Identify the driver pod on the node that owns the allocated GPUs:

         .. code-block:: console

            $ kubectl get pods --namespace gpu-operator \
                --selector app.kubernetes.io/component=nvidia-driver \
                --field-selector spec.nodeName=<node-name>

      #. Copy the ``list-partitions`` executable to the driver container:

         .. code-block:: console

            $ kubectl cp --namespace gpu-operator \
                --container nvidia-driver-ctr \
                ./list-partitions <driver-pod>:/run/nvidia/list-partitions

      #. List the Fabric Manager partitions:

         .. code-block:: console

            $ kubectl exec --namespace gpu-operator \
                --container nvidia-driver-ctr \
                <driver-pod> -- bash -c \
                "NVFM_UNIX_SOCKET_PATH=/run/nvidia-fabricmanager/socket /run/nvidia/list-partitions"

         Confirm that the partition selected for the claim reports ``"isActive": 1``.

   #. For an additional connectivity demonstration, install a guest-compatible build of
      `nvbandwidth v0.8 <https://github.com/NVIDIA/nvbandwidth/releases/tag/v0.8>`__ and run:

      .. code-block:: console

         $ ./nvbandwidth -t device_to_device_memcpy_read_sm

      A successful run reports device-to-device bandwidth for both GPUs without a CUDA peer-access error.

****************************************
Troubleshooting and Operational Guidance
****************************************

VM Remains Pending
==================

Inspect the generated ``ResourceClaim``, the VM events, and the available VFIO devices:

.. code-block:: console

   $ kubectl get resourceclaims
   $ kubectl describe vm dra-gpu-vm
   $ kubectl get resourceslices

If a partition-constrained claim cannot be allocated, confirm that the target hardware supports Fabric Manager partitioning
and that two VFIO devices advertise the same ``partition2`` value.
Also confirm that the claim template and VM are in the same namespace.

VFIO DeviceClass Is Unavailable
===============================

Verify that the ``gpu-cluster`` resource is ready and that ``PassthroughSupport`` and ``DeviceMetadata`` are enabled.
If you use Fabric Manager partitioning, also verify that ``FabricManagerPartitioning`` is enabled.
Check the GPU Operator namespace for DRA kubelet-plugin errors.

GPU Preparation Does Not Complete
=================================

If the ``virt-launcher`` pod remains in ``ContainerCreating``, inspect DRA kubelet-plugin logs for a ``NodePrepareResources`` error:

.. code-block:: console

   $ kubectl logs -n gpu-operator \
       -l dra-driver-nvidia-gpu-component=kubelet-plugin \
       -c gpus

A process with an open handle to ``/dev/nvidia*`` can prevent the GPU from switching to ``vfio-pci``.
Identify and stop the process, then allow kubelet to retry preparation.
Refer to the
`NVIDIA KubeVirt VFIO troubleshooting guide <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/guides/gpu-allocation/kubevirt-vfio-gpu-passthrough/#troubleshooting>`__
for the current diagnostic procedure.

Guest Does Not Detect the GPUs
==============================

Confirm that the VM is ready and that each GPU entry uses a unique ``claimName`` and ``requestName`` pair.
In the guest, verify that the running kernel matches the installed kernel development packages and that the NVIDIA kernel modules loaded successfully.

For GPU Operator upgrades, NVIDIA driver upgrades, and uninstall behavior with active claims,
refer to :ref:`Upgrading the NVIDIA GPU Operator`, :ref:`gpu-driver-upgrades`, and :doc:`uninstall`.

*******************
Related Information
*******************

* :ref:`DRA Driver for NVIDIA GPUs`
* :ref:`gpu-operator-kubevirt`
* `Assigning GPUs with Dynamic Resource Allocation <https://kubevirt.io/user-guide/compute/dra_gpu/>`__
* `KubeVirt VFIO GPU passthrough <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/guides/gpu-allocation/kubevirt-vfio-gpu-passthrough/>`__
* `Fabric Manager partitioning documentation <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/guides/gpu-allocation/fabric-manager-partitioning/>`__
* `NVIDIA Driver Installation Guide <https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/>`__
