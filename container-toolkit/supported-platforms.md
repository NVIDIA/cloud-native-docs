% Date: August 10 2020

% Author: pramarao

(supported-platforms)=

# Platform support

Recent NVIDIA Container Toolkit releases are tested and expected to work on these Linux distributions:

| OS Name / Version        | amd64 / x86_64 | ppc64le | arm64 / aarch64 {sup}`1` |
| ------------------------ | -------------- | ------- | ------------------------ |
| Amazon Linux 2023        | X              |         | X {sup}`2`               |
| Amazon Linux 2           | X              |         | X                        |
| Open Suse/SLES 15.x      | X              |         |                          |
| Debian Linux 11          | X              |         |                          |
| CentOS 8                 | X              | X       | X                        |
| RHEL 8.x                 | X              | X       | X                        |
| RHEL 9.x                 | X              | X       | X                        |
| RHEL 10.x                | X              | X       | X                        |
| Ubuntu 20.04             | X              | X       | X                        |
| Ubuntu 22.04             | X              | X       | X                        |
| Ubuntu 24.04             | X              |         | X                        |


## Report issues

Our qualification-testing procedures are constantly evolving and we might miss
certain problems. [Report](https://github.com/NVIDIA/nvidia-container-toolkit/issues) issues in
particular as they occur on a platform listed above.


## Other Linux distributions

Releases may work on more platforms than indicated in the table above (such as on distribution versions older and newer than listed).
Give things a try and we invite you to [report](https://github.com/NVIDIA/nvidia-container-toolkit/issues) any issue observed even if your Linux distribution is not listed.

----

1. The `arm64` / `aarch64` architecture includes support for Tegra-based systems.
2. For Amazon Linux 2023 on Arm64, a `g5g.2xlarge` Amazon EC2 instance was used for validation.
   The `g5g.xlarge` instance caused failures due to the limited system memory.
