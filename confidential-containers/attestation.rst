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

***********
Attestation
***********

The NVIDIA Reference Architecture for Confidential Containers includes built-in remote attestation support for the CPU and GPU. Attestation allows a workload owner to cryptographically verify the guest Trusted Computing Base (TCB) before secrets are released to the workload.

When a workload requires a secret, for example, to decrypt a container image or model, guest components identify the active CPU and GPU enclaves, collect hardware evidence, and send it to a remote verifier/broker such as Trustee. The verifier evaluates the evidence and conditionally releases the secret.

Features that depend on secrets depend on attestation.
These features include:

* Pulling encrypted images
* Authenticated container registry support
* Sealed secrets
* Direct workload requests for secrets

To use these features, a remote verifier/broker, like Trustee, must be provisioned in a trusted environment.
Then you can direct your workloads to use the verifier/broker to authenticate and release secrets based on your configured policies.


Configure Remote Verifier/Broker (Trustee)
==========================================

For an overview of attestation with Trustee, refer to the `Trustee documentation <https://confidentialcontainers.org/docs/attestation/>`_.

Follow the `upstream Trustee documentation <https://confidentialcontainers.org/docs/attestation/installation/>`_ to provision a Trustee instance in a trusted environment.
This will configure Trustee to use the remote NVIDIA verifier, NVIDIA Remote Attestation Service (NRAS), to evaluate the evidence by default.

.. note::

    If attestation does not succeed after provisioning Trustee, enable debug logging by setting the ``RUST_LOG=debug`` environment variable in the Trustee environment. 
    The Trustee log can then be used to diagnose the attestation process.

Next Steps
==========


* Configure policies to use attestation features.

  `Kata Agent <https://github.com/kata-containers/kata-containers/blob/main/src/agent/README.md>`_ (deployed with ``kata-deploy``) runs inside the guest virtual machine to manage the container lifecycle. 
  It enforces a strict, immutable security policy based on Rego (regorus) that prevents the untrusted host from executing unauthorized commands, such as a malicious ``kubectl exec`` command. 
  Attestation-dependent features require that these policies permit the relevant operations.

  Refer to the `Kata Containers Agent Policy documentation <https://github.com/kata-containers/kata-containers/blob/main/docs/how-to/how-to-use-the-kata-agent-policy.md>`_ for more on using policies. You can use the `genpolicy tool <https://github.com/kata-containers/kata-containers/blob/main/src/tools/genpolicy/README.md>`_ (installed with ``kata-deploy``) to autogenerate policies, or write your own manually.
  
  Refer to the Confidential Containers' `Init-Data <https://confidentialcontainers.org/docs/features/initdata>`_ documentation for more information on using the genpolicy tool to autogenerate policies.

* Configure workloads to use attestation features.
  You can configure workloads to use attestation and specify configuration for encrypted images and authenticated container registries.

  Refer to the `Confidential Containers Features <https://confidentialcontainers.org/docs/features>`_ documentation for more information on using attestation features.

