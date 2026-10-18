#!/usr/bin/env bash
# Expand ${VAR:-default} interpolations like Compose/Portainer, then parse YAML.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
compose="${1:-"$root/docker-compose.yml"}"
env_file="${ENV_FILE:-"$root/.env.example"}"

python3 - "$compose" "$env_file" <<'PY'
import os, re, sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit("PyYAML is required (python3 -m pip install pyyaml)")

compose_path, env_path = Path(sys.argv[1]), Path(sys.argv[2])
text = compose_path.read_text()

env = {}
if env_path.exists():
    for raw in env_path.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        env[key] = value

pattern = re.compile(r"\$\{([A-Za-z_][A-Za-z0-9_]*)(:-([^}]*))?\}")

def repl(match):
    key, _, default = match.group(1), match.group(2), match.group(3)
    if key in os.environ:
        return os.environ[key]
    if key in env and env[key] != "":
        return env[key]
    if default is not None:
        return default
    raise SystemExit(f"unset compose variable with no default: {key}")

expanded = pattern.sub(repl, text)
data = yaml.safe_load(expanded)
if not isinstance(data, dict) or "services" not in data:
    raise SystemExit("compose YAML missing top-level services")
svc = data["services"].get("minecraft")
if not svc:
    raise SystemExit("compose YAML missing services.minecraft")
for key in ("image", "environment", "ports", "volumes"):
    if key not in svc:
        raise SystemExit(f"services.minecraft missing {key}")
env_block = svc["environment"]
if not isinstance(env_block, dict):
    raise SystemExit("services.minecraft.environment must be a mapping")
for key in ("EULA", "TYPE", "VERSION", "MEMORY", "MODS"):
    if key not in env_block:
        raise SystemExit(f"minecraft environment missing {key}")
if str(env_block.get("TYPE")).upper() != "FORGE":
    raise SystemExit(f"expected TYPE=FORGE, got {env_block.get('TYPE')}")
if str(env_block.get("VERSION")) != "1.20.1":
    raise SystemExit(f"expected VERSION=1.20.1, got {env_block.get('VERSION')}")
mods = str(env_block.get("MODS") or "")
needed = (
    "ic2-forge-2.10.33-ex120.jar",
    "advanced_machines-61.0.3-1.20.1.jar",
    "advanced_solar_panels-4.3.1-1.20.1.jar",
    "jei-1.20.1-forge-15.56.0.205.jar",
    "journeymap-forge-1.20.1-6.0.7.jar",
    "serverlogin-1.0.3.jar",
    "tenshilib-1.20.1-1.7.6-forge.jar",
    "improvedmobs-1.20.1-1.13.7-forge.jar",
    "coroutil-forge-1.20.1-1.3.7.jar",
    "zombieawareness-1.20.1-1.13.1.jar",
    "Corgilib-Forge-1.20.1-4.0.3.6.jar",
    "Data_Anchor-forge-1.20.1-1.0.0.23.jar",
    "Enhanced-Celestials-forge-1.20.1-5.0.3.3.jar",
    "Atlas%20Lib-1.20.1-1.1.12.jar",
    "The-Hordes-1.20.1-1.6.3i-all.jar",
)
missing = [name for name in needed if name not in mods]
if missing:
    raise SystemExit(f"MODS is missing pinned jars: {missing}")
online = str(env_block.get("ONLINE_MODE")).strip().lower()
if online not in ("false", "0"):
    raise SystemExit(f"expected ONLINE_MODE=false for cracked clients, got {env_block.get('ONLINE_MODE')}")
if str(env_block.get("MAX_PLAYERS")) != "3":
    raise SystemExit(f"expected MAX_PLAYERS=3, got {env_block.get('MAX_PLAYERS')}")
if "volumes" not in data:
    raise SystemExit("compose YAML missing top-level volumes")
for vol in ("minecraft-world", "minecraft-mods", "minecraft-config", "minecraft-logs"):
    if vol not in data["volumes"]:
        raise SystemExit(f"missing named volume {vol}")
print(f"OK {compose_path} ({len(data['services'])} service, {len(data['volumes'])} volumes)")
PY
