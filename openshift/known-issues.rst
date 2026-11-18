.. Date: November 18 2026
.. Author: nbugrovs

.. headings are # * - =

.. _openshift-known-issues:

#####################################
Known Issues
#####################################

This page describes known issues that are specific to running and mirroring the NVIDIA GPU Operator on Red Hat OpenShift Container Platform.

***************************************************************
Disconnected mirroring fails for some GPU Operator images
***************************************************************

Starting with NVIDIA GPU Operator ``v26.7.0``, some published container images had inconsistent manifests.
An image manifest can be inconsistent in two ways:

* A layer is uncompressed instead of gzip-compressed.
* The top-level manifest is an OCI image index, but the per-architecture manifests that it references use the older Docker Schema2 media type instead of the matching OCI media type.

Registries such as Quay validate that a manifest index and its child manifests use a consistent media type.
When an image has one of these inconsistencies, ``oc-mirror`` and ``skopeo`` cannot mirror the image without converting its manifest, which would change the image digest.
Because digest preservation is required for Operator bundles and related images, the mirroring tools refuse to perform this conversion and the mirroring step fails.

The failure looks similar to the following:

.. code-block:: console

   error: Manifest list must be converted to type "application/vnd.docker.distribution.manifest.list.v2+json"
   to be written to destination, but we cannot modify it: "Instructed to preserve digests"

Check whether an image is affected
======================================

Use ``skopeo`` to inspect the top-level manifest type of an image:

.. code-block:: console

   $ skopeo inspect --raw docker://<image-reference> | jq -r .mediaType

If the result is ``application/vnd.oci.image.index.v1+json``, inspect each per-architecture manifest that the index references:

.. code-block:: console

   $ skopeo inspect --raw docker://<image-reference> | jq '.manifests[] | {platform, mediaType, digest}'

If any of the returned ``mediaType`` values is ``application/vnd.docker.distribution.manifest.v2+json``, the index and its children are inconsistent.
To check for uncompressed layers, inspect the referenced manifest directly:

.. code-block:: console

   $ skopeo inspect --raw docker://<image-reference>@<manifest-digest> | jq -r '.layers[].mediaType'

A layer is uncompressed if its media type does not end in ``gzip`` or ``zstd``, for example ``application/vnd.oci.image.layer.v1.tar``.

Status
======================================

NVIDIA GPU Operator ``v26.7.3`` fixes this issue for the GPU Operator image and its core related images, including the NVIDIA Container Toolkit, the NVIDIA Kubernetes Device Plugin, and the NVIDIA MIG Manager.

A small number of other related images referenced by the Operator bundle, such as the NVIDIA Driver Manager, GDRCopy, and the DRA driver for NVIDIA GPUs, keep their existing pinned versions in ``v26.7.3`` to avoid triggering a driver DaemonSet rollout during a patch upgrade.
Refer to `NVIDIA/gpu-operator#3166 <https://github.com/NVIDIA/gpu-operator/issues/3166>`_ for the current status of each affected image and for links to the corrected replacement images as they become available.

Workaround for affected images
======================================

If you deploy the GPU Operator in a disconnected or airgapped environment and mirroring fails for one of the images described in `NVIDIA/gpu-operator#3166 <https://github.com/NVIDIA/gpu-operator/issues/3166>`_, do the following:

#. Add the corrected replacement image to your ``ImageSetConfiguration`` so that ``oc-mirror`` mirrors it to your registry.
#. Override the corresponding image reference, by digest, in ``ClusterPolicy``, ``NVIDIADriver``, or the relevant ``gpu-operator`` deployment environment variable, so that the cluster pulls the mirrored replacement image.

A runtime image override alone does not resolve a mirroring failure, because ``oc-mirror`` mirrors the images listed in the Operator bundle, not the images that a cluster is configured to run.
