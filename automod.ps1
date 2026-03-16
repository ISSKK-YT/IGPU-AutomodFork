$host.ui.RawUI.WindowTitle = "AutoMod+ ULTRA AGRESSIVE (UHD 605 Incl.) - Intel iGPU 7-10th gen"

# Detección de archivo INF
if (Test-Path '.\Graphics\iigd_dch.inf' -PathType Leaf) { $inffile = '.\Graphics\iigd_dch.inf' }
if (Test-Path '.\Graphics\igdlh64.inf' -PathType Leaf) { $inffile = '.\Graphics\igdlh64.inf' }

if (!$inffile) {
    $inffile = Read-Host -Prompt 'Por favor, arrastra el archivo INF del controlador aquí y presiona Enter'
    $inffile = $inffile.Replace('"',"")
}

# Creación de Backup
$backupFile = "$inffile.backup"
if (!(Test-Path $backupFile)) {
    Copy-Item $inffile $backupFile
    Write-Host "Backup creado: $backupFile" -ForegroundColor Gray
}

function Replace-InFile {
    param ([string]$filePath, [string]$originalText, [string]$newText)
    $content = Get-Content $filePath -Raw
    if ($content -match [regex]::Escape($originalText)) {
        $content -replace [regex]::Escape($originalText), $newText | Out-File $filePath -Force
        Write-Host "Modificado: $originalText" -ForegroundColor Green
    }
}

# --- CONFIGURACIÓN DE ENERGÍA ULTRA (FORZADA) ---
Write-Host "`n[1] Forzando Plan de Energía de Máximo Rendimiento..." -ForegroundColor Cyan
Replace-InFile -filePath $inffile -originalText '%AC%, 1' -newText '%AC%, 1'
Replace-InFile -filePath $inffile -originalText '%AC%, 0' -newText '%AC%, 1'
Replace-InFile -filePath $inffile -originalText '%DC%, 1' -newText '%DC%, 2'
Replace-InFile -filePath $inffile -originalText '%DC%, 0' -newText '%DC%, 2'

# --- CONFIGURACIÓN DE MEMORIA (1GB VRAM) ---
Replace-InFile -filePath $inffile -originalText 'MaximumDeviceMemoryConfiguration = 512' -newText 'MaximumDeviceMemoryConfiguration = 1024'

# --- OPTIMIZACIONES AGRESIVAS DE REGISTRO ---
Write-Host "[2] Aplicando Tweaks de Ultra Rendimiento y Latencia..." -ForegroundColor Cyan

# Optimizaciones Base
Replace-InFile -filePath $inffile -originalText 'HKR,, IncreaseFixedSegment,%REG_DWORD%, 0' -newText ('HKR,, IncreaseFixedSegment,%REG_DWORD%, 1' + "`n" + 'HKR,, Display1_PipeOptimizationEnable,%REG_DWORD%, 1')
Replace-InFile -filePath $inffile -originalText 'HKR,, AdaptiveVsyncEnable,%REG_DWORD%, 1' -newText 'HKR,, AdaptiveVsyncEnable,%REG_DWORD%, 0'
Replace-InFile -filePath $inffile -originalText 'HKR,, Disable_OverlayDSQualityEnhancement,  %REG_DWORD%,     0' -newText 'HKR,, Disable_OverlayDSQualityEnhancement,  %REG_DWORD%, 1'

# Bloque de Tweaks Agresivos: 
# Sin ahorro de energía, compresión de color activada, latencia de cuadros mínima.
$ultraTweaks = "`n" + `
'HKR,, GpuLowPerfState_Enable,%REG_DWORD%, 0' + "`n" + `
'HKR,, Disable_FBC,%REG_DWORD%, 1' + "`n" + `
'HKR,, EnableDCC,%REG_DWORD%, 1' + "`n" + `
'HKR,, FlipQueueSize,%REG_DWORD%, 1' + "`n" + `
'HKR,, DisableFmCsEnsemble,%REG_DWORD%, 1' + "`n" + `
'HKR,, UseExternalVirtualMemory,%REG_DWORD%, 1' + "`n" + `
'HKR,, PowerSavingFeatures,%REG_DWORD%, 0' + "`n" + `
'HKR,, TelemetryEnable,%REG_DWORD%, 0'

Replace-InFile -filePath $inffile -originalText 'HKR,, IncreaseFixedSegment,%REG_DWORD%, 1' -newText ('HKR,, IncreaseFixedSegment,%REG_DWORD%, 1' + $ultraTweaks)

# --- CAMBIO DE IDs AUTOMÁTICO (INCLUYE UHD 605 DEV_3184) ---
Write-Host "[3] Suplantando IDs de Dispositivo (Objetivo: UHD 630 - 9BC6)..." -ForegroundColor Yellow

$devicePatterns = @(
    'iGLKGT2E18     = "Intel\(R\) UHD Graphics" "605"',
    'INTEL_DEV_3184 = "Intel\(R\) UHD Graphics 605"',
    'iKBLHALOGT1    = "Intel\(R\) HD Graphics" "610"', 'iKBLHALOGT2    = "Intel\(R\) HD Graphics" "630"',
    'iBXTGTP        = "Intel\(R\) HD Graphics" "505"', 'iBXTGTP12      = "Intel\(R\) HD Graphics" "500"',
    'iKBLULTGT1     = "Intel\(R\) HD Graphics" "610"', 'iKBLULTGT2     = "Intel\(R\) HD Graphics" "620"',
    'iKBLULTGT2R    = "Intel\(R\) UHD Graphics" "620"', 'iKBLULTGT2F    = "Intel\(R\) HD Graphics" "620"',
    'iKBLULTGT3E15  = "Intel\(R\) Iris\(R\) Plus Graphics" "640"', 'iKBLULTGT3E28  = "Intel\(R\) Iris\(R\) Plus Graphics" "650"',
    'iKBLULXGT2     = "Intel\(R\) HD Graphics" "615"', 'iKBLDTGT1      = "Intel\(R\) HD Graphics" "610"',
    'iKBLDTGT2      = "Intel\(R\) HD Graphics" "630"', 'iKBLWGT2       = "Intel\(R\) HD Graphics" "P630"',
    'iAMLULXGT2R    = "Intel\(R\) UHD Graphics" "615"', 'iAMLULXGT2R7W  = "Intel\(R\) UHD Graphics" "617"',
    'iAMLULXGT2Y42  = "Intel\(R\) UHD Graphics"', 'iCFLDTGT1           = "Intel\(R\) UHD Graphics" "610"',
    'iCFLDTGT2           = "Intel\(R\) UHD Graphics" "630"', 'iCFLDTWSGT2         = "Intel\(R\) UHD Graphics" "P630"',
    'iCFLHALOGT2         = "Intel\(R\) UHD Graphics" "630"', 'iCFLHALOWSGT2       = "Intel\(R\) UHD Graphics" "P630"',
    'iCFLULTGT3W15       = "Intel\(R\) Iris\(R\) Plus Graphics" "645"', 'iCFLULTGT3W28       = "Intel\(R\) Iris\(R\) Plus Graphics" "655"',
    'iCFLULTGT2D0        = "Intel\(R\) UHD Graphics" "620"', 'INTEL_DEV_9BC5 = "Intel\(R\) UHD Graphics" "630"',
    'INTEL_DEV_9BC8 = "Intel\(R\) UHD Graphics" "630"', 'INTEL_DEV_9BA8 = "Intel\(R\) UHD Graphics" "610"',
    'INTEL_DEV_8A51 = "Intel\(R\) Iris\(R\) Plus Graphics"', 'INTEL_DEV_8A52 = "Intel\(R\) Iris\(R\) Plus Graphics"',
    'INTEL_DEV_4E61 = "Intel\(R\) UHD Graphics"', 'INTEL_DEV_4E71 = "Intel\(R\) UHD Graphics"'
)

$content = Get-Content $inffile -Raw
foreach ($pattern in $devicePatterns) { $content = $content -replace $pattern, '' }

# Lista de IDs de hardware para redirigir a 9BC6
$deviceIds = @(
    'iGLKGT2E18', 'INTEL_DEV_3184', 'iBXTGTP', 'iBXTGTP12', 'iKBLULTGT1', 'iKBLULTGT2', 
    'iKBLULTGT2R', 'iKBLULTGT2F', 'iKBLULTGT3E15', 'iKBLULTGT3E28', 'iKBLULXGT2', 
    'iKBLDTGT1', 'iKBLDTGT2', 'iKBLHALOGT1', 'iKBLHALOGT2', 'iKBLWGT2', 'iAMLULXGT2R', 
    'iAMLULXGT2R7W', 'iAMLULXGT2Y42', 'iCFLDTGT1', 'iCFLDTGT2', 'iCFLDTWSGT2', 
    'iCFLHALOGT2', 'iCFLHALOWSGT2', 'iCFLULTGT3W15', 'iCFLULTGT3W28', 'iCFLULTGT2D0', 
    'INTEL_DEV_9BC5', 'INTEL_DEV_9BC8', 'INTEL_DEV_9BA8', 'INTEL_DEV_8A51', 
    'INTEL_DEV_8A52', 'INTEL_DEV_4E61', 'INTEL_DEV_4E71'
)

foreach ($id in $deviceIds) { $content = $content -replace $id, 'INTEL_DEV_9BC6' }
$content | Out-File $inffile -Force

# --- CUI MODS (Automático) ---
if (Test-Path '.\Graphics\cui_dch.inf' -PathType Leaf) {
    $cuiFile = '.\Graphics\cui_dch.inf'
    $newCuiContent = 'HKR,,"ShowOptimalBalloon",%REG_DWORD%,0' + "`n" + 'HKR,,"ShowPromotions",%REG_DWORD%,0'
    $c = Get-Content $cuiFile -Raw
    $c -replace 'HKR,,"ShowOptimalBalloon",%REG_DWORD%,1', $newCuiContent | Out-File $cuiFile -Force
    Write-Host "[4] Interfaz CUI optimizada." -ForegroundColor Cyan
}

Write-Host "`nModificaciones AGRESIVAS completadas con éxito!" -ForegroundColor Green
Write-Host "AVISO: Debes instalar esto con el 'Uso obligatorio de controladores firmados' DESACTIVADO." -ForegroundColor Red
pause
