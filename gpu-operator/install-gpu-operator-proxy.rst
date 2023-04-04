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

.. headings # #, * *, =, -, ^, "

.. Date: Sep 16 2021
.. Author: cdesiniotis

.. _install-gpu-operator-proxy:

Install GPU Operator in Proxy Environments
******************************************

Introduction
============

This page describes how to successfully deploy the GPU Operator in clusters behind an HTTP proxy.
By default, the GPU Operator requires internet access for the following reasons:

    1) Container images need to be pulled during GPU Operator installation.
    2) The ``driver`` container needs to download several OS packages prior to driver installation.

       .. tip::
          Using :doc:`precompiled-drivers` removes the need for the ``driver`` containers to
          download operating system packages.

To address these requirements, all Kubernetes nodes as well as the ``driver`` container need proper configuration
in order to direct traffic through the proxy.

This document demonstrates how to configure the GPU Operator so that the ``driver`` container can successfully
download packages behind a HTTP proxy. Since configuring Kubernetes/container runtime components to use
a proxy is not specific to the GPU Operator, we do not include those instructions here.

The instructions for Openshift are different, so skip the section titled :ref:`proxy_config_openshift` if you are not running Openshift.

Prerequisites
=============

* Kubernetes cluster is configured with HTTP proxy settings (container runtime should be enabled with HTTP proxy)

.. _proxy_config_openshift:

HTTP Proxy Configuration for Openshift
======================================

For Openshift, it is recommended to use the cluster-wide Proxy object to provide proxy information for the cluster.
Please follow the procedure described in `Configuring the cluster-wide proxy <https://docs.openshift.com/container-platform/4.8/networking/enable-cluster-wide-proxy.html>`_
from Red Hat Openshift public documentation. The GPU Operator will automatically inject proxy related ENV into the ``driver`` container
based on information present in the cluster-wide Proxy object.

.. note::

   * GPU Operator v1.8.0 does not work well on RedHat OpenShift when a cluster-wide Proxy object is configured and causes constant restarts of ``driver`` container. This will be fixed in an upcoming patch release v1.8.2.

HTTP Proxy Configuration
========================

First, get the ``values.yaml`` file used for GPU Operator configuration:

.. code-block:: console

  $ curl -sO https://raw.githubusercontent.com/NVIDIA/gpu-operator/v1.7.0/deployments/gpu-operator/values.yaml

.. note::

   Replace ``v1.7.0`` in the above command with the version you want to use.

Specify ``driver.env`` in ``values.yaml`` with appropriate HTTP_PROXY, HTTPS_PROXY, and NO_PROXY environment variables
(in both uppercase and lowercase).

.. code-block:: yaml

   driver:
      env:
      - name: HTTPS_PROXY
        value: http://<example.proxy.com:port>
      - name: HTTP_PROXY
        value: http://<example.proxy.com:port>
      - name: NO_PROXY
        value: <example.com>
      - name: https_proxy
        value: http://<example.proxy.com:port>
      - name: http_proxy
        value: http://<example.proxy.com:port>
      - name: no_proxy
        value: <example.com>

.. note::

   * Proxy related ENV are automatically injected by GPU Operator into the ``driver`` container to indicate proxy information used when downloading necessary packages.
   * If HTTPS Proxy server is setup then change the values of HTTPS_PROXY and https_proxy to use ``https`` instead.

Deploy GPU Operator
===================

Download and deploy GPU Operator Helm Chart with the updated ``values.yaml``.

Fetch the chart from NGC repository. ``v1.10.0`` is used as an example in the command below:

.. code-block:: console

    $ helm fetch https://helm.ngc.nvidia.com/nvidia/charts/gpu-operator-v1.10.0.tgz

Install the GPU Operator with updated ``values.yaml``:

.. code-block:: console

    $ helm install --wait gpu-operator \
         -n gpu-operator --create-namespace \
         gpu-operator-v1.10.0.tgz \
         -f values.yaml

Check the status of the pods to ensure all the containers are running:

.. code-block:: console

   $ kubectl get pods -n gpu-operator
