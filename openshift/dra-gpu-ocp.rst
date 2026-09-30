.. Date: Sept 30 2026
.. Author: nbugrovs

.. _dra-gpu-ocp:

########################################################
Installing the NVIDIA GPU Operator with DRA on OpenShift
########################################################

************
Introduction
************

Dynamic Resource Allocation (DRA) is a Kubernetes API for requesting, configuring, and sharing specialized devices such as GPUs.
Starting with NVIDIA GPU Operator v26.7, you can use the ``GPUCluster`` and ``NVIDIADriver`` custom resources to enable DRA-based GPU allocation on Red Hat OpenShift Container Platform, as an alternative to the Device Plugin-based ``ClusterPolicy`` workflow described in :ref:`install-nvidiagpu`.

.. important::

   A cluster can have either a ``GPUCluster`` resource for DRA or a ``ClusterPolicy`` resource for the Device Plugin, but not both.
   This page assumes a new installation. Refer to :external+gpuop:doc:`dra-intro-install` for the full DRA vs. Device Plugin capability comparison, feature-maturity matrix, and limitations, which apply equally to OpenShift.

*************
Prerequisites
*************

* Red Hat OpenShift Container Platform 4.21 or later. This guide is validated on Red Hat OpenShift Container Platform 4.22.
* A working OpenShift cluster with a GPU worker node. Refer to :doc:`prerequisites`.
* The Node Feature Discovery (NFD) Operator installed and running. Refer to :ref:`install-nfd`.
* No ``ClusterPolicy`` resource exists in the cluster:

  .. code-block:: console

     $ oc get clusterpolicy

  If a ``ClusterPolicy`` resource exists, use a different cluster for the DRA workflow, or remove the existing installation first. Refer to :doc:`clean-up`.

.. note::

   OpenShift's CRI-O container runtime supports the Container Device Interface (CDI) required by the DRA driver without additional configuration.

***************************
Installing the GPU Operator
***************************

Follow these steps to install the NVIDIA GPU Operator by using the OpenShift CLI (``oc``), then create ``GPUCluster`` and ``NVIDIADriver`` resources instead of ``ClusterPolicy``.

#. Create a namespace for the NVIDIA GPU Operator and save it in the ``nvidia-gpu-operator.yaml`` file:

   .. code-block:: yaml

      apiVersion: v1
      kind: Namespace
      metadata:
        name: nvidia-gpu-operator

   .. code-block:: console

      $ oc create -f nvidia-gpu-operator.yaml

#. Create an ``OperatorGroup`` CR and save it in the ``nvidia-gpu-operatorgroup.yaml`` file:

   .. code-block:: yaml

      apiVersion: operators.coreos.com/v1
      kind: OperatorGroup
      metadata:
        name: nvidia-gpu-operator-group
        namespace: nvidia-gpu-operator
      spec:
        targetNamespaces:
        - nvidia-gpu-operator

   .. code-block:: console

      $ oc create -f nvidia-gpu-operatorgroup.yaml

   .. note:: Refer to :ref:`install-gpu-ocp` for detailed namespace and ``OperatorGroup`` creation steps if you have not already created them.

#. Select the ``v${version}`` channel explicitly and look up the starting CSV:

   .. code-block:: console

      $ CHANNEL=v${version}
      $ STARTING_CSV=$(oc get packagemanifests/gpu-operator-certified -n openshift-marketplace -ojson | jq -r '.status.channels[] | select(.name == "'$CHANNEL'") | .currentCSV')

#. Create the ``Subscription`` CR:

   .. code-block:: console

      $ cat <<EOF > nvidia-gpu-sub.yaml
      apiVersion: operators.coreos.com/v1alpha1
      kind: Subscription
      metadata:
        name: gpu-operator-certified
        namespace: nvidia-gpu-operator
      spec:
        channel: $CHANNEL
        installPlanApproval: Manual
        name: gpu-operator-certified
        source: certified-operators
        sourceNamespace: openshift-marketplace
        startingCSV: $STARTING_CSV
      EOF

      $ oc create -f nvidia-gpu-sub.yaml

#. Approve the install plan:

   .. code-block:: console

      $ INSTALL_PLAN=$(oc get installplan -n nvidia-gpu-operator -oname)
      $ oc patch $INSTALL_PLAN -n nvidia-gpu-operator --type merge --patch '{"spec":{"approved":true }}'

******************************
Create the GPUCluster instance
******************************

The ``GPUCluster`` custom resource definition (CRD) and a default example are provided by the GPU Operator CSV, the same way ``ClusterPolicy`` is provided.

#. Extract the default ``GPUCluster`` example from the CSV:

   .. code-block:: console

      $ oc get csv -n nvidia-gpu-operator $STARTING_CSV -o jsonpath='{.metadata.annotations.alm-examples}' | jq -r 'map(select(.kind == "GPUCluster")) | .[0]' > gpucluster.json

   The default example, stored in ``gpucluster.json``, is similar to the following:

   .. code-block:: json

      {
        "apiVersion": "nvidia.com/v1alpha1",
        "kind": "GPUCluster",
        "metadata": {
          "name": "gpu-cluster"
        },
        "spec": {
          "draDriver": {
            "repository": "nvcr.io/nvidia",
            "image": "dra-driver-nvidia-gpu",
            "version": "v0.5.0",
            "imagePullPolicy": "IfNotPresent",
            "computeDomains": {
              "enabled": true
            }
          },
          "dcgm": {
            "enabled": false
          },
          "dcgmExporter": {
            "enabled": true
          }
        }
      }

   .. note:: ``GPUCluster`` does not manage the NVIDIA GPU driver. Create an ``NVIDIADriver`` resource in the next section to install the driver.

#. Apply the ``GPUCluster`` resource:

   .. code-block:: console

      $ oc apply -f gpucluster.json

   .. code-block:: console

      gpucluster.nvidia.com/gpu-cluster created

********************************
Create the NVIDIADriver instance
********************************

#. Extract the default ``NVIDIADriver`` example from the CSV:

   .. code-block:: console

      $ oc get csv -n nvidia-gpu-operator $STARTING_CSV -o jsonpath='{.metadata.annotations.alm-examples}' | jq -r 'map(select(.kind == "NVIDIADriver")) | .[0]' > nvidiadriver.json

   The default example, stored in ``nvidiadriver.json``, is similar to the following (abbreviated):

   .. code-block:: json

      {
        "apiVersion": "nvidia.com/v1alpha1",
        "kind": "NVIDIADriver",
        "metadata": {
          "name": "gpu-driver"
        },
        "spec": {
          "driverType": "gpu",
          "repository": "nvcr.io/nvidia",
          "image": "driver",
          "version": "sha256:<digest>",
          "nodeSelector": {}
        }
      }

   .. note:: The default ``version`` field pins a specific driver build by image digest rather than a release tag such as ``580.65.06``. The digest satisfies the DRA driver's minimum required GPU driver version of 580 or later. Change ``repository``, ``image``, and ``version`` to reference a different driver image if required, following the same pattern as the ``ClusterPolicy`` ``driver`` fields described in :ref:`create-cluster-policy`.

#. Apply the ``NVIDIADriver`` resource:

   .. code-block:: console

      $ oc apply -f nvidiadriver.json

   .. code-block:: console

      nvidiadriver.nvidia.com/gpu-driver created

   The Operator builds the driver container by using the OpenShift Driver Toolkit (DTK), the same mechanism used for the ``ClusterPolicy`` driver daemonset. If the driver pod does not become ready, refer to :ref:`broken-dtk` for troubleshooting steps that apply to both workflows.

***********************
Verify the installation
***********************

#. Confirm that the ``GPUCluster`` and ``NVIDIADriver`` resources are ready:

   .. code-block:: console

      $ oc get gpucluster gpu-cluster
      $ oc get nvidiadriver -n nvidia-gpu-operator

   *Example Output*

   .. code-block:: console

      NAME          STATUS   AGE
      gpu-cluster   ready    6m38s

      NAME         STATUS   DEFAULT   AGE
      gpu-driver   ready    false     2026-09-30T13:07:35Z

   .. note:: A ``ready`` status confirms that the Operator reconciled the desired state. If your cluster has no GPU nodes labeled yet, the managed pods in the next step do not start until the Node Feature Discovery Operator labels a GPU node.

#. Confirm that the managed pods are running in the GPU Operator namespace:

   .. code-block:: console

      $ oc get pods -n nvidia-gpu-operator

   *Example Output*

   .. code-block:: console

      NAME                                            READY   STATUS    RESTARTS   AGE
      gpu-operator-6b4b79979d-vl9pw                   1/1     Running   0          3h21m
      nvidia-dcgm-exporter-dra-pc85w                  1/1     Running   0          8m45s
      nvidia-dra-driver-controller-6fc968db58-fzfw7   1/1     Running   0          171m
      nvidia-dra-driver-kubelet-plugin-dhjcd          2/2     Running   0          8m34s
      nvidia-dra-validator-thqnh                      1/1     Running   0          8m45s
      nvidia-gpu-driver-rhel9-59f4c8db85-pn5c5        2/2     Running   0          8m45s

   The driver daemon set is named ``nvidia-gpu-driver-rhel9-<hash>`` and its node selector includes the RHCOS ``OSTREE_VERSION`` label, similar to the ``nvidia-driver-daemonset-<RHCOS-version>`` naming used by ``ClusterPolicy``.

#. Confirm that the DRA ``DeviceClass`` objects are available:

   .. code-block:: console

      $ oc get deviceclass

   *Example Output*

   .. code-block:: console

      NAME                                        AGE
      compute-domain-daemon.nvidia.com            3h
      compute-domain-default-channel.nvidia.com   3h
      gpu.nvidia.com                              3h
      mig.nvidia.com                              3h
      vfio.gpu.nvidia.com                         3h

#. Confirm that a ``ResourceSlice`` was published for your GPU node:

   .. code-block:: console

      $ oc get resourceslice -o yaml

   *Partial Output*

   .. code-block:: yaml

      apiVersion: resource.k8s.io/v1
      kind: ResourceSlice
      spec:
        devices:
        - attributes:
            addressingMode:
              string: HMM
            architecture:
              string: Turing
            brand:
              string: Nvidia
            cudaComputeCapability:
              version: 7.5.0
            cudaDriverVersion:
              version: 13.2.0
            driverVersion:
              version: 595.91.7
            productName:
              string: Tesla T4
            uuid:
              string: GPU-35cc335d-cbdd-999f-6289-38d96976de78
          capacity:
            memory:
              value: 15Gi
          name: gpu-0
        driver: gpu.nvidia.com

*****************************
Running a sample DRA workload
*****************************

Request a full GPU by creating a ``ResourceClaimTemplate`` and a pod that references it.

#. Create a project for the sample workload:

   .. code-block:: console

      $ oc new-project gpu-dra-demo

#. Create a ``ResourceClaimTemplate`` that requests one GPU by using the managed ``gpu.nvidia.com`` ``DeviceClass``:

   .. code-block:: console

      $ cat <<EOF | oc create -f -
      apiVersion: resource.k8s.io/v1
      kind: ResourceClaimTemplate
      metadata:
        namespace: gpu-dra-demo
        name: single-gpu
      spec:
        spec:
          devices:
            requests:
            - name: gpu
              exactly:
                deviceClassName: gpu.nvidia.com
      EOF

#. Create a pod that references the ``ResourceClaimTemplate``:

   .. code-block:: console

      $ cat <<EOF | oc create -f -
      apiVersion: v1
      kind: Pod
      metadata:
        namespace: gpu-dra-demo
        name: gpu-pod
      spec:
        containers:
        - name: workload
          image: nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0-ubi8
          command: ["bash", "-c"]
          args: ["nvidia-smi -L; sleep 9999"]
          resources:
            claims:
            - name: gpu
        resourceClaims:
        - name: gpu
          resourceClaimTemplateName: single-gpu
      EOF

   OpenShift can report a ``PodSecurity`` admission warning similar to the following. The warning does not block pod creation under the default namespace Pod Security level and can be ignored for this example:

   .. code-block:: console

      Warning: would violate PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "workload" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "workload" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "workload" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "workload" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")

#. Verify that the pod was allocated a GPU:

   .. code-block:: console

      $ oc exec -n gpu-dra-demo gpu-pod -- nvidia-smi -L

   *Example Output*

   .. code-block:: console

      GPU 0: Tesla T4 (UUID: GPU-35cc335d-cbdd-999f-6289-38d96976de78)

#. Clean up the sample workload:

   .. code-block:: console

      $ oc delete project gpu-dra-demo

For more allocation patterns, such as selecting a GPU by product name or memory size, sharing a GPU across containers, or requesting multiple GPUs, refer to `Request full GPUs <https://dra-driver-nvidia-gpu.sigs.k8s.io/docs/guides/gpu-allocation/allocating-gpus/>`__ in the upstream DRA driver documentation.

***********************************
Multi-Node NVLink and ComputeDomain
***********************************

By default, the ``GPUCluster`` resource enables ComputeDomain support (``draDriver.computeDomains.enabled: true``), which deploys the ComputeDomain controller and kubelet plugin and publishes generic ``daemon`` and ``channel`` devices under the ``compute-domain.nvidia.com`` driver, even on hardware without Multi-Node NVLink (MNNVL). This is expected and does not require any additional configuration on typical GPU nodes.

ComputeDomain support is intended for NVIDIA Grace Blackwell systems with Multi-Node NVLink, such as NVIDIA HGX GB200 NVL72 or NVIDIA HGX GB300 NVL72. Configuring and using ComputeDomains for multi-node workloads is out of scope for this guide. Refer to :external+gpuop:doc:`dra-intro-install` for ComputeDomain prerequisites and configuration, and to :external+gpuop:doc:`gpu-operator-kubevirt-dra` for KubeVirt and OpenShift Virtualization VFIO passthrough with DRA.

*********
Uninstall
*********

#. Delete any user-created ``ResourceClaims`` and workload pods that reference GPUs, and confirm that the claims are removed.

#. Delete the ``NVIDIADriver`` and ``GPUCluster`` resources:

   .. code-block:: console

      $ oc delete nvidiadriver -n nvidia-gpu-operator --all
      $ oc delete gpucluster gpu-cluster

#. Uninstall the GPU Operator subscription and CSV. Refer to :doc:`clean-up` for the complete uninstall procedure.

For finalizer-related recovery procedures, such as recovering from an uninstall that leaves orphaned ``ResourceClaims``, refer to the Troubleshooting section of :external+gpuop:doc:`dra-intro-install`.
