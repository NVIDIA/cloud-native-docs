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

   $ helm repo add nvidia https://nvidia.github.io/gpu-operator \
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

Chart Customization Options
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following options are available when using the Helm chart. These options can be used with ``--set`` when installing via Helm.

.. list-table::
   :widths: auto
   :header-rows: 1
   :align: center

   * - Parameter
     - Description
     - Default

   * - ``nfd.enabled``
     - Deploys Node Feature Discovery plugin as a daemonset. 
       Set this variable to ``false`` if NFD is already running in the cluster.
     - ``true``

   * - ``operator.defaultRuntime``
     - By default, the operator assumes your Kubernetes deployment is running with 
       ``docker`` as its container runtime. Other values are either ``crio`` 
       (for CRI-O) or ``containerd`` (for **containerd**).      
     - ``docker``

   * - ``mig.strategy``
     - Controls the strategy to be used with MIG on supported NVIDIA GPUs. Options 
       are either ``mixed`` or ``single``.
     - ``single``

   * - ``psp.enabled``
     - The GPU operator deploys ``PodSecurityPolicies`` if enabled.
     - ``false``     

   * - ``driver.enabled``
     - By default, the Operator deploys NVIDIA drivers as a container on the system. 
       Set this value to ``false`` when using the Operator on systems with pre-installed drivers.
     - ``true``

   * - ``driver.repository``
     - The images are downloaded from NGC. Specify another image repository when using 
       custom driver images.
     - ``nvcr.io/nvidia``

   * - ``driver.version``
     - Version of the NVIDIA datacenter driver supported by the Operator.
     - Depends on the version of the Operator. See the Component Matrix 
       for more information on supported drivers.
   
   * - ``toolkit.enabled``
     - By default, the Operator deploys the NVIDIA Container Toolkit (``nvidia-docker2`` stack) 
       as a container on the system. Set this value to ``false`` when using the Operator on systems 
       with pre-installed NVIDIA runtimes.
     - ``true``
  
   * - ``migManager.enabled``
     - The MIG manager watches for changes to the MIG geometry and applies reconfiguration as needed. By 
       default, the MIG manager only runs on nodes with GPUs that support MIG (for e.g. A100).
     - ``true``


Common Deployment Scenarios
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this section, we present some common deployment recipes when using the Helm chart to install the GPU Operator. 

Bare-metal/Passthrough with default configurations
""""""""""""""""""""""""""""""""""""""""""""""""""""

In this scenario, the default configuration options are used:

.. code-block:: console

   $ helm install --wait --generate-name \
        nvidia/gpu-operator

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
        nvidia/gpu-operator --set driver.repository=$PRIVATE_REGISTRY \
        --set driver.version=$VERSION \
        --set driver.imagePullSecrets={$REGISTRY_SECRET_NAME} \
        --set driver.licensingConfig.configMapName=licensing-config

----

Bare-metal/Passthrough with with pre-installed NVIDIA drivers 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

In this example, the user has already pre-installed NVIDIA drivers as part of the system image:

.. code-block:: console

   $ helm install --wait --generate-name \
        nvidia/gpu-operator \
        --set driver.enabled=false

----

Bare-metal/Passthrough with with pre-installed NVIDIA Container Toolkit (but no drivers)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

In this example, the user has already pre-installed the NVIDIA Container Toolkit (``nvidia-docker2``) as part of the system image. 

Before installing the operator, ensure that the ``root`` directive of the container runtime configuration is changed: 

.. code-block:: console

   $ sudo sed -i 's/^#root/root/' /etc/nvidia-container-runtime/config.toml

Once that is done, now install the GPU operator with the following options (which will provision a driver):

.. code-block:: console

   $ helm install --wait --generate-name \
        nvidia/gpu-operator \
        --set toolkit.enabled=false    

----

Bare-metal/Passthrough with with pre-installed drivers and NVIDIA Container Toolkit
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

In this example, the user has already pre-installed the NVIDIA drivers and NVIDIA Container Toolkit (``nvidia-docker2``) 
as part of the system image. 

Install the GPU operator with the following options:

.. code-block:: console

   $ helm install --wait --generate-name \
         nvidia/gpu-operator \
         --set driver.enabled=false \
         --set toolkit.enabled=false 

----
         
Custom driver image (based off a specific driver version)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

If you want to use custom driver container images (for e.g. using 465.27), then 
you would need to build a new driver container image. Follow these steps:

- Modify the Dockerfile (for e.g. by specifying the driver version in the Ubuntu 20.04 
  container `here <https://gitlab.com/nvidia/container-images/driver/-/blob/master/ubuntu20.04/Dockerfile#L51>`_)
- Build the container (e.g. ``docker build --pull -t nvidia/driver:455.28-ubuntu20.04 --file Dockerfile .``). 
  Ensure that the driver container is tagged as shown in the example by using the ``driver:<version>-<os>`` schema. 
- Specify the new driver image and repository by overriding the defaults in 
  the Helm install command. For example: 

  .. code-block:: console

     $ helm install --wait --generate-name \
          nvidia/gpu-operator \
          --set driver.repository=docker.io/nvidia \
          --set driver.version="465.27"

Note that these instructions are provided for reference and evaluation purposes. 
Not using the standard releases of the GPU Operator from NVIDIA would mean limited 
support for such custom configurations.

----

Set the default container runtime as ``containerd``
"""""""""""""""""""""""""""""""""""""""""""""""""""""

In this example, we set the default container runtime to be used as ``containerd``. 

.. code-block:: console

   $ helm install --wait --generate-name \
        nvidia/gpu-operator \
        --set operator.defaultRuntime=containerd

When setting `containerd` as the `defaultRuntime` the following 
options are also available:

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

----

Air-gapped installations
""""""""""""""""""""""""""

Refer to the section :ref:`install-gpu-operator-air-gapped` for more information on how to install the Operator 
in air-gapped environments, including private registries.

----

Multi-Instance GPU (MIG)
""""""""""""""""""""""""""

Refer to the document :ref:`install-gpu-operator-mig` for more information on how use the Operator with Multi-Instance GPU (MIG) 
on NVIDIA Ampere products.

----

Verify GPU Operator Install
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Once the Helm chart is installed, check the status of the pods to ensure all the containers are running and the validation is complete:

.. code-block:: console

   $ kubectl get pods -A

.. code-block:: console
   
   NAMESPACE                NAME                                                          READY   STATUS      RESTARTS   AGE
   default                  gpu-operator-d6ccd4d8d-f7m57                                  1/1     Running     0          5m51s
   default                  gpu-operator-node-feature-discovery-master-867c4f7bfb-cbxck   1/1     Running     0          5m51s
   default                  gpu-operator-node-feature-discovery-worker-wv2rq              1/1     Running     0          5m51s
   gpu-operator-resources   gpu-feature-discovery-qmftl                                   1/1     Running     0          5m35s
   gpu-operator-resources   nvidia-container-toolkit-daemonset-tx4rd                      1/1     Running     0          5m35s
   gpu-operator-resources   nvidia-cuda-validator-ip-172-31-65-3                          0/1     Completed   0          2m29s
   gpu-operator-resources   nvidia-dcgm-exporter-99t8p                                    1/1     Running     0          5m35s
   gpu-operator-resources   nvidia-device-plugin-daemonset-nkbtz                          1/1     Running     0          5m35s
   gpu-operator-resources   nvidia-device-plugin-validator-ip-172-31-65-3                 0/1     Completed   0          103s
   gpu-operator-resources   nvidia-driver-daemonset-w97sh                                 1/1     Running     0          5m35s
   gpu-operator-resources   nvidia-operator-validator-2djn2                               1/1     Running     0          5m35s
   kube-system              calico-kube-controllers-b656ddcfc-4sgld                       1/1     Running     0          8m11s
   kube-system              calico-node-wzdbr                                             1/1     Running     0          8m11s
   kube-system              coredns-558bd4d5db-2w9tf                                      1/1     Running     0          8m11s
   kube-system              coredns-558bd4d5db-cv5md                                      1/1     Running     0          8m11s
   kube-system              etcd-ip-172-31-65-3                                           1/1     Running     0          8m25s
   kube-system              kube-apiserver-ip-172-31-65-3                                 1/1     Running     0          8m25s
   kube-system              kube-controller-manager-ip-172-31-65-3                        1/1     Running     0          8m25s
   kube-system              kube-proxy-gpqc5                                              1/1     Running     0          8m11s
   kube-system              kube-scheduler-ip-172-31-65-3                                 1/1     Running     0          8m25s
  
We can now proceed to running some sample GPU workloads to verify that the Operator (and its components) are working correctly.