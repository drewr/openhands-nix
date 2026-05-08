#!/usr/bin/env bash
set -euo pipefail

VERSION=$(curl -s https://api.github.com/repos/OpenHands/OpenHands-CLI/releases/latest \
  | jq -r .tag_name)

PREFETCH=$(nix-prefetch-github OpenHands OpenHands-CLI --rev "$VERSION")
REV=$(echo "$PREFETCH" | jq -r .rev)
HASH=$(echo "$PREFETCH" | jq -r .hash)

jq -n \
  --arg version "$VERSION" \
  --arg rev "$REV" \
  --arg hash "$HASH" \
  '{"version": $version, "rev": $rev, "hash": $hash}' > hashes.json

echo "Updated to $VERSION ($REV)"
