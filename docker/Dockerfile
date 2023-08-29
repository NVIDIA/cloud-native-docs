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
      graphviz \
      imagemagick \
      make \
      curl \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install fonts for blockdiag
#Download IBM Plex
#curl -fOSsL https://github.com/IBM/plex/raw/v5.1.3/IBM-Plex-Mono/fonts/complete/ttf/IBMPlexMono-Regular.ttf
#Download Roboto https://fonts.google.com/specimen/Roboto
COPY assets/*.ttf /usr/share/fonts/truetype/
RUN fc-cache

ENV PM_PACKAGES_ROOT=/var/tmp/packman
COPY . /work
RUN /work/repo docs -p review || true
RUN /work/tools/packman/python.sh -m pip install --no-cache-dir --no-deps -U \
   -t /tmp/extension \
   sphinxcontrib-blockdiag \
   blockdiag \
   funcparserlib \
   Pillow \
   webcolors \
   sphinx-copybutton \
   sphinx-tabs \
   sphinx-reredirects
RUN (cd /tmp/extension; tar cf - . ) | (cd /var/tmp/packman/chk/sphinx/4.5.0.2-py3.7-linux-x86_64/; tar xf -)
RUN rm -rf /work /tmp/extension
