# NVIDIA Cloud Native Technologies Documentation

This is the documentation repository for software under the NVIDIA Cloud Native Technologies umbrella. The tools allow users to build and run GPU accelerated containers with popular container runtimes such as Docker and orchestration platforms such as Kubernetes.

## Building Documentation

Use the `spinhxdoc` Docker container for building the documentation:

```console
docker run -it --rm -v <path-to-local-workspace>/cnt-docs:/docs sphinxdoc/sphinx make html
```
The resulting HTML pages are located in the `_build/html` directory.