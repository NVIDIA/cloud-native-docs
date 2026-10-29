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

.. _dcgm-exporter-gpu-operator:

##########################################
DCGM Exporter with the NVIDIA GPU Operator
##########################################

`DCGM Exporter <https://github.com/NVIDIA/dcgm-exporter>`__ reads GPU metrics from
`NVIDIA DCGM <https://developer.nvidia.com/dcgm>`__ and exposes them for Prometheus at ``/metrics``.
The NVIDIA GPU Operator deploys DCGM Exporter on every GPU node by default.

This page covers what the GPU Operator does for DCGM Exporter and how you configure it through the Operator.
For DCGM Exporter itself, refer to the DCGM Exporter documentation:

* `Install DCGM Exporter <https://docs.nvidia.com/datacenter/dcgm/latest/installation/install-dcgm-exporter.html>`__,
  including standalone containers, packages, and the exporter's own Helm chart.
* `Command-line and YAML reference <https://docs.nvidia.com/datacenter/dcgm/latest/reference/command-line-reference/dcgm-exporter.html>`__
  for options, environment variables, and the configuration file.
* `DCGM Exporter metrics <https://docs.nvidia.com/datacenter/dcgm/latest/reference/dcgm-exporter-metrics.html>`__
  for metric names, units, labels, and MIG behavior.
* `Configure Prometheus for DCGM Exporter <https://docs.nvidia.com/datacenter/dcgm/latest/learn/getting-started-for-system-administrators/configure-prometheus-for-dcgm-exporter.html>`__.
* `DCGM Exporter release notes <https://docs.nvidia.com/datacenter/dcgm/latest/release-notes/dcgm-exporter.html>`__,
  including metric name changes and the DCGM version each release is tested with.


*************************
What the Operator Deploys
*************************

The Operator creates the following resources in the Operator namespace, such as ``gpu-operator``:

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - Resource
     - Description

   * - DaemonSet ``nvidia-dcgm-exporter``
     - Runs one DCGM Exporter pod on each node that has the ``nvidia.com/gpu.deploy.dcgm-exporter=true`` label.
       The pods have the ``app=nvidia-dcgm-exporter`` label.

   * - Service ``nvidia-dcgm-exporter``
     - Exposes port ``9400``, named ``gpu-metrics``.

   * - ServiceMonitor ``nvidia-dcgm-exporter``
     - Tells the Prometheus Operator to scrape ``/metrics`` on the ``gpu-metrics`` port.
       The GPU Operator creates it only when ``dcgmExporter.serviceMonitor.enabled`` is ``true``
       and the ``ServiceMonitor`` custom resource definition exists in the cluster.

   * - PrometheusRule ``nvidia-dcgm-exporter``
     - OpenShift only.
       Records the ``accelerator_*`` series that the OpenShift console uses.
       Refer to :external+ocp:ref:`enable-gpu-monitoring-dashboard`.

By default, DCGM Exporter runs an embedded DCGM host engine inside its container.

The Operator sets the following environment variables on the exporter container:

* ``DCGM_EXPORTER_LISTEN=:9400``
* ``DCGM_EXPORTER_KUBERNETES=true``, which adds pod, namespace, and container labels to the metrics of GPUs that pods use.
* ``DCGM_EXPORTER_COLLECTORS=/etc/dcgm-exporter/default-counters.csv``, the default metrics file in the image.
  When you supply a custom metrics file, the value is ``/etc/dcgm-exporter/dcgm-metrics.csv``.
* ``DCGM_REMOTE_HOSTENGINE_INFO=nvidia-dcgm:5555``, only when the standalone DCGM host engine is enabled.
  For a ``GPUCluster`` with standalone DCGM, the value is ``nvidia-dcgm-dra:5555``.

Variables in ``dcgmExporter.env`` are applied last and replace these values.
Environment variables also take precedence over the exporter's configuration file, ``/etc/dcgm-exporter/config.yaml``, in the image.

DCGM Exporter can stop at startup on an invalid setting.
An invalid value in ``dcgmExporter.env`` or ``dcgmExporter.args`` stops the pod with an error message.
To see the message, view the pod logs:

.. code-block:: console

   $ kubectl logs -n gpu-operator -l app=nvidia-dcgm-exporter


*************************
DCGM Exporter Helm Values
*************************

Set these values when you install or upgrade the Operator with Helm.
The same fields are under ``spec.dcgmExporter`` in the ``ClusterPolicy`` resource,
except ``config.create`` and ``config.data``, which only the Helm chart uses.

.. list-table::
   :widths: 35 45 20
   :header-rows: 1

   * - Parameter
     - Description
     - Default

   * - ``dcgmExporter.enabled``
     - When set to ``true``, the Operator deploys DCGM Exporter.
     - ``true``

   * - ``dcgmExporter.repository``, ``image``, ``version``
     - Image of DCGM Exporter.
       The default version is the one that the Operator release ships.
     - Refer to ``helm show values``

   * - ``dcgmExporter.env``
     - List of environment variables, as ``name`` and ``value`` pairs, to set in the DCGM Exporter container.
     - ``[]``

   * - ``dcgmExporter.args``
     - List of command-line arguments to pass to DCGM Exporter.
     - ``none``

   * - ``dcgmExporter.resources``
     - Resource requests and limits for the DCGM Exporter pods.
     - ``{}``

   * - ``dcgmExporter.annotations``
     - Map of custom annotations to add to the DCGM Exporter pods.
     - ``{}``

   * - ``dcgmExporter.config.name``
     - Name of a ConfigMap that holds a custom metrics file.
       Refer to :ref:`dcgm-exporter-custom-metrics`.
     - ``none``

   * - ``dcgmExporter.config.create``
     - Helm only.
       When set to ``true`` and ``config.data`` is set, the chart creates the ConfigMap named by ``config.name``.
     - ``none``

   * - ``dcgmExporter.config.data``
     - Helm only.
       Contents of the metrics file for the ConfigMap that the chart creates.
     - ``none``

   * - ``dcgmExporter.serviceMonitor.enabled``
     - When set to ``true``, the Operator creates a ``ServiceMonitor`` for DCGM Exporter.
     - ``true``

   * - ``dcgmExporter.serviceMonitor.interval``
     - Interval at which Prometheus scrapes DCGM Exporter.
     - ``15s``

   * - ``dcgmExporter.serviceMonitor.scrapeTimeout``
     - Timeout for one scrape. The value must not be greater than the interval.
     - ``10s``

   * - ``dcgmExporter.serviceMonitor.honorLabels``
     - When set to ``true``, Prometheus keeps the metric labels when they collide with target labels.
     - ``false``

   * - ``dcgmExporter.serviceMonitor.additionalLabels``
     - Map of labels to add to the ``ServiceMonitor``.
     - ``{}``

   * - ``dcgmExporter.serviceMonitor.relabelings``
     - List of Prometheus relabeling rules for the scrape target.
     - ``[]``

   * - ``dcgmExporter.serviceMonitor.metricRelabelings``
     - List of Prometheus relabeling rules for scraped samples, applied before ingestion.
     - ``[]``

   * - ``dcgmExporter.service.type``
     - Type of the ``nvidia-dcgm-exporter`` service.
     - ``ClusterIP``

   * - ``dcgmExporter.service.internalTrafficPolicy``
     - `Internal traffic policy <https://kubernetes.io/docs/concepts/services-networking/service/#traffic-policies>`__
       of the ``nvidia-dcgm-exporter`` service.
     - ``Cluster``

   * - ``dcgmExporter.hostNetwork``
     - When set to ``true``, the DCGM Exporter pods use the host's network namespace.
     - ``false``

   * - ``dcgmExporter.hostPID``
     - When set to ``true``, the DCGM Exporter pods use the host's process ID namespace.
     - ``false``

   * - ``dcgmExporter.enablePodLabels``
     - When set to ``true``, pod labels are added to the GPU metrics.
       The Operator grants the exporter read access to pods.
     - ``false``

   * - ``dcgmExporter.enablePodUID``
     - When set to ``true``, the pod UID is added to the GPU metrics.
       The Operator grants the exporter read access to pods.
     - ``false``

   * - ``dcgmExporter.podLabelAllowlistRegex``
     - List of regular expressions that select which pod labels are added.
       Use it to limit the number of Prometheus series.
     - ``none``

   * - ``dcgmExporter.hpcJobMapping.enabled``
     - When set to ``true``, GPU metrics get HPC job labels from files that a workload manager, such as Slurm, writes on the node.
       The Operator mounts the job mapping directory from the host.
     - ``none``

   * - ``dcgmExporter.hpcJobMapping.directory``
     - Host directory that holds the HPC job mapping files.
     - ``/var/lib/dcgm-exporter/job-mapping``

   * - ``dcgm.enabled``
     - When set to ``true``, the Operator deploys the standalone DCGM host engine.
       Refer to :ref:`dcgm-exporter-hostengine`.
     - ``false``

For the other Operator options, refer to :external+gpuop:ref:`chart-customization-options`.


.. _dcgm-exporter-custom-metrics:

********************
Custom Metrics Files
********************

By default, DCGM Exporter collects the metrics in ``/etc/dcgm-exporter/default-counters.csv`` in the image.
To collect a different set, supply your own metrics file in a ConfigMap.
For the file format and the available metrics, refer to
`DCGM Exporter metrics <https://docs.nvidia.com/datacenter/dcgm/latest/reference/dcgm-exporter-metrics.html>`__.

Metric names and units depend on the DCGM Exporter version.
Newer releases use the DCGM 4.7 field names, such as ``DCGM_FI_DEV_GPU_UTIL_RATIO``, and still load the older names, such as ``DCGM_FI_DEV_GPU_UTIL``.
A metric that uses an older name keeps that name and its older unit.
The DCGM Exporter release notes list the names each release uses.

#. Create a ConfigMap in the Operator namespace.
   Store the file under the key ``dcgm-metrics.csv``:

   .. code-block:: console

      $ kubectl create configmap custom-dcgm-exporter-metrics -n gpu-operator \
          --from-file=dcgm-metrics.csv=./dcgm-metrics.csv

#. Set ``dcgmExporter.config.name`` to the ConfigMap name.
   With Helm:

   .. code-block:: console

      $ helm upgrade gpu-operator nvidia/gpu-operator -n gpu-operator \
          --reuse-values --set dcgmExporter.config.name=custom-dcgm-exporter-metrics

   Or patch the cluster policy:

   .. code-block:: console

      $ kubectl patch clusterpolicies.nvidia.com/cluster-policy --type=merge \
          -p '{"spec": {"dcgmExporter": {"config": {"name": "custom-dcgm-exporter-metrics"}}}}'

The Operator mounts the file at ``/etc/dcgm-exporter/dcgm-metrics.csv``
and sets ``DCGM_EXPORTER_COLLECTORS`` to that path.
The ConfigMap replaces only the metrics file.
The configuration file in the image still applies.

Instead of the first step, you can have the Helm chart create the ConfigMap.
Set ``dcgmExporter.config.create=true`` and put the file contents in ``dcgmExporter.config.data``.

.. note::

   The Operator mounts the file with ``subPath``, so Kubernetes does not update the file in running pods when you edit the ConfigMap.
   After you change the ConfigMap, restart the DCGM Exporter pods:

   .. code-block:: console

      $ kubectl delete pod -n gpu-operator -l app=nvidia-dcgm-exporter

Do not use the ``DCGM_EXPORTER_CONFIGMAP_DATA`` environment variable to read metrics from a ConfigMap.
It is deprecated.


.. _dcgm-exporter-prometheus-scrape:

********************************
Collecting Metrics in Prometheus
********************************

If your cluster runs the `Prometheus Operator <https://prometheus-operator.dev/>`__,
for example through the ``kube-prometheus-stack`` Helm chart,
install it, or at least its custom resource definitions, before the GPU Operator.
The GPU Operator then creates the ``nvidia-dcgm-exporter`` ``ServiceMonitor``.

Prometheus must select the ``ServiceMonitor``.
By default, ``kube-prometheus-stack`` selects only ``ServiceMonitor`` objects that have its ``release`` label.
Do one of the following:

* Add the label through the GPU Operator:

  .. code-block:: console

     $ helm upgrade gpu-operator nvidia/gpu-operator -n gpu-operator \
         --reuse-values --set dcgmExporter.serviceMonitor.additionalLabels.release=<prometheus-release-name>

* Configure Prometheus to select all ``ServiceMonitor`` objects.
  In ``kube-prometheus-stack``, set ``prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false``.

To check that Prometheus collects the metrics, query GPU utilization.
Depending on the DCGM Exporter version, the metric is ``DCGM_FI_DEV_GPU_UTIL``, in percent,
or ``DCGM_FI_DEV_GPU_UTIL_RATIO``, a ratio from 0 to 1.

If you do not use the Prometheus Operator, scrape the ``nvidia-dcgm-exporter`` service on port ``9400``.
Refer to `Configure Prometheus for DCGM Exporter <https://docs.nvidia.com/datacenter/dcgm/latest/learn/getting-started-for-system-administrators/configure-prometheus-for-dcgm-exporter.html>`__.

For a Grafana dashboard, import ``dcgm-exporter-dashboard.json`` from the
`DCGM Exporter repository <https://github.com/NVIDIA/dcgm-exporter/tree/main/grafana>`__.
Use the file from the release tag that matches your DCGM Exporter version, such as ``4.8.4`` for the image ``4.6.1-4.8.4-distroless``,
so that the dashboard queries the metric names your exporter serves.
The `releases page <https://github.com/NVIDIA/dcgm-exporter/releases>`__ lists the tags.
On OpenShift, refer to :external+ocp:ref:`enable-gpu-monitoring-dashboard`.


*******************************
Metrics for Shared GPUs and MIG
*******************************

With GPU time-slicing or MPS, set ``KUBERNETES_VIRTUAL_GPUS=true`` in ``dcgmExporter.env``
so that the metrics are associated with the pods that share the GPU.
Refer to :external+gpuop:ref:`gpu-sharing`.

With MIG, DCGM Exporter reports metrics for each GPU instance.
The MIG Manager stops the DCGM Exporter pods while it changes the MIG configuration of a node.
For the MIG labels and metrics, refer to
`DCGM Exporter metrics <https://docs.nvidia.com/datacenter/dcgm/latest/reference/dcgm-exporter-metrics.html>`__.


.. _dcgm-exporter-hostengine:

*********************************
Using a Separate DCGM Host Engine
*********************************

By default, each DCGM Exporter pod runs its own embedded DCGM host engine.
You can use a separate host engine instead:

* **Standalone DCGM from the Operator.**
  Set ``dcgm.enabled=true``.
  The Operator deploys the ``nvidia-dcgm`` daemon set and points DCGM Exporter at the ``nvidia-dcgm`` service on port ``5555``.
  The default ``ClusterPolicy`` on OpenShift sets ``dcgm.enabled`` to ``true``.

* **DCGM on the host**, such as on NVIDIA DGX systems.
  Keep ``dcgm.enabled=false`` and point DCGM Exporter at the host engine on the node:

  .. code-block:: yaml

     dcgmExporter:
       hostNetwork: true
       env:
       - name: DCGM_REMOTE_HOSTENGINE_INFO
         value: localhost:5555

Each DCGM Exporter release is tested with one DCGM version, which its release notes name.
With an older host engine, DCGM Exporter can exit at startup with an error that lists the fields the host engine refuses.
If you set ``dcgmExporter.version``, also set ``dcgm.version``, or the DCGM on the host, to the DCGM version that release is tested with,
and change them together.

For more information, refer to
`Connect to a DCGM host engine <https://docs.nvidia.com/datacenter/dcgm/latest/installation/install-dcgm-exporter.html#connect-to-a-dcgm-host-engine>`__.
