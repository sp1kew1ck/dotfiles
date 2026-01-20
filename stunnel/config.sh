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

; 连接建立阶段（建连 + TLS握手）
; 90秒通常够覆盖不稳定网络的最坏情况（之前建议60-120s，这里取中间值）
TIMEOUTconnect = 90     

; 数据传输阶段（有数据进来时最多等多久）
; 10分钟，适合偶尔传输大文件（图像、histogram等），比默认300s更宽松
TIMEOUTbusy = 600    

; 完全空闲时（只有心跳或长时间无新metric）
; 8小时 —— 推荐起始值
TIMEOUTidle = 28800  
; 更激进选项：43200（12小时）或 86400（24小时）
; 极端持久：0 （永不因空闲超时，需依赖心跳或TCP keepalive来清理僵尸连接）

; 建议额外加上（防止中间设备杀连接）
socket = l:SO_KEEPALIVE=1
socket = r:SO_KEEPALIVE=1
; Linux上更精细的keepalive（可选，防止路由器/NAT杀掉）
socket = l:TCP_KEEPIDLE=180
socket = l:TCP_KEEPINTVL=60
socket = l:TCP_KEEPCNT=5
; 同理对远程端
socket = r:TCP_KEEPIDLE=180
socket = r:TCP_KEEPINTVL=60
socket = r:TCP_KEEPCNT=5

; 启用重试
retry = yes

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
