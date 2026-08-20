# GPU Operator Operating Models

These are FMC-style working models for agent reasoning. Use them before
choosing install, maintenance, troubleshooting, or escalation branches.

## How To Use These Models

- Start with the compositional model to locate the owner of the failing layer.
- Use the dynamic model to find the earliest failed transition.
- Use the value model to identify version, flag, label, status, and event
  values that can change the branch decision.
- Walk the minimal success ladder from the bottom up before debugging a
  downstream symptom.
- Record any live-test model change in runtime memory before changing command
  cards or prose.

## Model-First Diagnostic Loop

Use this loop for every non-happy-path scenario:

1. **Locate owner:** decide whether the earliest failing layer is host/provider, Kubernetes/runtime, GPU Operator controller/operand, or user workload.
2. **Find transition:** identify the first dynamic sequence step that failed.
3. **Read values:** collect the version, flag, label, status, event, or log phrase that controls the branch.
4. **Choose branch:** select the lowest-blast-radius branch that targets that layer; explicitly reject broader reinstall/reset branches.
5. **Validate:** prove the next rung of the success ladder before moving downstream.
6. **Persist:** if the evidence changes the model, update runtime memory before changing commands.

| Symptom shape | First model to use | Evidence that selects branch | Avoid |
| --- | --- | --- | --- |
| Validator fails but device plugin is intentionally disabled | Compositional ownership of device plugin and validator | node labels, daemonset selectors, validator logs | reinstalling operator or debugging CUDA workload |
| Runtime handler missing or CDI device unresolved | Toolkit/CDI/NRI value model and dynamic install sequence | RuntimeClasses, ClusterPolicy CDI/NRI, toolkit logs, pod event | treating as app image failure |
| Upgrade state labels conflict with pod health | Dynamic upgrade sequence and value model | gpu-driver-upgrade-state, driver pod status, workload pre/post proof | accepting upgrade-done without workload validation |
| Driver pod cannot mount host path or load kernel feature | Host/provider ownership and driver daemonset layer | kernel config, mount error, driver pod events | Helm retry loops |
| Image pull failure for driver/toolkit operand | Source/support boundary and operand layer | OS/kernel, image tag, registry event, support matrix | credential debugging before image existence/support check |

## Compositional Model

| component | owner | source_of_truth | writes | health_signal |
| --- | --- | --- | --- | --- |
| Sandbox/VM/host | Test environment owner | provisioning record | OS/runtime/K3s installs | hostname, OS/kernel, GPU visible |
| Kubernetes API/kubelet/runtime | Platform | cluster/kubeconfig/runtime config | node/runtime state | nodes Ready, runtime version |
| GPU hardware and host driver | Host/provider unless operator-managed driver | PCI/driver modules | kernel modules, device state | lspci, nvidia-smi, dmesg |
| NFD | GPU Operator by default or platform if pre-existing | node labels | feature labels | NVIDIA PCI labels |
| GPU Operator controller | Helm release | chart values, ClusterPolicy | operand resources | controller pod running |
| ClusterPolicy | GPU Operator CR | Helm-rendered CR and live patches | desired operand config | .status.state=ready/notReady |
| Driver daemonset | GPU Operator if driver.enabled=true; host otherwise | ClusterPolicy/NVIDIADriver/host | kernel driver files/modules | driver pod ready, nvidia-smi |
| Toolkit/CDI/NRI | GPU Operator if toolkit enabled; host otherwise | ClusterPolicy/runtime config | CDI specs, NRI plugin, runtime config | toolkit pod logs, no sandbox runtime errors |
| Device plugin | GPU Operator | ClusterPolicy/device-plugin config | extended resources | nvidia.com/gpu allocatable |
| MIG Manager | GPU Operator | ClusterPolicy, node labels, configmaps | MIG geometry/labels | mig.config.state=success |
| DCGM Exporter | GPU Operator | ClusterPolicy | metrics endpoint/service | exporter pod/logs/service |
| Workloads/examples | User/tester | manifests | GPU requests | VectorAdd Test PASSED |

## Dynamic Model

### Clean sandbox sequence

- Provision/select test-owned host.
- Prove shell host and GPU.
- Install/select Kubernetes.
- Set and prove KUBECONFIG.
- Re-check runtime, NFD labels, RuntimeClasses, host driver.
- Choose GPU Operator branch and Helm values.
### Install sequence

- Helm installs CRDs, operator deployment, and default ClusterPolicy.
- NFD labels GPU nodes unless an existing NFD branch is selected.
- Operator reconciles driver/toolkit/device-plugin/MIG/DCGM operands.
- Driver becomes usable or host driver is accepted.
- Toolkit configures CDI/NRI or legacy runtime integration.
- Device plugin advertises resources.
- Validators and durable workload manifests prove end-to-end GPU access.
### Upgrade sequence

- Capture values, manifest, CRDs, ClusterPolicy, node labels, workload inventory, and baseline workload results.
- Choose CRD hook or manual CRD path.
- Helm upgrade chart.
- If driver changes, monitor upgrade controller labels/events.
- Run the same workload suite after change.
- Roll back chart or driver only with the captured rollback point.
### Troubleshooting sequence

- Identify the earliest failing layer.
- Treat a CUDA workload error as downstream until host GPU, NFD labels, driver/toolkit, and device plugin advertisement are proven.

## Value Model

| value | meaning | evidence |
| --- | --- | --- |
| driver.enabled=true | GPU Operator owns containerized driver lifecycle | Helm values, ClusterPolicy |
| driver.enabled=false | Host/platform owns driver lifecycle | Helm values, host nvidia-smi |
| cdi.enabled=true | CDI device injection enabled by default in v25.10.0+ | docs, chart values |
| cdi.nriPluginEnabled=true | Toolkit runs NRI plugin; no nvidia RuntimeClass needed | ClusterPolicy, toolkit logs |
| toolkit.enabled=true | Operator owns toolkit/CDI/NRI config | chart values, toolkit pod |
| nfd.enabled=true | Chart deploys NFD by default | chart values, NFD pods |
| ClusterPolicy.status.state=ready | Operator sees operands ready | kubectl get clusterpolicy |
| nvidia.com/gpu.present=true | GPU node discovered | node labels |
| nvidia.com/gpu allocatable | Scheduler can place GPU workloads | node status |
| nvidia.com/gpu-driver-upgrade-state | Driver upgrade controller state | node labels |
| nvidia.com/mig.config.state | MIG Manager convergence state | node labels |

## Minimal Success Ladder

1. Intended sandbox shell proven.
2. Host GPU visible.
3. Kubernetes context proven and nodes Ready.
4. Runtime version and NFD state captured.
5. GPU Operator Helm install succeeds with explicit values.
6. Operator and operands are Running or validator pods Completed.
7. ClusterPolicy is ready.
8. GPU node advertises nvidia.com/gpu.
9. manifests/cuda-vectoradd.yaml completes with Test PASSED.
10. Declared optional example suite passes for the environment.
11. Health remains stable over the declared soak interval.
12. Same workload suite passes after approved upgrade/rollback.

## Branch Decision Table

| decision | choose_when | evidence | risk | fallback |
| --- | --- | --- | --- | --- |
| Operator-managed driver | no trusted host driver or disposable sandbox wants one owner | host nvidia-smi absent/not owned | driver mutates host kernel modules | host-managed branch if driver works |
| Host-managed driver | host driver works and platform owns lifecycle | nvidia-smi, user intent | hidden host drift | operator-managed in fresh sandbox |
| Chart NFD | no feature labels or NFD owner | label check false | duplicate NFD if wrong | disable NFD after owner proof |
| Existing NFD | feature labels and existing NFD are owned | labels/pods | stale labels | chart NFD after approval |
| CDI+NRI | K3s/k0s/RKE2 or non-standard containerd, runtime in known range | runtime version, docs | NRI API maturity | legacy toolkit env |
| Newer-than-known NRI | runtime newer than docs range, e.g. containerd 2.3.x | runtime version plus live test caveat | untested runtime behavior | proceed only in sandbox with extra validation, or use legacy/stop |
| Host toolkit/runtime | K3s generated working NVIDIA handlers from host toolkit | RuntimeClasses, host toolkit evidence | host drift | operator toolkit branch |
| MIG change | explicit partitioning requirement | MIG labels/capability, no active workload | workload disruption/reboot | leave MIG disabled |
