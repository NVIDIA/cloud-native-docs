.. Date: Aug 4 2021
.. Author: pramarao

.. headings (h1/h2/h3/h4/h5) are # * = -

.. _net-op: https://docs.nvidia.com/networking/display/cokan10/network+operator
.. |net-op| replace:: *NVIDIA Network Operator Deployment Guide*

.. _operator-rdma:

####################################
GPUDirect RDMA and GPUDirect Storage
####################################

.. contents::
   :depth: 2
   :local:
   :backlinks: none


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

To support GPUDirect RDMA, userspace CUDA APIs are required.
The kernel mode support is provided by one of two approaches: DMA-BUF from the Linux kernel or the legacy ``nvidia-peermem`` kernel module.
NVIDIA recommends using the DMA-BUF rather than using the ``nvidia-peermem`` kernel module from the GPU Driver.

Starting with v23.9.1 of the Operator, the Operator uses GDS driver version 2.17.5 or newer.
This version and higher is only supported with the NVIDIA Open GPU Kernel module driver.
The sample commands for installing the Operator include the ``--set useOpenKernelModules=true``
command-line argument for Helm.

In conjunction with the Network Operator, the GPU Operator can be used to
set up the networking related components such as network device kernel drivers and Kubernetes device plugins to enable
workloads to take advantage of GPUDirect RDMA and GPUDirect Storage.
Refer to the Network Operator `documentation <https://docs.nvidia.com/networking/software/cloud-orchestration/index.html>`_ for installation information.

********************
Common Prerequisites
********************

The prerequisites for configuring GPUDirect RDMA or GPUDirect Storage depend on whether you use DMA-BUF from the Linux kernel or the legacy ``nvidia-peermem`` kernel module.

.. list-table::
   :header-rows: 1
   :stub-columns: 1
   :widths: 20 40 40

   * - Technology
     - DMA-BUF
     - Legacy NVIDIA-peermem

   * - GPU Driver
     - Branch 535 or higher.
       An Open Kernel module driver is required.
     - Branch 470, 535 or higher.

   * - CUDA
     - CUDA 11.7 or higher.
       The CUDA runtime is provided by the driver.
     - No minimum version.
       The CUDA runtime is provided by the driver.

   * - GPU
     - Turing architecture data center, Quadro RTX, and RTX GPU or higher.
     - All data center, Quadro RTX, and RTX GPU or higher.

   * - Network Device Drivers
     - MLNX_OFED or DOCA-OFED are optional.
       You can use the Linux driver packages from the package manager.
     - MLNX_OFED or DOCA-OFED are required.

   * - Linux Kernel
     - 5.12 or higher.
     - No minimum version.

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
    `Deploy an AI-Ready Enterprise Platform on vSphere 7 <https://core.vmware.com/resource/deploy-ai-ready-vsphere-7#vm-settings-A>`_
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

To use DMA-BUF and network device drivers that are installed by the Network Operator:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set driver.useOpenKernelModules=true

To use DMA-BUF and network device drivers that are installed on the host:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set driver.useOpenKernelModules=true \
        --set driver.rdma.useHostMofed=true

To use the legacy ``nvidia-peermem`` kernel module instead of DMA-BUF, add ``--set driver.rdma.enabled=true`` to either of the preceding commands.
The ``driver.useOpenKernelModules=true`` argument is optional for using the legacy kernel driver.

Verifying the Installation of GPUDirect with RDMA
=================================================

During the installation, the NVIDIA driver daemon set runs an `init container` to wait on the network device kernel drivers to be ready.
This init container checks for Mellanox NICs on the node and ensures that the necessary kernel symbols are exported by the kernel drivers.

If you were required to use the ``driver.rdma.enabled=true`` argument when you installed the Operator, the nvidia-peermem-ctr container is started inside each driver pod after the verification.

#. Confirm that the pod template for the driver daemon set includes the mofed-validation init container and
   the nvidia-driver-ctr containers:

   .. code-block:: console

      $ kubectl describe ds -n gpu-operator nvidia-driver-daemonset

   *Example Output*

   The following partial output omits the init containers and containers that are common to all installations.

   .. code-block:: output

      ...
       Init Containers:
        mofed-validation:
        Container ID:  containerd://5a36c66b43f676df616e25ba7ae0c81aeaa517308f28ec44e474b2f699218de3
        Image:         nvcr.io/nvidia/cloud-native/gpu-operator-validator:v1.8.1
        Image ID:      nvcr.io/nvidia/cloud-native/gpu-operator-validator@sha256:7a70e95fd19c3425cd4394f4b47bbf2119a70bd22d67d72e485b4d730853262c
      ...
       Containers:
        nvidia-driver-ctr:
        Container ID:  containerd://199a760946c55c3d7254fa0ebe6a6557dd231179057d4909e26c0e6aec49ab0f
        Image:         nvcr.io/nvaie/vgpu-guest-driver:470.63.01-ubuntu20.04
        Image ID:      nvcr.io/nvaie/vgpu-guest-driver@sha256:a1b7d2c8e1bad9bb72d257ddfc5cec341e790901e7574ba2c32acaddaaa94625
      ...
        nvidia-peermem-ctr:
        Container ID:  containerd://0742d86f6017bf0c304b549ebd8caad58084a4185a1225b2c9a7f5c4a171054d
        Image:         nvcr.io/nvaie/vgpu-guest-driver:470.63.01-ubuntu20.04
        Image ID:      nvcr.io/nvaie/vgpu-guest-driver@sha256:a1b7d2c8e1bad9bb72d257ddfc5cec341e790901e7574ba2c32acaddaaa94625
      ...

   The nvidia-peermem-ctr container is present only if you were required to specify the ``driver.rdma.enabled=true`` argument when you installed the Operator.

#. Legacy only: Confirm that the nvidia-peermem-ctr container successfully loaded the nvidia-peermem kernel module:

   .. code-block:: console

      $ kubectl logs -n gpu-operator ds/nvidia-driver-daemonset -c nvidia-peermem-ctr

   Alternatively, run ``kubectl logs -n gpu-operator nvidia-driver-daemonset-xxxxx -c nvidia-peermem-ctr`` for each pod in the daemonset.

   *Example Output*

   .. code-block:: output

      waiting for mellanox ofed and nvidia drivers to be installed
      waiting for mellanox ofed and nvidia drivers to be installed
      successfully loaded nvidia-peermem module


Verifying the Installation by Performing a Data Transfer
========================================================

You can perform the following steps to verify that GPUDirect with RDMA is configured
correctly and that pods can perform RDMA data transfers.

#. Get the network interface name of the InfiniBand device on the host:

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

     Replace ``ens64np1`` with the the network interface name reported by the ``ibdev2netdev`` command
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

      $ kubectl delete -f demo-macvlannetworks.yaml


***********************
Using GPUDirect Storage
***********************

Platform Support
================

See :ref:`Support for GPUDirect Storage` on the platform support page.


Installing the GPU Operator and Enabling GPUDirect Storage
==========================================================

The following section is applicable to the following configurations and describe how to deploy the GPU Operator using the Helm Chart:

* Kubernetes on bare metal and on vSphere VMs with GPU passthrough and vGPU.

Starting with v22.9.1, the GPU Operator provides an option to load the ``nvidia-fs`` kernel module during the bootstrap of the NVIDIA driver daemon set.
Starting with v23.9.1, the GPU Operator deploys a version of GDS that requires using the NVIDIA Open Kernel module driver.

The following sample command applies to clusters that use the Network Operator to install the network device kernel drivers.

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set driver.useOpenKernelModules=true \
        --set gds.enabled=true

Add ``--set driver.rdma.enabled=true`` to the command to use the legacy ``nvidia-peermem`` kernel module.


Verification
==============

During the installation, an init container is used with the driver daemon set to wait on the network device kernel drivers to be ready.
This init container checks for Mellanox NICs on the node and ensures that the necessary kernel symbols are exported by the kernel drivers.
After the verification completes, the nvidia-fs-ctr container starts inside the driver pods.

If you were required to use the ``driver.rdma.enabled=true`` argument when you installed the Operator, the nvidia-peermem-ctr container is started inside each driver pod after the verification.

.. code-block:: console

   $ kubectl get pod -n gpu-operator

*Example Output*

.. code-block:: output

   gpu-operator   gpu-feature-discovery-pktzg                                       1/1     Running     0          11m
   gpu-operator   gpu-operator-1672257888-node-feature-discovery-master-7ccb7txmc   1/1     Running     0          12m
   gpu-operator   gpu-operator-1672257888-node-feature-discovery-worker-bqhrl       1/1     Running     0          11m
   gpu-operator   gpu-operator-6f64c86bc-zjqdh                                      1/1     Running     0          12m
   gpu-operator   nvidia-container-toolkit-daemonset-rgwqg                          1/1     Running     0          11m
   gpu-operator   nvidia-cuda-validator-8whvt                                       0/1     Completed   0          8m50s
   gpu-operator   nvidia-dcgm-exporter-pt9q9                                        1/1     Running     0          11m
   gpu-operator   nvidia-device-plugin-daemonset-472fc                              1/1     Running     0          11m
   gpu-operator   nvidia-device-plugin-validator-29nhc                              0/1     Completed   0          8m34s
   gpu-operator   nvidia-driver-daemonset-j9vw6                                     3/3     Running     0          12m
   gpu-operator   nvidia-mig-manager-mtjcw                                          1/1     Running     0          7m35s
   gpu-operator   nvidia-operator-validator-b8nz2                                   1/1     Running     0          11m


.. code-block:: console

   $ kubectl describe pod -n gpu-operator nvidia-driver-daemonset-xxxx
   <snip>
    Init Containers:
     mofed-validation:
      Container ID:  containerd://a31a8c16ce7596073fef7cb106da94c452fdff111879e7fc3ec58b9cef83856a
      Image:         nvcr.io/nvidia/cloud-native/gpu-operator-validator:v22.9.1
      Image ID:      nvcr.io/nvidia/cloud-native/gpu-operator-validator@sha256:18c9ea88ae06d479e6657b8a4126a8ee3f4300a40c16ddc29fb7ab3763d46005

    <snip>
    Containers:
     nvidia-driver-ctr:
      Container ID:  containerd://7cf162e4ee4af865c0be2023d61fbbf68c828d396207e7eab2506f9c2a5238a4
      Image:         nvcr.io/nvidia/driver:525.60.13-ubuntu20.04
      Image ID:      nvcr.io/nvidia/driver@sha256:0ee0c585fa720f177734b3295a073f402d75986c1fe018ae68bd73fe9c21b8d8


     <snip>
     nvidia-peermem-ctr:
      Container ID:  containerd://5c71c9f8ccb719728a0503500abecfb5423e8088f474d686ee34b5fe3746c28e
      Image:         nvcr.io/nvidia/driver:525.60.13-ubuntu20.04
      Image ID:      nvcr.io/nvidia/driver@sha256:0ee0c585fa720f177734b3295a073f402d75986c1fe018ae68bd73fe9c21b8d8

     <snip>
     nvidia-fs-ctr:
      Container ID:  containerd://f5c597d59e1cf8747aa20b8c229a6f6edd3ed588b9d24860209ba0cc009c0850
      Image:         nvcr.io/nvidia/cloud-native/nvidia-fs:2.14.13-ubuntu20.04
      Image ID:      nvcr.io/nvidia/cloud-native/nvidia-fs@sha256:109485365f68caeaee1edee0f3f4d722fe5b5d7071811fc81c630c8a840b847b

    <snip>



Lastly, verify that NVIDIA kernel modules are loaded on the worker node:

.. code-block:: console

   $ lsmod | grep nvidia

   nvidia_fs             245760  0
   nvidia_peermem         16384  0
   nvidia_modeset       1159168  0
   nvidia_uvm           1048576  0
   nvidia              39059456  115 nvidia_uvm,nvidia_modeset
   ib_core               319488  9 rdma_cm,ib_ipoib,iw_cm,ib_umad,rdma_ucm,ib_uverbs,mlx5_ib,ib_cm
   drm                   491520  6 drm_kms_helper,drm_vram_helper,nvidia,mgag200,ttm


*******************
Related Information
*******************

Refer to the following resources for more information:

  * GPUDirect RDMA: https://docs.nvidia.com/cuda/gpudirect-rdma/index.html

  * NVIDIA Network Operator: https://github.com/Mellanox/network-operator

  * Blog post on deploying the Network Operator: https://developer.nvidia.com/blog/deploying-gpudirect-rdma-on-egx-stack-with-the-network-operator/
