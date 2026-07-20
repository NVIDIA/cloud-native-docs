# GPU Operator Deployment Environment Inventory

Collect this inventory before diagnosing an issue or choosing an install,
maintenance, or recovery branch. Do not reason from symptom text alone. The
inventory tells the operating agent which layer owns the current behavior.

## Required Inventory

| area | evidence | why_it_matters |
| --- | --- | --- |
| Target identity | hostname, cloud/sandbox ID, user, working directory | Prevents mutation of the wrong host or cluster. |
| Kubernetes context | KUBECONFIG, current context, node list | Most false starts come from missing or wrong kube context. |
| Kubernetes distribution | node version, kubelet version, runtime string | K3s/RKE2/MicroK8s/containerd paths differ from default Kubernetes. |
| Host OS/kernel | /etc/os-release, uname -a | Driver and toolkit behavior depends on OS/kernel support. |
| GPU and driver | nvidia-smi, MIG mode, GPU model, driver version | Selects host-managed vs operator-managed driver branch. |
| Runtime paths | containerd/CRI-O version, config path, socket path | Selects CDI/NRI, explicit toolkit env, or host-toolkit branch. |
| NFD ownership | NFD pods, feature labels, GPU labels | Prevents duplicate NFD or stale-label decisions. |
| GPU Operator state | Helm release, values, ClusterPolicy, operands | Distinguishes install/config issues from workload issues. |
| Runtime integration | RuntimeClasses, CDI/NRI fields, toolkit logs | Diagnoses runtime handler and CDI injection failures. |
| Device plugin state | allocatable GPU, device-plugin logs, node labels | Determines whether workloads can schedule. |
| Workloads | GPU pods, namespaces, active GPU clients | Prevents disruptive maintenance and identifies workload-owned failures. |
| Hardware faults | dmesg/Xid, nvidia-smi -q, GPU health | Xid/hardware faults should stop product-level mutation. |

## Inventory Script

Use `scripts/inventory-gpu-operator-environment.sh` when shell access is available.

Required environment:
- KUBECONFIG, defaulting to /etc/rancher/k3s/k3s.yaml
- INVENTORY_DIR, defaulting to ./gpu-operator-inventory-<timestamp>

## Branch Decisions That Depend On Inventory

- driver.enabled requires host nvidia-smi, driver ownership, and platform intent.
- toolkit.enabled requires runtime handler/CDI evidence and whether host toolkit is already functional.
- cdi.nriPluginEnabled requires runtime version and whether the run is intentionally validating newer-than-documented NRI.
- nfd.enabled requires feature label evidence and NFD owner.
- maintenance/upgrade safety requires active workload inventory and pre-change workload proof.
- troubleshooting branch requires earliest-failed-layer evidence from events, logs, labels, and hardware health.

## Stop Conditions

- the host or kube context is not the assigned target
- nvidia-smi fails on a host-managed-driver branch
- Xid or hardware/fabric faults appear
- runtime config paths are unknown and the next step would edit host runtime
- active workloads would be disrupted without approval
- source evidence conflicts on a load-bearing support claim
