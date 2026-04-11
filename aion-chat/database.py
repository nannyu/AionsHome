"""
数据库初始化与连接
"""

import aiosqlite
from config import DB_PATH


async def init_db():
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("""
            CREATE TABLE IF NOT EXISTS conversations (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                model TEXT NOT NULL DEFAULT 'gemini-3-flash',
                created_at REAL NOT NULL,
                updated_at REAL NOT NULL
            )
        """)
        await db.execute("""
            CREATE TABLE IF NOT EXISTS messages (
                id TEXT PRIMARY KEY,
                conv_id TEXT NOT NULL,
                role TEXT NOT NULL,
                content TEXT NOT NULL,
                created_at REAL NOT NULL,
                FOREIGN KEY (conv_id) REFERENCES conversations(id) ON DELETE CASCADE
            )
        """)
        await db.execute("PRAGMA foreign_keys = ON")
        try:
            await db.execute("ALTER TABLE messages ADD COLUMN attachments TEXT DEFAULT ''")
        except:
            pass
        # 性能索引
        await db.execute("CREATE INDEX IF NOT EXISTS idx_messages_conv_id ON messages(conv_id, created_at)")
        await db.execute("CREATE INDEX IF NOT EXISTS idx_conversations_updated ON conversations(updated_at DESC)")
        await db.execute("""
            CREATE TABLE IF NOT EXISTS memories (
                id TEXT PRIMARY KEY,
                content TEXT NOT NULL,
                type TEXT DEFAULT 'event',
                created_at REAL NOT NULL,
                source_conv TEXT,
                embedding BLOB
            )
        """)
        # memories 表新增字段（向后兼容迁移）
        for col, defn in [
            ("keywords", "TEXT DEFAULT ''"),
            ("importance", "REAL DEFAULT 0.5"),
            ("source_start_ts", "REAL"),
            ("source_end_ts", "REAL"),
            ("unresolved", "INTEGER DEFAULT 0"),
        ]:
            try:
                await db.execute(f"ALTER TABLE memories ADD COLUMN {col} {defn}")
            except:
                pass
        # ── 日程/闹铃表 ──
        await db.execute("""
            CREATE TABLE IF NOT EXISTS schedules (
                id TEXT PRIMARY KEY,
                type TEXT NOT NULL,
                trigger_at TEXT NOT NULL,
                content TEXT NOT NULL,
                created_at REAL NOT NULL,
                status TEXT NOT NULL DEFAULT 'active'
            )
        """)
        await db.execute("CREATE INDEX IF NOT EXISTS idx_schedules_status ON schedules(status, trigger_at)")
        # ── 心语表 ──
        await db.execute("""
            CREATE TABLE IF NOT EXISTS heart_whispers (
                id TEXT PRIMARY KEY,
                conv_id TEXT,
                msg_id TEXT,
                content TEXT NOT NULL,
                created_at REAL NOT NULL
            )
        """)
        await db.execute("CREATE INDEX IF NOT EXISTS idx_heart_whispers_created ON heart_whispers(created_at DESC)")
        await db.commit()


def get_db():
    return aiosqlite.connect(DB_PATH)
