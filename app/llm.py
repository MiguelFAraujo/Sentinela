"""Sentinela — Integração com LLM local via Ollama."""

from __future__ import annotations

import logging

import requests

from app.config import MODELO, URL_OLLAMA_API

logger = logging.getLogger(__name__)

# ── Prompt do sistema ────────────────────────────────────────
_SYSTEM_PROMPT = (
    "Você é um Analista de SOC (Security Operations Center) especializado "
    "em análise de superfície de ataque. Responda sempre em português, de "
    "forma objetiva e técnica."
)

_USER_PROMPT_TEMPLATE = """\
Analise os seguintes serviços REAIS detectados em um host:

{dados}

Com base nos dados acima:
1. Identifique quais serviços representam risco em redes públicas (Wi-Fi).
2. Indique se as portas de sistema (135/445) estão em estado normal.
3. Dê uma recomendação de segurança concisa.
"""


def analisar_com_ia(dados_tecnicos: str, timeout: int = 120) -> str:
    """Envia dados de varredura para o LLM local e retorna a análise."""
    logger.info("Enviando dados para %s em %s", MODELO, URL_OLLAMA_API)

    payload = {
        "model": MODELO,
        "system": _SYSTEM_PROMPT,
        "prompt": _USER_PROMPT_TEMPLATE.format(dados=dados_tecnicos),
        "stream": False,
    }

    try:
        resp = requests.post(URL_OLLAMA_API, json=payload, timeout=timeout)
        resp.raise_for_status()
        body = resp.json()

        if "error" in body:
            return f"Erro retornado pelo Ollama: {body['error']}"

        return body.get("response", f"IA não retornou resposta válida. Raw: {body}")

    except requests.exceptions.ConnectionError:
        return "Erro de Conexão: O servidor Ollama parece estar offline."
    except requests.exceptions.Timeout:
        return "Timeout: O modelo demorou muito para responder."
    except requests.exceptions.HTTPError as exc:
        return f"Erro HTTP do Ollama ({exc.response.status_code}): {exc.response.text}"
    except Exception as exc:
        logger.exception("Erro inesperado na integração IA")
        return f"Erro interno na integração IA: {exc}"
