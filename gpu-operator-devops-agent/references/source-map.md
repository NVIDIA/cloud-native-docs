# Source Map

Reviewed 2026-07-02. Public URLs are listed for runtime traceability. The
runtime package depends on these public sources and live target-environment
evidence gathered during the user's approved run.

## Product Docs

- `getting-started.rst`
  - Public: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html
  - Supports prerequisites, Helm install, PSA namespace label, containerd
    branch, CDI/NRI options, install verification, CUDA VectorAdd manifest,
    Jupyter example, and optional workload pointers.
- `cdi.rst`
  - Public: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/cdi.html
  - Supports CDI default, NRI behavior, K3s/k0s/RKE2 no-runtime-config branch,
    RuntimeClass behavior, NRI runtime requirements, and `hostUsers:false`
    known issue.
- `platform-support.rst`
  - Public: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/platform-support.html
  - Supports support-matrix review and NRI runtime range.
- `upgrade.rst`
  - Public: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/upgrade.html
  - Supports CRD manual/hook upgrade paths and
    `--disable-openapi-validation`.
- `gpu-driver-upgrades.rst`
  - Public: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-driver-upgrades.html
  - Supports driver upgrade controller, state labels, events, drain risk, and
    recovery labels.
- `troubleshooting.rst`
  - Public: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/troubleshooting.html
  - Supports runtime handler, `nouveau`, Fabric Manager, Xid, DCGM, stuck
    upgrades, and label/taint failure signatures.
- `gpu-operator-mig.rst`
  - Public: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-mig.html
  - Supports MIG strategy, config state labels, workload/reboot cautions.
- `gpu-sharing.rst`
  - Public: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-sharing.html
  - Supports optional time-slicing validation branch.
- `release-notes.rst`
  - Public: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/release-notes.html
  - Supports version-specific component and known-issue checks before using
    this package outside the reviewed target.

## Product Source

- GPU Operator tag `v26.3.3`, commit
  `b0a49c0e7b2e061dcd83f2bb2fe4fe960c5d0338`.
- `deployments/gpu-operator/values.yaml`
  - Public: https://github.com/NVIDIA/gpu-operator/blob/v26.3.3/deployments/gpu-operator/values.yaml
  - Supports chart defaults: CDI, NRI, NFD, operator CRD hook, driver upgrade
    policy, toolkit/device-plugin/DCGM/MIG settings.
- `deployments/gpu-operator/templates/validations.yaml`
  - Public: https://github.com/NVIDIA/gpu-operator/blob/v26.3.3/deployments/gpu-operator/templates/validations.yaml
  - Supports invalid CDI/NRI/toolkit combinations.
- `api/nvidia/v1/clusterpolicy_types.go`
  - Public: https://github.com/NVIDIA/gpu-operator/blob/v26.3.3/api/nvidia/v1/clusterpolicy_types.go
  - Supports CRD fields/status model.
- `hack/must-gather.sh`
  - Public: https://github.com/NVIDIA/gpu-operator/blob/v26.3.3/hack/must-gather.sh
  - Supports evidence bundle content.
- `validator/manifests/*.yaml`
  - Public: https://github.com/NVIDIA/gpu-operator/tree/v26.3.3/validator/manifests
  - Supports validator workload behavior.

## Substrate Docs

- K3s installation and kubeconfig behavior:
  - Public: https://docs.k3s.io/quick-start
  - Supports `/etc/rancher/k3s/k3s.yaml` command-context proof for fresh K3s
    sandboxes.

## Public Field Scenario Seeds

- GPU Operator issue #2550:
  - Public: https://github.com/NVIDIA/gpu-operator/issues/2550
  - Supports validator/device-plugin-disabled field scenario.
- GPU Operator issue #1876:
  - Public: https://github.com/NVIDIA/gpu-operator/issues/1876
  - Supports CDI device injection / RuntimeClass upgrade field scenario.
- GPU Operator issue #2549:
  - Public: https://github.com/NVIDIA/gpu-operator/issues/2549
  - Supports upgrade-state ambiguity field scenario.
- GPU Operator issue #2463:
  - Public: https://github.com/NVIDIA/gpu-operator/issues/2463
  - Supports kernel hostPath / driver daemonset compatibility field scenario.
- NVIDIA Developer Forum runtime-handler thread:
  - Public: https://forums.developer.nvidia.com/t/failed-to-create-pod-sandbox-rpc-error-code-unknown-desc-failed-to-get-sandbox-runtime-no-runtime-for-nvidia-is-configured/296409
  - Supports missing `nvidia` runtime handler field scenario.
- NVIDIA Developer Forum driver image pull thread:
  - Public: https://forums.developer.nvidia.com/t/gpu-operator-helm-chat-deployment-issues/349743
  - Supports driver image pull / unsupported platform field scenario.
