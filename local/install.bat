@echo off
setlocal
cd /d "%~dp0"
where bash >nul 2>&1
if errorlevel 1 (
  echo Install Git for Windows or WSL, then:
  echo   bash local/install.sh
  echo Need Java 17, curl, python3, and sha256sum ^(Git Bash has these^).
  exit /b 1
)
bash "%~dp0install.sh" %*
