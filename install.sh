#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Skills install into both Codex and Claude Code skill homes.
# Override the target(s) with:
#   AGENT=codex   bash install.sh   # Codex only
#   AGENT=claude  bash install.sh   # Claude Code only
#   AGENT=both    bash install.sh   # default
AGENT="${AGENT:-both}"

CODEX_SKILLS_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
CLAUDE_SKILLS_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"

targets=()
case "$AGENT" in
  codex)  targets=("$CODEX_SKILLS_DIR") ;;
  claude) targets=("$CLAUDE_SKILLS_DIR") ;;
  both)   targets=("$CODEX_SKILLS_DIR" "$CLAUDE_SKILLS_DIR") ;;
  *)
    echo "Unknown AGENT='$AGENT' (use: codex | claude | both)" >&2
    exit 1
    ;;
esac

install_into() {
  local skills_dir="$1"
  mkdir -p "$skills_dir"

  for skill in aspire-hf-download nscc-aspire2a-ssh; do
    local source_dir="$ROOT_DIR/skills/$skill"
    local target_dir="$skills_dir/$skill"

    if [[ ! -d "$source_dir" ]]; then
      echo "Missing skill directory: $source_dir" >&2
      exit 1
    fi

    if [[ -e "$target_dir" ]]; then
      local backup_dir="$target_dir.backup.$(date +%Y%m%d%H%M%S)"
      mv "$target_dir" "$backup_dir"
      echo "Backed up existing skill: $backup_dir"
    fi

    cp -R "$source_dir" "$target_dir"
    echo "Installed: $target_dir"
  done
}

for dir in "${targets[@]}"; do
  install_into "$dir"
done

echo
echo "Done. Restart Codex / Claude Code if the skills are not discovered immediately."
