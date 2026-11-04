# Anti-Patterns

Append stale commands, unsafe advice, and repeated failed reasoning shapes here.

## Entry Template

```markdown
### YYYY-MM-DD - <short anti-pattern>

- Context:
- Bad pattern:
- Why it is risky or stale:
- Safer replacement:
- Evidence:
- Package update needed:
```

## Seeded Anti-Patterns

### 2026-07-02 - Treating Helm success as install success

- Context: GPU Operator controller-style product installation.
- Bad pattern: declaring success immediately after `helm install` returns.
- Why it is risky or stale: operands, labels, device plugin resources, and
  workload GPU access may still be unavailable.
- Safer replacement: follow the success ladder in
  `references/models.md`, ending with workload manifest success for the
  declared example suite.
- Evidence: public install verification docs and package model.
- Package update needed: keep this anti-pattern visible in install reviews.

### 2026-07-02 - Using `kubectl run --limits` as validation

- Context: workload proof after GPU Operator install.
- Bad pattern: relying on a brittle imperative `kubectl run --limits` command.
- Why it is risky or stale: CLI flags drift and are easy to misquote.
- Safer replacement: apply `manifests/cuda-vectoradd.yaml` and check logs for
  `Test PASSED`.
- Evidence: public getting-started docs use a manifest-based VectorAdd example.
- Package update needed: keep validation manifest current with public docs.

### 2026-07-02 - Treating `Ready` wait as the VectorAdd success gate

- Context: Durable CUDA VectorAdd validation after GPU Operator install.
- Bad pattern: using `kubectl wait --for=condition=Ready pod/cuda-vectoradd` as the decisive pass/fail signal.
- Why it is risky or stale: the sample pod is short-lived and can reach `Succeeded` before it remains `Ready`; a `Ready` wait miss can be a false negative.
- Safer replacement: inspect pod phase and logs; pass requires phase `Succeeded` and log line `Test PASSED`.
- Evidence: a live Brev A100 GPU instance completed VectorAdd twice on 2026-07-02 with `Status: Succeeded`, exit code 0, and `Test PASSED`.
- Package update needed: install and operate skills updated to name phase/logs as the pass gate.

### 2026-07-02 - Letting a status-print typo rerun a mutating remote command

- Context: Running multi-step `brev exec --host` commands that create/delete Kubernetes test pods.
- Bad pattern: appending a brittle final JSONPath/status command under `set -e` after successful workload validation in the same remote command.
- Why it is risky or stale: a non-product typo can make the command exit nonzero after the workload succeeded; the Brev wrapper may reconnect/retry, repeating earlier delete/apply steps.
- Safer replacement: split mutating workload execution from nonessential status formatting, or make final status printers best-effort and syntactically simple.
- Evidence: on a live Brev GPU instance, a malformed JSONPath `{.status.phase}{\n}` failed after VectorAdd success and the command sequence was replayed once.
- Package update needed: Prefer short commands with separate evidence collection in future runbooks.

### 2026-07-02 - Treating time-slicing availability as full CUDA proof

- Context: Optional time-slicing example validation.
- Bad pattern: declaring success from deployment availability or allocatable
  GPU count alone.
- Why it is risky or stale: availability proves scheduling capacity, but not
  that every intended CUDA replica actually executed successfully.
- Safer replacement: wait for `Test PASSED` logs from each verification pod, or
  explicitly mark the result as scheduling-only.
- Evidence: a prior live validation run reached rollout availability before all
  replica logs were captured.
- Package update needed: operate skill now requires per-pod log proof.

### 2026-07-02 - Incomplete optional-example cleanup

- Context: Reverting time-slicing after an optional example test.
- Bad pattern: deleting the test namespace and ConfigMap without checking the
  live `ClusterPolicy` field that references the config.
- Why it is risky or stale: the node can continue advertising time-sliced GPU
  resources after the apparent cleanup.
- Safer replacement: verify namespace/config absence, live `ClusterPolicy`,
  Helm values, node GPU labels/capacity, and a final VectorAdd smoke.
- Evidence: a prior live validation run caught live node labels still advertising
  time-slicing after initial cleanup.
- Package update needed: bootstrap and operate guidance now include the cleanup
  checklist.

### 2026-07-02 - Assuming `kubectl run --limits` portability

- Context: Quick GPU workload proof.
- Bad pattern: using imperative `kubectl run --limits` as the primary proof.
- Why it is risky or stale: client flag support varies and can fail before the
  product behavior is tested.
- Safer replacement: use small manifests for GPU workload proofs.
- Evidence: a prior live validation run hit `kubectl run --limits`
  incompatibility and recovered with a manifest.
- Package update needed: command catalog now names the manifest fallback.
