<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Using GPUDirect Storage

Throughout, replace `<gpu-operator-version>` with your target GPU Operator release.

## Platform Support

See Support for GPUDirect Storage on the platform support page.

## Installing the GPU Operator and Enabling GPUDirect Storage

The following section is applicable to the following configurations and describe how to deploy the GPU Operator using the Helm Chart:

* Kubernetes on bare metal and on vSphere VMs with GPU passthrough and vGPU.

Starting with v22.9.1, the GPU Operator provides an option to load the `nvidia-fs` kernel module during the bootstrap of the NVIDIA driver daemon set.
Starting with v23.9.1, the GPU Operator deploys a version of GDS that requires using the NVIDIA Open Kernel module driver.

The following sample command applies to clusters that use the Network Operator to install the network device kernel drivers.

```console
$ helm install --wait --generate-name \
     -n gpu-operator --create-namespace \
     nvidia/gpu-operator \
     --version=<gpu-operator-version> \
     --set gds.enabled=true
```

Add `--set driver.rdma.enabled=true` to the command to use the legacy `nvidia-peermem` kernel module.

Add `--set driver.kernelModuleType=open` if you are using a driver version from a branch earlier than R570.

## Verification

During the installation, an init container is used with the driver daemon set to wait on the network device kernel drivers to be ready.
This init container checks for Mellanox NICs on the node and ensures that the necessary kernel symbols are exported by the kernel drivers.
After the verification completes, the nvidia-fs-ctr container starts inside the driver pods.

If you were required to use the `driver.rdma.enabled=true` argument when you installed the Operator, the nvidia-peermem-ctr container is started inside each driver pod after the verification.

```console
$ kubectl get pod -n gpu-operator
```

*Example Output*

```output
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
```

```console
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
```

Lastly, verify that NVIDIA kernel modules are loaded on the worker node:

```console
$ lsmod | grep nvidia

nvidia_fs             245760  0
nvidia_peermem         16384  0
nvidia_modeset       1159168  0
nvidia_uvm           1048576  0
nvidia              39059456  115 nvidia_uvm,nvidia_modeset
ib_core               319488  9 rdma_cm,ib_ipoib,iw_cm,ib_umad,rdma_ucm,ib_uverbs,mlx5_ib,ib_cm
drm                   491520  6 drm_kms_helper,drm_vram_helper,nvidia,mgag200,ttm
```
