.. Date: July 30 2020
.. Author: pramarao

.. _operator-install-guide:

*****************************************
Getting Started
*****************************************

This document provides instructions, including pre-requisites for getting started with the NVIDIA GPU Operator.

----

Red Hat OpenShift 4
====================

For installing the GPU Operator on clusters with Red Hat OpenShift using RHCOS worker nodes,
follow the :ref:`user guide <openshift-introduction>`.


----

VMware vSphere with Tanzu
=========================

For installing the GPU Operator on VMware vSphere with Tanzu leveraging NVIDIA AI Enterprise,
follow the :ref:`NVIDIA AI Enterprise document <install-gpu-operator-nvaie>`.

----

Google Cloud Anthos
====================

For getting started with NVIDIA GPUs for Google Cloud Anthos, follow the getting started
`document <https://docs.nvidia.com/datacenter/cloud-native/kubernetes/anthos-guide.html>`_.

----

Prerequisites
=============

Before installing the GPU Operator, you should ensure that the Kubernetes cluster meets some prerequisites.

#. All worker nodes in the Kubernetes cluster must run the same operating system version to use the NVIDIA GPU Driver container.
   Alternatively, if you pre-install the NVIDIA GPU Driver on the nodes, then you can run different operating systems.

#. Nodes must be configured with a container engine such as Docker CE/EE, ``cri-o``, or ``containerd``. For **docker**, follow the official install
   `instructions <https://docs.docker.com/engine/install/>`_.
#. Node Feature Discovery (NFD) is a dependency for the Operator on each node.
   By default, NFD master and worker are automatically deployed by the Operator.
   If NFD is already running in the cluster, then you must disable deploying NFD when you install the Operator.

   One way to determine if NFD is already running in the cluster is to check for a NFD label on your nodes:

   .. code-block:: console

      $ kubectl get nodes -o json | jq '.items[].metadata.labels | keys | any(startswith("feature.node.kubernetes.io"))'

   If the command output is ``true``, then NFD is already running in the cluster.

#. For monitoring in Kubernetes 1.13 and 1.14, enable the kubelet ``KubeletPodResources`` `feature <https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/>`_
   gate. From Kubernetes 1.15 onwards, its enabled by default.

.. note::

   To enable the ``KubeletPodResources`` feature gate, run the following command: ``echo -e "KUBELET_EXTRA_ARGS=--feature-gates=KubeletPodResources=true" | sudo tee /etc/default/kubelet``

Before installing the GPU Operator on NVIDIA vGPU, ensure the following.

#. The NVIDIA vGPU Host Driver version 12.0 (or later) is pre-installed on all hypervisors hosting NVIDIA vGPU accelerated Kubernetes worker node virtual machines. Please refer to `NVIDIA vGPU Documentation <https://docs.nvidia.com/grid/12.0/index.html>`_ for details.
#. A NVIDIA vGPU License Server is installed and reachable from all Kubernetes worker node virtual machines.
#. A private registry is available to upload the NVIDIA vGPU specific driver container image.
#. Each Kubernetes worker node in the cluster has access to the private registry. Private registry access is usually managed through imagePullSecrets. See the Kubernetes Documentation for more information. The user is required to provide these secrets to the NVIDIA GPU-Operator in the driver section of the values.yaml file.
#. Git and Docker/Podman are required to build the vGPU driver image from source repository and push to local registry.

.. note::

    Uploading the NVIDIA vGPU driver to a publicly available repository or otherwise publicly sharing the driver is a violation of the NVIDIA vGPU EULA.


The rest of this document includes instructions for installing the GPU Operator on supported Linux distributions.

.. Shared content for the GPU Operator install

.. include:: install-gpu-operator.rst

Running Sample GPU Applications
=================================

CUDA VectorAdd
--------------

In the first example, let's run a simple CUDA sample, which adds two vectors together:


#. Create a file, such as ``cuda-vectoradd.yaml``, with contents like the following:

   .. code-block:: yaml

      apiVersion: v1
      kind: Pod
      metadata:
        name: cuda-vectoradd
      spec:
        restartPolicy: OnFailure
        containers:
        - name: cuda-vectoradd
          image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda11.7.1-ubuntu20.04"
          resources:
            limits:
              nvidia.com/gpu: 1

#. Run the pod:

   .. code-block:: console

      $ kubectl apply -f cuda-vectoradd.yaml

   The pod starts, runs the ``vectorAdd`` command, and then exits.

#. View the logs from the container:

   .. code-block:: console

      $ kubectl logs pod/cuda-vectoradd

   *Example Output*

   .. code-block:: output

      [Vector addition of 50000 elements]
      Copy input data from the host memory to the CUDA device
      CUDA kernel launch with 196 blocks of 256 threads
      Copy output data from the CUDA device to the host memory
      Test PASSED
      Done

#. Removed the stopped pod:

   .. code-block:: console

      $ kubectl delete -f cuda-vectoradd.yaml

   *Example Output*

   .. code-block:: output

      pod "cuda-vectoradd" deleted


Jupyter Notebook
------------------

You can perform the following steps to deploy Jupyter Notebook in your cluster:

#. Create a file, such as ``tf-notebook.yaml``, with contents like the following example:

   .. literalinclude:: ./manifests/input/tf-notebook.yaml
      :language: yaml

#. Apply the manifest to deploy the pod and start the service:

   .. code-block:: console

      $ kubectl apply -f tf-notebook.yaml

#. Check the pod status:

   .. code-block:: console

      $ kubectl get pod tf-notebook

   *Example Output*

   .. code-block:: output

      NAMESPACE   NAME          READY   STATUS      RESTARTS   AGE
      default     tf-notebook   1/1     Running     0          3m45s

#. Because the manifest includes a service, get the external port for the notebook:

   .. code-block:: console

      $ kubectl get svc tf-notebook

   *Example Output*

   .. code-block:: output

      NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)       AGE
      tf-notebook   NodePort    10.106.229.20   <none>        80:30001/TCP  4m41s

#. Get the token for the Jupyter notebook:

   .. code-block:: console

      $ kubectl logs tf-notebook

   *Example Output*

   .. code-block:: output

      [I 21:50:23.188 NotebookApp] Writing notebook server cookie secret to /root/.local/share/jupyter/runtime/notebook_cookie_secret
      [I 21:50:23.390 NotebookApp] Serving notebooks from local directory: /tf
      [I 21:50:23.391 NotebookApp] The Jupyter Notebook is running at:
      [I 21:50:23.391 NotebookApp] http://tf-notebook:8888/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9
      [I 21:50:23.391 NotebookApp]  or http://127.0.0.1:8888/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9
      [I 21:50:23.391 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
      [C 21:50:23.394 NotebookApp]

      To access the notebook, open this file in a browser:
         file:///root/.local/share/jupyter/runtime/nbserver-1-open.html
      Or copy and paste one of these URLs:
         http://tf-notebook:8888/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9
      or http://127.0.0.1:8888/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9

The notebook should now be accessible from your browser at this URL:
`http://your-machine-ip:30001/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9 <http://your-machine-ip:30001/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9>`_.

Demo
======

Check out the demo below where we scale GPU nodes in a K8s cluster using the GPU Operator:

.. image:: graphics/gpu-operator-demo.gif
   :width: 1440

GPU Telemetry
==============

To gather GPU telemetry in Kubernetes, the GPU Operator deploys the ``dcgm-exporter``. ``dcgm-exporter``, based
on `DCGM <https://developer.nvidia.com/dcgm>`_ exposes GPU metrics for Prometheus and can be visualized using Grafana. ``dcgm-exporter`` is architected to take advantage of
``KubeletPodResources`` `API <https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/>`_ and exposes GPU metrics in a format that can be
scraped by Prometheus.

Custom Metrics Config
---------------------

With GPU Operator users can customize the metrics to be collected by ``dcgm-exporter``. Below are the steps for this

 1. Fetch the metrics file and save as dcgm-metrics.csv

   .. code-block:: console

      $ curl https://raw.githubusercontent.com/NVIDIA/dcgm-exporter/main/etc/dcp-metrics-included.csv > dcgm-metrics.csv

 2. Edit the metrics file as required to add/remove any metrics to be collected.

 3. Create a Namespace ``gpu-operator`` if one is not already present.

  .. code-block:: console

     $ kubectl create namespace gpu-operator

 4. Create a ConfigMap using the file edited above.

   .. code-block:: console

      $ kubectl create configmap metrics-config -n gpu-operator --from-file=dcgm-metrics.csv

 5. Install GPU Operator with additional options ``--set dcgmExporter.config.name=metrics-config`` and
    ``--set dcgmExporter.env[0].name=DCGM_EXPORTER_COLLECTORS --set dcgmExporter.env[0].value=/etc/dcgm-exporter/dcgm-metrics.csv``


Collecting Metrics on NVIDIA DGX A100 with DGX OS
----------------------------------------------------

NVIDIA DGX systems running with DGX OS bundles drivers, DCGM, etc. in the system image and have `nv-hostengine` running already.
To avoid any compatibility issues, it is recommended to have `dcgm-exporter` connect to the existing `nv-hostengine` daemon to gather/publish
GPU telemetry data.

.. warning::

   The `dcgm-exporter` container image includes a DCGM client library (``libdcgm.so``) to communicate with
   `nv-hostengine`. In this deployment scenario we have `dcgm-exporter` (or rather ``libdcgm.so``) connect
   to an existing `nv-hostengine` running on the host. The DCGM client library uses an internal protocol to exchange
   information with `nv-hostengine`. To avoid any potential incompatibilities between the container image's DCGM client library
   and the host's `nv-hostengine`, it is strongly recommended to use a version of DCGM on which `dcgm-exporter` is based is
   greater than or equal to (but not less than) the version of DCGM running on the host. This can be easily determined by
   comparing the version tags of the `dcgm-exporter` image and by running ``nv-hostengine --version`` on the host.

In this scenario, we need to set ``DCGM_REMOTE_HOSTENGINE_INFO`` to ``localhost:5555`` for `dcgm-exporter` to connect to `nv-hostengine` running on the host.

.. code-block:: console

   $ kubectl patch clusterpolicy/cluster-policy --type='json' -p='[{"op": "add", "path": "/spec/dcgmExporter/env/-", "value":{"name":"DCGM_REMOTE_HOSTENGINE_INFO", "value":"localhost:5555"}}]'

Verify `dcgm-exporter` pod is running after this change

.. code-block:: console

   $ kubectl get pods -l app=nvidia-dcgm-exporter --all-namespaces

Refer to
`Setting up Prometheus <https://docs.nvidia.com/datacenter/cloud-native/gpu-telemetry/latest/kube-prometheus.html>`__
to complete the installation.

.. _operator-upgrades:

Upgrading the GPU Operator
==========================

Using Helm
-----------

The GPU Operator supports dynamic updates to existing resources.
This ability enables the GPU Operator to ensure settings from the cluster policy specification are always applied and current.

Because Helm does not `support <https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations>`_ automatic upgrade of existing CRDs,
you can upgrade the GPU Operator chart manually or by enabling a Helm hook.

Option 1 - manually upgrade CRD
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. blockdiag::

   blockdiag admin {
      A [label = "Update CRD from the latest chart", color = "#00CC00"];
      B [label = "Upgrade via Helm"];

      A -> B;
   }

With this workflow, all existing GPU operator resources are updated inline and the cluster policy resource is patched with updates from ``values.yaml``.

#. Specify the Operator release tag in an environment variable:

   .. code-block:: console

      $ export RELEASE_TAG=v23.3.1

#. Apply the custom resource definition for the cluster policy:

   .. code-block:: console

      $ kubectl apply -f \
          https://gitlab.com/nvidia/kubernetes/gpu-operator/-/raw/$RELEASE_TAG/deployments/gpu-operator/crds/nvidia.com_clusterpolicies_crd.yaml

   *Example Output*

   .. code-block:: output

      customresourcedefinition.apiextensions.k8s.io/clusterpolicies.nvidia.com configured

#. Apply the custom resource definition for Node Feature Discovery:

   .. code-block:: console

      $ kubectl apply -f \
          https://gitlab.com/nvidia/kubernetes/gpu-operator/-/raw/$RELEASE_TAG/deployments/gpu-operator/charts/node-feature-discovery/crds/nfd-api-crds.yaml

   *Example Output*

   .. code-block:: output

      customresourcedefinition.apiextensions.k8s.io/nodefeaturerules.nfd.k8s-sigs.io configured

#. Update the information about the Operator chart:

   .. code-block:: console

      $ helm repo update nvidia

   *Example Output*

   .. code-block:: output

      Hang tight while we grab the latest from your chart repositories...
      ...Successfully got an update from the "nvidia" chart repository
      Update Complete. ⎈Happy Helming!⎈

#. Fetch the values from the chart:

   .. code-block:: console

      $ helm show values nvidia/gpu-operator --version=$RELEASE_TAG > values-$RELEASE_TAG.yaml

#. Update the values file as needed.

#. Upgrade the Operator:

   .. code-block:: console

      $ helm upgrade gpu-operator nvidia/gpu-operator -n gpu-operator -f values-$RELEASE_TAG.yaml

   *Example Output*

   .. code-block:: output

      Release "gpu-operator" has been upgraded. Happy Helming!
      NAME: gpu-operator
      LAST DEPLOYED: Thu Apr 20 15:05:52 2023
      NAMESPACE: gpu-operator
      STATUS: deployed
      REVISION: 2
      TEST SUITE: None


Option 2 - auto upgrade CRD using Helm hook
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Starting with GPU Operator v22.09, a ``pre-upgrade`` Helm `hook <https://helm.sh/docs/topics/charts_hooks/#the-available-hooks>`_ is utilized to automatically upgrade to latest CRD.
A new parameter ``operator.upgradeCRD`` is added to to trigger this hook during GPU Operator upgrade using Helm. This is disabled by default.
This parameter needs to be set using ``--set operator.upgradeCRD=true`` option during upgrade command as below.

#. Specify the Operator release tag in an environment variable:

   .. code-block:: console

      $ export RELEASE_TAG=v23.3.1

#. Update the information about the Operator chart:

   .. code-block:: console

      $ helm repo update nvidia

   *Example Output*

   .. code-block:: output

      Hang tight while we grab the latest from your chart repositories...
      ...Successfully got an update from the "nvidia" chart repository
      Update Complete. ⎈Happy Helming!⎈

#. Fetch the values from the chart:

   .. code-block:: console

      $ helm show values nvidia/gpu-operator --version=$RELEASE_TAG > values-$RELEASE_TAG.yaml

#. Update the values file as needed.

#. Upgrade the Operator:

   .. code-block:: console

      $ helm upgrade gpu-operator nvidia/gpu-operator -n gpu-operator \
          --set operator.upgradeCRD=true --disable-openapi-validation -f values-$RELEASE_TAG.yaml

   .. note::

      * Option ``--disable-openapi-validation`` is required in this case so that Helm will not try to validate if CR instance from the new chart is valid as per old CRD.
        Since CR instance in the Chart is valid for the upgraded CRD, this will be compatible.

      * Helm hooks used with the GPU Operator use the operator image itself. If operator image itself cannot be pulled successfully (either due to network error or an invalid NGC registry secret in case of NVAIE), hooks will fail.
        In this case, chart needs to be deleted using ``--no-hooks`` option to avoid deletion to be hung on hook failures.

Cluster Policy Updates
^^^^^^^^^^^^^^^^^^^^^^^

The GPU Operator also supports dynamic updates to the ``ClusterPolicy`` CustomResource using ``kubectl``:

.. code-block:: console

   $ kubectl edit clusterpolicy

After the edits are complete, Kubernetes will automatically apply the updates to cluster.

Additional Controls for Driver Upgrades
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

While most of the GPU Operator managed daemonsets can be upgraded seamlessly, the NVIDIA driver daemonset has special considerations.
Refer to :ref:`GPU Driver Upgrades` for more information.

Using OLM in OpenShift
-----------------------

For upgrading the GPU Operator when running in OpenShift, refer to the official documentation on upgrading installed operators:
https://docs.openshift.com/container-platform/4.8/operators/admin/olm-upgrading-operators.html


Uninstall
===========================

To uninstall the operator:

.. code-block:: console

   $ helm delete -n gpu-operator $(helm list -n gpu-operator | grep gpu-operator | awk '{print $1}')

You should now see all the pods being deleted:

.. code-block:: console

   $ kubectl get pods -n gpu-operator

.. code-block:: console

   No resources found.

By default, Helm does not `support <https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations>`_ deletion of existing CRDs when the Chart is deleted.
Thus ``clusterpolicy`` CRD will still remain by default.

.. code-block:: console

   $ kubectl get crds -A | grep -i clusterpolicies.nvidia.com

To overcome this, a ``post-delete`` `hook <https://helm.sh/docs/topics/charts_hooks/#the-available-hooks>`_ is used in the GPU Operator to perform the CRD cleanup. A new parameter ``operator.cleanupCRD``
is added to enable this hook. This is disabled by default. This parameter needs to be enabled with ``--set operator.cleanupCRD=true`` during install or upgrade for automatic CRD cleanup to happen on chart deletion.

.. note::

   * After un-install of GPU Operator, the NVIDIA driver modules might still be loaded.
     Either reboot the node or unload them using the following command:

     .. code-block:: console

        $ sudo rmmod nvidia_modeset nvidia_uvm nvidia

   * Helm hooks used with the GPU Operator use the operator image itself. If operator image itself cannot be pulled successfully (either due to network error or an invalid NGC registry secret in case of NVAIE), hooks will fail.
     In this case, chart needs to be deleted using ``--no-hooks`` option to avoid deletion to be hung on hook failures.
