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

.. Date: Nov 25 2020
.. Author: pramarao

.. _install-gpu-operator:

Install NVIDIA GPU Operator
=============================

Install Helm
-------------

The preferred method to deploy the GPU Operator is using ``helm``.

.. code-block:: console

   $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
      && chmod 700 get_helm.sh \
      && ./get_helm.sh

Now, add the NVIDIA Helm repository:

.. code-block:: console

   $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
      && helm repo update

Install the GPU Operator
--------------------------

The GPU Operator Helm chart offers a number of customizable options that can be configured depending on your environment.

.. blockdiag::

   blockdiag admin {
      A [label = "Install Helm", color = "#00CC00"];
      B [label = "Customize options \n in Helm chart"];
      C [label = "Use Helm to deploy \n the GPU Operator", color = pink];

      A -> B;
      B -> C;
   }

.. _gpu-operator-helm-chart-options:

Chart Customization Options
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following options are available when using the Helm chart. These options can be used with ``--set`` when installing via Helm.

.. list-table::
   :widths: 20 50 30
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``cdi.enabled``
     - When set to ``true``, the Operator installs two additional runtime classes,
       nvidia-cdi and nvidia-legacy, and enables the use of the Container Device Interface (CDI)
       for making GPUs accessible to containers.
       Using CDI aligns the Operator with the recent efforts to standardize how complex devices like GPUs
       are exposed to containerized environments.

       Pods can specify ``spec.runtimeClassName`` as ``nvidia-cdi`` to use the functionality or
       specify ``nvidia-legacy`` to prevent using CDI to perform device injection.
     - ``false``

   * - ``cdi.default``
     - When set to ``true``, the container runtime uses CDI to perform device injection by default.
     - ``false``

   * - ``daemonsets.annotations``
     - Map of custom annotations to add to all GPU Operator managed pods.
     - ``{}``

   * - ``daemonsets.labels``
     - Map of custom labels to add to all GPU Operator managed pods.
     - ``{}``

   * - ``driver.enabled``
     - By default, the Operator deploys NVIDIA drivers as a container on the system.
       Set this value to ``false`` when using the Operator on systems with pre-installed drivers.
     - ``true``

   * - ``driver.repository``
     - The images are downloaded from NGC. Specify another image repository when using
       custom driver images.
     - ``nvcr.io/nvidia``

   * - ``driver.rdma.enabled``
     - Controls whether the driver daemonset should build and load the ``nvidia-peermem`` kernel module.
     - ``false``

   * - ``driver.rdma.useHostMofed``
     - Indicate if MOFED is directly pre-installed on the host. This is used to build and load ``nvidia-peermem`` kernel module.
     - ``false``

   * - ``driver.startupProbe``
     - By default, the driver container has an initial delay of ``60s`` before starting liveness probes.
       The probe runs the ``nvidia-smi`` command with a timeout duration of ``60s``.
       You can increase the ``timeoutSeconds`` duration if the ``nvidia-smi`` command
       runs slowly in your cluster.
     - ``60s``

   * - ``driver.usePrecompiled``
     - When set to ``true``, the Operator attempts to deploy driver containers that have
       precompiled kernel drivers.
       This option is available as a technology preview feature for select operating systems.
       Refer to the :doc:`precompiled driver containers <precompiled-drivers>` page for the supported operating systems.
     - ``false``

   * - ``driver.version``
     - Version of the NVIDIA datacenter driver supported by the Operator.

       If you set ``driver.usePrecompiled`` to ``true``, then set this field to
       a driver branch, such as ``525``.
     - Depends on the version of the Operator. See the Component Matrix
       for more information on supported drivers.

   * - ``mig.strategy``
     - Controls the strategy to be used with MIG on supported NVIDIA GPUs. Options
       are either ``mixed`` or ``single``.
     - ``single``

   * - ``migManager.enabled``
     - The MIG manager watches for changes to the MIG geometry and applies reconfiguration as needed. By
       default, the MIG manager only runs on nodes with GPUs that support MIG (for e.g. A100).
     - ``true``

   * - ``nfd.enabled``
     - Deploys Node Feature Discovery plugin as a daemonset.
       Set this variable to ``false`` if NFD is already running in the cluster.
     - ``true``

   * - ``operator.defaultRuntime``
     - **DEPRECATED as of v1.9**
     - ``docker``

   * - ``psp.enabled``
     - The GPU operator deploys ``PodSecurityPolicies`` if enabled.
     - ``false``

   * - ``toolkit.enabled``
     - By default, the Operator deploys the NVIDIA Container Toolkit (``nvidia-docker2`` stack)
       as a container on the system. Set this value to ``false`` when using the Operator on systems
       with pre-installed NVIDIA runtimes.
     - ``true``

   * - ``operator.defaultRuntime``
     - **DEPRECATED as of v1.9**
     - ``docker``

   * - ``operator.labels``
     - Map of custom labels that will be added to all GPU Operator managed pods.
     - ``{}``

   * - ``psp.enabled``
     - The GPU operator deploys ``PodSecurityPolicies`` if enabled.
     - ``false``

   * - ``toolkit.enabled``
     - By default, the Operator deploys the NVIDIA Container Toolkit (``nvidia-docker2`` stack)
       as a container on the system. Set this value to ``false`` when using the Operator on systems
       with pre-installed NVIDIA runtimes.
     - ``true``


Namespace
^^^^^^^^^

Prior to GPU Operator v1.9, the operator was installed in the ``default`` namespace while all operands were
installed in the ``gpu-operator-resources`` namespace.

Starting with GPU Operator v1.9, both the operator and operands get installed in the same namespace.
The namespace is configurable and is determined during installation. For example, to install the GPU Operator
in the ``gpu-operator`` namespace:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator

If a namespace is not specified during installation, all GPU Operator components will be installed in the
``default`` namespace.

Operands
^^^^^^^^

By default, the GPU Operator operands are deployed on all GPU worker nodes in the cluster.
GPU worker nodes are identified by the presence of the label ``feature.node.kubernetes.io/pci-10de.present=true``,
where ``0x10de`` is the PCI vendor ID assigned to NVIDIA.

To disable operands from getting deployed on a GPU worker node, label the node with ``nvidia.com/gpu.deploy.operands=false``.

.. code-block:: console

   $ kubectl label nodes $NODE nvidia.com/gpu.deploy.operands=false


Common Deployment Scenarios
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this section, we present some common deployment recipes when using the Helm chart to install the GPU Operator.


Bare-metal/Passthrough with default configurations on Ubuntu
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

In this scenario, the default configuration options are used:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator

.. note::

   * For installing on Secure Boot systems or using Precompiled modules refer to :ref:`install-precompiled-signed-drivers`.


Bare-metal/Passthrough with default configurations on Red Hat Enterprise Linux
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

In this scenario, the default configuration options are used:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator

.. note::

   * When using RHEL8 with Kubernetes, SELinux has to be enabled (either in permissive or enforcing mode) for use with the GPU Operator. Additionally, network restricted environments are not supported.

Bare-metal/Passthrough with default configurations on CentOS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

In this scenario, the CentOS toolkit image is used:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set toolkit.version=1.7.1-centos7

.. note::

   * For CentOS 8 systems, use `toolkit.version=1.7.1-centos8`.
   * Replace `1.7.1` toolkit version used here with the latest one available `here <https://ngc.nvidia.com/catalog/containers/nvidia:k8s:container-toolkit/tags>`_.

----

NVIDIA vGPU
""""""""""""

.. note::

   The GPU Operator with NVIDIA vGPUs requires additional steps to build a private driver image prior to install.
   Refer to the document :ref:`install-gpu-operator-vgpu` for detailed instructions on the workflow and required values of
   the variables used in this command.

The command below will install the GPU Operator with its default configuration for vGPU:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set driver.repository=$PRIVATE_REGISTRY \
        --set driver.version=$VERSION \
        --set driver.imagePullSecrets={$REGISTRY_SECRET_NAME} \
        --set driver.licensingConfig.configMapName=licensing-config

----

NVIDIA AI Enterprise
"""""""""""""""""""""

Refer to :ref:`GPU Operator with NVIDIA AI Enterprise <install-gpu-operator-nvaie>`.


----

Bare-metal/Passthrough with pre-installed NVIDIA drivers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

In this example, the user has already pre-installed NVIDIA drivers as part of the system image:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set driver.enabled=false

----

.. _preinstalled-drivers-and-toolkit:

Bare-metal/Passthrough with pre-installed drivers and NVIDIA Container Toolkit
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

In this example, the user has already pre-installed the NVIDIA drivers and NVIDIA Container Toolkit (``nvidia-docker2``)
as part of the system image.

.. note::

  These steps should be followed when using the GPU Operator v1.9+ on DGX A100 systems with DGX OS 5.1+.

Before installing the operator, ensure that the following configurations are modified depending on the container runtime configured in your cluster.

Docker:

  * Update the Docker configuration to add ``nvidia`` as the default runtime. The ``nvidia`` runtime should
    be setup as the default container runtime for Docker on GPU nodes. This can be done by adding the
    ``default-runtime`` line into the Docker daemon config file, which is usually located on the system
    at ``/etc/docker/daemon.json``:

    .. code-block:: console

      {
          "default-runtime": "nvidia",
          "runtimes": {
              "nvidia": {
                  "path": "/usr/bin/nvidia-container-runtime",
                  "runtimeArgs": []
            }
          }
      }

    Restart the Docker daemon to complete the installation after setting the default runtime:

    .. code-block:: console

      $ sudo systemctl restart docker

Containerd:

  * Update ``containerd`` to use ``nvidia`` as the default runtime and add ``nvidia`` runtime configuration.
    This can be done by adding below config to ``/etc/containerd/config.toml`` and restarting ``containerd`` service.

    .. code-block:: console

      version = 2
      [plugins]
        [plugins."io.containerd.grpc.v1.cri"]
          [plugins."io.containerd.grpc.v1.cri".containerd]
            default_runtime_name = "nvidia"

            [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
              [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
                privileged_without_host_devices = false
                runtime_engine = ""
                runtime_root = ""
                runtime_type = "io.containerd.runc.v2"
                [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
                  BinaryName = "/usr/bin/nvidia-container-runtime"

    Restart the Containerd daemon to complete the installation after setting the default runtime:

    .. code-block:: console

      $ sudo systemctl restart containerd


Install the GPU operator with the following options:

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --set driver.enabled=false \
         --set toolkit.enabled=false

----

Bare-metal/Passthrough with pre-installed NVIDIA Container Toolkit (but no drivers)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

In this example, the user has already pre-installed the NVIDIA Container Toolkit (``nvidia-docker2``) as part of the system image.

Before installing the operator, ensure that the following configurations are modified depending on the container runtime configured in your cluster.

Docker:

  * Update the Docker configuration to add ``nvidia`` as the default runtime. The ``nvidia`` runtime should
    be setup as the default container runtime for Docker on GPU nodes. This can be done by adding the
    ``default-runtime`` line into the Docker daemon config file, which is usually located on the system
    at ``/etc/docker/daemon.json``:

    .. code-block:: console

      {
          "default-runtime": "nvidia",
          "runtimes": {
              "nvidia": {
                  "path": "/usr/bin/nvidia-container-runtime",
                  "runtimeArgs": []
            }
          }
      }

    Restart the Docker daemon to complete the installation after setting the default runtime:

    .. code-block:: console

      $ sudo systemctl restart docker

Containerd:

  * Update ``containerd`` to use ``nvidia`` as the default runtime and add ``nvidia`` runtime configuration.
    This can be done by adding below config to ``/etc/containerd/config.toml`` and restarting ``containerd`` service.

    .. code-block:: console

      version = 2
      [plugins]
        [plugins."io.containerd.grpc.v1.cri"]
          [plugins."io.containerd.grpc.v1.cri".containerd]
            default_runtime_name = "nvidia"

            [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
              [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
                privileged_without_host_devices = false
                runtime_engine = ""
                runtime_root = ""
                runtime_type = "io.containerd.runc.v2"
                [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
                  BinaryName = "/usr/bin/nvidia-container-runtime"

    Restart the Containerd daemon to complete the installation after setting the default runtime:

    .. code-block:: console

      $ sudo systemctl restart containerd


Configure toolkit to use the ``root`` directory of the driver installation as ``/run/nvidia/driver``, which is the path mounted by driver container.

  .. code-block:: console

    $ sudo sed -i 's/^#root/root/' /etc/nvidia-container-runtime/config.toml


Once these steps are complete, now install the GPU operator with the following options (which will provision a driver):

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set toolkit.enabled=false

----

Custom driver image (based off a specific driver version)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

If you want to use custom driver container images (for e.g. using 465.27), then
you would need to build a new driver container image. Follow these steps:

- Rebuild the driver container by specifying the ``$DRIVER_VERSION`` argument when building the Docker image. For
  reference, the driver container Dockerfiles are available on the Git repo `here <https://gitlab.com/nvidia/container-images/driver>`_
- Build the container using the appropriate Dockerfile. For example:

  .. code-block:: console

    $ docker build --pull -t \
        --build-arg DRIVER_VERSION=455.28 \
        nvidia/driver:455.28-ubuntu20.04 \
        --file Dockerfile .

  Ensure that the driver container is tagged as shown in the example by using the ``driver:<version>-<os>`` schema.
- Specify the new driver image and repository by overriding the defaults in
  the Helm install command. For example:

  .. code-block:: console

     $ helm install --wait --generate-name \
          -n gpu-operator --create-namespace \
          nvidia/gpu-operator \
          --set driver.repository=docker.io/nvidia \
          --set driver.version="465.27"

Note that these instructions are provided for reference and evaluation purposes.
Not using the standard releases of the GPU Operator from NVIDIA would mean limited
support for such custom configurations.

.. _custom-runtime-options:

----

Custom configuration for runtime ``containerd``
"""""""""""""""""""""""""""""""""""""""""""""""""""""

When `containerd` is the container runtime used, the following configuration
options are used with the container-toolkit deployed with GPU Operator:

.. code-block:: yaml

   toolkit:
      env:
      - name: CONTAINERD_CONFIG
        value: /etc/containerd/config.toml
      - name: CONTAINERD_SOCKET
        value: /run/containerd/containerd.sock
      - name: CONTAINERD_RUNTIME_CLASS
        value: nvidia
      - name: CONTAINERD_SET_AS_DEFAULT
        value: true

These options are defined as follows:

   - **CONTAINERD_CONFIG** : The path on the host to the ``containerd`` config
      you would like to have updated with support for the ``nvidia-container-runtime``.
      By default this will point to ``/etc/containerd/config.toml`` (the default
      location for ``containerd``). It should be customized if your ``containerd``
      installation is not in the default location.

   - **CONTAINERD_SOCKET** : The path on the host to the socket file used to
      communicate with ``containerd``. The operator will use this to send a
      ``SIGHUP`` signal to the ``containerd`` daemon to reload its config. By
      default this will point to ``/run/containerd/containerd.sock``
      (the default location for ``containerd``). It should be customized if
      your ``containerd`` installation is not in the default location.

   - **CONTAINERD_RUNTIME_CLASS** : The name of the
      `Runtime Class <https://kubernetes.io/docs/concepts/containers/runtime-class>`_
      you would like to associate with the ``nvidia-container-runtime``.
      Pods launched with a ``runtimeClassName`` equal to CONTAINERD_RUNTIME_CLASS
      will always run with the ``nvidia-container-runtime``. The default
      CONTAINERD_RUNTIME_CLASS is ``nvidia``.

   - **CONTAINERD_SET_AS_DEFAULT** : A flag indicating whether you want to set
      ``nvidia-container-runtime`` as the default runtime used to launch all
      containers. When set to false, only containers in pods with a ``runtimeClassName``
      equal to CONTAINERD_RUNTIME_CLASS will be run with the ``nvidia-container-runtime``.
      The default value is ``true``.

For using with RKE2 (Rancher Kubernetes Engine 2) or K3s following settings needs to be set in `ClusterPolicy`.

.. code-block:: yaml

   toolkit:
      env:
      - name: CONTAINERD_CONFIG
        value: /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl
      - name: CONTAINERD_SOCKET
        value: /run/k3s/containerd/containerd.sock
      - name: CONTAINERD_RUNTIME_CLASS
        value: nvidia
      - name: CONTAINERD_SET_AS_DEFAULT
        value: "true"

These options can be passed to GPU Operator during install time as below.

.. code-block:: console

  helm install -n gpu-operator --create-namespace \
    nvidia/gpu-operator $HELM_OPTIONS \
      --set toolkit.env[0].name=CONTAINERD_CONFIG \
      --set toolkit.env[0].value=/var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl \
      --set toolkit.env[1].name=CONTAINERD_SOCKET \
      --set toolkit.env[1].value=/run/k3s/containerd/containerd.sock \
      --set toolkit.env[2].name=CONTAINERD_RUNTIME_CLASS \
      --set toolkit.env[2].value=nvidia \
      --set toolkit.env[3].name=CONTAINERD_SET_AS_DEFAULT \
      --set-string toolkit.env[3].value=true

----

Proxy Environments
""""""""""""""""""""""""""

Refer to the section :ref:`install-gpu-operator-proxy` for more information on how to install the Operator on clusters
behind a HTTP proxy.

----

Air-gapped Environments
""""""""""""""""""""""""""

Refer to the section :ref:`install-gpu-operator-air-gapped` for more information on how to install the Operator
in air-gapped environments.

----

Multi-Instance GPU (MIG)
""""""""""""""""""""""""""

Refer to the document :ref:`install-gpu-operator-mig` for more information on how use the Operator with Multi-Instance GPU (MIG)
on NVIDIA Ampere products. For guidance on configuring MIG support for the **NVIDIA GPU Operator** in an OpenShift Container Platform cluster, see the `user guide <https://docs.nvidia.com/datacenter/cloud-native/openshift/mig-ocp.html>`_.

----

KubeVirt / OpenShift Virtualization
""""""""""""""""""""""""""""""""""""

Refer to the document :ref:`gpu-operator-kubevirt` for more information on how to use the GPU Operator to provision GPU nodes for running KubeVirt virtual machines with access to GPU.
For guidance on using the GPU Operator with OpenShift Virtualization, refer to the document :ref:`nvidia-gpu-operator-openshift-virtualization-vgpu-enablement`.

Outdated Kernels
""""""""""""""""""""""""""

Refer to the section :ref:`install-gpu-operator-outdated-kernels` for more information on how to install the Operator successfully
when nodes in the cluster are not running the latest kernel

----

Verify GPU Operator Install
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Once the Helm chart is installed, check the status of the pods to ensure all the containers are running and the validation is complete:

.. code-block:: console

   $ kubectl get pods -n gpu-operator

.. code-block:: console

   NAME                                                          READY   STATUS      RESTARTS   AGE
   gpu-feature-discovery-crrsq                                   1/1     Running     0          60s
   gpu-operator-7fb75556c7-x8spj                                 1/1     Running     0          5m13s
   gpu-operator-node-feature-discovery-master-58d884d5cc-w7q7b   1/1     Running     0          5m13s
   gpu-operator-node-feature-discovery-worker-6rht2              1/1     Running     0          5m13s
   gpu-operator-node-feature-discovery-worker-9r8js              1/1     Running     0          5m13s
   nvidia-container-toolkit-daemonset-lhgqf                      1/1     Running     0          4m53s
   nvidia-cuda-validator-rhvbb                                   0/1     Completed   0          54s
   nvidia-dcgm-5jqzg                                             1/1     Running     0          60s
   nvidia-dcgm-exporter-h964h                                    1/1     Running     0          60s
   nvidia-device-plugin-daemonset-d9ntc                          1/1     Running     0          60s
   nvidia-device-plugin-validator-cm2fd                          0/1     Completed   0          48s
   nvidia-driver-daemonset-5xj6g                                 1/1     Running     0          4m53s
   nvidia-mig-manager-89z9b                                      1/1     Running     0          4m53s
   nvidia-operator-validator-bwx99                               1/1     Running     0          58s

We can now proceed to running some sample GPU workloads to verify that the Operator (and its components) are working correctly.

