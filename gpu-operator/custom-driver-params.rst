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

Configure Custom Driver Parameters
--------------------------

To pass custom parameters, execute the following steps.

#. Create a configuration file named ``<module>.conf``, where ``<module>`` is the name of the kernel module the parameters are for.
   The file should contain parameters as key-value pairs -- one parameter per line.

   The following example shows the GPU firmware logging parameter being passed to the ``nvidia`` module.

   .. code-block:: console

      $ cat nvidia.conf
      NVreg_EnableGpuFirmwareLogs=2

#. Create a ``ConfigMap`` for the configuration file.
   If multiple modules are being configured, pass multiple files when creating the ``ConfigMap``.

   .. code-block:: console

      $ kubectl create configmap kernel-module-params -n gpu-operator --from-file=nvidia.conf=./nvidia.conf

#. Install the GPU Operator and set ``driver.kernelModuleConfig.name`` to the name of the ``ConfigMap``
   containing the kernel module parameters.

   .. code-block:: console

      $ helm install --wait --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --version=${version} \
         --set driver.kernelModuleConfig.name="kernel-module-params"

-----------------------------------
Example using ``nvidia-uvm`` module
-----------------------------------

#. Create a configuration file named ``nvidia-uvm.conf``:
   The following example shows the High Memory Mode being disabled in the ``nvidia-uvm`` module:

   .. code-block:: console

      $ cat nvidia-uvm.conf
      uvm_disable_hmm=1


#. Create a ``ConfigMap`` for the configuration file.
   If multiple modules are being configured, pass multiple files when creating the ``ConfigMap``.

   .. code-block:: console

      $ kubectl create configmap kernel-module-params -n gpu-operator --from-file=nvidia-uvm.conf=./nvidia-uvm.conf

#. Install the GPU Operator and set ``driver.kernelModuleConfig.name`` to the name of the ``ConfigMap``
   containing the kernel module parameters.

   .. code-block:: console

      $ helm install --wait --generate-name \
         -n gpu-operator --create-namespace \
         nvidia/gpu-operator \
         --version=${version} \
         --set driver.kernelModuleConfig.name="kernel-module-params"

#. Verify the parameter has been correctly applied, go to ``/sys/module/nvidia_uvm/parameters/`` on the node:

   .. code-block:: console

      $ ls /sys/module/nvidia_uvm/parameters/

   *Example Output*

   .. code-block:: output

      ...           
      uvm_disable_hmm                               uvm_perf_access_counter_migration_enable  uvm_perf_prefetch_min_faults
      uvm_downgrade_force_membar_sys                uvm_perf_access_counter_threshold         uvm_perf_prefetch_threshold
      ...

   Then check the value of the parameter: 

   .. code-block:: console

      $ cat /sys/module/nvidia_uvm/parameters/uvm_disable_hmm

   *Example Output*

   .. code-block:: output

      Y