# Guia de Isolamento de MCPs no Trae IDE (Windows)

Este guia descreve como manter MCPs do Trae IDE totalmente isolados dos MCPs usados pelo Codex CLI, evitando conflitos de cache, Node e variáveis de ambiente.

## Pré-requisitos
- Node.js LTS 20.x instalado (idealmente no caminho fixo `C:\Program Files\nodejs\node.exe`).
- Permissões de leitura/escrita no diretório do usuário.
- Pacotes MCP que deseja usar (ex.: `github-mcp-custom`, `@cyanheads/git-mcp-server`, `@brave-intl/brave-search-mcp`).

## 1. Diretório dedicado de MCPs
- Crie um diretório isolado para os MCPs do Trae: `C:\Users\<user>\.trae\mcp`.
- Mantenha cada MCP como um pacote dentro de `node_modules` desse diretório.
- Use o script de preparação:

```
PowerShell
./scripts/trae-mcp-setup.ps1 -TargetDir "C:\Users\<user>\.trae\mcp" -NodePath "C:\Program Files\nodejs\node.exe" -Packages @(
  "github-mcp-custom",
  "@cyanheads/git-mcp-server",
  "@brave-intl/brave-search-mcp"
)
```

## 2. Configuração no Trae IDE
- Para cada MCP:
  - `command`: caminho absoluto para `node.exe` (Node 20)
  - `args`: caminho absoluto para `dist/index.js` do pacote instalado em `C:\Users\<user>\.trae\mcp\node_modules\<pacote>\dist\index.js`
  - Desative o uso de `npx` (não usar `npx` na configuração do Trae).
  - Evite depender do cache global `npm`.

### Exemplo: GitHub MCP (2 variações)
1) `github-mcp-custom`:
- command: `C:\Program Files\nodejs\node.exe`
- args: `C:\Users\<user>\.trae\mcp\node_modules\github-mcp-custom\dist\index.js`
- env:
  - `GITHUB_TOKEN`: token de acesso (mínimo escopo necessário)

2) `@cyanheads/git-mcp-server` (alternativa estável):
- command: `C:\Program Files\nodejs\node.exe`
- args: `C:\Users\<user>\.trae\mcp\node_modules\@cyanheads\git-mcp-server\dist\index.js`
- env:
  - `GITHUB_TOKEN`: token de acesso

### Exemplo: Brave Search MCP
- command: `C:\Program Files\nodejs\node.exe`
- args: `C:\Users\<user>\.trae\mcp\node_modules\@brave-intl\brave-search-mcp\dist\index.js`
- env:
  - `BRAVE_API_KEY`: chave da API Brave

## 3. Variáveis de Ambiente
- Defina todas as variáveis diretamente na configuração de cada MCP no Trae.
- Não leia automaticamente o `.env` do projeto.
- Agrupe por MCP para evitar conflitos.

### Template de variáveis por MCP
```
GitHub MCP
- GITHUB_TOKEN=ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXX

Brave MCP
- BRAVE_API_KEY=brv_XXXXXXXXXXXXXXXXXXXXXXXXXXXX

MySQL MCP (exemplo)
- MYSQL_HOST=localhost
- MYSQL_PORT=3306
- MYSQL_USER=root
- MYSQL_PASSWORD=********
- MYSQL_DATABASE=appdb
```

## 4. Boas Práticas
- Documente a configuração de cada MCP (command, args, env) em `docs/` e mantenha versionado.
- Use versionamento sem segredos: tokens e chaves nunca devem estar em plain text no repositório.
- Crie templates reutilizáveis com placeholders para variáveis.

### Template de configuração (para documentação)
```
MCP: <nome>
- command: C:\Program Files\nodejs\node.exe
- args:    C:\Users\<user>\.trae\mcp\node_modules\<pacote>\dist\index.js
- env:
  - KEY_1=<placeholder>
  - KEY_2=<placeholder>
Observações: <links, requisitos de escopo, etc>
```

## 5. Validação
- Inicie cada MCP no Trae e verifique os logs (sem `ERR_MODULE_NOT_FOUND`, sem `Connection closed`).
- Se houver erro de resolução de módulos:
  - Garanta que `dist/index.js` existe no pacote.
  - Reinstale o pacote com o script (sem `npx`).
  - Verifique a versão do Node (deve ser 20.x).

## 6. Isolação em relação ao Codex CLI
- Continue usando `scripts/codex-env.ps1` para carregar `.env` somente em comandos do Codex.
- Mantenha MCPs do Codex instalados via `scripts/install_mcps.sh` (WSL) e variáveis do projeto.
- Não compartilhe diretório, cache, nem Node entre Trae e Codex.

---

# Fetch MCP no Trae (uvx recomendado)

Este capítulo cobre a configuração do Fetch MCP Server no Trae IDE utilizando `uvx`, com comparação prática e notas para Windows 11/WSL.

## Comparação: npx vs uvx
- Recomendação: `uvx` ✅; `npx` ❌ para Trae isolado
- Performance: `uvx` geralmente mais rápido
- Segurança: `uvx` com ambientes isolados; `npx` baixa segurança (executa pacote com acesso total)
- Windows 11/WSL: `uvx` nativo e estável; `npx` pode exigir `PYTHONIOENCODING`
- Exemplos de uso:
  - `npx -y mcp-server-fetch`
  - `uvx mcp-server-fetch`

Referências: Storm MCP executáveis e boas práticas [stormmcp.ai/blog/mcp-server-executables-explained], Fetch MCP docs (Playbooks) [playbooks.com/mcp/modelcontextprotocol-fetch], Modelscope Fetch MCP [modelscope.cn/mcp/servers/@modelcontextprotocol/fetch].

## Configuração recomendada (Trae → Add Manually)
JSON para stdio com `uvx` e variável de ambiente no Windows:
```
{
  "mcpServers": {
    "fetch": {
      "command": "uvx",
      "args": ["mcp-server-fetch"],
      "env": {
        "PYTHONIOENCODING": "utf-8"
      }
    }
  }
}
```

Notas:
- `uvx` requer instalação do `uv` (Windows PowerShell):
  - `powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`
- Se preferir `python -m mcp_server_fetch`, ajuste `command` para `python` e `args` para `["-m", "mcp_server_fetch"]` (ver docs do Fetch MCP em Playbooks/Modelscope).

## WSL e Trae IDE: pontos de atenção
- WebSocket em WSL: há relatos de falha de conexão no Trae com WSL (Issue #766) — use o Trae no host Windows para máxima compatibilidade [github.com/Trae-AI/Trae/issues/766].
- Portas MCP/Projeto: evite conflitos (ex.: porta 3000 ocupada). Ajuste a porta do seu projeto se necessário.
- Distribuição: prefira Ubuntu 24.04 no WSL; NixOS pode apresentar incompatibilidades.
- Prática recomendada: mantenha MCPs do Trae fora do WSL; execute MCPs locais via stdio no Windows com `uvx`/`python`.

## Debug e inspeção
- MCP Inspector:
  - `npx @modelcontextprotocol/inspector uvx mcp-server-fetch`
- Se tempo limite/encoding no Windows, garanta `PYTHONIOENCODING=utf-8` na configuração do MCP.

## PowerShell vs WSL — diferenças operacionais que impactam o projeto

Este projeto pode operar tanto no host Windows (PowerShell) quanto no WSL (Ubuntu-24.04). Abaixo estão diferenças práticas que afetam comandos, scripts e execução de serviços MCP/HTTP:

- Caminhos e separadores
  - Windows/PowerShell usa `C:\...` e separador `\`; WSL usa `/mnt/c/...` e `/`.
  - Exemplo: `d:\projetos\mcp-codex` no WSL é visto como `/mnt/d/projetos/mcp-codex`.

- Variáveis de ambiente e quoting
  - PowerShell define com `$Env:VAR = 'valor'`; WSL usa `export VAR=valor`.
  - Aspas e expansão diferem; ao chamar comandos com JSON ou arrays no WSL, preferir aspas simples `'...'` para evitar expansões indesejadas.

- Ferramentas e disponibilidade
  - Binários instalados no Windows (ex.: `uvx`, `node`, `npx`) não estão automaticamente disponíveis no WSL. Instale-os também no WSL se forem usados dentro dele.
  - Utilitários HTTP: instale `curl`, `wget`, `ca-certificates` no WSL: `sudo apt update && sudo apt install -y curl ca-certificates wget`.

- Rede e binding de serviços
  - Serviços iniciados no Windows e bindados em `127.0.0.1` geralmente são acessíveis a partir do WSL em `localhost`.
  - O inverso (serviços iniciados no WSL) pode exigir bind em `0.0.0.0` e regras de firewall/roteamento para acesso pelo Windows.
  - WebSockets/SSE podem apresentar diferenças; recomenda-se expor UI/HTTP no host Windows quando possível.

- Arquivos e permissões
  - WSL respeita permissões POSIX; scripts podem precisar de `chmod +x`.
  - Cuidado com `CRLF` vs `LF` em scripts; prefira `LF` para Bash.

- Execução cruzada
  - Para chamar comandos Linux a partir do Windows use `wsl.exe bash -lc "<comando>"` garantindo PATH e ambiente do WSL.
  - Scripts `.ps1` rodam no PowerShell; scripts `.sh` rodam no WSL (Bash).

### Validações úteis no WSL

Para testar serviços locais e dependências de rede no WSL:

- HTTP/HTTPS externo:
  - `curl -I -sS https://example.com | head -n 1` deve retornar algo como `HTTP/2 200`.

- Serviço local na porta 6274:
  - Teste conexão HTTP: `curl -sS -o /dev/null -w '%{http_code} %{content_type}\n' 'http://localhost:6274/?MCP_PROXY_AUTH_TOKEN=<TOKEN>'`.
  - Teste de porta: `(echo > /dev/tcp/localhost/6274) >/dev/null 2>&1 && echo 'port 6274: open' || echo 'port 6274: closed'`.
  - Se a porta estiver fechada, inicie o serviço esperado no host Windows e confirme que está escutando em `127.0.0.1:6274`.

### Recomendações

- Preferir executar MCPs conectados ao Trae no host Windows (stdio) para minimizar problemas de transporte.
- Quando optar por executar ferramentas no WSL, mantenha instalações e variáveis independentes das do Windows.
- Documente comandos equivalentes para ambos os ambientes em `docs/` e evite misturar caminhos Windows em scripts Bash.
## GitHub MCP (npx oficial)

Alinhado aos exemplos oficiais do Model Context Protocol, o servidor GitHub pode ser iniciado com `npx` e configurado manualmente no Trae.

- Referências oficiais:
  - Lista de servidores MCP (inclui status de manutenção) — https://github.com/modelcontextprotocol/servers
  - Exemplos de uso (inclui configuração com npx) — https://modelcontextprotocol.io/examples

Importante: O servidor GitHub listado nos repositórios oficiais está classificado como “Archived” na coleção de referência. Embora o exemplo de configuração com `npx` continue disponível, recomenda-se validar compatibilidade de versões e considerar alternativas quando necessário. Veja também o requisito de Docker citado pela documentação do Trae para servidores GitHub obtidos via marketplace.

### Pré-requisitos
- Node.js 18 ou superior — recomenda-se Node 20 LTS para estabilidade com `npx`.
- `npx` disponível no PATH do Windows host.
- Token pessoal do GitHub: `GITHUB_PERSONAL_ACCESS_TOKEN` com escopos adequados (por exemplo, `repo`, conforme suas operações).

### Configuração manual no Trae (stdio/npx)
No Trae IDE, abra “MCP” → “Add Manually” e cole este JSON. Prefira apontar o executável `npx` do Windows com caminho absoluto (quando possível) para evitar conflitos de PATH.

```json
{
  "name": "GitHub",
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "<SEU_TOKEN>"
  }
}
```

Se desejar garantir a versão de Node utilizada pelo `npx`, aponte explicitamente para o executável do Windows (requer Node 20 instalado):

```json
{
  "name": "GitHub",
  "type": "stdio",
  "command": "C:\\Program Files\\nodejs\\npx.cmd",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "<SEU_TOKEN>"
  }
}
```

### Fallback (node.exe + dist/index.js)
Se `npx` apresentar erros (por exemplo, `ERR_MODULE_NOT_FOUND` em versões muito novas do Node), instale o pacote em um diretório isolado para o Trae e aponte diretamente para o entrypoint via `node.exe`:

1) Prepare um diretório isolado (ex.: `C:\\Users\\<usuario>\\.trae\\mcp\\github`) e instale o pacote:

```
cd C:\\Users\\<usuario>\\.trae\\mcp\\github
npm init -y
npm i @modelcontextprotocol/server-github
```

2) Configure no Trae usando `node.exe` e o `dist/index.js` do pacote:

```json
{
  "name": "GitHub",
  "type": "stdio",
  "command": "C:\\Program Files\\nodejs\\node.exe",
  "args": [
    "C:\\Users\\<usuario>\\.trae\\mcp\\github\\node_modules\\@modelcontextprotocol\\server-github\\dist\\index.js"
  ],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "<SEU_TOKEN>"
  }
}
```

### Versões e compatibilidade
- Node 20 LTS recomendado para evitar erros de resolução ESM em pacotes que não foram validados com Node 25+.
- Em Windows/WSL, rode o Trae e os executáveis MCP no Windows host para minimizar problemas com SSE/WebSocket e PATH.
- O servidor GitHub nos repositórios oficiais está marcado como “Archived”; valide se sua necessidade é melhor atendida pelo servidor `Git` (Python) via `uvx`, que permanece como referência ativa:

```bash
uvx mcp-server-git --help
```

### Testes e validação
- Terminal (Windows):
  - `node -v` e `npx -v`
  - `npx -y @modelcontextprotocol/server-github --help`
  - Se falhar com `ERR_MODULE_NOT_FOUND`, aplique o fallback ou fixe Node 20.
- Trae IDE:
  - Verifique que o servidor aparece como “Connected”.
  - Use ferramentas do MCP GitHub (listar/operar repositórios conforme suporte do servidor).
  - Erros comuns:
    - `Connection closed`: verifique PATH/command/args, token e transporte correto.
    - `ERR_MODULE_NOT_FOUND`: ajuste versão do Node ou use fallback `node.exe + dist/index.js`.
    - 401/403: verifique o escopo e validade do `GITHUB_PERSONAL_ACCESS_TOKEN`.
