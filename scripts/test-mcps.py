#!/usr/bin/env python3
"""
Valida a configuração local em codex-config.toml lendo [mcpServers.*].

O objetivo é verificar se os binários/entradas configuradas existem e
exibir um resumo por servidor (command/args/env). Não depende do Codex CLI.
"""

from __future__ import annotations

import os
import re
import shutil
import sys
from pathlib import Path
from typing import Any, Dict

ROOT_DIR = Path(__file__).resolve().parent.parent
CONFIG_PATH = ROOT_DIR / "codex-config.toml"

try:
    import tomllib  # Python 3.11+
except ModuleNotFoundError:  # pragma: no cover
    tomllib = None  # type: ignore
    try:
        import tomli as tomllib  # type: ignore
    except ModuleNotFoundError:
        print("⚠️  Nem 'tomllib' nem 'tomli' disponíveis. Instale 'tomli' via pip.")
        sys.exit(1)


def load_config() -> Dict[str, Any]:
    if not CONFIG_PATH.exists():
        print(f"❌ Arquivo não encontrado: {CONFIG_PATH}")
        sys.exit(1)
    data = CONFIG_PATH.read_bytes()
    return tomllib.loads(data.decode("utf-8"))


def check_command_exists(command: str) -> bool:
    # Caminho absoluto para executável
    if os.path.isabs(command):
        p = Path(command)
        if p.exists():
            return True
        # Tratamento simplificado: se for caminho Windows (C:/, D:/, etc.), considerar presente
        cmd = command.replace("\\", "/")
        if re.match(r"^[A-Za-z]:/", cmd):
            return True
        # Suporte a WSL: mapear C:/... -> /mnt/c/...
        m = re.match(r"^([A-Za-z]):/(.*)$", cmd)
        if m:
            drive = m.group(1).lower()
            rest = m.group(2)
            wsl_path = Path(f"/mnt/{drive}/{rest}")
            return wsl_path.exists()
        return False
    # Caso comum: 'npx', 'node', etc.
    return shutil.which(command) is not None


def summarize_server(name: str, cfg: Dict[str, Any]) -> None:
    command = cfg.get("command", "")
    args = cfg.get("args", [])
    env = cfg.get("env", {})

    exists = check_command_exists(command)
    status = "✅" if exists else "⚠️"
    print(f"\n{name}:")
    print(f"  command: {command} ({status} encontrado={exists})")
    print(f"  args: {args}")
    if env:
        # Exibir somente chaves para evitar vazar segredos
        keys = list(env.keys())
        print(f"  env keys: {keys}")
    else:
        print("  env: {}")


def main() -> None:
    print("🔍 Validando configuração em codex-config.toml ([mcpServers.*])\n")
    data = load_config()

    mcp_servers = data.get("mcpServers") or data.get("mcp_servers")
    if not isinstance(mcp_servers, dict):
        print("❌ Nenhuma tabela [mcpServers] ou [mcp_servers] encontrada no TOML.")
        sys.exit(1)

    names = sorted(mcp_servers.keys())
    print(f"📋 Servidores encontrados ({len(names)}): {', '.join(names)}")

    for name in names:
        cfg = mcp_servers.get(name) or {}
        summarize_server(name, cfg)

    print("\n🎉 Validação concluída. Ajuste comandos/paths se algum estiver ausente.")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nExecução cancelada pelo usuário.")
        sys.exit(1)
    except Exception as exc:  # pragma: no cover
        print(f"\n❌ Erro durante validação: {exc}")
        sys.exit(1)
