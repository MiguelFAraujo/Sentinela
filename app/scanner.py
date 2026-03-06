"""Sentinela — Network scanner and process correlation."""

from __future__ import annotations

import logging
import socket

import nmap
import psutil

from app.config import NMAP_PATH

logger = logging.getLogger(__name__)


def get_local_ip() -> str:
    """Return the local IP address of the machine on the network."""
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        try:
            sock.connect(("8.8.8.8", 1))
            return sock.getsockname()[0]
        except OSError:
            return "127.0.0.1"


def get_process_by_port(port: int, protocol: str = "tcp") -> str:
    """Cross-reference a port with active connections to identify the process."""
    for conn in psutil.net_connections(kind=protocol):
        if conn.laddr.port == port and conn.status == "LISTEN":
            try:
                proc = psutil.Process(conn.pid)
                return f"{proc.name()} (PID: {conn.pid})"
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                return "Hidden/System Process"
    return "Unknown"


def smart_audit(target: str) -> str:
    """Run an Nmap scan on the target and correlate with local processes."""
    logger.info("Starting scan on %s", target)

    try:
        nm = nmap.PortScanner(nmap_search_path=NMAP_PATH)
    except nmap.PortScannerError:
        nm = nmap.PortScanner()

    nm.scan(target, arguments="-F")

    results: list[str] = []

    for host in nm.all_hosts():
        logger.info("Host found: %s", host)
        for proto in nm[host].all_protocols():
            for port in sorted(nm[host][proto]):
                state = nm[host][proto][port]["state"]
                process_name = get_process_by_port(port)
                logger.info(
                    "Port %d/%s: %s | Process: %s", port, proto, state, process_name
                )
                results.append(
                    f"- Port {port}/{proto} is {state.upper()} "
                    f"running: {process_name}"
                )

    return "\n".join(results) if results else "No open ports detected."
