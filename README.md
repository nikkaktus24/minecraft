# Minecraft 1.20.1 Forge server (Portainer)

Docker Compose stack for a **Minecraft Java 1.20.1** dedicated server running **Forge 47.4.20**, with Industrial Craft 2: Refactored and the requested addons. Built for **Portainer stack deploy**. Jars are downloaded at container start — this repo does not commit Minecraft, Forge, or mod binaries.

Image: [`itzg/minecraft-server:java17`](https://github.com/itzg/docker-minecraft-server) (Java 17, required by 1.20.1).

## Loader

| Piece | Pin |
| --- | --- |
| Minecraft | Java Edition **1.20.1** |
| Loader | **Forge** (not NeoForge — the 1.20.1 IC2 Refactored ports and both addons are Forge) |
| Forge | **47.4.20** (`FORGE_VERSION`, overridable). Matches the Gradle pin in IC2 / Advanced Machines / Advanced Solar Panels. Later 47.4.x should work. |

## Mods (1.20.1 Forge)

All of the requested mods have a 1.20.1 Forge build. Nothing was substituted.

| Mod | File | Source | Extra required mods |
| --- | --- | --- | --- |
| Industrial Craft 2: Refactored | `ic2-forge-2.10.33-ex120.jar` | [craftorio/ic2 `2.10.33-ex120`](https://github.com/craftorio/ic2/releases/tag/2.10.33-ex120) | none |
| Advanced Machines (IC2 addon) | `advanced_machines-61.0.3-1.20.1.jar` | [craftorio/ic2-advanced-machines `61.0.3`](https://github.com/craftorio/ic2-advanced-machines/releases/tag/61.0.3) | IC2 ≥ `2.10.29-ex120` |
| Advanced Solar Panels (IC2 addon) | `advanced_solar_panels-4.3.1-1.20.1.jar` | [craftorio/ic2-advanced-solar-panels `4.3.1`](https://github.com/craftorio/ic2-advanced-solar-panels/releases/tag/4.3.1) | IC2 ≥ `2.10.26-ex120` |
| Just Enough Items | `jei-1.20.1-forge-15.56.0.205.jar` | Modrinth version `9jqubC9n` (latest **release**) | none on this release |
| JourneyMap | `journeymap-forge-1.20.1-6.0.7.jar` | Modrinth version `HWDC99DO` | none |

JEI is pinned to the latest **release**, not the current beta line. Newer JEI betas require [MezzConfig](https://modrinth.com/mod/mezzconfig); that extra library is not needed with 15.56.0.205.

IC2 / the addons are **not** on Modrinth or CurseForge for 1.20.1. The container pulls GitHub release URLs through itzg `MODS` (no API key). The same URLs live in `mods/urls.txt`. Checksums are in `mods/checksums.sha256`.

Upstream git (not used — no published jar yet): IC2 branch is `2.10.35-ex120`; Advanced Solar Panels branch is `4.3.2`. This stack uses the latest **released** jars.

## Ports to publish

| Port | Protocol | Purpose |
| --- | --- | --- |
| **25565** (host `SERVER_PORT`, default 25565) | TCP | Minecraft Java client connections |

Do **not** publish RCON (25575). The image uses RCON internally for a graceful stop.

## Named volumes

| Compose volume | Docker volume name (default prefix `mc-ic2`) | Container path |
| --- | --- | --- |
| `minecraft-world` | `mc-ic2-world` | `/data/world` |
| `minecraft-mods` | `mc-ic2-mods` | `/data/mods` |
| `minecraft-config` | `mc-ic2-config` | `/data/config` |
| `minecraft-logs` | `mc-ic2-logs` | `/data/logs` |
| `minecraft-data` | `mc-ic2-data` | `/data` (Forge installer, libraries, `server.properties`, EULA, …) |

Change the prefix with `VOLUME_PREFIX`. Nested mounts mean the world/mods/config/logs volumes overlay those folders inside `/data`.

## Environment

Copy `.env.example` → `.env` (compose CLI) or paste the keys into Portainer → Stack → **Environment variables**.

| Variable | Default | Notes |
| --- | --- | --- |
| `EULA` | `FALSE` | Must be `TRUE` |
| `MEMORY` | `5G` | JVM heap; intended range **4–6G** |
| `SERVER_PORT` | `25565` | Host TCP port |
| `FORGE_VERSION` | `47.4.20` | Forge build |
| `VOLUME_PREFIX` | `mc-ic2` | Named volume prefix |
| `UID` / `GID` | `1000` | Container process owner |
| `TZ` | `UTC` | Timezone |
| `MOTD`, `DIFFICULTY`, `MODE`, `ONLINE_MODE`, `MAX_PLAYERS`, `VIEW_DISTANCE`, `SIMULATION_DISTANCE`, `LEVEL` | see `.env.example` | Written to `server.properties` |
| `MAX_TICK_TIME` | `-1` | Watchdog off (typical for modded) |
| `USE_AIKAR_FLAGS` | `true` | JVM flags |
| `ENABLE_RCON` / `RCON_PASSWORD` | `true` / `minecraft` | Internal stop; change the password |
| `CF_API_KEY` / `MODRINTH_TOKEN` | unset | **Not required** for this stack |

Split heap (`INIT_MEMORY` / `MAX_MEMORY`) is documented in `.env.example` if you want 4G–6G instead of a single `MEMORY`.

## Deploy in Portainer

1. In Portainer: **Stacks → Add stack**.
2. **Git repository** (preferred): point at this repo, compose path `docker-compose.yml`, branch as deployed. **Web editor**: paste `docker-compose.yml`.
3. Under **Environment variables**, add every key from `.env.example`. Set **`EULA=TRUE`**.
4. Confirm port mapping `25565:25565` (or your `SERVER_PORT`).
5. Deploy. First boot downloads Forge 47.4.20 and the five mod jars (several minutes). Logs: container log or the `mc-ic2-logs` volume.
6. Connect with a **1.20.1 Forge** client (see below).

CLI equivalent:

```bash
cp .env.example .env
# set EULA=TRUE in .env
docker compose up -d
```

Give the JVM **4–6G** plus ~1.5–2G extra on the host for non-heap / OS. 5G heap is the default.

## Mods clients must install

Players need **Minecraft 1.20.1 + Forge 47.4.20** (or the same `FORGE_VERSION` as the server).

**Required to play the IC2 content** (install the same jars the server uses):

- `ic2-forge-2.10.33-ex120.jar`
- `advanced_machines-61.0.3-1.20.1.jar`
- `advanced_solar_panels-4.3.1-1.20.1.jar`

**Install on the client for those features** (server also has them):

- `jei-1.20.1-forge-15.56.0.205.jar` — recipe browser
- `journeymap-forge-1.20.1-6.0.7.jar` — map

Download links are in `mods/urls.txt`. `./scripts/fetch-mods.sh` pulls them into `mods/jars/` and checks sha256.

## How to add mods

1. **Preferred:** append a jar URL to `environment.MODS` in `docker-compose.yml` (and to `mods/urls.txt` if you keep that file in sync). Redeploy the stack. itzg downloads it into `/data/mods`.
2. **Drop a jar** into the `mc-ic2-mods` volume (Portainer → Volumes, or `docker cp`). Use 1.20.1 **Forge** jars only. Restart the container.
3. Optional local verify: `./scripts/fetch-mods.sh` then copy extra jars into that folder; do not commit `.jar` files.

Remove a URL from `MODS` if you want itzg to stop managing that download. Back up the mods volume before pruning.

## Helper scripts

| Script | Purpose |
| --- | --- |
| `scripts/fetch-mods.sh` | Download pinned jars to `mods/jars/` and `sha256sum -c` |
| `scripts/validate-compose.sh` | Expand env defaults and parse/validate `docker-compose.yml` |

## License / attribution

Mod jars are third-party. IC2: Refactored and the two addons declare “All Rights Reserved” in their Gradle metadata; this stack only downloads their published GitHub release artifacts at runtime. IC2 original: <https://industrial-craft.net/>. JEI and JourneyMap are used under their Modrinth licenses.
