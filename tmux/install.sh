#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status. Fail on unset variables. Fail if a command in a pipeline fails.
set -euo pipefail

# ===============================
# Preset variables
# ===============================

# 假设你的 dotfiles 仓库根目录
DOTFILES_BASE_DIR="${HOME}/dotfiles"
# 假设 tmux 配置文件位于该仓库下的 tmux 子目录
SOURCE_DIR="${DOTFILES_BASE_DIR}/tmux"

# 要安装的文件（源文件名 -> 目标 dotfile 名称）
declare -A FILES_TO_INSTALL=(
    [".tmux.conf"]=".tmux.conf"
    # 如果还有别的 tmux 相关配置，比如 .tmux.conf.local，可加在这里
    # [".tmux.conf.local"]=".tmux.conf.local"
)

echo "Starting tmux configuration deployment..."

# 1. 检查源目录是否存在
if [ ! -d "${SOURCE_DIR}" ]; then
    echo "ERROR: Source directory '${SOURCE_DIR}' does not exist. Please modify the DOTFILES_BASE_DIR or SOURCE_DIR variable in the script."
    exit 1
fi

# 2. 遍历每一个要安装的文件
for SRC_FILE in "${!FILES_TO_INSTALL[@]}"; do
    TARGET_FILE_NAME="${FILES_TO_INSTALL[$SRC_FILE]}"
    SRC_PATH="${SOURCE_DIR}/${SRC_FILE}"
    TARGET_PATH="${HOME}/${TARGET_FILE_NAME}"
    BACKUP_PATH="${TARGET_PATH}.bak"

    echo "---"
    echo "Processing file: ${TARGET_FILE_NAME}"

    # 检查源文件是否存在
    if [ ! -f "${SRC_PATH}" ]; then
        echo "WARNING: Source file '${SRC_PATH}' does not exist. Skipping this file."
        continue
    fi

    # 检查目标文件是否已存在（文件或符号链接）
    if [ -L "${TARGET_PATH}" ] || [ -f "${TARGET_PATH}" ]; then
        echo "  Target file already exists: ${TARGET_FILE_NAME}"

        # 如果是符号链接，先移除旧链接
        if [ -L "${TARGET_PATH}" ]; then
            echo "  Existing target is a symlink, removing it..."
            rm "${TARGET_PATH}"
        else
            # 如果是普通文件，创建备份
            echo "  Creating backup at: ${BACKUP_PATH}"
            rm -f "${BACKUP_PATH}"
            mv "${TARGET_PATH}" "${BACKUP_PATH}"
        fi
    fi

    # 3. 创建符号链接
    echo "  Creating symlink: ${TARGET_PATH} -> ${SRC_PATH}"
    ln -s "${SRC_PATH}" "${TARGET_PATH}"
done

echo "---"
echo "tmux configuration deployment Successfully complete!"
echo "Tips: Please start a new tmux session—or run 'tmux source-file ~/.tmux.conf' inside a tmux session to apply changes."

# 4. （可选）如果当前已在 tmux 会话中，自动重载配置
# 注意：这种方式仅在你当前已经在一个 tmux 会话里时有效
if [ -n "${TMUX:-}" ]; then
    tmux source-file "${HOME}/.tmux.conf"
    echo "Current tmux session reloaded ~/.tmux.conf."
fi

exit 0