# 备份原始 stunnel
mv ~/.local/bin/stunnel ~/.local/bin/stunnel.bin

# 创建包装脚本
cat > ~/.local/bin/stunnel << 'EOF'
#!/bin/bash
export LD_LIBRARY_PATH="$HOME/.local/lib64:$HOME/.local/lib:$LD_LIBRARY_PATH"
exec "$HOME/.local/bin/stunnel.bin" "$@"
EOF

chmod +x ~/.local/bin/stunnel
