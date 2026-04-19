FROM debian:bookworm-slim

ARG TARGETARCH
ARG CURSOR_CLI_VERSION=""
ARG IMAGE_CREATED=""
ARG VCS_REF=""
ARG VCS_URL="https://github.com/Redknife/cursor-cli-image"
ARG IMAGE_VERSION="latest"

LABEL org.opencontainers.image.title="cursor-cli image" \
      org.opencontainers.image.description="Minimal multi-arch image for running Cursor CLI in CI" \
      org.opencontainers.image.source="${VCS_URL}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.licenses="MIT"

ENV LANG=C.UTF-8 \
    TERM=xterm-256color \
    PATH=/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin \
    CURSOR_DISABLE_AUTOUPDATE=1 \
    CURSOR_AGENT_DISABLE_AUTOUPDATE=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      diffutils \
      git \
      jq \
      less \
      openssh-client \
      ripgrep \
      tini \
    && rm -rf /var/lib/apt/lists/*

COPY scripts/install-cursor-cli.sh /usr/local/bin/install-cursor-cli.sh

RUN chmod +x /usr/local/bin/install-cursor-cli.sh \
    && /usr/local/bin/install-cursor-cli.sh "${CURSOR_CLI_VERSION}" \
    && useradd --create-home --uid 1000 --shell /bin/bash agent \
    && mkdir -p /home/agent/.local \
    && chown -R agent:agent /home/agent

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["bash"]
