#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
fi

echo "========================================"
echo "  Aion Chat  正在启动..."
echo "  http://localhost:8080"
echo "  按 Ctrl+C 停止服务"
echo "========================================"

cd aion-chat
python3 -u main.py
