# MCP Codex Setup — Novembro/2025

Estrutura completa para instalar e validar os MCPs mais usados com o Codex CLI dentro do WSL Ubuntu 24.04 (Trae IDE). Inclui prompt inicial, template `.env`, configuração TOML, scripts automatizados e guias de API.

## Pré-requisitos
- Node.js 18+ e npm no WSL.
- Codex CLI instalado globalmente (`npm i -g @smithery-ai/codex-cli`).
- Acesso às chaves das integrações: GitHub, Brave Search, Exa, Context7, Playwright (opcional), Obsidian (opcional).
  Para o modelo, utilize login OAuth no Codex/Trae (sem `OPENAI_*`).

## Passos rápidos
1. Leia o `PROMPT.md` e execute o prompt principal se quiser gerar a estrutura via Codex CLI.
2. Copie o template: `cp .env.example .env` ou rode `python scripts/setup-apis.py` para preencher interativamente.
3. Instale tudo com `bash scripts/install_mcps.sh`.
4. Valide a configuração via `python3 scripts/test-mcps.py`.
5. Consulte `docs/API-SETUP-GUIDE.md` para detalhes das credenciais e `docs/MCP-USAGE-GUIDE.md` para exemplos de uso.

## Conteúdo
- `codex-config.toml`: lista dos 16 MCPs (10 principais + 6 adicionais) já parametrizados.
- `scripts/install_mcps.sh`: instala MCPs via npm (prefix `.mcp/`), copia config e checa o Codex CLI.
- `scripts/setup-apis.py`: wizard para preencher `.env`, com validação leve das chaves.
- `scripts/test-mcps.py`: roda `codex mcp list/info` e sinaliza MCPs com issues.
- `docs/API-SETUP-GUIDE.md`: links oficiais para gerar cada chave/token.
- `docs/MCP-USAGE-GUIDE.md`: comandos recomendados para debug e uso cotidiano.

## MCPs incluídos
- `sequential-thinking` — `@modelcontextprotocol/server-sequential-thinking`
- `shell` — `@mkusaka/mcp-shell-server`
- `github` — `@modelcontextprotocol/server-github`
- `brave-search` — `@brave/brave-search-mcp-server`
- `web-research` — `@mzxrai/mcp-webresearch`
- `task-manager` — `@kazuph/mcp-taskmanager`
- `sqlite` — `mcp-server-sqlite-npx`
- `fetch` — `@mokei/mcp-fetch`
- `memory` — `@iachilles/memento`
- `playwright` — `@executeautomation/playwright-mcp-server`
- `filesystem` — `@modelcontextprotocol/server-filesystem`
- `desktop-commander` — `@wonderwhy-er/desktop-commander`
- `exa-search` — `exa-mcp`
- `obsidian` — `mcp-obsidian`
- `context7` — `@upstash/context7-mcp`
- `git` — `@cyanheads/git-mcp-server`

> Observações: `@modelcontextprotocol/server-github` é marcado como deprecated no npm, mas continua funcional (última verificação 03/11/2025). O servidor `fetch` oficial é distribuído via Python (`mcp-server-fetch`), portanto usamos o pacote `@mokei/mcp-fetch` para manter o fluxo baseado em npm.

## Próximos passos sugeridos
- Versionar o projeto após preencher `.env` (garanta que `.env` está no `.gitignore`).
- Agendar revisão periódica das chaves (rotacionar tokens sensíveis).
- Ajustar `codex-config.toml` caso precise habilitar/desabilitar MCPs específicos (ex.: `iterm-mcp` no macOS).

## Isolamento Trae IDE vs Codex CLI

- Objetivo: evitar conflitos entre MCPs e variáveis quando usar Trae IDE e Codex CLI no mesmo PC.
- Como manter isolado:
  - Codex CLI
    - Usa `~/.codex/config.toml` e os pacotes instalados no prefixo local `.mcp/` do projeto.
    - Carregue o `.env` apenas no processo do Codex com `scripts/codex-env.ps1`:
      - `./scripts/codex-env.ps1 codex mcp list`
      - `./scripts/codex-env.ps1 python scripts/test-mcps.py`
    - Recomenda-se Node LTS 20 no WSL (conforme pré-requisitos).
  - Trae IDE
    - Configure cada MCP diretamente no Trae, com pacote instalado em um diretório separado (ex.: `C:\Users\<user>\.trae\mcp`).
    - Prefira executar via `node.exe` (caminho absoluto do Node 20) apontando para o `dist/index.js` do MCP, em vez de `npx`.
    - Defina variáveis de ambiente por MCP dentro do Trae, sem depender do `.env` do projeto.
- Benefícios:
  - Sem compartilhamento de caches `npx` e dependências entre Trae e Codex.
  - Tokens e chaves ficam separados; o `.env` só afeta o processo do Codex.
  - Reduz erros como `ERR_MODULE_NOT_FOUND` em caches do `npx` e conflitos de versão do Node.
