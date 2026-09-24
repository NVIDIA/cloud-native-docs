# Self-Improvement Loop

Use this reference whenever a run reveals something the package should remember
after the current session ends.

## Durable Memory Files

Write durable local notes under `runtime-memory/`:

| File | Use |
|---|---|
| `insights.md` | Validated reusable lessons, model changes, branch refinements. |
| `anti-patterns.md` | Stale commands, unsafe advice, repeated failed reasoning shapes. |
| `discovered-resources.md` | Public docs, source files, issues, forum posts, examples, or blogs found during operation. |
| `operating-parameters.md` | Target-specific versions, runtime values, chart values, feature flags, and support caveats. |
| `upstream-issue-drafts.md` | Draft public GitHub issues or package/doc improvements. |

Treat these files as local package memory. They may be committed to a review
branch when the user wants the package to carry the lesson forward, but they
are not automatically public reports.

## When To Record

Record a durable entry when:

- a command succeeds only after adding context that was missing from the
  package;
- public docs or examples are stale, incomplete, ambiguous, or environment
  sensitive;
- an issue/forum/blog reveals a recurring field pattern;
- a live run changes the compositional, dynamic, or value model;
- a support-matrix boundary is newer-than-known-tested but live evidence exists;
- an agent nearly took an unsafe branch or repeated the same failed branch.

## Entry Shape

Each entry should include:

- date;
- target product/version/environment;
- evidence source: public URL, source path, or live target evidence path;
- observation;
- package change needed;
- confidence level;
- whether an upstream issue should be drafted.

## Upstream Issue Discipline

Draft issues locally first. File an issue only after the user approves:

- target repo or tracker;
- title and body;
- labels/milestone/owner if any;
- whether the evidence is safe to publish;
- credentials/account to use.

For public GitHub issues, include only public docs/source evidence and redacted
live-environment evidence. Do not include NVIDIA-internal links, private
hostnames, credentials, customer data, or support-only details.

## Suggested GitHub Issue Template

```markdown
Title: <short public docs/product improvement>

## Summary
<What is unclear, stale, missing, or failing?>

## Environment
- GPU Operator version:
- Kubernetes distribution/version:
- Runtime:
- OS/kernel:
- GPU model:

## Evidence
- Public docs/source link:
- Live observed signal:
- Command/output excerpt with secrets redacted:

## Expected Behavior
<What should happen or what docs should say?>

## Actual Behavior
<What happened or what docs currently imply?>

## Suggested Improvement
<Concrete doc/product/package change>
```
