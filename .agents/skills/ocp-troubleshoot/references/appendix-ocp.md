# Appendix

<a id="ocp-appendix"></a>

# Appendix

<a id="cluster-entitlement"></a>

## Entitled NVIDIA Driver Builds No Longer Supported

### Introduction

:::{important}
**Entitled NVIDIA driver builds are deprecated and not supported starting with Red Hat OpenShift 4.10.**

The Driver Toolkit (DTK) enables entitlement-free deployments of the GPU Operator. In the past, entitled builds were used pre-DTK and for some OpenShift versions where Driver Toolkit images were broken.

If you encounter the {ref}`"broken driver toolkit detected" <broken-dtk>` warning on OpenShift 4.10 or later, you should {ref}`troubleshoot <broken-dtk-troubleshooting>` to find the root cause instead of falling back to entitled driver builds.

If the broken DTK warning is encountered on an older version of OpenShift, refer to the documentation for an older version of the NVIDIA GPU Operator to enable entitled builds. Keep in mind that older versions of OpenShift might no longer be supported.
:::

<a id="broken-dtk-troubleshooting"></a>

### Troubleshooting Broken Driver Toolkit Errors

The most likely reason for the broken DTK message is Node Feature Discovery (NFD) not working correctly. NFD might be disabled, failing, or not updating the kernel version label for other reasons. Another cause might be a missing or incomplete DTK image stream, for example, because of broken mirroring.

Follow these steps for initial troubleshooting of Node Feature Discovery:

1. **Check Node Feature Discovery (NFD) status:**

   ```console
   $ oc get pods -n openshift-nfd
   ```

   Ensure NFD pods are running and healthy. If NFD is not deployed or is failing, this can cause DTK issues.

2. **Verify kernel version labels are present and correct:**

   ```console
   $ oc get nodes -o jsonpath='{range .items[*]}{.metadata.name}{":\t"}{.metadata.labels.feature\.node\.kubernetes\.io/kernel-version\.full}{"\n"}{end}'
   ```

   Ensure nodes have proper kernel version labels that match the current OpenShift version of the cluster.

3. **Check Driver Toolkit image stream:**

   ```console
   $ oc get -n openshift is/driver-toolkit
   ```

   Verify the driver-toolkit image stream exists and has the correct tags that correspond to the current OpenShift version.

For additional troubleshooting resources:

- [Node Feature Discovery documentation](https://kubernetes-sigs.github.io/node-feature-discovery/).
- [Red Hat Node Feature Discovery Operator documentation](https://docs.openshift.com/container-platform/latest/hardware_enablement/psap-node-feature-discovery-operator.html)
- [OpenShift Driver Toolkit documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/latest/html/specialized_hardware_and_driver_enablement/driver-toolkit)
- [OpenShift Driver Toolkit GitHub repository](https://github.com/openshift/driver-toolkit/)
- [OpenShift troubleshooting guide](https://docs.openshift.com/container-platform/latest/support/troubleshooting/)
