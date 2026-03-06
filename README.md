# Sentinela V3.0

**Sistema EDR caseiro com análise de IA local**

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat-square&logo=python&logoColor=white)
![Nmap](https://img.shields.io/badge/Nmap-7.95-4682B4?style=flat-square)
![Ollama](https://img.shields.io/badge/Ollama-Phi--3-FF6F00?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)

---

## Por que este projeto existe

Durante minhas aulas na **Hackers do Bem**, ficou claro que entender o que está rodando no seu próprio computador é fundamental para segurança. Soluções EDR profissionais custam milhares de reais e enviam seus dados para a nuvem. Pensei: e se eu pudesse criar algo simples, local e que realmente me mostrasse o que está acontecendo na minha máquina?

O Sentinela nasceu dessa inquietação. A ideia era combinar ferramentas que eu estava aprendendo - Nmap para varredura, Python para automação, e recentemente descobri o Ollama, que permite rodar modelos de IA completamente offline. Depois de alguns fins de semana mexendo no código, consegui fazer as três ferramentas conversarem entre si.

Não é uma solução enterprise, mas funciona. E mais importante: me ajudou a entender na prática como EDRs funcionam e como processos se comportam no Windows.

---

## O que o Sentinela faz

O projeto monitora sua própria máquina em três etapas:

1. **Varredura de portas** - Usa o Nmap para identificar quais portas TCP estão abertas localmente
2. **Identificação de processos** - Cruza cada porta aberta com o processo real do Windows que está usando ela (nome do executável + PID)
3. **Análise por IA** - Envia os dados para o Phi-3 rodando localmente via Ollama, que gera um relatório em português explicando os riscos

A vantagem de usar IA local é que nenhum dado sai da sua máquina. Tudo roda offline.

---

## Tecnologias utilizadas

- **Python 3.10+** - Linguagem principal
- **python-nmap** - Wrapper Python para o Nmap
- **psutil** - Biblioteca para informações de processos do sistema
- **Nmap** - Scanner de portas
- **Ollama + Phi-3** - IA local para análise dos dados

---

## Instalação

### Requisitos

- Windows 10 ou 11
- Python 3.10 ou superior
- Nmap instalado
- Ollama instalado

### Passo a passo

**1. Clone o repositório**

```bash
git clone https://github.com/MiguelFAraujo/Sentinela.git
cd Sentinela
```

**2. Instale as dependências Python**

```bash
pip install psutil python-nmap requests
```

**3. Instale o Nmap**

Baixe em [nmap.org/download](https://nmap.org/download.html) e instale. O caminho padrão é:

```
C:\Program Files (x86)\Nmap\
```

O script já aponta para esse caminho. Se você instalou em outro lugar, edite a linha do `nmap_path` no `agente.py`.

**4. Instale o Ollama e baixe o Phi-3**

Baixe o Ollama em [ollama.com/download](https://ollama.com/download) e depois execute:

```bash
ollama pull phi3
```

O Ollama vai rodar em segundo plano na porta 11434.

---

## Como usar

Execute como Administrador para ter acesso completo aos processos do sistema:

```powershell
python agente.py
```

O script vai:
- Detectar seu IP local
- Escanear as portas abertas
- Identificar os processos
- Enviar para o Phi-3
- Mostrar o relatório de análise

### Automatizar com o Agendador de Tarefas

Incluí um script PowerShell que configura o Windows Task Scheduler para rodar o Sentinela diariamente às 9h:

```powershell
powershell -ExecutionPolicy Bypass -File .\instalar_rotina.ps1
```

Execute como Administrador. Depois disso, o agente vai rodar sozinho todo dia.

---

## Exemplo de execução

```
--------------------------------------------------
INICIANDO PROTOCOLO SENTINELA V3.0
--------------------------------------------------
Sentinela: Iniciando varredura PROFUNDA em 192.168.1.50...
   > Host encontrado: 192.168.1.50
     -> Porta 135: open | Software Real: svchost.exe (PID: 1104)
     -> Porta 445: open | Software Real: System (PID: 4)
     -> Porta 5938: open | Software Real: TeamViewer.exe (PID: 8832)

Sentinela: Enviando verdade técnica para o Phi-3...

RELATÓRIO DO ANALISTA:

1. Sim, o TeamViewer em Wi-Fi público representa risco significativo...
2. As portas 135 e 445 com o processo System são normais no Windows...
3. Recomendação: Desative o TeamViewer quando não estiver em uso...
```

---

## Avisos importantes

Este é um projeto educacional. Não substitui soluções profissionais de EDR. Use apenas em sua própria máquina e rede.

**Privacidade**: Os dados nunca saem do seu computador. O Phi-3 roda 100% local.

**Legalidade**: Não escaneie redes de terceiros sem autorização. É crime.

**Propósito**: Ferramenta de aprendizado para quem estuda segurança e quer entender como sistemas de detecção funcionam na prática.

---

## Sobre

Meu nome é Miguel F. Araújo. Estou estudando segurança cibernética na **Hackers do Bem** (turma fundamental), uma iniciativa brasileira focada em ethical hacking e defesa de sistemas.

Este projeto é parte do meu aprendizado. Se você também está começando na área de segurança, espero que o código seja útil para entender como integrar ferramentas básicas e criar algo funcional.

---

## Contribuições

Se quiser melhorar o projeto, fique à vontade para abrir issues ou pull requests. Algumas ideias:

- Suporte para Linux/macOS
- Interface web para visualizar os relatórios
- Exportar relatórios em JSON ou CSV
- Integração com alertas (email, Telegram)
- Melhorar os prompts da IA

---

## Licença

MIT License. Veja o arquivo `LICENSE` para detalhes.

---

**[GitHub](https://github.com/MiguelFAraujo) | Miguel F. Araújo | 2026**
