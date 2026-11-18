.. Date: November 18 2026
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

When ``oc-mirror`` mirrors the GPU Operator catalog to a Red Hat Quay registry, copying three images in the Operator bundle fails with the following error:

.. code-block:: output

   [ERROR] : [Worker] error mirroring image docker://nvcr.io/nvidia/cloud-native/<image>@sha256:...
   error: Manifest list must be converted to type "application/vnd.docker.distribution.manifest.list.v2+json"
   to be written to destination, but we cannot modify it: "Instructed to preserve digests"

``oc-mirror`` then omits the GPU Operator bundle from the mirror because one of the related images in the bundle failed to mirror.
The mirrored catalog does not contain an installable GPU Operator.

Clusters that use the DRA Driver for NVIDIA GPUs have no workaround.
The procedure on this page blocks the DRA driver image, so the DRA driver pods cannot start in the disconnected cluster.

Affected images
===============

The GPU Operator bundle lists the following images that fail to mirror to Red Hat Quay:

* ``nvcr.io/nvidia/cloud-native/k8s-driver-manager:v0.12.1``
* ``nvcr.io/nvidia/dra-driver-nvidia-gpu:v0.5.1``
* ``nvcr.io/nvidia/cloud-native/gdrdrv``

Mirror the Operator bundle
==========================

The procedure blocks the affected images and adds the replacement driver manager image.

#. Add the ``blockedImages`` and ``additionalImages`` entries to the ``mirror`` section of the ``ImageSetConfiguration`` file:

   .. code-block:: yaml
      :emphasize-lines: 8-13

      apiVersion: mirror.openshift.io/v2alpha1
      kind: ImageSetConfiguration
      mirror:
        operators:
        - catalog: registry.redhat.io/redhat/certified-operator-index:v<ocp-version>
          packages:
          - name: gpu-operator-certified
        additionalImages:
        - name: nvcr.io/nvidia/cloud-native/k8s-driver-manager:v0.13.0@sha256:c48dd0248777af64a4c1059982eafc5b0fc28ec2d98995c407af2b1bd8449fc3
        blockedImages:
        - name: 'nvcr[.]io/nvidia/cloud-native/k8s-driver-manager.*@sha256:37e6bf0cf02b5888288a173353b858da8823cc9f9fb9c6e8d6d1e2cf5bfb16c8'
        - name: 'nvcr[.]io/nvidia/dra-driver-nvidia-gpu.*@sha256:ae591dbc8e630b49181b40dfddf8f0a3f0890b883acb7b2b420f5b207fda253e'
        - name: 'nvcr[.]io/nvidia/cloud-native/gdrdrv@sha256:eef1b6663d78555f0e5c49c156196b67e8a3008bc22aaa02b03dad53887ee0f1'

   .. tip::

      If the mirror registry is Project Quay 3.17.3, remove the ``gdrdrv`` entry from ``blockedImages``.

#. Rerun the ``oc-mirror`` command with the updated ``ImageSetConfiguration`` file.

#. Apply the generated ``ImageDigestMirrorSet`` and ``CatalogSource`` resources from the ``working-dir/cluster-resources`` directory:

   .. code-block:: console

      $ oc apply -f <workspace>/working-dir/cluster-resources/idms-oc-mirror.yaml
      $ oc apply -f <workspace>/working-dir/cluster-resources/cs-<catalog>.yaml

#. Install the GPU Operator from the mirrored catalog.

#. Specify the replacement driver manager image by digest in the ``ClusterPolicy`` resource.
   The ``ImageDigestMirrorSet`` resource from ``oc-mirror`` redirects pulls by digest to the mirror registry.

   .. code-block:: yaml

      spec:
        driver:
          manager:
            repository: nvcr.io/nvidia/cloud-native
            image: k8s-driver-manager
            version: sha256:c48dd0248777af64a4c1059982eafc5b0fc28ec2d98995c407af2b1bd8449fc3

   If the cluster runs the NVIDIA vGPU Manager or the NVIDIA VFIO Manager, set the same ``repository``, ``image``, and ``version`` values in ``spec.vgpuManager.driverManager``, ``spec.vfioManager``, and ``spec.vfioManager.driverManager``.
   If the cluster uses ``NVIDIADriver`` resources, set the same values in ``spec.manager`` of each ``NVIDIADriver`` resource.

   Changing the driver manager image on a running cluster triggers a driver upgrade on each node and can evict GPU workloads.
   Refer to :external+gpuop:ref:`changing the driver manager image <v26.7.3-driver-manager-override>` in the GPU Operator release notes.

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

To report an affected image that this page does not list, add the image reference and the ``oc-mirror`` error output to `NVIDIA/gpu-operator#3166 <https://github.com/NVIDIA/gpu-operator/issues/3166>`_.
