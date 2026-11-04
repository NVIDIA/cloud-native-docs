---
name: gpu-operator-install
description: Install NVIDIA GPU Operator safely in a proven sandbox or cluster, including clean K3s bootstrap, staged branch decisions, and durable workload validation.
tags: [gpu-operator, install, helm, k3s, cdi, nri]
---

# GPU Operator Install

Use this skill when planning or running a GPU Operator install.

## Preconditions

- Approved test-owned sandbox or explicit approval for target cluster mutation.
- `kubectl`, `helm`, and `jq`.
- Deployment inventory collected with `references/environment-inventory.md`.
- Command context proven with `references/bootstrap.md`.
- Target version selected. Default: `v26.3.3`.
- Driver ownership and runtime/toolkit branch not finalized until after
  Kubernetes context and runtime evidence are collected.

Before choosing Helm values, read `references/branch-matrix.md` and cite the
row that selected the branch.

## Context Proof

```bash
hostname
echo "KUBECONFIG=${KUBECONFIG:-unset}"
kubectl config current-context
kubectl get nodes -o wide
kubectl get nodes -o json | jq '.items[] | {name: .metadata.name, os: .status.nodeInfo.osImage, kernel: .status.nodeInfo.kernelVersion, runtime: .status.nodeInfo.containerRuntimeVersion}'
helm version
```

For fresh K3s:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes -o wide
```

## Preflight Evidence And Inventory

```bash
scripts/inventory-gpu-operator-environment.sh
```

Expected signals: intended sandbox, Ready node, GPU visible, no unexpected
`nouveau` conflict, runtime version known, and NFD ownership known.

## Branch Logic

| Branch | Choose when | Helm posture | Stop if |
|---|---|---|---|
| Operator-managed driver | no trusted host driver or disposable sandbox wants one owner | default `driver.enabled=true` | host kernel/OS unsupported, no registry access, `nouveau` conflict |
| Host-managed driver | host `nvidia-smi` works and platform owns driver lifecycle | `--set driver.enabled=false` | `nvidia-smi` fails |
| Chart NFD | no owned feature labels exist | default `nfd.enabled=true` | existing NFD owner requires integration |
| Existing NFD | owned NFD labels already present | `--set nfd.enabled=false` | labels stale/incomplete |
| CDI+NRI | K3s-like runtime and containerd in documented NRI range | `--set cdi.nriPluginEnabled=true` | CDI/toolkit disabled |
| Explicit K3s toolkit env | K3s/containerd `2.3.x` or newer-than-documented NRI range and K3s paths exist | `--set cdi.nriPluginEnabled=false` plus K3s `toolkit.env` paths | config/socket path unknown |
| Newer-than-known NRI experiment | user explicitly wants sandbox validation of newer-than-documented NRI | `--set cdi.nriPluginEnabled=true` plus caveat and full validation | production or no approval for uncertainty |
| Host-managed toolkit | K3s already has working NVIDIA handlers from host toolkit | `--set toolkit.enabled=false` | handler evidence absent |

## Recommended K3s Sandbox Install

Create/label namespace:

```bash
kubectl create ns gpu-operator --dry-run=client -o yaml | kubectl apply -f -
kubectl label --overwrite ns gpu-operator pod-security.kubernetes.io/enforce=privileged
```

For host-preinstalled driver plus GPU Operator-managed toolkit on
K3s/containerd `2.3.x`, use the explicit K3s toolkit-env script:

```bash
scripts/install-gpu-operator-k3s-host-driver.sh
```

Only use CDI/NRI on newer-than-documented containerd when the user explicitly
approved a sandbox experiment. Record the support-matrix caveat and validate
with the full workload proof.

For operator-managed driver, use the same branch matrix first and do not use
the K3s host-driver script.

```bash
helm install gpu-operator nvidia/gpu-operator \
  -n gpu-operator \
  --version v26.3.3 \
  --set cdi.nriPluginEnabled=true
```

If using host-managed toolkit/runtime too, add `--set toolkit.enabled=false`
only after runtime handler evidence proves it.

## Verification

```bash
kubectl get pods -n gpu-operator -o wide
kubectl get ds -n gpu-operator
kubectl get clusterpolicy
kubectl get nodes -L nvidia.com/gpu.present,nvidia.com/gpu.count,nvidia.com/gpu.deploy.driver,nvidia.com/mig.capable
kubectl get nodes -o json | jq '.items[] | select(.status.allocatable["nvidia.com/gpu"] != null) | {name: .metadata.name, gpus: .status.allocatable["nvidia.com/gpu"]}'
```

Then run the durable core workload:

```bash
scripts/validate-cuda-vectoradd.sh
```

Pass signal: pod phase is `Succeeded` and logs include `Test PASSED`. This
short-lived validation pod may complete before it ever stays `Ready`, so use
phase and logs rather than a `Ready` condition as the success gate. If only this
workload runs, report a core-install proof.

## Recovery

- Helm fails before pods: check kubeconfig, namespace PSA, chart values.
- Pods stuck in init: inspect driver and toolkit logs before retry.
- Runtime handler error: check CDI/NRI branch and runtime evidence.
- No allocatable GPU: inspect device-plugin logs and Xid/dmesg.
- Two same-shape failures: stop and collect escalation bundle.

Sources: `references/bootstrap.md`, `references/operational-reasoning.md`,
`references/source-map.md`.
