#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status. Fail on unset variables. Fail if a command in a pipeline fails.
set -euo pipefail

echo "Starting Miniforge Installation and Configuration..."

# --- Conda Existence Check ---
# check if conda can be use in PATH
if command -v conda &> /dev/null; then
    echo "Conda appears to be already installed ($(command -v conda))."
    echo "Exiting installation script to prevent re-installation."
    exit 0
fi
# -----------------------------

MINIFORGE_INSTALLER="Miniforge3-Linux-x86_64.sh"
MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download/${MINIFORGE_INSTALLER}"
# 定义要检查和追加的 Conda 激活行 (使用 $HOME 以确保路径正确)
# CONDA_EVAL_LINE='eval "$($HOME/miniforge3/bin/conda shell.bash hook)"'
BASHRC="$HOME/.bashrc"

# 1. install miniforge

cd

echo "1. Downloading Miniforge3 installer..."
wget "$MINIFORGE_URL"

echo "2. Running Miniforge3 installation script (assuming default path: $HOME/miniforge3)..."
bash "$MINIFORGE_INSTALLER"
rm -f "$MINIFORGE_INSTALLER"

# 2. initialize conda for your shell

echo "3. Running 'conda init' for standard shell setup..."
export PATH="$HOME/miniforge3/bin:$PATH"
conda init

echo "4. Checking for single-line Conda hook in $BASHRC..."
# -q: quiet mode
# -F: fixed string search
# if ! grep -qF "$CONDA_EVAL_LINE" "$BASHRC"; then
#     echo "Specific Conda eval hook not found. Appending it to $BASHRC..."
    
#     # append to .bashrc
#     echo "" >> "$BASHRC"
#     echo "# --- Conda Immediate Activation Hook ---" >> "$BASHRC"
#     echo "# (This line allows immediate use of the base environment in new shells)" >> "$BASHRC"
#     echo "$CONDA_EVAL_LINE" >> "$BASHRC"
# else
#     echo "Specific Conda eval hook already present in $BASHRC. No changes made to the hook."
# fi

echo "Miniforge installation and configuration successfully complete."
echo "Please run 'source $BASHRC' or restart your terminal to activate Conda."