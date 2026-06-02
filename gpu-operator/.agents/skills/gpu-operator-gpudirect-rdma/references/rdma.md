<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Configuring GPUDirect RDMA

Throughout, replace `<gpu-operator-version>` with your target GPU Operator release.

## Platform Support

The following platforms are supported for GPUDirect with RDMA:

* Kubernetes on bare metal and on vSphere VMs with GPU passthrough and vGPU.
* VMware vSphere with Tanzu.
* For Red Hat OpenShift Container Platform on bare metal and on vSphere VMs with GPU passthrough and vGPU configurations,
  refer to NVIDIA AI Enterprise with OpenShift.

For information about the supported versions, refer to Support for GPUDirect RDMA on the platform support page.

## Installing the GPU Operator and Enabling GPUDirect RDMA

> [!NOTE]
> Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases).

To use DMA-BUF and network device drivers that are installed by the Network Operator:

```console
$ helm install --wait --generate-name \
     -n gpu-operator --create-namespace \
     nvidia/gpu-operator \
     --version=<gpu-operator-version> \
```

To use DMA-BUF and network device drivers that are installed on the host:

```console
$ helm install --wait --generate-name \
     -n gpu-operator --create-namespace \
     nvidia/gpu-operator \
     --version=<gpu-operator-version> \
     --set driver.rdma.useHostMofed=true
```

To use the legacy `nvidia-peermem` kernel module instead of DMA-BUF, add `--set driver.rdma.enabled=true` to either of the preceding commands.
Add `--set driver.kernelModuleType=open` if you are using a driver version from a branch earlier than R570.

## Verifying the Installation of GPUDirect with RDMA

During the installation, the NVIDIA driver daemon set runs an `init container` to wait on the network device kernel drivers to be ready.
This init container checks for Mellanox NICs on the node and ensures that the necessary kernel symbols are exported by the kernel drivers.

If you were required to use the `driver.rdma.enabled=true` argument when you installed the Operator, the nvidia-peermem-ctr container is started inside each driver pod after the verification.

1. Confirm that the pod template for the driver daemon set includes the mofed-validation init container and
   the nvidia-driver-ctr containers:

   ```console
   $ kubectl describe ds -n gpu-operator nvidia-driver-daemonset
   ```

   *Example Output*

   The following partial output omits the init containers and containers that are common to all installations.

   ```output
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
   ```

   The nvidia-peermem-ctr container is present only if you were required to specify the `driver.rdma.enabled=true` argument when you installed the Operator.

1. Legacy only: Confirm that the nvidia-peermem-ctr container successfully loaded the nvidia-peermem kernel module:

   ```console
   $ kubectl logs -n gpu-operator ds/nvidia-driver-daemonset -c nvidia-peermem-ctr
   ```

   Alternatively, run `kubectl logs -n gpu-operator nvidia-driver-daemonset-xxxxx -c nvidia-peermem-ctr` for each pod in the daemonset.

   *Example Output*

   ```output
   waiting for mellanox ofed and nvidia drivers to be installed
   waiting for mellanox ofed and nvidia drivers to be installed
   successfully loaded nvidia-peermem module
   ```

## Verifying the Installation by Performing a Data Transfer

You can perform the following steps to verify that GPUDirect with RDMA is configured
correctly and that pods can perform RDMA data transfers.

1. Get the network interface name of the InfiniBand device on the host:

   ```console
   $ kubectl exec -it -n network-operator mofed-ubuntu22.04-ds-xxxxx -- ibdev2netdev
   ```

   *Example Output*

   ```output
   mlx5_0 port 1 ==> ens64np1 (Up)
   ```

1. Configure a secondary network on the device using a macvlan network attachment:

   - Create a file, such as `demo-macvlannetwork.yaml`, with contents like the following example:

     ```yaml
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
     ```

     Replace `ens64np1` with the the network interface name reported by the `ibdev2netdev` command
     from the preceding step.

   - Apply the manifest:

     ```console
     $ kubectl apply -f demo-macvlannetwork.yaml
     ```

   - Confirm that the additional network is ready:

     ```console
     $ kubectl get macvlannetworks demo-macvlannetwork
     ```

     *Example Output*

     ```output
     NAME                  STATUS   AGE
     demo-macvlannetwork   ready    2023-03-10T18:22:28Z
     ```

1. Start two pods that run the `mellanox/cuda-perftest` container on two different nodes in the cluster.

   ### demo-pod-1

   - Create a file, such as `demo-pod-1.yaml`, for the first pod with contents like the following:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: demo-pod-1
     annotations:
       k8s.v1.cni.cncf.io/networks: demo-macvlannetwork
       # If a network with static IPAM is used replace network annotation with the below.
       # k8s.v1.cni.cncf.io/networks: '[
       #   { "name": "rdma-net",
       #     "ips": ["192.168.111.101/24"],
       #     "gateway": ["192.168.111.1"]
       #   }
       # ]'
   spec:
     nodeSelector:
       # Note: Replace hostname or remove selector altogether
       kubernetes.io/hostname: nvnode1
     restartPolicy: OnFailure
     containers:
     - image: mellanox/cuda-perftest
       name: rdma-gpu-test-ctr
       securityContext:
         capabilities:
           add: [ "IPC_LOCK" ]
       resources:
         limits:
           nvidia.com/gpu: 1
           rdma/rdma_shared_device_a: 1
         requests:
           nvidia.com/gpu: 1
           rdma/rdma_shared_device_a: 1
   ```

   - Apply the manifest:

     ```console
     $ kubectl apply -f demo-pod-1.yaml
     ```

   ### demo-pod-2

   - Create a file, such as `demo-pod-2.yaml`, for the second pod with contents like the following:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: demo-pod-2
     annotations:
       k8s.v1.cni.cncf.io/networks: demo-macvlannetwork
       # If a network with static IPAM is used replace network annotation with the below.
       # k8s.v1.cni.cncf.io/networks: '[
       #   { "name": "rdma-net",
       #     "ips": ["192.168.111.101/24"],
       #     "gateway": ["192.168.111.1"]
       #   }
       # ]'
   spec:
     nodeSelector:
       # Note: Replace hostname or remove selector altogether
       kubernetes.io/hostname: nvnode2
     restartPolicy: OnFailure
     containers:
     - image: mellanox/cuda-perftest
       name: rdma-gpu-test-ctr
       securityContext:
         capabilities:
           add: [ "IPC_LOCK" ]
       resources:
         limits:
           nvidia.com/gpu: 1
           rdma/rdma_shared_device_a: 1
         requests:
           nvidia.com/gpu: 1
           rdma/rdma_shared_device_a: 1
   ```

   - Apply the manifest:

     ```console
     $ kubectl apply -f demo-pod-2.yaml
     ```

1. Get the IP addresses of the pods:

   ```console
   $ kubectl get pods -o wide
   ```

   *Example Output*

   ```output
   NAME         READY   STATUS    RESTARTS   AGE    IP              NODE      NOMINATED NODE   READINESS GATES
   demo-pod-1   1/1     Running   0          3d4h   192.168.38.90   nvnode1   <none>           <none>
   demo-pod-2   1/1     Running   0          3d4h   192.168.47.89   nvnode2   <none>           <none>
   ```

1. From one terminal, open a shell in the container on the first pod and start the performance test server:

   ```console
   $ kubectl exec -it demo-pod-1 -- ib_write_bw --use_cuda=0 --use_cuda_dmabuf \
       -d mlx5_0 -a -F --report_gbits -q 1
   ```

   *Example Output*

   ```output
   ************************************
   * Waiting for client to connect... *
   ************************************
   ```

1. From another terminal, open a shell in the container on the second pod and run the performance client:

   ```console
   $ kubectl exec -it demo-pod-2 -- ib_write_bw -n 5000 --use_cuda=0 --use_cuda_dmabuf \
       -d mlx5_0 -a -F --report_gbits -q 1 192.168.38.90
   ```

   *Example Output*

   ```output
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
   ```

   The command output indicates that the data transfer rate was approximately 92 Gbps.

1. Delete the pods:

   ```console
   $ kubectl delete -f demo-pod-1.yaml -f demo-pod-2.yaml
   ```

1. Delete the secondary network:

   ```console
   $ kubectl delete -f demo-macvlannetworks.yaml
   ```
