# GPU Operator Validated Command Cards

Generated from a curated source manifest. These cards are
structural artifacts; their validation status is only as strong as the
transcript, fixture, or source evidence recorded in each card.

## Prove Brev/K3s Command Context

Status: `validated-live`
Last validated: 2026-07-02
Validated on: GPU Operator v26.3.3, Brev A100 80GB, Ubuntu 22.04.5, K3s v1.36.2+k3s1, containerd 2.3.2-k3s2
Sources: validated on a live A100 GPU node
Risk: `read-only`

Use when:
- the agent has an assigned Brev/K3s sandbox
- any later command will mutate Kubernetes or GPU Operator state

Do not use when:
- the target is not the assigned test-owned sandbox
- KUBECONFIG points to a different cluster

Context proof:

```bash
hostname
id
pwd
uname -a
cat /etc/os-release
nvidia-smi --query-gpu=name,driver_version,memory.total,mig.mode.current --format=csv,noheader
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl config current-context
kubectl get nodes -o wide
kubectl get nodes -o json \
  | jq '.items[] | {name: .metadata.name, os: .status.nodeInfo.osImage, kernel: .status.nodeInfo.kernelVersion, runtime: .status.nodeInfo.containerRuntimeVersion}'
KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm list -A
```

Command:

```bash
hostname
id
pwd
uname -a
cat /etc/os-release
nvidia-smi --query-gpu=name,driver_version,memory.total,mig.mode.current --format=csv,noheader
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl config current-context
kubectl get nodes -o wide
kubectl get nodes -o json \
  | jq '.items[] | {name: .metadata.name, os: .status.nodeInfo.osImage, kernel: .status.nodeInfo.kernelVersion, runtime: .status.nodeInfo.containerRuntimeVersion}'
KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm list -A
```

Expected success signals:
- hostname matches the assigned sandbox
- nvidia-smi shows the expected GPU and healthy driver
- K3s node is Ready
- runtime version is recorded
- Helm reaches the same K3s context

Common failures and interpretation:

| Failure signal | Likely layer | Next action |
|---|---|---|
| `The connection to the server localhost:8080 was refused` | missing kubeconfig | export KUBECONFIG=/etc/rancher/k3s/k3s.yaml; do not reinstall K3s |
| `helm list cannot connect but kubectl works` | Helm context missing | run Helm with inline KUBECONFIG=/etc/rancher/k3s/k3s.yaml |
| `nvidia-smi fails` | host GPU/driver layer | stop product install and collect host evidence |

Fallback:

```bash
KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl get nodes -o wide
KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm version
```

Cleanup verification:

```bash
true
```

Escalate/stop if:
- host GPU is absent or unhealthy
- the shell is not the assigned sandbox
- kube context cannot be proven
## Install GPU Operator On K3s With Host Driver And Explicit Toolkit Env

Status: `validated-fixture`
Last validated: 2026-07-02
Validated on: GPU Operator v26.3.3, Brev A100 80GB, K3s v1.36.2+k3s1, containerd 2.3.2-k3s2
Sources: distilled branch judgment; official NVIDIA GPU Operator docs for install and K3s/runtime configuration
Risk: `high-mutation`

Use when:
- the host driver is already healthy
- K3s/containerd is 2.3.x or otherwise newer than the documented NRI range
- K3s config/socket paths exist
- the environment is an approved disposable K3s sandbox or explicitly approved target

Do not use when:
- the cluster is production/shared
- K3s config/socket paths are unknown
- the host driver is missing or unhealthy

Context proof:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
nvidia-smi
kubectl get nodes -o wide
kubectl get nodes -o json \
  | jq '.items[] | {runtime: .status.nodeInfo.containerRuntimeVersion}'
kubectl get ns gpu-operator --show-labels || true
test -f /var/lib/rancher/k3s/agent/etc/containerd/config.toml
test -S /run/k3s/containerd/containerd.sock
```

Command:

```bash
scripts/install-gpu-operator-k3s-host-driver.sh
```

Expected success signals:
- Helm release is deployed
- ClusterPolicy reaches ready
- operands are Running or Completed
- node advertises nvidia.com/gpu=1
- CUDA VectorAdd card passes

Common failures and interpretation:

| Failure signal | Likely layer | Next action |
|---|---|---|
| `PodSecurity baseline blocks privileged pod` | namespace admission | label gpu-operator namespace privileged if approved |
| `no allocatable GPU after ready` | device-plugin/runtime/hardware | collect device-plugin logs, node labels, host nvidia-smi, Xid evidence |
| `no runtime handler under workload` | toolkit/runtime | inspect toolkit logs and runtime classes; compare actual K3s paths to Helm values |

Fallback:

```bash
Use the CDI/NRI sandbox-experiment branch only when the user explicitly wants to validate newer-than-documented NRI behavior in a disposable sandbox:
helm upgrade --install gpu-operator nvidia/gpu-operator \
  -n gpu-operator \
  --version v26.3.3 \
  --wait --timeout 10m \
  --set driver.enabled=false \
  --set cdi.nriPluginEnabled=true
```

Cleanup verification:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
helm list -n gpu-operator
kubectl get clusterpolicy
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.'nvidia\.com/gpu'
```

Escalate/stop if:
- the branch fails twice with the same runtime/toolkit symptom
- fixing requires driver mutation, node reboot, CRD deletion, or host runtime edits outside the approved sandbox
## Install GPU Operator With Host Driver And CDI/NRI Sandbox Branch

Status: `validated-live`
Last validated: 2026-07-02
Validated on: GPU Operator v26.3.3, Brev A100 80GB, K3s v1.36.2+k3s1, containerd 2.3.2-k3s2
Sources: validated on a live A100 GPU node, official NVIDIA GPU Operator docs for install and CDI/NRI
Risk: `high-mutation`

Use when:
- the user explicitly wants to validate newer-than-documented NRI behavior in a disposable sandbox
- the host driver is already healthy
- the operator will prove the result with workloads and cleanup

Do not use when:
- the cluster is production/shared
- the user asked for the conservative default K3s path
- the host driver is missing or unhealthy

Context proof:

```bash
Same as the Install GPU Operator On K3s With Host Driver And Explicit Toolkit Env card.
```

Command:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
helm upgrade --install gpu-operator nvidia/gpu-operator \
  -n gpu-operator \
  --version v26.3.3 \
  --wait --timeout 10m \
  --set driver.enabled=false \
  --set cdi.nriPluginEnabled=true
```

Expected success signals:
- Same as the Install GPU Operator On K3s With Host Driver And Explicit Toolkit Env card.

Common failures and interpretation:

| Failure signal | Likely layer | Next action |
|---|---|---|
| `PodSecurity baseline blocks privileged pod` | namespace admission | label gpu-operator namespace privileged if approved |
| `no allocatable GPU after ready` | device-plugin/runtime/hardware | collect device-plugin logs, node labels, host nvidia-smi, Xid evidence |
| `no runtime handler under workload` | toolkit/runtime | inspect toolkit logs and runtime classes; compare actual K3s paths to Helm values |

Fallback:

```bash
Any runtime/CDI/NRI ambiguity should fall back to the explicit K3s toolkit-env branch.
```

Cleanup verification:

```bash
Same as the Install GPU Operator On K3s With Host Driver And Explicit Toolkit Env card.
```

Escalate/stop if:
- Same as the Install GPU Operator On K3s With Host Driver And Explicit Toolkit Env card.
## Validate CUDA VectorAdd

Status: `validated-live`
Last validated: 2026-07-02
Validated on: GPU Operator v26.3.3, Brev A100 80GB
Sources: validated on a live A100 GPU node, manifests/cuda-vectoradd.yaml
Risk: `medium-mutation`

Use when:
- GPU Operator is installed
- node advertises at least one allocatable nvidia.com/gpu

Do not use when:
- node has no allocatable GPU
- device-plugin logs indicate Xid or unhealthy device

Context proof:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.'nvidia\.com/gpu'
```

Command:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl delete pod cuda-vectoradd --ignore-not-found
kubectl apply -f manifests/cuda-vectoradd.yaml
kubectl wait pod/cuda-vectoradd --for=jsonpath='{.status.phase}'=Succeeded --timeout=180s
kubectl logs cuda-vectoradd | grep 'Test PASSED'
kubectl delete pod cuda-vectoradd --ignore-not-found
```

Expected success signals:
- pod phase is Succeeded
- logs contain Test PASSED
- pod is removed after cleanup

Common failures and interpretation:

| Failure signal | Likely layer | Next action |
|---|---|---|
| `wait for Ready times out` | wrong success condition | use phase Succeeded plus logs |
| `Insufficient nvidia.com/gpu` | scheduling/device-plugin | inspect node allocatable and device-plugin logs |
| `JSONPath quoting fails` | shell quoting | use kubectl get pod cuda-vectoradd -o json \| jq -r .status.phase |

Fallback:

```bash
kubectl get pod cuda-vectoradd -o json | jq -r .status.phase
kubectl logs cuda-vectoradd
```

Cleanup verification:

```bash
kubectl get pod cuda-vectoradd 2>&1 | grep -E 'NotFound|not found'
```

Escalate/stop if:
- logs do not show Test PASSED after upstream health appears ready
- GPU is marked unhealthy or Xid appears
## Apply, Verify, And Revert Time-Slicing

Status: `validated-live`
Last validated: 2026-07-02
Validated on: GPU Operator v26.3.3, single A100, K3s
Sources: official NVIDIA GPU sharing docs, validated on a live A100 GPU node
Risk: `high-mutation`

Use when:
- the user wants a safe optional example for a single test-owned GPU node
- MIG is disabled and no production workloads are running
- temporary shared GPU advertising is approved

Do not use when:
- workloads are running on a shared/production node
- MIG reconfiguration is requested but not approved
- cleanup cannot be verified

Context proof:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.'nvidia\.com/gpu',PRODUCT:.metadata.labels.'nvidia\.com/gpu\.product',REPLICAS:.metadata.labels.'nvidia\.com/gpu\.replicas',MIG:.metadata.labels.'nvidia\.com/mig\.config\.state'
kubectl get pods -A -o wide | grep -i nvidia.com/gpu || true
```

Command:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl create configmap time-slicing-config-all -n gpu-operator \
  --from-literal=any='version: v1
sharing:
  timeSlicing:
    resources:
    - name: nvidia.com/gpu
      replicas: 4' \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl patch clusterpolicies.nvidia.com/cluster-policy --type=merge \
  -p '{"spec":{"devicePlugin":{"config":{"name":"time-slicing-config-all","default":"any"}}}}'
kubectl rollout status ds/nvidia-device-plugin-daemonset -n gpu-operator --timeout=180s
kubectl wait --for=condition=Ready pod -n gpu-operator -l app=nvidia-device-plugin-daemonset --timeout=180s
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.'nvidia\.com/gpu',PRODUCT:.metadata.labels.'nvidia\.com/gpu\.product',REPLICAS:.metadata.labels.'nvidia\.com/gpu\.replicas'
kubectl apply -f manifests/time-slicing-verification.yaml
kubectl rollout status deployment/time-slicing-verification --timeout=180s
for pod in $(kubectl get pods -l app=time-slicing-verification -o name); do
  kubectl logs "$pod" | grep 'Test PASSED'
done
```

Expected success signals:
- allocatable GPU changes from 1 to configured replica count
- product label gains -SHARED
- verification workload logs show Test PASSED

Common failures and interpretation:

| Failure signal | Likely layer | Next action |
|---|---|---|
| `ClusterPolicy patch applied but Helm values differ` | live/Helm drift | cleanup must reset both live ClusterPolicy and Helm values |
| `pods pending` | GPU sharing/device-plugin | inspect device-plugin rollout, node labels, pod describe |
| `some logs missing before cleanup` | evidence gap | wait for logs or reduce replica count |

Fallback:

```bash
Reduce replicas to 2 and rerun verification, or stop and collect device-plugin logs if rollout does not converge.
```

Cleanup verification:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl delete deployment time-slicing-verification --ignore-not-found
kubectl patch clusterpolicies.nvidia.com/cluster-policy --type=json \
  -p='[{"op":"remove","path":"/spec/devicePlugin/config"}]' || true
kubectl delete configmap time-slicing-config-all -n gpu-operator --ignore-not-found
kubectl rollout status ds/nvidia-device-plugin-daemonset -n gpu-operator --timeout=180s
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.'nvidia\.com/gpu',PRODUCT:.metadata.labels.'nvidia\.com/gpu\.product',REPLICAS:.metadata.labels.'nvidia\.com/gpu\.replicas'
kubectl get configmap time-slicing-config-all -n gpu-operator 2>&1 | grep -E 'NotFound|not found'
```

Escalate/stop if:
- cleanup cannot restore allocatable GPU to baseline
- workloads outside the test namespace are affected
## Same-Version Helm Maintenance Reconciliation

Status: `validated-live`
Last validated: 2026-07-02
Validated on: GPU Operator v26.3.3, Brev A100 80GB
Sources: validated on a live A100 GPU node
Risk: `high-mutation`

Use when:
- testing chart maintenance continuity without changing driver or product version
- the user approved chart-level mutation

Do not use when:
- driver changes, drain, reboot, downgrade, or CRD deletion would be required
- pre-change workload validation fails

Context proof:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
helm list -n gpu-operator
helm get values gpu-operator -n gpu-operator -o yaml
kubectl get clusterpolicy
```

Command:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl delete pod cuda-vectoradd --ignore-not-found
kubectl apply -f manifests/cuda-vectoradd.yaml
kubectl wait pod/cuda-vectoradd --for=jsonpath='{.status.phase}'=Succeeded --timeout=180s
kubectl logs cuda-vectoradd | grep 'Test PASSED'
kubectl delete pod cuda-vectoradd --ignore-not-found

helm upgrade gpu-operator nvidia/gpu-operator \
  -n gpu-operator \
  --version v26.3.3 \
  --reuse-values \
  --wait --timeout 10m

kubectl get clusterpolicy
kubectl apply -f manifests/cuda-vectoradd.yaml
kubectl wait pod/cuda-vectoradd --for=jsonpath='{.status.phase}'=Succeeded --timeout=180s
kubectl logs cuda-vectoradd | grep 'Test PASSED'
kubectl delete pod cuda-vectoradd --ignore-not-found
```

Expected success signals:
- Helm revision increments
- values remain aligned with intended branch
- ClusterPolicy remains ready
- same workload passes before and after

Common failures and interpretation:

| Failure signal | Likely layer | Next action |
|---|---|---|
| `Helm context cannot connect` | missing kubeconfig | rerun with inline KUBECONFIG |
| `post-change VectorAdd fails` | regression or runtime drift | collect Helm values, ClusterPolicy, events, operand logs |
| `Helm values reset but live policy still patched` | state drift | reconcile both Helm values and live ClusterPolicy |

Fallback:

```bash
If Helm revision changed and workload fails, stop and collect evidence before rollback. Use helm rollback only with approval.
```

Cleanup verification:

```bash
kubectl get pod cuda-vectoradd 2>&1 | grep -E 'NotFound|not found'
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.'nvidia\.com/gpu'
```

Escalate/stop if:
- rollback, drain, reboot, or driver mutation appears necessary
## Bad RuntimeClass Failure Injection And Cleanup

Status: `validated-live`
Last validated: 2026-07-02
Validated on: GPU Operator v26.3.3, Brev A100 80GB
Sources: validated on a live A100 GPU node, manifests/bad-runtimeclass-scenario.yaml
Risk: `medium-mutation`

Use when:
- testing whether the agent diagnoses runtime-handler failures without broad reinstall
- the environment is an approved sandbox

Do not use when:
- the target is shared/production
- scenario cleanup cannot be verified

Context proof:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get clusterpolicy
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.'nvidia\.com/gpu'
kubectl get runtimeclass
```

Command:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl apply -f manifests/bad-runtimeclass-scenario.yaml
kubectl describe pod abtest-bad-runtime | sed -n '/Events:/,$p'
kubectl get events --sort-by=.lastTimestamp | tail -30
```

Expected success signals:
- pod fails before workload execution
- event says no runtime for definitely-not-real-nvidia-handler is configured
- ClusterPolicy remains ready and GPU allocatable remains 1

Common failures and interpretation:

| Failure signal | Likely layer | Next action |
|---|---|---|
| `no runtime for synthetic handler` | injected RuntimeClass | delete bad pod/RuntimeClass; do not reinstall |
| `ClusterPolicy not ready before injection` | preexisting product issue | stop scenario and diagnose baseline first |
| `allocatable GPU missing before injection` | device-plugin/hardware | do not run scenario; collect evidence |

Fallback:

```bash
If the manifest path is unavailable, create an equivalent RuntimeClass and pod with a clearly synthetic handler name, then record the exact YAML used.
```

Cleanup verification:

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl delete pod abtest-bad-runtime --ignore-not-found
kubectl delete runtimeclass abtest-bad-nvidia --ignore-not-found
kubectl get pod abtest-bad-runtime 2>&1 | grep -E 'NotFound|not found'
kubectl get runtimeclass abtest-bad-nvidia 2>&1 | grep -E 'NotFound|not found'
kubectl get clusterpolicy
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.'nvidia\.com/gpu'
```

Escalate/stop if:
- cleanup cannot remove the synthetic RuntimeClass
- the scenario changes real GPU Operator state beyond the test pod/runtimeclass
## Public Field Scenario Evidence Triage

Status: `validated-fixture`
Last validated: 2026-07-02
Validated on: GPU Operator v26.3.3 package fixture evidence and public issue/forum seeds
Sources: references/field-scenario-cards.md, public issue/forum seeds listed there
Risk: `read-only`

Use when:
- the prompt describes a public-field-shaped failure
- the agent must diagnose from evidence without browsing public issues/forums

Do not use when:
- the live cluster context is unproven
- the task asks for a product code fix rather than operational diagnosis

Context proof:

```bash
export KUBECONFIG=${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}
kubectl config current-context
kubectl get nodes -o wide
```

Command:

```bash
export KUBECONFIG=${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}
kubectl get clusterpolicy -o yaml || true
kubectl get pods -n gpu-operator -o wide || true
kubectl get ds -n gpu-operator || true
kubectl get runtimeclass || true
kubectl get nodes -L nvidia.com/gpu.present,nvidia.com/gpu.count,nvidia.com/gpu-driver-upgrade-state,nvidia.com/gpu.deploy.device-plugin,nvidia.com/mig.config.state
kubectl get events -A --sort-by='.lastTimestamp' | tail -100
helm list -A || true
helm get values gpu-operator -n gpu-operator -o yaml || true
```

Expected success signals:
- context, pods, daemonsets, node labels, events, Helm values, and ClusterPolicy evidence are captured
- no mutation occurs

Common failures and interpretation:

| Failure signal | Likely layer | Next action |
|---|---|---|
| `namespace not found` | GPU Operator absent or different namespace | search Helm releases and namespaces before assuming install failure |
| `cluster connection refused` | kubeconfig/context | set intended kubeconfig and rerun proof |
| `no ClusterPolicy CRD` | install did not reach CRD stage | collect Helm release/events; do not diagnose operands yet |

Fallback:

```bash
kubectl get ns
helm list -A
```

Cleanup verification:

```bash
true
```

Escalate/stop if:
- context cannot be proven
- required evidence is unavailable and mutation would be speculative
## Device Plugin Disabled Validator Evidence

Status: `docs-derived`
Last validated: not-run as live mutation; distilled from public issue seed
Validated on: public issue evidence and package fixture
Sources: https://github.com/NVIDIA/gpu-operator/issues/2550
Risk: `read-only`

Use when:
- validator/plugin-validation fails while a node may intentionally disable the device plugin with nvidia.com/gpu.deploy.device-plugin=false

Do not use when:
- the task is to enable the device plugin on all nodes
- node label ownership is unknown and mutation is requested

Context proof:

```bash
export KUBECONFIG=${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}
kubectl get nodes --show-labels | grep 'nvidia.com/gpu.deploy.device-plugin=false' || true
kubectl get ds -n gpu-operator nvidia-device-plugin-daemonset -o wide || true
```

Command:

```bash
export KUBECONFIG=${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}
kubectl get pods -n gpu-operator -l app=nvidia-operator-validator -o wide
kubectl logs -n gpu-operator -l app=nvidia-operator-validator -c plugin-validation --tail=100 || true
kubectl describe pod -n gpu-operator -l app=nvidia-operator-validator | sed -n '/Events:/,$p'
```

Expected success signals:
- node disablement labels and validator/plugin logs are captured
- diagnosis distinguishes intentional device-plugin disablement from generic missing GPU resources

Common failures and interpretation:

| Failure signal | Likely layer | Next action |
|---|---|---|
| `GPU resources are not yet discovered` | device plugin disabled or not advertising | compare node labels with daemonset selectors before reinstall |
| `no matching validator pod` | namespace/label drift | inspect all gpu-operator pods and daemonsets |
| `no disabled label found` | different missing GPU cause | continue through success ladder and device-plugin logs |

Fallback:

```bash
kubectl get pods -n gpu-operator -o wide
kubectl get nodes --show-labels
```

Cleanup verification:

```bash
true
```

Escalate/stop if:
- fixing would require removing node labels owned by another workflow
- the product appears to validate a node intentionally excluded from device plugin deployment
## Upgrade State Audit

Status: `docs-derived`
Last validated: not-run as live driver upgrade; distilled from public issue seed
Validated on: public issue evidence and package fixture
Sources: https://github.com/NVIDIA/gpu-operator/issues/2549
Risk: `read-only`

Use when:
- upgrade labels and driver/workload health disagree
- a maintenance task asks whether an upgrade succeeded

Do not use when:
- the user has not approved maintenance diagnosis
- driver mutation, drain, reboot, or relabeling is requested as the first step

Context proof:

```bash
export KUBECONFIG=${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}
kubectl get nodes -L nvidia.com/gpu-driver-upgrade-state
helm list -n gpu-operator
```

Command:

```bash
export KUBECONFIG=${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}
kubectl get nodes -L nvidia.com/gpu-driver-upgrade-state
kubectl get pods -n gpu-operator -o wide
kubectl describe ds -n gpu-operator nvidia-driver-daemonset || true
kubectl get events -A --sort-by='.lastTimestamp' | tail -100
helm get values gpu-operator -n gpu-operator -o yaml || true
kubectl get clusterpolicy -o yaml || true
```

Expected success signals:
- upgrade labels, driver pod status, Helm values, and events are captured
- success is withheld until workload proof also passes

Common failures and interpretation:

| Failure signal | Likely layer | Next action |
|---|---|---|
| `upgrade-failed then upgrade-done` | upgrade controller state ambiguity | require workload proof and driver pod health before accepting success |
| `driver pod CrashLoopBackOff` | driver upgrade path | inspect active GPU workloads and driver logs before relabeling |
| `no upgrade label` | chart-only change or no driver upgrade | use normal maintenance continuity branch |

Fallback:

```bash
kubectl get pods -A -o wide | grep -i nvidia || true
kubectl get nodes --show-labels | grep gpu-driver-upgrade-state || true
```

Cleanup verification:

```bash
true
```

Escalate/stop if:
- relabeling, drain, reboot, or driver downgrade is proposed without explicit approval and rollback plan
