# Client mods (1.20.1 Forge)

Fetch the jars this pack needs on the **player PC**, including **OptiFine** (client-only). Binaries are not committed; re-run the script whenever you want a clean set.

## One-shot

```bash
./client/fetch-mods.sh
./client/install-mods.sh
```

`install-mods.sh` copies into `~/.minecraft/mods` by default. Override:

```bash
./client/install-mods.sh "/path/to/.minecraft/mods"
# Windows (Git Bash): ./client/install-mods.sh "/c/Users/YOU/AppData/Roaming/.minecraft/mods"
# or: MINECRAFT_MODS="/path/to/mods" ./client/install-mods.sh
```

Jars are stored in `client/mods/` after fetch (gitignored).

## Install order (what the script downloads)

1. `ic2-forge-2.10.33-ex120.jar`
2. `advanced_machines-61.0.3-1.20.1.jar`
3. `advanced_solar_panels-4.3.1-1.20.1.jar`
4. `jei-1.20.1-forge-15.56.0.205.jar`
5. `journeymap-forge-1.20.1-6.0.7.jar`
6. `OptiFine_1.20.1_HD_U_I6.jar` — **client only**, not on the server

URLs: `client/urls.txt`. Checksums: `client/checksums.sha256`.

## Before first launch

1. Install **Minecraft Java 1.20.1**.
2. Install **Forge 47.4.20** (same as the server) from [Forge 1.20.1](https://files.minecraftforge.net/net/minecraftforge/forge/index_1.20.1.html). Use the installer, pick the 1.20.1 profile.
3. Fetch + install the jars as above.
4. In the launcher, select the **forge-1.20.1** profile and join the server.
5. After you spawn, register/login (server is cracked, 3 slots, shared password):

```text
/login ic2play ic2play     # first time
/login ic2play             # later
```

The live password is `SERVER_PASSWORD` in `.env` / Portainer (default `ic2play`). You do **not** install Server Login on the client.

## OptiFine notes

- Official pin: **HD U I6** for 1.20.1 ([optifine.net/downloads](https://optifine.net/downloads)).
- OptiFine’s changelog lists **Forge 47.2.18**. This pack’s server uses **47.4.20**. If the client crashes with OptiFine, drop that jar from `mods/` or try Forge 47.2.18 on the *client only*.
- Do **not** put OptiFine in the Portainer/server mods volume.

If `fetch-mods.sh` cannot parse the OptiFine ad page, download `OptiFine_1.20.1_HD_U_I6.jar` from the official site into `client/mods/` and re-run the script (checksum still runs) or copy it straight into `.minecraft/mods`.
