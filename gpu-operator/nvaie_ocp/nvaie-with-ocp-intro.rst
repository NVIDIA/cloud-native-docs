.. Date: March 14 2022
.. Author: kquinn

.. _nvaie-ocp:


###################################
NVIDIA AI Enterprise with OpenShift
###################################


NVIDIA AI Enterprise is an end-to-end, cloud-native suite of AI and data analytics software, optimized, certified, and supported by NVIDIA with  NVIDIA-Certified  Systems. Additional information can be found at the `NVIDIA AI Enterprise web page <https://www.nvidia.com/en-us/data-center/products/ai-enterprise-suite/#benefits>`_.


NVIDIA AI Enterprise 2.0 adds support for OpenShift Container Platform 4.9 and 4.10 and this section describes how customers can use NVIDIA AI Enterprise with OpenShift.

The following methods of installation are supported:

* OpenShift Container Platform bare metal/VMware vSphere with GPU Passthrough
* OpenShift Container Platform on VMware vSphere with NVIDIA vGPUs


******************************************************************************
OpenShift Container Platform bare metal or VMware vSphere with GPU Passthrough
******************************************************************************

For OpenShift Container Platform bare metal or VMware vSphere with GPU Passthrough no particular actions are needed. The default cluster policy works. For more information on creating a cluster policy see, :ref:`Create the cluster policy for the NVIDIA GPU Operator<create-cluster-policy>`.

.. note::
   The NVIDIA datacenter driver is used in both installation scenarios.

****************************************************************
OpenShift Container Platform on VMware vSphere with NVIDIA vGPUs
****************************************************************

Overview
========

This section provides insights into deploying NVIDIA AI Enterprise for VMware vSphere with RedHat OpenShift’s Enterprise Kubernetes Platform.

A broad outline of the steps involved are:

-  Install Red Hat OpenShift on VMware vSphere

-  Step 1: Create NLS License Config Map

-  Step 2: Import NGC Secret

-  Step 3: Install the Node Feature Discovery (NFD) Operator

-  Step 4: Install the NVIDIA GPU Operator

-  Step 5: Create the Cluster Policy Instance

-  Optional: Step 6: Install the NVIDIA Network Operator

Prerequisites
--------------

* Access to an NVIDIA AI Enterprise License Token
* Access to the NVIDIA AI Enterprise Enterprise Portal (this is the location where the UBI based vGPU driver image is hosted).

Introduction
============

When NVIDIA AI Enterprise is running on VMware vSphere based virtualized infrastructure, a key component is NVIDIA virtual GPU. The NVIDIA AI
Enterprise Host Software vSphere Installation Bundle (VIB) is installed on the VMware ESXi host server and it is responsible for communicating with the NVIDIA vGPU guest driver which is
installed on the guest VM. This software enables multiple VMs to share a single GPU, or if there are multiple GPUs in the server, they
can be aggregated so that a single VM can access multiple GPUs. Physical NVIDIA GPUs can support multiple virtual GPUs (vGPUs) and be assigned
directly to guest VMs under the control of NVIDIA’s AI Enterprise Host Software running in a hypervisor. Guest VMs use the NVIDIA vGPUs in the
same manner as a physical GPU that has been passed through by the hypervisor. In the VM itself, vGPU drivers are installed which support
the different license levels that are available.


**Installing NGC catalog CLI**
------------------------------

To access the NVIDIA AI Enterprise Host Software vSphere Installation Bundle (VIB), you must first download and install NGC Catalog CLI. After the NGC Catalog CLI is installed, you will need to launch a command window and then run commands to download software.

To install NGC Catalog CLI:

#. Enter the `NVIDIA NGC <https://ngc.nvidia.com/>`_.

#. In the top right corner, click **Welcome** and then select **Setup** from the menu.

#. Click **Downloads** under Install NGC CLI from the Setup page.

#. From the CLI Install page, click the Windows, Linux, or MacOS tab, according to the platform from which you will be running NGC Catalog CLI.

#. Follow the instructions to install the CLI.

#. Open a Terminal or Command Prompt

#. Verify the installation by entering ``ngc --version``. The output should be NGC Catalog CLI x.y.z where x.y.z indicates the version.

#. You must configure NGC CLI for your use so that you can run the commands. Enter the following command and then include your API key when prompted:

   .. code-block:: console

      $ ngc config set

      Enter API key [no-apikey]. Choices: [<VALID_APIKEY>, 'no-apikey']:
      (COPY/PASTE API KEY)

      Enter CLI output format type [ascii]. Choices: [ascii, csv, json]:
      ascii

      Enter org [no-org]. Choices: ['no-org']: nvlp-aienterprise

      Enter team [no-team]. Choices: ['no-team']: no-team

      Enter ace [no-ace]. Choices: ['no-ace']: no-ace

After the NGC Catalog CLI is installed, launch a command window and run the following commands to download the NVIDIA AI Enterprise Host Software (vib).

**NVIDIA AI Enterprise 2.0**

   .. code-block:: console

      ngc registry resource download-version "nvaie/vgpu_host_driver_1_1:470.105"

      Choose the correct vib for your version of ESXi

      NVIDIA-AIE\_\ **ESXi_7.0.2**\ \_Driver_470.105-1OEM.702.0.0.17630552.vib

      NVIDIA-AIE\_\ **ESXi_6.7.0**\ \_Driver_470.105-1OEM.670.0.0.8169922.vib

Hardware Requirements and prerequisites
=======================================

The following hardware requirements and prerequisites need to be met:

-  At least three NVIDIA AI Enterprise Compatible servers that are `NVIDIA-Certified System <https://docs.nvidia.com/ngc/ngc-deploy-on-premises/nvidia-certified-systems/index.html>`_.

-  At least one of NVIDIA AI Enterprise Compatible servers must have a NVIDIA AI Enterprise supported `NVIDIA GPU <https://docs.nvidia.com/ai-enterprise/overview/overview.html#supported-hardware-and-software>`_.

-  Recommended A100 for training and A30 for inference

   -  Single Root I/O Virtualization (SR-IOV) – Enabled

   -  VT-d/IOMMU – Enabled

-  The GPU accelerated server(s) must have NVIDIA AI Enterprise Host Software vSphere Installation Bundle (VIB) installed.

   .. Note::
      The installation of VMware ESXi and the NVIDIA vGPU Host and Guest Driver Software is out of the scope of this document. Please refer to
      the NVIDIA AI Enterprise Deployment Guide for detailed instructions. To set up AI-ready VMs on VMware, a vGPU profile needs to add to the VM.
      This requires installing the vGPU Host Manager on ESXi, attaching a vGPU profile, installing a vGPU guest driver on the VM, and licensing the VM.
      The following sections of the guide are helpful for reference:

-  `Installing VMware ESXi <https://docs.nvidia.com/ai-enterprise/deployment-guide/dg-installing-esxi.html>`_

-  `Installing and Configuring NVIDIA AI Enterprise Host Software <https://docs.nvidia.com/ai-enterprise/deployment-guide/dg-vgpu.html>`_

-  `Deploying the NVIDIA License System <https://docs.nvidia.com/ai-enterprise/deployment-guide/dg-nls.html>`_

-  `Creating a VM and installing the NVIDIA Driver in the VM <https://docs.nvidia.com/ai-enterprise/deployment-guide/dg-first-vm.html>`_

-  `Selecting the Correct vGPU Profile <https://docs.nvidia.com/ai-enterprise/deployment-guide/dg-first-vm.html#enabling-the-nvidia-vgpu>`_

Once the three NVIDIA AI Enterprise Compatible servers have met the above NVIDIA AI Enterprise hardware and software requirements, you must `choose a method install OpenShift Container on
vSphere <https://docs.openshift.com/container-platform/latest/installing/installing_vsphere/preparing-to-install-on-vsphere.html#choosing-a-method-to-install-ocp-on-vsphere>`__.
For the authoring of this document, the `Installer-provisioned
infrastructure (IPI) <https://docs.openshift.com/container-platform/latest/installing/installing_vsphere/preparing-to-install-on-vsphere.html#installer-provisioned-infrastructure-installation-of-openshift-container-platform-on-vsphere>`__
was chosen since it is pre-configured and automates the provisioning of resources which are required by OpenShift Container Platform.


Red Hat OpenShift on VMware vSphere
=====================================

Follow the steps outlined in the `Installing vSphere section <https://docs.openshift.com/container-platform/latest/installing/installing_vsphere/preparing-to-install-on-vsphere.html>`__
of the RedHat OpenShift documentation installing OpenShift on vSphere.

   .. note::
      When using virtualized GPUs you must change the boot method of each VM that is deployed as a worker and the VM template to be EFI.
      This requires powering down running worker VMs. The template must be converted to a VM, then change the boot method to EFI, then convert back
      to a Template. When using the `UPI install method <https://docs.openshift.com/container-platform/4.9/installing/installing_vsphere/installing-vsphere.html#installation-vsphere-machines_installing-vsphere>`_, after **Step 8** of the “Installing RHCOS and starting the OpenShift
      container Platform bootstrap process” change the boot method to EFI before **continuing to Step 9.** When using the IPI method, each VM’s boot method can be changed to EFI after VM deployment.

It is also recommended that you leverage `Running Red Hat OpenShift Container Platform on VMware Cloud Foundation <https://core.vmware.com/resource/running-red-hat-openshift-container-platform-vmware-cloud-foundation#executive-summary>`_ documentation for deployment best practices, system configuration, and reference architecture.

NVIDIA AI Enterprise 2.0 requires OpenShift Container Platform Version 4.9+

Create CLS License Config Map
=====================================

The NVIDIA License System serves licenses to NVIDIA software products. To activate licensed functionalities, a licensed client leases a
software license served over the network from an NVIDIA Cloud License System (CLS). The `NVIDIA License System
Documentation <https://docs.nvidia.com/license-system/latest/>`_ explains in full detail how to install, configure, and manage license
tokens.

.. note::
   You must `generate a Client License Token for the CLS Instance <https://docs.nvidia.com/license-system/latest/nvidia-license-system-quick-start-guide/index.html#generating-client-configuration-token-for-cls-instance>`_ prior to proceeding.

#. Create a new project called nvidia-gpu-operator

   .. image:: graphics/create_project_1.png

   .. image:: graphics/create_project_2.png

#. Select the Workloads Drop Down menu.

#. Select **ConfigMaps**

#. Click Create ConfigMap

   .. image:: graphics/create_config_map1.png

#. Enter the details for your ConfigMap for the CLS Licensing

   .. image:: graphics/create_config_maps2.png

   .. note:: You must copy/paste the information for your CLS client token into the client_configuration_token.tok parameter.

#. Click Create

Import NGC Secret
=========================

OpenShift has a secret object type which provides a mechanism for holding sensitive information such as passwords and private source repository credentials. Next you will create a secret object for storing our NGC API key (the mechanism used to authenticate your access to the
NGC container registry).

.. note:: Before you begin you will need to generate or use an existing `API key <https://docs.nvidia.com/ngc/ngc-private-registry-user-guide/index.html#generating-api-key>`__.

#. Click Secrets from the Workloads drop down

#. Click the Create Drop down

#. Select Image Pull Secret

   .. image:: graphics/secrets.png

#. Enter the following into each field

..

   Secret name: gpu-operator-secret

   Authentication type: Image registry credentials

   Registry server address: nvcr.io/nvaie

   Username: $oauthtoken

   Password: <API-KEY>

   Email: <YOUR-EMAIL>

   .. image:: graphics/secrets_2.png

#. Click Create

Install the Node Feature Discovery Operator
===========================================

Follow the guidance in :ref:`install-nfd` to install the Node Feature Discovery Operator.


Install the NVIDIA GPU Operator
===============================

Follow the guidance in :ref:`install-nvidiagpu` to install the NVIDIA GPU Operator.

.. note:: Skip the guidance associated with comes creating the cluster policy instead carry out the steps below.

Create the Cluster Policy Instance
==========================================

Next, we will create the cluster policy, which is responsible for maintaining policy resources to create pods in a cluster. `¶ <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/openshift/install-gpu-ocp.html#id1>`__
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#. In the OpenShift Container Platform web console, from the side menu, select **Operators** > **Installed Operators**, and click **NVIDIA GPU Operator**.

#. Select the **ClusterPolicy** tab, then click **Create ClusterPolicy**.

   .. note:: The platform assigns the default name *gpu-cluster-policy*.

#. Expand the drop down for **Driver config** and then **Licensing Config.** In the text box labeled **Config Map Name,** enter the name
   of the licensing config map that was previously created (for example *licensing-config*). Check the **NLS Enabled** checkbox. Refer the
   screenshot below for parameter examples and modify values accordingly.

   .. note:: This was previously created in Step 2: Create CLS License Config Map.

.. image:: graphics/cluster_policy_1.png

#. Scroll down to specify repository path, image name and NVIDIA vGPU driver version bundled under **Driver** section. Refer the screenshot below for parameter examples and modify values accordingly.

..

       nlsEnabled: true

       repository: nvcr.io/nvaie

       version: 510.47.03

       image: vgpu-guest-driver

#. Expand the **Advanced configuration** menu and specify the imagePullSecret . (eg: *gpu-operator-secret*)

   .. note:: This was previously created in Step 3: Import NGC Secret.

   .. image:: graphics/pull-secret.png

#. Click **Create**.

The GPU Operator will proceed to install all the required components to set up the NVIDIA GPUs in the OpenShift cluster.

.. note:: Wait at least 10-20 minutes before digging deeper into any form of troubleshooting because this may take some time to finish.

The status of the newly deployed ClusterPolicy *gpu-cluster-policy* for the NVIDIA GPU Operator changes to State:ready when the installation succeeds.

.. image:: graphics/cluster-policy-suceed.png


Verify the ClusterPolicy installation from the CLI run:

   .. code-block:: console

      $ oc get nodes -o=custom-columns='Node:metadata.name,GPUs:status.capacity.nvidia\.com/gpu'

This lists each node and the number of GPUs it has available to Kubernetes.

   **Example output**

   .. code-block:: console

      $ oc get nodes -o=custom-columns='Node:metadata.name,GPUs:status.capacity.nvidia\.com/gpu'

        Node GPUs

        nvaie-ocp-7rfr8-master-0 <none>

        nvaie-ocp-7rfr8-master-1 <none>

        nvaie-ocp-7rfr8-master-2 <none>

        nvaie-ocp-7rfr8-worker-7x5km 1

        nvaie-ocp-7rfr8-worker-9jgmk <none>

        nvaie-ocp-7rfr8-worker-jntsp 1

        nvaie-ocp-7rfr8-worker-zkggt <none>
