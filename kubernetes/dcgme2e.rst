.. Date: July 30 2020
.. Author: pramarao

*****************************************
Integrating GPU Telemetry into Kubernetes
*****************************************

Understanding GPU usage provides important insights for IT administrators managing a data center. 
Trends in GPU metrics correlate with workload behavior and make it possible to optimize resource allocation, 
diagnose anomalies, and increase overall data center efficiency. As GPUs become more mainstream in 
Kubernetes environments, users would like to get access to GPU metrics to monitor GPU resources, just 
like they do today for CPUs. 

The purpose of this document is to enumerate an end-to-end (e2e) workflow 
for setting up and using `DCGM <https://developer.nvidia.com/dcgm>`_ within a Kubernetes environment. 

For simplicity, the base environment being used in this guide is Ubuntu 18.04 LTS and 
a native installation of the NVIDIA drivers on the GPU enabled nodes (i.e. neither 
the `NVIDIA GPU Operator <https://github.com/NVIDIA/gpu-operator>`_ nor containerized drivers are used 
in this document).

----

NVIDIA Drivers
==============
This section provides a summary of the steps for installing the driver using the ``apt`` package manager on Ubuntu LTS.

.. note::

   For complete instructions on setting up NVIDIA drivers, visit the quickstart guide at https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html.
   The guide covers a number of pre-installation requirements and steps on supported Linux distributions for a successful install of the driver. 


Install the kernel headers and development packages for the currently running kernel:

.. code-block:: console

   $ sudo apt-get install linux-headers-$(uname -r)

Setup the CUDA network repository and ensure packages on the CUDA network repository have priority over the Canonical repository:

.. code-block:: console

   $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g') \
      && wget https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/cuda-$distribution.pin \
      && sudo mv cuda-$distribution.pin /etc/apt/preferences.d/cuda-repository-pin-600

Install the CUDA repository GPG key:

.. code-block:: console

   $ sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/7fa2af80.pub \
      && echo "deb http://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64 /" | sudo tee /etc/apt/sources.list.d/cuda.list

Update the ``apt`` repository cache and install the driver using the ``cuda-drivers`` meta-package. Use the ``--no-install-recommends`` option for a lean driver install 
without any dependencies on X packages. This is particularly useful for headless installations on cloud instances:

.. code-block:: console

   $ sudo apt-get update \
      && sudo apt-get -y install cuda-drivers

----

Install Docker
==============
Use the official Docker script to install the latest release of Docker:

.. code-block:: console

   $ curl https://get.docker.com | sh

.. code-block:: console

   $ sudo systemctl start docker && sudo systemctl enable docker

----

Install NVIDIA Container Toolkit (previously ``nvidia-docker2``)
=================================================================
To run GPU accelerated containers in Docker, NVIDIA Container Toolkit for Docker is required. 

Setup the ``stable`` repository and the GPG key:

.. code-block:: console

   $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
      && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

Install the NVIDIA runtime packages (and their dependencies) after updating the package listing:

.. code-block:: console

   $ sudo apt-get update \
      && sudo apt-get install -y nvidia-docker2

Since Kubernetes does not support the ``--gpus`` option with Docker yet, the ``nvidia`` runtime should be setup as the 
default container runtime for Docker on the GPU node. This can be done by adding the ``default-runtime`` line into the Docker daemon 
config file, which is usually located on the system at ``/etc/docker/daemon.json``:

.. code-block:: console

   {
      "default-runtime": "nvidia",
      "runtimes": {
           "nvidia": {
               "path": "/usr/bin/nvidia-container-runtime",
               "runtimeArgs": []
         }
      }
   }

Restart the Docker daemon to complete the installation after setting the default runtime:

.. code-block:: console

   $ sudo systemctl restart docker

At this point, a working setup can be tested by running a base CUDA container:

.. code-block:: console

   $ sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

You should observe an output as shown below:

.. code-block:: console

   +-----------------------------------------------------------------------------+
   | NVIDIA-SMI 450.51.06    Driver Version: 450.51.06    CUDA Version: 11.0     |
   |-------------------------------+----------------------+----------------------+
   | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
   | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
   |                               |                      |               MIG M. |
   |===============================+======================+======================|
   |   0  Tesla T4            On   | 00000000:00:1E.0 Off |                    0 |
   | N/A   34C    P8     9W /  70W |      0MiB / 15109MiB |      0%      Default |
   |                               |                      |                  N/A |
   +-------------------------------+----------------------+----------------------+

   +-----------------------------------------------------------------------------+
   | Processes:                                                                  |
   |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
   |        ID   ID                                                   Usage      |
   |=============================================================================|
   |  No running processes found                                                 |
   +-----------------------------------------------------------------------------+

----

Install Kubernetes
===================

.. Shared content for K8s

Refer to :ref:`install-k8s` for getting started with setting up a Kubernetes cluster.

----

Install NVIDIA Device Plugin
============================
To use GPUs in Kubernetes, the `NVIDIA Device Plugin <https://github.com/NVIDIA/k8s-device-plugin/>`_ is required. 
The NVIDIA Device Plugin is a daemonset that automatically enumerates the number of GPUs on each node of the cluster 
and allows pods to be run on GPUs.

The preferred method to deploy the device plugin is as a daemonset using ``helm``. First, install Helm:

.. code-block:: console

   $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
      && chmod 700 get_helm.sh \
      && ./get_helm.sh

Add the ``nvidia-device-plugin`` ``helm`` repository:

.. code-block:: console

   $ helm repo add nvdp https://nvidia.github.io/k8s-device-plugin \
      && helm repo update

Deploy the device plugin:

.. code-block:: console

   $ helm install --generate-name nvdp/nvidia-device-plugin

For more user configurable options while deploying the daemonset, refer to the `documentation <https://github.com/NVIDIA/k8s-device-plugin/#deployment-via-helm>`_ 

At this point, all the pods should be deployed:

.. code-block:: console

   $ kubectl get pods -A

.. code-block:: console

   NAMESPACE     NAME                                       READY   STATUS      RESTARTS   AGE
   kube-system   calico-kube-controllers-5fbfc9dfb6-2ttkk   1/1     Running     3          9d
   kube-system   calico-node-5vfcb                          1/1     Running     3          9d
   kube-system   coredns-66bff467f8-jzblc                   1/1     Running     4          9d
   kube-system   coredns-66bff467f8-l85sz                   1/1     Running     3          9d
   kube-system   etcd-ip-172-31-81-185                      1/1     Running     4          9d
   kube-system   kube-apiserver-ip-172-31-81-185            1/1     Running     3          9d
   kube-system   kube-controller-manager-ip-172-31-81-185   1/1     Running     3          9d
   kube-system   kube-proxy-86vlr                           1/1     Running     3          9d
   kube-system   kube-scheduler-ip-172-31-81-185            1/1     Running     4          9d
   kube-system   nvidia-device-plugin-1595448322-42vgf      1/1     Running     2          9d

To test whether CUDA jobs can be deployed, run a sample CUDA ``vectorAdd`` application:

The pod spec is shown for reference below, which requests 1 GPU:

.. code-block:: console

   apiVersion: v1
   kind: Pod
   metadata:
     name: gpu-operator-test
   spec:
     restartPolicy: OnFailure
     containers:
     - name: cuda-vector-add
       image: "nvidia/samples:vectoradd-cuda10.2"
       resources:
         limits:
            nvidia.com/gpu: 1


Save this podspec as ``gpu-pod.yaml``. Now, deploy the application:

.. code-block:: console

   $ kubectl apply -f gpu-pod.yaml

Check the logs to ensure the app completed successfully: 

.. code-block:: console

   $ kubectl get pods gpu-operator-test

.. code-block:: console
   
   NAME                READY   STATUS      RESTARTS   AGE
   gpu-operator-test   0/1     Completed   0          9d

And check the logs of the ``gpu-operator-test`` pod: 

.. code-block:: console

   $ kubectl logs gpu-operator-test

.. code-block:: console

   [Vector addition of 50000 elements]
   Copy input data from the host memory to the CUDA device
   CUDA kernel launch with 196 blocks of 256 threads
   Copy output data from the CUDA device to the host memory
   Test PASSED
   Done

----

GPU Telemetry
==============
Monitoring stacks usually consist of a collector, a time-series database to store metrics and a visualization layer. 
A popular open-source stack is `Prometheus <https://prometheus.io/>`_ used along with `Grafana <https://grafana.com/>`_ as 
the visualization tool to create rich dashboards. Prometheus also includes an `Alertmanager <https://github.com/prometheus/alertmanager>`_, 
to create and manage alerts. Prometheus is deployed along with `kube-state-metrics <https://github.com/kubernetes/kube-state-metrics>`_ and 
`node_exporter <https://github.com/prometheus/node_exporter>`_ to expose cluster-level metrics for Kubernetes API objects and node-level 
metrics such as CPU utilization. 

An architecture of Prometheus is shown in the figure below:

.. image:: https://boxboat.com/2019/08/08/monitoring-kubernetes-with-prometheus/prometheus-architecture.png
   :width: 800


To gather GPU telemetry in Kubernetes, its recommended to use ``dcgm-exporter``. ``dcgm-exporter``, based on `DCGM <https://developer.nvidia.com/dcgm>`_ exposes 
GPU metrics for Prometheus and can be visualized using Grafana. ``dcgm-exporter`` is architected to take advantage of 
``KubeletPodResources`` `API <https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/>`_ and exposes GPU metrics in a format that can be 
scraped by Prometheus. A ``ServiceMonitor`` is also included to expose endpoints.

The rest of this section walks through how to deploy ``dcgm-exporter`` and then setup Prometheus, Grafana using Operators.

Setting up DCGM
----------------
Now, we will deploy ``dcgm-exporter`` to gather GPU telemetry. First, lets setup the Helm repo:

.. code-block:: console

   $ helm repo add gpu-helm-charts \
      https://nvidia.github.io/gpu-monitoring-tools/helm-charts

And then update the Helm repo:

.. code-block:: console

   $ helm repo update

Install the ``dcgm-exporter`` chart:

.. code-block:: console

   $ helm install \
      --generate-name \
      gpu-helm-charts/dcgm-exporter

Now, you can observe the ``dcgm-exporter`` pod:

.. code-block:: console

   $ kubectl get pods -A

.. code-block:: console

   NAMESPACE     NAME                                                              READY   STATUS      RESTARTS   AGE
   default       dcgm-exporter-2-1603213075-w27mx                                  1/1     Running     0          2m18s
   kube-system   calico-kube-controllers-8f59968d4-g28x8                           1/1     Running     1          43m
   kube-system   calico-node-zfnfk                                                 1/1     Running     1          43m
   kube-system   coredns-f9fd979d6-p7djj                                           1/1     Running     1          43m
   kube-system   coredns-f9fd979d6-qhhgq                                           1/1     Running     1          43m
   kube-system   etcd-ip-172-31-92-253                                             1/1     Running     1          43m
   kube-system   kube-apiserver-ip-172-31-92-253                                   1/1     Running     2          43m
   kube-system   kube-controller-manager-ip-172-31-92-253                          1/1     Running     1          43m
   kube-system   kube-proxy-mh528                                                  1/1     Running     1          43m
   kube-system   kube-scheduler-ip-172-31-92-253                                   1/1     Running     1          43m
   kube-system   nvidia-device-plugin-1603211071-7hlk6                             1/1     Running     0          35m

.. Shared content for kube-prometheus

.. include:: ../kubernetes/kube-prometheus.rst

Now you can see the Prometheus and Grafana pods:

.. code-block:: console

   $ kubectl get pods -A

.. code-block:: console

   NAMESPACE     NAME                                                              READY   STATUS      RESTARTS   AGE
   default       dcgm-exporter-2-1603213075-w27mx                                  1/1     Running     0          2m18s
   kube-system   calico-kube-controllers-8f59968d4-g28x8                           1/1     Running     1          43m
   kube-system   calico-node-zfnfk                                                 1/1     Running     1          43m
   kube-system   coredns-f9fd979d6-p7djj                                           1/1     Running     1          43m
   kube-system   coredns-f9fd979d6-qhhgq                                           1/1     Running     1          43m
   kube-system   etcd-ip-172-31-92-253                                             1/1     Running     1          43m
   kube-system   kube-apiserver-ip-172-31-92-253                                   1/1     Running     2          43m
   kube-system   kube-controller-manager-ip-172-31-92-253                          1/1     Running     1          43m
   kube-system   kube-proxy-mh528                                                  1/1     Running     1          43m
   kube-system   kube-scheduler-ip-172-31-92-253                                   1/1     Running     1          43m
   kube-system   nvidia-device-plugin-1603211071-7hlk6                             1/1     Running     0          35m
   prometheus    alertmanager-kube-prometheus-stack-1603-alertmanager-0            2/2     Running     0          23m
   prometheus    kube-prometheus-stack-1603-operator-6b95bcdc79-wmbkn              2/2     Running     0          23m
   prometheus    kube-prometheus-stack-1603211794-grafana-67ff56c449-tlmxc         2/2     Running     0          23m
   prometheus    kube-prometheus-stack-1603211794-kube-state-metrics-877df67c49f   1/1     Running     0          23m
   prometheus    kube-prometheus-stack-1603211794-prometheus-node-exporter-b5fl9   1/1     Running     0          23m
   prometheus    prometheus-kube-prometheus-stack-1603-prometheus-0                3/3     Running     1          23m

You can view the services setup as part of the operator and ``dcgm-exporter``:

.. code-block:: console
   
   $ kubectl get svc -A

.. code-block:: console
   
   NAMESPACE     NAME                                                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                        AGE
   default       dcgm-exporter-2-1603213075                                  ClusterIP   10.104.40.255   <none>        9400/TCP                       7m44s
   default       kubernetes                                                  ClusterIP   10.96.0.1       <none>        443/TCP                        49m
   kube-system   kube-dns                                                    ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP         48m
   kube-system   kube-prometheus-stack-1603-coredns                          ClusterIP   None            <none>        9153/TCP                       28m
   kube-system   kube-prometheus-stack-1603-kube-controller-manager          ClusterIP   None            <none>        10252/TCP                      28m
   kube-system   kube-prometheus-stack-1603-kube-etcd                        ClusterIP   None            <none>        2379/TCP                       28m
   kube-system   kube-prometheus-stack-1603-kube-proxy                       ClusterIP   None            <none>        10249/TCP                      28m
   kube-system   kube-prometheus-stack-1603-kube-scheduler                   ClusterIP   None            <none>        10251/TCP                      28m
   kube-system   kube-prometheus-stack-1603-kubelet                          ClusterIP   None            <none>        10250/TCP,10255/TCP,4194/TCP   28m
   prometheus    alertmanager-operated                                       ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP     28m
   prometheus    kube-prometheus-stack-1603-alertmanager                     ClusterIP   10.100.20.237   <none>        9093/TCP                       28m
   prometheus    kube-prometheus-stack-1603-operator                         ClusterIP   10.111.1.27     <none>        8080/TCP,443/TCP               28m
   prometheus    kube-prometheus-stack-1603-prometheus                       NodePort    10.99.188.46    <none>        9090:30090/TCP                 28m
   prometheus    kube-prometheus-stack-1603211794-grafana                    ClusterIP   10.109.219.60   <none>        80/TCP                         28m
   prometheus    kube-prometheus-stack-1603211794-kube-state-metrics         ClusterIP   10.103.250.41   <none>        8080/TCP                       28m
   prometheus    kube-prometheus-stack-1603211794-prometheus-node-exporter   ClusterIP   10.108.225.36   <none>        9100/TCP                       28m
   prometheus    prometheus-operated                                         ClusterIP   None            <none>        9090/TCP                       28m

You can observe that the Prometheus server is available at port 30090 on the node's IP address. Open your browser to ``http://<machine-ip-address>:30090``. 
It may take a few minutes for DCGM to start publishing the metrics to Prometheus. The metrics availability can be verified by typing ``DCGM_FI_DEV_GPU_UTIL`` 
in the event bar to determine if the GPU metrics are visible:

.. image:: graphics/001-dcgm-e2e-prom-screenshot.png
   :width: 800

Using Grafana 
-------------
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

.. code-block:: console

   $ cat << EOF | tee grafana-patch.yaml
   spec:
     type: NodePort
     nodePort: 32322
   EOF   

And now use ``kubectl patch``:

.. code-block:: console

   $ kubectl patch svc kube-prometheus-stack-1603211794-grafana \
      -n prometheus \
      --patch "$(cat grafana-patch.yaml)"

.. code-block:: console

   service/kube-prometheus-stack-1603211794-grafana patched

You can verify that the service is now exposed at an externally accessible port:

.. code-block:: console

   $ kubectl get svc -A

.. code-block:: console

   NAMESPACE     NAME                                                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                        AGE
   <snip>
   prometheus    kube-prometheus-stack-1603211794-grafana                    NodePort    10.109.219.60   <none>        80:30759/TCP                   32m

Open your browser to ``http://<machine-ip-address>:30759`` and view the Grafana login page. Access Grafana home using the ``admin`` username. 
The password credentials for the login are available in the ``prometheus.values`` file we edited in the earlier section of the doc:

.. code-block:: console

   ## Deploy default dashboards.
   ##
   defaultDashboardsEnabled: true

   adminPassword: prom-operator 

.. image:: graphics/002-dcgm-e2e-grafana-screenshot.png
   :width: 800

Port Forwarding
^^^^^^^^^^^^^^^
Another method to access the Grafana page would be to use port forwarding. 

First, it can be observed that the Grafana service is available at port 80. We will need to port-forward the service from an abitrary port - in this example, 
we will forward from port 32322 on our local machine to port 80 on the service (which in turn will forward to port 3000 that the Grafana pod is listening at, as 
shown below): 

.. code-block:: console

   $ kubectl port-forward svc/kube-prometheus-stack-1603211794-grafana -n prometheus 32322:80

.. code-block:: console
   
   Forwarding from 127.0.0.1:32322 -> 3000
   Forwarding from [::1]:32322 -> 3000
   Handling connection for 32322

If your cluster is setup on a cloud instance e.g. AWS EC2, you may have to setup an SSH tunnel between your local workstation and the instance using 
port forwarding to view the Grafana tool in your local workstation's browser. For example, on Windows you can use PuTTY to open an SSH tunnel and specify the 
source port as 32322 and destination as ``localhost:32322`` under the ``Tunnels`` sub-menu in the SSH menu.

Open your browser and point to ``http://localhost:32322/`` to view the Grafana login page using the same credentials in the previous section.


DCGM Dashboard in Grafana 
-------------------------
To add a dashboard for DCGM, you can use a standard dashboard that NVIDIA has made available, which can also be customized. 

.. image:: graphics/003-dcgm-e2e-grafana-home-screenshot.png
   :width: 800

To access the dashboard, navigate from the Grafana home page to Dashboards -> Manage -> Import:

.. image:: graphics/004-dcgm-e2e-grafana-manage-screenshot.png
   :width: 800

.. image:: graphics/005-dcgm-e2e-grafana-import-screenshot.png
   :width: 800

Import the NVIDIA dashboard from ``https://grafana.com/grafana/dashboards/12239``
and choose *Prometheus* as the data source in the drop down: 

.. image:: graphics/006-dcgm-e2e-grafana-import-screenshot.png
   :width: 800

.. image:: graphics/007-dcgm-e2e-grafana-import-screenshot.png
   :width: 800

The GPU dashboard will now be available on Grafana for visualizing metrics:

.. image:: graphics/008-dcgm-e2e-grafana-dashboard-screenshot.png
   :width: 800



Viewing Metrics for Running Applications
----------------------------------------
In this section, let's run a more complicated application and view the GPU metrics on the NVIDIA dashboard. 

We can use the standard *DeepStream Intelligent Video Analytics* `Demo <https://ngc.nvidia.com/catalog/helm-charts/nvidia:video-analytics-demo>`_ available on the NGC registry. 
For our example, let's use the Helm chart to use the WebUI:

.. code-block:: console

   $ helm fetch https://helm.ngc.nvidia.com/nvidia/charts/video-analytics-demo-0.1.4.tgz && \
      helm install video-analytics-demo-0.1.4.tgz --generate-name

.. code-block:: console

   NAME: video-analytics-demo-0-1596587131
   LAST DEPLOYED: Wed Aug  5 00:25:31 2020
   NAMESPACE: default
   STATUS: deployed
   REVISION: 1
   NOTES:
   1. Get the RTSP URL by running these commands:
   export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services video-analytics-demo-0-1596587131)
   export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
   echo rtsp://$NODE_IP:$NODE_PORT/ds-test

   2.Get the WebUI URL by running these commands:
   export ANT_NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services video-analytics-demo-0-1596587131-webui)
   export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
   echo http://$NODE_IP:$ANT_NODE_PORT/WebRTCApp/play.html?name=videoanalytics
   Disclaimer:
   Note: Due to the output from DeepStream being real-time via RTSP, you may experience occasional hiccups in the video stream depending on network conditions.
   
The demo can be viewed in the browser by pointing to the address following the instructions above. 

The GPU metrics are also visible either in the Grafana dashboard or the Prometheus dashboard as can be seen in the following screenshots showing 
GPU utilization, memory allocated as the application is running on the GPU:

.. image:: graphics/010-dcgm-e2e-deepstream-screenshot.png
   :width: 800

.. image:: graphics/011-dcgm-e2e-prom-dashboard-metrics-screenshot.png
   :width: 800


