.. _attestation:

Attestation
===========

The NVIDIA Reference Architecture for Confidential Containers has remote attestation support for the CPU and GPU built-in. 
Attestation allows a workload owner to cryptographically validate the guest Trusted Computing Base (TCB). 
This process is facilitated by components inside the guest root file system. 
When a secret resource is required inside the confidential guest (to decrypt a container image, or to decrypt a model, for instance), the guest components detect which CPU and GPU enclaves are in use and collect hardware evidence from them. 
This evidence is sent to a remote verifier/broker, for example Trustee, which evaluates the evidence and conditionally releases secrets. 

Features that depend on secrets depend on attestation. 
These features include:

* Pulling encrypted images
* Authenticated container registry support
* Sealed secrets
* Direct workload requests for secrets

To use these features, a remote verifier/broker, like Trustee, must first be provisioned in some trusted environment.

Configure Remote Verifier/Broker (Trustee)
------------------------------------------

Follow the `upstream Trustee documentation <https://confidentialcontainers.org/docs/attestation/installation/>`_ to provision a Trustee instance in a trusted environment with one adjustment. 
To enable the remote NVIDIA verifier, Trustee must be configured to use the remote NVIDIA verifier, which uses the NVIDIA Remote Attestation Service (NRAS) to evaluate the evidence. This is not enabled by default.

To enable the remote verifier, add the following lines to the Trustee configuration file::

   [attestation_service.verifier_config.nvidia_verifier]
   type = "Remote"

If you are using the docker compose Trustee deployment, add the verifier type to ``kbs/config/as-config.json`` prior to starting Trustee.

Following the upstream Trustee documentation, add the following annotation to the workload to point the guest components to Trustee:

.. code-block:: yaml

    io.katacontainers.config.hypervisor.kernel_params: "agent.aa_kbc_params=cc_kbc::http://<kbs-ip>:<kbs-port>"

Now, the guest can be used with attestation. For more information on how to provision Trustee with resources and policies, refer to the `Trustee documentation <https://confidentialcontainers.org/docs/attestation/>`_.

During attestation, the GPU will be set to ready. As such, when running a workload that does attestation, it is not necessary to set the ``nvrc.smi.srs=1`` and ``RUST_LOG=debug`` kernel parameters.

If attestation does not succeed, debugging is best done through the Trustee log. Debug mode can be enabled by setting the ``nvrc.smi.srs=1`` and ``RUST_LOG=debug`` kernel parameters in the Trustee environment.