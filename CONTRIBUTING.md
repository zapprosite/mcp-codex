# Contribuindo com o MCP Codex Orchestrator

## Requisitos

* Node 20+
* Codex CLI instalado
* systemd user habilitado

## Padrões de código

* Lint: `npm run lint` ou `bash -n script.sh`
* Commits:

  * `feat: novo script audit`
  * `fix: loop shim exit`
  * `docs: atualizar README`

## Fluxo PR

1. Criar branch
2. Rodar smoke
3. Rodar auditoria
4. Submeter PR

## Padrão de logs

```
[YYYY-MM-DDTHH:MM:SSZ] [MCP:env] sourced .env
[YYYY-MM-DDTHH:MM:SSZ] [MCP:daemon] start
```

## Revisão

* 1 reviewer técnico.
* 1 reviewer DevOps (lint, CI).
