
*****************************
Security Considerations
*****************************


Preventing Unprivileged GPU Access
==================================

By default, a container can request GPU access by setting the
``NVIDIA_VISIBLE_DEVICES`` environment variable, even when it does not request
an ``nvidia.com/gpu`` resource. This can allow an unprivileged workload to
access more GPUs than the Kubernetes device plugin allocated to it.

Cluster administrators can prevent this configuration by making the NVIDIA
Container Toolkit accept the device list only from the device plugin. Add the
following values during GPU Operator installation or upgrade:

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

This configuration assumes that the cluster's security policy does not allow
unprivileged workloads to create arbitrary host volume mounts. Review the
resulting pod security policy and admission controls before enabling it.

Privileged containers can still access all GPUs on a node. Restrict access to
the Operator namespace and avoid granting privileged access to ordinary
workloads. Components that need access to all GPUs, such as the device plugin
and DCGM Exporter, should be treated as infrastructure workloads.


Pod Security Context of the Operator and Operands
=================================================

Several of the NVIDIA GPU Operator operands, such as the driver containers and container toolkit,
require the following elevated privileges:

- ``privileged: true``
- ``hostPID: true``
- ``hostIPC: true``

The elevated privileges are required for the following reasons:

- Access to the host file system and hardware devices, such as NVIDIA GPUs.
- Restart system services such as containerd.
- Loading and unloading kernel modules.

Only the Kubernetes cluster administrator needs to access or manage the Operator namespace.
As a best practice, establish proper security policies and prevent any other users from accessing the Operator namespace.


CVEs
=================================================

The following is a list of known CVEs in the GPU Operator or its operands.
To view published security bulletins for NVIDIA products, refer to the
`NVIDIA product security page <https://www.nvidia.com/en-us/security/>`_.

.. list-table:: CVEs
   :widths: 20 45 35
   :header-rows: 1

   * - CVE ID
     - Affected Components
     - Fixed Version

   * - `NVIDIA CVE-2025-23359 <https://nvidia.custhelp.com/app/answers/detail/a_id/5616>`_
     - NVIDIA Container Toolkit, all versions up to and including 1.17.3

       NVIDIA GPU Operator, all versions up to and including 24.9.1
     - NVIDIA Container Toolkit 1.17.4

       NVIDIA GPU Operator 24.9.2

   * - `NVIDIA CVE-2024-0135 <https://nvidia.custhelp.com/app/answers/detail/a_id/5599>`_ 
     - NVIDIA Container Toolkit, all versions up to and including 1.17.2

       NVIDIA GPU Operator, all versions up to and including 24.9.0
     - NVIDIA Container Toolkit 1.17.3

       NVIDIA GPU Operator 24.9.1

   * - `NVIDIA CVE-2024-0136 <https://nvidia.custhelp.com/app/answers/detail/a_id/5599>`_ 
     - NVIDIA Container Toolkit, all versions up to and including 1.17.2

       NVIDIA GPU Operator, all versions up to and including 24.9.0
     - NVIDIA Container Toolkit 1.17.3

       NVIDIA GPU Operator 24.9.1

   * - `NVIDIA CVE-2024-0137 <https://nvidia.custhelp.com/app/answers/detail/a_id/5599>`_
     - NVIDIA Container Toolkit, all versions up to and including 1.17.2

       NVIDIA GPU Operator, all versions up to and including 24.9.0
     - NVIDIA Container Toolkit 1.17.3

       NVIDIA GPU Operator 24.9.1

   * - `NVIDIA CVE-2024-0134 <https://nvidia.custhelp.com/app/answers/detail/a_id/5585>`_
     - NVIDIA Container Toolkit, all versions up to and including 1.16.2

       NVIDIA GPU Operator, all versions up to and including 24.6.2
     - NVIDIA Container Toolkit 1.17.0

       NVIDIA GPU Operator 24.9.0

   * - `NVIDIA CVE-2024-0132 <https://nvidia.custhelp.com/app/answers/detail/a_id/5582>`_
     - NVIDIA Container Toolkit, all versions up to and including 1.16.1

       NVIDIA GPU Operator, all versions up to and including 24.6.1
     - NVIDIA Container Toolkit 1.16.2

       NVIDIA GPU Operator 24.6.2
   * - `NVIDIA CVE-2024-0133 <https://nvidia.custhelp.com/app/answers/detail/a_id/5582>`_
     - NVIDIA Container Toolkit, all versions up to and including 1.16.1

       NVIDIA GPU Operator, all versions up to and including 24.6.1
     - NVIDIA Container Toolkit 1.16.2

       NVIDIA GPU Operator 24.6.2

Report a Vulnerability
-----------------------------

For details on reporting a suspected vulnerability, refer to the `GPU Operator
Security policy <https://github.com/NVIDIA/gpu-operator/blob/main/SECURITY.md>`_.
