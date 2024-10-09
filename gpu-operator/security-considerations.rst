.. headings (h1/h2/h3/h4/h5) are # * = -

###############################################
Security Considerations for NVIDIA GPU Operator
###############################################

.. contents::
   :depth: 2
   :local:
   :backlinks: none


**************************************
Preventing Unprivileged Access to GPUs
**************************************

..
  k run --rm -it cuda --image=nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda11.7.1-ubuntu20.04 --restart=Never --override-type=strategic --overrides='{ "spec": { "containers": [{"name":"cuda", "resources": { "limits": { "nvidia.com/gpu": 2 } } }] }}' --command -- bash

A default installation of NVIDIA Container Toolkit and NVIDIA Device Plugin provides unprivileged containers with access to GPUs on a node when the pod specification does not specify resource limits or the container sets ``NVIDIA_VISIBLE_DEVICES``.
This behavior enables some pods such as NVIDIA DCGM Exporter to monitor all GPUs on a node without interfering with Kubernetes accounting for allocatable resources.
In addition, privileged containers always have access to all GPUs on a node.

Optionally, you can configure the toolkit and plugin to limit access for unprivileged containers.
The strategy is for the toolkit and plugin as follows:

- The toolkit ignores ``NVIDIA_VISIBLE_DEVICES``.
- The plugin produces a list of GPU devices as volume mounts, according to resource requests, and the toolkit accepts this list exclusively.

  An assumption is made that unprivileged containers are denied access to host mounts.

To configure these operands during Operator installation or upgrade, create a ``values.yaml`` file with contents like the following example:

.. code-block:: yaml

   toolkit:
     env:
     - name: ACCEPT_NVIDIA_VISIBLE_DEVICES_ENVVAR_WHEN_UNPRIVILEGED
       value: "false"
     - name: ACCEPT_NVIDIA_VISIBLE_DEVICES_AS_VOLUME_MOUNTS
       value: "true"
    devicePlugin:
      env:
      - name: DEVICE_LIST_STRATEGY
        value: volume-mounts


*************************************************
Pod Security Context of the Operator and Operands
*************************************************

Several of the NVIDIA GPU Operator operands, such as the driver containers and container toolkit,
require the following elevated privileges:

- ``privileged: true``
- ``hostPID: true``
- ``hostIPC: true``

The elevated privileges are required for the following reasons:

- Access to the host file system and hardware devices, such as NVIDIA GPUs.
- Restart system services such as containerd.
- Permit users to list all GPU clients using the ``nvidia-smi`` utility.

Only the Kubernetes cluster administrator needs to access or manage the Operator namespace.
As a best practice, establish proper security policies and prevent any other users from accessing the Operator namespace.
