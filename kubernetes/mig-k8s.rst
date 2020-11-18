.. Date: November 13 2020
.. Author: kklues, pramarao

.. _mig-k8s:

##########################
MIG Support in Kubernetes
##########################

The new Multi-Instance GPU (MIG) feature allows the NVIDIA A100 GPU to be securely partitioned into up to 
seven separate GPU Instances for CUDA applications, providing multiple users with separate GPU resources for 
optimal GPU utilization. This feature is particularly beneficial for workloads that do not fully saturate the GPU’s 
compute capacity and therefore users may want to run different workloads in parallel to maximize utilization.

This document provides an overview of the necessary software to enable MIG support for Kubernetes. 
Refer to the `MIG User Guide <https://docs.nvidia.com/datacenter/tesla/mig-user-guide/index.html>`_ for more details on the technical concepts, 
setting up MIG and the NVIDIA Container Toolkit for running containers with MIG.

The deployment workflow requires these pre-requisites:

#. You have installed the NVIDIA R450+ datacenter (450.80.02+) drivers required for NVIDIA A100. 
#. You have installed the NVIDIA Container Toolkit v2.5.0+ 
#. You already have a Kubernetes deployment up and running with access to at least one NVIDIA A100 GPU. 

Once these prerequisites have been met, you can proceed to deploy a MIG capable version of the NVIDIA ``k8s-device-plugin`` and (optionally) 
the ``gpu-feature-discovery`` component in your cluster, so that Kubernetes can schedule pods on the available MIG devices.

The minimum versions of the software components required are enumerated below:

#. NVIDIA R450+ datacenter driver: 450.80.02+
#. NVIDIA Container Toolkit (``nvidia-docker2``): v2.5.0+
#. NVIDIA `k8s-device-plugin <https://github.com/NVIDIA/k8s-device-plugin/tree/v0.7.0>`_: v0.7.0+
#. NVIDIA `gpu-feature-discovery <https://github.com/NVIDIA/gpu-feature-discovery/tree/v0.2.0>`_: v0.2.0+


****************
MIG Strategies
****************

NVIDIA provides two strategies for exposing MIG devices on a Kubernetes node. 
For more details on the strategies, refer to the 
`design document <https://docs.google.com/document/d/1mdgMQ8g7WmaI_XVVRrCvHPFPOMCm5LQD5JefgAh6N8g/edit>`_. 

***********************************
Using MIG Strategies in Kubernetes
***********************************

This section walks through the steps necessary to deploy and run the ``k8s-device-plugin`` 
and ``gpu-feature-discovery`` components for the various MIG strategies. The preferred 
approach for deployment is through Helm. 

For alternate deployment methods, refer to the instructions 
`here <https://github.com/NVIDIA/k8s-device-plugin/tree/v0.7.0/#deployment-via-helm>`_ and 
`here <https://github.com/NVIDIA/gpu-feature-discovery/tree/v0.2.0#deploying-via-helm-install-with-a-direct-url-to-the-helm-package>`_.

First, add the ``nvidia-device-plugin`` and ``gpu-feature-discovery`` helm repositories:

.. code-block:: console

   $ helm repo add nvdp https://nvidia.github.io/k8s-device-plugin

.. code-block:: console

   $ helm repo add nvgfd https://nvidia.github.io/gpu-feature-discovery

.. code-block:: console

   $ helm repo update

Then, verify that the **v0.7.0** version of the *nvidia-device-plugin* and the **v0.2.0** version 
of *gpu-feature-discovery* is available:

.. code-block:: console

   $ helm search repo nvdp --devel

.. code-block:: console

   NAME                     	  CHART VERSION  APP VERSION	DESCRIPTION
   nvdp/nvidia-device-plugin	  0.7.0          0.7.0 	       A Helm chart for ...

.. code-block:: console

   $ helm search repo nvgfd --devel

.. code-block:: console

   NAME                     	  CHART VERSION  APP VERSION	DESCRIPTION
   nvgfd/gpu-feature-discovery  0.2.0          0.2.0 	       A Helm chart for ...

Finally, select a MIG strategy and deploy the *nvidia-device-plugin* and *gpu-feature-discovery* components:

.. code-block:: console

   $ export MIG_STRATEGY=<none | single | mixed>

.. code-block:: console

   $ helm install \
      --version=0.7.0 \
      --generate-name \
      --set migStrategy=${MIG_STRATEGY} \
      nvdp/nvidia-device-plugin

.. code-block:: console

   $ helm install \
      --version=0.2.0 \
      --generate-name \
      --set migStrategy=${MIG_STRATEGY} \
      nvgfd/gpu-feature-discovery

***********************************
Testing with Different Strategies 
***********************************

This section walks through the steps necessary to test each of the MIG strategies.

.. note::

   With a default setup, only **one** device type can be requested by a container at a time for 
   the `mixed` strategy. If more than one device type is requested by the container, then the 
   device received is undefined. For example, a container cannot request both ``nvidia.com/gpu`` 
   and ``nvidia.com/mig-3g.20gb`` at the same time. However, it can request multiple instances 
   of the same resource type (e.g. ``nvidia.com/gpu: 2`` or ``nvidia.com/mig-3g.20gb: 2``) without restriction.

   To mitigate this behavior, we recommend following the guidance outlined in the `document <https://docs.google.com/document/d/1zy0key-EL6JH50MZgwg96RPYxxXXnVUdxLZwGiyqLd8>`_.

The ``none`` strategy
======================

The ``none`` strategy is designed to keep the *nvidia-device-plugin* running the same as it always 
has. The plugin will make no distinction between GPUs that have either MIG enabled or not, and 
will enumerate all GPUs on the node, making them available using the ``nvidia.com/gpu`` resource type.

Testing
---------

To test this strategy we check the enumeration of a GPU with and without MIG enabled and make 
sure we can see it in both cases. The test assumes a single GPU on a single node in the cluster.

#. Verify that MIG is disabled on the GPU:

   .. code-block:: console

      $ nvidia-smi 

   .. code-block:: console

      +-----------------------------------------------------------------------------+
      | NVIDIA-SMI 450.80.02    Driver Version: 450.80.02    CUDA Version: 11.0     |
      |-------------------------------+----------------------+----------------------+
      | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
      | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
      |                               |                      |               MIG M. |
      |===============================+======================+======================|
      |   0  A100-SXM4-40GB      Off  | 00000000:36:00.0 Off |                    0 |
      | N/A   29C    P0    62W / 400W |      0MiB / 40537MiB |      6%      Default |
      |                               |                      |             Disabled |
      +-------------------------------+----------------------+----------------------+

#. Start the *nvidia-device-plugin* with the ``none`` strategy as described in the previous section. 
   Restart the plugin if its already running.

#. Observe that 1 GPU is available on the node with resource type ``nvidia.com/gpu``:

   .. code-block:: console

      $ kubectl describe node
      ...
      Capacity:
      nvidia.com/gpu:          1
      ...
      Allocatable:
      nvidia.com/gpu:          1
      ...

#. Start *gpu-feature-discovery* with the ``none`` strategy as described in the previous section 
   Restart the plugin if its already running.

#. Observe that the proper set of labels have been applied for this MIG strategy:

   .. code-block:: console

      $ kubectl get node -o json | \
         jq '.items[0].metadata.labels | with_entries(select(.key | startswith("nvidia.com")))'

   .. code-block:: console
         
      {
      "nvidia.com/cuda.driver.major": "450",
      "nvidia.com/cuda.driver.minor": "80",
      "nvidia.com/cuda.driver.rev": "02",
      "nvidia.com/cuda.runtime.major": "11",
      "nvidia.com/cuda.runtime.minor": "0",
      "nvidia.com/gfd.timestamp": "1605312111",
      "nvidia.com/gpu.compute.major": "8",
      "nvidia.com/gpu.compute.minor": "0",
      "nvidia.com/gpu.count": "1",
      "nvidia.com/gpu.family": "ampere",
      "nvidia.com/gpu.machine": "NVIDIA DGX",
      "nvidia.com/gpu.memory": "40537",
      "nvidia.com/gpu.product": "A100-SXM4-40GB"
      }


#. Deploy a pod to consume the GPU and run ``nvidia-smi``

   .. code-block:: console

      $ kubectl run -it --rm \
         --image=nvidia/cuda:11.0-base \
         --restart=Never \
         --limits=nvidia.com/gpu=1 \
         mig-none-example -- nvidia-smi -L

   .. code-block:: console
      
      GPU 0: A100-SXM4-40GB (UUID: GPU-15f0798d-c807-231d-6525-a7827081f0f1)

#. Enable MIG on the GPU (requires stopping all GPU clients first)

   .. code-block:: console

      $ sudo systemctl stop kubelet

   .. note: To restart the plugins, you can delete the charts and reinstall using Helm

      .. code-block:: console

         $ helm delete $(helm ls --short)

   .. code-block:: console

      $ sudo nvidia-smi -mig 1

   .. code-block:: console

      Enabled MIG Mode for GPU 00000000:36:00.0
      All done.

   .. code-block:: console

      $ nvidia-smi --query-gpu=mig.mode.current --format=csv,noheader

   .. code-block:: console
   
      Enabled

#. Restart the ``kubelet`` and the plugins

   .. code-block:: console

      $ sudo systemctl start kubelet

#. Observe that 1 GPU is available on the node with resource type ``nvidia.com/gpu``.

   .. code-block:: console

      $ kubectl describe node
      ...
      Capacity:
      nvidia.com/gpu:          1
      ...
      Allocatable:
      nvidia.com/gpu:          1
      ...

#. Observe that the labels haven’t changed

   .. code-block:: console

      $ kubectl get node -o json | \
         jq '.items[0].metadata.labels | with_entries(select(.key | startswith("nvidia.com")))'

   .. code-block:: console

      {
      "nvidia.com/cuda.driver.major": "450",
      "nvidia.com/cuda.driver.minor": "80",
      "nvidia.com/cuda.driver.rev": "02",
      "nvidia.com/cuda.runtime.major": "11",
      "nvidia.com/cuda.runtime.minor": "0",
      "nvidia.com/gfd.timestamp": "1605312111",
      "nvidia.com/gpu.compute.major": "8",
      "nvidia.com/gpu.compute.minor": "0",
      "nvidia.com/gpu.count": "1",
      "nvidia.com/gpu.family": "ampere",
      "nvidia.com/gpu.machine": "NVIDIA DGX",
      "nvidia.com/gpu.memory": "40537",
      "nvidia.com/gpu.product": "A100-SXM4-40GB"
      }

#. Deploy a pod to consume the GPU and run nvidia-smi 

   .. code-block:: console

      $ kubectl run -it --rm \
         --image=nvidia/cuda:9.0-base \
         --restart=Never \
         --limits=nvidia.com/gpu=1 \
         mig-none-example -- nvidia-smi -L

   .. code-block:: console

      GPU 0: A100-SXM4-40GB (UUID: GPU-15f0798d-c807-231d-6525-a7827081f0f1)


The ``single`` strategy
=========================

The ``single`` strategy is designed to keep the user-experience of working with GPUs in Kubernetes the 
same as it has always been. MIG devices are enumerated with the nvidia.com/gpu resource type just as before. 
However, the properties associated with that resource type now map to the MIG devices available on that node, 
instead of the full GPUs.

Testing
---------

To test this strategy, we check that MIG devices of a single type are enumerated using the traditional ``nvidia.com/gpu`` 
resource type. The test assumes a single GPU on a single node in the cluster with MIG enabled on it already.

#. Verify that MIG is enabled on the GPU and no MIG devices present:

   .. code-block:: console

      $ nvidia-smi 

   .. code-block:: console

      +-----------------------------------------------------------------------------+
      | NVIDIA-SMI 450.80.02    Driver Version: 450.80.02    CUDA Version: 11.0     |
      |-------------------------------+----------------------+----------------------+
      | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
      | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
      |                               |                      |               MIG M. |
      |===============================+======================+======================|
      |   0  A100-SXM4-40GB      On   | 00000000:00:04.0 Off |                   On |
      | N/A   32C    P0    43W / 400W |      0MiB / 40537MiB |     N/A      Default |
      |                               |                      |              Enabled |
      +-------------------------------+----------------------+----------------------+

      +-----------------------------------------------------------------------------+
      | MIG devices:                                                                |
      +------------------+----------------------+-----------+-----------------------+
      | GPU  GI  CI  MIG |         Memory-Usage |        Vol|         Shared        |
      |      ID  ID  Dev |           BAR1-Usage | SM     Unc| CE  ENC  DEC  OFA  JPG|
      |                  |                      |        ECC|                       |
      |==================+======================+===========+=======================|
      |  No MIG devices found                                                       |
      +-----------------------------------------------------------------------------+

      +-----------------------------------------------------------------------------+
      | Processes:                                                                  |
      |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
      |        ID   ID                                                   Usage      |
      |=============================================================================|
      |  No running processes found                                                 |
      +-----------------------------------------------------------------------------+

#. Create 7 single-slice MIG devices on the GPU:

   .. code-block:: console

      $ sudo nvidia-smi mig -cgi 19,19,19,19,19,19,19 -C

   .. code-block:: console

      $ nvidia-smi -L

   .. code-block:: console

      GPU 0: A100-SXM4-40GB (UUID: GPU-4200ccc0-2667-d4cb-9137-f932c716232a)
        MIG 1g.5gb Device 0: (UUID: MIG-GPU-4200ccc0-2667-d4cb-9137-f932c716232a/7/0)
        MIG 1g.5gb Device 1: (UUID: MIG-GPU-4200ccc0-2667-d4cb-9137-f932c716232a/8/0)
        MIG 1g.5gb Device 2: (UUID: MIG-GPU-4200ccc0-2667-d4cb-9137-f932c716232a/9/0)
        MIG 1g.5gb Device 3: (UUID: MIG-GPU-4200ccc0-2667-d4cb-9137-f932c716232a/10/0)
        MIG 1g.5gb Device 4: (UUID: MIG-GPU-4200ccc0-2667-d4cb-9137-f932c716232a/11/0)
        MIG 1g.5gb Device 5: (UUID: MIG-GPU-4200ccc0-2667-d4cb-9137-f932c716232a/12/0)
        MIG 1g.5gb Device 6: (UUID: MIG-GPU-4200ccc0-2667-d4cb-9137-f932c716232a/13/0)


#. Start the *nvidia-device-plugin* plugin with the ``single`` strategy as described in the previous section. If its already 
   running, then restart the plugin.

#. Observe that 7 MIG devices are available on the node with resource type ``nvidia.com/gpu``:

   .. code-block:: console

      $ kubectl describe node
      ...
      Capacity:
      nvidia.com/gpu:          7
      ...
      Allocatable:
      nvidia.com/gpu:          7
      ...

#. Start *gpu-feature-discovery* with the ``single`` strategy as described in the previous section. If its already running, then 
   restart the plugin.

#. Observe that the proper set of labels have been applied for this MIG strategy:

   .. code-block:: console

      $ kubectl get node -o json | \
         jq '.items[0].metadata.labels | with_entries(select(.key | startswith("nvidia.com")))'

   .. code-block:: console
         
      {
      "nvidia.com/cuda.driver.major": "450",
      "nvidia.com/cuda.driver.minor": "80",
      "nvidia.com/cuda.driver.rev": "02",
      "nvidia.com/cuda.runtime.major": "11",
      "nvidia.com/cuda.runtime.minor": "0",
      "nvidia.com/gfd.timestamp": "1605657366",
      "nvidia.com/gpu.compute.major": "8",
      "nvidia.com/gpu.compute.minor": "0",
      "nvidia.com/gpu.count": "7",
      "nvidia.com/gpu.engines.copy": "1",
      "nvidia.com/gpu.engines.decoder": "0",
      "nvidia.com/gpu.engines.encoder": "0",
      "nvidia.com/gpu.engines.jpeg": "0",
      "nvidia.com/gpu.engines.ofa": "0",
      "nvidia.com/gpu.family": "ampere",
      "nvidia.com/gpu.machine": "NVIDIA DGX",
      "nvidia.com/gpu.memory": "4864",
      "nvidia.com/gpu.multiprocessors": "14",
      "nvidia.com/gpu.product": "A100-SXM4-40GB-MIG-1g.5gb",
      "nvidia.com/gpu.slices.ci": "1",
      "nvidia.com/gpu.slices.gi": "1",
      "nvidia.com/mig.strategy": "single"
      }


#. Deploy 7 pods, each consuming one MIG device (then read their logs and delete them)

   .. code-block:: console

      $ for i in $(seq 7); do
         kubectl run \
            --image=nvidia/cuda:11.0-base \
            --restart=Never \
            --limits=nvidia.com/gpu=1 \
            mig-single-example-${i} -- bash -c "nvidia-smi -L; sleep infinity"
      done

   .. code-block:: console

      pod/mig-single-example-1 created
      pod/mig-single-example-2 created
      pod/mig-single-example-3 created
      pod/mig-single-example-4 created
      pod/mig-single-example-5 created
      pod/mig-single-example-6 created
      pod/mig-single-example-7 created


   .. code-block:: console
      
      $ for i in $(seq 7); do
      echo "mig-single-example-${i}";
      kubectl logs mig-single-example-${i}
      echo "";
      done

   .. code-block:: console

      mig-single-example-1
      GPU 0: A100-SXM4-40GB (UUID: GPU-4200ccc0-2667-d4cb-9137-f932c716232a)
         MIG 1g.5gb Device 0: (UUID: MIG-GPU-4200ccc0-2667-d4cb-9137-f932c716232a/7/0)

      mig-single-example-2
      GPU 0: A100-SXM4-40GB (UUID: GPU-4200ccc0-2667-d4cb-9137-f932c716232a)
         MIG 1g.5gb Device 0: (UUID: MIG-GPU-4200ccc0-2667-d4cb-9137-f932c716232a/9/0)

      ...

   .. code-block:: console

      $ for i in $(seq 7); do
      kubectl delete pod mig-single-example-${i};
      done

   .. code-block:: console

      pod "mig-single-example-1" deleted
      pod "mig-single-example-2" deleted
      ...

The ``mixed`` strategy
=========================

The ``mixed`` strategy is designed to enumerate a different resource type for every MIG device 
configuration available in the cluster.


Testing
---------

To test this strategy, we check that all MIG devices are enumerated using their fully qualified name 
of the form ``nvidia.com/mig-<slice_count>g.<memory_size>gb``. The test assumes a single GPU on a single 
node in the cluster with MIG enabled on it already.

#. Verify that MIG is enabled on the GPU and no MIG devices present:

   .. code-block:: console

      $ nvidia-smi 

   .. code-block:: console

      +-----------------------------------------------------------------------------+
      | NVIDIA-SMI 450.80.02    Driver Version: 450.80.02    CUDA Version: 11.0     |
      |-------------------------------+----------------------+----------------------+
      | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
      | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
      |                               |                      |               MIG M. |
      |===============================+======================+======================|
      |   0  A100-SXM4-40GB      On   | 00000000:00:04.0 Off |                   On |
      | N/A   32C    P0    43W / 400W |      0MiB / 40537MiB |     N/A      Default |
      |                               |                      |              Enabled |
      +-------------------------------+----------------------+----------------------+

      +-----------------------------------------------------------------------------+
      | MIG devices:                                                                |
      +------------------+----------------------+-----------+-----------------------+
      | GPU  GI  CI  MIG |         Memory-Usage |        Vol|         Shared        |
      |      ID  ID  Dev |           BAR1-Usage | SM     Unc| CE  ENC  DEC  OFA  JPG|
      |                  |                      |        ECC|                       |
      |==================+======================+===========+=======================|
      |  No MIG devices found                                                       |
      +-----------------------------------------------------------------------------+

      +-----------------------------------------------------------------------------+
      | Processes:                                                                  |
      |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
      |        ID   ID                                                   Usage      |
      |=============================================================================|
      |  No running processes found                                                 |
      +-----------------------------------------------------------------------------+

#. Create 3 different MIG devices of different sizes on the GPU:

   .. code-block:: console

      $ sudo nvidia-smi mig -cgi 9,14,19 -C

   .. code-block:: console

      $ nvidia-smi -L

   .. code-block:: console

      GPU 0: A100-SXM4-40GB (UUID: GPU-4200ccc0-2667-d4cb-9137-f932c716232a)
        MIG 3g.20gb Device 0: (UUID: MIG-GPU-4200ccc0-2667-d4cb-9137-f932c716232a/2/0)
        MIG 2g.10gb Device 1: (UUID: MIG-GPU-4200ccc0-2667-d4cb-9137-f932c716232a/3/0)
        MIG 1g.5gb Device 2: (UUID: MIG-GPU-4200ccc0-2667-d4cb-9137-f932c716232a/9/0)


#. Start the *nvidia-device-plugin* plugin with the ``mixed`` strategy as described in the previous section. If its already 
   running, then restart the plugin.

#. Observe that 3 MIG devices are available on the node with resource type ``nvidia.com/gpu``:

   .. code-block:: console

      $ kubectl describe node
      ...
      Capacity:
      nvidia.com/mig-1g.5gb:   1
      nvidia.com/mig-2g.10gb:  1
      nvidia.com/mig-3g.20gb:  1
      ...
      Allocatable:
      nvidia.com/mig-1g.5gb:   1
      nvidia.com/mig-2g.10gb:  1
      nvidia.com/mig-3g.20gb:  1
      ...

#. Start *gpu-feature-discovery* with the ``mixed`` strategy as described in the previous section. If its already running, then 
   restart the plugin.

#. Observe that the proper set of labels have been applied for this MIG strategy:

   .. code-block:: console

      $ kubectl get node -o json | \
         jq '.items[0].metadata.labels | with_entries(select(.key | startswith("nvidia.com")))'

   .. code-block:: console
         
      {
      "nvidia.com/cuda.driver.major": "450",
      "nvidia.com/cuda.driver.minor": "80",
      "nvidia.com/cuda.driver.rev": "02",
      "nvidia.com/cuda.runtime.major": "11",
      "nvidia.com/cuda.runtime.minor": "0",
      "nvidia.com/gfd.timestamp": "1605658841",
      "nvidia.com/gpu.compute.major": "8",
      "nvidia.com/gpu.compute.minor": "0",
      "nvidia.com/gpu.count": "1",
      "nvidia.com/gpu.family": "ampere",
      "nvidia.com/gpu.machine": "NVIDIA DGX",
      "nvidia.com/gpu.memory": "40537",
      "nvidia.com/gpu.product": "A100-SXM4-40GB",
      "nvidia.com/mig-1g.5gb.count": "1",
      "nvidia.com/mig-1g.5gb.engines.copy": "1",
      "nvidia.com/mig-1g.5gb.engines.decoder": "0",
      "nvidia.com/mig-1g.5gb.engines.encoder": "0",
      "nvidia.com/mig-1g.5gb.engines.jpeg": "0",
      "nvidia.com/mig-1g.5gb.engines.ofa": "0",
      "nvidia.com/mig-1g.5gb.memory": "4864",
      "nvidia.com/mig-1g.5gb.multiprocessors": "14",
      "nvidia.com/mig-1g.5gb.slices.ci": "1",
      "nvidia.com/mig-1g.5gb.slices.gi": "1",
      "nvidia.com/mig-2g.10gb.count": "1",
      "nvidia.com/mig-2g.10gb.engines.copy": "2",
      "nvidia.com/mig-2g.10gb.engines.decoder": "1",
      "nvidia.com/mig-2g.10gb.engines.encoder": "0",
      "nvidia.com/mig-2g.10gb.engines.jpeg": "0",
      "nvidia.com/mig-2g.10gb.engines.ofa": "0",
      "nvidia.com/mig-2g.10gb.memory": "9984",
      "nvidia.com/mig-2g.10gb.multiprocessors": "28",
      "nvidia.com/mig-2g.10gb.slices.ci": "2",
      "nvidia.com/mig-2g.10gb.slices.gi": "2",
      "nvidia.com/mig-3g.21gb.count": "1",
      "nvidia.com/mig-3g.21gb.engines.copy": "3",
      "nvidia.com/mig-3g.21gb.engines.decoder": "2",
      "nvidia.com/mig-3g.21gb.engines.encoder": "0",
      "nvidia.com/mig-3g.21gb.engines.jpeg": "0",
      "nvidia.com/mig-3g.21gb.engines.ofa": "0",
      "nvidia.com/mig-3g.21gb.memory": "20096",
      "nvidia.com/mig-3g.21gb.multiprocessors": "42",
      "nvidia.com/mig-3g.21gb.slices.ci": "3",
      "nvidia.com/mig-3g.21gb.slices.gi": "3",
      "nvidia.com/mig.strategy": "mixed"
      }


#. Deploy 3 pods, each consuming one of the available MIG devices

   .. code-block:: console

      $ kubectl run -it --rm \
         --image=nvidia/cuda:11.0-base \
         --restart=Never \
         --limits=nvidia.com/mig-1g.5gb=1 \
         mig-mixed-example -- nvidia-smi -L

   .. code-block:: console

      GPU 0: A100-SXM4-40GB (UUID: GPU-4200ccc0-2667-d4cb-9137-f932c716232a)
      MIG 1g.5gb Device 0: (UUID: MIG-GPU-4200ccc0-2667-d4cb-9137-f932c716232a/9/0)
      pod "mig-mixed-example" deleted
