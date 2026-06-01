<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Common Chart Customization Options

The following options are available when using the Helm chart.
These options can be used with `--set` when installing with Helm.

The following table identifies the most frequently used options.
To view all the options, run `helm show values nvidia/gpu-operator`.

| Parameter | Description | Default |
| --- | --- | --- |
| `ccManager.enabled` | When set to `true`, the Operator deploys NVIDIA Confidential Computing Manager for Kubernetes. | `false` |
| `cdi.enabled` | When set to `true` (default), the Container Device Interface (CDI) will be used for injecting GPUs into workload containers. The Operator will no longer configure the `nvidia` runtime class as the default runtime handler. Instead, native-CDI support in container runtimes like containerd or cri-o will be leveraged for injecting GPUs into workload containers. Refer to the Container Device Interface page (use the `gpu-operator-container-device` skill) for more information. | `true` |
| `cdi.nriPluginEnabled` | When set to `true`, the Node Resource Interface (NRI) Plugin will be used for injecting GPUs into workload containers. In NRI Plugin mode, the NVIDIA Container Toolkit will no longer modify the runtime config. This feature requires containerd v1.7.30, v2.1.x, or v2.2.x. Refer to the Container Device Interface page (use the `gpu-operator-container-device` skill) for more information. | `false` |
| `cdi.default`  Deprecated. | This field is deprecated as of v25.10.0 and will be ignored. The `cdi.enabled` field is set to `true` by default in versions 25.10.0 and later. When set to `true`, the container runtime uses CDI to perform device injection by default. | `false` |
| `daemonsets.annotations` | Map of custom annotations to add to all GPU Operator managed pods. | `{}` |
| `daemonsets.labels` | Map of custom labels to add to all GPU Operator managed pods. | `{}` |
| `dcgmExporter.enabled` | By default, the Operator gathers GPU telemetry in Kubernetes using [DCGM Exporter](https://docs.nvidia.com/datacenter/cloud-native/gpu-telemetry/latest/dcgm-exporter.html). Set this value to `false` to disable it. Available values are `true` (default) or `false`. | `true` |
| `dcgmExporter.service.internalTrafficPolicy` | Specifies the [internalTrafficPolicy](https://kubernetes.io/docs/concepts/services-networking/service/#traffic-policies) for the DCGM Exporter service. Available values are `Cluster` (default) or `Local`. | `Cluster` |
| `dcgmExporter.hostNetwork` | When set to `true`, the DCGM Exporter will expose a metric port on the host's network namespace. | `false` |
| `devicePlugin.config` | Specifies the configuration for the NVIDIA Device Plugin as a config map. In most cases, this field is configured after installing the Operator, such as to configure GPU time-slicing (use the `gpu-operator-timeslicing-gpus` skill). | `{}` |
| `driver.enabled` | By default, the Operator deploys NVIDIA drivers as a container on the system. Set this value to `false` when using the Operator on systems with pre-installed drivers. | `true` |
| `driver.image` | Name of the NVIDIA Driver Container image to use. | `driver` |
| `driver.imagePullSecrets` | List of the image pull secret used for pulling the driver container image from the registry. | None |
| `driver.kernelModuleType` | Specifies the type of the NVIDIA GPU Kernel modules to use. Valid values are `auto` (default), `proprietary`, and `open`. `Auto` means that the recommended kernel module type (open or proprietary) is chosen based on the GPU devices on the host and the driver branch used. The `auto` option is only supported with the 570.86.15 and 570.124.06 or later driver containers. 550 and 535 branch drivers do not yet support this mode. `Open` means the open kernel module is used. `Proprietary` means the proprietary module is used. | `auto` |
| `driver.nvidiaDriverCRD.enabled` | When set to `true`, the Operator deploys NVIDIA GPU Driver Custom Resource Definition. Refer to the NVIDIA GPU Driver Custom Resource Definition (use the `gpu-operator-nvidia-driver` skill) page for more information. | `false` |
| `driver.repository` | The images are downloaded from NGC. Specify another image repository when using custom driver images. | `nvcr.io/nvidia` |
| `driver.rdma.enabled` | Controls whether the driver daemon set builds and loads the legacy `nvidia-peermem` kernel module. You might be able to use GPUDirect RDMA without enabling this option. Refer to the GPUDirect RDMA page (use the `gpu-operator-gpudirect-rdma` skill) for information about whether you can use DMA-BUF or you need to use legacy `nvidia-peermem`. | `false` |
| `driver.rdma.useHostMofed` | Indicate if MLNX_OFED (MOFED) drivers are pre-installed on the host. | `false` |
| `driver.secretEnv` | The name of the secret to the driver container. A common use case is to use this field to pass your Ubuntu Pro token secret if you are deploying the GPU Operator with government-ready components. Refer to the government-ready installation page (use the `gpu-operator-install-governmentready-environments` skill) for more information. | None |
| `driver.startupProbe` | By default, the driver container has an initial delay of `60s` before starting liveness probes. The probe runs the `nvidia-smi` command with a timeout duration of `60s`. You can increase the `timeoutSeconds` duration if the `nvidia-smi` command runs slowly in your cluster. | `60s` |
| `driver.useOpenKernelModules` Deprecated. | This field is deprecated as of v25.3.0 and will be ignored. Use `kernelModuleType` instead. When set to `true`, the driver containers install the NVIDIA Open GPU Kernel module driver. | `false` |
| `driver.usePrecompiled` | When set to `true`, the Operator attempts to deploy driver containers that have precompiled kernel drivers. Refer to the precompiled driver containers (use the `gpu-operator-precompiled-drivers` skill) page for the supported operating systems. | `false` |
| `driver.version` | Version of the NVIDIA datacenter driver supported by the Operator. If you set `driver.usePrecompiled` to `true`, then set this field to a driver branch, such as `525`. | Depends on the version of the Operator. Refer to the [GPU Operator Component Matrix](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/life-cycle-policy.html#gpu-operator-component-matrix) for more information on supported drivers. |
| `gdrcopy.enabled` | Enables support for GDRCopy. When set to `true`, the GDRCopy Driver runs as a sidecar container in the GPU driver pod. For information about GDRCopy, refer to the [gdrcopy](https://developer.nvidia.com/gdrcopy) page. You can enable GDRCopy if you use the NVIDIA GPU Driver custom resource (use the `gpu-operator-nvidia-driver` skill). | `false` |
| `mig.strategy` | Controls the strategy to be used with MIG on supported NVIDIA GPUs. Options are either `mixed` or `single`. | `single` |
| `migManager.enabled` | The MIG manager watches for changes to the MIG geometry and applies reconfiguration as needed. By default, the MIG manager only runs on nodes with GPUs that support MIG (such as the A100). | `true` |
| `nfd.enabled` | Deploys Node Feature Discovery plugin as a daemonset. Set this variable to `false` if NFD is already running in the cluster. | `true` |
| `nfd.nodefeaturerules` | Installs node feature rules that are related to confidential computing. NFD uses the rules to detect security features in CPUs and NVIDIA GPUs. Set this variable to `true` when you configure the Operator for Confidential Containers. | `false` |
| `operator.labels` | Map of custom labels that will be added to all GPU Operator managed pods. | `{}` |
| `psp.enabled` | The GPU Operator deploys `PodSecurityPolicies` if enabled. | `false` |
| `sandboxWorkloads.enabled` | Specifies if sandbox containers are enabled. | `false` |
| `sandboxWorkloads.defaultWorkload` | Specifies the default type of workload for the cluster, one of `container`, `vm-passthrough`, or `vm-vgpu`. Setting `vm-passthrough` or `vm-vgpu` can be helpful if you plan to run all or mostly virtual machines in your cluster. Refer to KubeVirt (use the `gpu-operator-kubevirt` skill), Kata Containers (use the `gpu-operator-kata-containers` skill) for more details on deploying different workload containers. | `container` |
| `sandboxWorkloads.mode` | Specifies the sandbox mode to use when deploying sandbox workloads. Accepted values are `kubevirt` (default) and `kata`. Refer to the KubeVirt (use the `gpu-operator-kubevirt` skill) or the Kata Containers (use the `gpu-operator-kata-containers` skill) pages for more information on using KubeVirt or Kata based workloads. | `kubevirt` |
| `toolkit.enabled` | By default, the Operator deploys the NVIDIA Container Toolkit (`nvidia-docker2` stack) as a container on the system. Set this value to `false` when using the Operator on systems with pre-installed NVIDIA runtimes. | `true` |
