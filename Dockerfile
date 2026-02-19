FROM python:3.12-slim

# Instala manager uv
RUN pip install uv && \
    apt-get update && \
    apt-get install -y nmap && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia e instala dependências
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen

COPY . .

CMD ["uv", "run", "agente.py"]
