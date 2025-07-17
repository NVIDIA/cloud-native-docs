.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

##########################
NVIDIA DRA Driver for GPUs
##########################


************
Installation
************

Prerequisites
=============

- Kubernetes v1.32 or newer.
- DRA and corresponding API groups must be enabled (`see Kubernetes docs <https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/#enabling-dynamic-resource-allocation>`_).
- GPU Driver 565 or later.
- NVIDIA's GPU Operator v25.3.0 or later, installed with CDI enabled (use the ``--set cdi.enabled=true`` commandline argument during ``helm install``). For reference, please refer to the GPU Operator `installation documentation <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#common-chart-customization-options>`__.

..
  For convenience, the following example shows how to enable CDI upon GPU Operator installation:
  .. code-block:: console
      $ helm install --wait --generate-name \
          -n gpu-operator --create-namespace \
          nvidia/gpu-operator \
          --version=${version} \
          --set cdi.enabled=true

.. note::

  If you want to use ComputeDomains and a pre-installed NVIDIA GPU Driver:

  - Make sure to have the corresponding ``nvidia-imex-*`` packages installed.
  - Disable the IMEX systemd service before installing the GPU Operator.
  - Refer to the `docs on installing the GPU Operator with a pre-installed GPU driver <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#pre-installed-nvidia-gpu-drivers>`__.


Configure and Helm-install the driver
=====================================

#. Add the NVIDIA Helm repository:

   .. code-block:: console

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
          && helm repo update

#. Install the driver, providing install-time configuration parameters. Example:

   .. code-block:: console

      $ helm install nvidia-dra-driver-gpu nvidia/nvidia-dra-driver-gpu \
            --version="25.3.0" \
            --create-namespace \
            --namespace nvidia-dra-driver-gpu \
            --set nvidiaDriverRoot=/run/nvidia/driver \
            --set resources.gpus.enabled=false

All install-time configuration parameters can be listed by running ``helm show values nvidia/nvidia-dra-driver-gpu``.

.. note::

  - A common mode of operation for now is to enable only the ComputeDomain subsystem (to have GPUs allocated using the traditional device plugin). The example above achieves that by setting ``resources.gpus.enabled=false``.
  - Setting  ``nvidiaDriverRoot=/run/nvidia/driver`` above expects a GPU Operator-provided GPU driver. That configuration parameter must be changed in case the GPU driver is installed straight on the host (typically at ``/``, which is the default value for ``nvidiaDriverRoot``).
  - In a future release, NVIDIA's DRA Driver for GPUs will be bundled with the NVIDIA GPU Operator (and does not need to be installed as a separate Helm chart anymore).


Validate installation
=====================

We recommend to perform validation steps to confirm that your setup works as expected.
To that end, we have prepared separate documentation:

- `Testing ComputeDomain allocation <https://github.com/NVIDIA/k8s-dra-driver-gpu/wiki/Validate-setup-for-ComputeDomain-allocation>`_
- [TODO] Testing GPU allocation
