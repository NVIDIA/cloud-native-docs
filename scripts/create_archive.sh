#!/bin/bash

# WARNING: assumes you are running this script from the top-level directory (e.g. scripts/create_archive.sh)
# Example:
# PROJECT=gpu-operator VERSION=1.9.0 ./scripts/create_archive.sh

set -e

PROJECT=${PROJECT:?"Missing PROJECT to archive"}
VERSION=${VERSION:?"Missing VERSION to archive"}
ARCHIVE="${PROJECT}/archive/${VERSION}"

# Create archive directory and copy over all current files/directories, excluding the archive directory itself
rm -rf $ARCHIVE
mkdir -p $ARCHIVE
rsync -aq "${PROJECT}/" $ARCHIVE --exclude "archive/"

# Find all labels in the project documentation and extract the label name.
# Labels are in the format: ".. _label-name:"
labels=$(grep -ohr --include \*.rst ".. _[^:]*" ${ARCHIVE} | cut -c 5- | xargs -n1 | sort | xargs)

# For each label, append a version suffix and update any references to the label.
for label in $labels; do
	echo "Updating all references to label: $label"
	find $ARCHIVE -name "*.rst" -exec sed -i '' "s/.. _${label}/&-${VERSION}/g" {} \;
	find $ARCHIVE -name "*.rst" -exec sed -i '' "s/:ref:\`.*${label}/&-${VERSION}/g" {} \;
done

