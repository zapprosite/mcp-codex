# Registro da Auditoria de Segurança — Novembro/2025

Esta auditoria visa garantir que o repositório MCP Codex esteja alinhado às melhores práticas antes de torná-lo o branch principal (`master`). A sequência abaixo resume as ações executadas:

1. **Snapshot completo**
   - Branch criado: `backup-pre-auditoria`.
   - Snapshot gerado em `backup-pre-auditoria.tar.gz` contendo TODO o diretório, inclusive itens do `.gitignore`.
2. **Revisão de rastreamento**
   - Ferramenta: `git ls-files` para identificar arquivos versionados inadequados.
   - Diretórios `.codex/`, `artifacts/` e `.vscode/` removidos do versionamento.
3. **Limpeza de histórico**
   - Ferramenta adotada: `git filter-repo --force --path .codex --path artifacts --path .vscode --invert-paths --refs main`.
   - Resultado: remoção desses caminhos de todo o histórico.
4. **Atualização do `.gitignore`**
   - Padrões abrangentes para ambientes, dependências, builds, IDEs, logs e dados temporários.
   - Exceções adicionadas para preservar placeholders (`!data/.gitkeep`).
5. **Documentação & comunicação**
   - README atualizado com diretrizes de segurança.
   - `CONTRIBUTING.md` criado com política de commits e verificação de segredos.
   - Alerta para notificar colaboradores sobre a troca do branch principal.

## Recomendações contínuas
- Repetir `python3 scripts/validate-env.py` e `python3 scripts/test-mcps.py` após alterações em variáveis ou pacotes MCP.
- Agendar auditorias semestrais repetindo os passos acima.
- Manter o branch `backup-pre-auditoria` apenas como referência; não aceitar merges nele.

## Histórico dos comandos executados
```
git checkout -b backup-pre-auditoria
tar --exclude='.git' --exclude='backup-pre-auditoria.tar.gz' -czf backup-pre-auditoria.tar.gz .
git add backup-pre-auditoria.tar.gz
python3 -m pip install --user --break-system-packages git-filter-repo
git filter-repo --force --path .codex --path artifacts --path .vscode --invert-paths --refs main
```

> Observação: o branch `backup-pre-auditoria` permanece intacto como salvaguarda caso seja necessário restaurar arquivos removidos pela limpeza de histórico.
