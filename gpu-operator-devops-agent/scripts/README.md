# GPU Operator Script Index

Generated from a curated source manifest. Scripts are
templates for fragile or repeated operations. Read each script before running
it and set the documented environment variables for the target environment.

| path | status | risk | description |
| --- | --- | --- | --- |
| scripts/inventory-gpu-operator-environment.sh | validated-fixture | read-only | Collect read-only GPU Operator deployment inventory before diagnosis. |
| scripts/install-gpu-operator-k3s-host-driver.sh | validated-fixture | high-mutation | Install GPU Operator on K3s with a host-managed driver and explicit K3s toolkit env. |
| scripts/validate-cuda-vectoradd.sh | validated-live | medium-mutation | Run and clean up the CUDA VectorAdd proof workload. |
| scripts/apply-time-slicing.sh | validated-fixture | high-mutation | Apply, verify, and revert a temporary time-slicing example. |
