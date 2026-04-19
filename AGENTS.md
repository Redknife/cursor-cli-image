# AGENTS.md

## Repository purpose

This repository builds and publishes a minimal, multi-architecture Docker image that packages Cursor CLI for CI automation, especially Merge Request review workflows.

## Hard rules

1. Keep the image minimal.
   - Any new apt package must be justified in the PR description.
   - Prefer `--no-install-recommends`.
2. Never include secrets in the image.
   - Do not bake API keys, tokens, or credentials into Docker layers.
   - `CURSOR_API_KEY` must come from runtime environment variables.
3. Keep everything in English.
   - README, documentation, comments, and commit messages.
4. Preserve multi-arch support.
   - All changes must keep `linux/amd64` and `linux/arm64` builds working.
5. Preserve reproducibility.
   - Keep Cursor auto-update disabled in the image.
   - Build should resolve and pin a Cursor CLI version during CI.

## Local verification before PR

Run these checks before opening or updating a PR:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t cursor-cli:test .
docker run --rm cursor-cli:test agent --version
```

If shell scripts change:

```bash
shellcheck scripts/*.sh
```

## Dockerfile conventions

- Use a slim Debian base image.
- Group related operations to minimize image layers.
- Always clean apt caches (`rm -rf /var/lib/apt/lists/*`) in the same `RUN`.
- Keep the runtime surface small; do not add language runtimes (Node.js, Python, Go) here.

## Pull request conventions

- Use short, imperative PR titles.
  - Example: `Bump cursor-cli to 2026.04.17-787b533`
  - Example: `Add ripgrep for review workflows`
- For Cursor CLI version bumps, include a link to the upstream release signal (install script/diff or changelog reference when available).

## Out of scope for this repository

- Language-specific build toolchains.
- Project-specific dependencies for individual applications.

Create downstream images with `FROM ghcr.io/redknife/cursor-cli` for those needs.
