#!/usr/bin/env bash
set -euo pipefail

# preset variables
BIN_DIR="$HOME/bin"
DOTFILES_DIR="$HOME/dotfiles/starship"
TOML_SRC="$DOTFILES_DIR/pure-text.toml"
CONFIG_DIR="$HOME/.config"
CONFIG_FILE="$CONFIG_DIR/starship.toml"
BASHRC="$HOME/.bashrc"

# 1. Check if starship is already installed
if command -v starship >/dev/null 2>&1 ; then
  echo "starship is already in \$PATH, skipping installation."
else
  # Check if binary exists in ~/bin
  if [ -x "$BIN_DIR/starship" ]; then
    echo "Found starship executable in $BIN_DIR, adding it to PATH."
  else
    echo "Installing starship into $BIN_DIR ..."
    mkdir -p "$BIN_DIR"
    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$BIN_DIR" --yes
  fi
fi

# 2. Ensure ~/bin is in PATH (write to ~/.bashrc but avoid duplicates)
grep -qxF 'export PATH="$HOME/bin:$PATH"' "$BASHRC" \
  || echo 'export PATH="$HOME/bin:$PATH"' >> "$BASHRC"

# Ensure starship init line is present
INIT_LINE='eval "$(starship init bash)"'
grep -qxF "$INIT_LINE" "$BASHRC" \
  || echo "$INIT_LINE" >> "$BASHRC"

# Reload ~/.bashrc (for current shell session)
echo "Reloading $BASHRC ..."
source "$BASHRC"

# 3. Configuration file handling
echo "Linking starship configuration file ..."
mkdir -p "$CONFIG_DIR"

if [ -L "$CONFIG_FILE" ] || [ -f "$CONFIG_FILE" ]; then
  echo "Removing existing configuration file $CONFIG_FILE"
  rm -f "$CONFIG_FILE"
fi

ln -s "$TOML_SRC" "$CONFIG_FILE"
echo "Created symlink: $CONFIG_FILE -> $TOML_SRC"

echo "Installation successfully complete!"