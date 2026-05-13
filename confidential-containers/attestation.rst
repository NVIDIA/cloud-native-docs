.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
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


.. _attestation:

###########
Attestation
###########


The :doc:`Confidential Containers deployment guide <confidential-containers-deploy>` configures your cluster to run workloads in a Confidential Container.
To strengthen workload security, configure attestation to verify the guest Trusted Execution Environment (TEE) for the CPU and GPU before secrets are released to a workload.

Attestation is required for any feature that depends on secrets, including:

* Pulling encrypted container images
* Accessing authenticated container registries
* Using sealed secrets
* Requesting secrets directly from workloads

When a workload requires a secret, such as a key to decrypt a container image or model, guest components collect hardware evidence from the active CPU and GPU enclaves.
The evidence is sent to a remote verifier, Trustee, which evaluates the evidence against configured policies and conditionally releases the secret.
Trustee is typically deployed in a separate trusted environment that is reachable from your worker nodes over the network.

.. note::

  This page is an educational overview of attestation with Confidential Containers, not a complete configuration guide.
  The attestation workflow is fully documented in the upstream `Confidential Containers documentation <https://confidentialcontainers.org/docs/attestation/>`_, which is the source of truth for setup and configuration details.

  Attestation is not required to deploy Confidential Containers, but is required for features that rely on secrets in your cluster.


*************
Prerequisites
*************

* A Kubernetes cluster configured to deploy Confidential Containers workloads.
  Refer to the :doc:`deployment guide <confidential-containers-deploy>` for configuration steps.
* A machine to host the Trustee instance.
  For production, deploy Trustee in a separate trusted environment.
  For development, Trustee can run in the same cluster.
  Trustee does not require Confidential Computing hardware or a GPU.
* Network connectivity from the worker nodes in your Kubernetes cluster to the Trustee instance.

**********************
Configuration Workflow
**********************

After you meet the prerequisites, complete the following steps to enable attestation:

#. :ref:`Provision Trustee <provision-trustee>`, the remote verifier and key broker, in a trusted environment.
#. :ref:`Configure your workloads <configure-workloads-trustee>` to point to the Trustee network endpoint.
#. Optionally, :ref:`customize attestation workflows <customize-attestation>` for your use cases.

After configuration, the Confidential Containers runtime automatically runs the attestation flow when a workload requires it.

.. _provision-trustee:

*****************
Provision Trustee
*****************

Trustee is an open-source framework used in Confidential Containers to verify attestation evidence and conditionally release secrets.
For a full overview of attestation with Trustee, refer to the upstream `Trustee documentation <https://confidentialcontainers.org/docs/attestation/>`_.

To provision a Trustee instance, follow the recommended upstream `Install Trustee in Docker <https://confidentialcontainers.org/docs/attestation/installation/docker/>`_ guide.

.. note::

   Guests with many passthrough devices, such as NVIDIA PPCIE GPUs, can produce attestation tokens that exceed HTTP header size limits.

   To avoid this, set ``verbose_token`` to ``false`` in the Attestation Service configuration file and restart Trustee.
   Refer to the upstream `Attestation Service configuration <https://github.com/confidential-containers/trustee/blob/main/attestation-service/docs/config.md>`_ documentation for details.

After you complete installation, Trustee is configured to use the NVIDIA Remote Attestation Service (NRAS) to evaluate GPU evidence by default.

.. _configure-workloads-trustee:

***********************************
Configure Workloads for Attestation
***********************************

To enable attestation for your workloads, point them to the Trustee network endpoint, also called the Key Broker Service (KBS) endpoint, by adding the following annotation to your workload pod spec:

.. code-block:: yaml

   io.katacontainers.config.hypervisor.kernel_params: "agent.aa_kbc_params=cc_kbc::http://<kbs-ip>:<kbs-port>"

Replace ``<kbs-ip>`` with the IP address or hostname at which your Trustee instance is reachable from the worker nodes.
Replace ``<kbs-port>`` with the port that Trustee listens on (default: ``8080``).

Refer to the upstream `Setup Confidential Containers <https://confidentialcontainers.org/docs/attestation/coco-setup/>`_ documentation for more information on configuring workloads for attestation.

.. _customize-attestation:

*****************************************
Optional: Customize Attestation Workflows
*****************************************

Confidential Containers enables sensible default attestation policies for NVIDIA Confidential Computing GPUs.
In most cases, the default policy is appropriate and you only need to provide reference values.
For more information, refer to the upstream `Confidential Containers reference values <https://confidentialcontainers.org/docs/attestation/reference-values/>`_ documentation.

You can use the Key Broker Service (KBS) Client Tool to configure Trustee reference values and secrets.
Refer to the upstream documentation on `using the KBS Client Tool <https://confidentialcontainers.org/docs/attestation/client-tool/>`_.

For more advanced customization, refer to the following upstream Confidential Containers documentation:

* `Resources <https://confidentialcontainers.org/docs/attestation/resources/>`_: Create the resources, such as secrets, that your workloads need.
* `Policies <https://confidentialcontainers.org/docs/attestation/policies/>`_: Configure the policy types that secure workloads at different layers.
* `Features <https://confidentialcontainers.org/docs/features>`_: Browse the full list of attestation features and how to configure them.

***************
Troubleshooting
***************

If attestation does not succeed after provisioning Trustee, enable debug logging by setting the ``RUST_LOG=debug`` environment variable in the Trustee environment.
Use the Trustee log to diagnose the attestation process.

**********
Next Steps
**********

* Refer to the upstream `Confidential Containers Features <https://confidentialcontainers.org/docs/features>`_ for complete documentation on attestation features.
* If you haven't already, refer to the :doc:`Confidential Containers deployment guide <confidential-containers-deploy>` to configure your environment for confidential workloads.
