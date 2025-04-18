.. headings # #, * *, =, -, ^, "

.. |prod-name-long| replace:: Mirantis k0RDENT
.. |prod-name-short| replace:: k0RDENT

#############################################
|prod-name-long| with the NVIDIA GPU Operator
#############################################


*********************************************
About |prod-name-short| with the GPU Operator
*********************************************

|prod-name-short| is as a "super control plane" designed to ensure the consistent provisioning and lifecycle
management of kubernetes clusters and the services that make them useful. The goal of the k0rdent project is
to provide platform engineers with the means to deliver a distributed container management environment (DCME) 
and enable them to compose unique internal developer platforms (IDP) to support a diverse range of complex 
modern application workloads.

The NVIDIA GPU Operator uses the operator framework within Kubernetes to automate
both the deployment and management of all NVIDIA software components needed to provision NVIDIA GPUs.
These components include the NVIDIA GPU drivers to enable CUDA, Kubernetes device plugin for GPUs,
the NVIDIA Container Toolkit, automatic node labeling using GFD, DCGM based monitoring and others.


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

   * - k0rdent 0.2.0 / k0s v1.31.5+k0s
     - v24.9.2
     - | Ubuntu 22.04
     - containerd v1.7.24  with the NVIDIA Container Toolkit v1.17.4
     - 1.31.5
     - Helm v3
     - | 2x NVIDIA RTX 4000 SFF Ada 20GB GDDR6 (ECC)
     - | Supermicro SuperServer 6028U-E1CNR4T+

       | 1000W Supermicro PWS-1K02A-1R

       | 2x Intel Xeon E5-2630v4, 10C/20T 2.2/3.1 GHz LGA 2011-3 25MB 85W

       | 32GB DDR4-2666 RDIMM, M393A4K40BB2-CTD6Q

       | NVMe 960GB PM983 NVMe M.2, MZ1LB960HAJQ-00007

       | 2 x NVIDIA RTX 4000 SFF Ada 20GB GDDR6 (ECC), 70W, PCIe 4.0x16, 4x

       | 4x Mini DisplayPort 1.4a


*************
Prerequisites
*************

* A running |prod-name-short| managed cluster with at least one control plane node and two worker nodes.
  The recommended configuration is at least three control plane nodes and at least two worker nodes.

* At least one worker node with an NVIDIA GPU physically installed.
  The GPU Operator can locate the GPU and label the node accordingly.

* The kubeconfig file for the |prod-name-short| managed cluster on the seed node.
  You can get the file from the |prod-name-short| control plane.

* You have access to the |prod-name-short| cluster.


*********
Procedure
*********

Perform the following steps to prepare the |prod-name-short| cluster:

#. Install template to k0rdent

   .. code-block:: console

      $ helm install gpu-operator oci://ghcr.io/k0rdent/catalog/charts/gpu-operator-service-template \
          --version 24.9.2 -n kcm-system

#. Verify service template:

   .. code-block:: console

      $ kubectl get servicetemplates -A

   *Example Output*

   .. code-block:: output

      NAMESPACE    NAME                          VALID
      kcm-system   gpu-operator-24-9-2           true

#. Deploy service template to child cluster

   .. code-block:: console

      apiVersion: k0rdent.mirantis.com/v1alpha1
      kind: MultiClusterService
      metadata:
        name: gpu-operator
      spec:
        clusterSelector:
          matchLabels:
            group: demo
      serviceSpec:
        services:
        - template: gpu-operator-24-9-2
          name: gpu-operator
          namespace: gpu-operator
          values: |
            operator:
              defaultRuntime: containerd
            toolkit:
              env:
                - name: CONTAINERD_CONFIG
                value: /etc/k0s/containerd.d/nvidia.toml
                - name: CONTAINERD_SOCKET
                value: /run/k0s/containerd.sock
                - name: CONTAINERD_RUNTIME_CLASS
                value: nvidia


The |prod-name-short| managed clusters will now have the NVIDIA GPU operator

*************************************************
Verifying |prod-name-short| with the GPU Operator
*************************************************

Refer to :external+gpuop:ref:`running sample gpu applications` to verify the installation.

***************
Getting Support
***************

Refer to the k0RDENT product documentation for information about working with k0RDENT.

*******************
Related information
*******************

* https://docs.k0rdent.io/v0.2.0/
