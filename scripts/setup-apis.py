#!/usr/bin/env python3
"""
Script interativo para configurar variáveis das APIs usadas pelos MCPs.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path
from typing import Dict

try:
    import requests
except ModuleNotFoundError:
    print("⚠️  O pacote 'requests' não está instalado. Execute 'pip install requests' e tente novamente.")
    sys.exit(1)

ROOT_DIR = Path(__file__).resolve().parent.parent
ENV_PATH = ROOT_DIR / ".env"
ENV_ORDER = [
    "GITHUB_TOKEN",
    "BRAVE_API_KEY",
    "EXA_API_KEY",
    "CONTEXT7_API_KEY",
    "PLAYWRIGHT_WS_ENDPOINT",
    "OBSIDIAN_VAULT_PATH",
    "SQLITE_DB_PATH",
    "FILESYSTEM_BASE_PATH",
    "MEMORY_DB_PATH",
    "MCP_LOG_LEVEL",
    "MCP_TIMEOUT",
    "MCP_MAX_RETRIES",
]


def check_api_key(service: str, value: str) -> bool:
    """Valida rapidamente algumas chaves chamando os endpoints públicos básicos."""
    try:
        if service == "github":
            headers = {"Authorization": f"token {value}"}
            response = requests.get("https://api.github.com/user", headers=headers, timeout=10)
            return response.status_code == 200
        if service == "brave":
            headers = {"X-Subscription-Token": value}
            response = requests.get(
                "https://api.search.brave.com/res/v1/web/search?q=test",
                headers=headers,
                timeout=10,
            )
            return response.status_code == 200
        if service == "exa":
            headers = {"Authorization": f"Bearer {value}"}
            response = requests.post(
                "https://api.exa.ai/search",
                headers=headers,
                json={"query": "test", "num_results": 1},
                timeout=10,
            )
            return response.status_code == 200
    except requests.RequestException:
        return False
    return True


def prompt_env() -> Dict[str, str]:
    """Recolhe inputs do usuário."""
    print("🔧 Configuração interativa do arquivo .env")
    print("=" * 60)

    env: Dict[str, str] = {}

    # Modelo via OAuth (sem chaves OpenAI) — nenhuma coleta necessária aqui.

    # GitHub
    print("\n🐙 GitHub Personal Access Token (https://github.com/settings/tokens?type=beta)")
    github_token = input("GITHUB_TOKEN: ").strip()
    if github_token:
        if check_api_key("github", github_token):
            print("✅ Token GitHub validado.")
        else:
            print("⚠️  Não foi possível validar o token GitHub.")
        env["GITHUB_TOKEN"] = github_token

    # Brave
    print("\n🔍 Brave Search API (https://brave.com/search/api/)")
    brave_key = input("BRAVE_API_KEY: ").strip()
    if brave_key:
        if check_api_key("brave", brave_key):
            print("✅ Chave Brave válida.")
        else:
            print("⚠️  Não foi possível validar a chave Brave.")
        env["BRAVE_API_KEY"] = brave_key

    # Exa
    print("\n🎯 Exa API (https://exa.ai/)")
    exa_key = input("EXA_API_KEY: ").strip()
    if exa_key:
        if check_api_key("exa", exa_key):
            print("✅ Chave Exa válida.")
        else:
            print("⚠️  Não foi possível validar a chave Exa.")
        env["EXA_API_KEY"] = exa_key

    # Context7
    print("\n📚 Context7 API (https://context7.com)")
    context7_key = input("CONTEXT7_API_KEY: ").strip()
    if context7_key:
        env["CONTEXT7_API_KEY"] = context7_key

    # Playwright
    print("\n🧪 Playwright MCP (opcional). Informe endpoint WebSocket remoto se usar grid/self-hosted.")
    playwright_ws = input("PLAYWRIGHT_WS_ENDPOINT (deixe vazio para usar browser local): ").strip()
    if playwright_ws:
        env["PLAYWRIGHT_WS_ENDPOINT"] = playwright_ws

    # Obsidian
    print("\n🗂  Obsidian MCP exige o caminho da vault.")
    obsidian_path = input("OBSIDIAN_VAULT_PATH (ex.: /mnt/d/notas/MinhaVault): ").strip()
    if obsidian_path:
        env["OBSIDIAN_VAULT_PATH"] = obsidian_path

    # Defaults locais
    # Sem variáveis OPENAI_* — uso por OAuth no Codex/Trae.
    env.setdefault("GITHUB_TOKEN", "")
    env.setdefault("BRAVE_API_KEY", "")
    env.setdefault("EXA_API_KEY", "")
    env.setdefault("CONTEXT7_API_KEY", "")
    env.setdefault("PLAYWRIGHT_WS_ENDPOINT", "")
    env.setdefault("OBSIDIAN_VAULT_PATH", "")
    env.setdefault("SQLITE_DB_PATH", "./data/mcp_database.db")
    env.setdefault("FILESYSTEM_BASE_PATH", "./")
    env.setdefault("MEMORY_DB_PATH", "./data/memory-store/memento.db")
    env.setdefault("MCP_LOG_LEVEL", "info")
    env.setdefault("MCP_TIMEOUT", "30")
    env.setdefault("MCP_MAX_RETRIES", "3")

    return env


def save_env(values: Dict[str, str]) -> None:
    """Grava arquivo .env no diretório raiz."""
    lines = []
    for key in ENV_ORDER:
        if key in values:
            lines.append(f"{key}={values[key]}")
    for key, value in values.items():
        if key not in ENV_ORDER:
            lines.append(f"{key}={value}")

    ENV_PATH.write_text(
        "# MCP Codex CLI - Configuração gerada por setup-apis.py\n"
        "# Nunca faça commit deste arquivo.\n\n"
        + "\n".join(lines)
        + "\n",
        encoding="utf-8",
    )
    print(f"\n✅ Arquivo .env atualizado em {ENV_PATH}")


def main() -> None:
    if not ENV_PATH.exists():
        print("⚠️  .env não encontrado. Um novo arquivo será criado a partir do template.")
    env_values = prompt_env()
    save_env(env_values)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n❌ Configuração cancelada pelo usuário.")
        sys.exit(1)
    except Exception as exc:  # pragma: no cover
        print(f"\n❌ Erro durante configuração: {exc}")
        sys.exit(1)
