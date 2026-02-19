import requests
from app.config import MODELO, URL_OLLAMA_API

def analisar_com_ia(dados_tecnicos):
    print(f"\n🧠 Sentinela: Enviando verdade técnica para o {MODELO} em {URL_OLLAMA_API}...")
    
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
        resposta = requests.post(URL_OLLAMA_API, json=payload)
        return resposta.json()['response']
    except Exception as e:
        return f"Erro na IA: {e}"
