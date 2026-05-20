#!/usr/bin/env bash
# Vow toolchain installer.
#
# Usage:
#   curl -fsSL https://vow-lang.com/install.sh | bash
#
# Environment variables:
#   VOW_INSTALL_PREFIX   Install prefix (default: $HOME/.local)
#   VOW_VERSION          Release tag to install (default: latest)

set -euo pipefail

REPO="vow-lang/vow"
PREFIX="${VOW_INSTALL_PREFIX:-$HOME/.local}"
VERSION="${VOW_VERSION:-latest}"
BIN_DIR="$PREFIX/bin"

red()    { printf '\033[31m%s\033[0m\n' "$*" >&2; }
green()  { printf '\033[32m%s\033[0m\n' "$*"; }
dim()    { printf '\033[2m%s\033[0m\n' "$*"; }

die() { red "error: $*"; exit 1; }

command -v curl >/dev/null 2>&1 || die "curl is required"

# Detect platform.
os_raw=$(uname -s)
arch_raw=$(uname -m)
case "$os_raw" in
    Linux)  os=linux ;;
    Darwin) os=macos ;;
    *) die "unsupported OS: $os_raw" ;;
esac
case "$arch_raw" in
    x86_64|amd64)  arch=x86_64 ;;
    aarch64|arm64) arch=aarch64 ;;
    *) die "unsupported architecture: $arch_raw" ;;
esac
platform="${os}-${arch}"

# Resolve release tag.
if [ "$VERSION" = "latest" ]; then
    tag=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
        | sed -nE 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' \
        | head -n1)
    [ -n "$tag" ] || die "could not resolve latest release tag for $REPO"
else
    tag="$VERSION"
fi

asset="vowc-${platform}"
base="https://github.com/$REPO/releases/download/$tag"

green "Installing vow $tag for $platform → $BIN_DIR"

# Confirm asset exists before downloading.
http_code=$(curl -sLI -o /dev/null -w '%{http_code}' "$base/$asset")
if [ "$http_code" != "200" ]; then
    die "no prebuilt binary for $platform in release $tag (HTTP $http_code at $base/$asset)"
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

dim "Downloading $asset..."
curl -fL --progress-bar -o "$tmp/$asset" "$base/$asset"

# Verify checksum if published alongside the asset.
if curl -fsSL -o "$tmp/$asset.sha256" "$base/$asset.sha256" 2>/dev/null; then
    dim "Verifying SHA-256..."
    (
        cd "$tmp"
        if command -v sha256sum >/dev/null 2>&1; then
            sha256sum -c "$asset.sha256" >/dev/null
        elif command -v shasum >/dev/null 2>&1; then
            shasum -a 256 -c "$asset.sha256" >/dev/null
        else
            red "warning: no sha256sum or shasum found; skipping checksum verification"
        fi
    ) || die "checksum mismatch for $asset"
fi

mkdir -p "$BIN_DIR"
install -m 0755 "$tmp/$asset" "$BIN_DIR/vowc"
ln -sf vowc "$BIN_DIR/vow"

green "Installed vowc $tag to $BIN_DIR/vowc"

# PATH hint.
case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *)
        dim ""
        dim "Add $BIN_DIR to your PATH:"
        dim "  export PATH=\"$BIN_DIR:\$PATH\""
        ;;
esac

dim ""
dim "Next:"
dim "  npx skills install vow-lang/vow   # install the Claude Code skill"
dim "  vowc --help"
