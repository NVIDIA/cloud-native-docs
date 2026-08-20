---
name: gpu-operator-evidence-bundle
description: Collect a safe GPU Operator evidence bundle for troubleshooting, escalation, or test reporting.
tags: [gpu-operator, evidence, must-gather, support]
---

# GPU Operator Evidence Bundle

Use when troubleshooting is unclear, escalation is likely, or a test report
needs durable evidence.

## Preconditions

- Approval to collect logs/manifests.
- Sensitive data handling plan for node names, workload names, image pull
  secrets, notebook tokens, and host logs.
- `kubectl` context proven.

## Quick Bundle

```bash
ARTIFACT_DIR="${ARTIFACT_DIR:-/tmp/nvidia-gpu-operator_$(date +%Y%m%d_%H%M)}"
mkdir -p "$ARTIFACT_DIR"
hostname > "$ARTIFACT_DIR/host.name"
echo "KUBECONFIG=${KUBECONFIG:-unset}" > "$ARTIFACT_DIR/kubeconfig.env"
kubectl config current-context > "$ARTIFACT_DIR/kube.context"
kubectl get nodes -o wide > "$ARTIFACT_DIR/nodes.status"
kubectl get nodes --show-labels > "$ARTIFACT_DIR/nodes.labels"
kubectl describe nodes -l nvidia.com/gpu.present=true > "$ARTIFACT_DIR/gpu_nodes.describe" || true
kubectl get runtimeclass > "$ARTIFACT_DIR/runtimeclasses.txt" || true
kubectl get pods -n gpu-operator -o wide > "$ARTIFACT_DIR/gpu_operator_pods.status"
kubectl get pods -n gpu-operator -o yaml > "$ARTIFACT_DIR/gpu_operator_pods.yaml"
kubectl get ds -n gpu-operator -o wide > "$ARTIFACT_DIR/gpu_operator_daemonsets.status"
kubectl get clusterpolicy -o yaml > "$ARTIFACT_DIR/clusterpolicy.yaml"
kubectl get nvidiadrivers.nvidia.com -A -o yaml > "$ARTIFACT_DIR/nvidiadrivers.yaml" || true
kubectl get events -A --sort-by='.lastTimestamp' > "$ARTIFACT_DIR/events.all"
helm list -n gpu-operator > "$ARTIFACT_DIR/helm.list" || true
helm get values gpu-operator -n gpu-operator -o yaml > "$ARTIFACT_DIR/helm.values.yaml" || true
```

Sandbox metadata when available:

```bash
curl -fsS -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/machine-type \
  > "$ARTIFACT_DIR/cloud.machine_type" 2>/dev/null || true
curl -fsS -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/zone \
  > "$ARTIFACT_DIR/cloud.zone" 2>/dev/null || true
curl -fsS -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/id \
  > "$ARTIFACT_DIR/cloud.instance_id" 2>/dev/null || true
```

Pod logs:

```bash
for pod in $(kubectl get pods -n gpu-operator -o name); do
  name="${pod#pod/}"
  kubectl describe "$pod" -n gpu-operator > "$ARTIFACT_DIR/pod_${name}.describe" || true
  kubectl logs "$pod" -n gpu-operator --all-containers --prefix --timestamps > "$ARTIFACT_DIR/pod_${name}.log" || true
  kubectl logs "$pod" -n gpu-operator --all-containers --prefix --timestamps --previous > "$ARTIFACT_DIR/pod_${name}.previous.log" || true
done
```

## Upstream Must-Gather

Prefer the target tag:

```bash
curl -o must-gather.sh -L https://raw.githubusercontent.com/NVIDIA/gpu-operator/v26.3.3/hack/must-gather.sh
chmod +x must-gather.sh
ARTIFACT_DIR="$ARTIFACT_DIR" ./must-gather.sh
```

Review before sharing; `nvidia-bug-report.sh` output can include detailed host
state.

## Escalation Summary

```text
Product/chart version:
Kubernetes/runtime/OS/kernel:
GPU model and driver:
Command context proof:
Install values:
First failing layer:
Primary symptom:
Commands run:
Risky action proposed:
Artifacts:
Known unknowns:
```
