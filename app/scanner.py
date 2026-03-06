"""Sentinela — Scanner de rede e correlação de processos."""

from __future__ import annotations

import logging
import socket

import nmap
import psutil

from app.config import NMAP_PATH

logger = logging.getLogger(__name__)


def pegar_ip_local() -> str:
    """Retorna o IP local da máquina na rede."""
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        try:
            sock.connect(("8.8.8.8", 1))
            return sock.getsockname()[0]
        except OSError:
            return "127.0.0.1"


def obter_processo_da_porta(porta: int, protocolo: str = "tcp") -> str:
    """Cruza a porta com a lista de conexões ativas para identificar o processo."""
    for conn in psutil.net_connections(kind=protocolo):
        if conn.laddr.port == porta and conn.status == "LISTEN":
            try:
                proc = psutil.Process(conn.pid)
                return f"{proc.name()} (PID: {conn.pid})"
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                return "Processo Oculto/Sistema"
    return "Desconhecido"


def auditoria_inteligente(alvo: str) -> str:
    """Executa varredura Nmap no alvo e correlaciona com processos locais."""
    logger.info("Iniciando varredura em %s", alvo)

    try:
        nm = nmap.PortScanner(nmap_search_path=NMAP_PATH)
    except nmap.PortScannerError:
        nm = nmap.PortScanner()

    nm.scan(alvo, arguments="-F")

    resultados: list[str] = []

    for host in nm.all_hosts():
        logger.info("Host encontrado: %s", host)
        for proto in nm[host].all_protocols():
            for port in sorted(nm[host][proto]):
                estado = nm[host][proto][port]["state"]
                nome_real = obter_processo_da_porta(port)
                logger.info(
                    "Porta %d/%s: %s | Processo: %s", port, proto, estado, nome_real
                )
                resultados.append(
                    f"- Porta {port}/{proto} está {estado.upper()} "
                    f"rodando: {nome_real}"
                )

    return "\n".join(resultados) if resultados else "Nenhuma porta aberta detectada."
