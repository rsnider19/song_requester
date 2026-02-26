#!/bin/bash
# Ensures Dart SDK, FVM, and GitHub CLI are installed.
# Used as a Claude Code SessionStart hook.

# Skip installation in local environments
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  exit 0
fi

install_dart_via_apt() {
  # Per https://dart.dev/get-dart#install
  echo "Installing Dart SDK via apt-get..."
  sudo apt-get update -y 2>&1
  sudo apt-get install -y apt-transport-https 2>&1
  sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/dart.gpg'
  sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main" > /etc/apt/sources.list.d/dart_stable.list'
  sudo apt-get update -y 2>&1
  sudo apt-get install -y dart 2>&1
}

install_dart_via_download() {
  local os arch platform dart_zip dart_url install_dir
  os="$(uname -s)"
  arch="$(uname -m)"

  # Map architecture
  case "$arch" in
    x86_64)  arch="x64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) echo "Unsupported architecture: $arch" >&2; return 1 ;;
  esac

  # Map platform
  case "$os" in
    Darwin) platform="macos" ;;
    Linux)  platform="linux" ;;
    *) echo "Unsupported OS: $os" >&2; return 1 ;;
  esac

  # Check required tools
  if ! command -v curl &>/dev/null; then
    echo "curl is required to download Dart SDK" >&2; return 1
  fi
  if ! command -v unzip &>/dev/null; then
    echo "unzip is required to extract Dart SDK" >&2; return 1
  fi

  install_dir="$HOME/.dart-sdk"
  dart_zip="dartsdk-${platform}-${arch}-release.zip"
  dart_url="https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/${dart_zip}"

  echo "Downloading Dart SDK from ${dart_url}..."
  mkdir -p "$install_dir"
  curl --retry 3 --location --fail --output "/tmp/${dart_zip}" "$dart_url" 2>&1
  unzip -qo "/tmp/${dart_zip}" -d "$install_dir" 2>&1
  rm -f "/tmp/${dart_zip}"

  export PATH="$install_dir/dart-sdk/bin:$PATH"
}

install_dart() {
  local os
  os="$(uname -s)"

  # Linux: try apt-get first (recommended method)
  if [ "$os" = "Linux" ] && command -v apt-get &>/dev/null; then
    install_dart_via_apt && return 0
    echo "apt-get install failed, falling back to direct download..." >&2
  fi

  # macOS or Linux fallback: direct download
  install_dart_via_download
}

# ── Dart ──
if ! command -v dart &>/dev/null; then
  echo "Dart SDK not found. Installing..."
  install_dart
  if ! command -v dart &>/dev/null; then
    echo "Failed to install Dart SDK." >&2
    exit 1
  fi
  echo "Dart installed: $(dart --version 2>&1)"
fi

# ── FVM ──
if ! command -v fvm &>/dev/null; then
  echo "fvm not found. Installing via dart pub global activate fvm..."
  dart pub global activate fvm 2>&1
  export PATH="$PATH:$HOME/.pub-cache/bin"
  if ! command -v fvm &>/dev/null; then
    echo "Failed to install fvm." >&2
    exit 1
  fi
  echo "fvm installed: $(fvm --version 2>/dev/null)"
fi

# ── Persist PATH for the session ──
if [ -n "$CLAUDE_ENV_FILE" ]; then
  # Include both possible Dart locations: apt (/usr/lib/dart/bin) and manual (~/.dart-sdk/dart-sdk/bin)
  echo "export PATH=\"/usr/lib/dart/bin:$HOME/.dart-sdk/dart-sdk/bin:$HOME/.pub-cache/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

# ── GitHub CLI ──
if ! command -v gh &>/dev/null; then
  echo "GitHub CLI not found. Installing..."
  (type -p wget >/dev/null || (sudo apt-get update && sudo apt-get install wget -y)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt-get update \
    && sudo apt-get install gh -y 2>&1
  if ! command -v gh &>/dev/null; then
    echo "Warning: Failed to install GitHub CLI. PR workflows will not be available." >&2
  else
    echo "GitHub CLI installed: $(gh --version 2>&1 | head -1)"
  fi
fi

# ── Install Flutter SDK via FVM ──
if [ -f "$CLAUDE_PROJECT_DIR/.fvmrc" ]; then
  echo "Running fvm install..."
  cd "$CLAUDE_PROJECT_DIR" && fvm install 2>&1
fi

echo "fvm is ready: $(fvm --version 2>/dev/null)"
exit 0
