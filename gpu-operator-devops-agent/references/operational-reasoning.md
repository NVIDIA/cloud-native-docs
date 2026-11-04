# Operational Reasoning

## Default Sandbox Recommendation

For a fresh single-node Brev/K3s A100 sandbox targeting GPU Operator `v26.3.3`:

1. Bootstrap/prove K3s context first; set
   `KUBECONFIG=/etc/rancher/k3s/k3s.yaml`.
2. Re-run host driver, runtime, RuntimeClass, and NFD evidence after K3s exists.
3. If the host driver is known-good and platform-owned, use
   `driver.enabled=false`; otherwise prefer operator-managed driver in a
   disposable sandbox.
4. Keep CDI enabled.
5. For K3s with containerd `1.7.30`, `2.1.x`, or `2.2.x`, enable
   `cdi.nriPluginEnabled=true`.
6. For containerd newer than the docs range, such as `2.3.x`, mark the runtime
   as newer-untested. In a test-owned sandbox, enabling NRI is reasonable only
   with explicit caveat and full workload validation.
7. Leave MIG disabled until whole-GPU scheduling is proven and the user asks
   for partitions.

## Staged Runtime Branch Logic

Two branches can be valid in fresh K3s-style sandboxes, depending on evidence
from the target environment:

- Host-managed driver plus host-managed toolkit/runtime can work when K3s
  creates usable NVIDIA runtime handlers from host toolkit evidence.
- Host-managed driver plus GPU Operator-managed toolkit with CDI/NRI can also
  work and avoids hand-editing K3s containerd paths.

Do not freeze toolkit/runtime choice before K3s bootstrap. Decide after
`kubectl get runtimeclass`, runtime version, host toolkit evidence, and Helm
values are available.

## Workload/Example Suite

Declare the suite before claiming install success:

- Core suite: `manifests/cuda-vectoradd.yaml`; pass requires pod completion and
  logs containing `Test PASSED`.
- Optional notebook suite: docs `tf-notebook.yaml`; pass requires pod running,
  service present, and token/log captured without exposing it broadly.
- Optional time-slicing suite: docs time-slicing config plus
  `manifests/time-slicing-verification.yaml`; pass requires expected replicas
  running and at least one VectorAdd success log.
- Optional MIG suite: only after approved MIG change; pass requires
  `mig.config.state=success`, expected MIG resources, and matching workload
  request success.

If only the core suite runs, report "core-install proof", not full
documentation-suite install success.

## Troubleshooting Reasoning

Always debug the earliest failed layer:

- No host GPU: host/provider problem, not GPU Operator.
- No NVIDIA labels/daemonsets desired zero: NFD/labels/taints.
- Driver pod failing: kernel, driver, image pull, `nouveau`, registry, or Xid.
- Runtime handler error: toolkit/CDI/NRI/runtime path, not CUDA app code.
- No `nvidia.com/gpu`: device plugin or GPU health.
- Workload fails after allocatable resources: workload manifest, CDI/runtime
  injection, image, or GPU health.

For field-shaped scenarios, use this order:

1. Load `references/models.md` and identify the owner/layer.
2. Load `references/field-scenario-cards.md` and match the closest symptom.
3. Run only the read-only evidence card for that symptom.
4. Name selected branch, rejected broad branch, and stop condition.
5. Mutate only if the branch targets the proven layer and the user approved the
   blast radius.

Do not infer that GPU Operator is broken because a downstream pod is failing.
First prove whether the failure is a host driver issue, runtime/toolkit issue,
device-plugin/resource-advertisement issue, workload spec issue, or documented
unsupported environment.

## Field Scenario Branch Examples

| Evidence | Choose | Reject |
|---|---|---|
| `nvidia.com/gpu.deploy.device-plugin=false` plus plugin-validation logs waiting for GPU resources | validator/device-plugin-disabled diagnosis and escalation bundle | reinstalling GPU Operator |
| `no runtime for "nvidia" is configured` with no RuntimeClass | runtime/toolkit branch | CUDA app debugging |
| CDI unresolved device errors after upgrade | CDI/device-plugin/runtime evidence branch | generic image-pull or app issue |
| driver daemonset mount error for sysfs path | host/kernel compatibility branch | Helm retry loop |
| driver image pull error with unsupported OS/kernel/image tag | support-matrix/image availability branch | credential debugging first |
| upgrade labels say done but workload proof absent | maintenance continuity branch | declaring success from labels alone |

## Maintenance Continuity

Maintenance success requires more than "upgrade command returned 0":

1. Capture pre-change values, CRDs, `ClusterPolicy`, node labels, operand
   health, RuntimeClasses, and workload inventory.
2. Run the declared workload suite before change.
3. Choose chart upgrade vs driver upgrade branch; record different risks.
4. Apply approved change.
5. Monitor driver upgrade labels/events if driver changes.
6. Run the same workload suite after change.
7. Soak for the declared interval and confirm no new operand errors.

Driver upgrade drain is a last resort. Try GPU pod deletion controls first;
enable full drain only with approval and disruption plan.
