# NVIDIA GPU Operator DevOps Agent Package

Purpose: help an AI DevOps agent install, operate, maintain, and troubleshoot
NVIDIA GPU Operator from public docs/source and live environment evidence. This
package is operational guidance, not a substitute for change approval.

## Supported Scope

- Primary product/version: NVIDIA GPU Operator `v26.3.3`.
- Primary install manager: Helm chart `nvidia/gpu-operator`.
- Primary environment: test-owned single-node or small Kubernetes clusters with
  NVIDIA data center GPUs, especially Ubuntu 22.04/24.04 plus K3s/containerd
  and A100-class hardware.
- Primary validation: GPU Operator health, allocatable GPU resources, CUDA
  VectorAdd manifest success, and optional documented examples selected for the
  environment.
- See `references/supported-scope.md` for caution zones and non-goals.

## Source Precedence

1. Live target evidence from read-only commands.
2. Official GPU Operator docs for the target release/current docs.
3. GPU Operator public source at the target tag, especially Helm values,
   templates, CRDs, and `hack/must-gather.sh`.
4. Public release notes, public GitHub issues, public forum evidence, and live
   target-environment evidence gathered during the user's approved run.

Runtime source boundary: do not require or cite NVIDIA-internal Confluence,
Google Docs, Jira, GitLab, Slack, private support systems, private hostnames,
or internal-only procedures. Public package decisions must be grounded in
public sources or the user's approved live environment.

## Required Tools And Access

- `kubectl` with cluster-admin or equivalent access for GPU Operator install.
- `helm`, `jq`, and shell access to the intended sandbox or cluster.
- `KUBECONFIG` explicitly set or context explicitly proven before mutation.
- Node shell access for host checks such as `nvidia-smi`, `lspci`, `lsmod`,
  `dmesg`, `journalctl`, and runtime version/config checks.
- Approval before changing nodes, drivers, runtime config, MIG, Helm releases,
  CRDs, namespaces, workload placement, reboots, drains, or test environment
  lifecycle.

## Bootstrap And Command Context Policy

Before any product mutation or troubleshooting branch selection, load
`references/environment-inventory.md` and `references/bootstrap.md`, then prove:

```bash
hostname
pwd
id
kubectl config current-context
kubectl get nodes -o wide
helm version
```

For fresh K3s sandboxes, set:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

Record the sandbox name/ID, how the environment was provisioned (e.g. a cloud
GPU instance or a K3s node), Kubernetes version, runtime version, OS/kernel,
GPU model, and cleanup command.

Use `scripts/inventory-gpu-operator-environment.sh` when shell access is
available. Do not diagnose from symptom text alone; collect deployment
inventory first and cite which inventory fact selects the branch.

Branch decisions are staged. Do not decide `driver.enabled`, `toolkit.enabled`,
NFD, CDI/NRI, or legacy runtime config from pre-bootstrap evidence alone. After
Kubernetes exists and `kubectl` works, rerun host/runtime/NFD evidence, then
choose install values.

Branch decisions are also model-first and matrix-backed. Before selecting a
fix, locate the earliest failed layer in `references/models.md`, then use
`references/branch-matrix.md` to select the branch, rejected branch, command
card, script, fallback, and stop condition. Mutate only the layer the evidence
actually implicates.

## Safety Policy

- Read first, mutate second, validate third, clean up test workloads last.
- Helm success is not product success. Require the success ladder in
  `references/models.md`.
- Do not use `helm uninstall`, CRD deletion, `kubectl drain`, node reboot,
  driver downgrade, host runtime edits, or MIG reconfiguration without naming
  blast radius and rollback.
- Do not retry the same failing install branch twice. Collect an escalation
  bundle instead.
- Keep test mutations inside the assigned test-owned sandbox. Never mutate
  production, shared, customer, or any other team's infrastructure.
- Persist reusable lessons in `runtime-memory/` before ending the session.
- Do not file upstream GitHub issues without user approval for the target repo,
  title/body, labels, and credentials. Draft them locally first.

## Standard Evidence Collection

```bash
kubectl get nodes -o wide
kubectl get nodes -L feature.node.kubernetes.io/pci-10de.present,nvidia.com/gpu.present,nvidia.com/gpu.count,nvidia.com/gpu-driver-upgrade-state,nvidia.com/mig.config,nvidia.com/mig.config.state
kubectl get pods -n gpu-operator -o wide
kubectl get ds -n gpu-operator
kubectl get clusterpolicy -o yaml
kubectl get events -A --sort-by='.lastTimestamp' | tail -100
helm list -n gpu-operator
helm get values gpu-operator -n gpu-operator -o yaml
```

## Skill Routing

| Task | Load |
|---|---|
| Deployment inventory before diagnosis | `references/environment-inventory.md`, then `scripts/inventory-gpu-operator-environment.sh` when shell access exists |
| Branch selection or layer ownership reasoning | `references/models.md`, then `references/branch-matrix.md`, before mutating |
| Public-field-shaped failure or scenario evidence | `references/field-scenario-cards.md`, then `references/failure-signatures.md` |
| Clean sandbox, K3s, kubeconfig, command proof | `references/bootstrap.md` first, then install skill |
| Fragile command execution or cleanup | `references/command-cards.md`, then the matching `scripts/*.sh` template |
| Fresh install or install plan | `skills/gpu-operator-install/SKILL.md` |
| Health, workload validation, drift check | `skills/gpu-operator-operate/SKILL.md` |
| Upgrade, rollback, driver/MIG/config maintenance | `skills/gpu-operator-maintain/SKILL.md` |
| Remove the product — uninstall the Helm release, clean up CRDs, unload host driver modules | `skills/gpu-operator-uninstall/SKILL.md` |
| Failed install, missing GPU, runtime errors, Xid, stuck upgrade | `skills/gpu-operator-troubleshoot/SKILL.md` |
| Support/debug handoff | `skills/gpu-operator-evidence-bundle/SKILL.md` |
| Record a reusable lesson, anti-pattern, discovered resource, operating parameter, or upstream issue draft | `skills/gpu-operator-improve/SKILL.md` |

## Operating Invariants

- Command context must point at the intended sandbox before mutation.
- Host GPU visibility precedes Kubernetes/GPU Operator debugging.
- Kubernetes node readiness precedes product install.
- NFD/GPU labels precede operand daemonset scheduling.
- Driver readiness precedes toolkit/device-plugin readiness.
- Device plugin resource advertisement precedes workload validation.
- `ClusterPolicy.status.state=ready` is necessary but not sufficient.
- CDI is default in GPU Operator v25.10.0+. NRI is useful on K3s-like runtimes
  when the runtime is in the known-tested range. For K3s/containerd `2.3.x`,
  prefer the explicit K3s toolkit-env branch unless the user explicitly wants a
  disposable-sandbox validation of newer-than-documented NRI.
- GPU Operator manages containerized drivers only when `driver.enabled=true`;
  host-preinstalled drivers remain host/platform owned.
- The package must improve from live evidence. If the run teaches a reusable
  lesson, write it to `runtime-memory/` and update references or skills when
  appropriate.

## Stop/Escalation Conditions

Stop and produce an escalation package when GPU hardware is absent, `nvidia-smi`
fails on a host-managed-driver branch, critical Xid errors appear, the needed
runtime/OS/kernel is outside reviewed scope, the fix requires reboot/drain/CRD
deletion/driver downgrade, credentials are missing, or public sources conflict
on a load-bearing claim.

## Freshness Policy

For any version other than `v26.3.3`, re-check release notes, chart values,
CRDs, `ClusterPolicy` schema, CDI/NRI defaults, driver defaults, support
matrix, and known issues. Update `references/claim-ledger.md` before reusing
this package for the new version.
