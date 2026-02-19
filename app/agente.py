import sys
from app.scanner import pegar_ip_local, auditoria_inteligente
from app.llm import analisar_com_ia

def main():
    meu_ip = pegar_ip_local()
    print("-" * 50)
    print(f"🚀 INICIANDO PROTOCOLO SENTINELA V3.0 (Enterprise)")
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
        # print("Dica: Verifique se o Nmap está instalado e no PATH.")

if __name__ == "__main__":
    main()
