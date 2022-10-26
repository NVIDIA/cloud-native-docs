.. Date: Sept 28 2022
.. Author: kquinn

.. _install-nvidiagpu:

###################################
Installing the NVIDIA GPU Operator
###################################

.. note:: If you are installing the **NVIDIA GPU Operator** on OpenShift <``4.9.9`` ensure you have :ref:`enabled a Cluster-wide entitlement <cluster-entitlement>`.
   For more information see :ref:`broken driver toolkit <broken-dtk>`.

With the :ref:`Node Feature Discovery Operator<install-nfd>` installed you can continue with the final step and install the **NVIDIA GPU Operator**.

As a cluster administrator, you can install the **NVIDIA GPU Operator** using the OpenShift Container Platform CLI or the web console.

***********************************************************
Installing the NVIDIA GPU Operator by using the web console
***********************************************************

#. In the OpenShift Container Platform web console from the side menu, navigate to  **Operators** > **OperatorHub** and select **All Projects**.

#. In **Operators** > **OperatorHub**, search for the **NVIDIA GPU Operator**. For additional information see the `Red Hat OpenShift Container Platform documentation <https://docs.openshift.com/container-platform/latest/operators/admin/olm-adding-operators-to-cluster.html>`_.

#. Select the **NVIDIA GPU Operator**, click **Install**. In the subsequent screen click **Install**.

  .. note:: Here, you can select the namespace where you want to deploy the GPU Operator. The suggested namespace to use is the ``nvidia-gpu-operator``. You can choose any existing namespace or create a new namespace under **Select a Namespace**.

            If you install in any other namespace other than ``nvidia-gpu-operator``, the GPU Operator will **not** automatically enable namespace monitoring, and metrics and alerts will **not** be collected by Prometheus.
            If only trusted operators are installed in this namespace, you can manually enable namespace monitoring with this command:

            .. code-block:: console

               $ oc label ns/$NAMESPACE_NAME openshift.io/cluster-monitoring=true

Proceed to :ref:`Create the cluster policy for the NVIDIA GPU Operator<create-cluster-policy>`.

*************************************************
Installing the NVIDIA GPU Operator using the CLI
*************************************************

As a cluster administrator, you can install the **NVIDIA GPU Operator** using the OpenShift CLI (``oc``).

#. Create a namespace for the **NVIDIA GPU Operator**.

   #. Create the following ``Namespace`` custom resource (CR) that defines the ``nvidia-gpu-operator`` namespace, and then save the YAML in the ``nvidia-gpu-operator.yaml`` file:

      .. code-block:: yaml

         apiVersion: v1
         kind: Namespace
         metadata:
           name: nvidia-gpu-operator

      .. note:: The suggested namespace to use is the ``nvidia-gpu-operator``. You can choose any existing namespace or create a new namespace name.
                If you install in any other namespace other than ``nvidia-gpu-operator``, the GPU Operator will **not** automatically enable namespace monitoring, and metrics and alerts will **not** be collected by Prometheus.

                If only trusted operators are installed in this namespace, you can manually enable namespace monitoring with this command:

                 .. code-block:: console

                    $ oc label ns/$NAMESPACE_NAME openshift.io/cluster-monitoring=true

   #. Create the namespace by running the following command:

      .. code-block:: console

         $ oc create -f nvidia-gpu-operator.yaml

      .. code-block:: console

         namespace/nvidia-gpu-operator created

#. Install the **NVIDIA GPU Operator** in the namespace you created in the previous step by creating the following objects:

   #. Create the following ``OperatorGroup`` CR and save the YAML in the ``nvidia-gpu-operatorgroup.yaml`` file:

      .. code-block:: yaml

         apiVersion: operators.coreos.com/v1
         kind: OperatorGroup
         metadata:
           name: nvidia-gpu-operator-group
           namespace: nvidia-gpu-operator
         spec:
          targetNamespaces:
          - nvidia-gpu-operator

   #. Create the ``OperatorGroup`` CR by running the following command:

      .. code-block:: console

         $ oc create -f nvidia-gpu-operatorgroup.yaml

      .. code-block:: console

         operatorgroup.operators.coreos.com/nvidia-gpu-operator-group created

#. Run the following command to get the ``channel`` value required for step number 5.

   .. code-block:: console

      $ oc get packagemanifest gpu-operator-certified -n openshift-marketplace -o jsonpath='{.status.defaultChannel}'

   **Example output**

   .. code-block:: console

      v22.9

#. Run the following commands to get the ``startingCSV`` value required for step number 5.

   .. code-block:: console

      $ CHANNEL=v22.9

   .. code-block:: console

      $ oc get packagemanifests/gpu-operator-certified -n openshift-marketplace -ojson | jq -r '.status.channels[] | select(.name == "'$CHANNEL'") | .currentCSV'

   **Example output**

   .. code-block:: console

      gpu-operator-certified.v22.9.0

#. Create the following ``Subscription`` CR and save the YAML in the ``nvidia-gpu-sub.yaml`` file:

   .. code-block:: yaml

      apiVersion: operators.coreos.com/v1alpha1
      kind: Subscription
      metadata:
        name: gpu-operator-certified
        namespace: nvidia-gpu-operator
      spec:
        channel: "v22.9"
        installPlanApproval: Manual
        name: gpu-operator-certified
        source: certified-operators
        sourceNamespace: openshift-marketplace
        startingCSV: "gpu-operator-certified.v22.9.0"

   .. note:: Update the ``channel`` and ``startingCSV`` fields with the information returned in step 3 and 4.

#. Create the subscription object by running the following command:

   .. code-block:: console

      $ oc create -f nvidia-gpu-sub.yaml

   .. code-block:: console

      subscription.operators.coreos.com/gpu-operator-certified created

#. Optional: Log in to web console and navigate to the **Operators** > **Installed Operators** page. In the ``Project: nvidia-gpu-operator`` the following is displayed:

   .. image:: graphics/gpu-operator-certified-cli-install.png

#. Verify an install plan has been created:

   .. code-block:: console

      $ oc get installplan -n nvidia-gpu-operator

   **Example output**

   .. code-block:: console

      NAME            CSV                              APPROVAL   APPROVED
      install-wwhfj   gpu-operator-certified.v22.9.0   Manual     false

#. Approve the install plan using the CLI commands:

   .. code-block:: console

      $ INSTALL_PLAN=$(oc get installplan -n nvidia-gpu-operator -oname)

   .. code-block:: console

      $ oc patch $INSTALL_PLAN -n nvidia-gpu-operator --type merge --patch '{"spec":{"approved":true }}'

   **Example output**

   .. code-block:: console

      installplan.operators.coreos.com/install-wwhfj patched

#. Alternatively click ``Upgrade available`` and approve the plan using the web console:

   .. image:: graphics/gpu-operator-certified-cli-install.png

#. Optional: Verify the successful install in the web console. The display changes to:

   .. image:: graphics/cluster_policy_suceed.png

.. _create-cluster-policy:

When you install the **NVIDIA GPU Operator** in the OpenShift Container Platform, a custom resource definition for a ClusterPolicy is created. The ClusterPolicy configures the GPU stack, configuring the image names and repository, pod restrictions/credentials and so on.

.. note:: If you create a ClusterPolicy that contains an empty specification, such as ``spec{}``, the ClusterPolicy fails to deploy.

As a cluster administrator, you can create a ClusterPolicy using the OpenShift Container Platform CLI or the web console. Also, these steps differ
when using **NVIDIA vGPU**. Please refer to appropriate sections below.

*****************************************************
Create the ClusterPolicy instance
*****************************************************

Create the cluster policy using the web console
-----------------------------------------------

#. In the OpenShift Container Platform web console, from the side menu, select **Operators** > **Installed Operators**, and click **NVIDIA GPU Operator**.

#. Select the **ClusterPolicy** tab, then click **Create ClusterPolicy**. The platform assigns the default name *gpu-cluster-policy*.

      .. note:: You can use this screen to customize the ClusterPolicy however the default are sufficient to get the GPU configured and running.

#. Click **Create**.

   At this point, the GPU Operator proceeds and installs all the required components to set up the NVIDIA GPUs in the OpenShift 4 cluster. Wait at least 10-20 minutes before digging deeper into any form of troubleshooting because this may take a period of time to finish.

#. The status of the newly deployed ClusterPolicy *gpu-cluster-policy* for the NVIDIA GPU Operator changes to ``State:ready`` when the installation succeeds.

 .. image:: graphics/cluster-policy-state-ready.png

.. _verify-gpu-operator-install-ocp:

Create the cluster policy using the CLI
---------------------------------------

#. Create the ClusterPolicy:

   .. code-block:: console

      $ oc get csv -n nvidia-gpu-operator gpu-operator-certified.v22.9.0 -ojsonpath={.metadata.annotations.alm-examples} | jq .[0] > clusterpolicy.json

   .. code-block:: console

      $ oc apply -f clusterpolicy.json

   .. code-block:: console

      clusterpolicy.nvidia.com/gpu-cluster-policy created

***************************************************************************
Create the ClusterPolicy instance with NVIDIA vGPU
***************************************************************************

Pre-requisites
--------------

* Please refer to :ref:`install-gpu-operator-vgpu` section for pre-requisite steps for using NVIDIA vGPU on RedHat OpenShift.

Create the cluster policy using the web console
-----------------------------------------------

#. In the OpenShift Container Platform web console, from the side menu, select **Operators** > **Installed Operators**, and click **NVIDIA GPU Operator**.

#. Select the **ClusterPolicy** tab, then click **Create ClusterPolicy**. The platform assigns the default name *gpu-cluster-policy*.

#. Provide name of the licensing ``ConfigMap`` under **Driver** section, this should be created during pre-requsite steps above for NVIDIA vGPU. Refer to below screenshots for example and modify values accordingly.

 .. image:: graphics/cluster_policy_vgpu_1.png

#. Specify ``repository`` path, ``image`` name and NVIDIA vGPU driver ``version`` bundled under **Driver** section. If the registry is not public, please specify the ``imagePullSecret`` created during pre-requisite step under **Driver** advanced configurations section.

 .. image:: graphics/cluster_policy_vgpu_2.png

#. Click **Create**.

   At this point, the GPU Operator proceeds and installs all the required components to set up the NVIDIA GPUs in the OpenShift 4 cluster. Wait at least 10-20 minutes before digging deeper into any form of troubleshooting because this may take a period of time to finish.

#. The status of the newly deployed ClusterPolicy *gpu-cluster-policy* for the NVIDIA GPU Operator changes to ``State:ready`` when the installation succeeds.

 .. image:: graphics/cluster-policy-state-ready.png

.. _verify-gpu-operator-install-ocp:

Create the cluster policy using the CLI
---------------------------------------

#. Create the ClusterPolicy:

   .. code-block:: console

      $ oc get csv -n nvidia-gpu-operator gpu-operator-certified.v22.9.0 -ojsonpath={.metadata.annotations.alm-examples} | jq .[0] > clusterpolicy.json

   Modify clusterpolicy.json file to specify ``driver.licensingConfig``, ``driver.repository``, ``driver.image``, ``driver.version`` and ``driver.imagePullSecrets`` created during pre-requiste steps. Below snippet is shown as an example, please change values accordingly.

   .. code-block:: json

         "driver": {
              "repository": "<repository-path>"
              "image": "driver",
              "imagePullSecrets": [],
              "licensingConfig": {
                "configMapName": "licensing-config",
                "nlsEnabled": true
              }
              "version": "470.82.01"
         }

   .. code-block:: console

      $ oc apply -f clusterpolicy.json

   .. code-block:: console

      clusterpolicy.nvidia.com/gpu-cluster-policy created

*************************************************************
Verify the successful installation of the NVIDIA GPU Operator
*************************************************************

Verify the successful installation of the NVIDIA GPU Operator as shown here:

#. Run the following command to view these new pods and daemonsets:

   .. code-block:: console

      $ oc get pods,daemonset -n nvidia-gpu-operator

   .. code-block:: console

      NAME                                                      READY   STATUS      RESTARTS   AGE
      pod/gpu-feature-discovery-c2rfm                           1/1     Running     0          6m28s
      pod/gpu-operator-84b7f5bcb9-vqds7                         1/1     Running     0          39m
      pod/nvidia-container-toolkit-daemonset-pgcrf              1/1     Running     0          6m28s
      pod/nvidia-cuda-validator-p8gv2                           0/1     Completed   0          99s
      pod/nvidia-dcgm-exporter-kv6k8                            1/1     Running     0          6m28s
      pod/nvidia-dcgm-tpsps                                     1/1     Running     0          6m28s
      pod/nvidia-device-plugin-daemonset-gbn55                  1/1     Running     0          6m28s
      pod/nvidia-device-plugin-validator-z7ltr                  0/1     Completed   0          82s
      pod/nvidia-driver-daemonset-410.84.202203290245-0-xxgdv   2/2     Running     0          6m28s
      pod/nvidia-node-status-exporter-snmsm                     1/1     Running     0          6m28s
      pod/nvidia-operator-validator-6pfk6                       1/1     Running     0          6m28s

      NAME                                                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                                                                                                         AGE
      daemonset.apps/gpu-feature-discovery                           1         1         1       1            1           nvidia.com/gpu.deploy.gpu-feature-discovery=true                                                                      6m28s
      daemonset.apps/nvidia-container-toolkit-daemonset              1         1         1       1            1           nvidia.com/gpu.deploy.container-toolkit=true                                                                          6m28s
      daemonset.apps/nvidia-dcgm                                     1         1         1       1            1           nvidia.com/gpu.deploy.dcgm=true                                                                                       6m28s
      daemonset.apps/nvidia-dcgm-exporter                            1         1         1       1            1           nvidia.com/gpu.deploy.dcgm-exporter=true                                                                              6m28s
      daemonset.apps/nvidia-device-plugin-daemonset                  1         1         1       1            1           nvidia.com/gpu.deploy.device-plugin=true                                                                              6m28s
      daemonset.apps/nvidia-driver-daemonset-410.84.202203290245-0   1         1         1       1            1           feature.node.kubernetes.io/system-os_release.OSTREE_VERSION=410.84.202203290245-0,nvidia.com/gpu.deploy.driver=true   6m28s
      daemonset.apps/nvidia-mig-manager                              0         0         0       0            0           nvidia.com/gpu.deploy.mig-manager=true                                                                                6m28s
      daemonset.apps/nvidia-node-status-exporter                     1         1         1       1            1           nvidia.com/gpu.deploy.node-status-exporter=true                                                                       6m29s
      daemonset.apps/nvidia-operator-validator                       1         1         1       1            1           nvidia.com/gpu.deploy.operator-validator=true                                                                         6m28s

   The ``nvidia-driver-daemonset`` pod runs on each worker node that contains a supported NVIDIA GPU.

   .. note:: When the Driver Toolkit is active, the ``DaemonSet`` is named ``nvidia-driver-daemonset-<RHCOS-version>``. Where ``RHCOS-version`` equals ``<OCP XY>.<RHEL XY>.<related date YYYYMMDDHHSS-0``.
             The pods of the ``DaemonSet`` are named ``nvidia-driver-daemonset-<RHCOS-version>-<UUID>``.

*************************************************************
Cluster monitoring
*************************************************************

The GPU Operator generates GPU performance metrics (DCGM-export), status metrics (node-status-exporter) and node-status alerts. For OpenShift Prometheus to collect these metrics, the namespace hosting the GPU Operator must have the label ``openshift.io/cluster-monitoring=true``.

When the GPU Operator is installed in the suggested ``nvidia-gpu-operator`` namespace, the GPU Operator automatically enables monitoring if the ``openshift.io/cluster-monitoring`` label is not defined.
If the label is defined, the GPU Operator will not change its value.

Disable cluster monitoring in the ``nvidia-gpu-operator`` namespace by setting ``openshift.io/cluster-monitoring=false`` as shown:

   .. code-block:: console

       $ oc label ns/nvidia-gpu-operator openshift.io/cluster-monitoring=true

If the GPU Operator is not installed in the suggested namespace, the GPU Operator will not automatically enable monitoring. Set the label manually as shown:

   .. code-block:: console

      $ oc label ns/$NAMESPACE openshift.io/cluster-monitoring=true

   .. note:: Only do this if trusted operators are installed in this namespace.

*************************************************************
Logging
*************************************************************

The ``nvidia-driver-daemonset`` pod has two containers.

#. Run the following to examine the logs associated with the ``nvidia-driver-ctr``:

   .. note:: This log shows the main container waiting for the driver binary, and loading it in memory.

   .. code-block:: console

      $ oc logs -f nvidia-driver-daemonset-410.84.202203290245-0-xxgdv -n nvidia-gpu-operator -c nvidia-driver-ctr

#. Run the following to examine the logs associated with the ``openshift-driver-toolkit-ctr``:

   .. note:: This log shows the driver being built.

   .. code-block:: console

      $ oc logs -f nvidia-driver-daemonset-410.84.202203290245-0-xxgdv -n nvidia-gpu-operator -c openshift-driver-toolkit-ctr

.. _running-sample-app:

*************************************************************
Running a sample GPU Application
*************************************************************

Run a simple CUDA VectorAdd sample, which adds two vectors together to ensure the GPUs have bootstrapped correctly.

#. Run the following:

   .. code-block:: console

      $ cat << EOF | oc create -f -

      apiVersion: v1
      kind: Pod
      metadata:
        name: cuda-vectoradd
      spec:
       restartPolicy: OnFailure
       containers:
       - name: cuda-vectoradd
         image: "nvidia/samples:vectoradd-cuda11.2.1"
         resources:
           limits:
             nvidia.com/gpu: 1
      EOF

   .. code-block:: console

      pod/cuda-vectoradd created

#. Check the logs of the container:

   .. code-block:: console

      $ oc logs cuda-vectoradd

   .. code-block:: console

      [Vector addition of 50000 elements]
      Copy input data from the host memory to the CUDA device
      CUDA kernel launch with 196 blocks of 256 threads
      Copy output data from the CUDA device to the host memory
      Test PASSED
      Done

*************************************************************
Getting information about the GPU
*************************************************************

The ``nvidia-smi`` shows memory usage, GPU utilization, and the temperature of the GPU. Test the GPU access by running the popular ``nvidia-smi`` command within the pod.

To view GPU utilization, run ``nvidia-smi`` from a pod in the GPU Operator daemonset.

#. Change to the nvidia-gpu-operator project:

   .. code-block:: console

      $ oc project nvidia-gpu-operator

#. Run the following command to view these new pods:

   .. code-block:: console

      $ oc get pod -owide -lopenshift.driver-toolkit=true

   .. code-block:: console

      NAME                                                  READY   STATUS    RESTARTS   AGE   IP            NODE                           NOMINATED NODE   READINESS GATES
      nvidia-driver-daemonset-410.84.202203290245-0-xxgdv   2/2     Running   0          23m   10.130.2.18   ip-10-0-143-147.ec2.internal   <none>           <none>


   .. note:: With the Pod and node name, run the ``nvidia-smi`` on the correct node.

#. Run the ``nvidia-smi`` command within the pod:

   .. code-block:: console

      $ oc exec -it nvidia-driver-daemonset-410.84.202203290245-0-xxgdv -- nvidia-smi

   .. code-block:: console

      Defaulted container "nvidia-driver-ctr" out of: nvidia-driver-ctr, openshift-driver-toolkit-ctr, k8s-driver-manager (init)
      Mon Apr 11 15:02:23 2022
      +-----------------------------------------------------------------------------+
      | NVIDIA-SMI 510.47.03    Driver Version: 510.47.03    CUDA Version: 11.6     |
      |-------------------------------+----------------------+----------------------+
      | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
      | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
      |                               |                      |               MIG M. |
      |===============================+======================+======================|
      |   0  Tesla T4            On   | 00000000:00:1E.0 Off |                    0 |
      | N/A   33C    P8    15W /  70W |      0MiB / 15360MiB |      0%      Default |
      |                               |                      |                  N/A |
      +-------------------------------+----------------------+----------------------+

      +-----------------------------------------------------------------------------+
      | Processes:                                                                  |
      |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
      |        ID   ID                                                   Usage      |
      |=============================================================================|
      |  No running processes found                                                 |
      +-----------------------------------------------------------------------------+

   Two tables are generated. The first table reflects the information about all available GPUs (the example shows one GPU). The second table provides details on the processes using the GPUs.

   For more information describing the contents of the tables see the man page for ``nvidia-smi``.
