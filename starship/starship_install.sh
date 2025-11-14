#!/usr/bin/env bash
set -euo pipefail

# 预设变量
BIN_DIR="$HOME/bin"
DOTFILES_DIR="$HOME/dotfiles/starship"
TOML_SRC="$DOTFILES_DIR/pure-text.toml"
CONFIG_DIR="$HOME/.config"
CONFIG_FILE="$CONFIG_DIR/starship.toml"
BASHRC="$HOME/.bashrc"

# 1. 检测 starship 是否已安装
if command -v starship >/dev/null 2>&1 ; then
  echo "starship 已在 \$PATH 中，跳过安装。"
else
  # 再检查 ~/bin 中是否有二进制
  if [ -x "$BIN_DIR/starship" ]; then
    echo "在 $BIN_DIR 中发现 starship 可执行文件，添加到 PATH。"
  else
    echo "安装 starship 到 $BIN_DIR ..."
    mkdir -p "$BIN_DIR"
    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$BIN_DIR" --yes
  fi
fi

# 2. 确保 ~/bin 在 PATH 中（写入 ~/.bashrc，但避免重复）
grep -qxF 'export PATH="$HOME/bin:$PATH"' "$BASHRC" \
  || echo 'export PATH="$HOME/bin:$PATH"' >> "$BASHRC"

# 确保 starship init 行存在
INIT_LINE='eval "$(starship init bash)"'
grep -qxF "$INIT_LINE" "$BASHRC" \
  || echo "$INIT_LINE" >> "$BASHRC"

# 立即加载 ~/.bashrc（当前 shell 会话）
# 注意：在远程/非交互 shell 中可能不会生效，仅作提示
echo "Reloading $BASHRC ..."
source "$BASHRC"

# 3. 配置文件处理
echo "配置 starship 配置文件链接 ..."
mkdir -p "$CONFIG_DIR"

if [ -L "$CONFIG_FILE" ] || [ -f "$CONFIG_FILE" ]; then
  echo "移除已有的配置文件 $CONFIG_FILE"
  rm -f "$CONFIG_FILE"
fi

ln -s "$TOML_SRC" "$CONFIG_FILE"
echo "创建软链接: $CONFIG_FILE -> $TOML_SRC"

echo "完成！请开启一个新的 shell session 来查看效果。"
