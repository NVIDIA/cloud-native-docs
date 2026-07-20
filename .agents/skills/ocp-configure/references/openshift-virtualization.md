# NVIDIA GPU Operator with OpenShift Virtualization

<a id="nvidia-gpu-operator-openshift-virtualization-vgpu-enablement"></a>

# NVIDIA GPU Operator with OpenShift Virtualization

## Introduction

There is a growing demand among Red Hat customers to use virtual GPUs (NVIDIA vGPU)
with Red Hat OpenShift Virtualization.
Red Hat OpenShift Virtualization is based on KubeVirt, a virtual machine (VM) management add-on to Kubernetes that allows you to run and manage VMs in a Kubernetes cluster.
It eliminates the need to manage separate clusters for VM and container workloads, as both can now coexist in a single Kubernetes cluster.
Red Hat OpenShift Virtualization is an OpenShift feature to run virtual machines (VMs) orchestrated by OpenShift (Kubernetes).

In addition to the GPU Operator being able to provision worker nodes for running GPU-accelerated containers, the GPU Operator can also be used to provision worker nodes for running GPU-accelerated virtual machines.

There are some different prerequisites required when running virtual machines with GPUs compared to running containers with GPUs.
The primary difference is the drivers required.
For example, the datacenter driver is needed for containers, the vfio-pci driver is needed for GPU passthrough, and the [NVIDIA vGPU Manager](https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#installing-configuring-grid-vgpu) is needed for creating vGPU devices.

<a id="configure-worker-nodes-for-gpu-operator-components"></a>

### Configure Worker Nodes for GPU Operator components

The GPU Operator can now be configured to deploy different software components on worker nodes depending on what GPU workload is configured to run on those nodes.
This is configured by adding a `nvidia.com/gpu.workload.config` label to the worker node with the value of `container`, `vm-passthrough`, or `vm-vgpu` depending on if you are planning to use vGPU or not.
The GPU Operator will use the label to determine which software components to deploy on the worker nodes.

Given the following node configuration:

- Node A is configured to run containers.
- Node B is configured to run VMs with Passthrough GPU.
- Node C is configured to run VMs with vGPU.

Node A receives the following software components:

- `NVIDIA Datacenter Driver` - To install the driver.
- `NVIDIA Container Toolkit` - To ensure containers can properly access GPUs.
- `NVIDIA Kubernetes Device Plugin` - To discover and advertise GPU resources to the kubelet.
- `NVIDIA DCGM and DCGM Exporter` - To monitor the GPU(s).

There are two approaches to configuring GPU passthrough and vGPU for virtual machines:

1. **NVIDIA GPU Operator approach** - Uses the GPU Operator to deploy and manage GPU software components.
2. **Red Hat OpenShift Virtualization approach** - Uses Red Hat OpenShift Virtualization native procedures, which are tested and supported by Red Hat.

Node B (GPU Passthrough) receives the following software components:

**NVIDIA GPU Operator approach:**

- `VFIO Manager` - To load vfio-pci and bind it to all GPUs on the node.
- `Sandbox Device Plugin` - To discover and advertise the passthrough GPUs to the kubelet.
- `Sandbox Validator` - Validates that Sandbox Device Plugin is working.

**Red Hat OpenShift Virtualization approach:**

- Uses Red Hat OpenShift Virtualization's [PCI passthrough configuration](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html-single/virtualization/index#virt-configuring-pci-passthrough).
- When using this approach, NVIDIA GPU Operator's operands must be disabled on the node to avoid conflicts.

Node C (vGPU) receives the following software components:

**NVIDIA GPU Operator approach:**

- `NVIDIA vGPU Manager` - To install the driver.
- `NVIDIA vGPU Device Manager` - To create vGPU devices on the node.
- `Sandbox Device Plugin` - To discover and advertise the vGPU devices to kubelet.
- `Sandbox Validator` - Validates that Sandbox Device Plugin is working.

**Red Hat OpenShift Virtualization approach:**

- Uses Red Hat OpenShift Virtualization's [vGPU configuration](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html-single/virtualization/index#virt-configuring-virtual-gpus).
- Relies on OpenShift Virtualization’s capabilities to configure mediated devices.
- The NVIDIA GPU Operator is only used for installing drivers with the NVIDIA vGPU Manager. The GPU Operator does not configure mediated devices.

### Assumptions, constraints, and dependencies

- A worker node can run GPU-accelerated containers, or GPU accelerated VMs with GPU passthrough, or GPU accelerated-VMs with vGPU, but not a combination of any of them.
- The cluster admin or developer has knowledge about their cluster ahead of time and can properly label nodes to indicate what types of GPU workloads they will run.
- Worker nodes running GPU accelerated VMs (with pGPU or vGPU) are assumed to be bare metal.
- The GPU Operator will not automate the installation of the vGPU guest driver inside KubeVirt VMs with vGPUs attached.
- There are two separate device plugins – the NVIDIA k8s-device-plugin and the NVIDIA kubevirt-gpu-device-plugin.
- KubeVirt/Openshift virtualization provides built-in device plugins. These are the default tested device plugins.

## Prerequisites

- [Install the OpenShift Virtualization Operator](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/virtualization/installing).

- [Install the virtctl client](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/virtualization/getting-started#installing-virtctl_virt-using-the-cli-tools).

- Starting with OpenShift Virtualization 4.12.3 and 4.13.0, set the `disableMDevConfiguration` feature gate:

  ```console
  $ kubectl patch hyperconverged -n openshift-cnv  kubevirt-hyperconverged --type='json' -p='[{"op": "add", "path": "/spec/featureGates/disableMDevConfiguration", "value": true}]'
  ```

  *Example Output*

  ```output
  hyperconverged.hco.kubevirt.io/kubevirt-hyperconverged patched
  ```

- If planning to use NVIDIA vGPU, SR-IOV must be enabled in the BIOS if your GPUs are based on the NVIDIA Ampere architecture or later. Refer to the [NVIDIA vGPU Documentation](https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#prereqs-vgpu) to ensure you have met all the prerequisites for using NVIDIA vGPU.

## Configure NVIDIA GPU Operator with OpenShift Virtualization

After configuring the {ref}`prerequisites<prerequisites>`, the high-level workflow for using the NVIDIA GPU Operator with OpenShift Virtualization is as follows:

- {ref}`Enable the IOMMU driver <enable-iommu-driver>`.
- {ref}`Label worker nodes <label-worker-nodes>` based on the GPU workloads they will run.
- {ref}`Install the GPU Operator <install-the-gpu-operator>` and set `sandboxWorkloads.enabled=true`.

If you are planning to deploy VMs with vGPU, the workflow is as follows:
: - {ref}`Build the NVIDIA vGPU Manager image <build-vgpu-manager-image>`, before installing the GPU Operator.
  - {ref}`Label the node for the vGPU configuration <vgpu-device-configuration>`
  - {ref}`Add vGPU resources to the HyperConverged Custom Resource <add-vgpu-resources-to-the-hyperconverged-custom-resource>`
  - {ref}`Create a virtual machine with vGPU <create-a-virtual-machine-with-gpu>`

If you are planning to deploy VMs with GPU passthrough, the workflow is as follows:
: - {ref}`Add GPU resources to the HyperConverged Custom Resource <add-gpu-resources-to-the-hyperconverged-custom-resource>`.
  - {ref}`Create a virtual machine with GPU passthrough <create-a-virtual-machine-with-gpu>`

<a id="enable-iommu-driver"></a>

## Enabling the IOMMU driver on hosts

To enable the IOMMU (Input-Output Memory Management Unit) driver in the kernel, create the `MachineConfig` object and add the kernel arguments.

### Prerequisites

- Administrative privilege to a working OpenShift Container Platform cluster.
- Intel or AMD CPU hardware.
- Intel Virtualization Technology for Directed I/O extensions or AMD IOMMU in the BIOS (Basic Input/Output System) is enabled.

### Procedure

1. Create a `MachineConfig` object that identifies the kernel argument.
   The following example shows a kernel argument for an Intel CPU.

   ```yaml
   apiVersion: machineconfiguration.openshift.io/v1
   kind: MachineConfig
   metadata:
     labels:
       machineconfiguration.openshift.io/role: worker
     name: 100-worker-iommu
   spec:
     config:
       ignition:
         version: 3.2.0
     kernelArguments:
         - intel_iommu=on
         # If you are using AMD CPU, include the following argument:
         # - amd_iommu=on
   ```

2. Create the new `MachineConfig` object.

   ```console
   $ oc create -f 100-worker-kernel-arg-iommu.yaml
   ```

3. Verify that the new `MachineConfig` object was added.

   ```console
   $ oc get machineconfig
   ```

<a id="label-worker-nodes"></a>

## Labeling worker nodes

Use the following command to add a label to a worker node.

```console
$ oc label node <node-name> --overwrite nvidia.com/gpu.workload.config=vm-vgpu
```

You can assign the following values to the label: `container`, `vm-passthrough`, and `vm-vgpu`.
The GPU Operator uses the value of this label to determine which operands to deploy.

If the node label `nvidia.com/gpu.workload.config` does not exist on the node, the GPU Operator assumes the default GPU workload configuration, `container`, and deploys the software components needed to support this workload type.
To change the default GPU workload configuration, set the following value in `ClusterPolicy`: `sandboxWorkloads.defaultWorkload=<config>`.

<a id="build-vgpu-manager-image"></a>

## Building the vGPU Manager Image

**Note:**

Building a vGPU Manager image is only required for NVIDIA vGPU.
If you plan to use GPU Passthrough only, skip this section.

Use the following steps to build the vGPU Manager container and push it to a private registry.

1. Download the vGPU Software from the [NVIDIA Licensing Portal](https://nvid.nvidia.com/dashboard/#/dashboard).

   **For NVIDIA AI Enterprise customers, download:**

   - Login to the NVIDIA Licensing Portal and navigate to the **Software Downloads** section.
   - Navigate to **[GPU Name] > NVAIE** then **Platform > Linux KVM**.
   - Download the **NVAIE [GPU Name] Linux KVM driver**. NVIDIA AI Enterprise customers must use the `aie` .run file for building the NVIDIA vGPU Manager image. After downloading, and rename the file to `NVIDIA-Linux-x86_64-<version>-vgpu-kvm.run`. Refer to the `Infrastructure Support Matrix` under section under the [NVIDIA AI Enterprise Infra Release Branches](https://docs.nvidia.com/ai-enterprise/index.html#infrastructure-software) for details on supported version number to use.

   **For non-NVIDIA AI Enterprise customers:**

   - Login to the NVIDIA Licensing Portal and navigate to the **Software Downloads** section.

   - The NVIDIA vGPU Software is located on the **Driver downloads** tab of the **Software Downloads** page.

   - Click the **Download** link for the Linux KVM complete vGPU package.

     Confirm that the **Product Version** column shows the vGPU version to install.
     Unzip the bundle to obtain the NVIDIA vGPU Manager for Linux file, `NVIDIA-Linux-x86_64-<version>-vgpu-kvm.run`.

   Use the following steps to clone the driver container repository and build the driver image.

2. Open a terminal and clone the driver container image repository:

   ```console
   $ git clone https://github.com/NVIDIA/gpu-driver-container.git
   $ cd gpu-driver-container
   ```

3. Copy the NVIDIA vGPU manager from your extracted ZIP file to the operating system version you want to build the image for:
   \* We use RHEL 8 as an example.

   Copy `<local-driver-download-directory>/\*-vgpu-kvm.run` to `vgpu-manager/rhel8/`.

   ```console
   $ cp <local-driver-download-directory>/*-vgpu-kvm.run vgpu-manager/rhel8/
   ```

4. Set the following environment variables.

   - `PRIVATE_REGISTRY` - Name of the private registry used to store the driver image.
   - `VGPU_HOST_DRIVER_VERSION` - The NVIDIA vGPU Manager version downloaded from the NVIDIA Software Portal.
   - `OS_TAG` - This must match the Guest OS version.

**Note:**

The driver container image tag for OpenShift has changed after the OCP 4.19 release.
Refer to [OpenShift Container Platform 4.19 Release Notes section 1.4.5](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/release_notes/ocp-4-19-release-notes#ocp-4-19-rhcos-split-layers_release-notes),
[RHEL Versions Utilized by RHEL CoreOS and OCP](https://access.redhat.com/articles/6907891),
and [Split RHCOS into layers: /etc/os-release](https://github.com/openshift/enhancements/blob/master/enhancements/rhcos/split-rhcos-into-layers.md#etcos-release)
for more information.

For RedHat OpenShift 4.18 or earlier, specify `rhcos4.x` where \_x\_ is the supported minor OCP version.

```console
$ export PRIVATE_REGISTRY=my/private/registry VGPU_HOST_DRIVER_VERSION=580.82.07 OS_TAG=rhcos4.18
```

For OpenShift 4.19 and later, specify `rhel9.6` instead.

```console
$ export PRIVATE_REGISTRY=my/private/registry VGPU_HOST_DRIVER_VERSION=580.82.07 OS_TAG=rhel9.6
```

**Note:**

The recommended registry to use is the Integrated OpenShift Container Platform registry.
For more information about the registry, refer to [Accessing the registry](https://docs.openshift.com/container-platform/latest/registry/accessing-the-registry.html).

1. Build the NVIDIA vGPU Manager image.

   **Note:**

Docker is the only supported container tool for building the vGPU Manager image.
   Multi-architecture builds additionally require [buildx](https://github.com/docker/buildx).
   :::

   ```console
   $ VGPU_HOST_DRIVER_VERSION=${VGPU_HOST_DRIVER_VERSION} IMAGE_NAME=${PRIVATE_REGISTRY}/vgpu-manager make build-vgpuhost-${OS_TAG}
   ```

2. Push the NVIDIA vGPU Manager image to your private registry.

   ```console
   $ VGPU_HOST_DRIVER_VERSION=${VGPU_HOST_DRIVER_VERSION} IMAGE_NAME=${PRIVATE_REGISTRY}/vgpu-manager make push-vgpuhost-${OS_TAG}
   ```

<a id="install-the-gpu-operator"></a>

## Installing the NVIDIA GPU Operator

Install the NVIDIA GPU Operator using the guidance at {ref}`Installing the NVIDIA GPU Operator <install-nvidiagpu>`.{note}
When prompted to create a cluster policy follow the guidance {ref}`Creating a ClusterPolicy for the GPU Operator<install-cluster-policy-vGPU>`.
:::

### Create the secret

OpenShift has a secret object type which provides a mechanism for holding sensitive information such as passwords and private source repository credentials. Next you will create a secret object for storing your registry API key (the mechanism used to authenticate your access to the
private container registry).

**Note:**

Before you begin you will need to generate or use an existing API key for your private registry.

1. Navigate to **Home** > **Projects** and ensure the `nvidia-gpu-operator` is selected.

2. In the OpenShift Container Platform web console, click **Secrets** from the Workloads drop down.

3. Click the **Create** Drop down.

4. Select Image Pull Secret.

   ```{image} graphics/secrets.png
   ```

5. Enter the following into each field:

   - **Secret name**: private-registry-secret
   - **Authentication type**: Image registry credentials
   - **Registry server address**: \<private-registry_address>
   - **Username**: \$oauthtoken
   - **Password**: \<API-KEY>
   - **Email**: \<YOUR-EMAIL>

6. Click **Create**.

   A pull secret is created.

<a id="install-cluster-policy-vgpu"></a>

### Creating a ClusterPolicy for the GPU Operator using the OpenShift Container Platform CLI

As a cluster administrator, you can create a ClusterPolicy using the OpenShift Container Platform CLI.
Create the cluster policy using the CLI:

1. Create the ClusterPolicy:

   ```console
   $ oc get csv -n nvidia-gpu-operator $STARTING_CSV -o jsonpath='{.metadata.annotations.alm-examples}' | jq -r 'map(select(.kind == "ClusterPolicy")) | .[0]' > clusterpolicy.json
   ```

   **Note:**

`$STARTING_CSV` is the value of the `startingCSV` field in the `Subscription` CR created in the {ref}`install-gpu-ocp` section.
   :::

2. Modify the `clusterpolicy.json` file as follows:

   - sandboxWorkloads.enabled=true
   - sandboxDevicePlugin.enabled=true
   - For GPU passthrough:
     : - vfioManager.enabled=true
       - Optionally, sandboxWorkloads.defaultWorkload=vm-passthrough (if you want passthrough to be the default mode)
   - For vGPU:
     : - vgpuManager.enabled=true
       - vgpuManager.repository=\<path to private repository>
       - vgpuManager.image=vgpu-manager
       - vgpuManager.version=\<driver version>
       - vgpuManager.imagePullSecrets={\<name of image pull secret>}
       - vgpuDeviceManager.enabled=true

   In general, the flag `sandboxWorkloads.enabled` in `ClusterPolicy` controls whether the GPU Operator can provision GPU worker nodes for virtual machine workloads, in addition to container workloads. This flag is disabled by default, meaning all nodes get provisioned with the same software which enables container workloads, and the `nvidia.com/gpu.workload.config` node label is not used.

   The term *sandboxing* refers to running software in a separate isolated environment, typically for added security (that is, a virtual machine). We use the term `sandbox workloads` to signify workloads that run in a virtual machine, irrespective of the virtualization technology used.

3. Apply the changes:

   ```console
   $ oc apply -f clusterpolicy.json
   ```

   ```console
   clusterpolicy.nvidia.com/gpu-cluster-policy created
   ```

The vGPU Device Manager, deployed by the GPU Operator, automatically creates vGPU devices which can be assigned to KubeVirt VMs.
Without additional configuration, the GPU Operator creates a default set of devices on all GPUs.
To learn more about how the vGPU Device Manager and configure which types of vGPU devices get created in your cluster, refer to {ref}`vGPU Device Configuration<vgpu-device-configuration>`.

### Creating a ClusterPolicy for the GPU Operator using the OpenShift Container Platform Web Console

As a cluster administrator, you can create a ClusterPolicy using the OpenShift Container Platform web console.

1. Navigate to **Ecosystem** > **Installed Operators** (for versions before 4.20, look for **Operators** > **Installed Operators**) and find your installed NVIDIA GPU Operator.

2. Under *Provided APIs*, click **ClusterPolicy**.

   ```{image} graphics/navigate_to_cluster_policy.png
   ```

3. Click **Create ClusterPolicy**.

   ```{image} graphics/create_cluster_policy.png
   ```

4. Expand the **NVIDIA GPU/vGPU Driver config** section.

5. Expand the **Sandbox Workloads config** section and select the checkbox to enable sandbox workloads.

   In general, when sandbox workloads are enabled, `ClusterPolicy` controls whether the GPU Operator can provision GPU worker nodes for virtual machine workloads, in addition to container workloads. This flag is disabled by default, meaning all nodes get provisioned with the same software which enables container workloads, and the `nvidia.com/gpu.workload.config` node label is not used.

   The term *sandboxing* refers to running software in a separate isolated environment, typically for added security (that is, a virtual machine). We use the term `sandbox workloads` to signify workloads that run in a virtual machine, irrespective of the virtualization technology used.
   \* Click **Create** to create the ClusterPolicy.

   ```{image} graphics/cluster_policy_enable_sandbox_workloads.png
   ```

6. Expand the **Sandbox Device Plugin config** section and make sure that the **enabled** checkbox is checked.

7. If you are planning to use NVIDIA vGPU

   - Expand the **NVIDIA vGPU Manager config** section and fill in your desired configuration settings, including:
     : - Select the **enabled** checkbox to enable the NVIDIA vGPU Manager.
       - Add your **imagePullSecrets**.
       - Under *driverManager*, fill in **repository** with the path to your private repository.
       - Under *env*, fill in **image** with `vgpu-manager` and the **version** with your driver version.
   - Expand the **NVIDIA vGPU Device Manager config** section and make sure that the **enabled** checkbox is checked.

   If you are only using GPU passthrough, you do not need to fill these sections out.

   - Expand the **VFIO Manager config** section and select the **enabled** checkbox.
   - Optionally, in the **Sandbox Workloads config** section, set **defaultWorkload** to `vm-passthrough` if you want passthrough to be the default mode.

   ```{image} graphics/cluster_policy_configure_vgpu.png
   ```

8. Click **Create** to create the ClusterPolicy.

   The vGPU Device Manager, deployed by the GPU Operator, automatically creates vGPU devices which can be assigned to KubeVirt VMs.
   Without additional configuration, the GPU Operator creates a default set of devices on all GPUs.
   To learn more about the vGPU Device Manager and how to configure which types of vGPU devices get created in your cluster, refer to {ref}`vGPU Device Configuration<vgpu-device-configuration>`.

## Add GPU Resources to the HyperConverged Custom Resource

Update the `HyperConverged` custom resource so that all GPU and vGPU devices in your cluster are permitted and can be assigned to virtual machines.

<a id="add-gpu-resources-to-the-hyperconverged-custom-resource-1"></a>

### Add GPU passthrough resources to the HyperConverged Custom Resource

The following example permits the A10 GPU device, the device names for the GPUs on your cluster will likely be different.

1. Determine the resource names for the GPU devices.

   ```console
   $ oc get node cnt-server-2 -o json | jq '.status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'
   ```

   *Example Output*

   ```output
   {
     "nvidia.com/GA102GL_A10": "1"
   }
   ```

2. Determine the PCI device IDs for the GPUs.

   - You can search by device name in the [PCI IDs database](https://pci-ids.ucw.cz/v2.2/pci.ids).

   - If you have host access to the node, you can list the NVIDIA GPU devices with a command like the following example:

     ```console
     $ lspci -nnk -d 10de:
     ```

     *Example Output*

     ```{code-block} output

     65:00.0 3D controller [0302]: NVIDIA Corporation GA102GL [A10] [10de:2236] (rev a1)
             Subsystem: NVIDIA Corporation GA102GL [A10] [10de:1482]
             Kernel modules: nvidiafb, nouveau
     ```

3. Modify the `HyperConverged` custom resource like the following partial examples.

   ```yaml
   ...
   spec:
      featureGates:
         disableMDevConfiguration: true
      permittedHostDevices: # Defines VM devices to import.
         pciHostDevices: # Include for GPU passthrough
         - externalResourceProvider: true
           pciDeviceSelector: 10DE:2236
           resourceName: nvidia.com/GA102GL_A10
   ...
   ```

   Replace the values in the YAML as follows.

   - `pciDeviceSelector` and `resourceName` under `pciHostDevices` to correspond to your GPU type.
   - Set `externalResourceProvider=true` to indicate that this resource is provided by an external device plugin, in this case the `sandbox-device-plugin` that is deployed by the GPU Operator.

Refer to the [KubeVirt user guide](https://kubevirt.io/user-guide/virtual_machines/host-devices/#listing-permitted-devices) for more information on the configuration options.

<a id="add-vgpu-resources-to-the-hyperconverged-custom-resource"></a>

### Add vGPU resources to the HyperConverged Custom Resource

The following example permits the A10-12Q vGPU device, the device names for the GPUs on your cluster will likely be different.

1. Determine the resource names for the GPU devices.

   ```console
   $ oc get node cnt-server-2 -o json | jq '.status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'
   ```

   *Example Output*

   ```output
   {
     "nvidia.com/NVIDIA_A10-12Q": "4"
   }
   ```

2. Determine the PCI device IDs for the GPUs.

   - You can search by device name in the [PCI IDs database](https://pci-ids.ucw.cz/v2.2/pci.ids).

   - If you have host access to the node, you can list the NVIDIA GPU devices with a command like the following example:

     ```console
     $ lspci -nnk -d 10de:
     ```

     *Example Output*

     ```{code-block} output

     65:00.0 3D controller [0302]: NVIDIA Corporation GA102GL [A10] [10de:2236] (rev a1)
             Subsystem: NVIDIA Corporation GA102GL [A10] [10de:1482]
             Kernel modules: nvidiafb, nouveau
     ```

3. Modify the `HyperConverged` custom resource like the following partial examples.

   ```yaml
   ...
   spec:
     featureGates:
       disableMDevConfiguration: true
     permittedHostDevices: # Defines VM devices to import.
       mediatedDevices: # Include for vGPU
       - externalResourceProvider: true
         mdevNameSelector: NVIDIA A10-12Q
         resourceName: nvidia.com/NVIDIA_A10-12Q
   ...
   ```

   Replace the values in the YAML as follows.

   - `mdevNameSelector` and `resourceName` under `mediatedDevices` to correspond to your vGPU type.
   - Set `externalResourceProvider=true` to indicate that this resource is provided by an external device plugin, in this case the `sandbox-device-plugin` that is deployed by the GPU Operator.

Refer to the [KubeVirt user guide](https://kubevirt.io/user-guide/virtual_machines/host-devices/#listing-permitted-devices) for more information on the configuration options.

### About Mediated Devices

A physical device that is divided into one or more virtual devices. A vGPU is a type of mediated device
(mdev); the performance of the physical GPU is divided among the virtual devices. You can assign mediated
devices to one or more virtual machines (VMs), but the number of guests must be compatible with your GPU.
Some GPUs do not support multiple guests.

<a id="create-a-virtual-machine-with-gpu"></a>

## Creating a virtual machine with GPU

Assign GPU devices, either passthrough or vGPU, to virtual machines.

### Prerequisites

- The GPU devices are configured in the `HyperConverged` custom resource (CR).

### Procedure

1. Assign the GPU devices to a virtual machine (VM) by editing the `spec.domain.devices.gpus` field of the `VirtualMachine` manifest:

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

   - `deviceName` The resource name associated with the GPU.
   - `name` A name to identify the device on the VM.

<a id="vgpu-device-configuration"></a>

## vGPU Device Configuration

The vGPU Device Manager assists in creating vGPU devices on GPU worker nodes.

The vGPU Device Manager allows administrators to declaratively define a set of possible vGPU device configurations they would like applied to GPUs on a node.
At runtime, they then point the vGPU Device Manager at one of these configurations, and vGPU Device Manager takes care of applying it.

The configuration file is created as a ConfigMap, and is shared across all worker nodes.
At runtime, a node label, `nvidia.com/vgpu.config`, can be used to decide which of these configurations to actually apply to a node at any given time.
If the node is not labeled, then the `default` configuration will be used.

For more information on this component and how it is configured, refer to the project [README](https://github.com/NVIDIA/vgpu-device-manager).

By default, the GPU Operator deploys a ConfigMap for the vGPU Device Manager, containing named configurations for all [vGPU types](https://docs.nvidia.com/grid/latest/grid-vgpu-user-guide/index.html#supported-gpus-grid-vgpu) supported by NVIDIA vGPU.
The GPU Operator only adds Q and C profiles in the default ConfigMap
Users can select a specific configuration for a worker node by applying the `nvidia.com/vgpu.config` node label.

For example, labeling a node with `nvidia.com/vgpu.config=A10-8Q` would create 3 vGPU devices of type **A10-8Q** on all **A10** GPUs on the node (note: 3 is the maximum number of **A10-8Q** devices that can be created per GPU).
If the node is not labeled, the `default` configuration will be applied.

The `default` configuration will create Q-series vGPU devices on all GPUs, where the amount of framebuffer memory per vGPU device is half the total GPU memory.
For example, the `default` configuration will create two **A10-12Q** devices on all **A10** GPUs.

You can also create different vGPU Q profiles on the same GPU using vGPU Device Manager configuration.
For example, you can create a **A10-4Q** and a **A10-6Q** device on same GPU by creating a vGPU Device Manager configuration with the following content:

```yaml
version: v1
vgpu-configs:
  custom-A10-config:
    - devices: all
       vgpu-devices:
         "A10-4Q": 3
         "A10-6Q": 2
```

If custom vGPU device configuration is desired, more than the default ConfigMap provides, you can create your own ConfigMap:

```console
$ oc create configmap custom-vgpu-config -n gpu-operator --from-file=config.yaml=/path/to/file
```

And then configure the GPU Operator to use it by setting `vgpuDeviceManager.config.name=custom-vgpu-config`.

### Apply a New vGPU Device Configuration

Apply a specific vGPU device configuration on a per-node basis by setting the `nvidia.com/vgpu.config` node label. It is recommended to set this node label prior to installing the GPU Operator if you do not want the default configuration applied.

Switching vGPU device configuration after one has been successfully applied assumes that no VMs with vGPU are currently running on the node. Any existing VMs will have to be shutdown/migrated first.

To apply a new configuration after GPU Operator install, simply update the `nvidia.com/vgpu.config` node label.{note}
On GPUs that support MIG, you have the option to select MIG-backed vGPU instances instead of time-sliced vGPU instances.
To select a MIG-backed vGPU profile, label the node with the name of the MIG-backed vGPU profile.
:::

The following example shows a system with two **A10** GPUs.

```console
$ nvidia-smi -L
GPU 0: NVIDIA A10 (UUID: GPU-ebd34bdf-1083-eaac-2aff-4b71a022f9bd)
GPU 1: NVIDIA A10 (UUID: GPU-1795e88b-3395-b27b-dad8-0488474eec0c)
```

After installing the GPU Operator as detailed in the previous sections and without labeling the node with `nvidia.com/vgpu.config`, the `default` vGPU config get applied -- four **A10-12Q** devices get created (two per GPU):

```console
$ oc get node cnt-server-2 -o json | jq '.status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'
{
   "nvidia.com/NVIDIA_A10-12Q": "4"
}
```

If instead you want to create **A10-4Q** devices, label the node as follows:

```console
$ oc label node <node-name> --overwrite nvidia.com/vgpu.config=A10-4Q
```

After the vGPU Device Manager finishes applying the new configuration, all GPU Operator pods should return to the Running state.

```console
$ oc get pods -n gpu-operator
NAME                                                          READY   STATUS    RESTARTS   AGE
...
nvidia-sandbox-device-plugin-daemonset-brtb6                  1/1     Running   0          10s
nvidia-sandbox-validator-ljnwg                                1/1     Running   0          10s
nvidia-vgpu-device-manager-8mgg8                              1/1     Running   0          30m
nvidia-vgpu-manager-daemonset-fpplc                           1/1     Running   0          31m
```

You should now see 12 **A10-4Q** devices on the node, as 6 **A10-4Q** devices can be created per **A10** GPU.

```console
$ oc get node cnt-server-2 -o json | jq '.status.allocatable | with_entries(select(.key | startswith("nvidia.com/"))) | with_entries(select(.value != "0"))'
{
   "nvidia.com/NVIDIA_A10-4Q": "12"
}
```
