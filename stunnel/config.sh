#!/usr/bin/env bash
set -euo pipefail

CONNECT="${CONNECT}"  # 目标服务器地址和端口，例如 server.example.com:443

# 创建配置目录
mkdir -p ~/.local/etc/stunnel

# 创建 Aim mTLS 配置文件
cat > ~/.local/etc/stunnel/stunnel.conf << 'EOF'
; Aim mTLS 客户端配置
foreground = yes
pid = 
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[aim-server]
client = yes
accept = 127.0.0.1:53800
connect = ${CONNECT}

; 客户端证书（用于 mTLS 认证）
cert = ${HOME}/.certs/aim/client.pem

; CA 证书（用于验证服务器）
CAfile = ${HOME}/.certs/aim/ca.crt
verifyChain = yes
EOF

# 替换 ${HOME} 为实际路径
sed -i "s|\${HOME}|$HOME|g" ~/.local/etc/stunnel/stunnel.conf

echo "配置文件已创建: ~/.local/etc/stunnel/stunnel.conf"
