
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

############################################
NVIDIA GPU Driver Custom Resource Definition
############################################

.. contents::
   :depth: 2
   :local:
   :backlinks: none


*****************************************************
Overview of the GPU Driver Custom Resource Definition
*****************************************************

.. note::

   Technology Preview features are not supported in production environments
   and are not functionally complete.
   Technology Preview features provide early access to upcoming product features,
   enabling customers to test functionality and provide feedback during the development process.
   These releases may not have any documentation, and testing is limited.

   This feature does not support an upgrade from an earlier version of the NVIDIA GPU Operator.
   You must uninstall an existing installation and then install the Operator again.
   Uninstalling the Operator interrupts services and applications that require access to NVIDIA GPUs.

As a technology preview feature, you can create one or more instances of an NVIDIA driver custom resource
to specify the NVIDIA GPU driver type and driver version to configure on specific nodes.
You can specify labels in the node selector field to control which NVIDIA driver configuration is applied to specific nodes.

Comparison: Managing the Driver with CRD versus the Cluster Policy
==================================================================

Before the introduction of the NVIDIA GPU Driver custom resource definition, you manage the driver by modifying
the driver field and subfields of the cluster policy custom resource definition.

The key differences between the two approaches are summarized in the following table.

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - Cluster Policy CRD
     - NVIDIA Driver CRD

   * -
       - Supports a single driver type and version on all nodes.
       - Does not support multiple operating system versions.
         This limitation complicates performing an operating system upgrade on your nodes.

     -
       - Supports multiple driver types and versions on different nodes.
       - Supports multiple operating system versions on nodes.


Driver Daemon Sets
==================

The NVIDIA GPU Operator starts a driver daemon set for each NVIDIA driver custom resource and each operating system version.

For example, if your cluster has one NVIDIA driver custom resource that specifies a 535 branch GPU driver and some
worker nodes run Ubuntu 20.04 and other worker nodes run Ubuntu 22.04, the Operator starts two driver daemon sets.
One daemon set configures the GPU driver on the Ubuntu 20.04 nodes and the other configures the driver on the Ubuntu 22.04 nodes.
All the nodes run the same 535 branch GPU driver.

.. image:: graphics/nvd-basics.svg

If you choose to use precompiled driver containers, the Operator starts a driver daemon set for each Linux kernel version.

For example, if some nodes run Ubuntu 22.04 and the 5.15.0-84-generic kernel, and other nodes run the 5.15.0-78-generic kernel,
then the Operator starts two daemon sets.


About the Default NVIDIA Driver Custom Resource
===============================================

By default, the helm chart configures a default NVIDIA driver custom resource during installation.
This custom resource does not include a node selector and as a result, the custom resource applies to every node in your cluster
that has an NVIDIA GPU.
The Operator starts a driver daemon set and pods for each operating system version in your cluster.

If you plan to configure your own driver custom resources to specify driver versions, types, and so on, then
you might prefer to avoid installing the default custom resource.
By preventing the installation, you can avoid node selector conflicts due to the default custom resource
matching all nodes and your custom resources matching some of the same nodes.

To prevent configuring the default custom resource, specify the ``--set driver.nvidiaDriverCRD.deployDefaultCR=false``
argument when you install the Operator with Helm.


Feature Compatibility
=====================

Driver type
  Each NVIDIA driver custom resource specifies the driver type and is one of ``gpu``, ``vgpu``, or ``vgpu-host-manager``.
  You can run the data-center driver (``gpu``) on some nodes and the vGPU driver on other nodes.

GPUDirect RDMA and GPUDirect Storage
  Each NVIDIA driver custom resource can specify how to configure GPUDirect RDMA and GPUDirect Storage (GDS).
  Refer to :ref:`GPUDirect RDMA and GPUDirect Storage` for the platform support and prerequisites.

GDRCopy
  Each NVIDIA driver custom resource can enable the GDRCopy sidecar container in the driver pod.

Precompiled and signed drivers
  You can run the default driver type that is compiled when the driver pod starts on some nodes
  and precompiled driver containers on other nodes.
  The :ref:`precomp-limitations-restrictions` for precompiled driver containers apply.

Preinstalled drivers on nodes
  If a node has an NVIDIA GPU driver installed in the operating system, then no driver container runs on the node.

Support for X86_64 and ARM64
  Each daemon set can run pods and driver containers for the X86_64 and ARM64 architectures.
  Refer to the `NVIDIA GPU Driver tags <https://catalog.ngc.nvidia.com/orgs/nvidia/containers/driver/tags>`__
  web page to determine which driver version and operating system combinations support both architectures.



***************************************
About the NVIDIA Driver Custom Resource
***************************************

An instance of the NVIDIA driver custom resource represents a specific NVIDIA GPU driver type and driver version to install and manage
on nodes.

.. literalinclude:: ./manifests/input/nvd-demo-gold.yaml
   :language: yaml
   :caption: Sample NVIDIA Driver Manifest

The following table describes some of the fields in the custom resource.

.. list-table::
   :header-rows: 1
   :widths: 20 60 20

   * - Field
     - Description
     - Default Value

   * - ``metadata.name``
     - Specifies the name of the NVIDIA driver custom resource.
     - None

   * - ``annotations``
     - Specifies a map of key and value pairs to add as custom annotations to the driver pod.
     - None

   * - ``driverType``
     - Specifies one of the following:

       - ``gpu`` to use the NVIDIA data-center GPU driver.
       - ``vgpu`` to use the NVIDIA vGPU guest driver.
       - ``vgpu-host-manager`` to use the NVIDIA vGPU Manager.
     - ``gpu``

   * - ``env``
     - Specifies environment variables to pass to the driver container.
     - None

   * - ``gdrcopy.enabled``
     - Specifies whether to deploy the GDRCopy Driver.
       When set to ``true`` the GDRCopy Driver image runs as a sidecar container.
     - ``false``

   * - ``gds.enabled``
     - Specifies whether to enable GPUDirect Storage.
     - ``false``

   * - ``image``
     - Specifies the driver container image name.
     - ``driver``

   * - ``imagePullPolicy``
     - Specifies the policy for kubelet to download the container image.
       Refer to the Kubernetes documentation for
       `image pull policy <https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy>`__.
     - Refer to the Kubernetes documentation.

   * - ``imagePullSecrets``
     - Specifies the credentials to provide to the registry if the registry is secured.
     - None

   * - ``labels``
     - Specifies a map of key and value pairs to add as custom labels to the driver pod.
     - None

   * - ``nodeSelector``
     - Specifies one or more node labels to match.
       The driver container is scheduled to nodes that match all the labels.
     - None.
       When you do not specify this field, the driver custom resource selects all nodes.

   * - ``priorityClassName``
     - Specifies the priority class for the driver pod.
     - ``system-node-critical``

   * - ``rdma.enabled``
     - Specifies whether to enable GPUDirect RDMA.
     - ``false``

   * - ``repository``
     - Specifies the container registry that contains the driver container.
     - ``nvcr.io/nvidia``

   * - ``useOpenKernelModules``
     - Specifies to use the NVIDIA Open GPU Kernel modules.
     - ``false``

   * - ``tolerations``
     - Specifies a set of tolerations to apply to the driver pod.
     - None

   * - ``usePrecompiled``
     - When set to ``true``, the Operator deploys a driver container image
       with a precompiled driver.
     - ``false``

   * - ``version``
     - Specifies the GPU driver version to install.
       For a data-center driver, specify a value like ``535.104.12``.
       If you set ``usePrecompiled`` to ``true``, specify the driver branch, such as ``535``.
     - Refer to the :ref:`operator-component-matrix`.


**********************************
Installing the NVIDIA GPU Operator
**********************************

Perform the following steps to install the GPU Operator and use the NVIDIA driver custom resources.

#. Optional: If you want to run more than one driver type or version in the cluster,
   label the worker nodes to identify the driver type and version to install on each node:

   *Example*

   .. code-block:: console

      $ kubectl label node <node-name> --overwrite driver.version=525.125.06

   - To use a mix of driver types, such as vGPU, label nodes for the driver type.
   - To use a mix of driver versions, label the nodes for the different versions.
   - To use a mix of conventional drivers and precompiled driver containers, label the nodes for the different types.

#. Install the Operator.

   - Add the NVIDIA Helm repository:

     .. code-block:: console

        $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
            && helm repo update

   - Install the Operator and specify at least the ``--set driver.nvidiaDriverCRD.enabled=true`` argument:

     .. code-block:: console

        $ helm install --wait --generate-name \
            -n gpu-operator --create-namespace \
            nvidia/gpu-operator \
            --version=${version}
            --set driver.nvidiaDriverCRD.enabled=true

     By default, Helm configures a ``default`` NVIDIA driver custom resource during installation.
     To prevent configuring the default custom resource, also specify ``--set driver.nvidiaDriverCRD.deployDefaultCR=false``.

#. Apply NVIDIA driver custom resources manifests to install the NVIDIA GPU driver version, type, and so on for your nodes.
   Refer to the sample manifests.


******************************
Sample NVIDIA Driver Manifests
******************************

One Driver Type and Version on All Nodes
========================================

#. Optional: Remove previously applied node labels.

#. Create a file, such as ``nvd-all.yaml``, with contents like the following:

   .. literalinclude:: ./manifests/input/nvd-all.yaml
      :language: yaml

   .. tip::

      Because the manifest does not include a ``nodeSelector`` field, the driver custom
      resource selects all nodes in the cluster that have an NVIDIA GPU.

#. Apply the manfiest:

   .. code-block:: console

      $ kubectl apply -n gpu-operator -f nvd-all.yaml

#. Optional: Monitor the progress:

   .. code-block:: console

      $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'


Multiple Driver Versions
========================

#. Label the nodes.

   - On some nodes, apply a label like the following:

     .. code-block:: console

        $ kubectl label node <node-name> --overwrite driver.config="gold"

   - On other nodes, apply a label like the following:

     .. code-block:: console

        $ kubectl label node <node-name> --overwrite driver.config="silver"

#. Create a file, such as ``nvd-driver-multiple.yaml``, with contents like the following:

   .. literalinclude:: ./manifests/input/nvd-driver-multiple.yaml
      :language: yaml

#. Apply the manfiest:

   .. code-block:: console

      $ kubectl apply -n gpu-operator -f nvd-driver-multiple.yaml

#. Optional: Monitor the progress:

   .. code-block:: console

      $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'


One Precompiled Driver Container on All Nodes
=============================================

#. Optional: Remove previously applied node labels.

#. Create a file, such as ``nvd-precompiled-all.yaml``, with contents like the following:

   .. literalinclude:: ./manifests/input/nvd-precompiled-all.yaml
      :language: yaml

   .. tip::

      Because the manfiest does not include a ``nodeSelector`` field, the driver custom
      resource selects all nodes in the cluster that have an NVIDIA GPU.

#. Apply the manfiest:

   .. code-block:: console

      $ kubectl apply -n gpu-operator -f nvd-precompiled-all.yaml

#. Optional: Monitor the progress:

   .. code-block:: console

      $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'


Precompiled Driver Container on Some Nodes
==========================================

#. Label the nodes like the following sample:

   .. code-block:: console

      $ kubectl label node <node-name> --overwrite driver.precompiled="true"
      $ kubectl label node <node-name> --overwrite driver.version="535"

#. Create a file, such as ``nvd-precomiled-some.yaml``, with contents like the following:

   .. literalinclude:: ./manifests/input/nvd-precompiled-some.yaml
      :language: yaml

#. Apply the manfiest:

   .. code-block:: console

      $ kubectl apply -n gpu-operator -f nvd-precompiled-some.yaml

#. Optional: Monitor the progress:

   .. code-block:: console

      $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'


.. _nvd-upgrade:

*******************************
Upgrading the NVIDIA GPU Driver
*******************************

You can upgrade the driver version by editing or patching the NVIDIA driver custom resource.

When you update the custom resource, the Operator performs a rolling update of the pods in the affected daemon set.

#. Update the ``driver.version`` field in the driver custom resource:

   .. code-block:: console

      $ kubectl patch nvidiadriver/demo-silver --type='json' \
          -p='[{"op": "replace", "path": "/spec/version", "value": "525.125.06"}]'

#. Optional: Monitor the progress:

   .. code-block:: console

      $ kubectl get pods -n gpu-operator -l app.kubernetes.io/component=nvidia-driver

   *Example Output*

   .. code-block:: output

      NAME                                             READY   STATUS        RESTARTS   AGE
      nvidia-gpu-driver-ubuntu20.04-788484b9bb-6zhd9   1/1     Running       0          5m1s
      nvidia-gpu-driver-ubuntu22.04-8896c4bf7-7s68q    1/1     Terminating   0          37m
      nvidia-gpu-driver-ubuntu22.04-8896c4bf7-jm74l    1/1     Running       0          37m

Eventually, the Operator replaces the pods that used the previous driver version with pods that use the updated driver version.


.. _nvd-troubleshooting:

***************
Troubleshooting
***************

If the driver daemon sets and pods are not running as you expect, perform the following steps.

#. Display the NVIDIA driver custom resources:

   .. code-block:: console

      $ kubectl get nvidiadrivers

   *Example Output*

   .. code-block:: output

      NAME           STATUS     AGE
      default        notReady   2023-10-13T14:03:24Z
      demo-precomp   notReady   2023-10-13T14:21:55Z

   It is normal for the status to report not ready shortly after modifying the resource.

#. If the status is not ready, describe the resource:

   .. code-block:: console

      $ kubectl describe nvidiadriver demo-precomp

   *Example Output*

   .. code-block:: output

      Name:         demo-precomp
      ...
        Version:          535.104.05
      Status:
        Conditions:
          Last Transition Time:  2023-10-13T14:33:30Z
          Message:
          Reason:                Error
          Status:                False
          Type:                  Ready
          Last Transition Time:  2023-10-13T14:33:30Z
          Message:               Waiting for driver pod to be ready
          Reason:                DriverNotReady
          Status:                True
          Type:                  Error
        State:                   notReady

#. Display the node selectors for the driver daemon sets.
   The selectors are set from the NVIDIA driver custom resources:

   .. code-block:: console

      $ kubectl get -n gpu-operator ds -l app.kubernetes.io/component=nvidia-driver

   *Example Output*

   .. code-block:: output

      NAME                                       DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                                                                                                                                                                                             AGE
      nvidia-gpu-driver-ubuntu20.04-788484b9bb   1         1         1       1            1           driver.config=silver,feature.node.kubernetes.io/system-os_release.ID=ubuntu,feature.node.kubernetes.io/system-os_release.VERSION_ID=20.04,nvidia.com/gpu.deploy.driver=true,nvidia.com/gpu.present=true   10m
      nvidia-gpu-driver-ubuntu22.04-8896c4bf7    2         2         2       2            2           driver.config=gold,feature.node.kubernetes.io/system-os_release.ID=ubuntu,feature.node.kubernetes.io/system-os_release.VERSION_ID=22.04,nvidia.com/gpu.deploy.driver=true,nvidia.com/gpu.present=true     10m

#. View the logs from the GPU Operator pod:

   .. code-block:: console

      $ kubectl logs -n gpu-operator deployment/gpu-operator

   *Example Output*

   .. code-block:: json

      {"level":"info","ts":1697223780.333307,"logger":"controllers.Upgrade","msg":"Node hosting a driver pod","node":"worker-2","state":"upgrade-done"}
      {"level":"info","ts":1697223780.3376482,"logger":"controllers.Upgrade","msg":"Node hosting a driver pod","node":"worker-1","state":"upgrade-done"}
      {"level":"info","ts":1697223780.345211,"logger":"controllers.Upgrade","msg":"Node hosting a driver pod","node":"worker-0","state":"upgrade-done"}
      {"level":"error","ts":1697223780.3452845,"logger":"controllers.Upgrade","msg":"Failed to build node upgrade state for pod","pod":{"namespace":"gpu-operator","name":"nvidia-gpu-driver-ubuntu22.04-6d4df6b96f-c6hfd"},"error":"unable to get node : resource name may not be empty"}
