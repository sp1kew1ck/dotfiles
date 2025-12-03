#!/usr/bin/env bash
set -euo pipefail

DOTFILES_BASE_DIR="${HOME}/dotfiles"

# 可选环境变量 DRY_RUN=1 表示只是打印操作，不真正执行
DRY_RUN=${DRY_RUN:-0} 

# 安装 dotfiles 模块到 HOME 的通用函数
# 参数:
#   $1 = module 子目录 (相对于 DOTFILES_BASE_DIR)，例如 "bash", "tmux", "config", etc.
#   $2 = 可选，目标根目录，默认是 $HOME
install_module() {
    local module="$1"
    local src_root="${DOTFILES_BASE_DIR}/${module}"
    local target_root="${2:-$HOME}"
    if [ ! -d "$src_root" ]; then
        echo "  [WARN] source module dir '$src_root' not found — skip"
        return
    fi

    echo "Installing module '$module' from '$src_root' ..."

    # 遍历 module 下的所有 文件 (包括子目录)
    # 利用 find 搜索 regular files (也可以 include dirs if you want to link dirs)
    find "$src_root" -type f | while IFS= read -r src_path; do
        # 相对于 module 根目录 (module/...)
        rel_path="${src_path#$src_root/}" # 做前缀匹配与删除，得到文件相对于模块根目录的相对路径
        target_path="${target_root}/${rel_path}"
        target_dir="$(dirname "$target_path")"

        echo "---"
        echo "Processing '$rel_path' --> '$target_path'"

        # 确保目标目录存在
        if [ ! -d "$target_dir" ]; then
            echo "  Creating target directory: $target_dir"
            [ "$DRY_RUN" = "1" ] || mkdir -p "$target_dir"
        fi

        # 如果目标已存在 (文件 / symlink)，先处理
        if [ -L "$target_path" ] || [ -e "$target_path" ]; then
            echo "  Target exists: $target_path"
            if [ -L "$target_path" ]; then
                echo "  Removing existing symlink"
                [ "$DRY_RUN" = "1" ] || rm "$target_path"
            else
                echo "  Backing up existing file to ${target_path}.bak"
                [ "$DRY_RUN" = "1" ] || {
                    rm -f "${target_path}.bak"
                    mv "$target_path" "${target_path}.bak"
                }
            fi
        fi

        # 计算从 HOME 到 src_path 的相对路径（如果 realpath 支持）
        # 如果 realpath 不支持 --relative-to，也可以直接用绝对路径
        if realpath --relative-to="${target_root}" "$src_path" >/dev/null 2>&1; then
            rel_src="$(realpath --relative-to="${target_root}" "$src_path")"
        else
            rel_src="$src_path"
        fi

        echo "  Creating symlink: $target_path -> $rel_src"
        [ "$DRY_RUN" = "1" ] || ln -s "$rel_src" "$target_path"
    done

    echo "Module '$module' installation done."
    echo ""
}

echo "---- Dotfiles install start ----"
echo ""

# 示例：安装多个 module
install_module bash
install_module tmux
# ...你可以继续增加 module ...

echo "---- Done ----"
