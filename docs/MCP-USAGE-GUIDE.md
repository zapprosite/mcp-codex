# Guia de Uso dos MCPs

Este repositório define os servidores MCP no arquivo `codex-config.toml` usando a tabela `[mcpServers.*]` (no próprio repo, não no Trae). Use o script de validação para confirmar comandos e variáveis antes de executar qualquer CLI.

### Validação da configuração local
- `python scripts/test-mcps.py` — lê `[mcpServers.*]` do `codex-config.toml`, verifica binários e exibe um resumo de cada servidor (command/args/env keys).
- Ajuste paths e chaves diretamente no `codex-config.toml` conforme necessário.

Sugestões de comandos para explorar os 16 MCPs instalados no baseline (via Codex CLI, se aplicável).

## Verificações iniciais
- `codex mcp list` — garante que o Codex CLI reconhece todos os servidores.
- `codex mcp get <nome>` — exibe configuração e status de um MCP específico.
- Logs em tempo real: `tail -f ~/.codex/logs/*.log`.

> Substitua `codex` por `codex-cli` caso esse seja o binário instalado.

## Essenciais

- **sequential-thinking**  
  `codex mcp exec sequential-thinking "Planeje uma refatoração do módulo X"`  
  Ajuda a quebrar problemas complexos em etapas.

- **shell**  
  `codex mcp exec shell "Instale dependências e rode testes"`  
  Executa comandos shell com cenário controlado (`@nazcamedia/mcp-shell`).

- **github**  
  `codex mcp exec github repo-status --owner meuuser --repo projeto`  
  Lista PRs, branches e status CI usando o token do GitHub.

- **brave-search**  
  `codex mcp exec brave-search "últimas novidades TypeScript 5.6"`  
  Usa a API Brave para buscas web com ranking confidencial.

- **web-research**  
  `codex mcp exec web-research "Resuma artigos sobre MCPs"`  
  Combina Brave + Exa para pesquisa enriquecida com crawling.

- **task-manager**  
  `codex mcp exec task-manager add "Implementar integração Stripe"`  
  Gera e organiza to-dos persistentes no Codex CLI.

- **sqlite**  
  `codex mcp exec sqlite "SELECT name FROM sqlite_master WHERE type='table';"`  
  Opera no banco configurado em `SQLITE_DB_PATH`.

- **fetch**  
  `codex mcp exec fetch GET https://httpbin.org/json`  
  Requisições HTTP rápidas sem sair do CLI (`@mokei/mcp-fetch`).

- **memory**  
  `codex mcp exec memory remember "Projeto X usa Node 20"`  
  Usa o servidor `@iachilles/memento` para guardar notas em `MEMORY_DB_PATH`.

## Adicionais

- **playwright**  
  `codex mcp exec playwright open https://example.org`  
  Abre/automatiza navegadores headless ou conectados via WebSocket.

- **filesystem**  
  `codex mcp exec filesystem read ./README.md`  
  Manipula arquivos respeitando o `FILESYSTEM_BASE_PATH`.

- **desktop-commander**  
  `codex mcp exec desktop-commander run "code ." `  
  Dispara comandos nativos do sistema (uso com cautela).

- **exa-search**  
  `codex mcp exec exa-search "papers sobre MCP 2025"`  
  Busca semântica avançada com resultados enriquecidos.

- **obsidian**  
  `codex mcp exec obsidian list`  
  Lista notas/tags da vault informada em `OBSIDIAN_VAULT_PATH`.

- **context7**  
  `codex mcp exec context7 summarize ./src/api`  
  Gera documentação atualizada a partir do repositório local.

- **git**  
  `codex mcp exec git status`  
  Expõe operações Git locais e remotas (usa o mesmo `GITHUB_TOKEN` do MCP `github`).

## Debug rápido
1. Rode `python scripts/test-mcps.py` após qualquer mudança no `codex-config.toml`.
2. Se estiver usando Codex CLI, erros de autenticação geralmente aparecem em `~/.codex/logs/<mcp>.log`.
3. Use `npm update -g <pacote>` para atualizar MCPs individualmente (se instalados globalmente).
4. Se um MCP não for mais necessário, remova-o do `codex-config.toml` e reinstale com `scripts/install_mcps.sh`.
5. Observação: o Codex CLI pode esperar a estrutura `[mcp_servers.*]`. Este repositório usa `[mcpServers.*]`; para consumo pelo Codex CLI, adapte conforme sua necessidade.
