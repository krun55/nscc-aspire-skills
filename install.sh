#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_SKILLS_DIR="${CODEX_HOME:-$HOME/.codex}/skills"

mkdir -p "$CODEX_SKILLS_DIR"

for skill in aspire-hf-download nscc-aspire2a-ssh; do
  source_dir="$ROOT_DIR/skills/$skill"
  target_dir="$CODEX_SKILLS_DIR/$skill"

  if [[ ! -d "$source_dir" ]]; then
    echo "Missing skill directory: $source_dir" >&2
    exit 1
  fi

  if [[ -e "$target_dir" ]]; then
    backup_dir="$target_dir.backup.$(date +%Y%m%d%H%M%S)"
    mv "$target_dir" "$backup_dir"
    echo "Backed up existing skill: $backup_dir"
  fi

  cp -R "$source_dir" "$target_dir"
  echo "Installed: $target_dir"
done

echo
echo "Done. Restart Codex if the skills are not discovered immediately."
