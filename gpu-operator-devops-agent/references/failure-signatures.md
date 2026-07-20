# Failure Signatures

| Symptom | Likely earliest layer | First checks | Recovery posture |
|---|---|---|---|
| `kubectl` points at wrong/empty cluster | command context | `echo $KUBECONFIG`, `kubectl config current-context`, nodes | stop before mutation; set intended context |
| Helm cannot reach cluster after K3s install | kubeconfig missing | `KUBECONFIG`, `/etc/rancher/k3s/k3s.yaml` | export K3s kubeconfig, rerun read-only proof |
| GPU Operator pods blocked by Pod Security | namespace PSA | namespace labels, events | label namespace privileged with approval |
| Daemonsets `DESIRED=0` | NFD labels/taints | node labels, taints, daemonset selectors | repair labels/tolerations; do not debug CUDA yet |
| Pods stuck in `Init` | driver/toolkit not ready | driver/toolkit logs, events, dmesg | fix earliest driver/toolkit issue |
| `no runtime for "nvidia" is configured` | runtime handler/toolkit | RuntimeClasses, ClusterPolicy CDI/NRI, toolkit logs | on K3s prefer CDI+NRI if supported; otherwise verify exact legacy paths |
| NRI enabled but chart render fails | invalid values | chart validation, CDI/toolkit values | keep CDI and toolkit enabled or disable NRI |
| `ClusterPolicy ready` but no allocatable GPU | device plugin/GPU health | device-plugin logs, dmesg/Xid | escalate hardware/driver if critical Xid |
| Device plugin marks GPU unhealthy/Xid 79 | GPU fell off bus/hardware | dmesg, device-plugin logs, host GPU UUID | stop product mutation; escalate |
| DCGM exporter failing while workloads pass | observability path | exporter logs/service/network policy | separate from core scheduling; repair observability only |
| Driver upgrade stuck at `pod-deletion-required` | GPU pod eviction blocked | upgrade labels/events, workload pod details | resolve workload/local storage; drain only as last resort |
| Node in `upgrade-failed` | failed driver upgrade stage | events and operator logs | fix cause before relabeling `upgrade-required` |
| MIG config pending/rebooting | active workloads or reboot needed | MIG labels, MIG manager logs, GPU clients | stop workloads/cordon/reboot only with approval |
| Pod with `hostUsers:false` fails sync socket | unsupported user namespace GPU pod | workload spec, CDI docs | remove `hostUsers:false` or set true |
| Mixed MIG/full GPU scheduling fails on affected drivers | known driver/NVML issue | driver version, MIG topology, issue evidence | use documented workaround only with approval |

Unsupported quick fixes: CRD deletion, generic reinstall, repeated pod restarts,
driver downgrade, full node drain, or MIG relabeling without approval and
evidence.

## Public Field Scenario Branch Table

| Scenario shape | First failing layer | Evidence to require | Correct posture |
|---|---|---|---|
| Validator fails on node with `nvidia.com/gpu.deploy.device-plugin=false` | validator/device-plugin ownership mismatch | node labels, daemonset selectors, plugin-validation logs | diagnose intentional disablement; avoid reinstall |
| CDI device injection error after upgrade | toolkit/CDI/runtime integration | RuntimeClasses, ClusterPolicy CDI/NRI, toolkit logs, failing pod event | choose scoped runtime/toolkit branch |
| `upgrade-failed` transitions later to `upgrade-done` | upgrade-controller state ambiguity | node upgrade labels, driver pod status, workload pre/post result | require workload proof before success |
| Driver pod mount error under `/sys/devices/system/memory` | host kernel/driver daemonset compatibility | kernel config, driver pod event, Helm values | escalate support/compatibility; avoid Helm retry |
| `no runtime for "nvidia" is configured` | RuntimeClass/toolkit config | RuntimeClasses, ClusterPolicy, toolkit logs, pod event | choose CDI/NRI or legacy path from evidence |
| Driver image `ImagePullBackOff` for specific OS/kernel/image | support matrix/image availability | OS, kernel, image tag, registry event, values | distinguish unsupported image from credential issue |
