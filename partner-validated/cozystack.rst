.. headings # #, * *, =, -, ^, "

.. |prod-name-long| replace:: Cozystack
.. |prod-name-short| replace:: Cozystack

#############################################
|prod-name-long| with the NVIDIA GPU Operator
#############################################


*********************************************
About |prod-name-short| with the GPU Operator
*********************************************

|prod-name-short| is a CNCF project and a free, open source platform for building public
and private clouds on bare metal. It provides multi-tenant Kubernetes clusters, virtual
machines, and managed databases from a single control plane, so a provider can hand each
tenant an isolated, self-service environment without operating a separate stack per tenant.

|prod-name-short| is a Certified Kubernetes distribution. Refer to the
`CNCF Certified Kubernetes conformance submission <https://github.com/cncf/k8s-conformance/tree/main/v1.35/cozystack>`__
for Kubernetes v1.35.

|prod-name-short| ships the NVIDIA GPU Operator as a platform package,
``cozystack.gpu-operator``. The package deploys the Kubernetes device plugin, node labeling
with GPU Feature Discovery, DCGM-based monitoring, and the operator validator, so GPUs on
|prod-name-short| nodes are exposed to workloads as the ``nvidia.com/gpu`` resource.

For more information about |prod-name-short|, refer to the
`Cozystack documentation <https://cozystack.io/docs/>`__.


******************************
Validated Configuration Matrix
******************************

|prod-name-long| has self-validated with the following components and versions:

.. list-table::
   :header-rows: 1

   * - Version
     - | NVIDIA
       | GPU
       | Operator
     - | Operating
       | System
     - | Container
       | Runtime
     - Kubernetes
     - Helm
     - NVIDIA GPU
     - Hardware Model
     - | Date
       | Validated

   * - Cozystack v1.6.4
     - v26.3.1
     - | Ubuntu 24.04
     - containerd 2.2.7 with the NVIDIA Container Toolkit 1.20.1
     - 1.35
     - Helm v3
     - | 1x NVIDIA RTX PRO 4000 Blackwell SFF Edition 24GB
     - | ASUS PRIME B760M-A D4

       | 1x Intel Core i5-13500, 14 cores, 2.5 GHz

       | 64 GB DDR4

       | 2x 512 GB NVMe SSD
     - October 2026


*************
Prerequisites
*************

* A running |prod-name-short| installation on bare metal. A single node that runs both the
  control plane and GPU workloads is sufficient.

* At least one worker node with an NVIDIA GPU physically installed, so that the GPU Operator
  can discover the GPU and label the node.

* The NVIDIA driver and the NVIDIA Container Toolkit are pre-installed on the Ubuntu host.
  The GPU Operator runs with ``driver.enabled=false`` and ``toolkit.enabled=false`` and does
  not deploy its own driver or toolkit containers. The validated host used the
  ``nvidia-driver-580-server-open`` driver, version 580.178.04.

* containerd on the GPU node uses the ``nvidia`` runtime as its default runtime.

* ``kubectl`` access to the cluster where you install the GPU Operator.

* The GPU Operator is installed into the root |prod-name-short| cluster and serves
  containerized workloads that run on the cluster nodes.


*********
Procedure
*********

#. On the GPU node, install the NVIDIA driver and the NVIDIA Container Toolkit, and install
   the ``linux-generic`` metapackage so that kernel updates also pull in the matching
   ``linux-modules-extra`` package:

   .. code-block:: console

      $ sudo ubuntu-drivers install --gpgpu nvidia:580-server-open
      $ sudo apt-get install -y linux-generic nvidia-utils-580-server nvidia-container-toolkit

   Reboot the node and confirm that ``nvidia-smi`` lists the GPU.

#. Make ``nvidia`` the default containerd runtime on the node and restart the container
   runtime. For example, with ``nvidia-ctk``:

   .. code-block:: console

      $ sudo nvidia-ctk runtime configure --runtime=containerd --set-as-default
      $ sudo systemctl restart containerd

#. Install the GPU Operator by creating the ``cozystack.gpu-operator`` package with the
   ``container`` variant. This variant disables the operator driver and toolkit containers:

   .. code-block:: yaml

      apiVersion: cozystack.io/v1alpha1
      kind: Package
      metadata:
        name: cozystack.gpu-operator
      spec:
        variant: container

   .. code-block:: console

      $ kubectl apply -f gpu-operator-container.yaml

#. Verify that the operator pods are running and that the node advertises the GPU:

   .. code-block:: console

      $ kubectl get pods -n cozy-gpu-operator
      $ kubectl get node <node-name> -o jsonpath='{.status.allocatable.nvidia\.com/gpu}'

*************************************************
Verifying |prod-name-short| with the GPU Operator
*************************************************

Refer to :external+gpuop:ref:`running sample gpu applications` to verify the installation.


***************
Getting Support
***************

End users receive support from Ænix.

* Documentation: https://cozystack.io/docs/
* Issues: https://github.com/cozystack/cozystack/issues
* Community: `#cozystack on Kubernetes Slack
  <https://kubernetes.slack.com/archives/C06L3CPRVN1>`_ (invite: https://slack.k8s.io)
* Commercial support: info@aenix.io


*******************
Related Information
*******************

* https://cozystack.io/
* https://github.com/cozystack/cozystack
* https://github.com/cncf/k8s-conformance/tree/main/v1.35/cozystack
