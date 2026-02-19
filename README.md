# Sentinela 🛡️

# Sentinela com Docker

Requisitos:
- Docker
- Docker Compose
- (Opcional) Ollama para uso local

## Como rodar:

```bash
git clone https://github.com/MiguelFAraujo/Sentinela
cd Sentinela
docker compose up
```

## Como atualizar dependências:

```bash
uv add <lib>
uv lock
docker compose build
docker compose up -d
```

---

## 💻 Instalação Manual (Windows/PowerShell)

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
