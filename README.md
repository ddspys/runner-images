# runner-images

Container image for the self-hosted GitHub Actions runners on a home Kubernetes
cluster (Actions Runner Controller, scale set `homelab`).

`ghcr.io/ddspys/runner-images/homelab-runner` is the ARC runner image
(`ghcr.io/actions/actions-runner`) plus the tools the repositories using these
runners need:

| What | Why |
|---|---|
| `libegl1` `libgl1` `libgomp1` `libusb-1.0-0` | open3d loads them at import |
| `xz-utils`, `git`, `curl` | release archives, full checkouts |
| Noto fonts (incl. CJK), pandoc, typst | PDF manuals |
| uv and a managed Python 3.12 (`UV_PYTHON_INSTALL_DIR=/opt/uv/python`) | `uv venv --python 3.12` without a download |

Images are built on GitHub-hosted runners on every push to `main` and weekly,
tagged `sha-<commit>` and `latest`. The cluster pins a `sha-` tag.

To add a tool, add it to the `Dockerfile`, open a PR (it builds without pushing),
merge, then move the cluster to the new `sha-` tag.
