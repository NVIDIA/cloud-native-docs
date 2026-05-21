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


.. _attestation-overview:

***********
Attestation
***********

In Confidential Containers, a Trusted Execution Environment (TEE) isolates a workload from the host.
Attestation is a process that cryptographically proves the state of the guest TEE, including both the CPU and the GPU, to a remote verifier before any secret or sensitive resource is released to the workload.
Attestation is required for any feature that depends on secrets, including:

* Pulling encrypted container images
* Accessing authenticated container registries
* Using sealed secrets
* Requesting secrets directly from workloads

When a workload requires a secret, such as a key to decrypt a container image or model, guest components collect hardware evidence from the active CPU and GPU enclaves. The evidence is sent to Trustee, the remote verifier in Confidential Containers deployments. Trustee evaluates the evidence against known-good reference values and configured policies, and conditionally releases the requested resource.

Key Concepts
============

The following concepts appear throughout this page:

* Confidential Containers (CoCo): The open-source project that implements the cloud-native approach to Confidential Computing. CoCo uses Kata Containers as the sandbox and Trustee as the attestation framework. Refer to the upstream `Confidential Containers documentation <https://confidentialcontainers.org/docs/>`_ for project background and attestation best practices.
* Trusted Execution Environment (TEE): A hardware-isolated environment, such as AMD SEV-SNP, Intel TDX, or an NVIDIA Confidential Computing GPU, that protects code and data in use.
* Remote attestation: The process of cryptographically proving to a remote party that a TEE is running the expected, untampered software stack before that party releases secrets to it.
* Trustee: The remote verifier in the Confidential Containers attestation flow. Trustee is composed of three cooperating services:

  * Key Broker Service (KBS): The HTTP endpoint that clients and confidential guests talk to. KBS orchestrates the attestation exchange and conditionally releases resources when policy allows.
  * Attestation Service (AS): Verifies hardware evidence presented by a guest TEE against reference values.
  * Reference Value Provider Service (RVPS): Holds the known-good reference values that the Attestation Service compares evidence against.
* KBS resource: A secret, for example, a key, credential, or token, that Trustee releases to a guest when attestation succeeds. Resources are addressed by a three-part path: ``<repository>/<type>/<tag>``.
* Policy: The rule set that Trustee evaluates against verified evidence to decide whether to release a resource. By default, Trustee denies resource requests from clients that have not presented valid TEE evidence.

Quickstart
==========

This page walks you through standing up a development Trustee instance with Docker Compose, installing the Key Broker Service (KBS) client tool, and sending a sample resource request to confirm the system is reachable.
The goal is to give you a working attestation backend and a client you can use to interact with it before you wire it into a Confidential Containers workload.

This page is for new users who want to try out attestation on a single Linux host.
For a deeper explanation of attestation, Trustee, and the full set of features, refer to the upstream `Attestation <https://confidentialcontainers.org/docs/attestation/>`_ and `Features <https://confidentialcontainers.org/docs/features>`_ sections of the Confidential Containers documentation.

This quickstart runs on a standalone Linux host and does not require a Kubernetes cluster or the Confidential Containers runtime to complete.
In a real deployment, attestation builds on the runtime setup described in the :doc:`Confidential Containers deployment guide <confidential-containers-deploy>`. Confidential workloads use Trustee to cryptographically verify their TEE before they receive secrets, encrypted container images, authenticated registries, or other sensitive resources.

.. note::

   This quickstart is for development and evaluation only. Do not use the Trustee instance you stand up here in production.
   It does not deploy a Trusted Execution Environment (TEE), does not produce real hardware attestation evidence, and does not release any secrets to a workload. It only validates that the Trustee components are running and reachable.
   To run attestation against real evidence from a confidential workload, refer to the upstream `Attestation <https://confidentialcontainers.org/docs/attestation/>`_ and `Features <https://confidentialcontainers.org/docs/features>`_ documentation for more information.


What You'll Build
-----------------

By the end of this quickstart, you will have:

* A local Trustee instance (KBS, Attestation Service, and Reference Value Provider Service) running in Docker containers on ``127.0.0.1:8080``.
* The ``kbs-client`` command-line tool installed and able to reach your Trustee instance.
* A sample resource request that exercises the end-to-end request path.

You'll know you're done when ``kbs-client`` can send a request to KBS and receive a response from the Trustee policy engine, even if that response is a policy denial.
A denial in this quickstart is the expected, successful outcome: it confirms that the client reached KBS, the Attestation Service evaluated the request, and policy was applied.


Prerequisites
-------------

* A Linux host with internet access.
  Trustee runs as a set of containers, so the host does not require confidential-computing hardware or an NVIDIA GPU.
* Docker Engine with the Compose plugin installed.
  Refer to the `Docker Engine install guide <https://docs.docker.com/engine/install/>`_ if Docker is not already installed.
* ``git``, ``curl``, and ``openssl`` available on the host.
* ORAS CLI installed and on your ``PATH``.
  ORAS is used to pull the ``kbs-client`` binary from the upstream container registry.
  Refer to the `ORAS installation guide <https://oras.land/docs/installation>`_ if ORAS is not already installed.


Step 1: Install Trustee with Docker Compose
-------------------------------------------

Clone the upstream Trustee repository.
The repository ships with a ``docker-compose.yml`` that wires KBS, the Attestation Service, and the Reference Value Provider Service together.

.. code-block:: console

   $ git clone https://github.com/confidential-containers/trustee.git && cd trustee

Start the Trustee containers in the background.

.. code-block:: console

   $ docker compose up -d

*Example Output:*

.. code-block:: output

   [+] Running 4/4
    ✔ Network trustee_default     Created
    ✔ Container trustee-rvps-1    Started
    ✔ Container trustee-as-1      Started
    ✔ Container trustee-kbs-1     Started

.. note::

   On first run, ``docker compose up -d`` pulls the KBS, AS, and RVPS images before starting them.
   This step can take several minutes. The command returns once the containers are starting. The services may need an additional few seconds to become ready to accept requests.

For details on optional configuration such as the admin keypair, debug logging, and per-service config files, refer to the upstream `Install Trustee in Docker <https://confidentialcontainers.org/docs/attestation/installation/docker/>`_ guide.


Step 2: Verify Trustee Is Running
---------------------------------

Confirm all three Trustee containers are up.

.. code-block:: console

   $ docker compose ps

*Example Output:*

.. code-block:: output

   NAME              IMAGE                     STATUS    PORTS
   trustee-as-1      .../attestation-service   Up        -
   trustee-kbs-1     .../kbs                   Up        0.0.0.0:8080->8080/tcp
   trustee-rvps-1    .../rvps                  Up        -

Confirm KBS is listening on port ``8080`` by sending a POST to the attestation endpoint.
The request body is intentionally empty. You are checking reachability, not submitting evidence.

.. code-block:: console

   $ curl -X POST http://127.0.0.1:8080/kbs/v0/attest

Any HTTP response from KBS, including an error response that rejects the empty request body, confirms KBS is listening and responding.
A connection refused or no-route error indicates that the containers are not running or that port ``8080`` is not exposed.

.. note::

   It is typically not recommended to curl the KBS endpoints directly unless you are checking connectivity. 
   Use the ``kbs-client``, installed in the next step, instead.


Step 3: Install the KBS Client Tool
-----------------------------------

The KBS client tool, ``kbs-client``, is distributed as a container artifact in the Confidential Containers GitHub Container Registry.
This tool is mainly used for configuring Trustee.

Pull the ``kbs-client`` artifact into the current directory with ORAS.

.. code-block:: console

   $ oras pull ghcr.io/confidential-containers/staged-images/kbs-client:latest

*Example Output:*

.. code-block:: output

   ✓ Pulled      kbs-client                                    12.3/12.3 MB 100.00%
   ✓ Pulled      application/vnd.oci.image.manifest.v1+json    533/533  B  100.00%
   Pulled [registry] ghcr.io/confidential-containers/staged-images/kbs-client:latest
   Digest: sha256:a2a48a7cea6dc5d1bad3baea15f4162835e1262eb74fdf4847a6382d09dc5caa

Confirm the ``kbs-client`` binary was extracted to the current directory.

.. code-block:: console

   $ ls kbs-client

Make the binary executable.

.. code-block:: console

   $ chmod +x kbs-client

Confirm the binary runs.

.. code-block:: console

   $ ./kbs-client --help

.. note::

   The ORAS-distributed ``kbs-client`` does not support requesting resources from inside a TEE enclave.
   For in-enclave use, refer to the upstream `Client Tool documentation <https://confidentialcontainers.org/docs/attestation/client-tool/>`_.


Step 4: Send a Sample Resource Request
--------------------------------------

Use ``kbs-client`` to request a resource from your local Trustee.
The request below uses a placeholder resource path. 
You do not need to pre-create the resource for this check.
The ``get-resource`` endpoint can be used (including inside a TEE), but it will always invoke the sample attester, which generates fake evidence for testing.

.. code-block:: console

   $ ./kbs-client --url http://127.0.0.1:8080 get-resource --path my_repo/resource_type/123abc

Trustee will deny the request because you are not running inside a TEE, required by the default policy, and you have not presented valid attestation evidence.
A policy-denied response is the expected, successful outcome of this quickstart.
It confirms that the client reached KBS, KBS routed the request through the Attestation Service, and the configured policy rejected the request.

*Example Output:*

.. code-block:: output

   WARN kbs_protocol::client::rcar_client: Authenticating with KBS failed. Perform a new RCAR handshake: ErrorInformation {
       error_type: "https://github.com/confidential-containers/kbs/errors/PolicyDeny",
       detail: "Access denied by policy",
   }
   Error: request unauthorized

The ``PolicyDeny`` warning and the final ``request unauthorized`` error confirm that KBS received the request, the Attestation Service evaluated it, and policy rejected it.

If you instead see a connection error, KBS is not reachable. Revisit Step 2.


Next Steps
==========

You now have a working local Trustee instance and a client that can talk to it. For more details, refer to the upstream Confidential Containers documentation:

* `Attestation <https://confidentialcontainers.org/docs/attestation/>`_ — Trustee architecture, configuration, resources, policies, the client tool, and guidance for production deployment topology, network configuration, and hardening.
* `Features <https://confidentialcontainers.org/docs/features>`_ — the complete set of Confidential Containers features, including how to wire attestation into real workloads.

To shut down the local Trustee instance when you're finished, run the following command from the ``trustee`` repository directory:

.. code-block:: console

   $ docker compose down