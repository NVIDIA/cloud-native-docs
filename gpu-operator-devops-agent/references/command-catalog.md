# Command Catalog

Risk levels: `read-only`, `local-mutation`, `medium-mutation`,
`high-mutation`.

| Command | Purpose | Expected signal | Risk |
|---|---|---|---|
| `hostname; id; pwd` | Prove shell host/user/location | intended sandbox shell | read-only |
| `export KUBECONFIG=/etc/rancher/k3s/k3s.yaml` | Select fresh K3s cluster context | later `kubectl` reaches K3s | local-mutation |
| `kubectl config current-context` | Prove kube context | expected context name | read-only |
| `kubectl get nodes -o wide` | Node readiness/runtime | node `Ready`; runtime shown | read-only |
| `kubectl get nodes -o json | jq ...nodeInfo...` | OS/kernel/runtime inventory | OS, kernel, runtime versions | read-only |
| `nvidia-smi` | Host GPU/driver evidence | GPU table, driver version | read-only host |
| `lspci | grep -i nvidia` | Host PCI GPU evidence | NVIDIA device present | read-only host |
| `lsmod | grep -E 'nouveau|nvidia'` | Driver module state | expected NVIDIA modules; no `nouveau` conflict | read-only host |
| `containerd --version` | Runtime version | version string | read-only host |
| `kubectl get runtimeclass` | Runtime handler evidence | expected classes or empty under NRI | read-only |
| `helm repo add nvidia https://helm.ngc.nvidia.com/nvidia` | Add chart repo | repo added | local-mutation |
| `helm repo update nvidia` | Refresh chart repo | update succeeds | local-mutation |
| `helm show values nvidia/gpu-operator --version v26.3.3` | Inspect chart defaults | values printed | read-only |
| `KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm list -A` | Prove Helm can reach K3s context | releases listed or empty table | read-only |
| `kubectl create ns gpu-operator` | Create operator namespace | namespace exists | medium-mutation |
| `kubectl label --overwrite ns gpu-operator pod-security.kubernetes.io/enforce=privileged` | Permit privileged operands under PSA | label present | medium-mutation |
| `helm install gpu-operator nvidia/gpu-operator ...` | Install GPU Operator | release deployed | high-mutation |
| `helm upgrade gpu-operator nvidia/gpu-operator ... --disable-openapi-validation` | Upgrade chart with CRD hook | revision increments | high-mutation |
| `helm rollback gpu-operator <rev> -n gpu-operator` | Roll back chart | previous revision active | high-mutation |
| `kubectl apply -f manifests/cuda-vectoradd.yaml` | Durable CUDA validation | pod completes; logs `Test PASSED` | medium-mutation |
| `kubectl delete -f manifests/cuda-vectoradd.yaml --ignore-not-found` | Clean validation pod | pod absent | medium-mutation |
| `kubectl apply -f manifests/time-slicing-verification.yaml` | Optional time-slicing workload proof | replicas running/logging VectorAdd | medium-mutation |
| `kubectl apply -f manifests/bad-runtimeclass-scenario.yaml` | Troubleshooting scenario injection | expected sandbox runtime error | medium-mutation |
| `kubectl patch clusterpolicies.nvidia.com/cluster-policy ...` | Change CDI/NRI/driver/MIG policy | operands reconcile/restart | high-mutation |
| `kubectl label node <node> nvidia.com/mig.config=... --overwrite` | Change MIG geometry | `mig.config.state=success` | high-mutation |
| `kubectl drain <node>` | Evict workloads from node | node drained | high-mutation |
| `sudo reboot` | Restart node | node returns | high-mutation |

High-mutation commands require explicit approval, blast-radius statement, and a
rollback or recovery plan.

For fragile or mutating command paths, use `references/command-cards.md` before
inventing new syntax. The cards record validation status, exact context proof,
expected signals, known failure strings, fallback, and cleanup verification.

Prefer manifest-based workload creation over `kubectl run --limits`; some
client versions do not support the limits flag shape consistently. If a quick
imperative command fails because of client flag drift, switch to a small
manifest and record the drift as an anti-pattern.
