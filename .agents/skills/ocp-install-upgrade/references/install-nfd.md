# Installing the Node Feature Discovery Operator on OpenShift

<a id="install-nfd"></a>

# Installing the Node Feature Discovery Operator on OpenShift

## Procedure

The Node Feature Discovery (NFD) Operator is a prerequisite for the **NVIDIA GPU Operator**. Install the NFD Operator using the Red Hat Software Catalog (Red Hat OperatorHub in versions before 4.20) in the OpenShift Container Platform web console.

1. Follow the Red Hat documentation guidance in the [Node Feature Discovery Operator guide](https://docs.openshift.com/container-platform/latest/hardware_enablement/psap-node-feature-discovery-operator.html) to install the Node Feature Discovery Operator.

2. Verify the Node Feature Discovery Operator is running:

   ```console
   $ oc get pods -n openshift-nfd
   ```

   ```console
   NAME                                      READY   STATUS    RESTARTS   AGE
   nfd-controller-manager-7f86ccfb58-nqgxm   2/2     Running   0          11m
   ```

3. When the Node Feature Discovery is installed, create an instance of Node Feature Discovery using the **NodeFeatureDiscovery** tab:

   1. Click **Ecosystem** > **Installed Operators** from the side menu.
      : In versions before 4.20, click **Operators** > **Installed Operators**.
   2. Find the **Node Feature Discovery** entry.
   3. Click **NodeFeatureDiscovery** under the **Provided APIs** field.
   4. Click **Create NodeFeatureDiscovery**.
   5. In the following screen, click **Create**. This starts the Node Feature Discovery Operator that proceeds to label the nodes in the cluster that have GPUs.

   :::{note}
   The values prepopulated by the Software Catalog (Red Hat OperatorHub in versions before 4.20) are valid for the GPU Operator.
   :::

## Verify that the Node Feature Discovery Operator is functioning correctly

The Node Feature Discovery Operator uses vendor PCI IDs to identify hardware in a node. NVIDIA uses the PCI ID `10de`. Use the OpenShift Container Platform web console or the CLI to verify that the Node Feature Discovery Operator is functioning correctly.

1. In the OpenShift Container Platform web console, click **Compute** > **Nodes** from the side menu.

2. Select a worker node that contains a GPU.

3. Click the **Details** tab.

4. Under **Node Labels**, verify that the following label is present:

   ```console
   feature.node.kubernetes.io/pci-10de.present=true
   ```

   :::{note}
   `0x10de` is the PCI vendor ID assigned to NVIDIA.
   :::

5. Verify that the GPU device (`pci-10de`) is discovered on the GPU node:

   ```console
   $ oc describe node | egrep 'Roles|pci' | grep -v master
   ```

   ```console
   Roles:              worker
                       feature.node.kubernetes.io/pci-10de.present=true
                       feature.node.kubernetes.io/pci-1d0f.present=true
   Roles:              worker
                       feature.node.kubernetes.io/pci-1013.present=true
                       feature.node.kubernetes.io/pci-8086.present=true
   Roles:              worker
                       feature.node.kubernetes.io/pci-1013.present=true
                       feature.node.kubernetes.io/pci-8086.present=true
   Roles:              worker
                       feature.node.kubernetes.io/pci-1013.present=true
                       feature.node.kubernetes.io/pci-8086.present=true
   ```
