import psutil
import requests
import nmap
import socket

import os

# Configurações
MODELO = "phi3"

# Lê URL do Ollama da variável de ambiente, padrão para localhost se não definida
# Isso funciona tanto no Docker Compose (http://ollama:11434) quanto localmente
URL_OLLAMA = os.getenv("OLLAMA_HOST", "http://localhost:11434")

if os.path.exists('/.dockerenv'):
    URL_OLLAMA = os.environ.get("OLLAMA_HOST", "http://host.docker.internal:11434/api/generate")
    # No Linux/Docker, o nmap geralmente está no PATH
    NMAP_PATH = ["nmap"]
else:
    # Caminho Windows
    NMAP_PATH = [r"C:\Program Files (x86)\Nmap\nmap.exe"]

# Garante que a URL termine com /api/generate se não tiver
if not URL_OLLAMA.endswith("/api/generate"):
    URL_OLLAMA = f"{URL_OLLAMA}/api/generate"

def pegar_ip_local():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('8.8.8.8', 1))
        ip = s.getsockname()[0]
    except Exception:
        ip = '127.0.0.1'
    finally:
        s.close()
    return ip

def obter_processo_da_porta(porta, protocolo='tcp'):
    """
    Cruza a porta encontrada com a lista de processos do Windows
    para descobrir QUEM está usando a porta.
    """
    for proc in psutil.net_connections(kind=protocolo):
        if proc.laddr.port == porta and proc.status == 'LISTEN':
            try:
                # Tenta pegar o nome do executável pelo PID
                processo = psutil.Process(proc.pid)
                return f"{processo.name()} (PID: {proc.pid})"
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                return "Processo Oculto/Sistema"
    return "Desconhecido"

def auditoria_inteligente(alvo):
    print(f"🕵️  Sentinela: Iniciando varredura PROFUNDA em {alvo}...")
    
    # O Python agora vai ler o caminho correto
    nm = nmap.PortScanner(nmap_search_path=NMAP_PATH)
    nm.scan(alvo, arguments='-F') # Scan rápido
    
    dados_para_ia = []
    
    for host in nm.all_hosts():
        print(f"   > Host encontrado: {host}")
        for proto in nm[host].all_protocols():
            lport = nm[host][proto].keys()
            for port in sorted(lport):
                estado = nm[host][proto][port]['state']
                
                # O Python descobre o nome real do software
                nome_real = obter_processo_da_porta(port)
                
                print(f"     -> Porta {port}: {estado} | Software Real: {nome_real}")
                
                dados_para_ia.append(f"- Porta {port}/{proto} está ABERTA rodando: {nome_real}")
    
    if not dados_para_ia:
        return "Nenhuma porta aberta detectada."
        
    return "\n".join(dados_para_ia)

def analisar_com_ia(dados_tecnicos):
    print(f"\n🧠 Sentinela: Enviando verdade técnica para o Phi-3...")
    
    prompt = f"""
    Você é um Analista de SOC (Security Operations Center).
    Analise esta lista de serviços REAIS rodando em um notebook de trabalho:
    
    {dados_tecnicos}
    
    Responda em PORTUGUÊS:
    1. O "AnyDesk" ou "TeamViewer" representam risco se o usuário estiver em Wi-Fi público?
    2. O "System" nas portas 135/445 é normal?
    3. Dê uma recomendação de segurança de apenas uma frase.
    """

    payload = {
        "model": MODELO,
        "prompt": prompt,
        "stream": False
    }

    try:
        resposta = requests.post(URL_OLLAMA, json=payload)
        return resposta.json()['response']
    except Exception as e:
        return f"Erro na IA: {e}"

# Execução
if __name__ == "__main__":
    meu_ip = pegar_ip_local()
    print("-" * 50)
    print(f"🚀 INICIANDO PROTOCOLO SENTINELA V3.0")
    print("-" * 50)
    
    try:
        dados = auditoria_inteligente(meu_ip)
        
        if dados != "Nenhuma porta aberta detectada.":
            analise = analisar_com_ia(dados)
            print("\n🛡️  RELATÓRIO DO ANALISTA:\n")
            print(analise)
        else:
            print("\n✅ Sistema Blindado: Nenhuma porta exposta encontrada.")
    except Exception as e:
        print(f"\n❌ ERRO CRÍTICO: {e}")
        print("Dica: Verifique se o Nmap está instalado em C:\\Program Files (x86)\\Nmap")