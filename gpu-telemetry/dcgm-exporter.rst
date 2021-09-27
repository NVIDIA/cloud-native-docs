.. Date: April 13 2021
.. Author: pramarao

.. _dcgm-exporter:

####################
DCGM-Exporter
####################

*************
Introduction
*************

`DCGM-Exporter <https://github.com/NVIDIA/dcgm-exporter>`_ is a tool based on the
Go APIs to `NVIDIA DCGM <https://developer.nvidia.com/dcgm>`_ that allows users to gather 
GPU metrics and understand workload behavior or monitor GPUs in clusters. `dcgm-exporter` is 
written in Go and exposes GPU metrics at an HTTP endpoint (``/metrics``) for monitoring solutions 
such as Prometheus. 

For information on the profiling metrics available from DCGM, refer to `this section <https://docs.nvidia.com/datacenter/dcgm/latest/dcgm-user-guide/feature-overview.html#profiling>`_ 
in the documentation. 

.. TODO: include a high-level diagram of the dcgm-exporter stack in Kubernetes

******************
Getting Started
******************

`dcgm-exporter` can be run as a standalone container or deployed as a 
daemonset on GPU nodes in a Kubernetes cluster. 

Since `dcgm-exporter` starts `nv-hostengine` as an embedded process (for collecting metrics), 
appropriate configuration options should be used if `dcgm-exporter` is run on systems (such as 
NVIDIA DGX) that have DCGM (or rather `nv-hostengine`) running. 

Running `dcgm-exporter`
-----------------------

The `dcgm-exporter` container can be run using a container engine such as Docker. In this mode, `dcgm-exporter` 
starts `nv-hostengine` as an embedded process and starts publishing metrics: 

.. code-block:: console

   $ DCGM_EXPORTER_VERSION=2.1.4-2.3.1 && \
   docker run -d --rm \
      --gpus all \
      --net host \
      --cap-add SYS_ADMIN \
      nvcr.io/nvidia/k8s/dcgm-exporter:${DCGM_EXPORTER_VERSION}-ubuntu20.04 \
      -f /etc/dcgm-exporter/dcp-metrics-included.csv

Retrieve the metrics: 

.. code-block:: console

   $ curl localhost:9400/metrics

.. code-block:: console

   # HELP DCGM_FI_DEV_SM_CLOCK SM clock frequency (in MHz).
   # TYPE DCGM_FI_DEV_SM_CLOCK gauge
   # HELP DCGM_FI_DEV_MEM_CLOCK Memory clock frequency (in MHz).
   # TYPE DCGM_FI_DEV_MEM_CLOCK gauge
   # HELP DCGM_FI_DEV_MEMORY_TEMP Memory temperature (in C).
   # TYPE DCGM_FI_DEV_MEMORY_TEMP gauge
   ...
   DCGM_FI_DEV_SM_CLOCK{gpu="0", UUID="GPU-604ac76c-d9cf-fef3-62e9-d92044ab6e52"} 139
   DCGM_FI_DEV_MEM_CLOCK{gpu="0", UUID="GPU-604ac76c-d9cf-fef3-62e9-d92044ab6e52"} 405
   DCGM_FI_DEV_MEMORY_TEMP{gpu="0", UUID="GPU-604ac76c-d9cf-fef3-62e9-d92044ab6e52"} 9223372036854775794
   ...   

Connecting to an existing DCGM agent
======================================

In this scenario, system images include DCGM and have `nv-hostengine` running already. Examples include 
the DGX systems that bundles drivers, DCGM, etc. in the system image. To avoid any compatibility issues, 
it is recommended to have `dcgm-exporter` connect to the existing `nv-hostengine` daemon to gather/publish 
GPU telemetry data.

.. warning:: 

   The `dcgm-exporter` container image includes a DCGM client library (``libdcgm.so``) to communicate with 
   `nv-hostengine`. In this deployment scenario we have `dcgm-exporter` (or rather ``libdcgm.so``) connect 
   to an existing `nv-hostengine` running on the host. The DCGM client library uses an internal protocol to exchange 
   information with `nv-hostengine`. To avoid any potential incompatibilities between the container image's DCGM client library 
   and the host's `nv-hostengine`, it is strongly recommended to use a version of DCGM on which `dcgm-exporter` is based is 
   greater than or equal to (but not less than) the version of DCGM running on the host. This can be easily determined by 
   comparing the version tags of the `dcgm-exporter` image and by running ``nv-hostengine --version`` on the host.

In this scenario, we use the ``-r`` option to connect to an existing `nv-hostengine` process:

.. code-block:: console

   $ DCGM_EXPORTER_VERSION=2.1.4-2.3.1 && 
   docker run -d --rm \
      --gpus all \
      --net host \
      --cap-add SYS_ADMIN \
      nvcr.io/nvidia/k8s/dcgm-exporter:${DCGM_EXPORTER_VERSION}-ubuntu20.04 \
      -r localhost:5555 -f /etc/dcgm-exporter/dcp-metrics-included.csv

*********************************
Multi-Instance GPU (MIG) Support
*********************************

The new Multi-Instance GPU (MIG) feature allows the GPUs based on the NVIDIA Ampere architecture to be 
securely partitioned into up to seven separate GPU Instances for CUDA applications, providing multiple users 
with separate GPU resources for optimal GPU utilization.

For more information on MIG, refer to the MIG `User Guide <https://docs.nvidia.com/datacenter/tesla/mig-user-guide/index.html>`_.

.. note::

   Support for MIG in `dcgm-exporter` was added starting with ``2.4.0-rc.2``. Replace the container image with this tag in the 
   command line examples above: ``2.1.8-2.4.0-rc.2-ubuntu20.04``. If you are connecting to an existing DCGM on the host system, 
   ensure that you upgrade to at least 2.1.8 on the host system.

`dcgm-exporter` publishes metrics for both the entire GPU as well as individual MIG devices (or GPU instances) 
as can be seen in the output below: 

.. code-block:: console

   DCGM_FI_DEV_SM_CLOCK{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 1215
   DCGM_FI_DEV_MEM_CLOCK{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 1215
   DCGM_FI_DEV_MEMORY_TEMP{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 69
   DCGM_FI_DEV_GPU_TEMP{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 61
   DCGM_FI_DEV_POWER_USAGE{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 409.692000
   DCGM_FI_DEV_TOTAL_ENERGY_CONSUMPTION{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 319159391
   DCGM_FI_DEV_PCIE_REPLAY_COUNTER{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 0
   DCGM_FI_DEV_XID_ERRORS{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 0
   DCGM_FI_DEV_FB_FREE{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 35690
   DCGM_FI_DEV_FB_USED{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 4845
   DCGM_FI_DEV_NVLINK_BANDWIDTH_TOTAL{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 0
   DCGM_FI_DEV_VGPU_LICENSE_STATUS{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 0
   DCGM_FI_PROF_GR_ENGINE_ACTIVE{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 0.995630
   DCGM_FI_PROF_PIPE_TENSOR_ACTIVE{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 0.929260
   DCGM_FI_PROF_DRAM_ACTIVE{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 0.690789
   DCGM_FI_PROF_PCIE_TX_BYTES{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 33011804
   DCGM_FI_PROF_PCIE_RX_BYTES{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",Hostname="ub20-a100-k8s"} 97863601

   DCGM_FI_DEV_XID_ERRORS{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",GPU_I_PROFILE="1g.5gb",GPU_I_ID="13",Hostname="ub20-a100-k8s"} 0
   DCGM_FI_PROF_GR_ENGINE_ACTIVE{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",GPU_I_PROFILE="1g.5gb",GPU_I_ID="13",Hostname="ub20-a100-k8s"} 0.995687
   DCGM_FI_PROF_PIPE_TENSOR_ACTIVE{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",GPU_I_PROFILE="1g.5gb",GPU_I_ID="13",Hostname="ub20-a100-k8s"} 0.930433
   DCGM_FI_PROF_DRAM_ACTIVE{gpu="0",UUID="GPU-34319582-d595-d1c7-d1d2-179bcfa61660",device="nvidia0",GPU_I_PROFILE="1g.5gb",GPU_I_ID="13",Hostname="ub20-a100-k8s"} 0.800339


For more information on the profiling metrics and how to interpret the metrics, refer to the `profiling metrics <https://docs.nvidia.com/datacenter/dcgm/latest/dcgm-user-guide/feature-overview.html#profiling>`_ 
section of the DCGM user guide.

****************************
GPU Telemetry in Kubernetes
****************************

Refer to the `DCGM-Exporter <https://docs.nvidia.com/datacenter/cloud-native/kubernetes/dcgme2e.html#gpu-telemetry>`_ documentation 
to get started with integrating GPU metrics into a Prometheus monitoring system.
