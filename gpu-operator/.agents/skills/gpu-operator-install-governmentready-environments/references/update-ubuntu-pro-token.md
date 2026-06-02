<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Update Ubuntu Pro Token in ClusterPolicy

You can update your Ubuntu Pro Token after installation by editing your Ubuntu Pro Token secret.
This secret name is set as value of `driver.secretEnv` of the GPU Operator ClusterPolicy.

Edit your Ubuntu Pro Token secret.

```console
$ kubectl edit secrets <ubuntu-fips-secret>
```

Then update the secret with your new Ubuntu Pro Token.
This token is required for the driver container to download kernel headers and other necessary packages from the Canonical repository when using the FIPS-enabled kernel on Ubuntu 24.04.
