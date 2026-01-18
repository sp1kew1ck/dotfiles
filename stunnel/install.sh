#!/usr/bin/env bash
set -euo pipefail

STUNNEL_VERSION=stunnel-5.76
OPENSSL_VERSION=openssl-3.5.4
PREFIX="$HOME/.local"

cd /tmp

# 清理之前的下载
rm -f openssl-*.tar.gz* stunnel-*.tar.gz*
rm -rf openssl-*/ stunnel-*/

# 1. 编译安装 OpenSSL（如果不存在）
if [ ! -f "$PREFIX/lib64/libssl.so" ]; then
    echo "=== 下载并编译 OpenSSL ==="
    wget --no-clobber "https://github.com/openssl/openssl/releases/download/${OPENSSL_VERSION}/${OPENSSL_VERSION}.tar.gz"
    
    if ! tar tzf "${OPENSSL_VERSION}.tar.gz" > /dev/null 2>&1; then
        echo "错误：OpenSSL 下载文件损坏，请重试"
        rm -f "${OPENSSL_VERSION}.tar.gz"
        exit 1
    fi
    
    tar xzf "${OPENSSL_VERSION}.tar.gz"
    cd "${OPENSSL_VERSION}"
    ./config --prefix="$PREFIX" --openssldir="$PREFIX/ssl" shared -Wl,-rpath,"$PREFIX/lib64"
    make -j$(nproc)
    make install
    cd /tmp
fi

# 2. 编译安装 stunnel（使用 rpath 嵌入库路径）
echo "=== 下载并编译 stunnel ==="
wget --no-clobber "https://www.stunnel.org/downloads/${STUNNEL_VERSION}.tar.gz"

if ! tar tzf "${STUNNEL_VERSION}.tar.gz" > /dev/null 2>&1; then
    echo "错误：stunnel 下载文件损坏，请重试"
    rm -f "${STUNNEL_VERSION}.tar.gz"
    exit 1
fi

tar xzf "${STUNNEL_VERSION}.tar.gz"
cd "${STUNNEL_VERSION}"

# 关键：添加 LDFLAGS 嵌入 rpath
export LDFLAGS="-Wl,-rpath,$PREFIX/lib64 -L$PREFIX/lib64"
export CPPFLAGS="-I$PREFIX/include"
export PKG_CONFIG_PATH="$PREFIX/lib64/pkgconfig"

./configure --prefix="$PREFIX" --with-ssl="$PREFIX"
make -j$(nproc)
make install

echo "=== 安装完成 ==="
echo "stunnel 路径: $PREFIX/bin/stunnel"

# 验证
echo "=== 验证安装 ==="
"$PREFIX/bin/stunnel" -version