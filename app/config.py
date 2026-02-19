import os

# Definições de Ambiente
MODELO = os.getenv("MODELO", "llama3")
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")

# Garante a URL da API
if not OLLAMA_HOST.endswith("/api/generate"):
    URL_OLLAMA_API = f"{OLLAMA_HOST}/api/generate"
else:
    URL_OLLAMA_API = OLLAMA_HOST

# Configuração do Nmap
if os.path.exists('/.dockerenv'):
    # No Linux/Docker, o nmap geralmente está no PATH
    NMAP_PATH = ["nmap"]
else:
    # Caminho Windows (Fallback seguro)
    NMAP_PATH = [r"C:\Program Files (x86)\Nmap\nmap.exe"]
