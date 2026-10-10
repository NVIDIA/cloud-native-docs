#!/usr/bin/env bash
# Scaffold for a time-slicing example: safety-gate + namespace setup/teardown.
# Status: validated-fixture
# Risk: high-mutation
#
# Use when:
# - Single test-owned node has no non-test GPU workloads and MIG is disabled.
#
# Do not use when:
# - Production/shared node or active workload inventory is present.
#
# Expected success signals:
# - No active GPU workloads are present before mutation.
# - Temporary namespace is removed during cleanup.
#
# Cleanup verification:
#   kubectl get namespace "${NAMESPACE}" 2>&1 | grep -E 'NotFound|not found'
#
# Stop/escalate if:
# - Active GPU workloads are present.
# - Cleanup cannot restore baseline.

set -euo pipefail
KUBECONFIG="${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}"
NAMESPACE="${NAMESPACE:-gpu-operator-timeslice}"
OPERATOR_NAMESPACE="${OPERATOR_NAMESPACE:-gpu-operator}"
CONFIGMAP="${CONFIGMAP:-time-slicing-config-all}"
REPLICAS="${REPLICAS:-2}"
export KUBECONFIG
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.'nvidia\.com/gpu'
kubectl get pods -A -o json | jq -e '.items[] | select((.spec.containers // []) | any((.resources.limits // {})["nvidia.com/gpu"] != null))' >/dev/null && { echo "GPU workloads already exist; stop before time-slicing mutation" >&2; exit 2; } || true
kubectl delete ns "${NAMESPACE}" --ignore-not-found=true
kubectl delete configmap -n "${OPERATOR_NAMESPACE}" "${CONFIGMAP}" --ignore-not-found=true
kubectl create namespace "${NAMESPACE}"
echo "Use the full package command card for ConfigMap and deployment manifests when running this script candidate."
kubectl delete namespace "${NAMESPACE}"
kubectl wait --for=delete "ns/${NAMESPACE}" --timeout=180s || true
