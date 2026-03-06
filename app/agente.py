"""Sentinela — Agente principal (API + CLI)."""

from __future__ import annotations

import argparse
import logging
import os
import sys

from fastapi import FastAPI
from pydantic import BaseModel

from app.config import HOST, PORT, VERSION
from app.llm import analisar_com_ia
from app.scanner import auditoria_inteligente, pegar_ip_local

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
    description="API de Monitoramento e Análise de Segurança com IA Local",
    version=VERSION,
)


# ── Modelos ───────────────────────────────────────────────────
class ScanResponse(BaseModel):
    target: str
    status: str
    analysis: str | None = None
    raw_data: str | None = None
    error: str | None = None


# ── Core ──────────────────────────────────────────────────────
def executar_varredura(host_alvo: str) -> dict:
    """Executa varredura completa e chama o LLM para análise."""
    logger.info("━" * 50)
    logger.info("🚀 PROTOCOLO SENTINELA (Target: %s)", host_alvo)
    logger.info("━" * 50)

    try:
        dados = auditoria_inteligente(host_alvo)

        analise = None
        if dados != "Nenhuma porta aberta detectada.":
            analise = analisar_com_ia(dados)
            logger.info("🛡️  RELATÓRIO:\n%s", analise)
        else:
            logger.info("✅ Sistema blindado — nenhuma porta exposta.")

        return {
            "target": host_alvo,
            "status": "success",
            "analysis": analise,
            "raw_data": dados,
        }
    except Exception as exc:
        logger.exception("Erro durante varredura")
        return {"target": host_alvo, "status": "error", "error": str(exc)}


def _resolver_alvo(target: str | None = None) -> str:
    """Resolve o IP alvo a partir do parâmetro, env ou detecção automática."""
    return target or os.getenv("TARGET_IP") or pegar_ip_local()


# ── Endpoints ─────────────────────────────────────────────────
@app.get("/", tags=["Status"])
def root():
    return {"status": "online", "service": "Sentinela EDR", "version": VERSION}


@app.get("/health", tags=["Status"])
def health_check():
    return {"status": "healthy"}


@app.post("/scan", tags=["Operations"], response_model=ScanResponse)
def trigger_scan(target: str | None = None):
    resultado = executar_varredura(_resolver_alvo(target))
    return ScanResponse(**resultado)


# ── CLI ───────────────────────────────────────────────────────
def main():
    """Entrypoint de linha de comando."""
    parser = argparse.ArgumentParser(
        description="🛡️ Sentinela — EDR com IA local",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "comando",
        nargs="?",
        default="start_api",
        choices=["scan", "start_api"],
        help="Comando a executar (padrão: start_api)",
    )
    parser.add_argument("--target", help="IP alvo para varredura")
    args = parser.parse_args()

    if args.comando == "scan":
        executar_varredura(_resolver_alvo(args.target))
    else:
        import uvicorn

        logger.info("🌐 Iniciando API em %s:%d", HOST, PORT)
        uvicorn.run(app, host=HOST, port=PORT)


if __name__ == "__main__":
    main()
