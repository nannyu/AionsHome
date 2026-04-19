#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "========================================"
echo "  Aion Chat 环境一键安装"
echo "========================================"
echo ""

# ────────────────────────────────────────
# 1. 检查 Python 是否已安装
# ────────────────────────────────────────
echo "[1/4] 检查 Python 环境..."
if ! command -v python3 &>/dev/null; then
    echo ""
    echo "❌ 未检测到 Python！请先安装 Python 3.10 或更高版本。"
    echo ""
    echo "   macOS:   brew install python3"
    echo "   Ubuntu:  sudo apt install python3 python3-venv python3-pip"
    echo "   下载地址: https://www.python.org/downloads/"
    echo ""
    exit 1
fi
PYVER=$(python3 --version 2>&1 | awk '{print $2}')
echo "   ✅ 检测到 Python $PYVER"

# ────────────────────────────────────────
# 2. 检查 venv 模块 + 创建虚拟环境
# ────────────────────────────────────────
echo ""
echo "[2/5] 检查虚拟环境模块..."
if ! python3 -c "import venv" &>/dev/null; then
    echo ""
    echo "❌ Python 的 venv 模块不可用！"
    echo ""
    echo "   Ubuntu/Debian: sudo apt install python3-venv"
    echo "   Fedora:        sudo dnf install python3-venv"
    echo "   macOS:         python3 应自带 venv，请检查安装是否完整"
    echo ""
    exit 1
fi
echo "   ✅ venv 模块正常"

echo ""
echo "[3/5] 创建虚拟环境 (.venv)..."
NEED_VENV=1
if [ -f ".venv/bin/activate" ]; then
    VENV_REAL=$(cd .venv && pwd)
    EXPECTED_REAL=$(pwd)/.venv
    if [ "$VENV_REAL" = "$EXPECTED_REAL" ]; then
        NEED_VENV=0
        echo "   虚拟环境已存在且路径正确，跳过创建"
    else
        echo "   虚拟环境路径不匹配（可能是从别处复制的），正在重建..."
        rm -rf .venv
    fi
fi
if [ "$NEED_VENV" = "1" ]; then
    python3 -m venv .venv
    if [ $? -ne 0 ]; then
        echo ""
        echo "❌ 创建虚拟环境失败！"
        exit 1
    fi
    echo "   虚拟环境创建成功"
fi

# ────────────────────────────────────────
# 3. 安装依赖
# ────────────────────────────────────────
echo ""
echo "[4/5] 安装 Python 依赖包（首次可能需要几分钟）..."
.venv/bin/pip install -r aion-chat/requirements.txt -q
if [ $? -ne 0 ]; then
    echo ""
    echo "❌ 依赖安装失败！"
    echo ""
    echo "   常见原因及解决方法："
    echo ""
    echo "   1. 网络问题 → 尝试使用国内镜像："
    echo "      .venv/bin/pip install -r aion-chat/requirements.txt -i https://mirrors.aliyun.com/pypi/simple/"
    echo ""
    echo "   2. 缺少系统库 → Linux 需要："
    echo "      sudo apt install portaudio19-dev python3-dev build-essential"
    echo ""
    exit 1
fi
echo "   ✅ 所有依赖安装完成"

# ────────────────────────────────────────
# 5. 完成
# ────────────────────────────────────────
echo ""
echo "[5/5] 检查安装结果..."
.venv/bin/python -c "import fastapi; print('   FastAPI', fastapi.__version__)"
.venv/bin/python -c "import cv2; print('   OpenCV ', cv2.__version__)"
.venv/bin/python -c "import numpy; print('   NumPy  ', numpy.__version__)"
.venv/bin/python -c "import pyncm; print('   PyNCM   OK')"
.venv/bin/python -c "import psutil; print('   psutil ', psutil.__version__)"
.venv/bin/python -c "import ebooklib; print('   ebooklib OK')"
.venv/bin/python -c "import bs4; print('   BeautifulSoup4 OK')"

echo ""
echo "========================================"
echo "  ✅ 环境安装完成！"
echo "  现在可以运行「./一键启动.sh」了"
echo "========================================"
