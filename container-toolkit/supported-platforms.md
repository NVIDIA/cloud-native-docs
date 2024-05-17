% Date: August 10 2020

% Author: pramarao

(supported-platforms)=

# Supported Platforms

```{contents}
---
depth: 2
local: true
backlinks: none
---
```

## Linux Distributions

The NVIDIA Container Toolkit has been qualified against the following platforms.

Note that the installation packages are generally forward-compatible and the
omission of newer distributions from this list below does not indicate that the
NVIDIA Container Toolkit cannot be used there. Specific issues with newer
distributions should be reported.

| OS Name / Version        | amd64 / x86_64 | ppc64le | arm64 / aarch64 |
| ------------------------ | -------------- | ------- | --------------- |
| Amazon Linux 2023        | X              |         | X {sup}`1`      |
| Amazon Linux 2           | X              |         | X               |
| Open Suse/SLES 15.x      | X              |         |                 |
| Debian Linux 10          | X              |         |                 |
| Debian Linux 11          | X              |         |                 |
| Centos 7                 | X              | X       |                 |
| Centos 8                 | X              | X       | X               |
| RHEL 7.x                 | X              | X       |                 |
| RHEL 8.x                 | X              | X       | X               |
| RHEL 9.x                 | X              | X       | X               |
| Ubuntu 18.04             | X              | X       | X               |
| Ubuntu 20.04             | X              | X       | X               |
| Ubuntu 22.04             | X              | X       | X               |

The `arm64` / `aarch64` architecture includes support for Tegra-based systems.

1. For Amazon Linux 2023 on Arm64, a `g5g.2xlarge` Amazon EC2 instance was used for validation.
   The `g5g.xlarge` instance caused failures due to the limited system memory.


