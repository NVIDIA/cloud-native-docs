---
name: gpu-operator-maintain
description: Plan GPU Operator upgrades, rollback, driver changes, MIG changes, and maintenance continuity checks.
tags: [gpu-operator, maintain, upgrade, rollback, driver, mig]
---

# GPU Operator Maintain

Use for chart upgrades, rollback, driver changes, MIG changes, and config
maintenance.

## Preconditions

- Explicit approval for mutation.
- Maintenance window for driver, MIG, drain, reboot, or runtime changes.
- `kubectl`/`helm` context proven.
- Workload owner notified when GPU workloads may be interrupted.
- Declared workload suite selected before change.

## Baseline And Continuity Capture

```bash
helm list -n gpu-operator
helm get values gpu-operator -n gpu-operator -o yaml > gpu-operator-values-before.yaml
helm get manifest gpu-operator -n gpu-operator > gpu-operator-manifest-before.yaml
kubectl get clusterpolicy -o yaml > clusterpolicy-before.yaml
kubectl get crd | grep -E 'nvidia.com|nodefeaturerules' > crds-before.txt
kubectl get nvidiadrivers.nvidia.com -A -o yaml > nvidiadrivers-before.yaml || true
kubectl get nodes -L nvidia.com/gpu-driver-upgrade-state,nvidia.com/mig.config,nvidia.com/mig.config.state
kubectl get pods -A -o wide > pods-before.txt
kubectl get runtimeclass > runtimeclasses-before.txt || true
```

Run the declared workload suite before changing state:

```bash
kubectl apply -f manifests/cuda-vectoradd.yaml
kubectl logs pod/cuda-vectoradd
kubectl delete -f manifests/cuda-vectoradd.yaml --ignore-not-found
```

## Chart Upgrade

Use the CRD hook path for v24.9.0+ when image pulls and hook jobs are expected
to work:

```bash
export RELEASE_TAG=v26.3.3
helm repo update nvidia
helm show values nvidia/gpu-operator --version "$RELEASE_TAG" > "values-$RELEASE_TAG.yaml"
# Merge approved existing values into values-$RELEASE_TAG.yaml.
helm upgrade gpu-operator nvidia/gpu-operator \
  -n gpu-operator \
  --disable-openapi-validation \
  -f "values-$RELEASE_TAG.yaml" \
  --version "$RELEASE_TAG"
```

Use the manual CRD path only when hook behavior is unsuitable:

```bash
kubectl apply -f "https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/$RELEASE_TAG/deployments/gpu-operator/crds/nvidia.com_clusterpolicies.yaml"
kubectl apply -f "https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/$RELEASE_TAG/deployments/gpu-operator/crds/nvidia.com_nvidiadrivers.yaml"
kubectl apply -f "https://raw.githubusercontent.com/NVIDIA/gpu-operator/refs/tags/$RELEASE_TAG/deployments/gpu-operator/charts/node-feature-discovery/crds/nfd-api-crds.yaml"
helm upgrade gpu-operator nvidia/gpu-operator -n gpu-operator -f "values-$RELEASE_TAG.yaml" --version "$RELEASE_TAG"
```

## Driver Upgrade

Only for operator-managed drivers. If `driver.enabled=false`, use the
host/platform driver runbook instead.

```bash
kubectl patch clusterpolicies.nvidia.com/cluster-policy \
  --type='json' \
  -p='[{"op":"replace","path":"/spec/driver/version","value":"<approved-version>"}]'
kubectl get node -l nvidia.com/gpu.present \
  -ojsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.nvidia\.com/gpu-driver-upgrade-state}{"\n"}{end}'
kubectl get events -A --sort-by='.lastTimestamp' | grep GPUDriverUpgrade
kubectl logs -n gpu-operator deployment/gpu-operator | grep controllers.Upgrade
```

Do not enable `driver.upgradePolicy.drain.enable=true` until GPU pod deletion
controls are insufficient and workload owners approve broader eviction.

## Post-Change Continuity

```bash
kubectl get pods -n gpu-operator -o wide
kubectl get ds -n gpu-operator
kubectl get clusterpolicy
kubectl get nodes -o json | jq '.items[] | {name: .metadata.name, allocatable_gpu: .status.allocatable["nvidia.com/gpu"]}'
kubectl apply -f manifests/cuda-vectoradd.yaml
kubectl logs pod/cuda-vectoradd
kubectl delete -f manifests/cuda-vectoradd.yaml --ignore-not-found
```

Pass requires the same suite to pass after change and no new persistent operand
errors during the declared soak interval.

## Rollback

```bash
helm history gpu-operator -n gpu-operator
helm rollback gpu-operator <REVISION> -n gpu-operator
```

For operator-managed driver rollback, patch the previous approved driver
version and monitor the upgrade controller. Do not roll back host drivers
through GPU Operator.

## MIG Change

MIG changes are disruptive. Stop until workload owners approve stopping or
migrating active GPU workloads.

```bash
kubectl patch clusterpolicies.nvidia.com/cluster-policy \
  --type='json' \
  -p='[{"op":"replace","path":"/spec/mig/strategy","value":"single"}]'
kubectl label node <node-name> nvidia.com/mig.config=all-1g.10gb --overwrite
kubectl get node <node-name> -L nvidia.com/mig.config,nvidia.com/mig.config.state
```

Escalate if reboot/drain is needed and not approved.
