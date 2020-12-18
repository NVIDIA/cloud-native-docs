# Imported from https://hub.docker.com/r/sphinxdoc/sphinx/dockerfile
# maintainer="Sphinx Team <https://www.sphinx-doc.org/>"
# $ docker build --pull \ 
#   --tag ${REGISTRY}/sphinxdoc 
#   --file Dockerfile .
FROM python:3.8-slim
LABEL maintainer="Pramod Ramarao <pramarao@nvidia>"

WORKDIR /docs
RUN apt-get update \
 && apt-get install --no-install-recommends -y \
      graphviz \
      imagemagick \
      make \
      curl \
 && apt-get autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir -U pip
RUN python3 -m pip install --no-cache-dir Sphinx==3.2.1 Pillow
RUN python3 -m pip install --no-cache-dir sphinx-copybutton
RUN python3 -m pip install --no-cache-dir sphinx-tabs

CMD ["make", "html"]
