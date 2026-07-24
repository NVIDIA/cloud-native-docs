.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

.. headings (h1/h2/h3/h4/h5) are # * = -

.. _nvaie-tanzu: https://docs.nvidia.com/ai-enterprise/deployment-guide-vmware/0.1.0/index.html
.. |nvaie-tanzu| replace:: *NVIDIA AI Enterprise VMware vSphere Deployment Guide*


.. _install-gpu-operator:
.. _operator-install-guide:

==================================
Installing the NVIDIA GPU Operator
==================================

.. admonition:: Version

   The current patch release of this version of the NVIDIA GPU Operator is ``${version}``.

Before installing the GPU Operator, refer to the :doc:`prerequisites` page to make sure your cluster is configured correctly.

.. seealso::

   Not sure which install guide fits your environment? Refer to :ref:`install-paths`.

**********
QuickStart
**********

A default installation deploys the NVIDIA GPU driver, NVIDIA Container Toolkit,
NVIDIA Device Plugin, DCGM Exporter, and MIG Manager as pods on every GPU worker node.
Use ``--set`` options to customize the deployment for your environment.


#. Add the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
          && helm repo update

#. Install the GPU Operator.

   - Install the Operator with the default configuration:

     .. code-block:: console

        $ helm install --wait --generate-name \
            -n gpu-operator --create-namespace \
            nvidia/gpu-operator \
            --version=${version}

   - Install the Operator and specify configuration options:

     .. code-block:: console

        $ helm install --wait --generate-name \
            -n gpu-operator --create-namespace \
            nvidia/gpu-operator \
            --version=${version} \
            --set <option-name>=<option-value>

     Refer to the :ref:`gpu-operator-helm-chart-options`
     and :ref:`common deployment scenarios` for more information.

#. After the Operator finishes deploying, :ref:`verify the installation <verify gpu operator install>`.



.. _running sample gpu applications:
.. _verify gpu operator install:

*********************************************
Verification: Running Sample GPU Applications
*********************************************

Verifying Operator Health
=========================

After the Helm install completes, confirm that the GPU Operator is healthy before
running workloads.

#. Check that all GPU Operator pods are running:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator

   *Example Output*

   .. code-block:: output

      NAME                                                          READY   STATUS      RESTARTS   AGE
      gpu-feature-discovery-7nwkb                                       1/1     Running     0          6m30s
      gpu-operator-1780680501-node-feature-discovery-gc-774b78f8mqg6b   1/1     Running     0          6m47s
      gpu-operator-1780680501-node-feature-discovery-master-79dctr6tf   1/1     Running     0          6m47s
      gpu-operator-1780680501-node-feature-discovery-worker-2gb9m       1/1     Running     0          6m47s
      gpu-operator-69fd4d9858-nvrvc                                     1/1     Running     0          6m47s
      nvidia-container-toolkit-daemonset-74gtl                          1/1     Running     0          6m30s
      nvidia-cuda-validator-5m8l6                                       0/1     Completed   0          4m46s
      nvidia-dcgm-exporter-tt5z5                                        1/1     Running     0          6m30s
      nvidia-device-plugin-daemonset-t5zfq                              1/1     Running     0          6m30s
      nvidia-driver-daemonset-nr9td                                     1/1     Running     0          6m37s
      nvidia-operator-validator-m2h8f                                   1/1     Running     0          6m47s

   All pods should show ``Running`` or ``Completed``.
   If any pod is in ``CrashLoopBackOff`` or ``Error`` state, refer to the :doc:`troubleshooting` page.
   The above output is for a default install.
   If you installed the Operator with custom configuration, you may see different pods.

#. Verify the ``ClusterPolicy`` is in the ``ready`` state:

   .. code-block:: console

      $ kubectl get clusterpolicy 

   *Example Output*

   .. code-block:: output

      cluster-policy   ready    2026-06-05T17:28:22Z

#. Confirm that GPU resources are available on nodes (requires `jq <https://jqlang.org/>`__):

   .. code-block:: console

      $ kubectl get nodes -o json \
          | jq '.items[] | select(.status.allocatable["nvidia.com/gpu"] != null) | {name: .metadata.name, gpus: .status.allocatable["nvidia.com/gpu"]}'

   *Example Output*

   .. code-block:: output

      {
        "name": "worker-node-01",
        "gpus": "4"
      }

   Each GPU worker node should show a non-null ``gpus`` value matching the number of
   physical GPUs on that node.
   The NVIDIA Kubernetes Device Plugin registers each GPU as a Kubernetes
   `extended resource <https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#extended-resources>`__
   named ``nvidia.com/gpu``.
   This step confirms that GPUs are visible to the scheduler.

CUDA VectorAdd
==============

In the first example, run a simple CUDA sample that adds two vectors together:


#. Create a file, such as ``cuda-vectoradd.yaml``, with contents like the following:

   .. code-block:: yaml

      apiVersion: v1
      kind: Pod
      metadata:
        name: cuda-vectoradd
      spec:
        restartPolicy: OnFailure
        containers:
        - name: cuda-vectoradd
          image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0-ubuntu22.04"
          resources:
            limits:
              nvidia.com/gpu: 1

#. Run the pod:

   .. code-block:: console

      $ kubectl apply -f cuda-vectoradd.yaml

   The pod starts, runs the ``vectorAdd`` command, and then exits.

#. View the logs from the container:

   .. code-block:: console

      $ kubectl logs pod/cuda-vectoradd

   *Example Output*

   .. code-block:: output

      [Vector addition of 50000 elements]
      Copy input data from the host memory to the CUDA device
      CUDA kernel launch with 196 blocks of 256 threads
      Copy output data from the CUDA device to the host memory
      Test PASSED
      Done

#. Remove the stopped pod:

   .. code-block:: console

      $ kubectl delete -f cuda-vectoradd.yaml

   *Example Output*

   .. code-block:: output

      pod "cuda-vectoradd" deleted


Jupyter Notebook
================

You can perform the following steps to deploy Jupyter Notebook in your cluster:

#. Create a file, such as ``tf-notebook.yaml``, with contents like the following example:

   .. literalinclude:: ./manifests/input/tf-notebook.yaml
      :language: yaml

#. Apply the manifest to deploy the pod and start the service:

   .. code-block:: console

      $ kubectl apply -f tf-notebook.yaml

#. Check the pod status:

   .. code-block:: console

      $ kubectl get pod tf-notebook

   *Example Output*

   .. code-block:: output

      NAMESPACE   NAME          READY   STATUS      RESTARTS   AGE
      default     tf-notebook   1/1     Running     0          3m45s

#. Because the manifest includes a service, get the external port for the notebook:

   .. code-block:: console

      $ kubectl get svc tf-notebook

   *Example Output*

   .. code-block:: output

      NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)       AGE
      tf-notebook   NodePort    10.106.229.20   <none>        80:30001/TCP  4m41s

#. Get the token for the Jupyter notebook:

   .. code-block:: console

      $ kubectl logs tf-notebook

   *Example Output*

   .. code-block:: output

      [I 21:50:23.188 NotebookApp] Writing notebook server cookie secret to /root/.local/share/jupyter/runtime/notebook_cookie_secret
      [I 21:50:23.390 NotebookApp] Serving notebooks from local directory: /tf
      [I 21:50:23.391 NotebookApp] The Jupyter Notebook is running at:
      [I 21:50:23.391 NotebookApp] http://tf-notebook:8888/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9
      [I 21:50:23.391 NotebookApp]  or http://127.0.0.1:8888/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9
      [I 21:50:23.391 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
      [C 21:50:23.394 NotebookApp]

      To access the notebook, open this file in a browser:
         file:///root/.local/share/jupyter/runtime/nbserver-1-open.html
      Or copy and paste one of these URLs:
         http://tf-notebook:8888/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9
      or http://127.0.0.1:8888/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9

The notebook should now be accessible from your browser at this URL:
`http://your-machine-ip:30001/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9 <http://your-machine-ip:30001/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9>`_.


***************************
Common Deployment Scenarios
***************************

The following common deployment scenarios and sample commands apply best to
bare metal hosts or virtual machines with GPU passthrough.

Installing with DRA Driver for NVIDIA GPUs
==========================================

.. note::

   Deploying and managing the DRA Driver for NVIDIA GPUs through the ``GPUCluster`` custom resource is in Technology
   Preview and is supported only for greenfield (new) deployments.
   Configuration options may change in future releases.
   Migrating an existing ``ClusterPolicy`` deployment to ``GPUCluster`` in place is not supported.
   Do not use ``ClusterPolicy`` and ``GPUCluster`` as GPU resource management models in the same cluster.

If you want to use Kubernetes Dynamic Resource Allocation (DRA) to manage GPU resource allocation in your cluster,
install the GPU Operator with the ``GPUCluster`` custom resource enabled and ``DEFAULT_GPU_ALLOCATION_MODE`` set to
``dra``.
This deploys the GPU Operator with the components necessary for DRA, including the DRA Driver for NVIDIA GPUs.

.. code-block:: console

  $ helm upgrade --install gpu-operator nvidia/gpu-operator \
      --version=${version} \
      --create-namespace \
      --namespace gpu-operator \
      --set gpuCluster.enabled=true \
      --set driver.nvidiaDriverCRD.enabled=true \
      --set operator.env[0].name=DEFAULT_GPU_ALLOCATION_MODE \
      --set operator.env[0].value=dra

The ``gpuCluster.enabled=true`` flag creates the default ``GPUCluster`` resource.
The ``driver.nvidiaDriverCRD.enabled=true`` flag creates the ``NVIDIADriver`` custom resource to manage the NVIDIA GPU driver. If you are planning to use pre-installed drivers, set this flag to ``false`` and include the ``driver.enabled=false`` flag.
Setting the ``DEFAULT_GPU_ALLOCATION_MODE`` environment variable to ``dra`` ensures that GPU nodes are labeled for DRA components.

Specifying the Operator Namespace
=================================

Both the Operator and operands are installed in the same namespace.
The namespace is configurable and is specified during installation.
For example, to install the GPU Operator in the ``nvidia-gpu-operator`` namespace:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n nvidia-gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --version=${version} \

If you do not specify a namespace during installation, all GPU Operator components are installed in the ``default`` namespace.

Preventing Installation of Operands on Some Nodes
=================================================

By default, the GPU Operator operands are deployed on all GPU worker nodes in the cluster.
GPU worker nodes are identified by the presence of the label ``feature.node.kubernetes.io/pci-10de.present=true``.
The value ``0x10de`` is the PCI vendor ID that is assigned to NVIDIA.

To disable operands from getting deployed on a GPU worker node, label the node with ``nvidia.com/gpu.deploy.operands=false``.

.. code-block:: console

   $ kubectl label nodes $NODE nvidia.com/gpu.deploy.operands=false

Preventing Installation of NVIDIA GPU Driver on Some Nodes
==========================================================

By default, the GPU Operator deploys the driver on all GPU worker nodes in the cluster.
To prevent installing the driver on a GPU worker node, label the node like the following sample command.

.. code-block:: console

   $ kubectl label nodes $NODE nvidia.com/gpu.deploy.driver=false


Installation on Red Hat Enterprise Linux
========================================

When using RHEL 8 with Kubernetes, SELinux must be enabled either in permissive or enforcing mode for use with the GPU Operator.
Additionally, when using RHEL 8 with containerd as the runtime and SELinux is enabled (either in permissive or enforcing mode) at the host level, containerd must also be configured for SELinux, by setting the ``enable_selinux=true`` configuration option.

Network restricted environments are not supported.

You can use the standard install comamnd to install the GPU Operator on RHEL.

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --version=${version} 


Pre-Installed NVIDIA GPU Drivers
================================

In this scenario, the NVIDIA GPU driver is already installed on the worker nodes that have GPUs:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --version=${version} \
        --set driver.enabled=false

The preceding command prevents the Operator from installing the GPU driver on any nodes in the cluster.

If you do not specify the ``driver.enabled=false`` argument and nodes in the cluster have a pre-installed GPU driver, the init container in the driver pod detects that the driver is preinstalled and labels the node so that the driver pod is terminated and does not get re-scheduled on to the node.
The Operator proceeds to start other pods, such as the container toolkit pod.

.. _preinstalled-drivers-and-toolkit:

Pre-Installed NVIDIA GPU Drivers and NVIDIA Container Toolkit
=============================================================

In this scenario, the NVIDIA GPU driver and the NVIDIA Container Toolkit are already installed on
the worker nodes that have GPUs.

.. tip::

   This scenario applies to NVIDIA DGX Systems that run NVIDIA Base OS.

Before installing the Operator, ensure that the default runtime is set to ``nvidia``.
Refer to :external+ctk:ref:`configuration` in the NVIDIA Container Toolkit documentation for more information.

Install the Operator with the following options:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --version=${version} \
        --set driver.enabled=false \
        --set toolkit.enabled=false


Pre-Installed NVIDIA Container Toolkit (but no drivers)
=======================================================

In this scenario, the NVIDIA Container Toolkit is already installed on the worker nodes that have GPUs.

1. Configure toolkit to use the ``root`` directory of the driver installation as ``/run/nvidia/driver``, because this is the path mounted by driver container.

   .. code-block:: console

      $ sudo sed -i 's/^#root/root/' /etc/nvidia-container-runtime/config.toml

2. Install the Operator with the following options (which will provision a driver):

   .. code-block:: console

      $ helm install --wait --generate-name \
          -n gpu-operator --create-namespace \
          nvidia/gpu-operator \
          --version=${version} \
          --set toolkit.enabled=false

Running a Custom Driver Image
=============================

If you want to use custom driver container images, such as version 580.126.20, then
you can build a custom driver container image. Follow these steps:

- Rebuild the driver container by specifying the ``$DRIVER_VERSION`` argument when building the Docker image. For
  reference, the `driver container Dockerfiles <https://github.com/NVIDIA/gpu-driver-container/>`__ are available on GitHub.
- Build the container using the appropriate Dockerfile. For example:

  .. code-block:: console

    $ docker build --pull \
        --build-arg DRIVER_VERSION=580.126.20 \
        -t nvidia/driver:580.126.20-ubuntu22.04 \
        --file Dockerfile .

  Ensure that the driver container is tagged as shown in the example by using the ``driver:<version>-<os>`` schema.
- Specify the new driver image and repository by overriding the defaults in
  the Helm install command. For example:

  .. code-block:: console

     $ helm install --wait --generate-name \
          -n gpu-operator --create-namespace \
          nvidia/gpu-operator \
          --version=${version} \
          --set driver.repository=docker.io/nvidia \
          --set driver.version="580.126.20"

These instructions are provided for reference and evaluation purposes.
Not using the standard releases of the GPU Operator from NVIDIA would mean limited
support for such custom configurations.

.. _custom-runtime-options:

***********************************************
Specifying Configuration Options for containerd
***********************************************

.. note::

 It's recommended that you enable the NRI Plugin to configure the container runtime by setting ``cdi.nriPluginEnabled=true``. 
 When enabled, you do not need to specify the ``toolkit.env`` options and injecting GPUs into workload containers is handled by the NRI Plugin.
 Refer to the :ref:`NRI Plugin <nri-plugin>` documentation, for more information.

When you use containerd as the container runtime, the following configuration
options are used with the container-toolkit deployed with GPU Operator:

.. code-block:: yaml

   toolkit:
      env:
      - name: CONTAINERD_CONFIG
        value: /etc/containerd/config.toml
      - name: CONTAINERD_SOCKET
        value: /run/containerd/containerd.sock
      - name: RUNTIME_CONFIG_SOURCE
        value: "command,file"


If you need to specify custom values, refer to the following sample command for the syntax:


.. code-block:: console

  helm install gpu-operator -n gpu-operator --create-namespace \
    nvidia/gpu-operator $HELM_OPTIONS \
      --version=${version} \
      --set toolkit.env[0].name=CONTAINERD_CONFIG \
      --set toolkit.env[0].value=/etc/containerd/containerd.toml \
      --set toolkit.env[1].name=CONTAINERD_SOCKET \
      --set toolkit.env[1].value=/run/containerd/containerd.sock \
      --set toolkit.env[2].name=RUNTIME_CONFIG_SOURCE \
      --set toolkit.env[2].value="command,file"

These options are defined as follows:

CONTAINERD_CONFIG
  The path on the host to the top-level ``containerd`` config file.
  By default this will point to ``/etc/containerd/config.toml``
  (the default location for ``containerd``). It should be customized if your ``containerd``
  installation is not in the default location.

CONTAINERD_SOCKET
  The path on the host to the socket file used to
  communicate with ``containerd``. The operator will use this to send a
  ``SIGHUP`` signal to the ``containerd`` daemon to reload its config. By
  default this will point to ``/run/containerd/containerd.sock``
  (the default location for ``containerd``). It should be customized if
  your ``containerd`` installation is not in the default location.

RUNTIME_CONFIG_SOURCE
  The config source(s) that the container-toolkit uses when fetching
  the current containerd configuration. A valid value for this setting is any
  combination of [command | file]. By default this will be configured as
  "command,file" which means the container-toolkit will attempt to fetch
  the configuration using the containerd CLI before falling back to reading the
  config from the top-level ``containerd`` config file (configured using
  CONTAINERD_CONFIG). When ``file`` is specified, the absolute path to the file
  to be used as a config source can be specified as ``file=/path/to/source/config.toml``

RUNTIME_DROP_IN_CONFIG
  The path on the host where the NVIDIA-specific drop-in config file
  will be created. By default this will point to ``/etc/containerd/conf.d/99-nvidia.toml``.


Rancher Kubernetes Engine 2
===========================

For Rancher Kubernetes Engine 2 (RKE2), refer to
`Deploy NVIDIA Operator <https://docs.rke2.io/add-ons/gpu_operators#deploy-nvidia-operator>`__
in the RKE2 documentation.

The NRI Plugin is available for use on RKE2. With CDI (the default) and the NRI Plugin both enabled, you do not need to set ``runtimeClassName: nvidia`` in your pod specification, and you do not need to configure the ``CONTAINERD_CONFIG``, ``CONTAINERD_SOCKET``, or ``RUNTIME_CONFIG_SOURCE`` environment variables.

.. note::

   The containerd project has not yet released a general availability (GA) version of the NRI Plugin. The implementation might change before the GA release.
   Refer to the `containerd NRI repository <https://github.com/containerd/nri#api-stability>`_ for details on project details.

Refer to the :ref:`v24.9.0-known-limitations`.

.. _microk8s-install-procedure:

MicroK8s
========


For MicroK8s, set the following in the ``ClusterPolicy``.

.. code-block:: yaml

   toolkit:
      env:
      - name: CONTAINERD_CONFIG
        value: /var/snap/microk8s/current/args/containerd-template.toml
      - name: CONTAINERD_SOCKET
        value: /var/snap/microk8s/common/run/containerd.sock
      - name: RUNTIME_CONFIG_SOURCE
        value: "file=/var/snap/microk8s/current/args/containerd.toml"

These options can be passed to GPU Operator during install time as below.

.. code-block:: console

  helm install gpu-operator -n gpu-operator --create-namespace \
    nvidia/gpu-operator $HELM_OPTIONS \
      --version=${version} \
      --set toolkit.env[0].name=CONTAINERD_CONFIG \
      --set toolkit.env[0].value=/var/snap/microk8s/current/args/containerd-template.toml \
      --set toolkit.env[1].name=CONTAINERD_SOCKET \
      --set toolkit.env[1].value=/var/snap/microk8s/common/run/containerd.sock \
      --set toolkit.env[2].name=RUNTIME_CONFIG_SOURCE \
      --set-string toolkit.env[2].value=file=/var/snap/microk8s/current/args/containerd.toml

***********************************************************
Installation on Commercially Supported Kubernetes Platforms
***********************************************************

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Product
     - Documentation

   * - | Red Hat OpenShift 4
       | using RHCOS worker nodes
     - :external+ocp:doc:`index`

   * - | VMware  vSphere Kubernetes Service
       | and NVIDIA AI Enterprise
     - |nvaie-tanzu|_

   * - Google Cloud Anthos
     - :external+edge:doc:`anthos-guide`

**********
Next Steps
**********

After verifying the installation, you can configure the GPU Operator for your workloads:

- :doc:`gpu-sharing` — Share a single GPU across multiple pods using time-slicing or MPS.
- :doc:`gpu-operator-mig` — Configure Multi-Instance GPU (MIG) partitioning on supported GPUs.
- :doc:`gpu-operator-rdma` — Enable GPUDirect RDMA for high-performance networking.
- :doc:`gpu-driver-configuration` — Use the NVIDIA GPU Driver Custom Resource Definition to manage drivers per node.
- :doc:`precompiled-drivers` — Speed up driver deployments with precompiled kernel modules.
- :doc:`cdi` — Learn about Container Device Interface (CDI) and NRI Plugin mode.