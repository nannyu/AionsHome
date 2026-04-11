"""
WebSocket 连接管理器
"""

import json, logging
from fastapi import WebSocket

log = logging.getLogger("ws")


class ConnectionManager:
    def __init__(self):
        self.active: list[WebSocket] = []

    async def connect(self, ws: WebSocket):
        await ws.accept()
        self.active.append(ws)
        log.info("WS connected, total=%d", len(self.active))

    def disconnect(self, ws: WebSocket):
        if ws in self.active:
            self.active.remove(ws)
        log.info("WS disconnected, total=%d", len(self.active))

    async def broadcast(self, data: dict, exclude: WebSocket = None):
        msg = json.dumps(data, ensure_ascii=False)
        msg_type = data.get("type", "unknown")
        targets = [ws for ws in self.active.copy() if ws is not exclude]
        sent = 0
        failed = 0
        for ws in targets:
            try:
                await ws.send_text(msg)
                sent += 1
            except Exception as e:
                log.warning("WS send failed: %s", e)
                if ws in self.active:
                    self.active.remove(ws)
                failed += 1
        log.info("broadcast type=%s sent=%d failed=%d total_clients=%d",
                 msg_type, sent, failed, len(self.active))


manager = ConnectionManager()
