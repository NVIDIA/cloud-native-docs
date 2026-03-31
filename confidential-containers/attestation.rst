.. _attestation:

Attestation
===========

Confidential Containers has remote attestation support for the CPU and GPU built-in. Attestation allows a workload owner to cryptographically validate the guest TCB. This process is facilitated by components inside the guest rootfs. When a secret resource is required inside the confidential guest (to decrypt a container image, or to decrypt a model, for instance), the guest components detect which CPU and GPU enclaves are in use and collect hardware evidence from them. This evidence is sent to a remote verifier/broker known as Trustee, which evaluates the evidence and conditionally releases secrets. Features that depend on secrets depend on attestation. These features include, pulling encrypted images, authenticated registry support, sealed secrets, direct workload requests for secrets, and more. To use these features, Trustee must first be provisioned in some trusted environment.

Trustee can be set up following `upstream documentation <https://confidentialcontainers.org/docs/attestation/installation/>`_, with one key requirement for attesting NVIDIA devices. Specifically, Trustee must be configured to use the remote NVIDIA verifier, which uses NRAS to evaluate the evidence. This is not enabled by default. Enabling the remote verifier assumes that the user has entered into a `licensing agreement <https://docs.nvidia.com/attestation/cloud-services/latest/license.html>`_ covering NVIDIA attestation services.

To enable the remote verifier, add the following lines to the Trustee configuration file::

   [attestation_service.verifier_config.nvidia_verifier]
   type = "Remote"

If you are using the docker compose Trustee deployment, add the verifier type to kbs/config/as-config.json prior to starting Trustee.

Per upstream documentation, add the following annotation to the workload to point the guest components to Trustee::

   io.katacontainers.config.hypervisor.kernel_params: "agent.aa_kbc_params=cc_kbc::http://<kbs-ip>:<kbs-port>"

Now, the guest can be used with attestation. For more information on how to provision Trustee with resources and policies, refer to the upstream documentation.

During attestation, the GPU will be set to ready. As such, when running a workload that does attestation, it is not necessary to set the nvrc.smi.srs=1 kernel parameter.

If attestation does not succeed, debugging is best done via the Trustee log. Debug mode can be enabled by setting RUST_LOG=debug in the Trustee environment.