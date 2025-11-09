# Manual de Lembrete dos MCPs para o GPT

Este documento fortalece a memória operacional do agente: quando pensar em cada MCP, qual poder ele traz e como manter a orquestração segura com o Codex CLI.

> Atualização registrada em 08/11/2025. Use-o como checklist antes de qualquer resposta longa ou quando for pedir ao GPT para agir.

## Contexto rápido
- Há 13 MCPs ativos neste repositório (ver `docs/MCP-USAGE-GUIDE.md`).
- O foco é evitar que o GPT execute tarefas sem tirar proveito dos MCPs disponíveis.
- Quando a resposta exigir pesquisa, execução shell ou colaboração com serviços externos, identifique o MCP recomendado abaixo e invoque-o via `codex mcp exec`.

## 1. Tabela de associação ( lembra-se de usar! )
| MCP | Função-chave | Exemplo de invocação | Lembrete rápido |
| --- | --- | --- | --- |
| `brave-search` | Atualizar contexto com buscas web | `codex mcp exec brave-search "site:github.com codex-cli mcp"` | Procure evidências públicas antes de responder novidades. |
| `context7` | Resumir/gerar documentação local | `codex mcp exec context7 summarize docs/` | Use quando precisar de uma visão consolidada do repositório. |
| `desktop-commander` | Rodar comandos do sistema | `codex mcp exec desktop-commander run "code ."` | Só use se o shell não resolver (ex: abrir IDE). |
| `exa-search` | Pesquisa semântica avançada | `codex mcp exec exa-search "status MCP 2025"` | Complementa o Brave com resultados qualificados. |
| `filesystem` | Ler/escrever arquivos locais | `codex mcp exec filesystem read docs/README.md` | Ideal antes de editar ou citar arquivos. |
| `git` | Operações git locais | `codex mcp exec git status` | Confere antes de dizer algo sobre branches. |
| `github` | Consultas remotas em GitHub | `codex mcp exec github repo-status --owner=...` | Use para PRs, issues e checks. |
| `memory` | Registrar lembretes persistentes | `codex mcp exec memory remember "Stack X usa MCP Y"` | Arquive fatos úteis para sessões seguintes. |
| `playwright` | Validar UIs ou APIs via browser | `codex mcp exec playwright open https://example.org` | Só com cuidado (headless e URLs confiáveis). |
| `sequential-thinking` | Planejamento estruturado | `codex mcp exec sequential-thinking "Planeje a tarefa"` | Ajuda a dividir problemas longos em passos. |
| `shell` | Execução controlada de comandos | `codex mcp exec shell "npm install"` | Use para scripts diretos quando não precisar de outros MCPs. |
| `sqlite` | Consultas ao banco local | `codex mcp exec sqlite "SELECT name FROM sqlite_master"` | Útil para dados armazenados em `SQLITE_DB_PATH`. |
| `task-manager` | Gerir tarefas persistentes | `codex mcp exec task-manager add "Validar MCP"` | Atualize a lista antes de finalizar uma demanda.

## 2. Quando recorrer a esta tabela
- Comece qualquer instrução longa lembrando-se de verificar qual MCP é a fonte mais forte para a atividade (ex.: web search → `brave-search`, manipulação de arquivos → `filesystem`).
- Antes de executar comandos, confirme se o `shell` já não resolve o caso; se for uma interação nativa do Codex CLI (GitHub, Git, Task Manager) invoque o MCP correspondente.
- Para respostas complexas, monte um mini-plano com `sequential-thinking` e use `memory` para fixar decisões importantes.

## 3. Orquestração automática existente
- Há um prompt orquestrador (`prompts/dual-mcp-orchestrator.toml`) que descreve fases de descoberta, sincronização e monitoramento de MCPs. Quando houver dúvidas sobre dependências ou inconsistências, execute `codex daemon:start --profile=dual-mcp-orchestrator` ou o script `scripts/start-dual-mcp-daemon.sh`.
- O daemon copia o prompt para `~/.codex/prompts/`, carrega variáveis como `GITHUB_TOKEN` e `BRAVE_API_KEY` com segurança e registra logs em `~/.codex/logs/daemon.log`.
- Se o comando `codex daemon:start` não estiver disponível, o fallback usa `codex exec` em background; sempre revise `~/.codex/logs/daemon.log` antes de declarar que os MCPs estão sincronizados.
## 4. Pesquisa atualizada (08/11/2025)
- Quando a pergunta se refere à comunidade Codex CLI ou a novos usos do MCP, use `brave-search` e `exa-search` para pegar o pulso do GitHub e fóruns open source (ex.: `codex mcp exec brave-search "site:github.com codex-cli MCP"`).
- Busque termos como "Codex CLI MCP orchestration", "Codex CLI daemon" e "Codex community prompts" para confirmar se há novas automações públicas.
- Documente o que encontrar em `memory` e crie uma nota breve em `~/logs` ou no repositório local (ex.: `docs/SECURITY-AUDIT ...`). 
- Sempre registre a data da coleta (08/11/2025) nos casos em que for usada durante a sessão atual.

## 5. Checklist de segurança antes de rodar MCPs
- Não exponha tokens ou segredos em prompts: use as variáveis `GITHUB_TOKEN`, `BRAVE_API_KEY`, etc., apenas conforme declarado nos scripts (`scripts/start-dual-mcp-daemon.sh`).
- Verifique o log ao chamar um daemon (`~/.codex/logs/daemon.log`); pare se houver erros de permissão ou conexões recusadas.
- Ao usar `desktop-commander` ou `shell`, prefira comandos idempotentes; confirme com `git status` antes e depois.
- Atualize `memory` apenas com fatos seguros e relevantes; não repita secrets nem dados pessoais.

## 6. Referências e próximos passos
- `docs/MCP-USAGE-GUIDE.md`: visão curta de cada MCP.
- `prompts/dual-mcp-orchestrator.toml`: blueprint de orquestração automática.
- `scripts/start-dual-mcp-daemon.sh`: rotina segura de inicialização.
- `AGENTS.md`: contexto geral do ambiente e próximos passos.
- `README.md` ou GitHub Codex CLI: use os MCPs de busca para validar o conteúdo remoto.

## 7. Plano do orquestrador em execução
1. Atualize `.env` (via `scripts/setup-apis.py` ou manualmente) e carregue com `scripts/codex-env.sh` para garantir que `GITHUB_TOKEN`, `BRAVE_API_KEY`, `EXA_API_KEY` e os caminhos estejam definidos; o script agora alerta se alguma dessas variáveis faltar.
2. Execute `bash scripts/start-dual-mcp-daemon.sh` — ele copia `prompts/dual-mcp-orchestrator.toml`, injeta `GITHUB_TOKEN/BRAVE_API_KEY`, inicia `codex daemon:start` (com fallback `codex exec`) e lança a varredura que identifica MCPs ativos antes de qualquer ação do agente.
3. Use `codex daemon:status` ou `tail -f ~/.codex/logs/daemon.log` para confirmar que o daemon está sincronizado e validou o `codex mcp list`.
4. Sempre que iniciar uma sessão longa, invoque o daemon e depois use a tabela acima para escolher qual MCP executar (p. ex., `codex daemon:start` + `codex mcp exec brave-search ...`).
5. Se o Orquestrador detectar divergências, ele registra status em `~/.codex/mcp-health.json` e gera relatórios em `~/.codex/reports/dual-mcp-status.md`; revise esses artefatos antes de responder perguntas que exigem MCPs específicos.
