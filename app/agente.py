"""Sentinela — Main agent (API + CLI)."""

from __future__ import annotations

import argparse
import logging
import os

from fastapi import FastAPI
from pydantic import BaseModel

from app.config import HOST, PORT, VERSION
from app.llm import analyze_with_ai
from app.scanner import smart_audit, get_local_ip

# ── Logging ───────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s │ %(levelname)-7s │ %(name)s │ %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger("sentinela")

# ── FastAPI ───────────────────────────────────────────────────
app = FastAPI(
    title="Sentinela EDR",
    description="Security Monitoring and AI-Powered Analysis API",
    version=VERSION,
)


# ── Models ────────────────────────────────────────────────────
class ScanResponse(BaseModel):
    target: str
    status: str
    analysis: str | None = None
    raw_data: str | None = None
    error: str | None = None


# ── Core ──────────────────────────────────────────────────────
def run_scan(target_host: str) -> dict:
    """Execute a full scan and call the LLM for analysis."""
    logger.info("━" * 50)
    logger.info("🚀 SENTINELA PROTOCOL (Target: %s)", target_host)
    logger.info("━" * 50)

    try:
        data = smart_audit(target_host)

        analysis = None
        if data != "No open ports detected.":
            analysis = analyze_with_ai(data)
            logger.info("🛡️  REPORT:\n%s", analysis)
        else:
            logger.info("✅ System hardened — no exposed ports.")

        return {
            "target": target_host,
            "status": "success",
            "analysis": analysis,
            "raw_data": data,
        }
    except Exception as exc:
        logger.exception("Error during scan")
        return {"target": target_host, "status": "error", "error": str(exc)}


def _resolve_target(target: str | None = None) -> str:
    """Resolve the target IP from parameter, env, or auto-detection."""
    return target or os.getenv("TARGET_IP") or get_local_ip()


# ── Endpoints ─────────────────────────────────────────────────
@app.get("/", tags=["Status"])
def root():
    return {"status": "online", "service": "Sentinela EDR", "version": VERSION}


@app.get("/health", tags=["Status"])
def health_check():
    return {"status": "healthy"}


@app.post("/scan", tags=["Operations"], response_model=ScanResponse)
def trigger_scan(target: str | None = None):
    result = run_scan(_resolve_target(target))
    return ScanResponse(**result)


# ── CLI ───────────────────────────────────────────────────────
def main():
    """Command-line entrypoint."""
    parser = argparse.ArgumentParser(
        description="🛡️ Sentinela — EDR with local AI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "command",
        nargs="?",
        default="start_api",
        choices=["scan", "start_api"],
        help="Command to execute (default: start_api)",
    )
    parser.add_argument("--target", help="Target IP for scanning")
    args = parser.parse_args()

    if args.command == "scan":
        run_scan(_resolve_target(args.target))
    else:
        import uvicorn

        logger.info("🌐 Starting API on %s:%d", HOST, PORT)
        uvicorn.run(app, host=HOST, port=PORT)


if __name__ == "__main__":
    main()
