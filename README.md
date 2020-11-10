# NVIDIA Cloud Native Technologies Documentation

This is the documentation repository for software under the NVIDIA Cloud Native Technologies umbrella. The tools allow users to build and run GPU accelerated containers with popular container runtimes such as Docker and orchestration platforms such as Kubernetes.

## Building Documentation

Use the `Dockerfile` in the repository (under the ``docker`` directory) to generate the custom doc build container. The `Dockerfile` is based 
off the official `spinhxdoc` container and includes some customizations (e.g. the `sphinx-copybutton`).

```console
docker build --pull \
    --tag cnt-doc-builder \
    --file docker/Dockerfile .
```
The docs can then be built using the custom doc build container `cnt-doc-builder` from the previous step:

```console
docker run -it --rm \
    -v <path-to-local-workspace>/cnt-docs:/docs \
    cnd-doc-builder \
    make html
```

The resulting HTML pages are located in the `_build/html` sub-directory of your ``<path-to-local-workspace>/cnt-docs`` directory.
