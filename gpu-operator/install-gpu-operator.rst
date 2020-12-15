.. Date: Nov 25 2020
.. Author: pramarao

.. _install-gpu-operator:

Install NVIDIA GPU Operator
=============================

Install Helm
-------------

The preferred method to deploy the GPU Operator is using ``helm``.

.. code-block:: console

   $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
      && chmod 700 get_helm.sh \
      && ./get_helm.sh

Now, add the NVIDIA Helm repository:

.. code-block:: console

   $ helm repo add nvidia https://nvidia.github.io/gpu-operator \
      && helm repo update

Now setup the operator using the Helm chart:

.. note::

   If NFD is already running in the cluster prior to the deployment of the operator, use the ``--set nfd.enabled=false`` Helm chart variable

.. code-block:: console

   $ helm install --wait --generate-name \
      nvidia/gpu-operator

.. note::

   If you want to use custom driver container images (for e.g. using 455.28), then you would need to build a new driver container image. Follow these steps:

   - Modify the Dockerfile (for e.g. by specifying the driver version in the Ubuntu 20.04 container `here <https://gitlab.com/nvidia/container-images/driver/-/blob/master/ubuntu20.04/Dockerfile#L27>`_)
   - Build the container (e.g. ``docker build --pull -t nvidia/driver:455.28-ubuntu20.04 --file Dockerfile .``). Ensure that the driver container is tagged as shown in the example 
     by using the ``driver:<version>-<os>`` schema. 
   - Specify the new driver image and repository by overriding the defaults in the Helm install command. For example: 

      .. code-block:: console

         $ helm install --wait --generate-name \
            nvidia/gpu-operator \
            --set driver.repository=docker.io/nvidia \
            --set driver.version="455.28"

   Note that these instructions are provided for reference and evaluation purposes. Not using the standard releases of the GPU Operator from NVIDIA would mean limited 
   support for such custom configurations.



Check the status of the pods to ensure all the containers are running:

.. code-block:: console

   $ kubectl get pods -A

.. code-block:: console
   
   NAMESPACE                NAME                                                              READY   STATUS      RESTARTS   AGE
   default                  gpu-operator-1597953523-node-feature-discovery-master-5bcfgvtzn   1/1     Running     0          2m18s
   default                  gpu-operator-1597953523-node-feature-discovery-worker-fx9xc       1/1     Running     0          2m18s
   default                  gpu-operator-774ff7994c-nwpvz                                     1/1     Running     0          2m18s
   gpu-operator-resources   nvidia-container-toolkit-daemonset-tt9zh                          1/1     Running     0          2m7s
   gpu-operator-resources   nvidia-dcgm-exporter-zpprv                                        1/1     Running     0          2m7s
   gpu-operator-resources   nvidia-device-plugin-daemonset-5ztkl                              1/1     Running     3          2m7s
   gpu-operator-resources   nvidia-device-plugin-validation                                   0/1     Completed   0          2m7s
   gpu-operator-resources   nvidia-driver-daemonset-qtn6p                                     1/1     Running     0          2m7s
   gpu-operator-resources   nvidia-driver-validation                                          0/1     Completed   0          2m7s
   kube-system              calico-kube-controllers-578894d4cd-pv5kw                          1/1     Running     0          5m36s
   kube-system              calico-node-ffhdd                                                 1/1     Running     0          5m36s
   kube-system              coredns-66bff467f8-nwdrx                                          1/1     Running     0          9m4s
   kube-system              coredns-66bff467f8-srg8d                                          1/1     Running     0          9m4s
   kube-system              etcd-ip-172-31-80-124                                             1/1     Running     0          9m19s
   kube-system              kube-apiserver-ip-172-31-80-124                                   1/1     Running     0          9m19s
   kube-system              kube-controller-manager-ip-172-31-80-124                          1/1     Running     0          9m19s
   kube-system              kube-proxy-kj5qb                                                  1/1     Running     0          9m4s
   kube-system              kube-scheduler-ip-172-31-80-124                                   1/1     Running     0          9m18s

.. Shared content for the GPU Operator install

.. include:: install-gpu-operator-air-gapped.rst