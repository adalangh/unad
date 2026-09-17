@echo off
REM ============================================================
REM  Verificar-Politicas.bat
REM  Lanzador: ejecuta el script Verificar-Politicas.ps1
REM  (debe estar en la MISMA carpeta que este .bat)
REM  El propio .ps1 se autoeleva a permisos de administrador.
REM ============================================================

set SCRIPT_DIR=%~dp0
set PS1_PATH=%SCRIPT_DIR%Verificar-Politicas.ps1

if not exist "%PS1_PATH%" (
    echo No se encontro Verificar-Politicas.ps1 en esta carpeta.
    echo Debe estar junto a este archivo .bat.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS1_PATH%"
