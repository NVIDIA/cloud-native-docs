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

Monitoring stacks usually consist of a collector, a time-series database to store metrics and a visualization layer.
A popular open-source stack is `Prometheus <https://prometheus.io/>`_ used along with `Grafana <https://grafana.com/>`_ as
the visualization tool to create rich dashboards. Prometheus also includes an `Alertmanager <https://github.com/prometheus/alertmanager>`_,
to create and manage alerts. Prometheus is deployed along with `kube-state-metrics <https://github.com/kubernetes/kube-state-metrics>`_ and
`node_exporter <https://github.com/prometheus/node_exporter>`_ to expose cluster-level metrics for Kubernetes API objects and node-level
metrics such as CPU utilization.

An architecture of Prometheus is shown in the figure below:

.. image:: https://boxboat.com/2019/08/08/monitoring-kubernetes-with-prometheus/prometheus-architecture.png
   :width: 800


To gather GPU telemetry in Kubernetes, its recommended to use DCGM Exporter.  DCGM Exporter, based on `DCGM <https://developer.nvidia.com/dcgm>`_ exposes
GPU metrics for Prometheus and can be visualized using Grafana.  DCGM Exporter is architected to take advantage of
``KubeletPodResources`` `API <https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/>`_ and exposes GPU metrics in a format that can be
scraped by Prometheus. A ``ServiceMonitor`` is also included to expose endpoints.
