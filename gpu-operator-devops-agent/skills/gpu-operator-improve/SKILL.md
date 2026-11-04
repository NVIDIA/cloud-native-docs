---
name: gpu-operator-improve
description: Capture durable GPU Operator DevOps package lessons, anti-patterns, discovered resources, operating parameters, and upstream issue drafts.
tags: [gpu-operator, improvement, memory, issues]
---

# GPU Operator Improve

Use this skill at the end of every live run, failed attempt, troubleshooting
scenario, or source-discovery pass.

## Inputs

- Run transcript, evidence bundle, or scenario result.
- Target environment metadata.
- Any newly discovered public docs/source/issues/forums/blogs.
- Any observed stale command, missing branch, unsafe advice, or docs/product
  improvement candidate.

## Workflow

1. Read `references/self-improvement.md`.
2. Classify each lesson:
   - insight;
   - anti-pattern;
   - discovered resource;
   - operating parameter;
   - upstream issue draft;
   - package source/reference update.
3. Append concise entries to the matching file in `runtime-memory/`.
4. If the lesson is validated and reusable, patch the package reference or
   skill that future agents will load.
5. If the lesson belongs upstream, draft an issue in
   `runtime-memory/upstream-issue-drafts.md`.
6. Ask for user approval before filing any external issue.

## GitHub Issue Filing Boundary

Creating or updating a GitHub issue is a mutating external action. Do it only
after the user approves:

- repository;
- title/body;
- labels/milestone if any;
- account/credentials;
- whether the included evidence is safe to publish.

Default target for public GPU Operator product/docs issues:

```text
https://github.com/NVIDIA/gpu-operator/issues
```

If the issue concerns this package rather than the product/docs,
draft it locally and ask where the package issue should live.

## Redaction Rules

Never write secrets, tokens, private hostnames, unredacted customer data,
internal-only NVIDIA links, or private support artifacts into public issue
drafts. Keep internal or private context in a non-exportable authoring note
outside the public package.

## Completion Criteria

- Relevant `runtime-memory/` files updated.
- Package refs/skills patched when the lesson is validated and reusable.
- Upstream issue draft written when appropriate.
- External issue filing either approved and completed, or left as an explicit
  pending draft.
