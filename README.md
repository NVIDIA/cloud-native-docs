# NVIDIA Cloud Native Technologies Documentation

This is the documentation repository for software under the NVIDIA Cloud Native Technologies umbrella. The tools allow users to
build and run GPU accelerated containers with popular container runtimes such as Docker and orchestration platforms such as Kubernetes.

The product documentation portal can be found at: https://docs.nvidia.com/datacenter/cloud-native/index.html

## Building Documentation

Use the `Dockerfile` in the repository (under the ``docker`` directory) to generate the custom doc build container.

1. Build the container:

   ```bash
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

   Alternatively, you can build the docs for just one software component, such as ``gpu-operator``
   or ``container-toolkit``:

   ```bash
   ./repo docs -p gpu-operator
   ```

The resulting HTML pages are located in the `_build/docs/...` directory of your repository clone.

More information about the ``repo docs`` command is available from
<http://omniverse-docs.s3-website-us-east-1.amazonaws.com/repo_docs/0.20.3/index.html>.

Additionally, the Gitlab CI for this project is configured to build and stage the documentation on every commit pushed to Gitlab. The staged documentation should be available to view via [Gitlab Pages](https://docs.gitlab.com/ee/user/project/pages/) for your repository. To find the pages url, visit `Settings > Pages` from the Gitlab UI. The url can also be found at the bottom of the logs for the `build_docs` stage of the CI.

## Releasing Documentation

### Special Branch Naming

CI is under development, but the proposed idea is to perform development updates
in the default branch and to release, create a branch with the following pattern:

   ```text
   <component-name>-v<version>
   ```

   *Example*

   ```text
   gpu-operator-v23.3.1
   ```

When a branch with that name is pushed to the repository, CI builds the documentation
in that branch---currently for all software components.
However, only the documentation for the `component-name` and specified version is
updated on the web.

### Updating for the Latest Release

If documentation for the `version` portion of the branch does not exist, the
documentation is also copied to the `latest` directory.

You can also add a `/latest` comment in your commit message on its own line
to force copying the documentation to the `latest` directory for the component.

## License and Contributing

This documentation repository is licensed under [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Contributions are welcome. Refer to the [CONTRIBUTING.md](https://gitlab.com/nvidia/cloud-native/cnt-docs/-/blob/master/CONTRIBUTING.md) document for more
information on guidelines to follow before contributions can be accepted.
