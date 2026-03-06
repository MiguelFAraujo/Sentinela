# 🛡️ Sentinela

**Experimental open-source EDR with local AI-powered analysis.**

Sentinela is an Endpoint Detection and Response system that combines network monitoring with intelligent analysis via a local LLM ([Ollama](https://ollama.ai)), running **100% offline** — your data never leaves your machine.

![CI](https://github.com/MiguelFAraujo/Sentinela/actions/workflows/ci.yml/badge.svg)
![License](https://img.shields.io/badge/license-MIT-green)
![Python](https://img.shields.io/badge/python-3.12-blue)
![Ollama](https://img.shields.io/badge/AI-Ollama-orange)

---

## Install with One Command

<details open>
<summary><strong>🐧 Linux & macOS</strong></summary>

```bash
curl -fsSL install.cat/MiguelFAraujo/Sentinela | sh
```
</details>

<details>
<summary><strong>🪟 Windows (PowerShell)</strong></summary>

```powershell
irm install.cat/MiguelFAraujo/Sentinela | iex
```
</details>

> Run the same command again at any time to **update** to the latest version.

---

## Quick Start

After installation, the `sentinela` command is available in your terminal:

```bash
sentinela              # Start all services
sentinela scan         # Run a manual scan
sentinela logs         # Follow logs in real-time
sentinela status       # Show container status
sentinela down         # Stop all services
sentinela update       # Update to the latest version
```

**API available at:** `http://localhost:3333`
**Interactive docs:** `http://localhost:3333/docs`

---

## Uninstall

<details>
<summary><strong>🐧 Linux & macOS</strong></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/MiguelFAraujo/Sentinela/main/uninstall.sh | sh
```
</details>

<details>
<summary><strong>🪟 Windows (PowerShell)</strong></summary>

```powershell
irm https://raw.githubusercontent.com/MiguelFAraujo/Sentinela/main/uninstall.ps1 | iex
```
</details>

---

## Architecture

Sentinela runs on a containerized architecture with Docker, separating responsibilities between the monitoring agent and the AI inference engine.

```mermaid
graph TD
    A["🛡️ Sentinela App"] -->|HTTP API| B["🧠 Ollama LLM"]
    A -->|"Nmap + psutil"| C["📡 Network Scanner"]
    B -->|Model| D["💾 Persistent Volume"]
    E["👤 User"] -->|"CLI / REST API"| A
```

### Components

| Component | Description |
|---|---|
| **Sentinela App** (`app/`) | Python core — orchestrates scans and analysis via FastAPI |
| **Scanner** (`scanner.py`) | Nmap + psutil to map the local attack surface |
| **LLM Client** (`llm.py`) | Interface with the Ollama API (SOC prompt system) |
| **Ollama** | Inference server running `llama3` in an isolated container |

---

## Sample Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 SENTINELA PROTOCOL (Target: 192.168.1.50)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Host found: 192.168.1.50
  Port 135/tcp: OPEN running: svchost.exe (PID: 1104)
  Port 445/tcp: OPEN running: System (PID: 4)
  Port 5938/tcp: OPEN running: TeamViewer.exe (PID: 8832)

🛡️ REPORT:
1. TeamViewer on public Wi-Fi poses a significant risk...
2. Ports 135/445 with System process are normal on Windows...
3. Recommendation: Disable TeamViewer when not in use.
```

---

## Development

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- [Python 3.12+](https://python.org) (for local development)
- [uv](https://docs.astral.sh/uv/) (package manager)

### Local Setup (without Docker)

```bash
git clone https://github.com/MiguelFAraujo/Sentinela
cd Sentinela
uv sync
uv run sentinela scan --target 127.0.0.1
```

### Docker Compose (manual)

```bash
docker compose up --build
```

### Project Structure

```
Sentinela/
├── app/
│   ├── agente.py        # Entrypoint (FastAPI + CLI)
│   ├── scanner.py       # Network scanning (Nmap + psutil)
│   ├── llm.py           # AI integration (Ollama)
│   └── config.py        # Centralized configuration
├── scripts/
│   └── wait-for-ollama.sh
├── tests/               # Unit tests
├── install.sh           # Linux/macOS installer
├── install.ps1          # Windows installer
├── CHANGELOG.md         # Release notes
├── Dockerfile
└── docker-compose.yml
```

### Development Commands

```bash
uv sync                                    # Install dependencies
uv run python -m pytest tests/ -v          # Run tests
uv run sentinela start_api                 # Start local API
uv run sentinela scan --target 127.0.0.1   # Local scan
```

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `OLLAMA_HOST` | `http://localhost:11434` | Ollama server URL |
| `MODELO` | `llama3` | AI model to use |
| `TARGET_IP` | Auto-detected | Target IP for scanning |
| `SENTINELA_HOST` | `0.0.0.0` | API server host |
| `SENTINELA_PORT` | `3333` | API server port |

---

## API Endpoints

| Method | Route | Description |
|---|---|---|
| `GET` | `/` | Service status |
| `GET` | `/health` | Health check |
| `POST` | `/scan` | Execute scan and analysis |
| `GET` | `/docs` | Interactive documentation (Swagger) |

---

## ⚠️ Important Notices

> **Educational**: This is a learning project. It does not replace professional EDR solutions.
>
> **Privacy**: Your data never leaves your computer. llama3 runs 100% locally.
>
> **Legality**: Do not scan third-party networks without authorization.

---

## Contributing

Contributions are welcome! Open an issue or pull request.

**Ideas:**
- Full Linux/macOS support
- Web interface for reports
- JSON/CSV export
- Email or Telegram alerts
- AI prompt improvements

---

## About

Project created by **Miguel F. Araújo** during cybersecurity studies at **Hackers do Bem** (fundamental class).

## License

MIT License — see the [LICENSE](LICENSE) file for details.

---

**[GitHub](https://github.com/MiguelFAraujo) · Miguel F. Araújo · 2026**
