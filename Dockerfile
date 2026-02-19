FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Instala dependências do sistema
RUN apt-get update && apt-get install -y \
    curl \
    bash \
    nmap \
    && rm -rf /var/lib/apt/lists/*

# Instala uv
RUN pip install uv

WORKDIR /app

# Copia arquivos de dependência primeiro (cache eficiente)
COPY pyproject.toml uv.lock ./

RUN uv sync --frozen

# Copia resto do projeto
COPY . .

# Script de espera do Ollama
RUN chmod +x scripts/wait-for-ollama.sh

EXPOSE 3333

CMD ["bash", "-c", "./scripts/wait-for-ollama.sh && uv run uvicorn app.agente:app --host 0.0.0.0 --port 3333"]
