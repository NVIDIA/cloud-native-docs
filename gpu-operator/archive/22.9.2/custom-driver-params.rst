.. Date: Mar 11 2022
.. Author: cdesiniotis

.. _custom-driver-params-22.9.2

Customizing NVIDIA GPU Driver Parameters during Installation
************************************************************

The NVIDIA Driver kernel modules accept a number of parameters which can be used to customize the behavior of the driver.
Most of the parameters are documented in the `NVIDIA Driver README <https://download.nvidia.com/XFree86/Linux-x86_64/510.47.03/README/>`_.
By default, the GPU Operator loads the kernel modules with default values.
Starting with v1.10, the GPU Operator provides the ability to pass custom parameters to the kernel modules that get loaded as part of the
NVIDIA Driver installation (e.g. ``nvidia``, ``nvidia-modeset``, ``nvidia-uvm``, and ``nvidia-peermem``).

To pass custom parameters, execute the following steps.

Create a configuration file named ``<module>.conf``, where ``<module>`` is the name of the kernel module the parameters are for.
The file should contain parameters as key-value pairs -- one parameter per line.
In the below example, we are passing one parameter to the ``nvidia`` module, which is disabling the use of
`GSP firmware <https://download.nvidia.com/XFree86/Linux-x86_64/510.47.03/README/gsp.html>`_.

.. code-block:: console

   $ cat nvidia.conf
   NVreg_EnableGpuFirmware=0

Create a ``ConfigMap`` for the configuration file.
If multiple modules are being configured, pass multiple files when creating the ``ConfigMap``.

.. code-block:: console

   $ kubectl create configmap kernel-module-params -n gpu-operator --from-file=nvidia.conf=./nvidia.conf

Install the GPU Operator and set ``driver.kernelModuleConfig.name`` to the name of the ``ConfigMap``
containing the kernel module parameters.

.. code-block:: console

   $ helm install --wait --generate-name \
        -n gpu-operator --create-namespace \
        nvidia/gpu-operator \
        --set driver.kernelModuleConfig.name="kernel-module-params"
