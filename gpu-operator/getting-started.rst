.. Date: July 30 2020
.. Author: pramarao

.. _operator-install-guide:

*****************************************
Getting Started
*****************************************
This document provides instructions, including pre-requisites for getting started with the NVIDIA GPU Operator. 

Prerequisites
=============

Before installing the GPU Operator, you should ensure that the Kubernetes cluster meets some prerequisites.

#. Nodes must not be pre-configured with NVIDIA components (driver, container runtime, device plugin).
#. Nodes must be configured with Docker CE or other supported container runtimes. Follow the official install 
   `instructions <https://docs.docker.com/engine/install/>`_.
#. If the HWE kernel (e.g. kernel 5.x) is used with Ubuntu 18.04 LTS, then the ``nouveau`` driver for NVIDIA GPUs must be blacklisted 
   before starting the GPU Operator. Follow the steps in the CUDA installation `guide <https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#runfile-nouveau-ubuntu>`_ 
   to disable the nouveau driver and update ``initramfs``.
#. Node Feature Discovery (NFD) is required on each node. By default, NFD master and worker are automatically deployed. 
   If NFD is already running in the cluster prior to the deployment of the operator, set the Helm chart variable ``nfd.enabled`` to ``false`` 
   during the Helm install step. 
#. For monitoring in Kubernetes 1.13 and 1.14, enable the kubelet ``KubeletPodResources`` `feature <https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/>`_ 
   gate. From Kubernetes 1.15 onwards, its enabled by default.

.. note:: 

   To enable the ``KubeletPodResources`` feature gate, run the following command: ``echo -e "KUBELET_EXTRA_ARGS=--feature-gates=KubeletPodResources=true" | sudo tee /etc/default/kubelet``

----

Red Hat OpenShift 4
====================

For installing the GPU Operator on clusters with Red Hat OpenShift 4.1, 4.2 and 4.3 using RHCOS worker nodes, 
follow the `user guide <https://docs.nvidia.com/datacenter/kubernetes/openshift-on-gpu-install-guide/index.html>`_.

----

Google Cloud Anthos
====================

For getting started with NVIDIA GPUs for Google Cloud Anthos, follow the getting started 
`document <https://docs.nvidia.com/datacenter/kubernetes/anthos-gpus-guide/>`_.

----

The rest of this document includes instructions for installing the GPU Operator on Ubuntu 18.04 LTS and CentOS 8. 

.. Shared content for K8s

.. include:: ../kubernetes/install-k8s.rst

Install Helm
-------------

The preferred method to deploy the GPU Operator is using ``helm``.

.. code-block:: bash

   curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
   chmod 700 get_helm.sh
   ./get_helm.sh

Install GPU Operator
======================

Add the NVIDIA Helm repository:

.. code-block:: bash

   helm repo add nvidia https://nvidia.github.io/gpu-operator
   helm repo update

Now setup the operator using the Helm chart:

.. code-block:: bash

   helm install nvidia/gpu-operator --wait --generate-name

.. note::

   If NFD is already running in the cluster prior to the deployment of the operator, use the ``--set nfd.enabled=false`` Helm chart variable

Check the status of the pods to ensure all the containers are running:

.. code-block:: bash

   kubectl get pods -A
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

Check out the demo below where we scale GPU nodes in a K8s cluster using the GPU Operator:

.. image:: graphics/gpu-operator-demo.gif
   :width: 800

Running Sample GPU Applications
--------------------------------

In this example, let's try running a TensorFlow Jupyter notebook.

First, deploy the pods:

.. code-block:: bash

   kubectl apply -f https://nvidia.github.io/gpu-operator/notebook-example.yml

Check to determine if the pod has successfully started:

.. code-block:: bash

   kubectl get pod tf-notebook
   NAMESPACE                NAME                                                              READY   STATUS      RESTARTS   AGE
   default                  tf-notebook                                                       1/1     Running     0          3m45s

Since the example also includes a service, let's obtain the external port at which the notebook is accessible:

.. code-block:: bash

   kubectl get svc -A
   NAMESPACE                NAME                                                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
   default                  tf-notebook                                             NodePort    10.106.229.20   <none>        80:30001/TCP             4m41s
   ..

And the token for the Jupyter notebook:

.. code-block:: bash

   kubectl logs tf-notebook
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

The notebook should now be accessible from your browser at this URL: ``http:://<your-machine-ip>:30001/?token=3660c9ee9b225458faaf853200bc512ff2206f635ab2b1d9``

GPU Telemetry
--------------
To gather GPU telemetry in Kubernetes, the GPU Operator deploys the ``dcgm-exporter``. ``dcgm-exporter``, based 
on `DCGM <https://developer.nvidia.com/dcgm>`_ exposes GPU metrics for Prometheus and can be visualized using Grafana. ``dcgm-exporter`` is architected to take advantage of 
``KubeletPodResources`` `API <https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/>`_ and exposes GPU metrics in a format that can be 
scraped by Prometheus.

The rest of this section walks through how to setup Prometheus, Grafana using Operators and then deploy ``dcgm-exporter``.

Setting up Prometheus Operator
``````````````````````````````
Implementing a Prometheus stack can be complicated but can be managed by taking advantage of the ``Helm`` package manager and 
the `Prometheus Operator <https://github.com/coreos/prometheus-operator>`_ and `kube-prometheus <https://github.com/coreos/kube-prometheus>`_ projects. 
The Operator uses standard configurations and dashboards for Prometheus and Grafana and the Helm `prometheus-operator <https://github.com/helm/charts/tree/master/stable/prometheus-operator>`_ 
chart allows you to get a full cluster monitoring solution up and running by installing Prometheus Operator and the rest of the components listed above.

First, add the ``helm`` repo:

.. code-block:: bash

   helm repo add stable https://kubernetes-charts.storage.googleapis.com

Now, search for the available ``prometheus`` charts:

.. code-block:: bash
   
   helm search repo prometheus

Once you’ve located which the version of the chart to use, inspect the chart so we can modify the settings:

.. code-block:: bash

   helm inspect values stable/prometheus-operator > /tmp/prometheus.values


Next, we’ll need to edit the values file to change the port at which the Prometheus server service is available. In the ``prometheus`` instance 
section of the chart, change the service type from ``ClusterIP`` to ``NodePort``. This will allow the Prometheus server to be accessible at your 
machine ip address at port 30090 as ``http://<machine-ip>:30090/``

.. code-block:: bash

   From:
    ## List of IP addresses at which the Prometheus server service is available
    ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
    ##
    externalIPs: []

    ## Port to expose on each node
    ## Only used if service.type is 'NodePort'
    ##
    nodePort: 30090

    ## Loadbalancer IP
    ## Only use if service.type is "loadbalancer"
    loadBalancerIP: ""
    loadBalancerSourceRanges: []
    ## Service type
    ##
    type: ClusterIP


   To:
    ## List of IP addresses at which the Prometheus server service is available
    ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
    ##
    externalIPs: []

    ## Port to expose on each node
    ## Only used if service.type is 'NodePort'
    ##
    nodePort: 30090

    ## Loadbalancer IP
    ## Only use if service.type is "loadbalancer"
    loadBalancerIP: ""
    loadBalancerSourceRanges: []
    ## Service type
    ##
    type: NodePort

Modify the ``prometheusSpec.serviceMonitorSelectorNilUsesHelmValues`` settings to ``false`` below:

.. code-block:: bash

    ## If true, a nil or {} value for prometheus.prometheusSpec.serviceMonitorSelector will cause the
    ## prometheus resource to be created with selectors based on values in the helm deployment,
    ## which will also match the servicemonitors created
    ##
    serviceMonitorSelectorNilUsesHelmValues: false

Add the following ``configMap`` to the section on ``additionalScrapeConfigs`` in the Helm chart:

.. code-block:: bash

    ## AdditionalScrapeConfigs allows specifying additional Prometheus scrape configurations. Scrape configurations
    ## are appended to the configurations generated by the Prometheus Operator. Job configurations must have the form
    ## as specified in the official Prometheus documentation:
    ## https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config. As scrape configs are
    ## appended, the user is responsible to make sure it is valid. Note that using this feature may expose the possibility
    ## to break upgrades of Prometheus. It is advised to review Prometheus release notes to ensure that no incompatible
    ## scrape configs are going to break Prometheus after the upgrade.
    ##
    ## The scrape configuraiton example below will find master nodes, provided they have the name .*mst.*, relabel the
    ## port to 2379 and allow etcd scraping provided it is running on all Kubernetes master nodes
    ##
    additionalScrapeConfigs:
    - job_name: gpu-metrics
      scrape_interval: 1s
      metrics_path: /metrics
      scheme: http
      kubernetes_sd_configs:
      - role: endpoints
        namespaces:
          names:
          - gpu-operator-resources
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_node_name]
        action: replace
        target_label: kubernetes_node


Finally, we can deploy the Prometheus and Grafana pods using the ``prometheus-operator`` via Helm:

.. code-block:: bash

   helm install stable/prometheus-operator --create-namespace --namespace prometheus --values /tmp/prometheus.values --generate-name

.. code-block:: console

   NAME: prometheus-operator-1597990146
   LAST DEPLOYED: Fri Aug 21 06:09:07 2020
   NAMESPACE: prometheus
   STATUS: deployed
   REVISION: 1
   NOTES:
   The Prometheus Operator has been installed. Check its status by running:
   kubectl --namespace prometheus get pods -l "release=prometheus-operator-1597990146"

   Visit https://github.com/coreos/prometheus-operator for instructions on how
   to create & configure Alertmanager and Prometheus instances using the Operator.

Now you can see the Prometheus and Grafana pods:

.. code-block:: bash

   kubectl get pods -A
   NAMESPACE                NAME                                                              READY   STATUS      RESTARTS   AGE
   default                  gpu-operator-1597965115-node-feature-discovery-master-fbf9rczx5   1/1     Running     1          6h57m
   default                  gpu-operator-1597965115-node-feature-discovery-worker-n58pm       1/1     Running     1          6h57m
   default                  gpu-operator-774ff7994c-xh62d                                     1/1     Running     1          6h57m
   default                  gpu-operator-test                                                 0/1     Completed   0          8h
   gpu-operator-resources   nvidia-container-toolkit-daemonset-grnnd                          1/1     Running     1          6h57m
   gpu-operator-resources   nvidia-dcgm-exporter-nv5z7                                        1/1     Running     7          6h57m
   gpu-operator-resources   nvidia-device-plugin-daemonset-qq6lq                              1/1     Running     7          6h57m
   gpu-operator-resources   nvidia-device-plugin-validation                                   0/1     Completed   0          6h57m
   gpu-operator-resources   nvidia-driver-daemonset-vwzvq                                     1/1     Running     1          6h57m
   gpu-operator-resources   nvidia-driver-validation                                          0/1     Completed   3          6h57m
   kube-system              calico-kube-controllers-578894d4cd-pv5kw                          1/1     Running     1          10h
   kube-system              calico-node-ffhdd                                                 1/1     Running     1          10h
   kube-system              coredns-66bff467f8-nwdrx                                          1/1     Running     1          10h
   kube-system              coredns-66bff467f8-srg8d                                          1/1     Running     1          10h
   kube-system              etcd-ip-172-31-80-124                                             1/1     Running     1          10h
   kube-system              kube-apiserver-ip-172-31-80-124                                   1/1     Running     1          10h
   kube-system              kube-controller-manager-ip-172-31-80-124                          1/1     Running     1          10h
   kube-system              kube-proxy-kj5qb                                                  1/1     Running     1          10h
   kube-system              kube-scheduler-ip-172-31-80-124                                   1/1     Running     1          10h
   prometheus               alertmanager-prometheus-operator-159799-alertmanager-0            2/2     Running     0          12s
   prometheus               prometheus-operator-159799-operator-78f95fccbd-hcl76              2/2     Running     0          16s
   prometheus               prometheus-operator-1597990146-grafana-5c7db4f7d4-qcjbj           2/2     Running     0          16s
   prometheus               prometheus-operator-1597990146-kube-state-metrics-645c57c8x28nv   1/1     Running     0          16s
   prometheus               prometheus-operator-1597990146-prometheus-node-exporter-6lchc     1/1     Running     0          16s
   prometheus               prometheus-prometheus-operator-159799-prometheus-0                2/3     Running     0          2s

You can view the services setup as part of the operator and ``dcgm-exporter``:

.. code-block:: bash
   
   kubectl get svc -A
   
   NAMESPACE                NAME                                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                        AGE
   default                  gpu-operator-1597965115-node-feature-discovery-master     ClusterIP   10.110.46.7      <none>        8080/TCP                       6h57m
   default                  kubernetes                                                ClusterIP   10.96.0.1        <none>        443/TCP                        10h
   default                  tf-notebook                                               NodePort    10.106.229.20    <none>        80:30001/TCP                   8h
   gpu-operator-resources   nvidia-dcgm-exporter                                      ClusterIP   10.99.250.100    <none>        9400/TCP                       6h57m
   kube-system              kube-dns                                                  ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP         10h
   kube-system              prometheus-operator-159797-kubelet                        ClusterIP   None             <none>        10250/TCP,10255/TCP,4194/TCP   4h50m
   kube-system              prometheus-operator-159799-coredns                        ClusterIP   None             <none>        9153/TCP                       32s
   kube-system              prometheus-operator-159799-kube-controller-manager        ClusterIP   None             <none>        10252/TCP                      32s
   kube-system              prometheus-operator-159799-kube-etcd                      ClusterIP   None             <none>        2379/TCP                       32s
   kube-system              prometheus-operator-159799-kube-proxy                     ClusterIP   None             <none>        10249/TCP                      32s
   kube-system              prometheus-operator-159799-kube-scheduler                 ClusterIP   None             <none>        10251/TCP                      32s
   kube-system              prometheus-operator-159799-kubelet                        ClusterIP   None             <none>        10250/TCP,10255/TCP,4194/TCP   18s
   prometheus               alertmanager-operated                                     ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP     28s
   prometheus               prometheus-operated                                       ClusterIP   None             <none>        9090/TCP                       18s
   prometheus               prometheus-operator-159799-alertmanager                   ClusterIP   10.106.93.161    <none>        9093/TCP                       32s
   prometheus               prometheus-operator-159799-operator                       ClusterIP   10.100.116.170   <none>        8080/TCP,443/TCP               32s
   prometheus               prometheus-operator-159799-prometheus                     NodePort    10.102.169.42    <none>        9090:30090/TCP                 32s
   prometheus               prometheus-operator-1597990146-grafana                    ClusterIP   10.104.40.69     <none>        80/TCP                         32s
   prometheus               prometheus-operator-1597990146-kube-state-metrics         ClusterIP   10.100.204.91    <none>        8080/TCP                       32s
   prometheus               prometheus-operator-1597990146-prometheus-node-exporter   ClusterIP   10.97.64.60      <none>        9100/TCP                       32s


You can observe that the Prometheus server is available at port 30090 on the node's IP address. Open your browser to ``http://<machine-ip-address>:30090``. 
It may take a few minutes for DCGM to start publishing the metrics to Prometheus. The metrics availability can be verified by typing ``DCGM_FI_DEV_GPU_UTIL`` 
in the event bar to determine if the GPU metrics are visible:

.. image:: ../kubernetes/graphics/001-dcgm-e2e-prom-screenshot.png
   :width: 800

Using Grafana 
``````````````
You can also launch the Grafana tools for visualizing the GPU metrics. 

There are two mechanisms for dealing with the ports on which Grafana is available - the service can be patched or port-forwarding can be used to reach the home page. 
Either option can be chosen based on preference.

Patching the Grafana Service
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
By default, Grafana uses a ``ClusterIP`` to expose the ports on which the service is accessible. This can be changed to a ``NodePort`` instead, so the page is accessible 
from the browser, similar to the Prometheus dashboard. 

You can use `kubectl patch <https://kubernetes.io/docs/tasks/manage-kubernetes-objects/update-api-object-kubectl-patch/>`_ to update the service API 
object to expose a ``NodePort`` instead. 

First, modify the spec to change the service type:

.. code-block:: bash

   cat << EOF | tee grafana-patch.yaml
   spec:
     type: NodePort
     nodePort: 32322
   EOF   

And now use ``kubectl patch``:

.. code-block:: bash

   kubectl patch svc prometheus-operator-1597990146-grafana -n prometheus --patch "$(cat grafana-patch.yaml)"

   service/prometheus-operator-1597990146-grafana patched

You can verify that the service is now exposed at an externally accessible port:

.. code-block:: bash

   kubectl get svc -A

   NAMESPACE     NAME                                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                        AGE
   <snip>
   prometheus    prometheus-operator-1597990146-grafana                    NodePort    10.108.187.141   <none>        80:32258/TCP                   17h

Open your browser to ``http://<machine-ip-address>:32258`` and view the Grafana login page. Access Grafana home using the ``admin`` username. 
The password credentials for the login are available in the ``prometheus.values`` file we edited in the earlier section of the doc:

.. code-block:: bash

   ## Deploy default dashboards.
   ##
   defaultDashboardsEnabled: true

   adminPassword: prom-operator 

.. image:: ../kubernetes/graphics/002-dcgm-e2e-grafana-screenshot.png
   :width: 800

Uninstalling GPU Operator
===========================

To uninstall the operator, first obtain the name using the following command:

.. code-block:: bash

   helm ls

Now delete the operator:

.. code-block:: bash

   helm delete <gpu-operator-name>

You should now see all the pods being deleted:

.. code-block:: bash

   kubectl get pods -n gpu-operator-resources
   
   No resources found.
