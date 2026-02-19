import sys
import os
import argparse
from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel
from app.scanner import pegar_ip_local, auditoria_inteligente
from app.llm import analisar_com_ia

# Definição da aplicação FastAPI
app = FastAPI(
    title="Sentinela EDR",
    description="API de Monitoramento e Análise de Segurança com IA Local",
    version="3.0.0"
)

# Modelo de resposta
class ScanResponse(BaseModel):
    target: str
    status: str
    analysis: str | None = None
    raw_data: str | None = None

def executar_varredura(host_alvo: str) -> dict:
    print("-" * 50)
    print(f"🚀 INICIANDO PROTOCOLO SENTINELA (Target: {host_alvo})")
    print("-" * 50)
    
    try:
        dados = auditoria_inteligente(host_alvo)
        
        analise = None
        if dados != "Nenhuma porta aberta detectada.":
            analise = analisar_com_ia(dados)
            print("\n🛡️  RELATÓRIO DO ANALISTA:\n")
            print(analise)
        else:
            print("\n✅ Sistema Blindado: Nenhuma porta exposta encontrada.")
            
        return {
            "target": host_alvo,
            "status": "success",
            "analysis": analise,
            "raw_data": dados
        }
    except Exception as e:
        print(f"\n❌ ERRO CRÍTICO: {e}")
        return {
            "target": host_alvo,
            "status": "error",
            "error": str(e)
        }

@app.get("/", tags=["Status"])
def root():
    return {"status": "online", "service": "Sentinela EDR", "version": "3.0.0"}

@app.get("/health", tags=["Status"])
def health_check():
    return {"status": "healthy"}

@app.post("/scan", tags=["Operations"], response_model=ScanResponse)
def trigger_scan(target: str | None = None):
    # Se não for passado target, tenta pegar da variável de ambiente ou IP local
    if not target:
        target = os.getenv("TARGET_IP", pegar_ip_local())
    
    resultado = executar_varredura(target)
    
    return ScanResponse(
        target=resultado.get("target", "unknown"),
        status=resultado.get("status", "error"),
        analysis=resultado.get("analysis"),
        raw_data=resultado.get("raw_data")
    )

# Mantemos a CLI para testes locais via "python -m app.agente scan" ou via script
def main():
    parser = argparse.ArgumentParser(description="Sentinela - EDR com IA local")
    parser.add_argument("comando", nargs="?", default="start_api", choices=["scan", "start_api"], help="Comando a executar")
    parser.add_argument("--target", help="IP Alvo para escaneamento")
    
    args = parser.parse_args()
    
    if args.comando == "scan":
        alvo = args.target if args.target else os.getenv("TARGET_IP", pegar_ip_local())
        executar_varredura(alvo)
    else:
        # Modo padrão: Rodar via Uvicorn (usado em dev local sem docker)
        import uvicorn
        uvicorn.run(app, host="0.0.0.0", port=3333)

if __name__ == "__main__":
    main()
