# Kubernetes Reference Architecture Documentation

The product documentation is available from <https://docs.nvidia.com/datacenter/cloud-native/>.

## Building the Documentation

1. Build the container:

   ```bash
   docker build --pull \
     --tag k8s-ref-arch:0.1.0 \
     --file Dockerfile .
   ```

1. Run the container from the previous step:

   ```bash
   docker run -it --rm \
     -v $(pwd):/work -w /work \
     k8s-ref-arch:0.1.0 \
     bash
   ```

1. Build the docs:

   ```bash
   sphinx-build -E -a -b html -d /tmp docs _build/output
   ```

   The documentation is viewable in your browser with a URL like <file://.../_build/latest/>.

## Publishing Documentation

Update `versions.json` and `project.json` to include the new version.

After the content is finalized, tag the commit to publish with `v` and a semantic version, such as `v0.1.0`.

If post-release updates are required, tag those commits like `v0.1.0-1`.

If post-release updates to an older version are required, ensure the commit message includes `/not-latest`.
Then tag the commit like `v0.1.0-1`.

## Checking for Broken URLs

Run a linkcheck build:

```bash
sphinx-build -b linkcheck -d /tmp . _build/output | grep broken
```

Artificial URLs like <https://host-ip> are reported as broken, so perfection is not possible.
