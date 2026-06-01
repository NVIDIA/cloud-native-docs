<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Configure KubeVirt with the GPU Operator

Throughout, replace `<gpu-operator-version>` with your target GPU Operator release.

## Label worker nodes

The GPU Operator uses the value of the `nvidia.com/gpu.workload.config` label to determine which operands to deploy on your worker node.

1. Add a `nvidia.com/gpu.workload.config` label to a worker node:

   ```console
   $ kubectl label node <node-name> --overwrite nvidia.com/gpu.workload.config=vm-vgpu
   ```

   You can assign the following values to the label:

   * `container`
   * `vm-passthrough`
   * `vm-vgpu`

   Refer to the Configure Worker Nodes for GPU Operator components section for more information on the different configurations options.

## Install the GPU Operator

Follow one of the below subsections for installing the GPU Operator, depending on whether you plan to use NVIDIA vGPU or not.

> [!NOTE]
> The following commands set the `sandboxWorkloads.enabled` flag.
> This `ClusterPolicy` flag controls whether the GPU Operator can provision GPU worker nodes for virtual machine workloads, in addition to container workloads.
> This flag is disabled by default, meaning all nodes get provisioned with the same software to enable container workloads, and the `nvidia.com/gpu.workload.config` node label is not used.

### Install the GPU Operator without NVIDIA vGPU

> [!NOTE]
> Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases).

Install the GPU Operator, enabling `sandboxWorkloads`:

```console
$ helm install --wait --generate-name \
      -n gpu-operator --create-namespace \
      nvidia/gpu-operator \
      --version=<gpu-operator-version> \
      --set sandboxWorkloads.enabled=true
```

### Install the GPU Operator with NVIDIA vGPU

Before installing the GPU Operator with NVIDIA vGPU, you must build a private NVIDIA vGPU Manager container image and push to a private registry (see [references/build-vgpu-manager.md](build-vgpu-manager.md)).
Follow the steps provided in this section.

1. Create a namespace for GPU Operator:

   ```console
   $ kubectl create namespace gpu-operator
   ```

1. Create an ImagePullSecret for accessing the NVIDIA vGPU Manager image:

   ```console
   $ kubectl create secret docker-registry ${REGISTRY_SECRET_NAME} \
      --docker-server=${PRIVATE_REGISTRY} --docker-username=<username> \
      --docker-password=<password> \
      --docker-email=<email-id> -n gpu-operator
   ```

1. Install the GPU Operator with `sandboxWorkloads` and `vgpuManager` enabled and specify the NVIDIA vGPU Manager image built previously:

   ```console
   $ helm install --wait --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --version=<gpu-operator-version> \
         --set sandboxWorkloads.enabled=true \
         --set vgpuManager.enabled=true \
         --set vgpuManager.repository=<path to private repository> \
         --set vgpuManager.image=vgpu-manager \
         --set vgpuManager.version=<driver version> \
         --set vgpuManager.imagePullSecrets={${REGISTRY_SECRET_NAME}}
   ```

The vGPU Device Manager, deployed by the GPU Operator, automatically creates vGPU devices that can be assigned to KubeVirt virtual machines.
Without additional configuration, the GPU Operator creates a default set of devices on all GPUs.
To learn more about the vGPU Device Manager and configure which types of vGPU devices get created in your cluster, refer to vGPU Device Configuration (see [references/vgpu-device-config.md](vgpu-device-config.md)).

## Add GPU resources to KubeVirt CR

Follow one of the below subsections for adding GPU resources to the KubeVirt CR, depending on whether you plan to use NVIDIA vGPU or not.

### Add vGPU resources to KubeVirt CR

Update the KubeVirt custom resource so that all vGPU devices in your cluster are permitted and can be assigned to virtual machines.

The following example shows how to permit the A10-12Q vGPU device, the device names for the GPUs on your cluster will likely be different.

1. Determine the resource names for the GPU devices:

   ```console
   $ kubectl get node cnt-server-2 -o json | jq '.status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'
   ```

   *Example Output*

   ```output
   {
     "nvidia.com/NVIDIA_A10-12Q": "4"
   }
   ```

1. Determine the PCI device IDs for the GPUs.

   * You can search by device name in the [PCI IDs database](https://pci-ids.ucw.cz/v2.2/pci.ids).

   * If you have host access to the node, you can list the NVIDIA GPU devices with a command like the following example:

     ```console
     $ lspci -nnk -d 10de:
     ```

     *Example Output*

     ```output
     65:00.0 3D controller [0302]: NVIDIA Corporation GA102GL [A10] [10de:2236] (rev a1)
             Subsystem: NVIDIA Corporation GA102GL [A10] [10de:1482]
             Kernel modules: nvidiafb, nouveau
     ```

1. Modify the `KubeVirt` custom resource like the following partial example.

   ```yaml
   ...
   spec:
     configuration:
       developerConfiguration:
         featureGates:
         - GPU
         - DisableMDEVConfiguration
       permittedHostDevices: # Defines VM devices to import.
         mediatedDevices: # Include for vGPU
         - externalResourceProvider: true
           mdevNameSelector: NVIDIA A10-12Q
           resourceName: nvidia.com/NVIDIA_A10-12Q
   ...
   ```

   Replace the values in the YAML as follows:

   * `mdevNameSelector` and `resourceName` under `mediatedDevices` to correspond to your vGPU type.

   * Set `externalResourceProvider=true` to indicate that this resource is provided by an external device plugin, in this case the `sandbox-device-plugin` that is deployed by the GPU Operator.

Refer to the [KubeVirt user guide](https://kubevirt.io/user-guide/virtual_machines/host-devices/#listing-permitted-devices) for more information on the configuration options.

### Add GPU passthrough resources to KubeVirt CR

Update the KubeVirt custom resource so that all GPU passthrough devices in your cluster are permitted and can be assigned to virtual machines.

The following example shows how to permit the A10 GPU device, the device names for the GPUs on your cluster will likely be different.

1. Determine the resource names for the GPU devices:

   ```console
   $ kubectl get node cnt-server-2 -o json | jq '.status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'
   ```

   *Example Output*

   ```output
   {
      "nvidia.com/GA102GL_A10": "1"
   }
   ```

1. Determine the PCI device IDs for the GPUs.

   * You can search by device name in the [PCI IDs database](https://pci-ids.ucw.cz/v2.2/pci.ids).

   * If you have host access to the node, you can list the NVIDIA GPU devices with a command like the following example:

     ```console
     $ lspci -nnk -d 10de:
     ```

     *Example Output*

     ```output
     65:00.0 3D controller [0302]: NVIDIA Corporation GA102GL [A10] [10de:2236] (rev a1)
             Subsystem: NVIDIA Corporation GA102GL [A10] [10de:1482]
             Kernel modules: nvidiafb, nouveau
     ```

1. Modify the `KubeVirt` custom resource like the following partial example.

   ```yaml
   ...
   spec:
     configuration:
       developerConfiguration:
         featureGates:
         - GPU
         - DisableMDEVConfiguration
       permittedHostDevices: # Defines VM devices to import.
         pciHostDevices: # Include for GPU passthrough
         - externalResourceProvider: true
           pciVendorSelector: 10DE:2236
           resourceName: nvidia.com/GA102GL_A10
   ...
   ```

   Replace the values in the YAML as follows:

   * `pciVendorSelector` and `resourceName` under `pciHostDevices` to correspond to your GPU model.

   * Set `externalResourceProvider=true` to indicate that this resource is provided by an external device plugin, in this case the `sandbox-device-plugin` that is deployed by the GPU Operator.

Refer to the [KubeVirt user guide](https://kubevirt.io/user-guide/virtual_machines/host-devices/#listing-permitted-devices) for more information on the configuration options.

## Create a virtual machine with GPU

After the `sandbox-device-plugin` pod is running on your worker nodes and the GPU resources have been added to the
KubeVirt allowlist, you can assign a GPU to a virtual machine by editing the `spec.domain.devices.gpus` field
in the `VirtualMachineInstance` manifest.

Example for GPU passthrough:

```yaml
apiVersion: kubevirt.io/v1alpha3
kind: VirtualMachineInstance
...
spec:
  domain:
    devices:
      gpus:
      - deviceName: nvidia.com/GA102GL_A10
        name: gpu1
...
```

Example for vGPU:

```yaml
apiVersion: kubevirt.io/v1alpha3
kind: VirtualMachineInstance
...
spec:
  domain:
    devices:
      gpus:
      - deviceName: nvidia.com/NVIDIA_A10-12Q
        name: gpu1
...
```

* `deviceName` is the resource name representing the device.

* `name` is a name to identify the device in the virtual machine
