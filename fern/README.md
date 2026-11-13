# GPU Operator navigation drafts for Fern

Two drafts of the same content, organized with the patterns in "Landing Page and Navigation Patterns for Docs in Fern".
Page titles and section headings come from the cloud-native-docs RST. Page bodies are stubs.

- `a-simple-product/`: Simple Product. Three peer Books as header tabs: GPU Operator, OpenShift, Partner-Validated.
- `b-complex-product/`: Complex Product. Category tabs: Guides, Reference, Release Notes, Troubleshooting, Support Matrix. The Guides tab has a Book menu: Install and Upgrade, Advanced Configuration, Sandboxed Workloads, OpenShift, Partner Platforms.

Both drafts show a version picker with 26.7, 26.3, and 25.10. All three versions use the same navigation.

## Run a draft

Requires Node.js 18 or later.

```bash
npm install -g fern-api@5.213.0
cd a-simple-product/fern && fern docs dev --port 3000
cd b-complex-product/fern && fern docs dev --port 3001
```

Open http://localhost:3000 and http://localhost:3001.

