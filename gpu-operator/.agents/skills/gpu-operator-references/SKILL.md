---
name: "gpu-operator-references"
description: "Loads NVIDIA GPU Operator reference material on demand: overview, security, life-cycle policy, platform support, release notes, troubleshooting, and confidential-containers deployment. Use when users ask conceptual or reference questions about the GPU Operator that are not tied to a specific install or upgrade flow."
triggers:
  - GPU Operator overview
  - platform support
  - release notes
  - life cycle policy
  - security considerations
  - troubleshooting
  - Confidential Containers
tags:
  - gpu-operator
  - nvidia
  - kubernetes
  - gpu
  - reference
  - overview
  - troubleshooting
---

<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# GPU Operator References

## References

- **Load [references/confidential-containers-deploy.md](references/confidential-containers-deploy.md)** when users ask about confidential GPU workloads or Confidential Containers with the GPU Operator. Points users to the Confidential Containers reference architecture and deployment documentation.
- **Load [references/overview.md](references/overview.md)** when users ask for a GPU Operator overview or documentation orientation. Explains what the NVIDIA GPU Operator is, which components it manages, and how it automates GPU node provisioning.
- **Load [references/security.md](references/security.md)** when reviewing security posture, vulnerability exposure, or operator namespace access. Explains GPU Operator security considerations, elevated privileges, and known CVEs.
- **Load [references/life-cycle-policy.md](references/life-cycle-policy.md)** when users ask about release support windows, maintenance, or version lifecycle. Explains the GPU Operator life cycle and support policy.
- **Load [references/platform-support.md](references/platform-support.md)** when checking compatibility before installation or upgrade. Lists supported Kubernetes platforms, operating systems, container runtimes, and GPU Operator configurations.
- **Load [references/release-notes.md](references/release-notes.md)** when users ask what changed, which component versions are included, or whether a release contains a fix. Includes release notes and component version information for the NVIDIA GPU Operator.
- **Load [references/troubleshooting.md](references/troubleshooting.md)** when diagnosing failed pods, driver problems, validator failures, or GPU workload issues. Provides troubleshooting steps for GPU Operator installation and runtime issues.
