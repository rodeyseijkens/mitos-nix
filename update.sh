#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NIX="$SCRIPT_DIR/package.nix"
REPO="mitos-editor/mitos"

echo "Fetching latest version..."
LATEST_VERSION=$(curl -sL "https://api.github.com/repos/${REPO}/releases/latest" | jq -r '.tag_name' | sed 's/^v//')
CURRENT_VERSION=$(grep 'version = ' "$PACKAGE_NIX" | head -1 | sed 's/.*"\(.*\)".*/\1/')

echo "Current version: $CURRENT_VERSION"
echo "Latest version:  $LATEST_VERSION"

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "Already up to date!"
    exit 0
fi

prefetch_sri() {
    local hash
    hash=$(nix-prefetch-url "$1" 2>/dev/null)
    nix hash convert --to sri --hash-algo sha256 "$hash"
}

BASE_URL="https://github.com/${REPO}/releases/download/v${LATEST_VERSION}"

echo "Fetching hashes for $LATEST_VERSION..."
X86_SRI=$(prefetch_sri "${BASE_URL}/mitos-v${LATEST_VERSION}-x86_64-linux.tar.xz")
AARCH64_SRI=$(prefetch_sri "${BASE_URL}/mitos-v${LATEST_VERSION}-aarch64-linux.tar.xz")

echo "x86_64 hash:  $X86_SRI"
echo "aarch64 hash: $AARCH64_SRI"

sed -i "s/version = \"$CURRENT_VERSION\"/version = \"$LATEST_VERSION\"/" "$PACKAGE_NIX"
sed -i "s|x86_64-linux = \"sha256-[^\"]*\"|x86_64-linux = \"$X86_SRI\"|" "$PACKAGE_NIX"
sed -i "s|aarch64-linux = \"sha256-[^\"]*\"|aarch64-linux = \"$AARCH64_SRI\"|" "$PACKAGE_NIX"

echo "Updated package.nix to version $LATEST_VERSION"
