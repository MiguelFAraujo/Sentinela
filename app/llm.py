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
        resposta = requests.post(URL_OLLAMA_API, json=payload, timeout=60)
        
        if resposta.status_code != 200:
            return f"Erro na API Ollama (Status {resposta.status_code}): {resposta.text}"
            
        resposta_json = resposta.json()
        
        # Se houver erro explícito do Ollama (ex: model not found)
        if "error" in resposta_json:
             return f"Erro retornado pelo Ollama: {resposta_json['error']}"

        return resposta_json.get("response", f"IA não retornou resposta válida. Raw: {str(resposta_json)}")
    except requests.exceptions.ConnectionError:
        return "Erro de Conexão: O servidor Ollama parece estar offline ou inacessível."
    except requests.exceptions.Timeout:
        return "Timeout: O modelo demorou muito para responder (pode estar carregando)."
    except Exception as e:
        return f"Erro interno na integração IA: {e}"
