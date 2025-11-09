# AGENTS.md — Contrato de Execução e Orquestração Codex CLI (Data 08/11/2025)

## 1. Propósito
Definir normas para que o Codex CLI opere sob disciplina controlada, sem improvisação,
garantindo que todos os agentes (MCPs e Daemon) executem tarefas de forma previsível,
determinística e auditável.

---

## 2. Regras de Conduta
- O Codex **não deve gerar ou alterar lógica por conta própria**.  
  Toda modificação deve seguir os prompts e arquivos oficiais (.env, scripts/).
- **É proibido improvisar** variáveis ou chaves fora de `.env` ou `.env.example`.
- O daemon e os MCPs devem ser inicializados **sempre via wrapper automático**.
- Cada execução deve ser registrada em `~/.codex/auto-run.log`.

---

## 3. Estrutura de Controle
- **Wrapper oficial:** `~/.npm-global/bin/codex`
  - Renomeia o binário real → `codex-real`
  - Injeta e garante `MCP_PROMPT_SEED=dual-mcp-orchestrator`
  - Carrega `.env` e `.env.example`
  - Inicia o daemon com retry (3 tentativas)
  - Cacheia MCPs em `~/.codex/mcp-health.json`
  - Corrige TTY no WSL usando `script`

---

## 4. Contratos Técnicos

### Variáveis críticas
| Variável | Obrigatória | Função |
|-----------|--------------|--------|
| MCP_PROMPT_SEED | ✅ | Ativa orquestrador dual-MCP |
| GITHUB_TOKEN | ✅ | Autenticação GitHub MCP |
| BRAVE_API_KEY | ✅ | Busca externa |
| EXA_API_KEY | ✅ | Busca alternativa |
| CONTEXT7_API_KEY | ✅ | Enriquecimento semântico |

### Logs
- `~/.codex/auto-run.log` → auditoria de execuções
- `~/.codex/daemon.log` → inicialização do daemon
- `~/.codex/mcp-health.json` → cache do inventário MCP

---

## 5. Contratos de Execução

### Regras de inicialização
1. Se `.env` e `.env.example` não existirem → gerar modelos mínimos.
2. Sempre garantir `MCP_PROMPT_SEED` antes de executar.
3. Iniciar daemon via:
   ```bash
   codex daemon:start --profile=dual-mcp-orchestrator
Caso o daemon falhe → tentar novamente 3 vezes com sleep 1s.

Nunca rodar daemon:status (não existe oficialmente).

6. Testes Smoke obrigatórios
Executar automaticamente após instalação:

bash
Copiar código
# 1. Confirma seed
codex env:seed | grep dual-mcp-orchestrator

# 2. Checa daemon
pgrep -af 'codex .*daemon' || codex daemon:start --profile=dual-mcp-orchestrator >/dev/null 2>&1

# 3. Garante cache
test -s ~/.codex/mcp-health.json && wc -c ~/.codex/mcp-health.json

# 4. Valida logs
tail -n 10 ~/.codex/auto-run.log

# 5. Inspeção .env
grep MCP_PROMPT_SEED .env
7. Política de Fallback
Caso algum MCP falhe, o daemon deve seguir a cadeia:

Recarregar cache.

Registrar erro no log.

Continuar execução com MCPs restantes.

8. Política de Atualização
Alterações no wrapper devem manter compatibilidade.

Nenhum script pode sobrescrever segredos existentes.

Antes de qualquer upgrade, rodar novamente os testes Smoke.

9. Auditoria e Controle
Todos os logs devem conter timestamps UTC (ISO 8601).

Erros de inicialização devem ser marcados com [WARN] ou [ERR].

O wrapper é soberano: qualquer chamada direta ao codex-real
fora do wrapper é considerada fora de compliance.

10. Conclusão
Com este contrato, o Codex CLI atua sob orquestração completa,
mantendo a integridade do ambiente MCP, estabilidade no daemon
e reprodutibilidade das execuções.
