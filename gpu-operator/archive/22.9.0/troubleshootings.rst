
#####################
Troubleshootings
#####################



************************************************
infoROM is corrupted (nvidia-smi return code 14)
************************************************


Issue:

nvidia-operator-validator fails and nvidia-driver-daemonsets fails as well.


Observation:

Output from kubectl logs -n gpu-operator nvidia-operator-validator-xxxxx -c driver-validation:


.. code-block:: console


        | NVIDIA-SMI 470.82.01    Driver Version: 470.82.01    CUDA Version: 11.4     |
        |-------------------------------+----------------------+----------------------+
        | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
        | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
        |                               |                      |               MIG M. |
        |===============================+======================+======================|
        |   0  Tesla P100-PCIE...  On   | 00000000:0B:00.0 Off |                    0 |
        | N/A   42C    P0    29W / 250W |      0MiB / 16280MiB |      0%      Default |
        |                               |                      |                  N/A |
        +-------------------------------+----------------------+----------------------+
                                                                                    
        +-----------------------------------------------------------------------------+
        | Processes:                                                                  |
        |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
        |        ID   ID                                                   Usage      |
        |=============================================================================|
        |  No running processes found                                                 |
        +-----------------------------------------------------------------------------+
        WARNING: infoROM is corrupted at gpu 0000:0B:00.0
        14

The GPU emits some warning messages related to infoROM.


Note:

possible return value for nvidia-smi is listed below (reference: `nvidia-smi specification <https://developer.download.nvidia.com/compute/DCGM/docs/nvidia-smi-367.38.pdf>`_):

.. code-block:: console

        RETURN VALUE

        Return code reflects whether the operation succeeded or failed and what
        was the reason of failure.

        Â·      Return code 0 - Success

        Â·      Return code 2 - A supplied argument or flag is invalid
        Â·      Return code 3 - The requested operation is not available on target device
        Â·      Return code 4 - The current user does  not  have permission  to access this device or perform this operation
        Â·      Return code 6 - A query to find an object was unsuccessful
        Â·      Return code 8 - A device's external power cables are not properly attached
        Â·      Return code 9 - NVIDIA driver is not loaded
        Â·      Return code 10 - NVIDIA Kernel detected an interrupt issue  with a GPU
        Â·      Return code 12 - NVML Shared Library couldn't be found or loaded
        Â·      Return code 13 - Local version of NVML  doesn't  implement  this function
        Â·      Return code 14 - infoROM is corrupted
        Â·      Return code 15 - The GPU has fallen off the bus or has otherwise become inaccessible
        Â·      Return code 255 - Other error or internal driver error occurred



Root cause:

nvidi-smi should return a success code (Return code 0) for driver-validator to pass and GPU operator to successfully deploy driver pod on the node.


Action:

replace the faulty GPU




*********************
EFI + Secure Boot
*********************


Issue:
GPU Driver pod fails to deploy


Root cause:
EFI Secure Boot is currently not supported with GPU Operator

Action:
Disable EFI Secure Boot on the server




