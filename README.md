<div align="center">

# 🛡️ Sentinela V3.0

### EDR Caseiro — Detecção e Resposta em Endpoints com IA Local

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Nmap](https://img.shields.io/badge/Nmap-Network%20Scanner-4682B4?style=for-the-badge&logo=gnometerminal&logoColor=white)
![Ollama](https://img.shields.io/badge/Ollama-Phi--3-FF6F00?style=for-the-badge&logo=meta&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?style=for-the-badge&logo=windows&logoColor=white)

<br>

*Um agente de segurança autônomo que escaneia sua rede, identifica processos reais*
*nas portas abertas e envia os dados para uma IA local (Phi-3) gerar relatórios de SOC.*

</div>

---

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Arquitetura](#-arquitetura)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação](#-instalação)
- [Configuração do Nmap no Windows](#-configuração-do-nmap-no-windows)
- [Configuração do Ollama](#-configuração-do-ollama)
- [Como Usar](#-como-usar)
- [Automação com Agendador de Tarefas](#-automação-com-agendador-de-tarefas)
- [Exemplo de Saída](#-exemplo-de-saída)
- [Segurança e Avisos](#-segurança-e-avisos)
- [Licença](#-licença)

---

## 🔍 Visão Geral

O **Sentinela** é um EDR (Endpoint Detection & Response) caseiro que combina três tecnologias para criar um agente de segurança inteligente:

| Componente | Função |
|:--|:--|
| **Nmap** | Varredura de portas abertas na máquina local |
| **psutil** | Cruzamento de portas com processos reais do Windows (nome + PID) |
| **Ollama (Phi-3)** | Análise inteligente dos dados por IA local, sem nuvem |

> **Por que IA local?** Seus dados de rede nunca saem da sua máquina. Toda a análise é feita offline pelo modelo Phi-3 rodando via Ollama.

---

## 🏗️ Arquitetura

```
┌───────────────────────────────────────────────────┐
│                  Sentinela V3.0                   │
├───────────────────────────────────────────────────┤
│                                                   │
│   1. Detecta IP local via socket                  │
│              │                                    │
│              ▼                                    │
│   2. Nmap escaneia portas abertas (-F)            │
│              │                                    │
│              ▼                                    │
│   3. psutil cruza porta → processo real (PID)     │
│              │                                    │
│              ▼                                    │
│   4. Dados enviados ao Phi-3 (Ollama local)       │
│              │                                    │
│              ▼                                    │
│   5. Relatório de SOC em português                │
│                                                   │
└───────────────────────────────────────────────────┘
```

---

## ✅ Pré-requisitos

- **Windows 10/11**
- **Python 3.10+** — [Download](https://www.python.org/downloads/)
- **Nmap** — [Download](https://nmap.org/download.html)
- **Ollama** — [Download](https://ollama.com/download)

---

## 📦 Instalação

### 1. Clonar ou baixar o repositório

```bash
git clone https://github.com/seu-usuario/sentinela.git
cd sentinela
```

### 2. Instalar dependências Python

```bash
pip install psutil python-nmap requests
```

> **Nota:** Se você usa ambientes virtuais, ative-o antes de instalar:
> ```bash
> python -m venv venv
> venv\Scripts\activate
> pip install psutil python-nmap requests
> ```

---

## 🗺️ Configuração do Nmap no Windows

### Passo 1 — Baixar e instalar

1. Acesse [nmap.org/download](https://nmap.org/download.html)
2. Baixe o instalador **Windows** (`.exe`)
3. Execute o instalador e **mantenha o caminho padrão**:
   ```
   C:\Program Files (x86)\Nmap\
   ```
4. Marque a opção **"Register Nmap Path"** durante a instalação

### Passo 2 — Verificar a instalação

Abra o **PowerShell** ou **CMD** e execute:

```powershell
& "C:\Program Files (x86)\Nmap\nmap.exe" --version
```

Você deve ver algo como:

```
Nmap version 7.95 ( https://nmap.org )
```

### Passo 3 — (Opcional) Adicionar ao PATH do sistema

Se quiser usar `nmap` de qualquer terminal:

1. Abra **Configurações do Sistema** → **Variáveis de Ambiente**
2. Em **Path** (variável do sistema), adicione:
   ```
   C:\Program Files (x86)\Nmap
   ```
3. Reinicie o terminal

> ⚠️ **O Sentinela já aponta diretamente para o executável do Nmap no código**, então adicionar ao PATH é opcional.

---

## 🤖 Configuração do Ollama

### 1. Instalar o Ollama

Baixe e instale a partir de [ollama.com/download](https://ollama.com/download).

### 2. Baixar o modelo Phi-3

```bash
ollama pull phi3
```

### 3. Verificar se está rodando

O Ollama roda um servidor local na porta `11434`. Teste com:

```bash
curl http://localhost:11434/api/tags
```

Ou no PowerShell:

```powershell
Invoke-RestMethod -Uri "http://localhost:11434/api/tags"
```

---

## 🚀 Como Usar

Execute o agente **como Administrador** para acesso completo às portas e processos:

```powershell
python agente.py
```

> ⚠️ **Executar como Administrador** é recomendado para que o `psutil` consiga identificar processos do sistema nas portas 135, 445, etc.

---

## ⏰ Automação com Agendador de Tarefas

O projeto inclui o script `instalar_rotina.ps1` que configura automaticamente o Agendador de Tarefas do Windows para executar o Sentinela diariamente às 09:00.

```powershell
# Execute como Administrador
powershell -ExecutionPolicy Bypass -File .\instalar_rotina.ps1
```

Consulte o arquivo para mais detalhes.

---

## 📊 Exemplo de Saída

```
--------------------------------------------------
🚀 INICIANDO PROTOCOLO SENTINELA V3.0
--------------------------------------------------
🕵️  Sentinela: Iniciando varredura PROFUNDA em 192.168.1.50...
   > Host encontrado: 192.168.1.50
     -> Porta 135: open | Software Real: svchost.exe (PID: 1104)
     -> Porta 445: open | Software Real: System (PID: 4)
     -> Porta 5938: open | Software Real: TeamViewer.exe (PID: 8832)

🧠 Sentinela: Enviando verdade técnica para o Phi-3...

🛡️  RELATÓRIO DO ANALISTA:

1. Sim, o TeamViewer em Wi-Fi público representa risco significativo...
2. As portas 135 e 445 com o processo System são normais no Windows...
3. Recomendação: Desative o TeamViewer quando não estiver em uso...
```

---

## 🔒 Segurança e Avisos

> [!WARNING]
> Este projeto é uma ferramenta **educacional e de uso pessoal**. Não substitui soluções EDR comerciais.

- 🔐 **Privacidade total** — Nenhum dado sai da sua máquina. A IA roda 100% local via Ollama
- 🛑 **Não use em redes alheias** — Escanear redes sem autorização é ilegal
- 🧪 **Use para aprendizado** — Ideal para estudar segurança, redes e integração com IA

---

## 📄 Licença

Este projeto é distribuído sob a licença **MIT**. Veja o arquivo `LICENSE` para mais detalhes.

---

<div align="center">

**Feito com 🧠 e ☕ para a comunidade de segurança brasileira.**

</div>
