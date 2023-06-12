.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

.. headings (h1/h2/h3/h4/h5) are # * = -

#########################################
Integrating GPU Telemetry into Kubernetes
#########################################

.. contents::
   :depth: 5
   :local:
   :backlinks: none


*************************
Benefits of GPU Telemetry
*************************

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

**************
NVIDIA Drivers
**************
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

**************
Install Docker
**************

Use the official Docker script to install the latest release of Docker:

.. code-block:: console

   $ curl https://get.docker.com | sh

.. code-block:: console

   $ sudo systemctl --now enable docker

********************************
Install NVIDIA Container Toolkit
********************************

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


****************************
Install NVIDIA Device Plugin
****************************

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
