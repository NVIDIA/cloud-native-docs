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

##########################################################
GPU Operator Support for Confidential Containers with Kata
##########################################################

.. contents::
   :depth: 2
   :local:
   :backlinks: none


*****************************************
About Support for Confidential Containers
*****************************************

.. note:: Technology Preview features are not supported in production environments
          and are not functionally complete.
          Technology Preview features provide early access to upcoming product features,
          enabling customers to test functionality and provide feedback during the development process.
          These releases may not have any documentation, and testing is limited.

Confidential containers is the cloud-native approach of confidential computing.
Confidential computing extends the practice of securing data in transit and data at rest by
adding the practice of securing data in use.

Confidential computing is a technology that isolates sensitive data in NVIDIA GPUs and a protected CPU enclave during processing.
Confidential computing relies on hardware features such as Intel SGX, Intel TDX, and AMD SEV to provide the *trusted execution environment* (TEE).
The TEE provides embedded encryption keys and an embedded attestation mechanism to ensure that keys are only accessible by authorized application code.

The following high-level diagram shows some fundamental concepts for confidential containers with the NVIDIA GPU Operator:

- containerd is configured to run a Kata runtime to start virtual machines.
- Kata starts the virtual machines using an NVIDIA optmizied Linux kernel and NVIDIA provided initial RAM disk
- Before the containers run in the virtual machine, a guest pre-start hook runs the local verifier
  that is part of the NVIDIA Attestation SDK.

.. figure:: ./graphics/gpu-op-confidential-containers.svg
   :width: 920px

   High-Level Logical Diagram of Software Components and Communication Paths

************
Requirements
************

Refer to the *Confidential Computing Deployment Guide* at the
`https://docs.nvidia.com/confidential-computing <https://docs.nvidia.com/confidential-computing>`__ website
for information about supported NVIDIA GPUs, such as the NVIDIA Hopper H100.

The following topics in the deployment guide apply to a cloud-native environment:

* Hardware selection and initial hardware configuration, such as BIOS settings.

* Host operating system selection, initial configuration, and validation.

The remaining configuration topics in the deployment guide do not apply to a cloud-native environment.
NVIDIA GPU Operator performs the actions that are described in these topics.


***********************
Key Software Components
***********************

NVIDIA GPU Operator brings together the following software components to
simplify managing the software required for confidential computing and deploying confidential container workloads:

Confidential Containers Operator
  The Operator manages installing and deploying a runtime that can run Kata Containers with QEMU.

NVIDIA Kata Manager for Kubernetes
  GPU Operator deploys NVIDIA Kata Manager for Kubernetes, ``k8s-kata-manager``.
  The manager performs the following functions:

  * Manages the ``kata-qemu-nvidia-gpu-snp`` runtime class.
  * Configures containerd to use the runtime class.
  * Manages the Kata artifacts such as Linux kernel images and initial RAM disks.

NVIDIA Confidential Computing Manager for Kubernetes
  GPU Operator deploys the manager, ``k8s-cc-manager``, to set the confidential computing mode on the NVIDIA GPUs.

Node Feature Discovery (NFD)
  When you install NVIDIA GPU Operator for confidential computing, you must specify the ``nfd.nodefeaturerules=true`` option.
  This option directs the Operator to install node feature rules that detect CPU security features and the NVIDIA GPU hardware.
  You can confirm the rules are installed by running ``kubectl get nodefeaturerules nvidia-nfd-node-featurerules``.

  On nodes that have an NVIDIA Hopper family GPU and either Intel TDX or AMD SEV-SNP, NFD adds labels to the node
  such as ``"feature.node.kubernetes.io/cpu-security.sev.snp.enabled": "true"`` and ``"nvidia.com/cc.capable": "true"``.
  NVIDIA GPU Operator only deploys the operands for confidential containers on nodes that have the
  ``"nvidia.com/cc.capable": "true"`` label.


About NVIDIA Confidential Computing Manager
===========================================

You can set the default confidential computing mode of the NVIDIA GPUs by setting the
``ccManager.defaultMode=<on|off>`` option.
You can set this option when you install NVIDIA GPU Operator or afterward by modifying the
``cluster-policy`` instance of the ``ClusterPolicy`` object.

When you change the mode, the manager performs the following actions:

* Evicts the other GPU Operator operands from the node.

  However, the manager does not drain user workloads.
  You must make sure ensure that no user workloads running on the node before you change the mode.

* Unbinds the GPU from the VFIO PCI device driver.

* Changes the mode and resets the GPU.

* Reschedules the other GPU Operator operands.


NVIDIA Confidential Computing Manager Configuration
===================================================

The following part of the cluster policy shows the fields related to the manager:

.. code-block:: yaml

   ccManager:
     enabled: true
     defaultMode: "off"
     repository: nvcr.io/nvidia/cloud-native
     image: k8s-cc-manager
     version: v0.1.0
     imagePullPolicy: IfNotPresent
     imagePullSecrets: []
     env:
       - name: CC_CAPABLE_DEVICE_IDS
         value: "0x2331,0x2322"
     resources: {}


****************************
Limitations and Restrictions
****************************

* GPUs are available to containers as a single GPU in passthrough mode only.
  Multi-GPU passthrough and vGPU are not supported.

* Support is limited to initial installation and configuration only.
  Upgrade and configuration of existing clusters to configure confidential computing is not supported.

* Support for confidential computing environments is limited to the implementation described on this page.

* NVIDIA supports the Operator and confidential computing with the containerd runtime only.

* The Operator supports performing local attestation only.


*******************************
Cluster Topology Considerations
*******************************

You can configure all the worker nodes in your cluster for confidential containers or you configure some
nodes for confidential containers and the others for traditional containers.
Consider the following example.

Node A is configured to run traditional containers.

Node B is configured to run confidential containers.

Node A receives the following software components:

- ``NVIDIA Driver Manager for Kubernetes`` -- to install the data-center driver.
- ``NVIDIA Container Toolkit`` -- to ensure that containers can access GPUs.
- ``NVIDIA Device Plugin for Kubernetes`` -- to discover and advertise GPU resources to kubelet.
- ``NVIDIA DGCM and DGCM Exporter`` -- to monitor GPUs.
- ``NVIDIA MIG Manager for Kubernetes`` -- to manage MIG-capable GPUs.
- ``NVIDIA GPU Feature Discovery`` -- to detect NVIDIA GPUs and label worker nodes.

Node B receives the following software components:

- ``NVIDIA Kata Manager for Kubernetes`` -- to manage the NVIDIA artifacts such as the
  NVIDIA optimized Linux kernel image and initial RAM disk.
- ``NVIDIA Sandbox Device Plugin`` -- to discover and advertise the passthrough GPUs to kubelet.
- ``NVIDIA VFIO Manager`` -- to load the vfio-pci device driver and bind it to all GPUs on the node.
- ``Node Feature Discovery`` -- to detect CPU security features, NVIDIA GPUs, and label worker nodes.


*************
Prerequisites
*************

* Refer to the *Confidential Computing Deployment Guide* for the following prerequisites:

  * You selected and configured your hardware and BIOS to support confidential computing.

  * You installed and configured an operating system to support confidential computing.

  * You validated that the Linux kernel is SNP-aware.

* Your hosts are configured to enable hardware virtualization.
  Enabling this feature is typically performed by configuring the host BIOS.

* Your hosts are configured to support IOMMU.

  If the output from running ``ls /sys/kernel/iommu_groups`` includes ``0``, ``1``, and so on,
  then your host is configured for IOMMU.

  If the host is not configured or you are unsure, add the ``intel_iommu=on`` Linux kernel command-line argument.
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


******************************************
Overview of Installation and Configuration
******************************************

Installing and configuring your cluster to support the NVIDIA GPU Operator with confidential containers is as follows:

#. Label the worker nodes that you want to use with confidential containers.

   This step ensures that you can continue to run traditional container workloads and vGPU workloads on some nodes in your cluster.

#. Install the Confidential Containers Operator.

   This step installs the Operator and also the Kata Containers runtime that NVIDIA uses for confidential containers.

#. Install the NVIDIA GPU Operator.

   You install the Operator and specify options to deploy the operands that are required for confidential containers.

After installation, you can change the confidential computing mode and run a sample workload.


**************************************
Label Nodes for Confidental Containers
**************************************

> Label the nodes to run Kata Containers and configure for confidential containers:

  .. code-block:: console

     $ kubectl label node <node-name> nvidia.com/gpu.workload.config=vm-passthrough

..
   .. include:: gpu-operator-kata.rst
      :start-after: start-install-coco-operator
      :end-before: end-install-coco-operator

********************************************
Install the Confidential Containers Operator
********************************************

Perform the following steps to install and verify the Confidential Containers Operator:

#. Set the Operator version in an environment variable:

   .. code-block:: console

      $ export VERSION=v0.7.0

#. Install the Operator:

   .. code-block:: console

      $ kubectl apply -k "github.com/confidential-containers/operator/config/release?ref=${VERSION}"

   *Example Output*

   .. code-block:: output

      namespace/confidential-containers-system created
      customresourcedefinition.apiextensions.k8s.io/ccruntimes.confidentialcontainers.org created
      serviceaccount/cc-operator-controller-manager created
      role.rbac.authorization.k8s.io/cc-operator-leader-election-role created
      clusterrole.rbac.authorization.k8s.io/cc-operator-manager-role created
      clusterrole.rbac.authorization.k8s.io/cc-operator-metrics-reader created
      clusterrole.rbac.authorization.k8s.io/cc-operator-proxy-role created
      rolebinding.rbac.authorization.k8s.io/cc-operator-leader-election-rolebinding created
      clusterrolebinding.rbac.authorization.k8s.io/cc-operator-manager-rolebinding created
      clusterrolebinding.rbac.authorization.k8s.io/cc-operator-proxy-rolebinding created
      configmap/cc-operator-manager-config created
      service/cc-operator-controller-manager-metrics-service created
      deployment.apps/cc-operator-controller-manager create

#. (Optional) View the pods and services in the ``confidental-containers-system`` namespace:

   .. code-block:: console

      $ kubectl get pod,svc -n confidential-containers-system

   *Example Output*

   .. code-block:: output

      NAME                                                 READY   STATUS    RESTARTS   AGE
      pod/cc-operator-controller-manager-c98c4ff74-ksb4q   2/2     Running   0          2m59s

      NAME                                                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
      service/cc-operator-controller-manager-metrics-service   ClusterIP   10.98.221.141   <none>        8443/TCP   2m59s

#. Install the sample Confidential Containers runtime by creating the manifests and then editing the node selector so
   that the runtime is installed only on the labelled nodes.

   #. Create a local copy of the manifests in a file that is named ``ccruntime.yaml``:

      .. code-block:: console

        $ kubectl apply --dry-run=client -o yaml \
            -k "github.com/confidential-containers/operator/config/samples/ccruntime/default?ref=${VERSION}" > ccruntime.yaml

   #. Edit the ``ccruntime.yaml`` file and set the node selector as follows:

      .. code-block:: yaml

         apiVersion: confidentialcontainers.org/v1beta1
         kind: CcRuntime
         metadata:
           annotations:
         ...
         spec:
           ccNodeSelector:
             matchLabels:
               nvidia.com/gpu.workload.config: "vm-passthrough"
         ...

   #. Apply the modified manifests:

      .. code-block:: console

         $ kubectl apply -f ccruntime.yaml

      *Example Output*

      .. code-block:: output

         ccruntime.confidentialcontainers.org/ccruntime-sample created

   Wait approximately 10 minutes for the Operator to create the base runtime classes.

#. (Optional) View the runtime classes:

   .. code-block:: console

      $ kubectl get runtimeclass

   *Example Output*

   .. code-block:: output

      NAME            HANDLER         AGE
      kata            kata            13m
      kata-clh        kata-clh        13m
      kata-clh-tdx    kata-clh-tdx    13m
      kata-qemu       kata-qemu       13m
      kata-qemu-sev   kata-qemu-sev   13m
      kata-qemu-snp   kata-qemu-snp   13m
      kata-qemu-tdx   kata-qemu-tdx   13m


*******************************
Install the NVIDIA GPU Operator
*******************************

Procedure
=========

Perform the following steps to install the Operator for use with confidential containers:

#. Add and update the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
         && helm repo update


#. Specify at least the following options when you install the Operator:

   .. code-block:: console

      $ helm install --wait --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --set sandboxWorkloads.enabled=true \
         --set kataManager.enabled=true \
         --set ccManager.enabled=true \
         --set nfd.nodefeaturerules=true

   *Example Output*

   .. code-block:: output

      NAME: gpu-operator
      LAST DEPLOYED: Tue Jul 25 19:19:07 2023
      NAMESPACE: gpu-operator
      STATUS: deployed
      REVISION: 1
      TEST SUITE: None


Verification
============

#. Verify that the Kata Manager, Confidential Computing Manager, and VFIO Manager operands are running:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator

   *Example Output*

   .. code-block:: output
      :emphasize-lines: 5,6,9

      NAME                                                         READY   STATUS      RESTARTS   AGE
      gpu-operator-57bf5d5769-nb98z                                1/1     Running     0          6m21s
      gpu-operator-node-feature-discovery-master-b44f595bf-5sjxg   1/1     Running     0          6m21s
      gpu-operator-node-feature-discovery-worker-lwhdr             1/1     Running     0          6m21s
      nvidia-cc-manager-yzbw7                                      1/1     Running     0          3m36s
      nvidia-kata-manager-bw5mb                                    1/1     Running     0          3m36s
      nvidia-sandbox-device-plugin-daemonset-cr4s6                 1/1     Running     0          2m37s
      nvidia-sandbox-validator-9wjm4                               1/1     Running     0          2m37s
      nvidia-vfio-manager-vg4wp                                    1/1     Running     0          3m36s

#. Verify that the ``kata-qemu-nvidia-gpu`` and ``kata-qemu-nvidia-gpu-snp`` runtime classes are available:

   .. code-block:: console

      $ kubectl get runtimeclass

   *Example Output*

   .. code-block:: output
      :emphasize-lines: 6, 7

      NAME                       HANDLER                    AGE
      kata                       kata                       37m
      kata-clh                   kata-clh                   37m
      kata-clh-tdx               kata-clh-tdx               37m
      kata-qemu                  kata-qemu                  37m
      kata-qemu-nvidia-gpu       kata-qemu-nvidia-gpu       96s
      kata-qemu-nvidia-gpu-snp   kata-qemu-nvidia-gpu-snp   96s
      kata-qemu-sev              kata-qemu-sev              37m
      kata-qemu-snp              kata-qemu-snp              37m
      kata-qemu-tdx              kata-qemu-tdx              37m
      nvidia                     nvidia                     97s


#. (Optional) If you have host access to the worker node, you can perform the following steps:

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

   #. Confirm that Kata manager installed the ``kata-qemu-nvidia-gpu`` runtime class files:

      .. code-block:: console

         $ ls -1 /opt/nvidia-gpu-operator/artifacts/runtimeclasses/kata-qemu-nvidia-gpu-snp/

      *Example Output*

      .. code-block:: output

         5.19.2.tar.gz
         config-5.19.2-109-nvidia-gpu-sev
         configuration-kata-qemu-nvidia-gpu-snp.toml
         dpkg.sbom.list
         kata-ubuntu-jammy-nvidia-gpu.initrd
         vmlinuz-5.19.2-109-nvidia-gpu-sev
         ...


****************************************
Managing the Confidential Computing Mode
****************************************

Three modes are supported:

- ``on`` -- Enable confidential computing.
- ``off`` -- Disable confidential computing.
- ``devtools`` -- Development mode for software development and debugging.

You can set a cluster-wide default mode and you can set the mode on individual nodes.
The mode that you set on a node has higher precedence than the cluster-wide default mode.


Setting a Cluster-Wide Default Mode
===================================

To set a cluster-wide mode, specify the ``ccManager.defaultMode`` field like the following example:

.. code-block:: console

   $ kubectl patch clusterpolicy/cluster-policy \
          -p '{"spec": {"ccManager": {"defaultMode": "on"}}}'


Setting a Node-Level Mode
=========================

To set a node-level mode, apply the ``nvidia.com/cc.mode=<on|off|devtools>`` label like the following example:

.. code-block:: console

   $ kubectl label node <node-name> nvidia.com/cc.mode=on --overwrite


Verifying a Mode Change
=======================

To verify that changing the mode was successful, a cluster-wide or node-level change,
view the ``nvidia.com/cc.mode.state`` node label:

.. code-block:: console

   $ kubectl get node <node-name> -o json |  \
       jq '.items[0].metadata.labels | with_entries(select(.key | startswith("nvidia.com/cc.mode.state)))'

The label is set to either ``success`` or ``failed``.


*********************
Run a Sample Workload
*********************

A pod specification for a confidential computing requires the following:

* Specify the ``kata-qemu-nvidia-gpu-snp`` runtime class.

* Specify a passthrough GPU resource.

#. Determine the passthrough GPU resource names:

   .. code-block:: console

      kubectl get nodes -l nvidia.com/gpu.present -o json | \
        jq '.items[0].status.allocatable |
          with_entries(select(.key | startswith("nvidia.com/"))) |
          with_entries(select(.value != "0"))'

   *Example Output*

   .. code-block:: output

      {
         "nvidia.com/GA102GL_A10": "1"
      }

#. Create a file, such as ``cuda-vectoradd-coco.yaml``, like the following example:

   .. code-block:: yaml
      :emphasize-lines: 6, 15

      apiVersion: v1
      kind: Pod
      metadata:
        name: cuda-vectoradd-coco
        annotations:
          cdi.k8s.io/gpu: "nvidia.com/pgpu=0"
      spec:
        runtimeClassName: kata-qemu-nvidia-gpu-snp
        restartPolicy: OnFailure
        containers:
        - name: cuda-vectoradd
          image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda11.7.1-ubuntu20.04"
        resources:
          limits:
            "nvidia.com/GA102GL_A10": 1

#. Create the pod:

   .. code-block:: console

      $ kubectl apply -f cuda-vectoradd-coco.yaml

#. View the logs from pod:

   .. code-block:: console

      $ kubectl logs -n default cuda-vectoradd-coco

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

      $ kubectl delete -f cuda-vectoradd-coco.yaml


Refer to :ref:`About the Pod Annotation` for information about the pod annotation.


***********
Attestation
***********

About Attestation
=================

With confidential computing, *attestation* is the assertion that the hardware and
software is trustworthy.

The Kata runtime uses the ``kata-ubuntu-jammy-nvidia-gpu.initrd`` initial RAM disk file
that NVIDIA Kata Manager for Kubernetes downloaded from NVIDIA Container Registry, nvcr.io.
The initial RAM disk includes an NVIDIA verifier tool that runs as a container guest pre-start hook.
When the attestation is successful, the GPU is set in the ``Ready`` state.
On failure, containers still start, but CUDA applications fail with a ``system not initialized`` error.

Refer to *NVIDIA Hopper Confidential Computing Attestation Verifier* at https://docs.nvidia.com/confidential-computing
for more information about attestation.


Accessing the VM of a Scheduled Confidential Container
======================================================

You do not need to access the VM as a routine task.
Accessing the VM is useful for troubleshooting or performing lower-level verification about the confidential computing mode.

This task requires host access to the Kubernetes node that is running the container.

#. Determine the Kubernetes node and pod sandbox ID:

   .. code-block:: console

      $ kubectl describe pod <pod-name>

#. Access the Kubernetes node.
   Using secure shell is typical.

#. Access the Kata runtime:

   .. code-block:: console

      $ kata-runtime exec <pod-sandbox-ID>

Viewing the GPU Ready State
===========================

After you access the VM, you can run ``nvidia-smi conf-compute -grs``:

.. code-block:: output

   Confidential Compute GPUs Ready state: ready


Viewing the Confidential Computing Mode
=======================================

After you access the VM, you can run ``nvidia-smi conf-compute -f`` to view the mode:

.. code-block:: output

   CC status: ON


Verifying That Attestation Is Successful
========================================

After you access the VM, you can run the following commands to verify that attestation is successful:

.. code-block:: console

   # source /gpu-attestation/nv-venv/bin/activate
   # python3 /gpu-attestation/nv_attestation_sdk/tests/SmallGPUTest.py

*Example Output*

.. code-block:: output

   [SmallGPUTest] node name : thisNode1
   [['LOCAL_GPU_CLAIMS', <Devices.GPU: 2>, <Environment.LOCAL: 2>, '', '', '']]
   [SmallGPUTest] call attest() - expecting True
   Number of GPUs available : 1
   -----------------------------------
   Fetching GPU 0 information from GPU driver.
   VERIFYING GPU : 0
         Driver version fetched : 535.86.05
         VBIOS version fetched : 96.00.5e.00.01
         Validating GPU certificate chains.
                GPU attestation report certificate chain validation successful.
                       The certificate chain revocation status verification successful.
         Authenticating attestation report
                The nonce in the SPDM GET MEASUREMENT request message is matching with the generated nonce.
                Driver version fetched from the attestation report : 535.86.05
                VBIOS version fetched from the attestation report : 96.00.5e.00.01
                Attestation report signature verification successful.
                Attestation report verification successful.
         Authenticating the RIMs.
                Authenticating Driver RIM
                        Schema validation passed.
                        driver RIM certificate chain verification successful.
                        The certificate chain revocation status verification successful.
                        driver RIM signature verification successful.
                        Driver RIM verification successful
               Authenticating VBIOS RIM.
                        RIM Schema validation passed.
                        vbios RIM certificate chain verification successful.
                        The certificate chain revocation status verification successful.
                        vbios RIM signature verification successful.
                        VBIOS RIM verification successful
         Comparing measurements (runtime vs golden)
                        The runtime measurements are matching with the golden measurements.
                GPU is in the expected state.
         GPU 0 verified successfully.
         attestation result: True
         claims list:: {'x-nv-gpu-availability': True, 'x-nv-gpu-attestation-report-available': ...
         True
         [SmallGPUTest] token : [["JWT", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e..."],
            {"LOCAL_GPU_CLAIMS": "eyJhbGciOiJIUzI1NiIsInR5cCI..."}]
         [SmallGPUTest] call validate_token() - expecting True
         True


Troubleshooting
===============

To troubleshoot attestation failures, access the VM and view the logs in the ``/var/log/`` directory.

To troubleshoot virtual machine failures, access the Kubernetes node and view logs with the ``journalctl`` command.

.. code-block:: console

   $ sudo journalctl -u containerd -f

The Kata agent communicates with the virtcontainers library on the host by using the VSOCK port.
The communication is recorded to the system journal on the host.
When you view the logs, refer to logs with a ``kata`` or ``virtcontainers`` prefix.


********************
Additional Resources
********************

* NVIDIA Confidential Computing documentation is available at https://docs.nvidia.com/confidential-computing.

* NVIDIA Verifier Tool is part of the nvTrust project.
  Refer to https://github.com/NVIDIA/nvtrust/tree/main/guest_tools/gpu_verifiers/local_gpu_verifier
  for more information.

