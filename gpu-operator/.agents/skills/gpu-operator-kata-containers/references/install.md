<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Configure and Install Kata Containers with the GPU Operator

## Label Nodes to use Kata Containers

1. Get a list of the nodes in your cluster:

   ```console
   $ kubectl get nodes
   ```

   *Example Output:*

   ```output
   NAME          STATUS   ROLES           AGE   VERSION
   node-01       Ready    <none>          10d   v1.34.0
   node-02       Ready    <none>          10d   v1.34.0
   ```

1. Label the nodes you want to use for Kata Containers:

   ```console
   $ kubectl label node <node-name> nvidia.com/gpu.workload.config=vm-passthrough
   ```

   The GPU Operator uses this label to determine what software components to deploy to a node.
   The `nvidia.com/gpu.workload.config=vm-passthrough` label specifies that the node should receive the software components to run Kata Containers.
   A node can only run one container runtime at a time, so a labeled node runs only Kata container workloads and cannot run traditional GPU container workloads.
   The labeling approach is useful if you want to run Kata container workloads on some nodes and traditional GPU container workloads on other nodes in your cluster.
   Refer to the GPU Operator Cluster Topology Considerations section for more details on what gets deployed to a Kata Container node.

   > [!TIP]
   > Skip this section if you plan to set `sandboxWorkloads.defaultWorkload=vm-passthrough` when you install the GPU Operator.

   1. Verify the node label was added:

   ```console
   $ kubectl describe node <node-name> | grep nvidia.com/gpu.workload.config
   ```

   *Example Output:*

   ```output
   nvidia.com/gpu.workload.config: vm-passthrough
   ```

After labeling the nodes, you can continue to the next steps to install Kata Containers and the NVIDIA GPU Operator.

## Install the Kata Containers Helm Chart

Install Kata Containers using the `kata-deploy` Helm chart.
The `kata-deploy` chart installs all required components from the Kata Containers project including the Kata Containers runtime binary, runtime configuration, UVM kernel, and images that NVIDIA uses for Kata Containers.

The minimum required version is 3.29.0.

1. Set the chart version and registry path:

   ```console
   $ export VERSION="3.29.0"
   $ export CHART="oci://ghcr.io/kata-containers/kata-deploy-charts/kata-deploy"
   ```

1. Install the kata-deploy Helm chart:

   ```console
   $ helm install kata-deploy "${CHART}" \
      --namespace kata-system --create-namespace \
      --set nfd.enabled=false \
      --wait --timeout 10m \
      --version "${VERSION}"
   ```

   *Example Output:*

   ```output
   LAST DEPLOYED: Wed Apr  1 17:03:00 2026
   NAMESPACE: kata-system
   STATUS: deployed
   REVISION: 1
   DESCRIPTION: Install complete
   TEST SUITE: None
   ```

   > [!NOTE]
   > The `--wait` flag in the install command instructs Helm to wait until the release is deployed before returning.
   > It can take a few minutes to return output.

   There is a [known Helm issue](https://github.com/helm/helm/issues/8660) on single node clusters, that may result in the Helm command finishing before all deployed pods are finished initializing.
   If you are deploying to a single node cluster, you may need to wait for an additional few minutes after the Helm command completes for the `kata-deploy` pod to be in the Running state.
   > [!NOTE]
   > Both `kata-deploy` and the GPU Operator deploy Node Feature Discovery (NFD) by default.
   > The install command includes `--set nfd.enabled=false` to prevent `kata-deploy` from deploying NFD.
   > The GPU Operator will deploy and manage NFD in the next step.

   1. Optional: Verify that the `kata-deploy` pod is running:

   ```console
   $ kubectl get pods -n kata-system | grep kata-deploy
   ```

   *Example Output:*

   ```output
   NAME                    READY   STATUS    RESTARTS      AGE
   kata-deploy-b2lzs       1/1     Running   0             6m37s
   ```

1. Optional: Verify that the `kata-qemu-nvidia-gpu` runtime class is available:

   ```console
   $ kubectl get runtimeclass | grep kata-qemu-nvidia-gpu
   ```

   *Example Output:*

   ```output
   NAME                       HANDLER                    AGE
   kata-qemu-nvidia-gpu       kata-qemu-nvidia-gpu       40s
   kata-qemu-nvidia-gpu-snp   kata-qemu-nvidia-gpu-snp   40s
   kata-qemu-nvidia-gpu-tdx   kata-qemu-nvidia-gpu-tdx   40s
   ```

   Several runtime classes are installed by the `kata-deploy` chart.
   The `kata-qemu-nvidia-gpu` runtime class is used with Kata Containers.
   The `kata-qemu-nvidia-gpu-snp` and `kata-qemu-nvidia-gpu-tdx` runtime classes are used to deploy Confidential Containers.

   > [!NOTE]
   > To manage the lifecycle of Kata Containers, including upgrades and day-two operations,
   > install the [Kata Lifecycle Manager](https://github.com/kata-containers/lifecycle-manager).
   > This Argo Workflows-based tool is the recommended way to manage Kata Containers deployments.

   1. Optional: If you have an issue deploying the `kata-deploy` pod or are not seeing the expected runtime classes, get the pod name and view the logs:

   ```console
   $ kubectl get pods -n kata-system | grep kata-deploy
   $ kubectl logs -n kata-system <pod-name>
   ```

   Replace `<pod-name>` with the name of the `kata-deploy` pod from the first command's output.

## Install the NVIDIA GPU Operator

Install the NVIDIA GPU Operator and configure it to deploy Kata Container components.

1. Add and update the NVIDIA Helm repository:

   ```console
   $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
      && helm repo update
   ```

   *Example Output:*

   ```output
   "nvidia" has been added to your repositories
   Hang tight while we grab the latest from your chart repositories...
   ...Successfully got an update from the "nvidia" chart repository
   Update Complete. ⎈Happy Helming!⎈
   ```

> [!NOTE]
> Replace `<gpu-operator-version>` with your target GPU Operator release; see the [releases page](https://github.com/NVIDIA/gpu-operator/releases).

1. Install the GPU Operator.
   The following configures the GPU Operator to deploy the operands that are required for Kata Containers.
   Refer to Common Chart Customization Options for more details on the additional configuration options you can specify when installing the GPU Operator.

   ```console
   $ helm install --generate-name \
      -n gpu-operator --create-namespace \
      nvidia/gpu-operator \
      --version=<gpu-operator-version> \
      --set sandboxWorkloads.enabled=true \
      --set sandboxWorkloads.mode=kata \
      --set nfd.enabled=true \
      --set nfd.nodefeaturerules=true
   ```

   *Example Output:*

   ```output
   NAME: gpu-operator
   LAST DEPLOYED: Wed Mar 25 17:21:34 2026
   NAMESPACE: gpu-operator
   STATUS: deployed
   REVISION: 1
   DESCRIPTION: Install complete
   TEST SUITE: None
   ```

   > [!TIP]
   > Add `--set sandboxWorkloads.defaultWorkload=vm-passthrough` if every worker node should use Kata by default.

   1. Optional: Verify that all GPU Operator pods, especially the Sandbox Device Plugin and VFIO Manager operands, are running:

   ```console
   $ kubectl get pods -n gpu-operator
   ```

   *Example Output:*

   ```output
   NAME                                                              READY   STATUS    RESTARTS   AGE
   gpu-operator-1766001809-node-feature-discovery-gc-75776475sxzkp   1/1     Running   0          86s
   gpu-operator-1766001809-node-feature-discovery-master-6869lxq2g   1/1     Running   0          86s
   gpu-operator-1766001809-node-feature-discovery-worker-mh4cv       1/1     Running   0          86s
   gpu-operator-f48fd66b-vtfrl                                       1/1     Running   0          86s
   nvidia-cc-manager-7z74t                                           1/1     Running   0          61s
   nvidia-kata-sandbox-device-plugin-daemonset-d5rvg                 1/1     Running   0          30s
   nvidia-sandbox-validator-6xnzc                                    1/1     Running   0          30s
   nvidia-vfio-manager-h229x                                         1/1     Running   0          62s
   ```

   > [!NOTE]
   > It can take several minutes for all GPU Operator pods to be in the Running state.
   > If you are not seeing the expected output, you can view the logs for the GPU Operator pods:

   ```console
   $ kubectl logs -n gpu-operator <pod-name>
   ```

   Replace `<pod-name>` with the name of the GPU Operator pod from `kubectl get pods -n gpu-operator`.
   > [!NOTE]
   > The NVIDIA Confidential Computing (CC) Manager for Kubernetes (`nvidia-cc-manager`) is deployed to all nodes configured to run Kata containers, even if you are not planning to run Confidential Containers.
   > This manager sets the confidential computing mode on the NVIDIA GPUs, if your GPU is capable of Confidential Computing, but will not be used if you are deploying in Kata Containers only.
   > Refer to Confidential Containers for more details.

   1. Optional: If you have host access to the worker node, you can perform the following validation step:

   a. Confirm that the host uses the `vfio-pci` device driver for GPUs:

      ```console
      $ lspci -nnk -d 10de:
      ```

      *Example Output:*

      ```output
      65:00.0 3D controller [0302]: NVIDIA Corporation xxxxxxx [xxx] [10de:xxxx] (rev xx)
              Subsystem: NVIDIA Corporation xxxxxxx [xxx] [10de:xxxx]
              Kernel driver in use: vfio-pci
              Kernel modules: nvidiafb, nouveau
      ```

## Optional: Configuring GPU or NVSwitch Resource Types Name

By default, the NVIDIA GPU Operator creates a resource type for GPUs and NVSwitches, `nvidia.com/pgpu` and `nvidia.com/nvswitch`.
You can reference these names in your manifests to request GPU or NVSwitch resources for your workload.
If you want to use a different name, you can set the `P_GPU_ALIAS` or `NVSWITCH_ALIAS` environment variables in the Kata device plugin to your preferred name.
In clusters where all GPUs are the same model, a single resource type is typically sufficient.

In heterogeneous clusters, where you have different GPU types on your nodes, you might want to use specific GPU types for your workload.
To do this, specify an empty `P_GPU_ALIAS` environment variable in the Kata device plugin by adding the following to your GPU Operator installation:
`--set kataSandboxDevicePlugin.env[0].name=P_GPU_ALIAS` and
`--set kataSandboxDevicePlugin.env[0].value=""`.

When this variable is set to `""`, the Kata device plugin creates GPU model-specific resource types, for example `nvidia.com/GH100_H100L_94GB`, instead of the default `nvidia.com/pgpu` type.
Use the exposed device resource types in pod specs by specifying respective resource limits.

Similarly, you can set `NVSWITCH_ALIAS` to `""` to advertise model-specific NVSwitch resource types.

The following example installs the GPU Operator with both `P_GPU_ALIAS` and `NVSWITCH_ALIAS` configured:

```console
$ helm install --generate-name \
   -n gpu-operator --create-namespace \
   nvidia/gpu-operator \
   --version=<gpu-operator-version> \
   --set sandboxWorkloads.enabled=true \
   --set sandboxWorkloads.mode=kata \
   --set nfd.enabled=true \
   --set nfd.nodefeaturerules=true \
   --set kataSandboxDevicePlugin.env[0].name=P_GPU_ALIAS \
   --set kataSandboxDevicePlugin.env[0].value="" \
   --set kataSandboxDevicePlugin.env[1].name=NVSWITCH_ALIAS \
   --set kataSandboxDevicePlugin.env[1].value=""
```

After installing the GPU Operator, you can view the GPU or NVSwitch resource types available on a node by running the following command:

```console
$ kubectl get node <node-name> -o json | grep nvidia.com
```

*Example Output:*

```output
"nvidia.com/GH100_H100L_94GB": "1"
```
