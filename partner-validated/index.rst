.. license-header
  SPDX-FileCopyrightText: Copyright (c) 2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
  SPDX-License-Identifier: Apache-2.0

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

.. headings # #, * *, =, -, ^, "


######################################
About Partner-Validated Configurations
######################################

.. toctree::
   :caption: Partner-Validated Configurations
   :titlesonly:
   :hidden:

   self
   k0rdent.rst
   mirantis-mke.rst

Partner-validated configurations help end users who want to use
NVIDIA GPUs with a Kubernetes-based software stack that is not supported by NVIDIA.

Vendors of Kubernetes-based software stacks can self-validate
the NVIDIA GPU Operator with their software so that they can meet the needs of
their end users.

When a partner self-validates their software with the GPU Operator,
the partner develops the documentation that end users need.
Then the partner and NVIDIA add the information to this document.
End users can read the details about the software versions that are validated,
how to use the GPU Operator with the software stack, and how to report issues.

.. important::

   Partner-validated configurations rely on community support and do not constitute
   enterprise support from NVIDIA AI Enterprise.
   While a partner-validated stack is a necessary first step, it does not guarantee
   an automatic elevation to enterprise support from NVIDIA AI Enterprise at some
   point in the future.


*************************************************
How Partners Contribute a Validated Configuration
*************************************************

You can contact the NVIDIA team by sending an email.
NVIDIA will reach out to set up a meeting to discuss the software stack and any
questions.


************************
What Partners Have to Do
************************

You provide the following:

* Indicate whether you are a CNCF member and whether your software stack is a
  part of the
  `certified Kubernetes software conformance program <https://www.cncf.io/certification/software-conformance/>`_
  from the CNCF.

* Document and contribute the exact software stack that you self-validated.
  Refer to the
  `PARTNER-VALIDATED-TEMPLATE.rst file <https://gitlab.com/NVIDIA/cloud-native/cnt-docs/-/tree/master/partner-validated>`__
  in the ``partner-validated`` directory of the documentation repository as a starting point.
  Open a pull request to the repository with your update.
  Refer to the `CONTRIBUTING.md file <https://gitlab.com/nvidia/cloud-native/cnt-docs/-/blob/master/CONTRIBUTING.md>`__
  in the root directory of the documentation repository for information about contributing documentation.

* Run the self-validated configuration and then share the outcome with NVIDIA by providing
  the output from ``must-gather``.

* Upon request, provide NVIDIA remote access so that the NVIDIA team can perform
  further verification.

* Specify a GitHub user name that NVIDIA can refer to when end users open GitHub issues
  specific to the partner self-validated stack.

Performing the preceding steps is not a guarantee that NVIDIA will include your
self-validated configuration in the GPU Operator documentation.


*****************************
How End Users Receive Support
*****************************

End users receive support from the partner and not from NVIDIA.

If an end user experiences an issue with a partner-validated configuration and the
NVIDIA GPU Operator, the end user works with their partner support contact.

Partners include a Getting Support heading in the documentation they contribute
that includes contact information.


****************************************
How Partners Receive Support from NVIDIA
****************************************

When the partner is not able to resolve an end user issue without the help from NVIDIA,
the partner is responsible to replicate the issue on one of the software stacks that
NVIDIA supports.

The NVIDIA records the
:ref:`gpuop:container-platforms`
in the NVIDIA GPU Operator product documentation.

After the partner records the steps to reproduce the issue on an NVIDIA supported software stack,
the partner can report the issue about the supported software stack in the NVIDIA GPU Operator GitHub repository.

NVIDIA investigates fixing the issue on the supported software stack on a best-effort basis.
After NVIDIA develops and releases the fix for the NVIDIA supported software stack,
the partner validates, and, if necessary, ports the fix to the partner software stack.

In cases where the partner provides software, such as GPU driver images, the partner
provides maintenance and support of the software.
This maintenance and support includes security and bug fixes.


**************************
Frequently Asked Questions
**************************

Will NVIDIA add the partner's software stack to the NVIDIA GPU Operator QA process?
  No, but we advise the customer to include the GPU Operator into the partner's QA process.

Will the partner have to run through the certification for all versions of the partner's software stack?
  Yes, if the partner wants the documentation to include a list of the versions.
  No, if the partner wants to only validate a specific version of the partner's software.

Will there be any legal agreement/MOU associated with these partner-validated configurations?
  No. The partner provides support, and possibly the community, so the main objective
  is having a mutually beneficial partner collaboration.

What happens if the partner wants to remove their contributed documentation?
  The partner will be removed from this documentation as a supported configuration for future releases.
  For previously supported configurations, it is up to the partner to communicate a graceful exit strategy with their end customers.

What happens if the partner requires changes to the NVIDIA GPU Operator that are specific to the partner's software stack?
  The GPU Operator is open source and open to review incoming pull requests.

How are CVE fixes managed for partner software that is used by the NVIDIA GPU Operator?
  The partner is responsible for managing security issues and is advised to proactively notify users of issues and fixes.
  When the partner provides users with software, such as a containerized GPU driver, the partner is responsible for notifying and resolving issues with the container image.
