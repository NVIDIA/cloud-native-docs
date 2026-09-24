#!/usr/bin/env bash
# Collect read-only GPU Operator deployment inventory before diagnosis.
# Status: validated-fixture
# Risk: read-only
#
# Use when:
# - Before install, maintenance, troubleshooting, or branch selection.
#
# Do not use when:
# - The shell is not the assigned target environment.
#
# Expected success signals:
# - An inventory directory is written.
# - Host, Kubernetes, runtime, GPU, and GPU Operator evidence files are present when available.
#
# Cleanup verification:
#   test -d "${INVENTORY_DIR}"
#
# Stop/escalate if:
# - The shell or kube context is not the assigned target.
# - Required read access is missing.

set -euo pipefail
KUBECONFIG="${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}"
INVENTORY_DIR="${INVENTORY_DIR:-./gpu-operator-inventory-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "${INVENTORY_DIR}"
run() {
  local name="$1"
  shift
  { echo "$ $*"; "$@"; } >"${INVENTORY_DIR}/${name}.txt" 2>&1 || true
}
run shell-context hostname
run id id
run pwd pwd
run os-release cat /etc/os-release
run kernel uname -a
run nvidia-smi nvidia-smi
run nvidia-smi-query nvidia-smi --query-gpu=name,driver_version,memory.total,mig.mode.current --format=csv,noheader
run lspci-nvidia bash -lc "lspci | grep -i nvidia"
run lsmod-nvidia bash -lc "lsmod | grep -E 'nouveau|nvidia'"
run dmesg-nvidia bash -lc "dmesg | grep -Ei 'NVRM|Xid|nouveau|nvidia' | tail -120"
run containerd-version bash -lc "containerd --version || true"
run crio-version bash -lc "crio --version || true"
run k3s-runtime-paths bash -lc "test -f /var/lib/rancher/k3s/agent/etc/containerd/config.toml && echo k3s-config-present || true; test -S /run/k3s/containerd/containerd.sock && echo k3s-socket-present || true; grep -i nvidia /var/lib/rancher/k3s/agent/etc/containerd/config.toml || true"
if test -f "${KUBECONFIG}"; then
  export KUBECONFIG
  run kube-context kubectl config current-context
  run nodes-wide kubectl get nodes -o wide
  run node-runtime kubectl get nodes -o json
  run node-gpu-labels kubectl get nodes -L feature.node.kubernetes.io/pci-10de.present,nvidia.com/gpu.present,nvidia.com/gpu.count,nvidia.com/gpu-driver-upgrade-state,nvidia.com/mig.config,nvidia.com/mig.config.state
  run runtimeclasses kubectl get runtimeclass -o yaml
  run namespaces kubectl get ns --show-labels
  run gpu-operator-pods kubectl get pods -n gpu-operator -o wide
  run gpu-operator-daemonsets kubectl get ds -n gpu-operator -o wide
  run clusterpolicy kubectl get clusterpolicy -o yaml
  run helm-list helm list -A
  run helm-values bash -lc "helm get values gpu-operator -n gpu-operator -o yaml || true"
  run events bash -lc "kubectl get events -A --sort-by='.lastTimestamp' | tail -200"
  run gpu-workloads bash -lc "kubectl get pods -A -o json | jq -r '.items[] | select((.spec.containers // []) | any((.resources.limits // {})[\"nvidia.com/gpu\"] != null)) | [.metadata.namespace, .metadata.name, .status.phase] | @tsv'"
else
  echo "KUBECONFIG not found: ${KUBECONFIG}" >"${INVENTORY_DIR}/kubeconfig-missing.txt"
fi
echo "Inventory written to ${INVENTORY_DIR}"
