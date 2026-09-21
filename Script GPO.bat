@echo off
title VALIDACION GPO - CLEARPASS
color 0A

:: ============================================================
:: 4. VALIDAR POLITICAS GPO
:: ============================================================

echo ============================================================
echo        VALIDACION DE POLITICAS GPO - CLEARPASS
echo ============================================================
echo.

echo [1] Politicas aplicadas al equipo:
echo.

gpresult /r /scope computer

echo.
echo ============================================================
echo        VERIFICACION DE GPO REQUERIDAS
echo ============================================================
echo.

gpresult /r > "%TEMP%\gpo_resultado.txt"

:: ============================================================
:: GPO 1
:: ============================================================

findstr /I /C:"GPO_CP_Cert_Autoenrollment Compute" "%TEMP%\gpo_resultado.txt" >nul

if %errorlevel% EQU 0 (
    echo [OK] GPO_CP_Cert_Autoenrollment Compute
) else (
    echo [ERROR] GPO_CP_Cert_Autoenrollment Compute NO encontrada
)

:: ============================================================
:: GPO 2
:: ============================================================

findstr /I /C:"GPO_CP_Cert_Autoenrollment User" "%TEMP%\gpo_resultado.txt" >nul

if %errorlevel% EQU 0 (
    echo [OK] GPO_CP_Cert_Autoenrollment User
) else (
    echo [ERROR] GPO_CP_Cert_Autoenrollment User NO encontrada
)

:: ============================================================
:: GPO 3
:: ============================================================

findstr /I /C:"GPO_CP_802.1x_Adapter_Prueba" "%TEMP%\gpo_resultado.txt" >nul

if %errorlevel% EQU 0 (
    echo [OK] GPO_CP_802.1x_Adapter_Prueba
) else (
    echo [ERROR] GPO_CP_802.1x_Adapter_Prueba NO encontrada
)

:: ============================================================
:: 5. ACTUALIZAR POLITICAS
:: ============================================================

echo.
echo ============================================================
echo        ACTUALIZANDO POLITICAS - GPUPDATE
echo ============================================================
echo.

gpupdate /force

echo.
echo ============================================================
echo        VALIDACION DESPUES DE GPUPDATE
echo ============================================================
echo.

gpresult /r /scope computer

:: ============================================================
:: PREGUNTA 1 - LIMPIEZA
:: ============================================================

echo.
echo ============================================================
echo        OPCION 1 - LIMPIEZA DE POLITICAS LOCALES
echo ============================================================
echo.
echo Se eliminaran:
echo.
echo C:\Windows\System32\GroupPolicy
echo C:\Windows\System32\GroupPolicyUsers
echo.

choice /C SN /N /M "Desea realizar la LIMPIEZA? [S/N]: "

if errorlevel 2 goto PREGUNTA_REINICIO

echo.
echo ------------------------------------------------------------
echo LIMPIANDO POLITICAS LOCALES...
echo ------------------------------------------------------------
echo.

rd /s /q "C:\Windows\System32\GroupPolicy"
rd /s /q "C:\Windows\System32\GroupPolicyUsers"

echo.
echo [OK] Limpieza de politicas locales realizada.
echo.

:: Actualizar despues de la limpieza
echo Actualizando politicas nuevamente...
echo.

gpupdate /force

:: ============================================================
:: PREGUNTA 2 - REINICIO
:: ============================================================

:PREGUNTA_REINICIO

echo.
echo ============================================================
echo        OPCION 2 - REINICIO DEL EQUIPO
echo ============================================================
echo.

choice /C SN /N /M "Desea REINICIAR el equipo ahora? [S/N]: "

if errorlevel 2 goto FIN

echo.
echo ============================================================
echo        REINICIANDO EQUIPO
echo ============================================================
echo.
echo El equipo se reiniciara en 10 segundos...
echo.

shutdown /r /t 10

goto FIN

:: ============================================================
:: FINAL
:: ============================================================

:FIN

echo.
echo ============================================================
echo        PROCESO FINALIZADO
echo ============================================================
echo.

pause
