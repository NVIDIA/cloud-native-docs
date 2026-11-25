# Bootstrap And Command Context

Use this reference before install, maintenance, or troubleshooting when the
target substrate might not exist or the shell context is uncertain.

## Clean-Sandbox Path

For documentation/example testing, start from a clean, disposable GPU sandbox —
for example a cloud GPU instance (such as a Brev instance) or a single-node K3s
host.

Record the selected environment and how it was provisioned. The setup notes must
record instance type, instance ID, GPU model, Kubernetes/substrate choice,
cleanup command, and whether the instance should be stopped or destroyed. If a
clean sandbox is not available, stop and provision one before continuing.

## K3s Bootstrap On A Test-Owned VM

Only use this when the VM is explicitly assigned to the test and host mutation
is approved.

1. Prove the host:

   ```bash
   hostname
   id
   uname -a
   cat /etc/os-release
   nvidia-smi
   lspci | grep -i nvidia
   ```

2. Install or select Kubernetes. For a disposable K3s sandbox, install K3s by
   the approved environment runbook. If the runbook explicitly allows the
   upstream K3s installer, use:

   ```bash
   curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -s -
   ```

   After install, always set:

   ```bash
   export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
   ```

3. Prove command context:

   ```bash
   export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
   kubectl config current-context
   kubectl get nodes -o wide
   kubectl get nodes -o json \
     | jq '.items[] | {name: .metadata.name, os: .status.nodeInfo.osImage, kernel: .status.nodeInfo.kernelVersion, runtime: .status.nodeInfo.containerRuntimeVersion}'
   KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm version
   ```

4. Capture runtime and handler evidence after K3s exists:

   ```bash
   containerd --version || true
   sudo k3s crictl info 2>/dev/null | jq '.config.containerd' || true
   kubectl get runtimeclass || true
   ```

5. Only now choose GPU Operator install values.

## Command-Context Proof Checklist

Write these facts into the transcript before mutation:

- Shell hostname and user.
- `KUBECONFIG` path or kube context.
- `kubectl get nodes -o wide` output.
- Kubernetes version and runtime version.
- GPU model and host driver state.
- Helm repo and chart version.
- Whether NFD labels already exist.
- Whether namespace Pod Security Admission requires a privileged label.

## Staged Branch Decisions

| Decision | Stage 1 before K8s | Stage 2 after K8s/K3s bootstrap |
|---|---|---|
| Driver ownership | Check host `nvidia-smi` and user intent | If host driver works and platform owns it, use `driver.enabled=false`; otherwise use operator-managed driver in disposable sandbox |
| NFD ownership | Unknown until node labels exist | If feature labels already exist from an owned NFD, set `nfd.enabled=false`; otherwise chart-managed NFD |
| Runtime/toolkit path | Runtime may not exist yet | Prefer CDI default; enable NRI on K3s-like runtimes in known-tested range; for newer runtime, proceed only with caveat and extra validation |
| Validation | Do not run workloads | Apply manifests under `manifests/` after allocatable GPU exists |

## Validation And Reporting

When validating documentation examples or end-to-end documented procedures on a
disposable sandbox, capture a report that states:

- how the sandbox was provisioned;
- product package path and version;
- instance type, ID, GPU model, and cleanup command;
- commands run and risk class;
- pass/fail for context proof, install, workload suite, maintenance continuity,
  troubleshooting scenario, and cleanup.

Portability note: do not assume GNU `timeout` exists on the machine running
these commands. If it is missing (for example on macOS), use your shell or SSH
command boundaries, or record its absence, instead of relying on `timeout`.

For K3s sandboxes, `kubectl` and `helm` may not share the same context unless
`KUBECONFIG=/etc/rancher/k3s/k3s.yaml` is exported or supplied inline. Prove
Helm context separately before `helm install`, `helm upgrade`, or `helm get`.

Cleanup verification checklist:

- disposable namespaces, pods, jobs, deployments, and RuntimeClasses are gone;
- optional-example ConfigMaps are gone or no longer referenced;
- live `ClusterPolicy` matches the intended baseline;
- Helm values match the intended baseline;
- node GPU labels, capacity, and allocatable resources match the intended
  baseline;
- final CUDA VectorAdd smoke passes.
