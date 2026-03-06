# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [3.1.2] — 2026-03-06

### Changed
- **Default AI Model Optimization** — In order to provide a lighter and faster offline AI experience, the default Ollama model was changed from `llama3` (~4.7GB) to `llama3.2` (~2.0GB). This affects both the `docker-compose.yml` (`ollama-init`) and the native Python fallback execution config.

### Added
- **Global `sentinela` CLI for Bare-Metal** — The native Windows setup script (`setup.ps1`) now permanently binds the `sentinela` command to the user's system PATH. Users who opt to install directly without Docker can now execute the exact same toolset directly from PowerShell:
  - `sentinela up` — Starts the REST API locally.
  - `sentinela scan --target <IP>` — Runs the network and process discovery scan directly in the host OS.
- PSScriptAnalyzer lint fixes for the Windows setup script unapproved verbs.

---

## [3.1.1] — 2026-03-06

### Fixed
- **Docker: CRLF line endings in shell scripts** — `wait-for-ollama.sh` had Windows-style CRLF line endings causing `\r: command not found` errors inside Linux containers. Rewrote with Unix LF endings and added `sed` fallback in Dockerfile.
- **Docker: Ollama healthcheck failing** — The `ollama/ollama` image does not include `curl`. Changed the healthcheck from `curl` to `ollama list`, which is natively available in the image.
- **Docker: `ollama-init` restart loop** — The model download init container could restart indefinitely. Added `restart: "no"` policy so it runs once and exits.
- **Git: Missing `.gitattributes`** — Created `.gitattributes` to enforce LF line endings on `.sh` files and Docker-related files, preventing CRLF issues when cloning on Windows.

### Changed
- **Full English translation** — All source code, documentation, comments, CLI messages, installer scripts, and README translated from Portuguese to English.
- **Version bump** — `3.1.0` → `3.1.1`

---

## [3.1.0] — 2026-03-05

### Added
- One-command installer for Linux/macOS (`install.sh`) and Windows (`install.ps1`)
- One-command uninstaller for both platforms
- CLI launcher with sub-commands: `up`, `down`, `scan`, `logs`, `status`, `update`
- Docker Compose setup with Ollama integration
- Healthcheck for both Ollama and Sentinela containers
- Comprehensive unit tests

### Core
- FastAPI-based REST API with Swagger documentation
- Nmap + psutil network scanning with process correlation
- Local LLM analysis via Ollama (llama3)
- Centralized configuration with environment variable support
