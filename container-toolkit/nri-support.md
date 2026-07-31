(nri-support)=

# Support for Node Resource Interface

## About the NRI Plugin

The NVIDIA Container Toolkit container can run a Node Resource Interface (NRI)
plugin. The plugin connects to an NRI-enabled container runtime and adds
Container Device Interface (CDI) device requests to container configurations.
This path is useful when the runtime cannot process the original CDI request
directly.

The plugin enforces different namespace rules for workload and management
devices:

- The plugin can inject ordinary workload devices, such as `nvidia.com/gpu`,
  into containers in any namespace.
- The plugin injects `management.nvidia.com/gpu` devices only into the toolkit
  namespace or an additional namespace that an administrator explicitly
  authorizes.

## Enabling the NRI Plugin

The container runtime must have NRI enabled, and the toolkit container must have
access to the runtime's NRI socket. Keep the toolkit installer running as a
daemon. The `--enable-nri-plugin` option is ignored when `--no-daemon` is set.

Add the following options to the toolkit container entry point:

```console
$ nvidia-ctk-installer \
    --enable-nri-plugin \
    --nri-namespace=nvidia-gpu-operator
```

The `--nri-namespace` value must match the Kubernetes namespace that contains
the toolkit pod. Use `--nri-socket` if the runtime exposes the NRI socket at a
nondefault path.

You can configure the same settings with environment variables:

```yaml
env:
  - name: ENABLE_NRI_PLUGIN
    value: "true"
  - name: NRI_NAMESPACE
    valueFrom:
      fieldRef:
        fieldPath: metadata.namespace
```

## Authorizing Management Devices in Additional Namespaces

Use `--nri-management-cdi-device-namespaces` to allow a namespace to receive
management CDI devices. You can repeat the option. The toolkit namespace is
always allowed and does not need to appear in the list.

The following example authorizes management devices in two additional
namespaces:

```console
$ nvidia-ctk-installer \
    --enable-nri-plugin \
    --nri-namespace=nvidia-gpu-operator \
    --nri-management-cdi-device-namespaces=gpu-monitoring \
    --nri-management-cdi-device-namespaces=gpu-diagnostics
```

For a container deployment, the equivalent environment variable accepts a
comma-separated list:

```yaml
env:
  - name: NRI_MANAGEMENT_CDI_DEVICE_NAMESPACES
    value: "gpu-monitoring,gpu-diagnostics"
```

Namespace matching is exact. Wildcards are not supported. Allow only namespaces
that contain trusted management workloads. A management CDI device can provide
broader access than an ordinary workload device, so follow the principle of
least privilege.
