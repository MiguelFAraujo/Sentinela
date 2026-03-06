"""Sentinela — Local LLM integration via Ollama."""

from __future__ import annotations

import logging

import requests

from app.config import MODEL, OLLAMA_API_URL

logger = logging.getLogger(__name__)

# ── System Prompt ────────────────────────────────────────────
_SYSTEM_PROMPT = (
    "You are a SOC (Security Operations Center) Analyst specialized in "
    "attack surface analysis. Always respond in a concise and technical manner."
)

_USER_PROMPT_TEMPLATE = """\
Analyze the following REAL services detected on a host:

{data}

Based on the data above:
1. Identify which services pose a risk on public networks (Wi-Fi).
2. Indicate whether system ports (135/445) are in a normal state.
3. Provide a concise security recommendation.
"""


def analyze_with_ai(technical_data: str, timeout: int = 120) -> str:
    """Send scan data to the local LLM and return the analysis."""
    logger.info("Sending data to %s at %s", MODEL, OLLAMA_API_URL)

    payload = {
        "model": MODEL,
        "system": _SYSTEM_PROMPT,
        "prompt": _USER_PROMPT_TEMPLATE.format(data=technical_data),
        "stream": False,
    }

    try:
        resp = requests.post(OLLAMA_API_URL, json=payload, timeout=timeout)
        resp.raise_for_status()
        body = resp.json()

        if "error" in body:
            return f"Error returned by Ollama: {body['error']}"

        return body.get("response", f"AI did not return a valid response. Raw: {body}")

    except requests.exceptions.ConnectionError:
        return "Connection Error: The Ollama server appears to be offline."
    except requests.exceptions.Timeout:
        return "Timeout: The model took too long to respond."
    except requests.exceptions.HTTPError as exc:
        return f"HTTP Error from Ollama ({exc.response.status_code}): {exc.response.text}"
    except Exception as exc:
        logger.exception("Unexpected error in AI integration")
        return f"Internal error in AI integration: {exc}"
