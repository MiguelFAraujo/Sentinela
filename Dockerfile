FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    nmap \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install --no-cache-dir uv

WORKDIR /app

# Cache dependencies
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

# Source code
COPY . .

RUN sed -i 's/\r$//' scripts/wait-for-ollama.sh && chmod +x scripts/wait-for-ollama.sh

EXPOSE 3333

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:3333/health || exit 1

CMD ["bash", "-c", "./scripts/wait-for-ollama.sh && uv run uvicorn app.agente:app --host 0.0.0.0 --port 3333"]
