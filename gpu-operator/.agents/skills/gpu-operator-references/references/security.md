<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->
# Security Considerations

## Pod Security Context of the Operator and Operands

Several of the NVIDIA GPU Operator operands, such as the driver containers and container toolkit,
require the following elevated privileges:

- `privileged: true`
- `hostPID: true`
- `hostIPC: true`

The elevated privileges are required for the following reasons:

- Access to the host file system and hardware devices, such as NVIDIA GPUs.
- Restart system services such as containerd.
- Loading and unloading kernel modules.

Only the Kubernetes cluster administrator needs to access or manage the Operator namespace.
As a best practice, establish proper security policies and prevent any other users from accessing the Operator namespace.

## CVEs

The following is a list of known CVEs in the GPU Operator or its operands.
To view any published security bulletins for NVIDIA products, refer to the NVIDIA product security page at https://www.nvidia.com/en-us/security/.

| CVE ID | Affected Components | Fixed Version |
| --- | --- | --- |
| [NVIDIA CVE-2025-23359](https://nvidia.custhelp.com/app/answers/detail/a_id/5616) | NVIDIA Container Toolkit, all versions up to and including 1.17.3 NVIDIA GPU Operator, all versions up to and including 24.9.1 | NVIDIA Container Toolkit 1.17.4 NVIDIA GPU Operator 24.9.2 |
| [NVIDIA CVE-2024-0135](https://nvidia.custhelp.com/app/answers/detail/a_id/5599) | NVIDIA Container Toolkit, all versions up to and including 1.17.2 NVIDIA GPU Operator, all versions up to and including 24.9.0 | NVIDIA Container Toolkit 1.17.3 NVIDIA GPU Operator 24.9.1 |
| [NVIDIA CVE-2024-0136](https://nvidia.custhelp.com/app/answers/detail/a_id/5599) | NVIDIA Container Toolkit, all versions up to and including 1.17.2 NVIDIA GPU Operator, all versions up to and including 24.9.0 | NVIDIA Container Toolkit 1.17.3 NVIDIA GPU Operator 24.9.1 |
| [NVIDIA CVE-2024-0137](https://nvidia.custhelp.com/app/answers/detail/a_id/5599) | NVIDIA Container Toolkit, all versions up to and including 1.17.2 NVIDIA GPU Operator, all versions up to and including 24.9.0 | NVIDIA Container Toolkit 1.17.3 NVIDIA GPU Operator 24.9.1 |
| [NVIDIA CVE-2024-0134](https://nvidia.custhelp.com/app/answers/detail/a_id/5585) | NVIDIA Container Toolkit, all versions up to and including 1.16.2 NVIDIA GPU Operator, all versions up to and including 24.6.2 | NVIDIA Container Toolkit 1.17.0 NVIDIA GPU Operator 24.9.0 |
| [NVIDIA CVE-2024-0132](https://nvidia.custhelp.com/app/answers/detail/a_id/5582) | NVIDIA Container Toolkit, all versions up to and including 1.16.1 NVIDIA GPU Operator, all versions up to and including 24.6.1 | NVIDIA Container Toolkit 1.16.2 NVIDIA GPU Operator 24.6.2 |
| [NVIDIA CVE-2024-0133](https://nvidia.custhelp.com/app/answers/detail/a_id/5582) | NVIDIA Container Toolkit, all versions up to and including 1.16.1 NVIDIA GPU Operator, all versions up to and including 24.6.1 | NVIDIA Container Toolkit 1.16.2 NVIDIA GPU Operator 24.6.2 |
### Report a Vulnerability

For details on reporting a suspected vulnerability, refer to the  [GPU Operator Security policies](https://github.com/NVIDIA/gpu-operator/blob/main/SECURITY.md/) page.
