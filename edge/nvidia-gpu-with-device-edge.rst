.. Date: February 09, 2013
.. Author: stesmith

.. headings are # * - =

.. _mirror-gpu-ocp-disconnected:


################################################################
Accelerating workloads with NVIDIA GPUs with Red Hat Device Edge
################################################################

**************
Introduction
**************

.. note:: Developer Preview features are not supported with Red Hat production service level agreements (SLAs) and are not functionally complete. Red Hat does not advise using them in a production setting. Developer Preview features provide early access to upcoming product features, enabling customers to test functionality and provide feedback during the development process. These releases may not have any documentation, and testing is limited. Red Hat may provide ways to submit feedback on Developer Preview releases without an associated SLA.

Red Hat has released Red Hat Device Edge, which provides access to MicroShift. MicroShift offers the simplicity of single-node deployment with the functionality and services you need for computing in resource-constrained locations. You can have many deployments on different hosts, creating the specific system image needed for each of your applications. Installing MicroShift on top of your managed RHEL devices in hard-to-service locations also allows for streamlined over-the-air updates.

Red Hat Device Edge combines light-weight Kubernetes using MicroShift with Red Hat Enterprise Linux at the edge. MicroShift is a Kubernetes implementation derived from OpenShift, focusing on a minimal  footprint. Red Hat Device Edge addresses the needs of bare metal, virtual, containerized, or kubernetes workloads deployed to resource constrained environments.

Perform the procedures on this page to enable workloads to use NVIDIA GPUs on an x86 system running Red Hat Device Edge.

****************
Prerequisites
****************

* Install `MicroShift from an RPM package <https://access.redhat.com/documentation/en-us/red_hat_build_of_microshift/4.13/html/installing/microshift-install-rpm>`_ on the Red Hat Enterprise Linux 8.7 machine.
* Verify an NVIDIA GPU is installed on the machine:

  .. code-block:: console

     $ lspci -nnv | grep -i nvidia

  **Example Output**

  .. code-block:: output

     17:00.0 3D controller [0302]: NVIDIA Corporation GA100GL [A30 PCIe] [10de:20b7] (rev a1)
             Subsystem: NVIDIA Corporation Device [10de:1532]


********************************
Installing the NVIDIA GPU driver
********************************

NVIDIA provides a precompiled driver in RPM repositories that implement the modularity mechanism.
For more information, see `Streamlining NVIDIA Driver Deployment on RHEL 8 with Modularity Streams <https://developer.nvidia.com/blog/streamlining-nvidia-driver-deployment-on-rhel-8-with-modularity-streams/>`_.

#. At this stage, you should have already subscribed your machine and enabled the ``rhel-9-for-x86_64-baseos-rpms`` and ``rhel-9-for-x86_64-appstream-rpms`` repositories.
   Add the NVIDIA CUDA repository:

   .. code-block:: console

      $ sudo dnf config-manager --add-repo=https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo

#. NVIDIA provides different branches of their drivers, with different lifecycles, that are described in `NVIDIA Datacenter Drivers documentation <https://docs.nvidia.com/datacenter/tesla/drivers/index.html#cuda-drivers>`_.
   Use the latest version from the production branch, for example, version ``R525``. Install the driver, fabric-manager and NSCQ:

   .. code-block:: console

      $ sudo dnf module install nvidia-driver:525
      $ sudo dnf install nvidia-fabric-manager libnvidia-nscq-525

#. After installing the driver, disable the ``nouveau`` driver because it conflict with the NVIDIA driver:

   .. code-block:: console

      $ echo 'blacklist nouveau' | sudo tee /etc/modprobe.d/nouveau-blacklist.conf

#. Update initramfs:

   .. code-block:: console

      $ sudo dracut --force

#. Enable the ``nvidia-fabricmanager`` and ``nvidia-persistenced`` services:

   .. code-block:: console

      $ sudo systemctl enable nvidia-fabricmanager.service
      $ sudo systemctl enable nvidia-persistenced.service

#. Reboot the machine:

   .. code-block:: console

      $ sudo systemctl reboot

#. After the machine boots, verify that the NVIDIA drivers are installed properly:

   .. code-block:: console

      $ nvidia-smi

   **Example Output**

   .. code-block:: output

      Thu Jun 22 14:29:53 2023
      +-----------------------------------------------------------------------------+
      | NVIDIA-SMI 525.105.17   Driver Version: 525.105.17   CUDA Version: 12.0     |
      |-------------------------------+----------------------+----------------------+
      | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
      | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
      |                               |                      |               MIG M. |
      |===============================+======================+======================|
      |   0  NVIDIA A30          Off  | 00000000:17:00.0 Off |                    0 |
      | N/A   29C    P0    35W / 165W |      0MiB / 24576MiB |     25%      Default |
      |                               |                      |             Disabled |
      +-------------------------------+----------------------+----------------------+

      +-----------------------------------------------------------------------------+
      | Processes:                                                                  |
      |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
      |        ID   ID                                                   Usage      |
      |=============================================================================|
      |  No running processes found                                                 |
      +-----------------------------------------------------------------------------+


***************************************
Installing the NVIDIA Container Toolkit
***************************************

The `NVIDIA Container Toolkit <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/overview.html>`_ enables users
to build and run GPU accelerated containers. The toolkit includes a container runtime library and utilities to automatically configure containers
to leverage NVIDIA GPUs. You have to install it to enable the container runtime to transparently configure the NVIDIA GPUs for the pods deployed in MicroShift.

The NVIDIA container toolkit supports the distributions listed in the `NVIDIA Container Toolkit repository <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#installation-guide/>`_.

#. Add the ``libnvidia-container`` repository:

   .. code-block:: console

      $ curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | sudo tee /etc/yum.repos.d/libnvidia-container.repo

#. Install the NVIDIA Container Toolkit for RHEL:

   .. code-block:: console

      $ sudo dnf install nvidia-container-toolkit -y

#. Set the NVIDIA Container Toolkit to use the CDI mode:

   .. code-block:: console

      $ sudo nvidia-ctk config --in-place --set nvidia-container-runtime.mode=cdi

#. The NVIDIA Container Toolkit requires some SELinux permissions to work properly. These permissions are set in three steps.

   A. Use DNF to install the ``container-selinux.noarch`` package:

      .. code-block:: console

         $ sudo dnf install container-selinux.noarch


   B. Set the SELinux configuration flag for ``container_use_devices`` to ``on``:

      .. code-block:: console

         $ sudo setsebool -P container_use_devices on


   C. It is still missing a permission, so create a policy file:

      .. code-block:: console

         $ cat <<EOF > nvidia-container-microshift.te
         module nvidia-container-microshift 1.0;

         require {
	               type xserver_misc_device_t;
	               type container_t;
	               class chr_file { map read write };
         }

         #============= container_t ==============
         allow container_t xserver_misc_device_t:chr_file map;
         EOF


   D. Compile the policy:

      .. code-block:: console

         $ checkmodule -m -M -o nvidia-container-microshift.mod nvidia-container-microshift.te


   E. Create the ``semodule`` package:

      .. code-block:: console

         $ semodule_package --outfile nvidia-container-microshift.pp --module nvidia-container-microshift.mod


   F. Apply the policy:

     .. code-block:: console

        $ sudo semodule -i nvidia-container-microshift.pp


***************************************
Installing the NVIDIA Device Plugin
***************************************

To enable MicroShift to allocate GPU resource to the pods, deploy the `NVIDIA Device Plugin <https://github.com/NVIDIA/k8s-device-plugin>`_.  The plugin runs as a daemon set that provides the following features:

* Exposes the number of GPUs on each node of your cluster.
* Keeps track of the health of your GPUs.
* Runs GPU-enabled containers in your Kubernetes cluster.

The deployment consists of adding manifests and a ``kustomize`` configuration to the ``/etc/microshift/manifests`` folder where MicroShift checks for manifests to create at start time. This is explained in the `Configuring section of the MicroShift documentation <https://access.redhat.com/documentation/en-us/red_hat_build_of_microshift/4.12/html/configuring/index>`_.

#. Create the ``manifests`` folder:

   .. code-block:: console

      $ sudo mkdir -p /etc/microshift/manifests.d/nvidia-device-plugin

#. The device plugin runs in privileged mode, so you need to isolate it from other workloads by running it in its own namespace, ``nvidia-device-plugin``. To add the plugin to the manifests deployed by MicroShift at start time, download the configuration file and save it at ``/etc/microshift/manifests.d/nvidia-device-plugin``.

   .. code-block:: console

      $ curl -s -L https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/refs/heads/main/deployments/static/nvidia-device-plugin-privileged-with-service-account.yml | sudo tee /etc/microshift/manifests.d/nvidia-device-plugin/nvidia-device-plugin.yml

#. The resources are not created automatically even though the files exist. You need to add them to the ``kustomize`` configuration. Do this by adding a single ``kustomization.yaml`` file in the ``manifests`` folder that references all the resources you want to create.

   .. code-block:: console

      $ cat <<EOF | sudo tee /etc/microshift/manifests.d/nvidia-device-plugin/kustomization.yaml
      ---
      apiVersion: kustomize.config.k8s.io/v1beta1
      kind: Kustomization
      resources:
        - nvidia-device-plugin.yml
      EOF

#. Restart the MicroShift service so that it creates the resources:

   .. code-block:: console

      $ sudo systemctl restart microshift

#. After MicroShift restarts, verify that the pod is running in the ``nvidia-device-plugin`` namespace:

   .. code-block:: console

      $ oc get pod -n nvidia-device-plugin


   **Example Output**

   .. code-block:: output

      NAMESPACE                  NAME                                   READY   STATUS        RESTARTS     AGE
      nvidia-device-plugin       nvidia-device-plugin-daemonset-jx8s8   1/1     Running       0            1m


#. Verify in the log that it has registered itself as a device plugin for the ``nvidia.com/gpu`` resources:

   .. code-block:: console

      $ oc logs -n nvidia-device-plugin nvidia-device-plugin-jx8s8

   **Example Output**

   .. code-block:: output

      [...]
      2023/06/22 14:25:38 Retreiving plugins.
      2023/06/22 14:25:38 Detected NVML platform: found NVML library
      2023/06/22 14:25:38 Detected non-Tegra platform: /sys/devices/soc0/family file not found
      2023/06/22 14:25:38 Starting GRPC server for 'nvidia.com/gpu'
      2023/06/22 14:25:38 Starting to serve 'nvidia.com/gpu' on /var/lib/kubelet/device-plugins/nvidia-gpu.sock
      2023/06/22 14:25:38 Registered device plugin for 'nvidia.com/gpu' with Kubelet

#. You can also verify that the node exposes the ``nvidia.com/gpu`` resources in its capacity:

   .. code-block:: console

      $ oc get node -o json | jq -r '.items[0].status.capacity'


   **Example Output**

   .. code-block:: output

      {
        "cpu": "48",
        "ephemeral-storage": "142063152Ki",
        "hugepages-1Gi": "0",
        "hugepages-2Mi": "0",
        "memory": "196686216Ki",
        "nvidia.com/gpu": "1",
        "pods": "250"
      }


**********************************************************
Running a GPU-Accelerated Workload on Red Hat Device Edge
**********************************************************

You can run a test workload to verify that the configuration is correct. A simple workload is the CUDA vectorAdd program that NVIDIA provides in a container image.

#. Create a ``test`` namespace:

   .. code-block:: console

      $ oc create namespace test

#. Create a file, such as ``pod-cuda-vector-add.yaml``, with a pod specification. Note the ``spec.containers[0].resources.limits`` field where the ``nvidia.com/gpu`` resource specifies a value of ``1``.

   .. code-block:: console

      $ cat << EOF > pod-cuda-vector-add.yaml
      ---
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-cuda-vector-add
        namespace: test
      spec:
        restartPolicy: OnFailure
        containers:
        - name: cuda-vector-add
          image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda11.7.1-ubi8"
          resources:
            limits:
              nvidia.com/gpu: 1
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop: ["ALL"]
            runAsNonRoot: true
            seccompProfile:
              type: "RuntimeDefault"
      EOF

#. Create the pod:

   .. code-block:: console

      $ oc apply -f pod-cuda-vector-add.yaml

#. Verify the pod log has found a CUDA device:

   .. code-block:: console

      $ oc logs -n test test-cuda-vector-add

   **Example Output**

   .. code-block:: output

      [Vector addition of 50000 elements]
      Copy input data from the host memory to the CUDA device
      CUDA kernel launch with 196 blocks of 256 threads
      Copy output data from the CUDA device to the host memory
      Test PASSED
      Done


#. Undeploy the pods in the ``pod-cuda-vector-add.yaml`` file:

   .. code-block:: console

      $ oc delete -f pod-cuda-vector-add.yaml


#. Delete the ``test`` namespace:

   .. code-block:: console

      $ oc delete ns test
