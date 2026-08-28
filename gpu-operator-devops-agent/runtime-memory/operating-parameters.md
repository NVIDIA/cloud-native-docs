# Operating Parameters

Record target-specific values and support caveats here.

## Entry Template

```markdown
### YYYY-MM-DD - <target name>

- Sandbox/cluster:
- GPU Operator version:
- Helm chart version:
- Kubernetes distribution/version:
- Container runtime/version:
- OS/kernel:
- GPU model:
- Driver version:
- Install branch:
- Enabled features:
- Known-tested/support caveats:
- Workload/example suite:
- Cleanup status:
```

### 2026-07-02 - Live A100 GPU instance

- Sandbox/cluster: a live A100 GPU instance; single-node K3s cluster context `default`.
- GPU Operator version: v26.3.3.
- Helm chart version: `gpu-operator-v26.3.3`.
- Kubernetes distribution/version: K3s v1.36.2+k3s1.
- Container runtime/version: K3s node runtime `containerd://2.3.2-k3s2`; host `/usr/bin/containerd` reported containerd.io v2.2.5 before K3s.
- OS/kernel: Ubuntu 22.04.5 LTS; kernel `6.8.0-1060-gcp`.
- GPU model: NVIDIA A100-SXM4-80GB, MIG disabled.
- Driver version: 580.159.03, host-managed.
- Install branch: `driver.enabled=false`; chart-managed NFD/toolkit/device-plugin; namespace `gpu-operator` labeled `pod-security.kubernetes.io/enforce=privileged`.
- Enabled features: `cdi.enabled=true`, `cdi.nriPluginEnabled=true`, `toolkit.enabled=true`, `nfd.enabled=true`.
- Known-tested/support caveats: K3s v1.36/containerd 2.3 is newer than the package's known-tested NRI range; live sandbox validation passed, but production use still needs support-matrix confirmation.
- Workload/example suite: Core install proof only: package `manifests/cuda-vectoradd.yaml` completed with `Test PASSED`; bad RuntimeClass troubleshooting scenario produced expected kubelet runtime-handler failure and was cleaned up.
- Cleanup status: Validation pods and bad RuntimeClass scenario deleted; GPU Operator and K3s intentionally left running during the instance-local test; the instance was stopped after all testing completed.

### 2026-07-02 - Live A100 GPU follow-up multi-instance run

- Sandbox/cluster: multiple live A100 GPU instances;
  single-node K3s clusters.
- GPU Operator version: v26.3.3.
- Helm chart version: `gpu-operator-v26.3.3`.
- Kubernetes distribution/version: K3s v1.36.2+k3s1.
- Container runtime/version: `containerd://2.3.2-k3s2`.
- OS/kernel: Ubuntu 22.04.5 LTS; kernel `6.8.0-1060-gcp`.
- GPU model: NVIDIA A100-SXM4-80GB, MIG disabled.
- Driver version: 580.159.03, host-managed.
- Install branch: `driver.enabled=false`; toolkit/CDI/NRI enabled.
- Enabled features: temporary time-slicing, then restored to baseline.
- Known-tested/support caveats: this is sandbox evidence for the newer K3s and
  containerd combination, not a support-matrix guarantee.
- Workload/example suite: time-slicing workload proof, same-version Helm
  reconciliation with pre/post VectorAdd, bad RuntimeClass scenario, final
  cleanup proof.
- Cleanup status: all test resources removed, node allocatable GPU restored to
  `1`, and all three instances were stopped.
