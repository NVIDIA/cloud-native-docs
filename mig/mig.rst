.. Date: April 26 2021
.. Author: pramarao

.. headings (h1/h2/h3/h4/h5) are # * - =

.. _mig-landing:

####################
Multi-Instance GPU
####################

*************
Introduction
*************

The new Multi-Instance GPU (MIG) feature allows GPUs based on the NVIDIA Ampere architecture 
(such as NVIDIA A100) to be securely partitioned into up to seven separate GPU Instances for 
CUDA applications, providing multiple users with separate GPU resources for optimal GPU 
utilization. This feature is particularly beneficial for workloads that do not fully saturate 
the GPU’s compute capacity and therefore users may want to run different workloads in parallel 
to maximize utilization.

Refer to the `MIG User Guide <https://docs.nvidia.com/datacenter/tesla/mig-user-guide/index.html>`_ 
for more details on the technical concepts, setting up and using MIG on NVIDIA Ampere GPUs. 


