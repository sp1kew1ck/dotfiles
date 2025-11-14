#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status. Fail on unset variables. Fail if a command in a pipeline fails.
set -euo pipefail

# ===============================
# Preset variables
# ===============================

# Assumes the root directory of your dotfiles repository. Adjust this path as needed.
DOTFILES_BASE_DIR="$HOME/dotfiles"
# Here, we assume the source files are located in ~/dotfiles/bash
SOURCE_DIR="$DOTFILES_BASE_DIR/bash"

# List of configuration files to process (source filename -> target dotfile name)
# Note: Target filenames are dotfiles (hidden files) starting with a dot.
declare -A FILES_TO_INSTALL=(
    ["bashrc"]=".bashrc"
    ["exports"]=".exports"
    ["aliases"]=".aliases"
    ["functions"]=".functions"
)

echo "Starting Bash configuration deployment..."

# 1. Check if the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "ERROR: Source directory '$SOURCE_DIR' does not exist. Please modify the DOTFILES_BASE_DIR variable in the script."
    exit 1
fi

# 2. Loop through each configuration file
for SRC_FILE in "${!FILES_TO_INSTALL[@]}"; do
    TARGET_FILE_NAME="${FILES_TO_INSTALL[$SRC_FILE]}"

    SRC_PATH="$SOURCE_DIR/$SRC_FILE"
    TARGET_PATH="$HOME/$TARGET_FILE_NAME"
    BACKUP_PATH="${TARGET_PATH}.bak"

    echo "---"
    echo "Processing file: $TARGET_FILE_NAME"

    # Check if the source file exists (ensure the file to be linked is present)
    if [ ! -f "$SRC_PATH" ]; then
        echo "WARNING: Source file '$SRC_PATH' does not exist. Skipping this file."
        continue
    fi

    # Check if the target file already exists (file or symlink)
    if [ -L "$TARGET_PATH" ] || [ -f "$TARGET_PATH" ]; then
        echo "  Target file already exists: $TARGET_FILE_NAME"
        
        # If it's a symlink, remove the old link first
        if [ -L "$TARGET_PATH" ]; then
            echo "  Existing file is a symlink, removing..."
            rm "$TARGET_PATH"
        else
            # If it's a regular file, create a backup
            echo "  Creating backup at: $BACKUP_PATH"
            # Ensure old backup is deleted before moving to prevent issues
            rm -f "$BACKUP_PATH"
            mv "$TARGET_PATH" "$BACKUP_PATH"
        fi
    fi

    # 3. Create the symlink
    echo "  Creating symlink: $TARGET_PATH -> $SRC_PATH"
    ln -s "$SRC_PATH" "$TARGET_PATH"

done

echo "---"
echo "Bash configuration deployment Successfully complete!"
echo "Tips: Please test in a new terminal, or run 'source ~/.bashrc' to apply changes immediately."

# 4. Force reload configuration (only effective for the current shell session)
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
    echo "Current shell session reloaded ~/.bashrc."
fi