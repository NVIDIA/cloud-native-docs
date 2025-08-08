#!/bin/bash

# Function to print usage
print_usage() {
    echo "Usage: $0 <component-name> <new-version>"
    echo "Example: $0 container-toolkit 1.17.9"
    exit 1
}

# Check if yq is installed
check_yq() {
    if ! command -v yq &> /dev/null; then
        echo "Error: yq is not installed"
        echo "Please install yq first. On macOS, you can use: brew install yq"
        exit 1
    fi
}

# Validate input parameters
if [[ $# -ne 2 ]]; then
    print_usage
fi

COMPONENT="$1"
NEW_VERSION="$2"

# Check if yq is available
check_yq

# Validate component exists both as a directory and in repo.toml
if [[ ! -d "$COMPONENT" ]]; then
    echo "Error: Component directory '${COMPONENT}' not found"
    exit 1
fi

# Check if the version field exists and get current version
CURRENT_VERSION=$(yq ".repo_docs.projects.${COMPONENT}.version" repo.toml)
if [[ "$CURRENT_VERSION" == "null" ]]; then
    echo "Error: Component '${COMPONENT}' version field not found in repo.toml"
    exit 1
fi

# Update versions.json if it exists
VERSIONS_JSON="$COMPONENT/versions.json"
if [[ -f "$VERSIONS_JSON" ]]; then
    echo "Updating $VERSIONS_JSON..."
    yq -p=json -o=json -i '. = [{"preferred": "true", "url": "../'"${NEW_VERSION}"'", "version": "'"${NEW_VERSION}"'"}] + [(.[0] | del(.preferred))] + .[1:]' "$VERSIONS_JSON"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to update $VERSIONS_JSON"
        exit 1
    fi
fi

# Update version in repo.toml using sed
echo "Updating version in repo.toml..."
# Remove quotes from current version for sed
CURRENT_VERSION=${CURRENT_VERSION//\"/}
if [[ $(uname) == "Darwin" ]]; then
    # macOS requires an empty string for -i
    sed -i '' "s/version = \"${CURRENT_VERSION}\"/version = \"${NEW_VERSION}\"/" repo.toml
else
    # Linux version of sed
    sed -i "s/version = \"${CURRENT_VERSION}\"/version = \"${NEW_VERSION}\"/" repo.toml
fi

if [[ $? -ne 0 ]]; then
    echo "Error: Failed to update repo.toml"
    exit 1
fi

echo "Successfully updated version to ${NEW_VERSION} for ${COMPONENT}"