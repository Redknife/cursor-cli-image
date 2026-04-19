#!/usr/bin/env bash
set -euo pipefail

INSTALL_ROOT="${INSTALL_ROOT:-/usr/local/share/cursor-agent}"
BIN_DIR="${BIN_DIR:-/usr/local/bin}"
INSTALL_SCRIPT_URL="${INSTALL_SCRIPT_URL:-https://cursor.com/install}"
TARGET_VERSION="${1:-${CURSOR_CLI_VERSION:-}}"
TARGETARCH="${TARGETARCH:-$(uname -m)}"

map_arch() {
  case "$1" in
    amd64|x86_64)
      echo "x64"
      ;;
    arm64|aarch64)
      echo "arm64"
      ;;
    *)
      echo "Unsupported architecture: $1" >&2
      exit 1
      ;;
  esac
}

ARCH="$(map_arch "$TARGETARCH")"
OS="linux"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

INSTALL_SH="${TMP_DIR}/install.sh"
curl -fsSL "$INSTALL_SCRIPT_URL" -o "$INSTALL_SH"

if [ -z "$TARGET_VERSION" ]; then
  TARGET_VERSION="$(sed -n 's/.*\/lab\/\([^/]*\)\/linux\/.*/\1/p' "$INSTALL_SH" | head -n 1)"
fi

if [ -z "$TARGET_VERSION" ]; then
  echo "Failed to resolve cursor-cli version from ${INSTALL_SCRIPT_URL}" >&2
  exit 1
fi

DOWNLOAD_URL="https://downloads.cursor.com/lab/${TARGET_VERSION}/${OS}/${ARCH}/agent-cli-package.tar.gz"
INSTALL_DIR="${INSTALL_ROOT}/versions/${TARGET_VERSION}"

mkdir -p "$INSTALL_DIR" "$BIN_DIR"
curl -fsSL "$DOWNLOAD_URL" | tar --strip-components=1 -xzf - -C "$INSTALL_DIR"

ln -sf "${INSTALL_DIR}/cursor-agent" "${BIN_DIR}/agent"
ln -sf "${INSTALL_DIR}/cursor-agent" "${BIN_DIR}/cursor-agent"

echo "$TARGET_VERSION" > "${INSTALL_ROOT}/VERSION"
echo "$TARGET_VERSION"
