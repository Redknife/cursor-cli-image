# cursor-cli Docker Image

[![Build and Publish Image](https://github.com/Redknife/cursor-cli-image/actions/workflows/build.yml/badge.svg)](https://github.com/Redknife/cursor-cli-image/actions/workflows/build.yml)
[![GHCR Package](https://img.shields.io/badge/ghcr-public-blue)](https://github.com/Redknife/cursor-cli-image/pkgs/container/cursor-cli)

Minimal, multi-arch Docker image for running Cursor CLI (`agent`) in CI pipelines.

The image is designed for automated review workflows (including GitLab Merge Request jobs), while keeping the dependency surface and image size low.

## What is included

- `cursor-cli` (`agent`, `cursor-agent`)
- `git`, `curl`, `ca-certificates`, `openssh-client`
- `jq`, `ripgrep`, `bash`, `diffutils`, `less`, `tini`

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

## Tags

- `latest` - default branch scheduled refresh and push builds.
- `<cursor-version>` - resolved from `https://cursor.com/install` during image build.
- `sha-<short-sha>` - immutable tag for the source revision.
- `v*` - tags created from Git refs such as `v1.0.0`.
- `YYYYMMDD` - daily scheduled build tag.

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
    - agent -p "Review this merge request diff for bugs, risks, and missing tests."
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
      - run: agent -p "Review the repository changes in this branch."
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
