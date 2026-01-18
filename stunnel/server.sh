#!/usr/bin/env bash
set -euo pipefail

CERT_DIR="${CERT_DIR:-$HOME/.certs/aim/mtls}"
USERNAME="${USERNAME}"          # 用于组织名等
SERVER_IP="${SERVER_IP}"        # 服务器的公网 IP 地址
CA_CN="${CA_CN:-Aim CA}"
CA_O="${CA_O:-$USERNAME}"
SERVER_CN="${SERVER_CN:-$SERVER_IP}"   # 如果你想用主机名可改为主机名
CLIENT_CN="${CLIENT_CN:-aim-client}"



# 在远程服务器上执行
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

# 1. 生成 CA（证书颁发机构）
openssl genrsa -out ca.key 4096
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt \
    -subj "/CN=${CA_CN}/O=${CA_O}"

# 2. 生成服务器证书（用 IP 作为 CN）
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr \
    -subj "/CN=${SERVER_CN}/O=${CA_O}"

# 创建扩展文件（支持 IP 地址）
cat > server_ext.cnf <<EOF
subjectAltName = IP:${SERVER_IP}
EOF

openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out server.crt -extfile server_ext.cnf

# 3. 生成客户端证书
openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr \
    -subj "/CN=${CLIENT_CN}/O=${CA_O}"
openssl x509 -req -days 3650 -in client.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out client.crt

# 4. 合并客户端证书和密钥（stunnel 需要）
cat client.crt client.key > client.pem

# 5. 设置权限
chmod 600 *.key *.pem
