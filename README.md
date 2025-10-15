# NVIDIA Cloud Native Technologies Documentation

This is the documentation repository for software under the NVIDIA Cloud Native Technologies umbrella. The tools allow users to
build and run GPU accelerated containers with popular container runtimes such as Docker and orchestration platforms such as Kubernetes.

The product documentation portal can be found at: https://docs.nvidia.com/datacenter/cloud-native/index.html

## Building the Container

This step is optional if your only goal is to build the documentation.
As an alternative to building the container, you can run `docker pull ghcr.io/nvidia/cloud-native-docs:4`.

Refer to <https://gitlab.com/nvidia/cloud-native/cnt-docs/container_registry> to find the most recent tag.

If you change the `Dockerfile`, update `CONTAINER_RELEASE_IMAGE` in the `gitlab-ci.yml` file to the new tag and build the container.
Use the `Dockerfile` in the repository (under the `docker` directory) to generate the custom doc build container.

Refer to <https://github.com/NVIDIA/cloud-native-docs/tags> to find the most recent tag.
1. Build the container:

   ```bash
   git clone https://github.com/NVIDIA/cloud-native-docs.git
   cd cloud-native-docs
   docker build --pull \
     --tag cnt-doc-builder \
     --file docker/Dockerfile .
   ```

1. Run the container from the previous step:

   ```bash
   docker run -it --rm \
     -v $(pwd):/work -w /work \
     cnt-doc-builder \
     bash
   ```

1. Build the docs:

   ```bash
   ./repo docs
   ```

   Alternatively, you can build just one docset, such as `gpu-operator` or `container-toolkit`:

   ```bash
   ./repo docs -p gpu-operator -p openshift
   ```

   You can determine the docsets by viewing the `[repo_docs.projects.<docset-name>]` tables in the `repo.toml` file.
   For the GPU Operator, always build it with the OCP docset as well, as shown in the preceding command.

The resulting HTML pages are located in the `_build/docs/.../latest/` directory of your repository clone.

More information about the `repo docs` command is available from
<http://omniverse-docs.s3-website-us-east-1.amazonaws.com/repo_docs/0.20.3/index.html>.

Also, the Github CI for this project builds the documentation on every merge into the default branch (`main`).
The documentation from the current default branch (`main`) is available at <https://docs.nvidia.com/datacenter/cloud-native/>.
Documentation in the default branch is under development and unstable.

## Checking for Broken Links

Periodically, run a linkcheck build:

```bash
./repo docs -p <docset-name> -b linkcheck
```

To view the targets for `:ref:` and `:doc:` role links, run the following command:

```bash
python3 -m sphinx.ext.intersphinx _build/docs/gpu-operator/latest/objects.inv
```

In all likelihood, you will use `grep` to filter the results.

*Example Output*

```output
supported container runtimes       Supported Container Runtimes     : platform-support.html#supported-container-runtimes
install-gpu-operator               Install NVIDIA GPU Operator      : install-gpu-operator.html
```

If the third column includes a `#`, then use `:ref:`.
Otherwise, use `:doc:`.
In the preceding output, the markup would be as follows:

- ``:ref:`supported container runtimes` ``
- ``:doc:`install-gpu-operator` ``

## Releasing Documentation

### Configuration File Updates

Always update the openshift docset when there is a new gpu-operator docset version.

1. Update the version in `repo.toml`:

   ```diff
   diff --git a/repo.toml b/repo.toml
   index e7cd8db..e091d62 100644
   --- a/repo.toml
   +++ b/repo.toml
   @@ -51,7 +51,7 @@ sphinx_conf_py_extra = """
    docs_root = "${root}/container-toolkit"
    project = "container-toolkit"
    name = "NVIDIA Container Toolkit"
   -version = "1.13.1"
   +version = "NEW_VERSION"
    copyright_start = 2020
   ```

1. Update the version in `<component-name>/versions1.json`:

   ```diff
   diff --git a/container-toolkit/versions1.json b/container-toolkit/versions1.json
   index 95429953..e2738987 100644
   --- a/container-toolkit/versions1.json
   +++ b/container-toolkit/versions1.json
   @@ -1,6 +1,10 @@
    [
      {
        "preferred": "true",
   +    "url": "../1.17.4",
   +    "version": "1.17.4"
   +  },
   +  {
        "url": "../1.17.3",
        "version": "1.17.3"
      },
   ```

   These values control the menu at the bottom of the table of contents and
   whether pages show a warning banner when readers view an older release.
   The warning banner directs readers to the latest version.

   We can prune the list to the six most-recent releases.
   The documentation for the older releases is not removed, readers are just
   less likely to browse the older releases.

### Tagging for Publication

Changes to the default branch are not published on docs.nvidia.com.

Only tags are published to docs.nvidia.com.

1. Create a tag from your commit with the following naming pattern: `<component-name>-v<version>`.

   *Example*

   ```text
   gpu-operator-v23.3.1
   ```

   The first three fields of the semantic version are used.
   For a "do over," push a tag like `gpu-operator-v23.3.1-1`.

   Always tag the openshift docset and for each new gpu-operator docset release.

1. Push the tag to the repository.

CI builds the documentation for the Git ref, for all software components.
However, only the documentation for the `component-name` and specified version is updated on the web.
By default, the documentation for the "latest" URL is updated.

*Example*

<https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/>

If the commit message includes `/not-latest`, then only the documentation in the versioned URL is updated:

<https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/23.3.1/index.html>

## Updating Dependencies

1. Make an update to `docker/Dockerfile` to specify the dependency change.

1. Update `.github/workflows/docs-build.yaml` and increment the `env.TAG` value.

1. Update `.gitlab-ci.yml` and set the same value--prefixed by `ghcr.io...`--in the `variables.BUILDER_IMAGE` field.

1. Optional: [Build the container and docs](#building-the-container) locally and confirm the update works as intended.

1. Open a pull request.

   The pull request builds a commit-specific container and builds the docs from that container.
   Review the preview HTML to confirm the update works as intended.

1. After you merge the pull request, the `docs-build.yaml` action detects that the newly incremented `env.TAG`
   container is not in the registry, builds the container with that tag and pushes it to the GitHub registry.

   When you tag a commit to publish, Github CI pulls image from the `variables.BUILDER_IMAGE` value,
   builds the documentation, and that HTML is delivered to docs.nvidia.com.

## License and Contributing

This documentation repository is licensed under [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Contributions are welcome. Refer to the [CONTRIBUTING.md](https://github.com/NVIDIA/cloud-native-docs/blob/main/CONTRIBUTING.md) document for more
information on guidelines to follow before contributions can be accepted.
