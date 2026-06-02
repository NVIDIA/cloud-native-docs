<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Install DRA Driver for GPUs and Validate

> [!NOTE]
> The `gpuResourcesEnabledOverride=true` is an additional flag that is required to fully enable GPU allocation support.
> Include it in the Helm command if you want to enable GPU allocation support.

If you want to disable either functionality:

* To disable GPU allocation support, include `--set resources.gpus.enabled=false` in the Helm command.
* To disable ComputeDomain support, include `--set resources.computeDomains.enabled=false` in the Helm command.

> [!NOTE]
> The `nvidiaDriverRoot` flag sets the root directory for the NVIDIA GPU driver.
> The default value is `/`, which is the typical value for drivers installed directly on the host.
> If you are using GPU Operator managed drivers (default), the drivers are installed to `/run/nvidia/driver` by default.
> If you are using [pre-installed drivers](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#pre-installed-nvidia-gpu-drivers), you can remove the `nvidiaDriverRoot` flag or set it to `/` in the command above.

## GPU Allocation

1. Create a custom `values.yaml` file for installing the DRA driver helm chart.

   ### values.yaml file

   Specifies the node selector label for nodes that will support GPU allocation through the DRA Driver.

   ```yaml
   image:
     pullPolicy: IfNotPresent
   kubeletPlugin:
     nodeSelector:
       nvidia.com/dra-kubelet-plugin: "true"
   ```

   ### GKE values.yaml file

   Google Kubernetes Engine requires some specific values to be set in the `values.yaml` file, including the driver root on the host in `nvidiaDriverRoot` as well as the node selector label for nodes that will support GPU allocation through the DRA Driver.

   ```yaml
   # Specify the driver root on the host in nvidiaDriverRoot.
   # "/home/kubernetes/bin/nvidia" is the default driver root on GKE.
   nvidiaDriverRoot: "/home/kubernetes/bin/nvidia"

   controller:
     priorityClassName: ""
     affinity: null
   image:
     pullPolicy: IfNotPresent
   kubeletPlugin:
     priorityClassName: ""
     tolerations:
       - effect: NoSchedule
         key: nvidia.com/gpu
         operator: Exists
     nodeSelector:
       nvidia.com/dra-kubelet-plugin: "true"
   ```

2. Add the Helm repo:

   ```console
   helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
   && helm repo update
   ```

3. Install the DRA driver:

   ### install command

   ```console
   helm upgrade -i nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
     --version="${dra_version}" \
     --namespace nvidia-dra-driver-gpu \
     --create-namespace \
     --set nvidiaDriverRoot=/run/nvidia/driver \
     --set gpuResourcesEnabledOverride=true \
     -f values.yaml
   ```

   ### GKE install command

   ```console
   helm upgrade -i nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
     --version="${dra_version}" \
     --namespace nvidia-dra-driver-gpu \
     --create-namespace \
     --set gpuResourcesEnabledOverride=true \
     -f values.yaml
   ```

## ComputeDomain

1. Add the NVIDIA NGC Catalog's Helm chart repository:

   ```console
   helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update
   ```

2. Install the DRA driver.

   Example for Operator-provided GPU driver:

   ```console
   helm upgrade -i nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
     --version="${dra_version}" \
     --create-namespace \
     --namespace nvidia-dra-driver-gpu \
     --set resources.gpus.enabled=false \
     --set nvidiaDriverRoot=/run/nvidia/driver
   ```

   Example for host-provided GPU driver:

   ```console
   helm upgrade -i nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
     --version="${dra_version}" \
     --create-namespace \
     --namespace nvidia-dra-driver-gpu \
     --set resources.gpus.enabled=false
   ```

## Validate Installation

1. Confirm that the DRA driver components are running:

   ```console
   kubectl get pods -n nvidia-dra-driver-gpu
   ```

   *Example Output*

   ```output
   NAME                                                READY   STATUS    RESTARTS   AGE
   nvidia-dra-driver-gpu-controller-67cb99d84b-5q7kj   1/1     Running   0          7m26s
   nvidia-dra-driver-gpu-kubelet-plugin-h5xsn          1/1     Running   0          7m27s
   ```

2. Verify that GPU DeviceClasses are available:

   ```console
   kubectl get deviceclass
   ```

   *Example Output*

   ```output
   NAME              AGE
   compute-domain-daemon.nvidia.com            55s
   compute-domain-default-channel.nvidia.com   55s
   gpu.nvidia.com                              55s
   mig.nvidia.com                              55s
   ```

The `compute-domain-daemon.nvidia.com` and `compute-domain-default-channel.nvidia.com` DeviceClasses are installed when ComputeDomain support is enabled.
The `gpu.nvidia.com` and `mig.nvidia.com` DeviceClasses are installed when GPU allocation support is enabled.

Additional validation steps are available in the DRA Driver repository documentation:

* [Validate setup for ComputeDomain allocation](https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki/Validate-setup-for-ComputeDomain-allocation)
* [Validate setup for GPU allocation](https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki/Validate-setup-for-GPU-allocation)
