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

A default installation of NVIDIA Container Toolkit and NVIDIA Kubernetes Device Plugin permits unprivileged containers to bypass the Kubernetes Device Plugin API and gain access to GPUs on a node by setting the ``NVIDIA_VISIBLE_DEVICES`` environment variable.
This behavior means that an unprivileged container can gain access to GPUs without specifying resource limits or gain access to more GPUs than were specified through resource limits.

However, there are valid circumstances to grant containers access to all GPUs on the system without going through the NVIDIA Kubernetes Device Plugin and interfering with Kubernetes accounting for allocatable resources.
Examples of these pods are the device plugin itself and and container that performs monitoring of GPU devices, such as NVIDIA DCGM Exporter.
However, these pods differ from typical workloads because they run software that is critical to the overall Kubernetes infrastructure and should be considered privileged.
Keep in mind that privileged containers always have access to all GPUs on a node.

You can configure the toolkit and device plugin to prevent unprivileged containers from gaining access to GPUs through the ``NVIDIA_VISIBLE_DEVICES`` environment variable.
The strategy for the toolkit and device plugin are as follows:

- The toolkit ignores ``NVIDIA_VISIBLE_DEVICES``.
- The device plugin produces a list of GPU devices as volume mounts, according to resource requests, and the toolkit accepts this list exclusively.

  An assumption is made that cluster administrators do not allow host volume mounts for unprivileged containers.

The combination of configuring the toolkit and device plugin, and not allowing host volume mounts for unprivileged containers prevents those containers from setting up the GPU device list themselves.

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

The following comparison shows how setting ``NVIDIA_VISIBLE_DEVICES`` to ``all`` grants access to more GPUs than the resource request
in the default configuration and that access is limited after reconfiguration.
Any image can set ``NVIDIA_VISIBLE_DEVICES`` to ``all``--the base CUDA image in the example does--with the same result as explicitly setting the variable on the command line.

+------------------------------------------------------------------+-----------------------------------------------------------------+
| .. literalinclude:: ./manifests/input/k-run-cuda.txt                                                                               |
|    :language: console                                                                                                              |
|    :start-after: envall-limit-1                                                                                                    |
|    :end-before: end                                                                                                                |
+------------------------------------------------------------------+-----------------------------------------------------------------+
| Default Configuration                                            | Limit Unprivileged                                              |
+------------------------------------------------------------------+-----------------------------------------------------------------+
| .. literalinclude:: ./manifests/input/k-run-cuda.txt             | .. literalinclude:: ./manifests/input/k-run-cuda.txt            |
|   :language: output                                              |    :language: output                                            |
|   :start-after: default-envall-limit-1                           |    :start-after: limit-envall-limit-1                           |
|   :end-before: end                                               |    :end-before: end                                             |
+------------------------------------------------------------------+-----------------------------------------------------------------+

The following comparison shows how specifying a resource request of ``nvidia.com/gpu: 0`` grants access to GPUs
in the default configuration and that access is limited after reconfiguration.

+------------------------------------------------------------------+-----------------------------------------------------------------+
| .. literalinclude:: ./manifests/input/k-run-cuda.txt                                                                               |
|    :language: console                                                                                                              |
|    :start-after: noenv-limit-0                                                                                                     |
|    :end-before: end                                                                                                                |
+------------------------------------------------------------------+-----------------------------------------------------------------+
| Default Configuration                                            | Limit Unprivileged                                              |
+------------------------------------------------------------------+-----------------------------------------------------------------+
| .. literalinclude:: ./manifests/input/k-run-cuda.txt             | .. literalinclude:: ./manifests/input/k-run-cuda.txt            |
|   :language: output                                              |    :language: output                                            |
|   :start-after: default-noenv-limit-0                            |    :start-after: limit-noenv-limit-0                            |
|   :end-before: end                                               |    :end-before: end                                             |
+------------------------------------------------------------------+-----------------------------------------------------------------+

The following comparison shows that privileged containers have access to all GPUs regardless of environment variables, resource requests,
or device plugin and toolkit configuration.

+------------------------------------------------------------------+-----------------------------------------------------------------+
| .. literalinclude:: ./manifests/input/k-run-cuda.txt                                                                               |
|    :language: text                                                                                                                 |
|    :start-after: privileged                                                                                                        |
|    :end-before: end                                                                                                                |
+------------------------------------------------------------------+-----------------------------------------------------------------+
| Default Configuration                                            | Limit Unprivileged                                              |
+------------------------------------------------------------------+-----------------------------------------------------------------+
| .. literalinclude:: ./manifests/input/k-run-cuda.txt             | .. literalinclude:: ./manifests/input/k-run-cuda.txt            |
|   :language: output                                              |    :language: output                                            |
|   :start-after: default-privileged                               |    :start-after: limit-privileged                               |
|   :end-before: end                                               |    :end-before: end                                             |
+------------------------------------------------------------------+-----------------------------------------------------------------+

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
