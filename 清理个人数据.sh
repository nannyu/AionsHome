#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "========================================"
echo "  清理个人数据（打包给朋友前使用）"
echo "========================================"
echo ""
echo "  将删除以下内容:"
echo "    - 聊天数据库 (chat.db)"
echo "    - 导出的聊天记录 (chats/)"
echo "    - 监控日志 (monitor_logs/)"
echo "    - 摄像头截图 (screenshots/)"
echo "    - 上传的图片/视频 (uploads/)"
echo "    - 活动日志 (activity_logs/)"
echo "    - TTS 语音缓存 (tts_cache/)"
echo "    - 临时文件 (tmp/)"
echo "    - 聊天状态 + 记忆锚点"
echo "    - 定位配置 + 定位状态（含家坐标/高德Key）"
echo "    - 世界书人设 (重置为空白)"
echo "    - 小剧场角色预设 (theater_personas.json)"
echo "    - 奥罗斯幽林游戏数据 (ghost_forest/)"
echo "    - 阅读书籍数据 (books/)"
echo "    - API Key (需要朋友自己填)"
echo "    - 虚拟环境 (朋友需重新安装)"
echo "    - 源码中硬编码的 API Key (重置为空)"
echo "    - 火山引擎 TTS 配置 + 输出"
echo "    - 个人笔记/备份文件"
echo "    - .vscode 配置"
echo ""
echo "  !! 请确认这是【复制出来的副本】!!"
echo "  !! 不要在你自己的原始文件夹里运行 !!"
echo ""
read -p "确认清理? 输入 Y 继续: " CONFIRM
if [ "$CONFIRM" != "Y" ]; then
    echo "已取消。"
    exit 0
fi

echo ""
echo "正在清理..."

# ── aion-chat/data/ ──
rm -f "aion-chat/data/chat.db"
rm -f "aion-chat/data/chat_status.json"
rm -f "aion-chat/data/digest_anchor.json"
rm -f "aion-chat/data/cam_config.json"
rm -f "aion-chat/data/location_status.json"

rm -rf "aion-chat/data/chats"
mkdir -p "aion-chat/data/chats"

rm -rf "aion-chat/data/monitor_logs"
mkdir -p "aion-chat/data/monitor_logs"

rm -rf "aion-chat/data/screenshots"
mkdir -p "aion-chat/data/screenshots"

rm -rf "aion-chat/data/uploads"
mkdir -p "aion-chat/data/uploads"

rm -rf "aion-chat/data/activity_logs"
mkdir -p "aion-chat/data/activity_logs"

rm -rf "aion-chat/data/tts_cache"
mkdir -p "aion-chat/data/tts_cache"

rm -rf "aion-chat/data/tmp"
mkdir -p "aion-chat/data/tmp"

# ── 清理奥罗斯幽林游戏数据 ──
rm -rf "aion-chat/data/ghost_forest"
mkdir -p "aion-chat/data/ghost_forest"

# ── 清理阅读书籍数据 ──
rm -rf "aion-chat/data/books"
mkdir -p "aion-chat/data/books"

# ── 清理小剧场角色预设 ──
rm -f "aion-chat/data/theater_personas.json"

# 重置 settings.json（清空所有 API Key）
echo '{}' > "aion-chat/data/settings.json"

# 重置世界书人设
echo '{"ai_persona": "", "user_persona": "", "ai_name": "AI", "user_name": ""}' > "aion-chat/data/worldbook.json"

# 重置定位配置（清空高德Key和家坐标）
echo '{"amap_key": "", "home_lng": 0, "home_lat": 0, "home_threshold": 500, "heartbeat_outdoor_min": 5, "heartbeat_home_min": 30, "poi_types": {"餐饮美食": "050000", "风景名胜": "110000", "休闲娱乐": "100000", "购物": "060000"}, "poi_radius": 2000, "enabled": false, "quiet_hours_enabled": true, "quiet_hours_start": "00:00", "quiet_hours_end": "10:00", "movement_threshold": 500}' > "aion-chat/data/location_config.json"

# ── 删除个人笔记/备份文件 ──
rm -f "自己看的存档.txt"
rm -f "MW_RAG_Backup_2026-04-04.json"
rm -f "import_mw_rag.py"
rm -f "fix_schedules.py"

# ── 删除 Active 独立监控截图 ──
rm -rf "Active/screenshots"
mkdir -p "Active/screenshots"

# ── 删除 .vscode 配置 ──
rm -rf ".vscode"

# ── 清理 Android App 硬编码 IP ──
JAVA_DIR="AionApp/app/src/main/java/com/aion/chat"
if [ -f "$JAVA_DIR/LauncherActivity.java" ]; then
    sed -i '' -E 's|http://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:8080/chat|http://192.168.xx.xxx:8080/chat|g' "$JAVA_DIR/LauncherActivity.java" 2>/dev/null || \
    sed -i -E 's|http://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:8080/chat|http://192.168.xx.xxx:8080/chat|g' "$JAVA_DIR/LauncherActivity.java"
fi
if [ -f "$JAVA_DIR/WebViewActivity.java" ]; then
    sed -i '' -E 's|http://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:8080/chat|http://192.168.xx.xxx:8080/chat|g' "$JAVA_DIR/WebViewActivity.java" 2>/dev/null || \
    sed -i -E 's|http://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:8080/chat|http://192.168.xx.xxx:8080/chat|g' "$JAVA_DIR/WebViewActivity.java"
fi
if [ -f "$JAVA_DIR/AionPushService.java" ]; then
    sed -i '' -E 's|http://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:8080/chat|http://192.168.xx.xxx:8080/chat|g' "$JAVA_DIR/AionPushService.java" 2>/dev/null || \
    sed -i -E 's|http://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:8080/chat|http://192.168.xx.xxx:8080/chat|g' "$JAVA_DIR/AionPushService.java"
fi

# ── 删除虚拟环境 ──
rm -rf ".venv"

echo ""
echo "========================================"
echo "  清理完成!"
echo "  朋友拿到后按顺序操作:"
echo "  1. 运行「./一键安装环境.sh」"
echo "  2. 运行「./一键启动.sh」"
echo "  3. 浏览器打开 localhost:8080"
echo "  4. 设置里填 API Key"
echo "========================================"
