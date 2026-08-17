function Write-Header ($Title) {
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor White -BackgroundColor DarkCyan
    Write-Host "=========================================================" -ForegroundColor Cyan
}

function Prompt-YesNo ($Message) {
    while ($true) {
        $Response = Read-Host "[?] $Message (E/H)"
        if ($Response -match "^[EeYy]$") { return $true }
        if ($Response -match "^[HhNn]$") { return $false }
    }
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "[!] Bu betigin yonetici haklariyla calistirilmasi gerekmektedir! Yonetici olarak yeniden baslatiliyor..."
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Header "MUK ULTIMATE SISTEM VE OYUN OPTIMIZATORU V3"

Write-Header "SISTEM KORUMASI"
if (Prompt-YesNo "Islemlere baslamadan once Sistem Geri Yukleme Noktasi olusturulsun mu?") {
    Write-Host "[+] Geri Yukleme Noktasi olusturuluyor (Bu islem birkac dakika surebilir)..." -ForegroundColor Yellow
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "MUK_Optimizer_Oncesi" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    Write-Host "[V] Geri Yukleme Noktasi basariyla olusturuldu." -ForegroundColor Green
} else {
    Write-Host "[-] Geri yukleme noktasi adimi atlandi." -ForegroundColor Gray
}

Write-Header "AG VE DNS OPTIMIZASYONU"
if (Prompt-YesNo "En iyi ping degerini bulmak icin DNS Taramasi (Benchmark) yapilsin mi?") {
    Write-Host "[+] DNS Sunuculari test ediliyor. Lutfen bekleyin..." -ForegroundColor Yellow
    $DNSServers = @{
        "Cloudflare" = "1.1.1.1"
        "Google" = "8.8.8.8"
        "Quad9" = "9.9.9.9"
        "NextDNS" = "45.90.28.0"
        "AdGuard" = "94.140.14.14"
        "OpenDNS" = "208.67.222.222"
    }
    $BestDNSName = ""
    $BestDNSIP = ""
    $LowestPing = 9999
    foreach ($DNS in $DNSServers.GetEnumerator()) {
        Write-Host "    -> Test ediliyor: $($DNS.Name) ($($DNS.Value))..." -ForegroundColor DarkGray
        $PingResult = Test-Connection -ComputerName $DNS.Value -Count 3 -ErrorAction SilentlyContinue
        if ($PingResult) {
            $AvgPing = ($PingResult | Measure-Object ResponseTime -Average).Average
            $AvgPing = [math]::Round($AvgPing)
            Write-Host "       Sonuc: $AvgPing ms" -ForegroundColor Gray
            if ($AvgPing -lt $LowestPing -and $AvgPing -gt 0) {
                $LowestPing = $AvgPing
                $BestDNSName = $DNS.Name
                $BestDNSIP = $DNS.Value
            }
        } else {
            Write-Host "       Sonuc: Zaman Asimi" -ForegroundColor Red
        }
    }
    Write-Host ""
    if ($LowestPing -ne 9999) {
        Write-Host "[!] En dusuk gecikme bulundu: $BestDNSName ($BestDNSIP) - $LowestPing ms" -ForegroundColor Green
        if (Prompt-YesNo "Bu DNS sunucusu ($BestDNSName) sisteminize uygulansin mi?") {
            $NetworkInterfaces = Get-NetAdapter | Where-Object Status -eq "Up"
            foreach ($Adapter in $NetworkInterfaces) {
                Set-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex -ServerAddresses $BestDNSIP
                Write-Host "    -> $($Adapter.Name) bagdastiricisina $BestDNSIP uygulandi." -ForegroundColor Green
            }
            Clear-DnsClientCache
            Write-Host "[V] DNS Onbellegi temizlendi ve yeni DNS ayarlandi." -ForegroundColor Green
        }
    } else {
        Write-Host "[-] DNS sunucularina ulasilamadi." -ForegroundColor Red
    }
}

Write-Header "GELISMIS SISTEM, CPU VE OYUN OPTIMIZASYONLARI"
Write-Host "[+] CPU, RAM ve Gecikme ayarlari uygulaniyor..." -ForegroundColor Yellow

powercfg /h off
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
powercfg -setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 100
powercfg -setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
powercfg -setacvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a558bd4 0
powercfg -setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bea737a32d 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg -setactive SCHEME_CURRENT

$MemPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $MemPath -Name "DisablePagingExecutive" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $MemPath -Name "LargeSystemCache" -Value 0 -Type DWord -Force

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force

$DWMPrefPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe\PerfOptions"
if (-not (Test-Path $DWMPrefPath)) { New-Item -Path $DWMPrefPath -Force | Out-Null }
Set-ItemProperty -Path $DWMPrefPath -Name "CpuPriorityClass" -Value 3 -Type DWord -Force
Set-ItemProperty -Path $DWMPrefPath -Name "IoPriority" -Value 3 -Type DWord -Force

$CSRSSPrefPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions"
if (-not (Test-Path $CSRSSPrefPath)) { New-Item -Path $CSRSSPrefPath -Force | Out-Null }
Set-ItemProperty -Path $CSRSSPrefPath -Name "CpuPriorityClass" -Value 3 -Type DWord -Force

$SysProfilePath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
Set-ItemProperty -Path $SysProfilePath -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -Force
Set-ItemProperty -Path $SysProfilePath -Name "SystemResponsiveness" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "$SysProfilePath\Tasks\Games" -Name "GPU Priority" -Value 8 -Type DWord -Force
Set-ItemProperty -Path "$SysProfilePath\Tasks\Games" -Name "Priority" -Value 6 -Type DWord -Force

$DWMPath = "HKLM:\SOFTWARE\Microsoft\Windows\Dwm"
if (-not (Test-Path $DWMPath)) { New-Item -Path $DWMPath -Force | Out-Null }
Set-ItemProperty -Path $DWMPath -Name "OverlayTestMode" -Value 5 -Type DWord -Force

Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Type String -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Type String -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Type String -Force

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -ErrorAction SilentlyContinue

$Nics = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($Nic in $Nics) {
    Set-ItemProperty -Path $Nic.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $Nic.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $Nic.PSPath -Name "GlobalMaxTcpWindowSize" -Value 65535 -Type DWord -ErrorAction SilentlyContinue
}

Write-Header "ARKA PLAN SERVISLERI VE TELEMETRI KONTROLU"
Write-Host "[+] Gereksiz hizmetler devre disi birakiliyor..." -ForegroundColor Yellow

$ServicesToDisable = @(
    "DiagTrack",
    "dmwappushservice",
    "SysMain",
    "MapsBroker",
    "lfsvc",
    "WerSvc"
)

foreach ($Service in $ServicesToDisable) {
    if (Get-Service -Name $Service -ErrorAction SilentlyContinue) {
        Stop-Service -Name $Service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $Service -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "    -> $Service devre disi birakildi." -ForegroundColor Gray
    }
}

Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Value 1 -Type DWord -Force

Write-Header "SISTEM VE DISK TEMIZLIGI"
if (Prompt-YesNo "Gereksiz dosyalar, Windows Update artiklari ve Temp klasorleri temizlensin mi?") {
    Write-Host "[+] Disk temizligi baslatiliyor..." -ForegroundColor Yellow
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:WINDIR\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:WINDIR\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:WINDIR\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files" -Name "StateFlags0001" -Value 2 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup" -Name "StateFlags0001" -Value 2 -PropertyType DWord -Force | Out-Null
    
    Write-Host "    -> Sagerun komutu tetikleniyor. Arka planda temizlik devam edecek." -ForegroundColor Gray
    Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -NoNewWindow -Wait
    Write-Host "[V] Disk temizligi tamamlandi." -ForegroundColor Green
}

Write-Header "EXPLORER VE ARAYUZ YENILEME"
Write-Host "[+] Arayuz tepki hizi artiriliyor ve Explorer yeniden baslatiliyor..." -ForegroundColor Yellow

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -Type String -Force
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -ErrorAction SilentlyContinue

Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
Start-Process "explorer.exe"

Write-Header "TUM ISLEMLER BASARIYLA TAMAMLANDI!"
Write-Host "En iyi sonuclar icin sisteminizi yeniden baslatiniz." -ForegroundColor Green
Write-Host ""