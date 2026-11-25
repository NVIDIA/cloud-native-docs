#!/usr/bin/env bash
# Install GPU Operator on K3s with a host-managed driver and explicit K3s toolkit env.
# Status: validated-fixture
# Risk: high-mutation
#
# Use when:
# - K3s/containerd 2.3.x or newer-than-documented NRI range is present.
# - Host nvidia-smi works and driver lifecycle is platform-owned.
# - K3s config and socket paths exist.
#
# Do not use when:
# - The target is production/shared without approval.
# - Host GPU or K3s runtime paths are not proven.
#
# Expected success signals:
# - Helm release is deployed.
# - ClusterPolicy is ready.
# - Node advertises nvidia.com/gpu.
#
# Cleanup verification:
#   helm list -n "${NAMESPACE}"
#   kubectl get clusterpolicy
#   kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.'nvidia\.com/gpu'
#
# Stop/escalate if:
# - nvidia-smi fails.
# - K3s config/socket paths are absent.
# - The same runtime/toolkit failure repeats twice.

set -euo pipefail
GPU_OPERATOR_VERSION="${GPU_OPERATOR_VERSION:-v26.3.3}"
KUBECONFIG="${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}"
NAMESPACE="${NAMESPACE:-gpu-operator}"
RELEASE="${RELEASE:-gpu-operator}"
export KUBECONFIG
hostname
nvidia-smi
kubectl get nodes -o wide
test -f /var/lib/rancher/k3s/agent/etc/containerd/config.toml
test -S /run/k3s/containerd/containerd.sock
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia >/dev/null 2>&1 || true
helm repo update nvidia
kubectl create ns "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
kubectl label --overwrite ns "${NAMESPACE}" pod-security.kubernetes.io/enforce=privileged
helm upgrade --install "${RELEASE}" nvidia/gpu-operator -n "${NAMESPACE}" --version "${GPU_OPERATOR_VERSION}" --wait --timeout 15m --set driver.enabled=false --set cdi.nriPluginEnabled=false --set toolkit.enabled=true --set toolkit.env[0].name=CONTAINERD_CONFIG --set toolkit.env[0].value=/var/lib/rancher/k3s/agent/etc/containerd/config.toml --set toolkit.env[1].name=CONTAINERD_SOCKET --set toolkit.env[1].value=/run/k3s/containerd/containerd.sock --set toolkit.env[2].name=RUNTIME_CONFIG_SOURCE --set-string toolkit.env[2].value=file=/var/lib/rancher/k3s/agent/etc/containerd/config.toml
kubectl get clusterpolicy
kubectl get pods -n "${NAMESPACE}" -o wide
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.'nvidia\.com/gpu'
