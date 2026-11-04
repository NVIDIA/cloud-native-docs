# Runtime Memory

This directory is local durable memory for GPU Operator DevOps agent runs. Use
it to preserve useful learning across agent sessions, compaction, and context
loss.

Do not store secrets, tokens, private hostnames, customer data, internal-only
NVIDIA links, or unredacted logs here. Draft public issue content locally first;
file externally only after user approval.

Recommended flow:

1. During a run, append observations to the relevant file.
2. At the end of a run, promote repeated or validated observations into
   package references/skills.
3. Leave tentative or environment-specific notes clearly scoped.
4. Draft upstream issues in `upstream-issue-drafts.md`; do not file them
   automatically.
