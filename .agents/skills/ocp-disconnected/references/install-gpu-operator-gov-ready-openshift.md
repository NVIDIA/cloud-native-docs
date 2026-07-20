# NVIDIA GPU Operator Government Ready on OpenShift

<a id="install-gpu-operator-gov-ready-openshift"></a>

# NVIDIA GPU Operator Government Ready on Openshift

The NVIDIA GPU Operator now offers government-ready components for NVIDIA AI Enterprise customers.
Government ready is NVIDIA's designation for software that meets applicable security requirements for deployment in your FedRAMP High or equivalent sovereign use case.
For more information on NVIDIA's government-ready support, refer to the white paper [AI Software for Regulated Environments](https://docs.nvidia.com/ai-enterprise/planning-resource/ai-software-regulated-environments-white-paper/latest/index.html).

Refer to the [support components matrix](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/install-gpu-operator-gov-ready.html#supported-gpu-operator-components) for a full list of available GPU Operator government-ready components.

This page outlines how to install the NVIDIA GPU Operator government-ready components on Red Hat OpenShift Container Platform.

## Prerequisites

- An active NVIDIA AI Enterprise subscription and NGC API token to access GPU Operator government-ready containers.
  Refer to [Generating Your NGC API Key](https://docs.nvidia.com/ngc/gpu-cloud/ngc-user-guide/index.html#generating-api-key) in the NVIDIA NGC User Guide for more information on NGC API tokens.
- Red Hat OpenShift 4.19 in FIPS mode.
- [Node Feature Discovery Operator installed](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/install-nfd.html).
- Optionally, Service Mesh for intra-cluster traffic encryption.
  By default, the NVIDIA GPU Operator does not encrypt traffic between its controller (and operands) and the Kubernetes API server.
  If you wish to encrypt this communication, you should deploy and maintain a service mesh application within the Kubernetes cluster to enable secure traffic.

## Install GPU Operator Government Ready Components

1. In the OpenShift Container Platform web console, from the side menu, navigate to **Operators** > **OperatorHub** and select **All Projects**.

2. In **Operators** > **OperatorHub**, search for the **NVIDIA GPU Operator**. For additional information, refer to the [Red Hat OpenShift Container Platform documentation](https://docs.openshift.com/container-platform/latest/operators/admin/olm-adding-operators-to-cluster.html).

3. Select the **NVIDIA GPU Operator**, click **Install**. In the following screen, click **Install**.

   :::{note}
   Here, you can select the namespace where you want to deploy the GPU Operator. The suggested namespace to use is the `nvidia-gpu-operator`. You can choose any existing namespace or create a new namespace under **Select a Namespace**.
   :::

## Create NVIDIA NGC Image Pull Secret

OpenShift has a secret object type which provides a mechanism for holding sensitive information such as passwords and private source repository credentials.
Create a secret object for storing your NGC API key.

1. Navigate to **Home** > **Projects** and ensure that `nvidia-gpu-operator` is selected.

2. In the OpenShift Container Platform web console, click **Secrets** from the Workloads drop down.

3. Click the **Create** Drop down.

4. Select Image Pull Secret.

   ```{image} graphics/secrets.png
   ```

5. Enter the following into each field:

   - **Secret name:** `ngc-api-secret`
   - **Authentication type:** Image registry credentials
   - **Registry server address:** `nvcr.io`
   - **Username:** `$oauthtoken`
   - **Password:** `<NGC-API-KEY>`

6. Click **Create**.

   A pull secret is created.

## Create the ClusterPolicy Instance

When you install the **NVIDIA GPU Operator** in the OpenShift Container Platform, a custom resource definition for a ClusterPolicy is created. The ClusterPolicy configures the GPU Operator, configuring the image names and repository, pod restrictions and credentials, and more. Use the ClusterPolicy to set the NGC image pull secret and government ready repository.

1. In the OpenShift Container Platform web console, from the side menu, select **Ecosystem** > **Installed Operators** (for versions before 4.20, look for **Operators** > **Installed Operators**), and click **NVIDIA GPU Operator**.

2. Select the **ClusterPolicy** tab, then click **Create ClusterPolicy**. The platform assigns the default name *gpu-cluster-policy*.

3. Expand the **NVIDIA GPU/vGPU Driver config** section and set the following fields:

   - **version:** `580.95.05-stig-fips`
   - **image:** `gpu-driver-stig-fips`
   - **repository:** `nvcr.io/nvidia`

   Expand **Image Pull Secret** in the **Advanced configuration** section and add your NGC image pull secret name.

   - **value:** `ngc-api-secret`

4. Click **Create**.

   At this point, the GPU Operator proceeds and installs all the required components to set up the NVIDIA GPUs in the OpenShift cluster. Wait at least 10 to 20 minutes before troubleshooting because this process can take some time to finish.

5. The status of the newly deployed ClusterPolicy *gpu-cluster-policy* for the NVIDIA GPU Operator changes to `State:ready` when the installation succeeds.

   ```{image} graphics/cluster-policy-state-ready.png
   ```
