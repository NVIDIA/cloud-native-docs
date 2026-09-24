---
name: gpu-operator-uninstall
description: Cleanly uninstall the GPU Operator — remove the Helm release, clean up CRDs, unload host driver modules, and verify teardown. High-blast-radius, gated lifecycle operation; not a troubleshooting shortcut.
tags: [gpu-operator, uninstall, teardown, helm, crd, cleanup]
---

# GPU Operator Uninstall

Remove the GPU Operator and its operands from a **test-owned** cluster and
verify the node is clean. Every mutating step here is high blast radius: it
deletes cluster-wide CRDs, tears down GPU operands, and can leave or unload
host kernel modules. Treat uninstall as a deliberate lifecycle action.

> **Uninstall is not a troubleshooting shortcut.** A failed install or a broken
> operand is almost never fixed by uninstall/reinstall as a first response —
> that erases the evidence. Route failures through
> `skills/gpu-operator-troubleshoot/SKILL.md` first. Uninstall only when the
> goal is genuinely to remove the product.

## Preconditions

- **Run inventory first.** Load `references/environment-inventory.md` and run
  `scripts/inventory-gpu-operator-environment.sh` (or the Step 0 evidence
  below) before any deletion. Do not uninstall from assumption.
- **Explicit approval for teardown**, plus a maintenance window if GPU
  workloads or the node itself may be interrupted.
- **`kubectl`/`helm` context proven** to point at the intended test-owned
  cluster (`kubectl config current-context`), never production, shared, or
  another team's cluster.
- **Blast radius + rollback named** before proceeding: uninstall removes the
  `gpu-operator` release, the `ClusterPolicy`/`NVIDIADriver` CRDs (if CRD
  cleanup is chosen), and — on operator-managed-driver nodes — requires
  unloading kernel modules or a reboot to fully clear the driver. Rollback =
  reinstall via `skills/gpu-operator-install/SKILL.md`.
- **Know the driver ownership.** If `driver.enabled=false`, the host/platform
  owns the NVIDIA driver — do NOT unload host driver modules as part of this
  uninstall; leave the host driver to its own lifecycle.

## Command Environment

```bash
export KUBECONFIG="${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}"
kubectl config current-context
helm version
```

## Step 0 — Capture pre-uninstall inventory (read-only)

Status: docs-derived. Establish what exists before deleting anything.

```bash
helm list -n gpu-operator
kubectl get clusterpolicy -o yaml > clusterpolicy-before-uninstall.yaml
kubectl get nvidiadrivers.nvidia.com -A -o yaml > nvidiadrivers-before-uninstall.yaml || true
kubectl get pods -n gpu-operator -o wide
kubectl get crd | grep -E 'nvidia.com|nodefeaturerules'
kubectl get nodes -L nvidia.com/gpu.present,nvidia.com/gpu.count,nvidia.com/gpu.deploy.driver
```

Record whether `driver.enabled` is true (operator-managed) or false
(host-managed) from `helm get values gpu-operator -n gpu-operator -o yaml`; it
decides Step 5.

## Step 1 — (Optional) Delete NVIDIA driver custom resources — GATE

Status: docs-derived (GPU Operator "Uninstalling the GPU Operator", step 1).
Only when the operator manages `NVIDIADriver` CRs and you intend to remove them.

```bash
kubectl get nvidiadrivers
# for each returned driver CR:
kubectl delete nvidiadriver <name>
# then remove the CRD itself (cluster-wide, GATE):
kubectl delete crd nvidiadrivers.nvidia.com
```

Deleting the CRD is cluster-wide and irreversible without reinstall. Confirm
before running.

## Step 2 — Delete the Operator Helm release — GATE

Status: docs-derived (GPU Operator "Uninstalling the GPU Operator", step 2).

```bash
helm delete -n gpu-operator $(helm list -n gpu-operator | grep gpu-operator | awk '{print $1}')
```

This tears down all GPU operands (driver, toolkit, device-plugin, DCGM,
validators). If the release name is known, prefer it explicitly:
`helm uninstall gpu-operator -n gpu-operator`.

## Step 3 — Confirm operands are terminating (read-only)

Status: docs-derived.

```bash
kubectl get pods -n gpu-operator
# expected: pods deleting, then "No resources found."
```

## Step 4 — CRD cleanup — GATE

Status: docs-derived (GPU Operator uninstall docs, CRD-cleanup note).

Helm does **not** delete CRDs on chart removal by default, so `clusterpolicy`
and `nvidiadrivers` CRDs remain:

```bash
kubectl get crd clusterpolicies.nvidia.com
```

Two supported ways to clean them up:

1. **Post-delete hook (set at install/upgrade time):** the chart parameter
   `operator.cleanupCRD=true` enables a `post-delete` hook that removes the
   CRDs automatically on chart deletion. It is disabled by default and must
   have been set with `--set operator.cleanupCRD=true` during a prior install
   or upgrade. The hook uses the Operator image (see Step 4a).
2. **Manual deletion (cluster-wide, GATE):**
   ```bash
   kubectl delete crd clusterpolicies.nvidia.com
   ```
   Deleting a CRD deletes all its custom resources cluster-wide. Confirm no
   other tenant relies on it before running.

### Step 4a — Hook-failure fallback

Status: docs-derived (GPU Operator uninstall docs, Helm-hooks note).

The `cleanupCRD` hook runs the Operator image. If that image cannot be pulled
(network error, or an invalid NGC registry secret on NVAIE), the hook fails and
`helm delete` can hang. In that case, delete the chart with hooks disabled and
clean the CRDs manually:

```bash
helm delete gpu-operator -n gpu-operator --no-hooks
kubectl delete crd clusterpolicies.nvidia.com nvidiadrivers.nvidia.com
```

## Step 5 — Unload host driver modules (operator-managed driver only) — GATE

Status: docs-derived (GPU Operator uninstall docs, driver-modules note).

Only when `driver.enabled=true` was in use. After uninstall, NVIDIA driver
modules may still be loaded on the node. Either reboot the node (with owner
approval) or unload the modules:

```bash
sudo rmmod nvidia_modeset nvidia_uvm nvidia
```

If `rmmod` reports the module is in use, GPU workloads or processes still hold
it — stop and collect evidence rather than forcing. **If `driver.enabled=false`
(host-managed driver), skip this step entirely** — the host driver is not
yours to unload.

## Step 6 — Verify teardown (read-only)

Status: docs-derived + synthesized verification composition.

```bash
kubectl get pods -n gpu-operator            # No resources found
helm list -n gpu-operator                    # release gone
kubectl get crd | grep -E 'clusterpolicies.nvidia.com|nvidiadrivers.nvidia.com' || echo "CRDs removed"
kubectl get nodes -L nvidia.com/gpu.present  # GPU labels cleared where operator-managed
nvidia-smi 2>/dev/null || echo "no NVIDIA runtime (expected on operator-managed-driver nodes after module unload)"
```

Uninstall is complete only when the release is gone, chosen CRDs are removed,
operand pods are gone, and (for operator-managed drivers) the modules are
unloaded or the node rebooted.

## Rollback / Recovery

To restore, reinstall via `skills/gpu-operator-install/SKILL.md` using the
values captured in Step 0. CRD deletion is not reversible without reinstall;
the operator re-creates its CRDs on the next install.

## Stop / Escalation Conditions

Stop and produce an escalation bundle
(`skills/gpu-operator-evidence-bundle/SKILL.md`) when: a `rmmod` reports the
module is still in use, `helm delete` hangs on a failing hook and `--no-hooks`
does not clear it, a CRD deletion would affect resources outside this
test-owned cluster, the node is host-managed-driver and a reboot/drain is
required but not approved, or any deletion targets shared/production
infrastructure.

## Sources

- NVIDIA GPU Operator documentation — "Uninstalling the GPU Operator"
  (`gpu-operator/uninstall.rst`): Helm release removal, the
  `operator.cleanupCRD` post-delete hook, manual CRD deletion, the
  driver-modules-remain note (`rmmod`), and the `--no-hooks` fallback.
- Helm CRD lifecycle: Helm does not delete CRDs on chart removal by default.
