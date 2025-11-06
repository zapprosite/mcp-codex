# Contribuição para o MCP Codex

1. **Branches e fluxo**
   - Branch principal: `master` (após a auditoria de novembro/2025).
   - Crie branches funcionais a partir de `master` e abra Pull Requests descrevendo impacto.
2. **Segredos e arquivos sensíveis**
   - Nunca versione `.env` ou derivados. Utilize `python scripts/validate-env.py` para checar variáveis faltantes.
   - Verifique o repositório local com `git ls-files` antes de cada commit para garantir que nenhuma chave/token foi adicionada.
3. **Checklist antes do commit**
   - Rode `python3 scripts/test-mcps.py` para garantir que os MCPs configurados respondem.
   - Execute `npm test` ou a suíte relevante ao alterar código TypeScript/Node.
   - Use `npm run lint` (quando aplicável) e corrija avisos críticos.
4. **Padrões de commits**
   - Mensagens em português no formato `tipo: resumo curto` (ex.: `fix: atualizar teste do sqlite`).
   - Commits que mexem em segurança devem incluir o termo `seguranca` no resumo.
5. **Documentação**
   - Toda alteração de fluxo deve ser refletida em `docs/` e, se necessário, adicionada à seção "Política de Auditoria" do README.
   - Atualize ou crie arquivos `*.md` com instruções reproduzíveis.

> Dúvidas? Abra uma issue no repositório descrevendo o contexto ou consulte `docs/SECURITY-AUDIT-2025-11.md` para entender o racional de segurança atual.
