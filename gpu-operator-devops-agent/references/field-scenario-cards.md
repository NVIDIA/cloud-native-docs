# GPU Operator Field Scenario Cards

These cards distill public issue/forum failure shapes into package-local
diagnostic guidance. They are for live support
reasoning: the operating agent should not need to browse the public thread to
know which evidence to gather or which broad fixes to reject.

Use these cards after `references/models.md` and before choosing a mutation.

## Validator Fails When Device Plugin Is Intentionally Disabled

Source seed: https://github.com/NVIDIA/gpu-operator/issues/2550
Reproduction class: live-safe proxy

Symptom:
- `nvidia-operator-validator` fails in plugin validation.
- A node has `nvidia.com/gpu.deploy.device-plugin=false`.
- Logs can say GPU resources are not discovered.

Model interpretation:
- Device plugin ownership has been intentionally disabled for that node.
- Validator behavior can become downstream noise if it still expects GPU
  resources on a node where the device plugin is not supposed to advertise
  them.

Evidence to collect:

```bash
kubectl get nodes --show-labels | grep 'nvidia.com/gpu.deploy.device-plugin=false' || true
kubectl get ds -n gpu-operator nvidia-device-plugin-daemonset -o wide
kubectl get pods -n gpu-operator -l app=nvidia-operator-validator -o wide
kubectl logs -n gpu-operator -l app=nvidia-operator-validator -c plugin-validation --tail=100
kubectl describe pod -n gpu-operator -l app=nvidia-operator-validator
```

Expected branch:
- Diagnose as node-label/device-plugin-disabled versus generic install failure.
- Do not reinstall GPU Operator.
- If this is an intentional split-node deployment, escalate as product behavior
  or documentation gap with evidence.

Unsafe/low-value branches:
- `helm uninstall` / reinstall.
- Debugging CUDA workloads before resolving the validator/device-plugin
  ownership mismatch.
- Removing labels without approval from the owner of that node partitioning.

## CDI Device Injection Or RuntimeClass Failure After Upgrade

Source seed: https://github.com/NVIDIA/gpu-operator/issues/1876
Reproduction class: evidence-only or live-safe proxy

Symptom:
- GPU workload fails with CDI device injection error.
- RuntimeClass such as `nvidia-cdi` is involved.
- Workload without RuntimeClass may see `/dev` devices but miss userspace
  files/libraries.

Model interpretation:
- Failure is at toolkit/CDI/runtime integration, not at the application layer.
- Device ID strategy, CDI defaults, RuntimeClass selection, and toolkit branch
  all control the outcome.

Evidence to collect:

```bash
kubectl get runtimeclass
kubectl get clusterpolicy -o yaml
kubectl get pods -n gpu-operator -o wide
kubectl logs -n gpu-operator -l app=nvidia-container-toolkit-daemonset --tail=200
kubectl describe pod <failing-pod> -n <namespace>
kubectl get events -A --sort-by='.lastTimestamp' | tail -80
```

Expected branch:
- Separate CDI/runtime diagnosis from generic operator health.
- Compare workload `runtimeClassName`, ClusterPolicy CDI/NRI settings, and
  runtime/device-plugin strategy.
- Use a scoped RuntimeClass/toolkit branch, or escalate if the target mix is
  outside reviewed support.

Unsafe/low-value branches:
- Treating the failure as a container image or CUDA app issue first.
- Reinstalling GPU Operator without preserving Helm values and runtime
  evidence.

## Upgrade State Labels Conflict With Driver Or Workload Health

Source seed: https://github.com/NVIDIA/gpu-operator/issues/2549
Reproduction class: live-safe proxy

Symptom:
- Node label moves through `upgrade-failed` and later `upgrade-done`.
- Driver pod health and workload continuity are ambiguous.
- Upgrade involves driver branch changes or active GPU workloads.

Model interpretation:
- Upgrade label is a value-model signal, not final truth.
- Maintenance success requires workload proof before and after change.

Evidence to collect:

```bash
kubectl get nodes -L nvidia.com/gpu-driver-upgrade-state
kubectl get pods -n gpu-operator -o wide
kubectl describe ds -n gpu-operator nvidia-driver-daemonset
kubectl get events -A --sort-by='.lastTimestamp' | tail -100
helm get values gpu-operator -n gpu-operator -o yaml
kubectl get clusterpolicy -o yaml
```

Expected branch:
- Monitor label sequence, driver pod state, and workload proof together.
- Do not accept `upgrade-done` unless the declared workload suite still passes.
- If relabeling is considered, record why it is safe and what recovery action it
  represents.

Unsafe/low-value branches:
- Declaring success from labels alone.
- Draining/rebooting/downgrading before proving active workload and driver
  ownership.

## Driver Daemonset Fails On Kernel HostPath Or Kernel Feature

Source seed: https://github.com/NVIDIA/gpu-operator/issues/2463
Reproduction class: evidence-only

Symptom:
- Driver daemonset is `CreateContainerError`.
- Event mentions a hostPath/mount failure under `/sys/devices/system/memory`.
- Kernel lacks the expected feature or userspace cannot create the sysfs path.

Model interpretation:
- Earliest failed layer is host/kernel compatibility or driver daemonset mount
  assumptions.
- Helm retry does not change the host kernel.

Evidence to collect:

```bash
kubectl describe pod -n gpu-operator -l app=nvidia-driver-daemonset
kubectl get events -n gpu-operator --sort-by='.lastTimestamp' | tail -80
uname -a
grep CONFIG_MEMORY_HOTPLUG /boot/config-$(uname -r) || true
ls -l /sys/devices/system/memory/auto_online_blocks || true
helm get values gpu-operator -n gpu-operator -o yaml
```

Expected branch:
- Escalate or use a supported host/kernel branch.
- Preserve the exact event and kernel evidence.
- Avoid retrying Helm until the host compatibility question is resolved.

Unsafe/low-value branches:
- Reinstalling GPU Operator.
- Attempting to create sysfs paths from userspace.
- Mutating driver settings without confirming support.

## Runtime Handler `nvidia` Is Not Configured

Source seed: https://forums.developer.nvidia.com/t/failed-to-create-pod-sandbox-rpc-error-code-unknown-desc-failed-to-get-sandbox-runtime-no-runtime-for-nvidia-is-configured/296409
Reproduction class: live-safe proxy

Symptom:
- Pod sandbox creation fails with `no runtime for "nvidia" is configured`.
- Cluster may have working host GPU but missing RuntimeClass/toolkit runtime
  integration.

Model interpretation:
- Earliest failed layer is Kubernetes/runtime/toolkit integration.
- The product may be healthy up to controller readiness while workloads still
  fail at sandbox creation.

Evidence to collect:

```bash
kubectl get runtimeclass
kubectl get clusterpolicy -o yaml
kubectl get pods -n gpu-operator -l app=nvidia-container-toolkit-daemonset -o wide
kubectl logs -n gpu-operator -l app=nvidia-container-toolkit-daemonset --tail=200
kubectl describe pod <failing-pod> -n <namespace>
```

Expected branch:
- Decide between CDI/NRI branch and explicit legacy K3s/RKE2 toolkit paths from
  evidence.
- Do not debug application code before the sandbox runtime succeeds.

Unsafe/low-value branches:
- Full operator uninstall/reinstall as first response.
- Editing host runtime files without approval or without a rollback plan.

## Driver Image Pull Failure Or Unsupported Platform Image

Source seed: https://forums.developer.nvidia.com/t/gpu-operator-helm-chat-deployment-issues/349743
Reproduction class: evidence-only or live-safe proxy

Symptom:
- Driver pod has `ErrImagePull` / `ImagePullBackOff`.
- Event references an unavailable driver image tag, OS, or kernel branch.

Model interpretation:
- Earliest failed layer may be image availability/support matrix, not registry
  credentials.
- The driver operand cannot progress until image/platform compatibility is
  resolved.

Evidence to collect:

```bash
kubectl describe pod -n gpu-operator -l app=nvidia-driver-daemonset
kubectl get events -n gpu-operator --sort-by='.lastTimestamp' | tail -80
cat /etc/os-release
uname -r
helm get values gpu-operator -n gpu-operator -o yaml
kubectl get clusterpolicy -o yaml
```

Expected branch:
- Compare OS/kernel/driver branch to supported images.
- If the image tag is unsupported or unavailable, report a support-boundary or
  docs/product gap with exact evidence.
- Only debug credentials after proving the image should exist and be reachable.

Unsafe/low-value branches:
- Retrying image pulls without changing evidence.
- Switching driver branches or OS/kernel without approval.
