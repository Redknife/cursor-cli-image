# cursor-cli Docker Image

[![Build and Publish Image](https://github.com/Redknife/cursor-cli-image/actions/workflows/build.yml/badge.svg)](https://github.com/Redknife/cursor-cli-image/actions/workflows/build.yml)
[![GHCR Package](https://img.shields.io/badge/ghcr-public-blue)](https://github.com/Redknife/cursor-cli-image/pkgs/container/cursor-cli)

Minimal, multi-arch Docker image for running Cursor CLI (`agent`) in CI pipelines.

The image is designed for automated review workflows (including GitLab Merge Request jobs), while keeping the dependency surface and image size low.

## What is included

- `cursor-cli` (`agent`, `cursor-agent`)
- `git`, `curl`, `ca-certificates`, `openssh-client`
- `jq`, `ripgrep`, `bash`, `diffutils`, `less`, `tini`
- Built-in review subagents in `~/.cursor/agents/`:
  - `code-reviewer` (Senior Staff Engineer perspective)
  - `security-auditor` (Security Engineer perspective)

## Quick start

```bash
docker pull ghcr.io/redknife/cursor-cli:latest

docker run --rm \
  -e CURSOR_API_KEY \
  -v "$PWD":/work \
  -w /work \
  ghcr.io/redknife/cursor-cli:latest \
  agent -p "review the diff and suggest fixes"
```

## Built-in review personas

This image ships pre-configured subagent personas for targeted review workflows.

| Agent | Role | Perspective |
|-------|------|-------------|
| `code-reviewer` | Senior Staff Engineer | Five-axis code review with "would a staff engineer approve this?" standard |
| `security-auditor` | Security Engineer | Vulnerability detection, threat modeling, OWASP assessment |

These personas are installed in `~/.cursor/agents/`, so they are available in `cursor-cli` without extra setup.

Project-local subagents in `.cursor/agents/` still take precedence when names conflict.

## Review examples

Use the bundled `code-reviewer` persona:

```bash
docker run --rm \
  -e CURSOR_API_KEY \
  -v "$PWD":/work \
  -w /work \
  ghcr.io/redknife/cursor-cli:latest \
  agent -p "/code-reviewer Review the current branch diff. Report Critical, Important, and Suggestion findings, plus missing tests."
```

Use the bundled `security-auditor` persona:

```bash
docker run --rm \
  -e CURSOR_API_KEY \
  -v "$PWD":/work \
  -w /work \
  ghcr.io/redknife/cursor-cli:latest \
  agent -p "/security-auditor Audit the current branch for OWASP Top 10 risks and return findings by severity with concrete mitigations."
```

## Tags

- `latest` - updated on default branch push builds and manual workflow dispatch.
- `<cursor-version>` - resolved from `https://cursor.com/install` during image build.
- `sha-<short-sha>` - immutable tag for the source revision.
- `v*` - tags created from Git refs such as `v1.0.0`.

## Supported architectures

- `linux/amd64`
- `linux/arm64`

## GitLab CI example (MR review job)

```yaml
review_mr:
  image: ghcr.io/redknife/cursor-cli:latest
  stage: test
  variables:
    GIT_STRATEGY: fetch
  script:
    - agent --version
    - agent -p "/code-reviewer Review this merge request diff for bugs, risks, and missing tests."
```

Set `CURSOR_API_KEY` in **GitLab CI/CD Variables** (masked + protected as needed).

## GitHub Actions example (using this image)

```yaml
jobs:
  review:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/redknife/cursor-cli:latest
    steps:
      - uses: actions/checkout@v4
      - run: agent --version
      - run: agent -p "/code-reviewer Review the repository changes in this branch."
        env:
          CURSOR_API_KEY: ${{ secrets.CURSOR_API_KEY }}
```

## Environment variables

- `CURSOR_API_KEY` (required) - API key for Cursor CLI authentication.
- `CURSOR_DISABLE_AUTOUPDATE=1` - set in the image to keep CI runs deterministic.

## Publishing to GHCR

1. Push this repository to GitHub.
2. Ensure Actions are enabled.
3. Run the `Build and Publish Image` workflow (or push to `main`).
4. Open package settings and set package visibility to **Public**.

## Build locally

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t cursor-cli:local .
docker run --rm cursor-cli:local agent --version
```

## License

MIT. See `LICENSE`.
