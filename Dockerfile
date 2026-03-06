FROM python:3.12-slim

# Instala uv e nmap (CRÍTICO: nmap é necessário para python-nmap funcionar)
RUN pip install uv && \
    apt-get update && \
    apt-get install -y nmap && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia arquivos de definição de dependência
COPY pyproject.toml uv.lock ./

# Instala dependências usando uv
RUN uv sync --frozen

COPY . .

# Executa usando o ambiente gerenciado pelo uv
CMD ["uv", "run", "agente.py"]
