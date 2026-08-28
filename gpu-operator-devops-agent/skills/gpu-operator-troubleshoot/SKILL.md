---
name: gpu-operator-troubleshoot
description: Diagnose GPU Operator failures by command context and earliest failing layer, with safe recovery and escalation.
tags: [gpu-operator, troubleshoot, runtime, driver, xid, mig]
---

# GPU Operator Troubleshoot

Use for failed installs, not-ready `ClusterPolicy`, missing GPUs, runtime
handler errors, stuck upgrades, MIG issues, and DCGM failures.

## First Rule

Take inventory, prove command context, then find the earliest failed layer:

1. Intended sandbox/cluster context.
2. Host GPU visible.
3. Kubernetes nodes ready.
4. NFD/GPU labels present.
5. Driver healthy or host driver accepted.
6. Toolkit/CDI/NRI runtime injection healthy.
7. Device plugin advertises resources.
8. Workload manifest succeeds.
9. Optional observability/MIG/example path succeeds.

## Evidence Commands

Preferred inventory path:

```bash
scripts/inventory-gpu-operator-environment.sh
```

If the script is unavailable, collect the same facts manually:

```bash
hostname
echo "KUBECONFIG=${KUBECONFIG:-unset}"
kubectl config current-context
kubectl get nodes -o wide
kubectl get pods -n gpu-operator -o wide
kubectl get ds -n gpu-operator
kubectl get clusterpolicy -o yaml
kubectl get nodes -L feature.node.kubernetes.io/pci-10de.present,nvidia.com/gpu.present,nvidia.com/gpu.count,nvidia.com/gpu-driver-upgrade-state,nvidia.com/mig.config,nvidia.com/mig.config.state
kubectl get runtimeclass || true
kubectl get events -A --sort-by='.lastTimestamp' | tail -100
```

For failing pods:

```bash
kubectl describe pod -n gpu-operator <pod>
kubectl logs -n gpu-operator <pod> --all-containers --prefix --timestamps
kubectl logs -n gpu-operator <pod> --all-containers --prefix --timestamps --previous
```

## Branches

### Helm Or Kubectl Cannot Reach Fresh K3s

Likely context issue. Set `KUBECONFIG=/etc/rancher/k3s/k3s.yaml`, then rerun
read-only proof. Do not reinstall GPU Operator until context is proven.

### Pods Blocked By Pod Security

Events mention baseline/restricted PodSecurity or privileged container denial.
Label namespace privileged with approval:

```bash
kubectl label --overwrite ns gpu-operator pod-security.kubernetes.io/enforce=privileged
```

Then inspect pods/events before retrying Helm.

### Runtime Handler Error

For `no runtime for "nvidia" is configured`, classify as toolkit/runtime
injection. Load `references/branch-matrix.md`, then check:

```bash
kubectl get clusterpolicy -o jsonpath='{.items[0].spec.cdi.enabled}{" "}{.items[0].spec.cdi.nriPluginEnabled}{"\n"}' 2>/dev/null || kubectl get clusterpolicy cluster-policy -o jsonpath='{.spec.cdi.enabled}{" "}{.spec.cdi.nriPluginEnabled}{"\n"}'
kubectl get runtimeclass || true
kubectl logs -n gpu-operator -l app=nvidia-container-toolkit-daemonset --all-containers --tail=200
```

K3s branch:

- If runtime is in the documented NRI range, CDI+NRI is a candidate.
- If K3s/containerd is `2.3.x` or otherwise newer than the documented NRI
  range, prefer explicit K3s toolkit env when paths exist.
- Use newer-than-documented NRI only as an explicit sandbox experiment with
  workload validation.

### Missing `nvidia.com/gpu`

Check device-plugin logs and Xid:

```bash
kubectl logs -n gpu-operator -l app=nvidia-device-plugin-daemonset --all-containers --tail=200
sudo dmesg | grep -Ei 'NVRM|Xid|nouveau' | tail -80
```

Critical Xid means hardware/driver health; do not fix by restarting the plugin.

### Driver Upgrade Stuck

```bash
kubectl get node -l nvidia.com/gpu.present \
  -ojsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.nvidia\.com/gpu-driver-upgrade-state}{"\n"}{end}'
kubectl get events -A --sort-by='.lastTimestamp' | grep GPUDriverUpgrade
kubectl logs -n gpu-operator deployment/gpu-operator | grep controllers.Upgrade
```

If `upgrade-failed`, fix the recorded cause before relabeling
`upgrade-required`.

### MIG Request With Active Workloads

Stop until workload owners approve disruption. Record current clients, cordon
plan, desired profile, possible reboot, and rollback to `all-disabled`.

## Escalation Package

Use `gpu-operator-evidence-bundle`. Include context proof, first failing layer,
commands run, logs/events, host/runtime facts, Helm values, proposed next
mutation, risk, and rollback.
