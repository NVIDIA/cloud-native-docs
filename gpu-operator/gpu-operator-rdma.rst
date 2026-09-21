.. Date: Aug 4 2021
.. Author: pramarao

.. headings (h1/h2/h3/h4/h5) are # * = -

.. _net-op: https://docs.nvidia.com/networking/display/cokan10/network+operator
.. |net-op| replace:: *NVIDIA Network Operator Deployment Guide*

.. _operator-rdma:

####################################
GPUDirect RDMA and GPUDirect Storage
####################################


******************************************
About GPUDirect RDMA and GPUDirect Storage
******************************************

`GPUDirect RDMA <https://docs.nvidia.com/cuda/gpudirect-rdma/index.html>`__ is a technology in NVIDIA GPUs that enables direct
data exchange between GPUs and a third-party peer device using PCI Express. The third-party devices could be network interfaces
such as NVIDIA ConnectX SmartNICs or BlueField DPUs, or video acquisition adapters.

`GPUDirect Storage <https://docs.nvidia.com/gpudirect-storage/overview-guide/index.html>`__ (GDS) enables a direct data path between local or remote storage, such as NFS servers or NVMe/NVMe over Fabric (NVMe-oF), and GPU memory.
GDS performs direct memory access (DMA) transfers between GPU memory and storage.
DMA avoids a bounce buffer through the CPU.
This direct path increases system bandwidth and decreases the latency and utilization load on the CPU.
The GDS information on this page focuses on remote storage that transfers data over an RDMA-capable network.
For local NVMe and other GDS configurations, refer to the `GPUDirect Storage documentation <https://docs.nvidia.com/gpudirect-storage/>`__.

To support GPUDirect RDMA, an application or communication library registers GPU memory with an RDMA device.
The system can register the memory through DMA-BUF in the Linux kernel or the legacy ``nvidia-peermem`` kernel module.
NVIDIA recommends using DMA-BUF when it is supported.
DMA-BUF uses the Linux kernel and RDMA buffer-sharing interfaces and does not require the GPU Operator to build and load the legacy ``nvidia-peermem`` kernel module.
DMA-BUF reduces the network driver dependencies and configuration required on each node.
When using DMA-BUF, the application or library must explicitly request it when registering GPU memory.

In conjunction with the Network Operator, the GPU Operator can be used to
set up the networking related components such as network device kernel drivers and Kubernetes device plugins to enable
workloads to take advantage of GPUDirect RDMA and GPUDirect Storage.
Refer to the Network Operator `documentation <https://docs.nvidia.com/networking/software/cloud-orchestration/index.html>`_ for installation information.

****************************
GPUDirect RDMA Prerequisites
****************************

The prerequisites for configuring direct GPUDirect RDMA workloads depend on whether you use DMA-BUF or the legacy ``nvidia-peermem`` kernel module.

.. list-table::
   :header-rows: 1
   :stub-columns: 1
   :widths: 20 40 40

   * - Requirement
     - DMA-BUF
     - Legacy NVIDIA peermem

   * - GPU Driver
     - An Open Kernel module driver is required.
     - Any supported driver.

   * - CUDA
     - CUDA 11.7 or later in the workload.
     - A CUDA version that is supported by the GPU driver and the workload.

   * - Application
     - The application or communication library must support DMA-BUF and explicitly select it when registering GPU memory.
     - The application or communication library must support GPUDirect RDMA.

   * - GPU
     - Turing architecture data center, Quadro RTX, and RTX GPU or higher.
     - All data center, Quadro RTX, and RTX GPU or higher.

   * - Network Device Drivers
     - MLNX_OFED or DOCA-OFED are optional.
       You can use the Linux network driver and RDMA userspace packages from the operating system package manager.
     - MLNX_OFED or DOCA-OFED are required.

   * - Linux Kernel
     - 5.12 or higher.
     - No minimum version.

The NVIDIA GPU driver provides the CUDA driver interface.
The CUDA runtime and other CUDA userspace components must be available in the workload container.

* Make sure the network device drivers are installed.

  You can use the `Network Operator <https://docs.nvidia.com/networking/software/cloud-orchestration/index.html>`__
  to manage the driver lifecycle for MLNX_OFED and DOCA-OFED drivers.

  You can install the drivers on each host.
  Refer to `Adapter Software <https://docs.nvidia.com/networking/software/adapter-software/index.html>`__
  in the networking documentation for information about the MLNX_OFED, DOCA-OFED, and Linux inbox drivers.

* For installations on VMware vSphere, refer to the following additional prerequisites:

  * Make sure the network interface controller and the NVIDIA GPU are in the same PCIe IO root complex.
  * Enable the following PCI options:

    * ``pciPassthru.allowP2P = true``
    * ``pciPassthru.RelaxACSforP2P = true``
    * ``pciPassthru.use64bitMMIO = true``
    * ``pciPassthru.64bitMMIOSizeGB = 128``

    For information about configuring the settings, refer to the
    `Deploy an AI-Ready Enterprise Platform on vSphere 7 <https://www.vmware.com/docs/deploy-an-ai-ready-enterprise-platform-on-vsphere-7-update-2#vm-settings-A>`_
    document from VMWare.

**************************
Configuring GPUDirect RDMA
**************************

Platform Support
================

The following platforms are supported for GPUDirect with RDMA:

* Kubernetes on bare metal and on vSphere VMs with GPU passthrough and vGPU.
* VMware vSphere with Tanzu.
* For Red Hat OpenShift Container Platform on bare metal and on vSphere VMs with GPU passthrough and vGPU configurations,
  refer to :ref:`NVIDIA AI Enterprise with OpenShift <nvaie-ocp>`.

For information about the supported versions, refer to :ref:`Support for GPUDirect RDMA` on the platform support page.

Installing the GPU Operator and Enabling GPUDirect RDMA
=======================================================

For DMA-BUF, install the GPU Operator with the NVIDIA Open GPU Kernel module driver:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --version=${version} \
        --set driver.kernelModuleType=open

To use the legacy ``nvidia-peermem`` kernel module, add ``--set driver.rdma.enabled=true`` to the command.
If MLNX_OFED is installed directly on the host, also add ``--set driver.rdma.useHostMofed=true``.

Verifying the Installation by Performing a Data Transfer
========================================================

You can perform the following steps to verify that GPUDirect with RDMA is configured
correctly and that pods can perform RDMA data transfers.
The example verifies GPUDirect RDMA over an Ethernet/RoCE network.
It uses a MacVLAN secondary network and the RDMA shared device plugin to give the test pods shared access to an RDMA device.
The sample commands use DMA-BUF.
The ``--use_cuda_dmabuf`` option causes the perftest application to register GPU memory by using DMA-BUF.
For the legacy ``nvidia-peermem`` path, run both commands without ``--use_cuda_dmabuf``.

#. Run ``ibdev2netdev`` to identify the network interface associated with the RDMA device.

   The following example runs the command in a Network Operator driver pod:

   .. code-block:: console

      $ kubectl exec -it -n network-operator mofed-ubuntu22.04-ds-xxxxx -- ibdev2netdev

   *Example Output*

   .. code-block:: output

      mlx5_0 port 1 ==> ens64np1 (Up)

#. Configure a secondary network on the device using a macvlan network attachment:

   - Create a file, such as ``demo-macvlannetwork.yaml``, with contents like the following example:

     .. code-block:: yaml
        :emphasize-lines: 7

        apiVersion: mellanox.com/v1alpha1
        kind: MacvlanNetwork
        metadata:
          name: demo-macvlannetwork
        spec:
          networkNamespace: "default"
          master: "ens64np1"
          mode: "bridge"
          mtu: 1500
          ipam: |
            {
              "type": "whereabouts",
              "range": "192.168.2.225/28",
              "exclude": [
                "192.168.2.229/30",
                "192.168.2.236/32"
              ]
            }

     Replace ``ens64np1`` with the network interface name reported by the ``ibdev2netdev`` command
     from the preceding step.

   - Apply the manifest:

     .. code-block:: console

        $ kubectl apply -f demo-macvlannetwork.yaml

   - Confirm that the additional network is ready:

     .. code-block:: console

        $ kubectl get macvlannetworks demo-macvlannetwork

     *Example Output*

     .. code-block:: output

        NAME                  STATUS   AGE
        demo-macvlannetwork   ready    2023-03-10T18:22:28Z

#. Start two pods that run the ``mellanox/cuda-perftest`` container on two different nodes in the cluster.

   .. tab-set::

      .. tab-item:: demo-pod-1

         - Create a file, such as ``demo-pod-1.yaml``, for the first pod with contents like the following:

           .. literalinclude:: ./manifests/input/gpu-direct-rdma-demo-pod-1.yaml
              :language: yaml
              :emphasize-lines: 4,17

         - Apply the manifest:

           .. code-block:: console

              $ kubectl apply -f demo-pod-1.yaml

      .. tab-item:: demo-pod-2

         - Create a file, such as ``demo-pod-2.yaml``, for the second pod with contents like the following:

           .. literalinclude:: ./manifests/input/gpu-direct-rdma-demo-pod-2.yaml
              :language: yaml
              :emphasize-lines: 4,17

         - Apply the manifest:

           .. code-block:: console

              $ kubectl apply -f demo-pod-2.yaml

#. Get the IP addresses of the pods:

   .. code-block:: console

      $ kubectl get pods -o wide

   *Example Output*

   .. code-block:: output

      NAME         READY   STATUS    RESTARTS   AGE    IP              NODE      NOMINATED NODE   READINESS GATES
      demo-pod-1   1/1     Running   0          3d4h   192.168.38.90   nvnode1   <none>           <none>
      demo-pod-2   1/1     Running   0          3d4h   192.168.47.89   nvnode2   <none>           <none>

#. From one terminal, open a shell in the container on the first pod and start the performance test server:

   .. code-block:: console

      $ kubectl exec -it demo-pod-1 -- ib_write_bw --use_cuda=0 --use_cuda_dmabuf \
          -d mlx5_0 -a -F --report_gbits -q 1

   *Example Output*

   .. code-block:: output

      ************************************
      * Waiting for client to connect... *
      ************************************

#. From another terminal, open a shell in the container on the second pod and run the performance client:

   .. code-block:: console

      $ kubectl exec -it demo-pod-2 -- ib_write_bw -n 5000 --use_cuda=0 --use_cuda_dmabuf \
          -d mlx5_0 -a -F --report_gbits -q 1 192.168.38.90

   *Example Output*

   .. code-block:: output

      ---------------------------------------------------------------------------------------
                         RDMA_Write BW Test
      Dual-port       : OFF          Device         : mlx5_0
      Number of qps   : 1            Transport type : IB
      Connection type : RC           Using SRQ      : OFF
      PCIe relax order: ON
      ibv_wr* API     : ON
      TX depth        : 128
      CQ Moderation   : 100
      Mtu             : 1024[B]
      Link type       : Ethernet
      GID index       : 5
      Max inline data : 0[B]
      rdma_cm QPs     : OFF
      Data ex. method : Ethernet
     ---------------------------------------------------------------------------------------
      local address: LID 0000 QPN 0x01ac PSN 0xc76db1 RKey 0x23beb2 VAddr 0x007f26a2c8b000
      GID: 00:00:00:00:00:00:00:00:00:00:255:255:192:168:02:226
      remote address: LID 0000 QPN 0x01a9 PSN 0x2f722 RKey 0x23beaf VAddr 0x007f820b24f000
      GID: 00:00:00:00:00:00:00:00:00:00:255:255:192:168:02:225
     ---------------------------------------------------------------------------------------
      #bytes     #iterations    BW peak[Gb/sec]    BW average[Gb/sec]   MsgRate[Mpps]
      2          5000             0.11               0.11               6.897101
      4          5000             0.22               0.22               6.995646
      8          5000             0.45               0.45               7.014752
      16         5000             0.90               0.90               7.017509
      32         5000             1.80               1.80               7.020162
      64         5000             3.59               3.59               7.007110
      128        5000             7.19               7.18               7.009540
      256        5000             15.06              14.98              7.313517
      512        5000             30.04              29.73              7.259329
      1024       5000             59.65              58.81              7.178529
      2048       5000             91.53              91.47              5.582931
      4096       5000             92.13              92.06              2.809574
      8192       5000             92.35              92.31              1.408535
      16384      5000             92.46              92.46              0.705381
      32768      5000             92.36              92.35              0.352302
      65536      5000             92.39              92.38              0.176196
      131072     5000             92.42              92.41              0.088131
      262144     5000             92.45              92.44              0.044080
      524288     5000             92.42              92.42              0.022034
      1048576    5000             92.40              92.40              0.011015
      2097152    5000             92.40              92.39              0.005507
      4194304    5000             92.40              92.39              0.002753
      8388608    5000             92.39              92.39              0.001377
     ---------------------------------------------------------------------------------------

   The command output indicates that the data transfer rate was approximately 92 Gbps.

#. Delete the pods:

   .. code-block:: console

      $ kubectl delete -f demo-pod-1.yaml -f demo-pod-2.yaml

#. Delete the secondary network:

   .. code-block:: console

      $ kubectl delete -f demo-macvlannetwork.yaml


Verifying the nvidia-peermem Kernel Module
==========================================

For deployments with the legacy ``nvidia-peermem`` kernel module, confirm that the ``nvidia-peermem-ctr`` container successfully loaded the module:

.. code-block:: console

   $ kubectl logs -n gpu-operator ds/nvidia-driver-daemonset -c nvidia-peermem-ctr

Alternatively, run ``kubectl logs -n gpu-operator nvidia-driver-daemonset-xxxxx -c nvidia-peermem-ctr`` for each pod in the daemon set.

*Example Output*

.. code-block:: output

   successfully loaded nvidia-peermem module


***********************
Using GPUDirect Storage
***********************

This section covers GDS with remote storage over an RDMA-capable network.
In this configuration, GDS uses RDMA as the network transport, but the storage integration determines which network drivers and GPU memory registration mechanism are required.
Follow the documentation for your storage system to configure and verify those components.
For other storage configurations, refer to the `GPUDirect Storage documentation <https://docs.nvidia.com/gpudirect-storage/>`__.

Platform Support
================

See :ref:`Support for GPUDirect Storage` on the platform support page.


Installing the GPU Operator and Enabling GPUDirect Storage
==========================================================

The following section describes how to deploy the GPU Operator using the Helm Chart for these configurations:

* Kubernetes on bare metal and on vSphere VMs with GPU passthrough and vGPU.

The GPU Operator loads the ``nvidia-fs`` kernel module during the bootstrap of the NVIDIA driver daemon set.
The Operator uses ``nvidia-fs`` version 2.17.5 or later, which requires the NVIDIA Open GPU Kernel module driver.

Configure the RDMA network and storage software separately according to the requirements for your storage system.
Install the GPU Operator with the open kernel module driver and GDS enabled:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --version=${version} \
        --set gds.enabled=true \
        --set driver.kernelModuleType=open

If the storage integration requires the legacy ``nvidia-peermem`` kernel module, also set ``driver.rdma.enabled=true``.
If the integration uses ``nvidia-peermem`` with network device drivers that are installed on the host, also set ``driver.rdma.useHostMofed=true``.

Verification
============

When GDS is enabled, the GPU Operator adds the nvidia-fs-ctr container to each NVIDIA driver pod.
The container loads the ``nvidia_fs`` kernel module that provides the kernel support required by GDS.
Confirm that the container is configured in the NVIDIA driver daemon set:

.. code-block:: console

   $ kubectl get ds -n gpu-operator nvidia-driver-daemonset \
       -o jsonpath='{.spec.template.spec.containers[*].name}'

*Example Output*

.. code-block:: output

   nvidia-driver-ctr nvidia-fs-ctr

Verify that the ``nvidia_fs`` kernel module is loaded on a worker node:

.. code-block:: console

   $ lsmod | grep nvidia_fs

*Example Output*

.. code-block:: output

   nvidia_fs             245760  0

Finally, use the verification procedure for your storage system to confirm that the mount or storage client uses GDS over RDMA.


*******************
Related Information
*******************

Refer to the following resources for more information:

  * GPUDirect RDMA: https://docs.nvidia.com/cuda/gpudirect-rdma/index.html

  * GPUDirect Storage: https://docs.nvidia.com/gpudirect-storage/

  * NVIDIA Network Operator: https://github.com/Mellanox/network-operator

  * Blog post on deploying the Network Operator: https://developer.nvidia.com/blog/deploying-gpudirect-rdma-on-egx-stack-with-the-network-operator/
