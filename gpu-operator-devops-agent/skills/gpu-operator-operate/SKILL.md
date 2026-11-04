---
name: gpu-operator-operate
description: Run GPU Operator day-2 health checks, workload validation, drift detection, and optional example-suite checks.
tags: [gpu-operator, operate, health, validation, dcgm]
---

# GPU Operator Operate

Use for health checks, post-install validation, resource inventory, and drift
detection.

## Preconditions

- `kubectl` context proven against the intended cluster.
- Read-only access for health checks.
- Approval to create/delete disposable validation workloads.

## Health Ladder

1. Context and nodes proven.
2. NVIDIA PCI/GPU labels present or NFD branch understood.
3. GPU Operator controller and operands healthy.
4. Driver is healthy or host-managed driver accepted.
5. Toolkit/CDI/NRI state matches install branch.
6. Device plugin advertises GPUs.
7. `ClusterPolicy` ready.
8. Durable workload manifest passes.
9. Optional examples selected for the environment pass.

## Commands

```bash
kubectl config current-context
kubectl get nodes -o wide
kubectl get nodes -L feature.node.kubernetes.io/pci-10de.present,nvidia.com/gpu.present,nvidia.com/gpu.count,nvidia.com/gpu.product,nvidia.com/mig.config,nvidia.com/mig.config.state
kubectl get pods -n gpu-operator -o wide
kubectl get ds -n gpu-operator
kubectl get clusterpolicy
kubectl get events -n gpu-operator --sort-by='.lastTimestamp' | tail -80
kubectl get runtimeclass || true
```

Resource advertisement:

```bash
kubectl get nodes -o json | jq '.items[] | {name: .metadata.name, allocatable_gpu: .status.allocatable["nvidia.com/gpu"], capacity_gpu: .status.capacity["nvidia.com/gpu"]}'
```

Core workload:

```bash
kubectl apply -f manifests/cuda-vectoradd.yaml
kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/cuda-vectoradd --timeout=120s || true
kubectl get pod cuda-vectoradd -o jsonpath='{.status.phase}{"\n"}'
kubectl logs pod/cuda-vectoradd
kubectl delete -f manifests/cuda-vectoradd.yaml --ignore-not-found
```

Expected: pod phase `Succeeded` and logs include `Test PASSED`.

## Optional Example Suite

- Jupyter notebook: use the docs `tf-notebook.yaml` only when exposing a
  NodePort is acceptable. Capture pod/service status and redact tokens.
- Time slicing: apply documented time-slicing config, then
  `manifests/time-slicing-verification.yaml`; pass requires every requested
  verification replica to reach `Available` and at least one `Test PASSED` log
  from each pod before cleanup. Align the ConfigMap replica count with the
  verification manifest's replica count, or reduce the manifest replica count
  to match the approved ConfigMap value. Restore the original
  `ClusterPolicy.spec.devicePlugin.config` and verify node GPU labels/capacity
  after the test.
- MIG: run only after approved MIG configuration; pass requires expected MIG
  resources and matching workload success.

When optional examples mutate the live `ClusterPolicy` directly instead of
Helm values, record that ownership distinction before maintenance actions.
Cleanup is not complete until the test namespace/config, live ClusterPolicy,
Helm values, node GPU labels/capacity, and a final CUDA smoke all show the
baseline state.

## Drift Signals

- Kube context changes unexpectedly.
- GPU labels disappear.
- Driver/device-plugin daemonset ready count falls below desired.
- `nvidia.com/gpu` allocatable drops or disappears.
- Device-plugin logs mark GPUs unhealthy.
- RuntimeClasses change unexpectedly after CDI/NRI changes.
- Upgrade labels remain non-terminal after the approved window.
- MIG state remains pending/rebooting/failure-like.

## Escalation Package

Include health ladder output, workload manifest/logs, node labels/resources,
`ClusterPolicy`, Helm values, recent events, device-plugin/toolkit/DCGM logs,
runtime version, and whether host/runtime changes occurred.
