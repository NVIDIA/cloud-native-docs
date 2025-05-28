# Imported from https://hub.docker.com/r/sphinxdoc/sphinx/dockerfile
# maintainer="Sphinx Team <https://www.sphinx-doc.org/>"
# $ docker build --pull \
#   --tag ${REGISTRY}/sphinxdoc
#   --file Dockerfile .
FROM python:3.10-slim

WORKDIR /docs
RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
 && apt-get install --no-install-recommends -y \
      curl \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV PM_PACKAGES_ROOT=/var/tmp/packman

RUN --mount=type=bind,source=.,destination=/x,rw /x/repo docs -p review || true

RUN --mount=type=bind,source=.,destination=/x,rw /x/tools/packman/python.sh -m pip install --no-cache-dir --no-deps -U \
   -t /tmp/extension \
   sphinx-copybutton \
   nvidia-sphinx-theme \
   pydata-sphinx-theme

RUN (cd /tmp/extension; tar cf - . ) | (cd /var/tmp/packman/chk/sphinx/4.5.0.2-py3.7-linux-x86_64/; tar xf -)
RUN rm -rf /tmp/extension
