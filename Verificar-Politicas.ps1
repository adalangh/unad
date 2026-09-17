# ============================================================
#  Verificar-Politicas.ps1
#  Verifica que ciertas GPO esten aplicadas al equipo.
#  Si no lo estan, fuerza gpupdate; si aun asi no aplican,
#  limpia la cache de Group Policy y reinicia el equipo.
# ============================================================

# --- 1. Auto-elevacion (requiere permisos de administrador) ---
$esAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $esAdmin) {
    Write-Host "Solicitando permisos de administrador..." -ForegroundColor Yellow
    $argumentos = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process -FilePath "powershell.exe" -Verb RunAs -ArgumentList $argumentos
    exit
}

# --- 2. Configuracion ---
$politicasRequeridas = @(
    "GPO_CP_Cert_Autoenrollment Compute",
    "GPO_CP_Cert_Autoenrollment User",
    "GPO_CP_802.1x_Adapter_Prueba"
)

$logPath = "$env:ProgramData\Verificar-Politicas.log"

function Escribir-Log {
    param([string]$Mensaje)
    $linea = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Mensaje
    Write-Host $Mensaje
    Add-Content -Path $logPath -Value $linea
}

function Probar-Politicas {
    # Ejecuta gpresult y valida que las politicas requeridas aparezcan en el reporte
    $reporte = gpresult /r /scope computer
    $todasAplicadas = $true

    foreach ($gpo in $politicasRequeridas) {
        if ($reporte -match [regex]::Escape($gpo)) {
            Escribir-Log "  [OK] Aplicada: $gpo"
        } else {
            Escribir-Log "  [FALTA] No aplicada: $gpo"
            $todasAplicadas = $false
        }
    }

    return $todasAplicadas
}

# --- 3. Primera verificacion ---
Escribir-Log "=== Verificacion inicial de politicas (gpresult /r /scope computer) ==="
$aplicadas = Probar-Politicas

if ($aplicadas) {
    Escribir-Log "Todas las politicas requeridas ya estan aplicadas. Finalizando."
    Start-Sleep -Seconds 3
    exit 0
}

# --- 4. No estan aplicadas -> gpupdate /force ---
Escribir-Log "=== Faltan politicas. Ejecutando gpupdate /force ==="
gpupdate /force | Out-Null

# --- 5. Segunda verificacion ---
Escribir-Log "=== Verificacion posterior a gpupdate ==="
$aplicadas2 = Probar-Politicas

if ($aplicadas2) {
    Escribir-Log "Politicas aplicadas correctamente tras gpupdate /force. Finalizando."
    Start-Sleep -Seconds 3
    exit 0
}

# --- 6. Sigue sin actualizar -> limpiar cache de GPO y reiniciar ---
Escribir-Log "=== Las politicas siguen sin aplicarse. Limpiando cache de Group Policy ==="

if (Test-Path "C:\Windows\System32\GroupPolicy") {
    Remove-Item -Path "C:\Windows\System32\GroupPolicy" -Recurse -Force -ErrorAction SilentlyContinue
    Escribir-Log "  Eliminado: C:\Windows\System32\GroupPolicy"
}

if (Test-Path "C:\Windows\System32\GroupPolicyUsers") {
    Remove-Item -Path "C:\Windows\System32\GroupPolicyUsers" -Recurse -Force -ErrorAction SilentlyContinue
    Escribir-Log "  Eliminado: C:\Windows\System32\GroupPolicyUsers"
}

Escribir-Log "=== Ejecutando gpupdate /force tras limpieza ==="
gpupdate /force | Out-Null

Escribir-Log "=== Reiniciando el equipo en 10 segundos ==="
shutdown /r /t 10

exit 0
