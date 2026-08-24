#!/usr/bin/env bash
set -euo pipefail

# Named volumes mount root-owned the first time.
sudo chown -R vscode:vscode /home/vscode/.claude /home/vscode/.Garmin \
                            /home/vscode/.connect-iq-sdk-manager /home/vscode/.ciq

# --- Claude Code -------------------------------------------------------------
# Native install, no Node.js: the launcher at ~/.local/bin/claude symlinks into
# ~/.local/share/claude/versions/. Claude Code then checks for updates at startup
# and periodically while running, installing in the background — so this only has
# to establish a current baseline after a rebuild.
#
# The channel passed here becomes the default for those auto-updates:
#   latest — every release as it ships (default)
#   stable — roughly a week behind, skips releases with major regressions
if command -v claude >/dev/null 2>&1; then
  claude update || true
else
  curl -fsSL https://claude.ai/install.sh | bash -s "${CLAUDE_CHANNEL:-latest}"
fi
claude --version || true

# --- developer key -----------------------------------------------------------
# RSA 4096 + PKCS#8 DER is what monkeyc's -y flag expects. Lives in the ciq-keys
# volume. Back it up: a lost key means a published app can never be updated.
if [ ! -f "$HOME/.ciq/developer_key.der" ]; then
  openssl genrsa -out "$HOME/.ciq/developer_key.pem" 4096
  openssl pkcs8 -topk8 -inform PEM -outform DER \
    -in "$HOME/.ciq/developer_key.pem" \
    -out "$HOME/.ciq/developer_key.der" -nocrypt
  chmod 600 "$HOME/.ciq/developer_key."*
  cat <<'WARN'

!! Generated a NEW developer key in the ciq-keys volume.
!! SimpTemp is already published, so this is almost certainly NOT the key you
!! want: the store rejects an update signed with a different key. Copy your
!! existing developer_key.der into the volume and delete the generated pair:
!!
!!   docker run --rm -v ciq-keys:/k -v "$HOME/<dir-with-your-key>":/src:ro \
!!     alpine sh -c 'cp /src/developer_key.der /src/developer_key.pem /k/'
!!
!! Then back that key up somewhere durable.

WARN
fi

# --- SDK ---------------------------------------------------------------------
mkdir -p "$HOME/.local"

link_sdk() {
  local sdk
  sdk="$(connect-iq-sdk-manager sdk current-path 2>/dev/null || true)"
  if [ -n "$sdk" ]; then
    ln -sfn "$sdk" "$HOME/.local/ciq-sdk"
    echo ">> SDK linked: $sdk"
  fi
}

if [ -n "$(connect-iq-sdk-manager sdk current-path 2>/dev/null || true)" ]; then
  link_sdk
else
  cat <<'EOF'
>> No SDK yet. One-time setup in the container terminal:

     connect-iq-sdk-manager agreement view
     connect-iq-sdk-manager agreement accept
     connect-iq-sdk-manager login             # Garmin SSO in a browser
     connect-iq-sdk-manager sdk set 8.2.1
     connect-iq-sdk-manager device download --manifest=manifest.xml --include-fonts
     make sdk-link                            # refresh ~/.local/ciq-sdk

   Then: claude   (browser OAuth, once per devcontainer)
EOF
fi
