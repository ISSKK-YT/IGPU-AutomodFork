$host.ui.RawUI.WindowTitle = "AutoMod+ ULTRA AGRESSIVE (Full Optimization) - Intel iGPU"

# --- DETECCIÓN DE ARCHIVOS ---
$path_gfx = '.\Graphics\iigd_dch.inf', '.\Graphics\igdlh64.inf'
$path_cui = '.\Graphics\cui_dch.inf'

foreach ($p in $path_gfx) { if (Test-Path $p -PathType Leaf) { $inffile = $p } }
if (!$inffile) {
    $inffile = Read-Host -Prompt 'Por favor, arrastra el archivo INF de GRÁFICOS aquí'
    $inffile = $inffile.Replace('"',"")
}

# --- BACKUP ---
function Create-Backup([string]$file) {
    if (Test-Path $file) {
        $bak = "$file.backup"
        if (!(Test-Path $bak)) { Copy-Item $file $bak; Write-Host "Backup creado: $bak" -ForegroundColor Gray }
    }
}
Create-Backup $inffile
Create-Backup $path_cui

function Replace-InFile {
    param ([string]$filePath, [string]$originalText, [string]$newText)
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        if ($content -match [regex]::Escape($originalText)) {
            $content -replace [regex]::Escape($originalText), $newText | Out-File $filePath -Force
            Write-Host "Optimizado: [$originalText] en $(Split-Path $filePath -Leaf)" -ForegroundColor Green
        }
    }
}

# --- [1] OPTIMIZACIÓN DE ENERGÍA Y MEMORIA (iigd_dch.inf) ---
Write-Host "`n[1] Aplicando Energía y Memoria Ultra..." -ForegroundColor Cyan
Replace-InFile $inffile '%AC%, 1' '%AC%, 1'
Replace-InFile $inffile '%AC%, 0' '%AC%, 1'
Replace-InFile $inffile '%DC%, 1' '%DC%, 2'
Replace-InFile $inffile '%DC%, 0' '%DC%, 2'
Replace-InFile $inffile 'MaximumDeviceMemoryConfiguration = 512' 'MaximumDeviceMemoryConfiguration = 1024'

# --- [2] TWEAKS AGRESIVOS DE RENDIMIENTO (iigd_dch.inf) ---
Write-Host "[2] Aplicando Registro de Ultra Latencia..." -ForegroundColor Cyan
$ultraTweaks = "`n" + `
'HKR,, IncreaseFixedSegment,%REG_DWORD%, 1' + "`n" + `
'HKR,, Display1_PipeOptimizationEnable,%REG_DWORD%, 1' + "`n" + `
'HKR,, GpuLowPerfState_Enable,%REG_DWORD%, 0' + "`n" + `
'HKR,, Disable_FBC,%REG_DWORD%, 1' + "`n" + `
'HKR,, EnableDCC,%REG_DWORD%, 1' + "`n" + `
'HKR,, FlipQueueSize,%REG_DWORD%, 1' + "`n" + `
'HKR,, PowerSavingFeatures,%REG_DWORD%, 0' + "`n" + `
'HKR,, TelemetryEnable,%REG_DWORD%, 0'

Replace-InFile $inffile 'HKR,, IncreaseFixedSegment,%REG_DWORD%, 0' $ultraTweaks

# --- [3] SPOOFING DE IDs (UHD 605 -> UHD 630 9BC6) ---
Write-Host "[3] Suplantando IDs de Hardware..." -ForegroundColor Yellow
$devicePatterns = @(
    'iGLKGT2E18     = "Intel\(R\) UHD Graphics" "605"', 'INTEL_DEV_3184 = "Intel\(R\) UHD Graphics 605"',
    'iKBLHALOGT2    = "Intel\(R\) HD Graphics" "630"', 'iKBLULTGT2R    = "Intel\(R\) UHD Graphics" "620"',
    'iCFLDTGT2           = "Intel\(R\) UHD Graphics" "630"', 'INTEL_DEV_9BC5 = "Intel\(R\) UHD Graphics" "630"'
)
$content = Get-Content $inffile -Raw
foreach ($pattern in $devicePatterns) { $content = $content -replace $pattern, '' }

$deviceIds = @('iGLKGT2E18', 'INTEL_DEV_3184', 'iBXTGTP', 'iKBLULTGT2', 'iCFLDTGT2', 'INTEL_DEV_9BC5')
foreach ($id in $deviceIds) { $content = $content -replace $id, 'INTEL_DEV_9BC6' }
$content | Out-File $inffile -Force

# --- [4] MODIFICACIÓN AGRESIVA DE INTERFAZ (cui_dch.inf) ---
if (Test-Path $path_cui) {
    Write-Host "[4] Limpiando Interfaz CUI (Sin Iconos, Sin Hotkeys)..." -ForegroundColor Cyan
    
    # Desactivar Icono de Bandeja (ShowTrayIcon 1 -> 0)
    Replace-InFile $path_cui 'HKR,,"ShowTrayIcon",%REG_DWORD%,1' 'HKR,,"ShowTrayIcon",%REG_DWORD%,0'
    
    # Desactivar Teclas de Acceso Rápido (HotKeyState 0x1 -> 0x0)
    Replace-InFile $path_cui 'HKR,,"HotKeyState",%REG_DWORD%,0x1' 'HKR,,"HotKeyState",%REG_DWORD%,0x0'
    
    # Silenciar globos y promociones (Asegurar que estén en 0)
    Replace-InFile $path_cui 'HKR,,"ShowOptimalBalloon",%REG_DWORD%,1' 'HKR,,"ShowOptimalBalloon",%REG_DWORD%,0'
    Replace-InFile $path_cui 'HKR,,"ShowPromotions",%REG_DWORD%,1' 'HKR,,"ShowPromotions",%REG_DWORD%,0'
    
    # Forzar desactivación de teclado virtual
    Replace-InFile $path_cui 'HKR,,"ShowVirtualKeyBoard",%REG_DWORD%,1' 'HKR,,"ShowVirtualKeyBoard",%REG_DWORD%,0'
}

Write-Host "�MODIFICACI�N AGRESIVA COMPLETADA!" -ForegroundColor Green
Write-Host "Recuerda: Instala desde el Administrador de Dispositivos tras deshabilitar la firma de controladores." -ForegroundColor Red
pause