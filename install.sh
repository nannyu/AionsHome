#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "========================================"
echo "  Aion Chat - Environment Setup"
echo "========================================"
echo ""

# ----------------------------------------
# 1. Check Python
# ----------------------------------------
echo "[1/5] Checking Python ..."
if ! command -v python3 &>/dev/null; then
    echo ""
    echo "[ERROR] Python not found!"
    echo ""
    echo "   Please install Python 3.10+ from:"
    echo "   https://www.python.org/downloads/"
    echo ""
    exit 1
fi
PYVER=$(python3 --version 2>&1 | awk '{print $2}')
echo "   [OK] Python $PYVER"

# ----------------------------------------
# 2. Check venv module
# ----------------------------------------
echo ""
echo "[2/5] Checking venv module ..."
if ! python3 -c "import venv" &>/dev/null; then
    echo ""
    echo "[ERROR] Python venv module is not available!"
    echo ""
    echo "   On Debian/Ubuntu: sudo apt install python3-venv"
    echo "   On macOS: python3 should include venv by default."
    echo ""
    exit 1
fi
echo "   [OK] venv module ready"

# ----------------------------------------
# 3. Create virtual environment
# ----------------------------------------
echo ""
echo "[3/5] Creating virtual environment (.venv) ..."
NEED_VENV=1
if [ -f ".venv/bin/activate" ]; then
    VENV_REAL=$(cd .venv && pwd)
    EXPECTED_REAL=$(pwd)/.venv
    if [ "$VENV_REAL" = "$EXPECTED_REAL" ]; then
        NEED_VENV=0
        echo "   .venv already exists, skipping"
    else
        echo "   .venv path mismatch, rebuilding ..."
        rm -rf .venv
    fi
fi
if [ "$NEED_VENV" = "1" ]; then
    python3 -m venv .venv
    if [ $? -ne 0 ]; then
        echo ""
        echo "[ERROR] Failed to create virtual environment!"
        exit 1
    fi
    echo "   Virtual environment created"
fi

# ----------------------------------------
# 4. Install dependencies
# ----------------------------------------
echo ""
echo "[4/5] Installing dependencies (may take a few minutes) ..."
echo "   Trying Aliyun mirror first for speed ..."
.venv/bin/pip install -r aion-chat/requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ -q 2>/dev/null || {
    echo ""
    echo "   Mirror failed, retrying with default PyPI ..."
    .venv/bin/pip install -r aion-chat/requirements.txt -q
}
if [ $? -ne 0 ]; then
    echo ""
    echo "[ERROR] Dependency installation failed!"
    echo ""
    echo "   Common fixes:"
    echo ""
    echo "   1. Network issue - try manually:"
    echo "      .venv/bin/pip install -r aion-chat/requirements.txt -i https://mirrors.aliyun.com/pypi/simple/"
    echo ""
    echo "   2. On Linux, you may need system packages:"
    echo "      sudo apt install portaudio19-dev python3-dev"
    echo "      sudo yum install portaudio-devel python3-devel"
    echo ""
    exit 1
fi
echo "   [OK] All dependencies installed"

# ----------------------------------------
# 5. Verify
# ----------------------------------------
echo ""
echo "[5/5] Verifying installation ..."
.venv/bin/python -c "import fastapi; print('   FastAPI', fastapi.__version__)"
.venv/bin/python -c "import cv2; print('   OpenCV ', cv2.__version__)"
.venv/bin/python -c "import numpy; print('   NumPy  ', numpy.__version__)"
.venv/bin/python -c "import pyncm; print('   PyNCM   OK')"
.venv/bin/python -c "import psutil; print('   psutil ', psutil.__version__)"
.venv/bin/python -c "import ebooklib; print('   ebooklib OK')"
.venv/bin/python -c "import bs4; print('   BeautifulSoup4 OK')"

echo ""
echo "========================================"
echo "  [OK] Setup complete!"
echo "  You can now run the app."
echo "========================================"
