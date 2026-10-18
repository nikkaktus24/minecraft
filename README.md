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
| Server Login (server-only) | `serverlogin-1.0.3.jar` | Modrinth `hfNV8isR` | none — **not** installed on clients |
| TenshiLib | `tenshilib-1.20.1-1.7.6-forge.jar` | Modrinth `5elJ9ZTS` | hard dep of Improved Mobs |
| Improved Mobs | `improvedmobs-1.20.1-1.13.7-forge.jar` | Modrinth `hQPzm4z2` | TenshiLib |
| CoroUtil | `coroutil-forge-1.20.1-1.3.7.jar` | Modrinth `6rPDKAT8` | hard dep of Zombie Awareness |
| Zombie Awareness | `zombieawareness-1.20.1-1.13.1.jar` | Modrinth `vmo9rLxO` | CoroUtil |
| CorgiLib | `Corgilib-Forge-1.20.1-4.0.3.6.jar` | Modrinth `OtJzHtsl` | hard dep of Enhanced Celestials |
| Data Anchor | `Data_Anchor-forge-1.20.1-1.0.0.23.jar` | Modrinth `ybaOCLNa` | hard dep of Enhanced Celestials |
| Enhanced Celestials | `Enhanced-Celestials-forge-1.20.1-5.0.3.3.jar` | Modrinth `FU1k4KeY` | CorgiLib + Data Anchor |
| Atlas Lib | `Atlas Lib-1.20.1-1.1.12.jar` | Modrinth `PKJi0BrP` | hard dep of The Hordes (filename contains a space) |
| The Hordes | `The-Hordes-1.20.1-1.6.3i-all.jar` | Modrinth `WMyMpstF` | Atlas Lib |

JEI is pinned to the latest **release**, not the current beta line. Newer JEI betas require [MezzConfig](https://modrinth.com/mod/mezzconfig); that extra library is not needed with 15.56.0.205.

All four difficulty mods have a 1.20.1 Forge build. Extra jars are **hard dependencies only**:

- **TenshiLib 1.7.6** is the latest *published* 1.20.1 Forge build (Improved Mobs requires TenshiLib).
- **The Hordes** lists Atlas Lib as required. Modrinth version `WMyMpstF` points that required dep at Atlas `UekJfJ7l` (**1.12.2** `Atlas-Lib-1.12.2-1.1.11.jar`) — a metadata bug. This stack pins the matching **1.20.1** Atlas **1.1.12** (`PKJi0BrP`), not the 1.12.2 file. The `-all` Hordes jar does **not** shade Atlas.
- **Game Stages** is an *optional* Hordes dep (event gating) and is **not** included. JEI is already in the pack (also optional for Hordes).
- Fetch scripts URL-decode `Atlas%20Lib-…` so the on-disk name is `Atlas Lib-1.20.1-1.1.12.jar`.

**Access:** `online-mode=false` (cracked / no Microsoft license) so anyone can connect, **max 3 players**, and a join password via Server Login (vanilla has no server password). Default password is `SERVER_PASSWORD` (`ic2play` until you change it).

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
| `EULA` | `TRUE` | Mojang EULA. Compose defaults this so Portainer Git/paste works without extra env. Override with `EULA=FALSE` if you must refuse. **Not** `ONLINE_MODE`. |
| `MEMORY` | `5G` | JVM heap; intended range **4–6G** |
| `SERVER_PORT` | `25565` | Host TCP port |
| `FORGE_VERSION` | `47.4.20` | Forge build |
| `VOLUME_PREFIX` | `mc-ic2` | Named volume prefix |
| `UID` / `GID` | `1000` | Container process owner |
| `TZ` | `UTC` | Timezone |
| `MOTD`, `DIFFICULTY`, `MODE`, `VIEW_DISTANCE`, `SIMULATION_DISTANCE`, `LEVEL` | see `.env.example` | Written to `server.properties` |
| `ONLINE_MODE` | `false` | Cracked / unlicensed clients allowed. **Not** the Mojang EULA (`EULA` must still be `TRUE`). |
| `ENFORCE_SECURE_PROFILE` | `false` | Required when offline |
| `MAX_PLAYERS` | `3` | Slot cap |
| `SERVER_PASSWORD` | `ic2play` | Shared join password friends type with `/login` (change it) |
| `MAX_TICK_TIME` | `-1` | Watchdog off (typical for modded) |
| `USE_AIKAR_FLAGS` | `true` | JVM flags |
| `ENABLE_RCON` / `RCON_PASSWORD` | `true` / `ic2rcon` | Internal stop; do not publish 25575 |
| `CF_API_KEY` / `MODRINTH_TOKEN` | unset | **Not required** for this stack |

Split heap (`INIT_MEMORY` / `MAX_MEMORY`) is documented in `.env.example` if you want 4G–6G instead of a single `MEMORY`.

## Deploy in Portainer

1. In Portainer: **Stacks → Add stack**.
2. **Git repository** (preferred): point at this repo, compose path `docker-compose.yml`, branch as deployed. **Web editor**: paste `docker-compose.yml`.
3. Under **Environment variables**, optionally paste keys from `.env.example` (`MEMORY`, `SERVER_PASSWORD`, …). **`EULA` is already `TRUE` in compose** — Portainer Git does not load `.env.example`, so you do not need to add it unless you want to override (`EULA=FALSE` refuses the Mojang EULA and the container will exit).
4. Confirm port mapping `25565:25565` (or your `SERVER_PORT`).
5. Deploy. First boot downloads Forge 47.4.20 and the pinned server jars (several minutes). Logs: container log or the `mc-ic2-logs` volume.
6. Connect with a **1.20.1 Forge** client (see below).

CLI equivalent:

```bash
cp .env.example .env
# EULA=TRUE is already in .env.example / compose
docker compose up -d
```

Give the JVM **4–6G** plus ~1.5–2G extra on the host for non-heap / OS. 5G heap is the default.

## Join password (cracked server)

Vanilla Minecraft has no server password. This stack uses **Server Login** (server-only). After connecting:

```text
/login ic2play ic2play     # first time (register)
/login ic2play             # every later join
```

Change `SERVER_PASSWORD` in Portainer / `.env` and tell your three players the new value. Do not put the password in the MOTD (the server list would show it).

## Client install (including OptiFine)

```bash
./client/fetch-mods.sh
./client/install-mods.sh
# or: ./client/install-mods.sh "/path/to/.minecraft/mods"
```

Players need **Minecraft 1.20.1 + Forge 47.4.20**, then the jars in `client/` (IC2 pack, difficulty mods + their hard deps, **OptiFine HD U I6**). OptiFine is **client-only** — never drop it in the server mods volume. Server Login is **server-only** — clients do not install it. Details: `client/README.md`.

## How to add mods

1. **Preferred:** append a jar URL to `environment.MODS` in `docker-compose.yml` (and to `mods/urls.txt` if you keep that file in sync). Redeploy the stack. itzg downloads it into `/data/mods`.
2. **Drop a jar** into the `mc-ic2-mods` volume (Portainer → Volumes, or `docker cp`). Use 1.20.1 **Forge** jars only. Restart the container.
3. Optional local verify: `./scripts/fetch-mods.sh` then copy extra jars into that folder; do not commit `.jar` files.

Remove a URL from `MODS` if you want itzg to stop managing that download. Back up the mods volume before pruning.

## Helper scripts

| Script | Purpose |
| --- | --- |
| `client/fetch-mods.sh` | Download client jars (incl. OptiFine) into `client/mods/` |
| `client/install-mods.sh` | Copy those jars into `.minecraft/mods` |
| `scripts/fetch-mods.sh` | Download **server** jars to `mods/jars/` and `sha256sum -c` |
| `scripts/validate-compose.sh` | Expand env defaults and parse/validate `docker-compose.yml` |

## License / attribution

Mod jars are third-party. IC2: Refactored and the two addons declare “All Rights Reserved” in their Gradle metadata; this stack only downloads their published GitHub release artifacts at runtime. IC2 original: <https://industrial-craft.net/>. JEI and JourneyMap are used under their Modrinth licenses.
