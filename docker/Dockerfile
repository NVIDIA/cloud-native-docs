# Imported from https://hub.docker.com/r/sphinxdoc/sphinx/dockerfile
# maintainer="Sphinx Team <https://www.sphinx-doc.org/>"
# $ docker build --pull \
#   --tag ${REGISTRY}/sphinxdoc
#   --file Dockerfile .
FROM python:3.9-slim
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
RUN python3 -m pip install --no-cache-dir "Sphinx<=4.6" Pillow
RUN python3 -m pip install --no-cache-dir sphinx-copybutton
RUN python3 -m pip install --no-cache-dir sphinx-tabs
RUN python3 -m pip install --no-cache-dir sphinxcontrib-blockdiag
RUN python3 -m pip install --no-cache-dir "sphinx_rtd_theme==1.0.0"

# Install fonts for blockdiag
#Download IBM Plex
#curl -fOSsL https://github.com/IBM/plex/raw/v5.1.3/IBM-Plex-Mono/fonts/complete/ttf/IBMPlexMono-Regular.ttf
#Download Roboto https://fonts.google.com/specimen/Roboto
COPY assets/*.ttf /usr/share/fonts/truetype/
RUN fc-cache

CMD ["make", "html"]
