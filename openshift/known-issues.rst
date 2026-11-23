.. Date: November 22 2026
.. Author: nbugrovs

.. headings are # * - =

.. _openshift-known-issues:

#####################################
Known Issues
#####################################

The following issues apply to NVIDIA GPU Operator 26.7.x on Red Hat OpenShift Container Platform.

.. _openshift-known-issues-oc-mirror-quay:

*********************************************************************
``oc-mirror`` fails to mirror the GPU Operator bundle to Red Hat Quay
*********************************************************************

When ``oc-mirror`` mirrors the GPU Operator catalog to a Red Hat Quay registry, copying two images in the Operator bundle fails with the following error:

.. code-block:: output

   [ERROR] : [Worker] error mirroring image docker://nvcr.io/nvidia/cloud-native/<image>@sha256:...
   error: Manifest list must be converted to type "application/vnd.docker.distribution.manifest.list.v2+json"
   to be written to destination, but we cannot modify it: "Instructed to preserve digests"

``oc-mirror`` then omits the GPU Operator bundle from the mirror because one of the related images in the bundle failed to mirror.
The mirrored catalog does not contain an installable GPU Operator.

Two different manifest inconsistencies cause this failure:

* ``dra-driver-nvidia-gpu`` uses the Docker Schema2 manifest format with an uncompressed layer.
  The Docker Schema2 specification defines no uncompressed layer media type, so every Red Hat Quay version rejects it.
* ``gdrdrv``'s OCI image index references Docker Schema2 child manifests.
  Red Hat Quay releases before 3.16.7 and 3.17.0 reject this combination.
  Red Hat Quay 3.17.0 introduced a fix for this as `PROJQUAY-11689 <https://issues.redhat.com/browse/PROJQUAY-11689>`_, documented in the `Red Hat Quay 3.17 release notes <https://docs.redhat.com/en/documentation/red_hat_quay/3.17/html/red_hat_quay_release_notes/release-notes-317>`_.
  Red Hat Quay 3.16.7 backports the same fix as `PROJQUAY-11694 <https://issues.redhat.com/browse/PROJQUAY-11694>`_.
  No earlier release line, including 3.15 and 3.14, received this backport.

Clusters that use the DRA Driver for NVIDIA GPUs have no workaround, because every Red Hat Quay version rejects the uncompressed layer in ``dra-driver-nvidia-gpu``.
The procedure on this page blocks the DRA driver image, so the DRA driver pods cannot start in the disconnected cluster.

Affected images
===============

The GPU Operator bundle lists the following images that fail to mirror to Red Hat Quay:

* ``nvcr.io/nvidia/dra-driver-nvidia-gpu:v0.5.1``
* ``nvcr.io/nvidia/cloud-native/gdrdrv:v2.6-rhel9.6``

Mirror the Operator bundle
==========================

The procedure blocks the two affected images so that ``oc-mirror`` mirrors the rest of the GPU Operator bundle.

#. Add the ``blockedImages`` entries to the ``mirror`` section of the ``ImageSetConfiguration`` file:

   .. code-block:: yaml
      :emphasize-lines: 8-10

      apiVersion: mirror.openshift.io/v2alpha1
      kind: ImageSetConfiguration
      mirror:
        operators:
        - catalog: registry.redhat.io/redhat/certified-operator-index:v<ocp-version>
          packages:
          - name: gpu-operator-certified
        blockedImages:
        - name: 'nvcr[.]io/nvidia/dra-driver-nvidia-gpu.*@sha256:ae591dbc8e630b49181b40dfddf8f0a3f0890b883acb7b2b420f5b207fda253e'
        - name: 'nvcr[.]io/nvidia/cloud-native/gdrdrv@sha256:eef1b6663d78555f0e5c49c156196b67e8a3008bc22aaa02b03dad53887ee0f1'

   .. tip::

      If the mirror registry runs Red Hat Quay 3.16.7, 3.17.0, or later, remove the ``gdrdrv`` entry from ``blockedImages``.

#. Rerun the ``oc-mirror`` command with the updated ``ImageSetConfiguration`` file.

#. Apply the generated ``ImageDigestMirrorSet`` and ``CatalogSource`` resources from the ``working-dir/cluster-resources`` directory:

   .. code-block:: console

      $ oc apply -f <workspace>/working-dir/cluster-resources/idms-oc-mirror.yaml
      $ oc apply -f <workspace>/working-dir/cluster-resources/cs-<catalog>.yaml

#. Install the GPU Operator from the mirrored catalog.

Check an image for manifest problems
====================================

To check an image that fails to mirror, use ``skopeo`` to inspect the image manifests.

#. Display the media type of the top-level manifest:

   .. code-block:: console

      $ skopeo inspect --raw docker://<image-reference> | jq -r .mediaType

#. If the media type is ``application/vnd.oci.image.index.v1+json``, display the media types of the per-architecture manifests:

   .. code-block:: console

      $ skopeo inspect --raw docker://<image-reference> | jq '.manifests[] | {platform, mediaType, digest}'

   A per-architecture media type of ``application/vnd.docker.distribution.manifest.v2+json`` does not match the OCI image index.

#. Display the layer media types of a per-architecture manifest:

   .. code-block:: console

      $ skopeo inspect --raw docker://<image-reference>@<manifest-digest> | jq -r '.layers[].mediaType'

   A layer media type that does not end in ``gzip`` or ``zstd``, such as ``application/vnd.oci.image.layer.v1.tar``, identifies an uncompressed layer.

   An uncompressed layer under an OCI image manifest, ``application/vnd.oci.image.layer.v1.tar``, mirrors without a problem.
   The OCI Image Specification defines this media type.
   An uncompressed layer under a Docker Schema2 manifest, ``application/vnd.docker.image.rootfs.diff.tar``, does not mirror.
   The Docker Image Manifest V2, Schema 2 specification defines no uncompressed layer media type, so registries reject it.

To report an affected image that this page does not list, add the image reference and the ``oc-mirror`` error output to `NVIDIA/gpu-operator#3166 <https://github.com/NVIDIA/gpu-operator/issues/3166>`_.

.. _openshift-known-issues-ocp5-default-driver:

*********************************************************************************************
Default driver container fails on newly installed OpenShift Container Platform 5.0 clusters
*********************************************************************************************

When you install the GPU Operator with the default cluster policy on a newly installed OpenShift Container Platform 5.0 cluster, the ``nvidia-driver-daemonset`` pods fail on the GPU nodes.

Newly installed clusters use RHCOS 10 nodes. A cluster that you upgraded from OpenShift 4.x keeps RHCOS 9 nodes and is not affected.

The GPU Operator bundle pins the default driver container image by digest. The image is based on RHEL 9. The Operator uses a digest-pinned driver image as-is, without per-node operating system tag resolution. The RHEL 9 driver container therefore runs on RHCOS 10 nodes and fails to load kernel modules.

Specify the driver version in the cluster policy
================================================

#. Set ``spec.driver.version`` in the cluster policy to a floating driver version, such as ``${recommended}``. The Operator resolves the operating-system tag for each node and deploys ``${recommended}-rhel10`` on RHCOS 10 nodes:

   .. code-block:: yaml

      driver:
        repository: nvcr.io/nvidia
        image: driver
        version: "${recommended}"

   Alternatively, set the field to the RHEL 10 driver image digest for driver version ``${recommended}``:

   .. code-block:: yaml

      driver:
        repository: nvcr.io/nvidia
        image: driver
        version: "sha256:52b984c00817b08dcf5a0ed50dbba7b9f4d779614bde486a3483a4fb61dea3e5"

#. Verify that the driver daemon set uses the RHEL 10 image:

   .. code-block:: console

      $ oc -n nvidia-gpu-operator get ds -o custom-columns=NAME:.metadata.name,IMAGE:.spec.template.spec.containers[0].image

   *Partial Output*

   .. code-block:: console

      NAME                                       IMAGE
      nvidia-driver-daemonset-10.2.20261015-0    nvcr.io/nvidia/driver:${recommended}-rhel10
