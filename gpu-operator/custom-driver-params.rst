.. Date: Mar 11 2022
.. Author: cdesiniotis

.. _custom-driver-params:

Customizing NVIDIA GPU Driver Parameters during Installation
************************************************************

The NVIDIA Driver kernel modules accept a number of parameters which can be used to customize the behavior of the driver.
By default, the GPU Operator loads the kernel modules with default values.
On a machine with the driver already installed, you can list the parameter names and values with the ``cat /proc/driver/nvidia/params`` command.
You can pass custom parameters to the kernel modules that get loaded as part of the
NVIDIA Driver installation (``nvidia``, ``nvidia-modeset``, ``nvidia-uvm``, and ``nvidia-peermem``).

To pass custom parameters, execute the following steps.

Create a configuration file named ``<module>.conf``, where ``<module>`` is the name of the kernel module the parameters are for.
The file should contain parameters as key-value pairs -- one parameter per line.
In the following example, the GPU firmware logging parameter is passed to the ``nvidia`` module.

.. code-block:: console

   $ cat nvidia.conf
   NVreg_EnableGpuFirmwareLogs=2

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
        --version=${version} \
        --set driver.kernelModuleConfig.name="kernel-module-params"
