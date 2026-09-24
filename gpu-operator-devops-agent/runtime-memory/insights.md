# Insights

Append validated reusable lessons here.

## Entry Template

```markdown
### YYYY-MM-DD - <short insight>

- Product/version:
- Environment:
- Evidence:
- Observation:
- Model/branch impact:
- Package update needed:
- Confidence:
```

### 2026-07-02 - K3s 1.36/containerd 2.3 sandbox proved host-driver plus CDI/NRI branch

- Product/version: NVIDIA GPU Operator v26.3.3.
- Environment: a live Brev A100 single-node sandbox (disposable).
- Evidence: live target evidence from `kubectl get clusterpolicy`, node allocatable resources, and package VectorAdd manifest.
- Observation: On Ubuntu 22.04.5 with host driver 580.159.03, K3s v1.36.2+k3s1 and runtime `containerd://2.3.2-k3s2`, Helm values `driver.enabled=false` and `cdi.nriPluginEnabled=true` reconciled to `ClusterPolicy.ready`; device-plugin advertised one GPU; `manifests/cuda-vectoradd.yaml` completed with `Test PASSED`.
- Model/branch impact: The newer-than-known K3s/containerd CDI+NRI branch can succeed in a disposable Brev A100 sandbox, but should remain caveated until public support docs explicitly cover that runtime range.
- Package update needed: Keep the branch as sandbox-prove-before-production; record this as a live proof point, not a support guarantee.
- Confidence: High for this live sandbox; medium for generalization.

### 2026-07-02 - Time-slicing and maintenance run proved safe optional-example path

- Product/version: NVIDIA GPU Operator v26.3.3.
- Environment: multiple live Brev A100 single-node sandboxes (disposable).
- Evidence: live validation run: time-slicing enabled, workload proof passed,
  same-version Helm reconciliation succeeded, bad RuntimeClass scenario was
  diagnosed and cleaned up, and node allocatable GPU was restored to `1`.
- Observation: time-slicing is a useful second-stage discriminator because it
  safely changes GPU advertisement without MIG reconfiguration. It also exposes
  whether the agent understands ConfigMap, live ClusterPolicy, Helm-values, and
  workload-proof boundaries.
- Model/branch impact: optional examples should be part of package evaluation,
  but cleanup must verify both live object state and Helm state.
- Package update needed: keep cleanup verification and per-replica log proof in
  operate/maintenance guidance.
- Confidence: High for Brev A100 single-node sandbox.
