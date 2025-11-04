# Prompts de Setup Rápido (Nov/2025)

Use os blocos abaixo no Codex CLI (Trae IDE/WSL). O primeiro cria e instala o novo `.env`; o segundo instala e valida os MCPs.

## 1) Instalar o novo .env (a partir do .env.example)

```
THINK
Quero instalar o novo .env e garantir que todas as chaves necessárias estejam definidas.

PLAN
1) Verificar dependências (node/npm/Codex CLI)
2) Copiar `.env.example` para `.env` (sem sobrescrever se já existir)
3) Executar assistente interativo `scripts/setup-apis.py` para preencher chaves
4) Exibir diff final do `.env`

EXECUTE
node -v
npm -v
command -v codex || command -v codex-cli
cp -n .env.example .env || echo ".env já existe (pulando cópia)"
python3 scripts/setup-apis.py
echo "\n--- .env (prévia) ---" && sed -n '1,80p' .env
```

## 2) Instalar MCPs e validar configuração

```
THINK
Com o .env pronto, quero instalar MCPs e validar que todos sobem.

PLAN
1) Instalar pacotes MCP no prefixo `.mcp/`
2) Verificar configuração do Codex CLI
3) Validar entradas do `codex-config.toml`

EXECUTE
bash scripts/install_mcps.sh
python3 scripts/test-mcps.py
```

Notas
- Segredos nunca devem ser comitados. `.env` já está ignorado.
- As chaves esperadas estão documentadas em `.env.example` e `docs/API-SETUP-GUIDE.md`.
