#!/usr/bin/env sh
set -eu

APP_NAME="cc-buddy-roller"
DEFAULT_REPO_SLUG="liuxiaopai-ai/cc-buddy-roller"
REPO_SLUG="${CC_BUDDY_ROLLER_REPO_SLUG:-$DEFAULT_REPO_SLUG}"
REPO_REF="${CC_BUDDY_ROLLER_REF:-main}"

if [ -n "${CC_BUDDY_ROLLER_REPO_URL:-}" ]; then
  REPO_SOURCE="$CC_BUDDY_ROLLER_REPO_URL"
elif [ -f "./buddy.mjs" ]; then
  REPO_SOURCE="$(pwd)"
else
  REPO_SOURCE="https://codeload.github.com/${REPO_SLUG}/tar.gz/refs/heads/${REPO_REF}"
fi

INSTALL_ROOT="${CC_BUDDY_ROLLER_HOME:-$HOME/.local/share/$APP_NAME}"
BUN_HOME="${BUN_INSTALL:-$HOME/.bun}"

if [ -n "${CC_BUDDY_ROLLER_BIN_DIR:-}" ]; then
  BIN_DIR="$CC_BUDDY_ROLLER_BIN_DIR"
elif [ -d "$BUN_HOME/bin" ]; then
  BIN_DIR="$BUN_HOME/bin"
else
  BIN_DIR="$HOME/.local/bin"
fi

LAUNCHER_PATH="$BIN_DIR/$APP_NAME"

info() {
  printf '[%s] %s\n' "$APP_NAME" "$1"
}

fail() {
  printf '[%s] %s\n' "$APP_NAME" "$1" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

ensure_bun() {
  if command -v bun >/dev/null 2>&1; then
    BUN_BIN="$(command -v bun)"
    info "Found Bun at $BUN_BIN"
    return
  fi

  need_cmd curl
  info "Bun not found. Installing Bun first..."
  curl -fsSL https://bun.sh/install | bash

  BUN_BIN="$BUN_HOME/bin/bun"
  PATH="$BUN_HOME/bin:$PATH"
  export PATH

  [ -x "$BUN_BIN" ] || fail "Bun installation finished, but bun was not found at $BUN_BIN"
  info "Installed Bun at $BUN_BIN"
}

install_from_local_dir() {
  SOURCE_DIR="$1"
  info "Copying local source from $SOURCE_DIR"
  rm -rf "$INSTALL_ROOT"
  mkdir -p "$INSTALL_ROOT"
  cp -R "$SOURCE_DIR"/. "$INSTALL_ROOT"/
}

install_from_archive() {
  ARCHIVE_URL="$1"
  need_cmd curl
  need_cmd tar

  TMP_DIR="$(mktemp -d)"
  cleanup_archive() {
    rm -rf "$TMP_DIR"
  }
  trap cleanup_archive EXIT INT TERM

  info "Downloading source archive from $ARCHIVE_URL"
  curl -fsSL "$ARCHIVE_URL" -o "$TMP_DIR/repo.tar.gz"
  tar -xzf "$TMP_DIR/repo.tar.gz" -C "$TMP_DIR"

  SOURCE_DIR="$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  [ -n "$SOURCE_DIR" ] || fail "Unable to unpack the project archive."
  [ -f "$SOURCE_DIR/buddy.mjs" ] || fail "The downloaded archive does not look like a cc-buddy-roller checkout."

  mkdir -p "$(dirname "$INSTALL_ROOT")"
  rm -rf "$INSTALL_ROOT"
  cp -R "$SOURCE_DIR" "$INSTALL_ROOT"

  trap - EXIT INT TERM
  cleanup_archive
}

sync_repo() {
  mkdir -p "$(dirname "$INSTALL_ROOT")"

  if [ -d "$REPO_SOURCE" ] && [ -f "$REPO_SOURCE/buddy.mjs" ]; then
    install_from_local_dir "$REPO_SOURCE"
    return
  fi

  if [ -f "$INSTALL_ROOT/buddy.mjs" ] && [ -n "${CC_BUDDY_ROLLER_REPO_URL:-}" ] && [ -d "$CC_BUDDY_ROLLER_REPO_URL" ]; then
    install_from_local_dir "$CC_BUDDY_ROLLER_REPO_URL"
  else
    install_from_archive "$REPO_SOURCE"
  fi
}

write_launcher() {
  mkdir -p "$BIN_DIR"

  cat >"$LAUNCHER_PATH" <<EOF
#!/usr/bin/env sh
set -eu

APP_ROOT="$INSTALL_ROOT"
PINNED_BUN="$BUN_BIN"
export CC_BUDDY_ROLLER_LAUNCHER="$APP_NAME"

if [ -x "\$PINNED_BUN" ]; then
  exec "\$PINNED_BUN" "\$APP_ROOT/buddy.mjs" "\$@"
fi

if command -v bun >/dev/null 2>&1; then
  exec "\$(command -v bun)" "\$APP_ROOT/buddy.mjs" "\$@"
fi

echo "cc-buddy-roller: bun not found. Re-run the installer or install Bun." >&2
exit 1
EOF

  chmod +x "$LAUNCHER_PATH"
  info "Wrote launcher to $LAUNCHER_PATH"
}

show_finish() {
  info "Install complete."
  printf '\n'
  printf 'Next step:\n'
  printf '  %s guide\n' "$APP_NAME"
  printf '\n'
  printf 'Installed files:\n'
  printf '  app: %s\n' "$INSTALL_ROOT"
  printf '  launcher: %s\n' "$LAUNCHER_PATH"
  printf '\n'

  case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *)
      printf 'Your PATH does not currently include %s.\n' "$BIN_DIR"
      printf 'Open a new terminal, or run:\n'
      printf '  export PATH="%s:$PATH"\n' "$BIN_DIR"
      printf '\n'
      ;;
  esac

  printf 'You can safely run this installer again later to update the local copy.\n'
}

ensure_bun
sync_repo
write_launcher
show_finish
