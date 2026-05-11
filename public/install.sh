#!/bin/sh
set -eu

DEFAULT_PACKAGE="https://install.thisismonolith.com/downloads/monolith_cli-0.4.9-py3-none-any.whl"
REPO="${MONOLITH_CLI_REPO:-}"
REF="${MONOLITH_CLI_REF:-main}"
SUBDIRECTORY="${MONOLITH_CLI_SUBDIRECTORY:-}"
if [ -n "${MONOLITH_CLI_PACKAGE:-}" ]; then
  PACKAGE="$MONOLITH_CLI_PACKAGE"
elif [ -n "$REPO" ] && [ -n "$SUBDIRECTORY" ]; then
  PACKAGE="monolith-cli @ git+${REPO}@${REF}#subdirectory=${SUBDIRECTORY}"
elif [ -n "$SUBDIRECTORY" ]; then
  fail "MONOLITH_CLI_SUBDIRECTORY requires MONOLITH_CLI_REPO"
elif [ -n "$REPO" ]; then
  PACKAGE="monolith-cli @ git+${REPO}@${REF}"
else
  PACKAGE="$DEFAULT_PACKAGE"
fi
BIN_DIR="${MONOLITH_BIN_DIR:-$HOME/.local/bin}"
VENV_DIR="${MONOLITH_VENV_DIR:-$HOME/.local/share/monolith/venv}"

info() {
  printf '%s\n' "$*"
}

fail() {
  printf 'monolith install: %s\n' "$*" >&2
  exit 1
}

if ! command -v python3 >/dev/null 2>&1; then
  fail "python3 is required"
fi

PYTHON="python3"

install_with_pipx() {
  pipx uninstall monolith-cli >/dev/null 2>&1 || true
  pipx install "$PACKAGE"
  rm -f "$HOME/.local/bin/raava" "$HOME/.local/bin/raava-mcp"
}

install_with_venv() {
  "$PYTHON" -m venv "$VENV_DIR"
  "$VENV_DIR/bin/python" -m pip install --upgrade pip
  "$VENV_DIR/bin/python" -m pip install --upgrade "$PACKAGE"
  mkdir -p "$BIN_DIR"
  ln -sf "$VENV_DIR/bin/monolith" "$BIN_DIR/monolith"
  ln -sf "$VENV_DIR/bin/monolith-mcp" "$BIN_DIR/monolith-mcp"
  rm -f "$BIN_DIR/raava" "$BIN_DIR/raava-mcp"
}

info "Installing Monolith CLI from: $PACKAGE"

if command -v pipx >/dev/null 2>&1; then
  install_with_pipx
else
  info "pipx not found; installing into $VENV_DIR"
  install_with_venv
fi

if [ -x "$BIN_DIR/monolith" ]; then
  "$BIN_DIR/monolith" --version
elif command -v monolith >/dev/null 2>&1; then
  monolith --version
else
  info "Installed. Add $BIN_DIR to PATH if 'monolith' is not found."
  info "Example: export PATH=\"$BIN_DIR:\$PATH\""
fi

info "Next step — connect to your tenant:"
info "  monolith auth login --token <JWT>"
info "Get a token at https://app.thisismonolith.com/setup"
