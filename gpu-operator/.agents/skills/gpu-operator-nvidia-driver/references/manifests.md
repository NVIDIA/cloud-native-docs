<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Sample NVIDIA Driver Manifests

## One Driver Type and Version on All Nodes

1. Optional: Remove previously applied node labels.

1. Create a file, such as `nvd-all.yaml`, with contents like the following:

   ```yaml
   apiVersion: nvidia.com/v1alpha1
   kind: NVIDIADriver
   metadata:
     name: nvidiadriver-sample
   spec:
     # use pre-compiled packages for NVIDIA driver installation.
     usePrecompiled: false
     driverType: gpu
     repository: nvcr.io/nvidia
     image: driver
     version: "580.126.20"
     imagePullPolicy: IfNotPresent
     imagePullSecrets: []
     nodeSelector: {}
     manager: {}
     rdma:
       enabled: false
       useHostMofed: false
     gds:
       enabled: false
     # Private mirror repository configuration
     repoConfig:
       name: ""
     # custom ssl key/certificate configuration
     certConfig:
       name: ""
     # vGPU licensing configuration
     licensingConfig:
       secretName: ""
       nlsEnabled: true
     # vGPU topology daemon configuration
     virtualTopologyConfig:
       name: ""
     # kernel module configuration for NVIDIA driver
     kernelModuleConfig:
       name: ""
   ```

1. Apply the manifest:

   ```console
   $ kubectl apply -n gpu-operator -f nvd-all.yaml
   ```

1. Optional: Monitor the progress:

   ```console
   $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'
   ```

## Multiple Driver Versions

1. Label the nodes.

   - On some nodes, apply a label like the following:

     ```console
     $ kubectl label node <node-name> --overwrite driver.config="gold"
     ```

   - On other nodes, apply a label like the following:

     ```console
     $ kubectl label node <node-name> --overwrite driver.config="silver"
     ```

1. Create a file, such as `nvd-driver-multiple.yaml`, with contents like the following:

   ```yaml
   apiVersion: nvidia.com/v1alpha1
   kind: NVIDIADriver
   metadata:
     name: demo-gold
   spec:
     driverType: gpu
     env: []
     image: driver
     imagePullPolicy: IfNotPresent
     imagePullSecrets: []
     manager: {}
     nodeSelector:
       driver.config: "gold"
     repository: nvcr.io/nvidia
     version: "580.126.20"
   ---
   apiVersion: nvidia.com/v1alpha1
   kind: NVIDIADriver
   metadata:
     name: demo-silver
   spec:
     driverType: gpu
     env: []
     image: driver
     imagePullPolicy: IfNotPresent
     imagePullSecrets: []
     manager: {}
     nodeSelector:
       driver.config: "silver"
     repository: nvcr.io/nvidia
     version: "470.141.10"
   ```

1. Apply the manifest:

   ```console
   $ kubectl apply -n gpu-operator -f nvd-driver-multiple.yaml
   ```

1. Optional: Monitor the progress:

   ```console
   $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'
   ```

## One Precompiled Driver Container on All Nodes

1. Optional: Remove previously applied node labels.

1. Create a file, such as `nvd-precompiled-all.yaml`, with contents like the following:

   ```yaml
   apiVersion: nvidia.com/v1alpha1
   kind: NVIDIADriver
   metadata:
     name: demo-precomp-all
   spec:
     driverType: gpu
     env: []
     image: driver
     imagePullPolicy: IfNotPresent
     imagePullSecrets: []
     manager: {}
     nodeSelector: {}
     repository: nvcr.io/nvidia
     resources: {}
     usePrecompiled: true
     version: "580"
   ```

   > [!TIP]
   > Because the manifest does not include a `nodeSelector` field, the driver custom
   > resource selects all nodes in the cluster that have an NVIDIA GPU.

   1. Apply the manifest:

   ```console
   $ kubectl apply -n gpu-operator -f nvd-precompiled-all.yaml
   ```

1. Optional: Monitor the progress:

   ```console
   $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'
   ```

## Precompiled Driver Container on Some Nodes

1. Label the nodes like the following sample:

   ```console
   $ kubectl label node <node-name> --overwrite driver.precompiled="true"
   $ kubectl label node <node-name> --overwrite driver.version="580"
   ```

1. Create a file, such as `nvd-precompiled-some.yaml`, with contents like the following:

   ```yaml
   apiVersion: nvidia.com/v1alpha1
   kind: NVIDIADriver
   metadata:
     name: demo-precomp
   spec:
     driverType: gpu
     env: []
     image: driver
     imagePullPolicy: IfNotPresent
     imagePullSecrets: []
     manager: {}
     nodeSelector:
       driver.precompiled: "true"
       driver.version: "580"
     repository: nvcr.io/nvidia
     resources: {}
     usePrecompiled: true
     version: "580"
   ```

1. Apply the manifest:

   ```console
   $ kubectl apply -n gpu-operator -f nvd-precompiled-some.yaml
   ```

1. Optional: Monitor the progress:

   ```console
   $ kubectl get events -n gpu-operator --sort-by='.lastTimestamp'
   ```
