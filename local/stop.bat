@echo off
setlocal
cd /d "%~dp0"
where bash >nul 2>&1
if errorlevel 1 (
  echo Close the window that is running start.bat, or Ctrl+C that process.
  echo Git Bash / WSL: bash local/stop.sh
  exit /b 1
)
bash "%~dp0stop.sh" %*
