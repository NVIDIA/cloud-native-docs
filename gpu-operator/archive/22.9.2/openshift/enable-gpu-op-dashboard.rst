.. Date: November 16 2021
.. Author: kquinn

.. _enable-gpu-operator-dashboard-22.9.2:

###################################
Enable the GPU Operator Dashboard
###################################

*************
Prerequisites
*************

* Install `Helm <https://helm.sh/docs/intro/install/>`_
* OpenShift Container Platform 4.10+

Follow this guidance to provide GPU usage information in the cluster utilization screen in the OpenShift Container Platform web console.

******************************************************************
Enable the NVIDIA GPU Operator usage information
******************************************************************

#. Add the ``helm`` repo:

   .. code-block:: console

      $ helm repo add rh-ecosystem-edge https://rh-ecosystem-edge.github.io/console-plugin-nvidia-gpu

#. Update the repo:

   .. code-block:: console

      $ helm repo update

#. Install the ``helm`` chart in the default NVIDIA GPU Operator namespace:

   .. code-block:: console

      $ helm install -n nvidia-gpu-operator console-plugin-nvidia-gpu rh-ecosystem-edge/console-plugin-nvidia-gpu

   .. code-block:: console

      NAME: console-plugin-nvidia-gpu
      LAST DEPLOYED: Thu Apr 14 09:35:36 2022
      NAMESPACE: nvidia-gpu-operator
      STATUS: deployed
      REVISION: 1
      NOTES:
      View the Console Plugin NVIDIA GPU deployed resources by running the following command:

      $ kubectl -n nvidia-gpu-operator get all -l app.kubernetes.io/name=console-plugin-nvidia-gpu

      Enable the plugin by running the following command:

      $ kubectl patch consoles.operator.openshift.io cluster --patch '[{"op": "add", "path": "/spec/plugins/-", "value": "console-plugin-nvidia-gpu" }]' --type=json

#. View the deployed resources:

   .. code-block:: console

      $ oc -n nvidia-gpu-operator get all -l app.kubernetes.io/name=console-plugin-nvidia-gpu

#. Verify the plugins field is specified:

   .. code-block:: console

      $ oc get consoles.operator.openshift.io cluster --output=jsonpath="{.spec.plugins}"

   #. If it is **not** specified, then run the following to enable the plugin:

      .. code-block:: console

         $ oc patch consoles.operator.openshift.io cluster --patch '{ "spec": { "plugins": ["console-plugin-nvidia-gpu"] } }' --type=merge

   #. If it **is** specified, then run the following to enable the plugin:

      .. code-block:: console

         $ oc patch consoles.operator.openshift.io cluster --patch '[{"op": "add", "path": "/spec/plugins/-", "value": "console-plugin-nvidia-gpu" }]' --type=json

#. In the OpenShift Container Platform web console from the side menu, navigate to  **Home** > **Overview**.

   The ``Cluster utilization`` window now displays the GPU related graphs.

   .. image:: graphics/gpu_overview_dashboard.png

*************************************************
The NVIDIA GPU Operator dashboards
*************************************************

The following table provides a brief description of the displayed dashboards.

+---------------------+---------------------------------------------------------------------+
|       Dashboard     |             Description                                             |
+=====================+=====================================================================+
| GPU                 | Number of available GPUs.                                           |
+---------------------+---------------------------------------------------------------------+
|GPU Power Usage      | Power usage in watts for each GPU.                                  |
+---------------------+---------------------------------------------------------------------+
| GPU Encoder/Decoder | Percentage of GPU workload dedicated to video encoding and decoding.|
+---------------------+---------------------------------------------------------------------+
