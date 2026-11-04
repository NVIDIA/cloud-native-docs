# Discovered Resources

Append public resources discovered during operation.

## Entry Template

```markdown
### YYYY-MM-DD - <resource title>

- URL/path:
- Visibility: public | live-target-evidence | internal-non-exportable
- Product/version scope:
- Why it matters:
- Claims or scenarios it supports:
- Follow-up:
```

## Seed Resources

- https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html
- https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/cdi.html
- https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/platform-support.html
- https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/troubleshooting.html
- https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/release-notes.html
- https://github.com/NVIDIA/gpu-operator/tree/v26.3.3

### 2026-07-02 - Live Brev A100 v26.3.3 install proof

- URL/path: live-target-evidence from a live A100 GPU instance run; the full transcript is not shipped with this package.
- Visibility: live-target-evidence.
- Product/version scope: NVIDIA GPU Operator v26.3.3 on Brev A100 with K3s v1.36.2+k3s1.
- Why it matters: Provides a concrete proof point for host-managed driver plus chart-managed toolkit/CDI/NRI on a newer K3s/containerd sandbox.
- Claims or scenarios it supports: Context proof, host GPU proof, Helm explicit values, `ClusterPolicy.ready`, allocatable `nvidia.com/gpu=1`, VectorAdd success, bad RuntimeClass first-layer diagnosis.
- Follow-up: Use as package-local evidence only; do not cite as public support guarantee.
