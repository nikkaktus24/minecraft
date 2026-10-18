@echo off
setlocal
cd /d "%~dp0"
if exist "%~dp0server\run.bat" goto have_install
echo Run install first:
echo   bash local/install.sh
echo Or double-click local\install.bat ^(Git Bash / WSL^).
exit /b 1

:have_install
where bash >nul 2>&1
if not errorlevel 1 (
  bash "%~dp0start.sh" --fg %*
  exit /b %ERRORLEVEL%
)
cd /d "%~dp0server"
echo Starting attached via run.bat. Ctrl+C stops. Shared /login password is SERVER_PASSWORD ^(default ic2play^).
call run.bat nogui
