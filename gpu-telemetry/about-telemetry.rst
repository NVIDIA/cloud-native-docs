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

###################
About GPU Telemetry
###################

The NVIDIA GPU Operator deploys NVIDIA DCGM Exporter on every GPU node by default.
DCGM Exporter reads GPU metrics from `NVIDIA DCGM <https://developer.nvidia.com/dcgm>`__
and exposes them for `Prometheus <https://prometheus.io/>`__.
You can view the metrics in Grafana or, on Red Hat OpenShift, in the web console.

This documentation covers what the GPU Operator does for GPU telemetry:

* :doc:`dcgm-exporter` describes the resources that the Operator creates,
  the Operator values for DCGM Exporter, custom metrics files, Prometheus scraping, and a separate DCGM host engine.
* :external+ocp:doc:`enable-gpu-monitoring-dashboard` describes the GPU dashboard in the OpenShift web console.

For DCGM Exporter itself, such as standalone and Helm installs, the configuration file, command-line options,
and the list of metrics, refer to the
`DCGM Exporter documentation <https://docs.nvidia.com/datacenter/dcgm/latest/installation/install-dcgm-exporter.html>`__.

***********
Quick Links
***********

* `NVIDIA GPU Operator documentation <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/>`__
* `DCGM Exporter documentation <https://docs.nvidia.com/datacenter/dcgm/latest/installation/install-dcgm-exporter.html>`__
* `DCGM Exporter release notes <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/dcgm-exporter.html>`__
* `DCGM Exporter GitHub repository <https://github.com/NVIDIA/dcgm-exporter>`__
* `DCGM documentation <https://docs.nvidia.com/datacenter/dcgm/latest/>`__
