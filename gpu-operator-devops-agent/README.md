<!--
SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
SPDX-License-Identifier: Apache-2.0
-->

# NVIDIA GPU Operator — DevOps Agent Package (prototype)

## What this is

A prototype **DevOps agent package** for the NVIDIA GPU Operator: a curated
`AGENTS.md` front door + skills + references that let an AI coding/ops agent
(Claude, Cursor, etc.) help an operator **install / operate / maintain /
troubleshoot** the GPU Operator by reading and reasoning over the **public**
GPU Operator docs and source — instead of a fresh agent guessing from an
unstructured search.

It was built by distilling the public GPU Operator documentation (this repo's
`gpu-operator/` docs) and the public GPU Operator source into a compact,
routable operating charter with an explicit safety model.

## What's in it

| Path | What it is |
|---|---|
| `AGENTS.md` | Agent front door / operating charter — supported scope, source precedence, bootstrap policy, safety policy, skill routing, operating invariants, stop/escalation conditions |
| `skills/` | Six operator SOPs: `gpu-operator-install`, `-operate`, `-maintain`, `-troubleshoot`, `-evidence-bundle`, `-improve` |
| `references/` | The reasoning substrate — `models.md` (the layered success ladder), `branch-matrix.md` (staged branch decisions), `command-cards.md` (validated recipes), `field-scenario-cards.md` + `failure-signatures.md` (troubleshooting), `environment-inventory.md`, `supported-scope.md`, `claim-ledger.md`, others |
| `scripts/` | Read-only inventory + a few guarded mutation helpers (host-driver K3s install, CUDA VectorAdd validation, time-slicing) |
| `runtime-memory/` | Seed files the agent appends to as it learns (insights, anti-patterns, discovered resources, operating parameters) |
| `manifests/` | Small validation manifests (CUDA VectorAdd, time-slicing verification, a bad-runtimeClass repro) |

## Intended behavior (what to watch for when testing)

A correctly-behaving agent should:

- **Inventory before diagnosing** — prove command context (`kubectl config
  current-context`, `kubectl get nodes`, host `nvidia-smi`) and run
  `scripts/inventory-gpu-operator-environment.sh` before any mutation; never
  diagnose from symptom text alone.
- **Follow source precedence** — live target evidence first, then the official
  GPU Operator docs for the target release, then public GPU Operator source at
  the target tag, then public release notes / issues / forums. It should **cite
  the source** for each load-bearing claim and refuse to rely on private/internal
  sources.
- **Stage branch decisions** — not decide `driver.enabled` / `toolkit.enabled` /
  NFD / CDI-NRI from pre-bootstrap evidence; locate the **earliest failed layer**
  in `references/models.md`, then select a branch via `references/branch-matrix.md`.
- **Respect the safety model** — read → mutate → validate → clean up; treat
  Helm success as *not* product success (require the success ladder); and
  **name blast radius + rollback** before `helm uninstall`, CRD deletion,
  `kubectl drain`, node reboot, driver downgrade, or MIG reconfiguration. It
  should refuse to retry the same failing branch twice and produce an escalation
  bundle instead.

## How to test it

1. Point an agent at **`gpu-operator-devops-agent/AGENTS.md`** as its front door
   (copy the directory into a workspace and let Claude/Cursor read it as the
   working set).
2. Ask it an operator task against a **test-owned** single-node or small cluster
   (Ubuntu 22.04/24.04 + K3s/containerd + A100-class GPU is the primary target) —
   e.g. *"install the GPU Operator on this K3s node,"* *"a GPU workload can't be
   scheduled after install,"* *"upgrade the GPU Operator and roll back if driver
   pods crash-loop."*
3. Watch for the intended behavior above: probe-first, cited sources, staged
   branch selection, and safety refusals on high-blast-radius steps.
4. To capture a support/debug handoff, exercise
   `skills/gpu-operator-evidence-bundle`.

Keep all mutations inside a disposable, test-owned sandbox. This package is
operational guidance, **not** a substitute for change approval.

## Status & honesty caveats

- **Prototype, docs-derived.** Command flows are distilled from the public docs
  and public source; the package **has not itself been rerun end-to-end after
  authoring** (see `references/supported-scope.md` → *Verification Gap
  Statement*). Readiness for a new environment requires a package-loaded run that
  exercises clean bootstrap, install, workload validation, and at least one
  troubleshooting scenario.
- **Version-anchored to GPU Operator `v26.3.3`.** For any other version, the
  agent is instructed to re-check release notes, chart values, CRDs,
  `ClusterPolicy` schema, CDI/NRI defaults, and the support matrix, and to update
  `references/claim-ledger.md` first (see *Freshness Policy* in `AGENTS.md`).
- **Scope is single-node / small K3s clusters with data-center GPUs.** Out of
  scope: OpenShift OLM, vGPU licensing, confidential containers, Kata, KubeVirt,
  GPUDirect RDMA/GDS, air-gapped/private-registry flows, managed-cloud cluster
  creation, and Jetson/integrated-GPU platforms — see
  `references/supported-scope.md`.

## What feedback helps most

- **Command-card accuracy** — are the install / validation / troubleshooting
  recipes in `references/command-cards.md` correct and complete for the GPU
  Operator on K3s/containerd?
- **Doc & source citations** — are the cited docs sections and source paths right?
- **Layered model** — does `references/models.md` match how the GPU Operator
  actually fails and recovers (NFD → driver → toolkit → device-plugin →
  validator → workload)?
- **Skill coverage** — are install / operate / maintain / troubleshoot /
  evidence-bundle / improve the right operator buckets? What's missing?

## Provenance

Generated from a curated source manifest built by reading the **public** GPU
Operator documentation in this repository (`gpu-operator/`, snapshot commit
`77a2daaf234a2cebc8e178f24e18cc4a6150e8b1`) and the public GPU Operator source
at the `v26.3.3` release. This directory is the **reference prototype** — a draft
for review and testing, not a validated release.
