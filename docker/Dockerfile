# Imported from https://hub.docker.com/r/sphinxdoc/sphinx/dockerfile
# maintainer="Sphinx Team <https://www.sphinx-doc.org/>"
# $ docker build --pull \
#   --tag ${REGISTRY}/sphinxdoc
#   --file Dockerfile .
FROM python:3.9-slim
LABEL maintainer="Pramod Ramarao <pramarao@nvidia>"

WORKDIR /docs
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
 && apt-get install --no-install-recommends -y \
      curl \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV PM_PACKAGES_ROOT=/var/tmp/packman
COPY . /work
RUN /work/repo docs -p review || true
RUN /work/tools/packman/python.sh -m pip install --no-cache-dir --no-deps -U \
   -t /tmp/extension \
   sphinx-copybutton
 RUN (cd /tmp/extension; tar cf - . ) | (cd /var/tmp/packman/chk/sphinx/4.5.0.2-py3.7-linux-x86_64/; tar xf -)
RUN rm -rf /work /tmp/extension
