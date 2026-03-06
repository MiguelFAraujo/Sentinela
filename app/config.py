"""Sentinela — Centralized configuration."""

import os
from pathlib import Path

# ── AI Model ──────────────────────────────────────────────────
MODEL: str = os.getenv("MODELO", "llama3")
OLLAMA_HOST: str = os.getenv("OLLAMA_HOST", "http://localhost:11434")

# Ensure full API URL
OLLAMA_API_URL: str = (
    OLLAMA_HOST
    if OLLAMA_HOST.endswith("/api/generate")
    else f"{OLLAMA_HOST}/api/generate"
)

# ── Scanner ───────────────────────────────────────────────────
_IS_DOCKER = Path("/.dockerenv").exists()

NMAP_PATH: list[str] = (
    ["nmap"] if _IS_DOCKER else [r"C:\Program Files (x86)\Nmap\nmap.exe"]
)

# ── Server ────────────────────────────────────────────────────
HOST: str = os.getenv("SENTINELA_HOST", "0.0.0.0")
PORT: int = int(os.getenv("SENTINELA_PORT", "3333"))
VERSION: str = "3.1.1"
