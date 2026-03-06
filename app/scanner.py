import socket
import nmap
import psutil
from app.config import NMAP_PATH

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
    
    try:
        # Tenta inicializar o scanner com o caminho configurado
        nm = nmap.PortScanner(nmap_search_path=NMAP_PATH)
    except nmap.PortScannerError:
        # Fallback: Tenta sem caminho específico (confia no PATH)
        nm = nmap.PortScanner()
        
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
