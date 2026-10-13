# Runner image for the self-hosted GitHub Actions runners on the homelab cluster
# (Actions Runner Controller, scale set `homelab`).
#
# The ARC base image is minimal: Ubuntu, the runner and sudo. GitHub-hosted
# ubuntu-latest ships hundreds of tools, and workflows written against it rely on
# some of them without saying so. This image adds what the repositories using
# these runners actually need, so jobs start with it already installed instead of
# running apt-get every time.
FROM ghcr.io/actions/actions-runner:2.338.0

USER root

ARG PANDOC_VERSION=3.9.0.2
ARG TYPST_VERSION=0.14.2

# - libegl1 libgl1 libgomp1 libusb-1.0-0: loaded by open3d at import
# - xz-utils: unpacks .tar.xz release archives (typst)
# - git: actions/checkout falls back to a tarball without it, with no history
# - fonts-noto-*: PDF builds, including Korean text
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git xz-utils \
      libegl1 libgl1 libgomp1 libusb-1.0-0 \
      fonts-noto-core fonts-noto-cjk fonts-noto-mono \
 && curl -fsSL -o /tmp/pandoc.deb \
      "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-amd64.deb" \
 && apt-get install -y --no-install-recommends /tmp/pandoc.deb \
 && curl -fsSL "https://github.com/typst/typst/releases/download/v${TYPST_VERSION}/typst-x86_64-unknown-linux-musl.tar.xz" \
      | tar -xJ -C /tmp \
 && mv /tmp/typst-x86_64-unknown-linux-musl/typst /usr/local/bin/typst \
 && rm -rf /tmp/pandoc.deb /tmp/typst-x86_64-unknown-linux-musl /var/lib/apt/lists/*

# uv, and a managed Python 3.12 in a shared location, so `uv venv --python 3.12`
# finds it instead of downloading one per job.
COPY --from=ghcr.io/astral-sh/uv:0.12.18 /uv /uvx /usr/local/bin/
ENV UV_PYTHON_INSTALL_DIR=/opt/uv/python
RUN uv python install 3.12 \
 && chmod -R a+rX /opt/uv

USER runner
