# NVIDIA Cloud Native Technologies Documentation

This is the documentation repository for software under the NVIDIA Cloud Native Technologies umbrella. The tools allow users to 
build and run GPU accelerated containers with popular container runtimes such as Docker and orchestration platforms such as Kubernetes.

The product documentation portal can be found at: https://docs.nvidia.com/datacenter/cloud-native/index.html

## Building Documentation

Use the `Dockerfile` in the repository (under the ``docker`` directory) to generate the custom doc build container. The `Dockerfile` is based 
off the official `spinhxdoc` container and includes some customizations (e.g. the `sphinx-copybutton`).

```bash
docker build --pull \
    --tag cnt-doc-builder \
    --file docker/Dockerfile .
```
The docs can then be built using the custom doc build container `cnt-doc-builder` from the previous step:

```bash
docker run -it --rm \
    -v <path-to-local-workspace>/cnt-docs:/docs \
    cnt-doc-builder \
    make html
```

The resulting HTML pages are located in the `_build/html` sub-directory of your ``<path-to-local-workspace>/cnt-docs`` directory.

## License and Contributing

This documentation repository is licensed under [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Contributions are welcome. Refer to the [CONTRIBUTING.md](https://gitlab.com/nvidia/cloud-native/cnt-docs/-/blob/master/CONTRIBUTING.md) document for more 
information on guidelines to follow before contributions can be accepted.
