.. Date: Nov 15 2021
.. Author: kquinn

.. _install-nfd:

####################################################
Installing the Node Feature Discovery (NFD) Operator
####################################################

The Node Feature Discovery (NFD) Operator is a prerequisite for the **NVIDIA GPU Operator**. Install the NFD Operator using the Red Hat OperatorHub catalog in the OpenShift Container Platform web console .

#. Follow the Red Hat documentation guidance in `The Node Feature Discovery Operator <https://docs.openshift.com/container-platform/latest/hardware_enablement/psap-node-feature-discovery-operator.html>`_ to install the Node Feature Discovery Operator.

#. Verify the Node Feature Discovery Operator is running:

   .. code-block:: console

      $ oc get pods -n openshift-nfd

   .. code-block:: console

      NAME                                      READY   STATUS    RESTARTS   AGE
      nfd-controller-manager-7f86ccfb58-nqgxm   2/2     Running   0          11m

#. When the Node Feature Discovery is installed, create an instance of Node Feature Discovery using the **NodeFeatureDiscovery** tab.

 #. Click **Operators** > **Installed Operators** from the side menu.

 #. Find the **Node Feature Discovery** entry.

 #. Click **NodeFeatureDiscovery** under the **Provided APIs** field.

 #. Click **Create NodeFeatureDiscovery**.

 #. In the subsequent screen click **Create**. This starts the Node Feature Discovery Operator that proceeds to label the nodes in the cluster that have GPUs.

      .. note:: The values pre-populated by the OperatorHub are valid for the GPU Operator.

*************************************************************************
Verify that the Node Feature Discovery Operator is functioning correctly
*************************************************************************

The Node Feature Discovery Operator uses vendor PCI IDs to identify hardware in a node. NVIDIA uses the PCI ID 10de. Use the OpenShift Container Platform web console or the CLI to verify that the Node Feature Discovery Operator is functioning correctly.


#. In the OpenShift Container Platform web console, click **Compute** > **Nodes** from the side menu.

#. Select a worker node that you know contains a GPU.

#. Click the **Details** tab.

#. Under **Node labels** verify that the following label is present:

   .. code-block:: console

      feature.node.kubernetes.io/pci-10de.present=true

   .. note:: ``0x10de`` is the PCI vendor ID that is assigned to NVIDIA.

#. Verify the GPU device (``pci-10de``) is discovered on the GPU node:

   .. code-block:: console

      $ oc describe node | egrep 'Roles|pci' | grep -v master

   .. code-block:: console

      Roles:              worker
                          feature.node.kubernetes.io/pci-10de.present=true
                          feature.node.kubernetes.io/pci-1d0f.present=true
      Roles:              worker
                          feature.node.kubernetes.io/pci-1013.present=true
                          feature.node.kubernetes.io/pci-8086.present=true
      Roles:              worker
                          feature.node.kubernetes.io/pci-1013.present=true
                          feature.node.kubernetes.io/pci-8086.present=true
      Roles:              worker
                          feature.node.kubernetes.io/pci-1013.present=true
                          feature.node.kubernetes.io/pci-8086.present=true
