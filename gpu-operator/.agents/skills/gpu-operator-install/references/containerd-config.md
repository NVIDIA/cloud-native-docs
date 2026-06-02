<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Specifying Configuration Options for containerd

Throughout, replace `<gpu-operator-version>` with your target GPU Operator release.

> [!NOTE]
> It's recommended that you enable the NRI Plugin to configure the container runtime by setting `cdi.nriPluginEnabled=true`.
> When enabled, you do not need to specify the `toolkit.env` options and injecting GPUs into workload containers is handled by the NRI Plugin.
> Refer to the Container Device Interface and NRI page (use the `gpu-operator-container-device` skill) for more information.
> When you use containerd as the container runtime, the following configuration
> options are used with the container-toolkit deployed with GPU Operator:

```yaml
toolkit:
   env:
   - name: CONTAINERD_CONFIG
     value: /etc/containerd/config.toml
   - name: CONTAINERD_SOCKET
     value: /run/containerd/containerd.sock
   - name: RUNTIME_CONFIG_SOURCE
     value: "command,file"
```

If you need to specify custom values, refer to the following sample command for the syntax:

```console
helm install gpu-operator -n gpu-operator --create-namespace \
  nvidia/gpu-operator $HELM_OPTIONS \
    --version=<gpu-operator-version> \
    --set toolkit.env[0].name=CONTAINERD_CONFIG \
    --set toolkit.env[0].value=/etc/containerd/containerd.toml \
    --set toolkit.env[1].name=CONTAINERD_SOCKET \
    --set toolkit.env[1].value=/run/containerd/containerd.sock \
    --set toolkit.env[2].name=RUNTIME_CONFIG_SOURCE \
    --set toolkit.env[2].value="command,file"
```

These options are defined as follows:

CONTAINERD_CONFIG
  The path on the host to the top-level `containerd` config file.
  By default this will point to `/etc/containerd/containerd.toml`
  (the default location for `containerd`). It should be customized if your `containerd`
  installation is not in the default location.

CONTAINERD_SOCKET
  The path on the host to the socket file used to
  communicate with `containerd`. The operator will use this to send a
  `SIGHUP` signal to the `containerd` daemon to reload its config. By
  default this will point to `/run/containerd/containerd.sock`
  (the default location for `containerd`). It should be customized if
  your `containerd` installation is not in the default location.

RUNTIME_CONFIG_SOURCE
  The config source(s) that the container-toolkit uses when fetching
  the current containerd configuration. A valid value for this setting is any
  combination of [command | file]. By default this will be configured as
  "command,file" which means the container-toolkit will attempt to fetch
  the configuration using the containerd CLI before falling back to reading the
  config from the top-level `containerd` config file (configured using
  CONTAINERD_CONFIG). When `file` is specified, the absolute path to the file
  to be used as a config source can be specified as `file=/path/to/source/config.toml`

RUNTIME_DROP_IN_CONFIG
  The path on the host where the NVIDIA-specific drop-in config file
  will be created. By default this will point to `/etc/containerd/conf.d/99-nvidia.toml`.

## Rancher Kubernetes Engine 2

For Rancher Kubernetes Engine 2 (RKE2), refer to
[Deploy NVIDIA Operator](https://docs.rke2.io/add-ons/gpu_operators#deploy-nvidia-operator)
in the RKE2 documentation.

It's recommended that you enable CDI (default) and the NRI Plugin on RKE.
With both features enabled, you do not need to set `runtimeClassName: nvidia` in your pod spec.

Refer to the [v24.9.0 known limitations](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/release-notes.html) in the release notes.

## MicroK8s

For MicroK8s, set the following in the `ClusterPolicy`.

```yaml
toolkit:
   env:
   - name: CONTAINERD_CONFIG
     value: /var/snap/microk8s/current/args/containerd-template.toml
   - name: CONTAINERD_SOCKET
     value: /var/snap/microk8s/common/run/containerd.sock
   - name: RUNTIME_CONFIG_SOURCE
     value: "file=/var/snap/microk8s/current/args/containerd.toml"
```

These options can be passed to GPU Operator during install time as below.

```console
helm install gpu-operator -n gpu-operator --create-namespace \
  nvidia/gpu-operator $HELM_OPTIONS \
    --version=<gpu-operator-version> \
    --set toolkit.env[0].name=CONTAINERD_CONFIG \
    --set toolkit.env[0].value=/var/snap/microk8s/current/args/containerd-template.toml \
    --set toolkit.env[1].name=CONTAINERD_SOCKET \
    --set toolkit.env[1].value=/var/snap/microk8s/common/run/containerd.sock \
    --set toolkit.env[2].name=RUNTIME_CONFIG_SOURCE \
    --set-string toolkit.env[2].value=file=/var/snap/microk8s/current/args/containerd.toml
```

## Installation on Commercially Supported Kubernetes Platforms

| Product | Documentation |
| --- | --- |
| Red Hat OpenShift 4 using RHCOS worker nodes | [NVIDIA GPU Operator on Red Hat OpenShift](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/index.html) |
| VMware vSphere Kubernetes Service and NVIDIA AI Enterprise | [NVIDIA AI Enterprise VMware vSphere Deployment Guide](https://docs.nvidia.com/ai-enterprise/deployment-guide-vmware/0.1.0/index.html) |
| Google Cloud Anthos | [Google Cloud Anthos guide](https://docs.nvidia.com/datacenter/cloud-native/edge/latest/anthos-guide.html) |
