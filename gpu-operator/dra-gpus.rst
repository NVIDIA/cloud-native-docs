.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

##########################
NVIDIA DRA Driver for GPUs
##########################

**************
GPU allocation
**************

Compared to `traditional <https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/>`_ GPU allocation using undifferentiated count-based requests (such as ``nvidia.com/gpu: 1``), the GPU allocation side of this driver enables fine-grained control and powerful features long desired by the community, such as:

#. Controlled sharing of individual GPUs between multiple pods and/or containers.
#. GPU selection via complex constraints expressed via `CEL <https://kubernetes.io/docs/reference/using-api/cel/>`_.
#. Dynamic partitioning.

To learn more about this part of the driver and about what we are planning to build in the future, have a look at `these release notes <https://github.com/NVIDIA/k8s-dra-driver-gpu/releases/tag/v25.3.0-rc.3>`_.

While the GPU allocation features of this driver can be tried out, they are not yet officially supported.
Hence, the GPU kubelet plugin is currently disabled by default in the Helm chart installation.

For documentation on how to use and test the current set of GPU allocation features, please head over to the `demo section <https://github.com/NVIDIA/k8s-dra-driver-gpu?tab=readme-ov-file#a-kind-demo>`_ of the driver's README and to its `quickstart directory <https://github.com/NVIDIA/k8s-dra-driver-gpu/tree/main/demo/specs/quickstart>`_.

.. note::
  This part of the NVIDIA DRA Driver for GPUs is in **Technology Preview**.
  They are not yet supported in production environments and are not functionally complete.
  Technology Preview features provide early access to upcoming product features, enabling customers to test functionality and provide feedback during the development process.
  These releases may not have full documentation, and testing is limited.

