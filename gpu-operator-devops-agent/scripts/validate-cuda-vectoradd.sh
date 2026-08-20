#!/usr/bin/env bash
# Run and clean up the CUDA VectorAdd proof workload.
# Status: validated-live
# Risk: medium-mutation
#
# Use when:
# - GPU Operator is installed and node advertises allocatable nvidia.com/gpu.
#
# Do not use when:
# - Device-plugin logs or dmesg indicate unhealthy GPU/Xid.
#
# Expected success signals:
# - Pod phase reaches Succeeded.
# - Logs contain Test PASSED.
# - Pod is removed after cleanup.
#
# Cleanup verification:
#   kubectl get pod cuda-vectoradd 2>&1 | grep -E 'NotFound|not found'
#
# Stop/escalate if:
# - VectorAdd fails after upstream health is ready.
# - GPU is marked unhealthy or Xid appears.

set -euo pipefail
KUBECONFIG="${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}"
PACKAGE_ROOT="${PACKAGE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MANIFEST="${MANIFEST:-${PACKAGE_ROOT}/manifests/cuda-vectoradd.yaml}"
export KUBECONFIG
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.'nvidia\.com/gpu'
kubectl delete pod cuda-vectoradd --ignore-not-found
kubectl apply -f "${MANIFEST}"
kubectl wait pod/cuda-vectoradd --for=jsonpath='{.status.phase}'=Succeeded --timeout=180s
kubectl logs cuda-vectoradd | grep 'Test PASSED'
kubectl delete pod cuda-vectoradd --ignore-not-found
kubectl get pod cuda-vectoradd 2>&1 | grep -E 'NotFound|not found'
