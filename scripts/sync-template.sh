#!/usr/bin/env bash
# mirror the shared logic into template/ so the flake starter never drifts from the real
# config. only the engine is copied. the settings surface (flake.nix, hosts/) is authored
# per config and stays template-only. run with --check to fail on drift instead of copying.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

# byte-identical between the real config and the template
synced=(
  modules/basic.nix
  modules/options.nix
  modules/nvidia.nix
  modules/extended.nix
  modules/specialized-dev.nix
  modules/specialized-game.nix
  home/basic.nix
)

check=0
[ "${1:-}" = "--check" ] && check=1

status=0
for f in "${synced[@]}"; do
  dest="template/$f"
  if [ "$check" -eq 1 ]; then
    if ! diff -q "$f" "$dest" >/dev/null 2>&1; then
      echo "drift: $dest differs from $f"
      status=1
    fi
  else
    mkdir -p "$(dirname "$dest")"
    cp "$f" "$dest"
  fi
done

[ "$check" -eq 1 ] && [ "$status" -eq 0 ] && echo "template in sync"
exit $status
