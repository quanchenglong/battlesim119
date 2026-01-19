#!/bin/bash

echo "========================================"
echo "  战斗模拟器 - 局域网服务器启动工具"
echo "========================================"
echo ""

# 检查Python是否安装
if ! command -v python3 &> /dev/null; then
    echo "[错误] 未检测到Python3，请先安装Python"
    exit 1
fi

# 获取本机IP地址
IP=$(hostname -I | awk '{print $1}')

echo ""
echo "========================================"
echo "  访问地址"
echo "========================================"
echo "  本机访问: http://localhost:8000"
echo "  局域网访问: http://$IP:8000"
echo "========================================"
echo ""
echo "[提示] 确保防火墙允许8000端口访问"
echo "[提示] 同一局域网内的设备可使用局域网地址访问"
echo ""
echo "正在启动服务器..."
echo "按 Ctrl+C 停止服务器"
echo ""

# 切换到脚本所在目录
cd "$(dirname "$0")"

# 启动Python HTTP服务器
python3 -m http.server 8000
