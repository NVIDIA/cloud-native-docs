<!-- SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved. -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Installing GPU Operator Using the vGPU Driver

## Prerequisites

- A client configuration token has been generated for the client on which the script will install the vGPU guest driver.
  Refer to [Generating a Client Configuration Token](https://docs.nvidia.com/license-system/latest/nvidia-license-system-user-guide/index.html#generating-client-configuration-token)
  in the *NVIDIA License System User Guide* for more information.
- An NGC CLI API key that is used to create an image pull secret.
  The secret is used to pull the prebuilt vGPU driver image from NVIDIA NGC.
  Refer to [Generating Your NGC API Key](https://docs.nvidia.com/ngc/latest/ngc-private-registry-user-guide.html#prug-generating-personal-api-key)
  in the *NVIDIA NGC Private Registry User Guide* for more information.

## Procedure

1. Export the NGC CLI API key and your email address as environment variables:

   ```console
   $ export NGC_API_KEY="M2Vub3QxYmgyZ..."
   $ export NGC_USER_EMAIL="user@example.com"
   ```

1. Go to the
   [NVIDIA GPU Operator - Deploy Installer Script](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/vgpu/resources/gpu-operator-installer-5)
   web page on NVIDIA NGC.

   Click the **File Browser** tab, identify your NVIDIA AI Enterprise release, click ellipses-img, and select **Download File**.

   Copy the downloaded script to the same directory as the client configuration token.

1. Rename the client configuration token that you downloaded to `client_configuration_token.tok`.
   Originally, the client configuration token is named to match the pattern: `client_configuration_token_mm-dd-yyyy-hh-mm-ss.tok`.

1. From the directory that contains the downloaded script and the client configuration token, run the script:

   ```console
   $ bash gpu-operator-nvaie.sh install
   ```
