.. _confidential-containers-deploy:

*******************************************************
Deploy Confidential Containers with NVIDIA GPU Operator
*******************************************************

This page describes how to deploy Confidential Containers using the NVIDIA GPU Operator.
For an overview of Confidential Containers, refer to :ref:`early-access-gpu-operator-confidential-containers-kata`.

.. note::

   Early Access features are not supported in production environments and are not functionally complete. Early Access features provide a preview of upcoming product features, enabling customers to test functionality and provide feedback during the development process. These releases may not have complete documentation, and testing is limited. Additionally, API and architectural designs are not final and may change in the future.

.. _coco-prerequisites:

Prerequisites
=============

* You are using a supported platform for confidential containers. For more information, refer to :ref:`supported-platforms`. In particular:

  * You selected and configured your hardware and BIOS to support confidential computing.
  * You installed and configured Ubuntu 25.10 as host OS with its default kernel to support confidential computing.
  * You validated that the Linux kernel is SNP-aware.

* Your hosts are configured to enable hardware virtualization and Access Control Services (ACS). With some AMD CPUs and BIOSes, ACS might be grouped under Advanced Error Reporting (AER). Enabling these features is typically performed by configuring the host BIOS.
* Your hosts are configured to support IOMMU.

  * If the output from running ``ls /sys/kernel/iommu_groups`` includes 0, 1, and so on, then your host is configured for IOMMU.

* You have a Kubernetes cluster and you have cluster administrator privileges. For this cluster, you are using containerd 2.1 and Kubernetes version v1.34. These versions have been validated with the kata-containers project and are recommended. You use a ``runtimeRequestTimeout`` of more than 5 minutes in your `kubelet configuration <https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/>`_ (the current method to pull container images within the confidential container may exceed the two minute default timeout in case of using large container images).

.. _installation-and-configuration:

Installation and Configuration
===============================

Overview
--------

Installing and configuring your cluster to support the NVIDIA GPU Operator with confidential containers is as follows:

1. Label the worker nodes that you want to use with confidential containers.

   This step ensures that you can continue to run traditional container workloads with GPU or vGPU workloads on some nodes in your cluster. Alternatively, you can set a default sandbox workload parameter to vm-passthrough to run confidential containers on all worker nodes when you install the GPU Operator.

2. Install the latest Kata Containers helm chart (minimum version: 3.24.0).

   This step installs all required components from the Kata Containers project including the Kata Containers runtime binary, runtime configuration, UVM kernel and initrd that NVIDIA uses for confidential containers and native Kata containers.

3. Install the latest version of the NVIDIA GPU Operator (minimum version: v25.10.0).

   You install the Operator and specify options to deploy the operands that are required for confidential containers.

After installation, you can change the confidential computing mode and run a sample GPU workload in a confidential container.

Label nodes and install the Kata Containers Helm Chart
-------------------------------------------------------

Perform the following steps to install and verify the Kata Containers Helm Chart:

1. Label the nodes on which you intend to run confidential containers as follows::

      $ kubectl label node <node-name> nvidia.com/gpu.workload.config=vm-passthrough

2. Use the 3.24.0 Kata Containers version and chart in environment variables::

      $ export VERSION="3.24.0"
      $ export CHART="oci://ghcr.io/kata-containers/kata-deploy-charts/kata-deploy"

3. Install the Chart::

      $ helm install kata-deploy \
          --namespace kata-system \
          --create-namespace \
          -f "https://raw.githubusercontent.com/kata-containers/kata-containers/refs/tags/${VERSION}/tools/packaging/kata-deploy/helm-chart/kata-deploy/try-kata-nvidia-gpu.values.yaml" \
          --set nfd.enabled=false \
          --set shims.qemu-nvidia-gpu-tdx.enabled=false \
          --wait --timeout 10m --atomic \
          "${CHART}" --version "${VERSION}"

   *Example Output*::

      Pulled: ghcr.io/kata-containers/kata-deploy-charts/kata-deploy:3.24.0
      Digest: sha256:d87e4f3d93b7d60eccdb3f368610f2b5ca111bfcd7133e654d08cfd192fb3351
      NAME: kata-deploy
      LAST DEPLOYED: Wed Dec 17 20:01:53 2025
      NAMESPACE: kata-system
      STATUS: deployed
      REVISION: 1
      TEST SUITE: None

4. Optional: View the pod in the kata-system namespace and ensure it is running::

      $ kubectl get pod,svc -n kata-system

   *Example Output*::

      NAME                    READY   STATUS    RESTARTS   AGE
      pod/kata-deploy-4f658   1/1     Running   0          21s

   Wait a few minutes for kata-deploy to create the base runtime classes.

5. Verify that the kata-qemu-nvidia-gpu and kata-qemu-nvidia-gpu-snp runtime classes are available::

      $ kubectl get runtimeclass

   *Example Output*::

      NAME                       HANDLER                    AGE
      kata-qemu-nvidia-gpu       kata-qemu-nvidia-gpu       40s
      kata-qemu-nvidia-gpu-snp   kata-qemu-nvidia-gpu-snp   40s

Install the NVIDIA GPU Operator
--------------------------------

Perform the following steps to install the Operator for use with confidential containers:

1. Add and update the NVIDIA Helm repository::

      $ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
         && helm repo update

2. Specify at least the following options when you install the Operator. If you want to run Confidential Containers by default on all worker nodes, also specify ``--set sandboxWorkloads.defaultWorkload=vm-passthrough``::

      $ helm install --wait --generate-name \
          -n gpu-operator --create-namespace \
          nvidia/gpu-operator \
          --set sandboxWorkloads.enabled=true \
          --set kataManager.enabled=true \
          --set kataManager.config.runtimeClasses=null \
          --set kataManager.repository=nvcr.io/nvidia/cloud-native \
          --set kataManager.image=k8s-kata-manager \
          --set kataManager.version=v0.2.4 \
          --set ccManager.enabled=true \
          --set ccManager.defaultMode=on \
          --set ccManager.repository=nvcr.io/nvidia/cloud-native \
          --set ccManager.image=k8s-cc-manager \
          --set ccManager.version=v0.2.0 \
          --set sandboxDevicePlugin.repository=nvcr.io/nvidia/cloud-native \
          --set sandboxDevicePlugin.image=nvidia-sandbox-device-plugin \
          --set sandboxDevicePlugin.version=v0.0.1 \
          --set 'sandboxDevicePlugin.env[0].name=P_GPU_ALIAS' \
          --set 'sandboxDevicePlugin.env[0].value=pgpu' \
          --set nfd.enabled=true \
          --set nfd.nodefeaturerules=true

   *Example Output*::

      NAME: gpu-operator-1766001809
      LAST DEPLOYED: Wed Dec 17 20:03:29 2025
      NAMESPACE: gpu-operator
      STATUS: deployed
      REVISION: 1
      TEST SUITE: None

   Note that, for heterogeneous clusters with different GPU types, you can omit
   the ``P_GPU_ALIAS`` environment variable lines (the two ``sandboxDevicePlugin.env``
   options). This causes the sandbox device plugin to create GPU model-specific
   resource types (such as ``nvidia.com/GH100_H100L_94GB``) instead of the generic
   ``nvidia.com/pgpu``. For simplicity, this guide uses the generic alias.

3. Verify that all GPU Operator pods, especially the Kata Manager, Confidential Computing Manager, Sandbox Device Plugin and VFIO Manager operands, are running::

      $ kubectl get pods -n gpu-operator

   *Example Output*::

      NAME                                                              READY   STATUS    RESTARTS   AGE
      gpu-operator-1766001809-node-feature-discovery-gc-75776475sxzkp   1/1     Running   0          86s
      gpu-operator-1766001809-node-feature-discovery-master-6869lxq2g   1/1     Running   0          86s
      gpu-operator-1766001809-node-feature-discovery-worker-mh4cv       1/1     Running   0          86s
      gpu-operator-f48fd66b-vtfrl                                       1/1     Running   0          86s
      nvidia-cc-manager-7z74t                                           1/1     Running   0          61s
      nvidia-kata-manager-k8ctm                                         1/1     Running   0          62s
      nvidia-sandbox-device-plugin-daemonset-d5rvg                      1/1     Running   0          30s
      nvidia-sandbox-validator-6xnzc                                    1/1     Running   1          30s
      nvidia-vfio-manager-h229x                                         1/1     Running   0          62s

4. If the nvidia-cc-manager is *not* running, you need to label your CC-capable node(s) by hand. The node labelling capabilities in the early access version are not complete. To label your node(s), run::

      $ kubectl label node <nodename> nvidia.com/cc.capable=true

5. Optional: If you have host access to the worker node, you can perform the following validation steps:

   a. Confirm that the host uses the vfio-pci device driver for GPUs::

         $ lspci -nnk -d 10de:

      *Example Output*::

         65:00.0 3D controller [0302]: NVIDIA Corporation xxxxxxx [xxx] [10de:xxxx] (rev xx)
                 Subsystem: NVIDIA Corporation xxxxxxx [xxx] [10de:xxxx]
                 Kernel driver in use: vfio-pci
                 Kernel modules: nvidiafb, nouveau

   b. Confirm that the kata-deploy functionality installed the kata-qemu-nvidia-gpu-snp and kata-qemu-nvidia-gpu runtime class files::

         $ ls -l /opt/kata/share/defaults/kata-containers/ | grep nvidia

      *Example Output*::

         -rw-r--r-- 1 root root  3333 Dec 17 20:01 configuration-qemu-nvidia-gpu-snp.toml
         -rw-r--r-- 1 root root 30812 Dec 12 17:41 configuration-qemu-nvidia-gpu-tdx.toml
         -rw-r--r-- 1 root root 30279 Dec 12 17:41 configuration-qemu-nvidia-gpu.toml

   c. Confirm that the kata-deploy functionality installed the UVM components::

         $ ls -l /opt/kata/share/kata-containers/ | grep nvidia

      *Example Output*::

         lrwxrwxrwx 1 root root        58 Dec 17 20:01 kata-containers-initrd-nvidia-gpu-confidential.img -> kata-ubuntu-noble-nvidia-gpu-confidential-580.95.05.initrd
         lrwxrwxrwx 1 root root        45 Dec 17 20:01 kata-containers-initrd-nvidia-gpu.img -> kata-ubuntu-noble-nvidia-gpu-580.95.05.initrd
         lrwxrwxrwx 1 root root        57 Dec 17 20:01 kata-containers-nvidia-gpu-confidential.img -> kata-ubuntu-noble-nvidia-gpu-confidential-580.95.05.image
         lrwxrwxrwx 1 root root        44 Dec 17 20:01 kata-containers-nvidia-gpu.img -> kata-ubuntu-noble-nvidia-gpu-580.95.05.image
         lrwxrwxrwx 1 root root        42 Dec 17 20:01 vmlinux-nvidia-gpu-confidential.container -> vmlinux-6.16.7-173-nvidia-gpu-confidential
         lrwxrwxrwx 1 root root        30 Dec 17 20:01 vmlinux-nvidia-gpu.container -> vmlinux-6.12.47-173-nvidia-gpu

Run a Sample Workload
----------------------

A pod manifest for a confidential computing GPU workload requires the following:

1. Create a file, such as the following cuda-vectoradd-kata.yaml sample, specifying the kata-qemu-nvidia-gpu-snp runtime class:

   .. code-block:: yaml

      apiVersion: v1
      kind: Pod
      metadata:
        name: cuda-vectoradd-kata
        namespace: default
        annotations:
          io.katacontainers.config.hypervisor.kernel_params: "nvrc.smi.srs=1"
      spec:
        runtimeClassName: kata-qemu-nvidia-gpu-snp
        restartPolicy: Never
        containers:
          - name: cuda-vectoradd
            image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0-ubuntu22.04"
            resources:
              limits:
                nvidia.com/pgpu: "1"
                memory: 16Gi

2. Create the pod::

      $ kubectl apply -f cuda-vectoradd-kata.yaml

3. View the logs from pod after the container was started::

      $ kubectl logs -n default cuda-vectoradd-kata

   *Example Output*::

      [Vector addition of 50000 elements]
      Copy input data from the host memory to the CUDA device
      CUDA kernel launch with 196 blocks of 256 threads
      Copy output data from the CUDA device to the host memory
      Test PASSED
      Done

4. Delete the pod::

      $ kubectl delete -f cuda-vectoradd-kata.yaml

.. _managing-confidential-computing-mode:

Managing the Confidential Computing Mode
=========================================

You can set the default confidential computing mode of the NVIDIA GPUs by setting the ``ccManager.defaultMode=<on|off|devtools>`` option. The default value is off. You can set this option when you install NVIDIA GPU Operator or afterward by modifying the cluster-policy instance of the ClusterPolicy object.

When you change the mode, the manager performs the following actions:

* Evicts the other GPU Operator operands from the node.

  However, the manager does not drain user workloads. You must make sure that no user workloads are running on the node before you change the mode.

* Unbinds the GPU from the VFIO PCI device driver.
* Changes the mode and resets the GPU.
* Reschedules the other GPU Operator operands.

Three modes are supported:

* ``on`` -- Enable confidential computing.
* ``off`` -- Disable confidential computing.
* ``devtools`` -- Development mode for software development and debugging.

You can set a cluster-wide default mode and you can set the mode on individual nodes. The mode that you set on a node has higher precedence than the cluster-wide default mode.

Setting a Cluster-Wide Default Mode
------------------------------------

To set a cluster-wide mode, specify the ccManager.defaultMode field like the following example::

   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
         --type=merge \
         -p '{"spec": {"ccManager": {"defaultMode": "on"}}}'

Setting a Node-Level Mode
--------------------------

To set a node-level mode, apply the ``nvidia.com/cc.mode=<on|off|devtools>`` label like the following example::

   $ kubectl label node <node-name> nvidia.com/cc.mode=on --overwrite

The mode that you set on a node has higher precedence than the cluster-wide default mode.

Verifying a Mode Change
------------------------

To verify that changing the mode was successful, a cluster-wide or node-level change, view the nvidia.com/cc.mode and nvidia.com/cc.mode.state node labels::

   $ kubectl get node <node-name> -o json | \
       jq '.metadata.labels | with_entries(select(.key | startswith("nvidia.com/cc.mode")))'

Example output when CC mode is disabled:

.. code-block:: json

   {
     "nvidia.com/cc.mode": "off",
     "nvidia.com/cc.mode.state": "on"
   }

Example output when CC mode is enabled:

.. code-block:: json

   {
     "nvidia.com/cc.mode": "on",
     "nvidia.com/cc.mode.state": "on"
   }

The "nvidia.com/cc.mode.state" variable is either "off" or "on", with "off" meaning that mode state transition is still ongoing and "on" meaning mode state transition completed.

.. _attestation:

Attestation
===========

Confidential Containers has remote attestation support for the CPU and GPU built-in. Attestation allows a workload owner to cryptographically validate the guest TCB. This process is facilitated by components inside the guest rootfs. When a secret resource is required inside the confidential guest (to decrypt a container image, or to decrypt a model, for instance), the guest components detect which CPU and GPU enclaves are in use and collect hardware evidence from them. This evidence is sent to a remote verifier/broker known as Trustee, which evaluates the evidence and conditionally releases secrets. Features that depend on secrets depend on attestation. These features include, pulling encrypted images, authenticated registry support, sealed secrets, direct workload requests for secrets, and more. To use these features, Trustee must first be provisioned in some trusted environment.

Trustee can be set up following `upstream documentation <https://confidentialcontainers.org/docs/attestation/installation/>`_, with one key requirement for attesting NVIDIA devices. Specifically, Trustee must be configured to use the remote NVIDIA verifier, which uses NRAS to evaluate the evidence. This is not enabled by default. Enabling the remote verifier assumes that the user has entered into a `licensing agreement <https://docs.nvidia.com/attestation/cloud-services/latest/license.html>`_ covering NVIDIA attestation services.

To enable the remote verifier, add the following lines to the Trustee configuration file::

   [attestation_service.verifier_config.nvidia_verifier]
   type = "Remote"

If you are using the docker compose Trustee deployment, add the verifier type to kbs/config/as-config.json prior to starting Trustee.

Per upstream documentation, add the following annotation to the workload to point the guest components to Trustee::

   io.katacontainers.config.hypervisor.kernel_params: "agent.aa_kbc_params=cc_kbc::http://<kbs-ip>:<kbs-port>"

Now, the guest can be used with attestation. For more information on how to provision Trustee with resources and policies, see the upstream documentation.

During attestation, the GPU will be set to ready. As such, when running a workload that does attestation, it is not necessary to set the nvrc.smi.srs=1 kernel parameter.

If attestation does not succeed, debugging is best done via the Trustee log. Debug mode can be enabled by setting RUST_LOG=debug in the Trustee environment.

.. _additional-resources:

Additional Resources
====================

* NVIDIA Confidential Computing documentation is available at https://docs.nvidia.com/confidential-computing.
* Trustee Upstream Documentation: https://confidentialcontainers.org/docs/attestation/
* Trustee NVIDIA Verifier Documentation: https://github.com/confidential-containers/trustee/blob/main/deps/verifier/src/nvidia/README.md
