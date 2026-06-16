#!/usr/bin/env bash
set -euo pipefail

HOST="${NSCC_ASPIRE_HOST:-aspire2a.nus.edu.sg}"
ALIASES="${NSCC_ASPIRE_ALIASES:-aspire2a nscc}"
KEY_NAME="${NSCC_ASPIRE_KEY_NAME:-nscc_aspire2a}"
START_MARKER="# >>> nscc-aspire2a-ssh"
END_MARKER="# <<< nscc-aspire2a-ssh"

usage() {
  cat <<'USAGE'
Set up NSCC ASPIRE 2A SSH access.

Usage:
  bash setup_nscc_aspire2a_ssh.sh
  bash setup_nscc_aspire2a_ssh.sh e1538xxx
  bash setup_nscc_aspire2a_ssh.sh e1538xxx /path/to/private_key

Optional environment variables:
  NSCC_ASPIRE_HOST=aspire2a.nus.edu.sg
  NSCC_ASPIRE_ALIASES="aspire2a nscc"
  NSCC_ASPIRE_KEY_NAME=nscc_aspire2a
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

USER_ID="${1:-}"
KEY_SOURCE="${2:-}"

if [[ -z "$USER_ID" ]]; then
  printf "NSCC username, e.g. e1538xxx: "
  IFS= read -r USER_ID
fi

if [[ ! "$USER_ID" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "Invalid username: $USER_ID" >&2
  exit 1
fi

SSH_DIR="$HOME/.ssh"
KEY_FILE="$SSH_DIR/$KEY_NAME"
CONFIG_FILE="$SSH_DIR/config"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

TMP_KEY="$(mktemp "$SSH_DIR/${KEY_NAME}.tmp.XXXXXX")"
cleanup() {
  rm -f "$TMP_KEY" "$TMP_KEY.pub" 2>/dev/null || true
}
trap cleanup EXIT
chmod 600 "$TMP_KEY"

if [[ -n "$KEY_SOURCE" ]]; then
  if [[ ! -f "$KEY_SOURCE" ]]; then
    echo "Private key file not found: $KEY_SOURCE" >&2
    exit 1
  fi
  cp "$KEY_SOURCE" "$TMP_KEY"
else
  cat <<'PROMPT'
Paste your private SSH key below.
It should start with -----BEGIN ... PRIVATE KEY----- and end with -----END ... PRIVATE KEY-----.
PROMPT
  : > "$TMP_KEY"
  while IFS= read -r line; do
    printf '%s\n' "$line" >> "$TMP_KEY"
    case "$line" in
      "-----END "*"PRIVATE KEY-----") break ;;
    esac
  done
fi

chmod 600 "$TMP_KEY"

if ! ssh-keygen -lf "$TMP_KEY" >/dev/null 2>&1; then
  echo "The pasted/file private key is not valid. Nothing was installed." >&2
  exit 1
fi

if [[ -f "$KEY_FILE" ]] && ! cmp -s "$TMP_KEY" "$KEY_FILE"; then
  BACKUP="$KEY_FILE.backup.$(date +%Y%m%d%H%M%S)"
  cp -p "$KEY_FILE" "$BACKUP"
  echo "Existing key backed up to: $BACKUP"
fi

mv "$TMP_KEY" "$KEY_FILE"
chmod 600 "$KEY_FILE"
trap - EXIT

ssh-keygen -y -f "$KEY_FILE" > "$KEY_FILE.pub"
chmod 644 "$KEY_FILE.pub"

touch "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"

TMP_CONFIG="$(mktemp "$SSH_DIR/config.tmp.XXXXXX")"
TMP_BLOCK="$(mktemp "$SSH_DIR/config.block.XXXXXX")"
trap 'rm -f "$TMP_CONFIG" "$TMP_BLOCK" 2>/dev/null || true' EXIT

awk -v start="$START_MARKER" -v end="$END_MARKER" '
  $0 == start { skipping = 1; next }
  $0 == end { skipping = 0; next }
  !skipping { print }
' "$CONFIG_FILE" > "$TMP_CONFIG"

{
  echo "$START_MARKER"
  echo "Host $ALIASES"
  echo "    HostName $HOST"
  echo "    User $USER_ID"
  echo "    IdentityFile ~/.ssh/$KEY_NAME"
  echo "    IdentitiesOnly yes"
  echo "    AddKeysToAgent yes"
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "    UseKeychain yes"
  fi
  echo "    ServerAliveInterval 60"
  echo "    ServerAliveCountMax 3"
  echo "$END_MARKER"
  echo
} > "$TMP_BLOCK"

cat "$TMP_BLOCK" "$TMP_CONFIG" > "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"
rm -f "$TMP_CONFIG" "$TMP_BLOCK"
trap - EXIT

FIRST_ALIAS="${ALIASES%% *}"

echo
echo "Installed:"
echo "  Key:    $KEY_FILE"
echo "  Public: $KEY_FILE.pub"
echo "  Config: $CONFIG_FILE"
echo
printf "Key fingerprint: "
ssh-keygen -lf "$KEY_FILE" | awk '{print $2, $4}'
echo
echo "Effective SSH config:"
ssh -F "$CONFIG_FILE" -G "$FIRST_ALIAS" 2>/dev/null | awk '/^(user|hostname|port|identityfile|identitiesonly|serveraliveinterval|serveralivecountmax) /{print "  " $0}'
echo
echo "Next:"
echo "  1. Connect NUS VPN if you are outside campus."
echo "  2. Run: ssh $FIRST_ALIAS"
echo "  3. Upload files with: scp file.py $FIRST_ALIAS:~/"
echo

if command -v nc >/dev/null 2>&1; then
  echo "Quick port check:"
  if nc -vz -G 5 "$HOST" 22 >/dev/null 2>&1; then
    echo "  SSH port is reachable: $HOST:22"
  elif nc -vz -w 5 "$HOST" 22 >/dev/null 2>&1; then
    echo "  SSH port is reachable: $HOST:22"
  else
    echo "  Could not reach $HOST:22. Check NUS VPN or network access."
  fi
fi
