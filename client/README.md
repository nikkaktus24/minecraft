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
6. `tenshilib-1.20.1-1.7.6-forge.jar` — hard dep of Improved Mobs
7. `improvedmobs-1.20.1-1.13.7-forge.jar`
8. `coroutil-forge-1.20.1-1.3.7.jar` — hard dep of Zombie Awareness
9. `zombieawareness-1.20.1-1.13.1.jar`
10. `Corgilib-Forge-1.20.1-4.0.3.6.jar` and `Data_Anchor-forge-1.20.1-1.0.0.23.jar` — hard deps of Enhanced Celestials
11. `Enhanced-Celestials-forge-1.20.1-5.0.3.3.jar`
12. `Atlas Lib-1.20.1-1.1.12.jar` — hard dep of The Hordes (space in the filename)
13. `The-Hordes-1.20.1-1.6.3i-all.jar`
14. `OptiFine_1.20.1_HD_U_I6.jar` — **client only**, not on the server

Server Login is **server-only** and is not in this list. URLs: `client/urls.txt`. Checksums: `client/checksums.sha256`.

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
