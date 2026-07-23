# Supported Scope

Reviewed/generated on 2026-07-02 from public docs/source snapshots.

## Primary Scope

- Product: NVIDIA GPU Operator.
- Version focus: `v26.3.3`.
- Source focus:
  - Public GPU Operator docs snapshot from NVIDIA docs and the public
    `NVIDIA/cloud-native-docs` repository at commit
    `77a2daaf234a2cebc8e178f24e18cc4a6150e8b1`.
  - Public GPU Operator source repository, tag `v26.3.3` release commit
    `b0a49c0e7b2e061dcd83f2bb2fe4fe960c5d0338`.
- Environment focus: test-owned single-node or small Kubernetes clusters,
  especially Ubuntu 22.04/24.04, K3s/containerd, and A100 GPUs.
## Supported With Caution

- Official platform-matrix Kubernetes/container runtime/OS combinations.
- K3s with CDI and NRI when containerd is in the documented NRI range:
  `1.7.30`, `2.1.x`, or `2.2.x`.
- Containerd newer than the documented NRI range, such as `2.3.x`: not
  declared known-tested by the docs snapshot. Treat as newer-untested; require
  sandbox approval, context proof, NRI caveat, operand logs, allocatable GPU
  proof, and workload manifest success before declaring the branch usable.
- Host-preinstalled drivers: supported only as integration. GPU Operator does
  not own host driver lifecycle when `driver.enabled=false`.
- MIG on A100/H100-class GPUs with workload disruption approval and possible
  reboot planning.

## Explicit Non-Goals

- Production execution without environment owner approval.
- OpenShift OLM, vGPU licensing, confidential containers, Kata, KubeVirt,
  GPUDirect RDMA/GDS, GDRCopy, NVAIE, air-gapped/private registry flows, or
  managed cloud cluster creation.
- Jetson/integrated-GPU platforms.
- Broad multi-node SLO/disruption engineering beyond the basic upgrade and
  rollback controls documented here.

## Verification Gap Statement

This package has not itself been rerun end-to-end after authoring. It
incorporates prior live-test results and public field-scenario distillation,
but package readiness for a new environment requires a package-loaded run that
exercises clean bootstrap, install, workload validation, and at least one
field-shaped troubleshooting scenario.
