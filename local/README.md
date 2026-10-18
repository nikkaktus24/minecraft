# Local Forge server (no Docker)

Same **Minecraft 1.20.1 / Forge 47.4.20** pack as the Portainer stack, running on the host. Use this when Docker volume ownership is in the way. Jars are downloaded at install time — nothing is committed.

OptiFine stays **client-only** (`client/`). Server Login is **server-only** (in `mods/urls.txt`).

## Linux (first)

Need **Java 17**, `curl`, `python3`, `sha256sum` (usual on Debian/Ubuntu).

```bash
sudo apt-get install -y openjdk-17-jre-headless curl python3
# if `java -version` is not 17:
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
# or: export JAVA_BIN=/usr/lib/jvm/java-17-openjdk-amd64/bin/java

./local/install.sh
./local/start.sh
```

First install downloads the Forge installer, vanilla 1.20.1, and the pinned server mods (`scripts/fetch-mods.sh` + `mods/urls.txt`). Several minutes.

```bash
./local/stop.sh
```

Attached (foreground) start:

```bash
./local/start.sh --fg
```

Logs: `local/server/logs/console.log` (daemon) or the terminal (`--fg`). World, mods, and config live under `local/server/` (gitignored).

Join on **TCP 25565**. After spawn:

```text
/login ic2play ic2play     # first time
/login ic2play             # later
```

Password is `SERVER_PASSWORD` from `.env` (default `ic2play`), same as Docker. Server Login has no global config key — friends register with that shared value.

`eula.txt` is written `true` (Mojang EULA). `online-mode=false`, `max-players=3`. This does **not** change `docker-compose.yml`.

Optional: `cp .env.example .env` and edit `MEMORY`, `SERVER_PASSWORD`, `SERVER_PORT`. Local install always sets `eula=true` even if `.env.example` still has `EULA=FALSE` for Portainer.

## Windows

Git Bash or WSL is the supported path (same scripts):

```bat
bash local/install.sh
bash local/start.sh --fg
```

Or `local\install.bat` then `local\start.bat` (attached). `local\stop.bat` works if Git Bash is on PATH; otherwise Ctrl+C the start window.

Install **Temurin / Oracle Java 17**, not 8. Git for Windows provides `bash`, `curl`, and `sha256sum`. Python 3 must be on PATH as `python3` (or `alias python3=python` in Git Bash).

## Re-install / update mods

```bash
./local/install.sh
```

Re-runs the Forge installer if needed, re-fetches jars, and copies them into `local/server/mods/`. World data is left in place.

## Java

Minecraft 1.20.1 is a **Java 17** server. Java 21 may work; the scripts warn. Java 8/11 will fail.
