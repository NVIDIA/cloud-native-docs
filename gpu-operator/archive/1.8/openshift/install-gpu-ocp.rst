.. Date: August 26 2021
.. Author: kquinn

.. _install-nvidiagpu-1.8:

###################################
Installing the NVIDIA GPU Operator
###################################

With the proper :ref:`Red Hat entitlement<cluster-entitlement-1.8>` in place and the :ref:`Node Feature Discovery Operator<install-nfd-1.8>` installed you can continue with the final step and install the **NVIDIA GPU Operator**.

#. In the OpenShift Container Platform web console from the side menu, select **Operators** > **OperatorHub**, then search for the **NVIDIA GPU Operator**. For additional information see the `Red Hat OpenShift Container Platform documentation <https://docs.openshift.com/container-platform/latest/operators/admin/olm-adding-operators-to-cluster.html>`_.

#. Select the **NVIDIA GPU Operator**, click **Install**. In the subsequent screen click **Install**.

.. _create-cluster-policy-1.8:

*****************************************************
Create the cluster policy for the NVIDIA GPU Operator
*****************************************************

When you install the **NVIDIA GPU Operator** in the OpenShift Container Platform, a custom resource definition for a ClusterPolicy is created. The ClusterPolicy configures the GPU stack that will be deployed, configuring the image names and repository, pod restrictions/credentials and so on.

.. note:: If you create a ClusterPolicy that contains an empty specification, such as ``spec{}``, the ClusterPolicy fails to deploy.

#. In the OpenShift Container Platform web console, from the side menu, select **Operators** > **Installed Operators**, then click **NVIDIA GPU Operator**.

#. Select the **ClusterPolicy** tab, then click **Create ClusterPolicy**. The platform assigns the default name *gpu-cluster-policy*.

      .. note:: You can use this screen to customize the ClusterPolicy however the default are sufficient to get the GPU configured and running.

#. Click **Create**.

   At this point, the GPU Operator proceeds and installs all the required components to set up the NVIDIA GPUs in the OpenShift 4 cluster. This may take a while so be patient and wait at least 10-20 minutes before digging deeper into any form of troubleshooting.

#. The status of the newly deployed ClusterPolicy *gpu-cluster-policy* for the NVIDIA GPU Operator changes to ``State:ready`` once the installation succeeded.

 .. image:: graphics/cluster_policy_suceed.png

.. _verify-gpu-operator-install-ocp-1.8:

*************************************************************
Verify the successful installation of the NVIDIA GPU Operator
*************************************************************

The commands below describe various ways to verify the successful installation of the NVIDIA GPU Operator.

#. Run the following command to view these new pods and daemonsets:

   .. code-block:: console

      $ oc get pods,daemonset -n gpu-operator-resources

   .. code-block:: console

      NAME                                           READY   STATUS      RESTARTS   AGE
      pod/gpu-feature-discovery-vwhnt                1/1     Running     0          6m32s
      pod/nvidia-container-toolkit-daemonset-k8x28   1/1     Running     0          6m33s
      pod/nvidia-cuda-validator-xr5sz                0/1     Completed   0          90s
      pod/nvidia-dcgm-5grvn                          1/1     Running     0          6m32s
      pod/nvidia-dcgm-exporter-cp8ml                 1/1     Running     0          6m32s
      pod/nvidia-device-plugin-daemonset-p9dp4       1/1     Running     0          6m32s
      pod/nvidia-device-plugin-validator-mrhst       0/1     Completed   0          48s
      pod/nvidia-driver-daemonset-pbplc              1/1     Running     0          6m33s
      pod/nvidia-node-status-exporter-s2ml2          1/1     Running     0          6m33s
      pod/nvidia-operator-validator-44jdf            1/1     Running     0          6m32s

      NAME                                                DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                                      AGE
      daemonset.apps/gpu-feature-discovery                1         1         1       1            1           nvidia.com/gpu.deploy.gpu-feature-discovery=true   6m32s
      daemonset.apps/nvidia-container-toolkit-daemonset   1         1         1       1            1           nvidia.com/gpu.deploy.container-toolkit=true       6m33s
      daemonset.apps/nvidia-dcgm                          1         1         1       1            1           nvidia.com/gpu.deploy.dcgm=true                    6m33s
      daemonset.apps/nvidia-dcgm-exporter                 1         1         1       1            1           nvidia.com/gpu.deploy.dcgm-exporter=true           6m33s
      daemonset.apps/nvidia-device-plugin-daemonset       1         1         1       1            1           nvidia.com/gpu.deploy.device-plugin=true           6m33s
      daemonset.apps/nvidia-driver-daemonset              1         1         1       1            1           nvidia.com/gpu.deploy.driver=true                  6m33s
      daemonset.apps/nvidia-mig-manager                   0         0         0       0            0           nvidia.com/gpu.deploy.mig-manager=true             6m32s
      daemonset.apps/nvidia-node-status-exporter          1         1         1       1            1           nvidia.com/gpu.deploy.node-status-exporter=true    6m34s
      daemonset.apps/nvidia-operator-validator            1         1         1       1            1           nvidia.com/gpu.deploy.operator-validator=true      6m33s

   The ``nvidia-driver-daemonset`` pod runs on each worker node that contains a supported NVIDIA GPU.

.. _running-sample-app-1.8:

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
Getting information on the GPU
*************************************************************

The ``nvidia-smi`` shows memory usage, GPU utilization and the temperature of GPU. Test the GPU access by running the popular ``nvidia-smi`` command within the pod.

To view GPU utilization, run ``nvidia-smi`` from a pod in the GPU Operator daemonset.

#. Change to the gpu-operator-resources project:

   .. code-block:: console

      $ oc project gpu-operator-resources

#. Run the following command to view these new pods:

   .. code-block:: console

      $ oc get pod -owide -lapp=nvidia-driver-daemonset

   .. code-block:: console

      NAME                            READY   STATUS    RESTARTS   AGE     IP            NODE                          NOMINATED NODE   READINESS GATES
      nvidia-driver-daemonset-pbplc   1/1     Running   0          8m17s   10.130.2.28   ip-10-0-143-64.ec2.internal   <none>           <none>

   .. note:: The node is shown above, so with the Pod name, you can choose to execute the ``nvidia-smi`` on the correct node.

#. Run the ``nvidia-smi`` command within the pod:

   .. code-block:: console

      $ oc exec -it nvidia-driver-daemonset-pbplc -- nvidia-smi

   .. code-block:: console

      +-----------------------------------------------------------------------------+
      | NVIDIA-SMI 470.57.02    Driver Version: 470.57.02    CUDA Version: 11.4     |
      |-------------------------------+----------------------+----------------------+
      | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
      | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
      |                               |                      |               MIG M. |
      |===============================+======================+======================|
      |   0  Tesla T4            On   | 00000000:00:1E.0 Off |                    0 |
      | N/A   40C    P8    16W /  70W |      0MiB / 15109MiB |      0%      Default |
      |                               |                      |                  N/A |
      +-------------------------------+----------------------+----------------------+
      | Processes:                                                                  |
      |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
      |        ID   ID                                                   Usage      |
      |=============================================================================|
      |  No running processes found                                                 |
      +-----------------------------------------------------------------------------+

Two tables are generated the first reflects the information about all available GPUs (the example shows one GPU). The second table tells you about the processes using the GPUs.

For more information on the contents of the tables please refer to the man page for ``nvidia-smi``.
