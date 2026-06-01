<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# MIG Configuration Examples

Throughout, replace `<gpu-operator-version>` with your target GPU Operator release.

## Example: Single MIG Strategy

The following steps show how to use the single MIG strategy and configure the `1g.10gb` profile on one node.

1. Configure the MIG strategy to `single` if you are unsure of the current strategy:

   ```console
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
       --type='json' \
       -p='[{"op":"replace", "path":"/spec/mig/strategy", "value":"single"}]'
   ```

1. Label the nodes with the profile to configure:

   ```console
   $ kubectl label nodes <node-name> nvidia.com/mig.config=all-1g.10gb --overwrite
   ```

   MIG Manager proceeds to apply a `mig.config.state` label to the node and terminates all
   the GPU pods in preparation to enable MIG mode and configure the GPU into the desired MIG geometry.

1. Optional: Display the node labels:

   ```console
   $ kubectl get node <node-name> -o=jsonpath='{.metadata.labels}' | jq .
   ```

   *Partial Output*

   ```json
     "nvidia.com/gpu.product": "NVIDIA-H100-80GB-HBM3",
     "nvidia.com/gpu.replicas": "1",
     "nvidia.com/gpu.sharing-strategy": "none",
     "nvidia.com/mig.capable": "true",
     "nvidia.com/mig.config": "all-1g.10gb",
     "nvidia.com/mig.config.state": "pending",
     "nvidia.com/mig.strategy": "single"
   }
   ```

   When the `WITH_REBOOT` option is set, MIG Manager sets the label to `nvidia.com/mig.config.state: rebooting`.

1. Confirm that MIG Manager completed the configuration by checking the node labels:

   ```console
   $ kubectl get node <node-name> -o=jsonpath='{.metadata.labels}' | jq .
   ```

   Check for the following labels:

   * `nvidia.com/gpu.count: 7` (the value differs according to the GPU model)
   * `nvidia.com/gpu.slices.ci: 1`
   * `nvidia.com/gpu.slices.gi: 1`
   * `nvidia.com/mig.config.state: success`

   *Partial Output*

   ```json
   "nvidia.com/gpu.count": "7",
   "nvidia.com/gpu.present": "true",
   "nvidia.com/gpu.product": "NVIDIA-H100-80GB-HBM3-MIG-1g.10gb",
   "nvidia.com/gpu.slices.ci": "1",
   "nvidia.com/gpu.slices.gi": "1",
   "nvidia.com/mig.capable": "true",
   "nvidia.com/mig.config": "all-1g.10gb",
   "nvidia.com/mig.config.state": "success",
   "nvidia.com/mig.strategy": "single"
   ```

1. Optional: Run the `nvidia-smi` command in the driver container to verify that the MIG configuration has been applied.

   ```console
   $ kubectl exec -it -n gpu-operator ds/nvidia-driver-daemonset -- nvidia-smi -L
   ```

   *Example Output*

## Example: Mixed MIG Strategy

The following steps show how to use the `mixed` MIG strategy and configure the `all-balanced` profile on one node.

1. Configure the MIG strategy to `mixed` if you are unsure of the current strategy:

   ```console
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
       --type='json' \
       -p='[{"op":"replace", "path":"/spec/mig/strategy", "value":"mixed"}]'
   ```

1. Label the nodes with the profile to configure:

   ```console
   $ kubectl label nodes <node-name> nvidia.com/mig.config=all-balanced --overwrite
   ```

   MIG Manager proceeds to apply a `mig.config.state` label to the node and terminates all
   the GPU pods in preparation to enable MIG mode and configure the GPU into the desired MIG geometry.

1. Confirm that MIG Manager completed the configuration by checking the node labels:

   ```console
   $ kubectl get node <node-name> -o=jsonpath='{.metadata.labels}' | jq .
   ```

   Check for labels like the following.
   The profiles and GPU counts differ according to the GPU model.

   * `nvidia.com/mig-1g.10gb.count: 2`
   * `nvidia.com/mig-2g.20gb.count: 1`
   * `nvidia.com/mig-3g.40gb.count: 1`
   * `nvidia.com/mig.config.state: success`

   *Partial Output*

1. Optional: Run the `nvidia-smi` command in the driver container to verify that the GPU has been configured.

   ```console
   $ kubectl exec -it -n gpu-operator ds/nvidia-driver-daemonset -- nvidia-smi -L
   ```

   *Example Output*

## Example: Reconfiguring MIG Profiles

MIG Manager supports dynamic reconfiguration of the MIG geometry.
The following steps show how to update a GPU on a node to the `3g.40gb` profile with the single MIG strategy.

1. Label the node with the profile:

   ```console
   $ kubectl label nodes <node-name> nvidia.com/mig.config=all-3g.40gb --overwrite
   ```

1. Optional: Monitor the MIG Manager logs to confirm the new MIG geometry is applied:

   ```console
   $ kubectl logs -n gpu-operator -l app=nvidia-mig-manager -c nvidia-mig-manager
   ```

   *Example Output*

   ```console
   Applying the selected MIG config to the node
   time="2024-05-14T18:31:26Z" level=debug msg="Parsing config file..."
   time="2024-05-14T18:31:26Z" level=debug msg="Selecting specific MIG config..."
   time="2024-05-14T18:31:26Z" level=debug msg="Running apply-start hook"
   time="2024-05-14T18:31:26Z" level=debug msg="Checking current MIG mode..."
   time="2024-05-14T18:31:26Z" level=debug msg="Walking MigConfig for (devices=all)"
   time="2024-05-14T18:31:26Z" level=debug msg="  GPU 0: 0x233010DE"
   time="2024-05-14T18:31:26Z" level=debug msg="    Asserting MIG mode: Enabled"
   time="2024-05-14T18:31:26Z" level=debug msg="    MIG capable: true\n"
   time="2024-05-14T18:31:26Z" level=debug msg="    Current MIG mode: Enabled"
   time="2024-05-14T18:31:26Z" level=debug msg="Checking current MIG device configuration..."
   time="2024-05-14T18:31:26Z" level=debug msg="Walking MigConfig for (devices=all)"
   time="2024-05-14T18:31:26Z" level=debug msg="  GPU 0: 0x233010DE"
   time="2024-05-14T18:31:26Z" level=debug msg="    Asserting MIG config: map[3g.40gb:2]"
   time="2024-05-14T18:31:26Z" level=debug msg="Running pre-apply-config hook"
   time="2024-05-14T18:31:26Z" level=debug msg="Applying MIG device configuration..."
   time="2024-05-14T18:31:26Z" level=debug msg="Walking MigConfig for (devices=all)"
   time="2024-05-14T18:31:26Z" level=debug msg="  GPU 0: 0x233010DE"
   time="2024-05-14T18:31:26Z" level=debug msg="    MIG capable: true\n"
   time="2024-05-14T18:31:26Z" level=debug msg="    Updating MIG config: map[3g.40gb:2]"
   MIG configuration applied successfully
   time="2024-05-14T18:31:27Z" level=debug msg="Running apply-exit hook"
   Restarting validator pod to re-run all validations
   pod "nvidia-operator-validator-kmncw" deleted
   Restarting all GPU clients previously shutdown in Kubernetes by reenabling their component-specific nodeSelector labels
   node/node-name labeled
   Changing the 'nvidia.com/mig.config.state' node label to 'success'
   ```

1. Optional: Display the node labels to confirm the GPU count (`2`), slices (`3`), and profile are set:

   ```console
   $ kubectl get node <node-name> -o=jsonpath='{.metadata.labels}' | jq .
   ```

   *Partial Output*

   ```json
     "nvidia.com/gpu.count": "2",
     "nvidia.com/gpu.present": "true",
     "nvidia.com/gpu.product": "NVIDIA-H100-80GB-HBM3-MIG-3g.40gb",
     "nvidia.com/gpu.replicas": "1",
     "nvidia.com/gpu.sharing-strategy": "none",
     "nvidia.com/gpu.slices.ci": "3",
     "nvidia.com/gpu.slices.gi": "3",
     "nvidia.com/mig.capable": "true",
     "nvidia.com/mig.config": "all-3g.40gb",
     "nvidia.com/mig.config.state": "success",
     "nvidia.com/mig.strategy": "single",
     "nvidia.com/mps.capable": "false"
   }
   ```

## Example: Custom MIG Configuration During Installation

If you need to use custom profiles, you can create a custom ConfigMap during installation by passing in a name and data for the ConfigMap with the Helm command.

The MIG Manager daemonset is configured to use this ConfigMap instead of the auto-generated one.

In your values.yaml file, set `migManager.config.create` to `true`, set `migManager.config.name`, and add the ConfigMap data under `migManager.config.data`, for example:

1. In your `values.yaml` file, add the data for the ConfigMap, like the following example:

> [!NOTE]
> Custom ConfigMaps must contain a key named "config.yaml"

1. Install or upgrade the GPU Operator with this values file so the chart creates the ConfigMap:

   ```console
   $ helm upgrade --install gpu-operator -n gpu-operator --create-namespace \
       nvidia/gpu-operator --version=<gpu-operator-version> \
       -f values.yaml
   ```

1. If the custom configuration specifies more than one instance profile, set the strategy to `mixed`:

   ```console
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
       --type='json' \
       -p='[{"op":"replace", "path":"/spec/mig/strategy", "value":"mixed"}]'
   ```

1. Label the nodes with the profile to configure:

   ```console
   $ kubectl label nodes <node-name> nvidia.com/mig.config=custom-mig --overwrite
   ```

1. Optional: Monitor the MIG Manager logs to confirm the new MIG geometry is applied:

   ```console
   $ kubectl logs -n gpu-operator -l app=nvidia-mig-manager -c nvidia-mig-manager
   ```

   *Example Output*

   ```console
   Applying the selected MIG config to the node
   time="2024-05-15T13:40:08Z" level=debug msg="Parsing config file..."
   time="2024-05-15T13:40:08Z" level=debug msg="Selecting specific MIG config..."
   time="2024-05-15T13:40:08Z" level=debug msg="Running apply-start hook"
   time="2024-05-15T13:40:08Z" level=debug msg="Checking current MIG mode..."
   time="2024-05-15T13:40:08Z" level=debug msg="Walking MigConfig for (devices=all)"
   time="2024-05-15T13:40:08Z" level=debug msg="  GPU 0: 0x233010DE"
   time="2024-05-15T13:40:08Z" level=debug msg="    Asserting MIG mode: Enabled"
   time="2024-05-15T13:40:08Z" level=debug msg="    MIG capable: true\n"
   time="2024-05-15T13:40:08Z" level=debug msg="    Current MIG mode: Enabled"
   time="2024-05-15T13:40:08Z" level=debug msg="Checking current MIG device configuration..."
   time="2024-05-15T13:40:08Z" level=debug msg="Walking MigConfig for (devices=all)"
   time="2024-05-15T13:40:08Z" level=debug msg="  GPU 0: 0x233010DE"
   time="2024-05-15T13:40:08Z" level=debug msg="    Asserting MIG config: map[1g.10gb:5 2g.20gb:1]"
   time="2024-05-15T13:40:08Z" level=debug msg="Running pre-apply-config hook"
   time="2024-05-15T13:40:08Z" level=debug msg="Applying MIG device configuration..."
   time="2024-05-15T13:40:08Z" level=debug msg="Walking MigConfig for (devices=all)"
   time="2024-05-15T13:40:08Z" level=debug msg="  GPU 0: 0x233010DE"
   time="2024-05-15T13:40:08Z" level=debug msg="    MIG capable: true\n"
   time="2024-05-15T13:40:08Z" level=debug msg="    Updating MIG config: map[1g.10gb:5 2g.20gb:1]"
   time="2024-05-15T13:40:09Z" level=debug msg="Running apply-exit hook"
   MIG configuration applied successfully
   ```

## Example: Custom MIG Configuration

You can create and apply a ConfigMap yourself if the default profiles do not meet your needs.

1. Create a file, such as `custom-mig-config.yaml`, with contents like the following example:

   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: custom-mig-config
   data:
     config.yaml: |
       version: v1
       mig-configs:
         all-disabled:
           - devices: all
             mig-enabled: false

         five-1g-one-2g:
           - devices: all
             mig-enabled: true
             mig-devices:
               "1g.10gb": 5
               "2g.20gb": 1
   ```

> [!NOTE]
> Custom ConfigMaps must contain a key named "config.yaml"

1. Apply the manifest:

   ```console
   $ kubectl apply -n gpu-operator -f custom-mig-config.yaml
   ```

1. If the custom configuration specifies more than one instance profile, set the strategy to `mixed`:

   ```console
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
       --type='json' \
       -p='[{"op":"replace", "path":"/spec/mig/strategy", "value":"mixed"}]'
   ```

1. Patch the cluster policy so MIG Manager uses the custom ConfigMap:

   ```console
   $ kubectl patch clusterpolicies.nvidia.com/cluster-policy \
       --type='json' \
       -p='[{"op":"replace", "path":"/spec/migManager/config/name", "value":"custom-mig-config"}]'
   ```

1. Label the nodes with the profile to configure:

   ```console
   $ kubectl label nodes <node-name> nvidia.com/mig.config=five-1g-one-2g --overwrite
   ```

## Verification: Running Sample CUDA Workloads

After configuring a MIG profile and confirming `nvidia.com/mig.config.state: success`,
deploy a sample CUDA workload that requests a MIG resource to confirm scheduling.
Use the `gpu-operator-install` skill's verification workload (CUDA VectorAdd) as a basis,
requesting the appropriate MIG resource (for example `nvidia.com/mig-1g.10gb`).

## Disabling MIG

You can disable MIG on a node by setting the `nvidia.com/mig.config` label to `all-disabled`:

```console
$ kubectl label nodes <node-name> nvidia.com/mig.config=all-disabled --overwrite
```
