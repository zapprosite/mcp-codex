✅ Trae Git MCP - FIXED (template)
Data: 2025-11-04T14:43:22Z UTC
Erro Original: ERR_MODULE_NOT_FOUND (Node 25 + npx)
Solução: Usar Git MCP com Node LTS + dist/index.js

Mudanças Aplicadas
❌ Removido: GitHub MCP (npx)
✅ Adicionado: Git MCP (node.exe direto)

Config Aplicada
```json
{
  "name": "Git",
  "type": "stdio",
  "command": "C:\\Program Files\\nodejs\\node.exe",
  "args": [
    "C:\\Users\\Zappro\\.trae\\mcp\\git\\node_modules\\@cyanheads\\git-mcp-server\\dist\\index.js"
  ],
  "env": {
    "GITHUB_TOKEN": "ghp_..."
  }
}
```

Status (esperado após aplicar no Trae)
✅ Trae IDE: Connected
✅ Git MCP: Funcional
✅ Codex CLI: Sincronizado

Ferramentas Disponíveis (Git MCP)
- git_add, git_commit, git_push, git_pull
- git_branch, git_checkout, git_merge
- git_clone, git_status, git_log

Próximos Passos
1. Abra Trae IDE Settings
2. Remova "GitHub" MCP (npx)
3. Adicione "Git" MCP (JSON acima)
4. Salve e reinicie
5. Teste git_status()

Corrigido automaticamente em 2025-11-04T14:43:22Z

