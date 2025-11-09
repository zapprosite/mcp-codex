# Guia de Configuração de APIs (MCP Codex — Nov/2025)

Use este passo a passo para gerar ou recuperar cada credencial antes de executar `scripts/install_mcps.sh`.

## Modelo (OAuth)
- Sem `OPENAI_API_KEY` e sem `OPENAI_API_MODEL`.
- Remova qualquer linha `model = "openai:..."` do `codex-config.toml`.
- Autentique via OAuth no Codex/Trae (ex.: conta ChatGPT).  
  O provedor/modelo será inferido a partir da conta autenticada.

## GitHub
- **Variável**: `GITHUB_TOKEN`
- **Onde gerar**: https://github.com/settings/tokens?type=beta
- **Escopos mínimos sugeridos**:  
  - `Contents: Read`  
  - `Metadata: Read`  
  - `Pull requests: Read`
- **Observações**: utilize um token fine-grained e restrinja aos repositórios necessários.
  O mesmo token é usado pelos MCPs `github` e `git`.

## Brave Search
- **Variável**: `BRAVE_API_KEY`
- **Onde gerar**: https://brave.com/search/api/
- **Passos**: escolha o plano, gere a chave em **API Keys** e copie para o `.env`.

## Exa
- **Variável**: `EXA_API_KEY`
- **Onde gerar**: https://exa.ai/exa-api
- **Passos**: após login, gere uma chave em **Dashboard → API Keys**.  
  Permite buscas semânticas via o MCP `exa-search`.

## Context7 (Upstash)
- **Variável**: `CONTEXT7_API_KEY`
- **Onde gerar**: https://context7.com (login com conta Upstash)  
- **Passos**: na área **API Key**, selecione **Generate key** e cole o valor no `.env`.

## Playwright MCP (opcional)
- **Variável**: `PLAYWRIGHT_WS_ENDPOINT`
- **Quando usar**: apenas se você expõe um navegador remoto/Cloud.  
- **Valor**: URL `ws://` ou `wss://` do grid Playwright. Se deixar vazio, o MCP tenta abrir um browser local.

## SQLite MCP
- **Variável**: `SQLITE_DB_PATH`
- **Valor padrão**: `./data/mcp_database.db` (já definido no template).  
- **Dica**: mantenha o diretório `data/` fora do versionamento.

## Filesystem MCP
- **Variável**: `FILESYSTEM_BASE_PATH`
- **Valor padrão**: `./`. Ajuste para restringir o escopo de acesso a arquivos.

## Memory MCP
- **Variável**: `MEMORY_DB_PATH`
- **Valor padrão**: `./data/memory-store/memento.db`. O servidor `@iachilles/memento` cria o arquivo se ele não existir.

## Parâmetros gerais
- `MCP_LOG_LEVEL`: níveis aceitos `trace`, `debug`, `info`, `warn`, `error`.
- `MCP_TIMEOUT`: tempo (s) para aguardar respostas dos MCPs.
- `MCP_MAX_RETRIES`: número máximo de tentativas em erros transitórios.

> **Nunca** faça commit do arquivo `.env`. Utilize `git secret`, `1Password CLI` ou outra solução segura caso deseje compartilhar as chaves com a equipe.
