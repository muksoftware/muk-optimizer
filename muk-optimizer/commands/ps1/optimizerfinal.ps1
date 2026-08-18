# =============================================================================
#  WINDOWS TELEMETRI, OPTIMIZASYON & GUVENLIK TEMIZLEYICI - TAM SURUM
#  Yapimci  : @muksoftware
#  Dil      : PowerShell 5.1+ (Windows'a gomulu) / Multi-Language (Coklu Dil)
#  Gerekli  : Yonetici (Administrator) yetkisi
#  Test     : Windows 10 21H2+ / Windows 11
# =============================================================================

# --- SİSTEM DİLİ ALGILAMA VE ÇOKLU DİL SÖZLÜĞÜ (I18N) ---
$SysCulture = (Get-Culture).TwoLetterISOLanguageName.ToLower()

$i18n = @{
    "tr" = @{
        Title           = "WINDOWS TELEMETRI & OPTIMIZASYON TEMIZLEYICI"
        Author          = "Yapimci"
        AdminWarn       = "[!] Yonetici izni gerekiyor! Otomatik olarak yetki isteniyor..."
        PressEnter      = "Devam etmek icin ENTER'a basin (Cikmak icin CTRL+C)..."
        PromptYesNo     = "[?] {0} (E/H)"
        YesMatch        = "^[EeYy]$"
        NoMatch         = "^[HhNn]$"
        
        DnsTitle        = "DNS BENCHMARK VE AG OPTIMIZASYONU"
        DnsPrompt       = "En dusuk gecikmeyi (ping) bulmak icin DNS testi yapilsin mi?"
        DnsTesting      = "[+] DNS Sunuculari test ediliyor. Lutfen bekleyin..."
        DnsTestServer   = "    -> Test ediliyor: {0} ({1})..."
        DnsResult       = "       Sonuc: {0} ms"
        DnsTimeout      = "       Sonuc: Zaman Asimi"
        DnsBestFound    = "[!] En dusuk gecikme bulundu: {0} ({1}) - {2} ms"
        DnsApplyPrompt  = "Bu DNS sunucusu ({0}) sisteminize uygulansin mi?"
        DnsAdapterSet   = "    -> {0} bagdastiricisina {1} uygulandi."
        DnsFlushed      = "[V] DNS Onbellegi temizlendi (ipconfig /flushdns) ve yeni DNS ayarlandi."
        DnsNotFound     = "[-] DNS sunucularina ulasilamadi."

        RestartPrompt   = "Sistemi simdi yeniden baslatmak ister misiniz?"
        Restarting      = "Sistem 10 saniye icinde yeniden baslatiliyor..."
    }
    "en" = @{
        Title           = "WINDOWS TELEMETRY & OPTIMIZATION CLEANER"
        Author          = "Author"
        AdminWarn       = "[!] Administrator privilege required! Requesting elevation..."
        PressEnter      = "Press ENTER to continue (CTRL+C to exit)..."
        PromptYesNo     = "[?] {0} (Y/N)"
        YesMatch        = "^[Yy]$"
        NoMatch         = "^[Nn]$"
        
        DnsTitle        = "DNS BENCHMARK & NETWORK OPTIMIZATION"
        DnsPrompt       = "Do you want to run DNS Benchmark to find the lowest latency?"
        DnsTesting      = "[+] Testing DNS Servers. Please wait..."
        DnsTestServer   = "    -> Testing: {0} ({1})..."
        DnsResult       = "       Result: {0} ms"
        DnsTimeout      = "       Result: Timeout"
        DnsBestFound    = "[!] Lowest latency found: {0} ({1}) - {2} ms"
        DnsApplyPrompt  = "Do you want to apply this DNS ({0}) to your system?"
        DnsAdapterSet   = "    -> Applied {1} to adapter {0}."
        DnsFlushed      = "[V] DNS Cache flushed (ipconfig /flushdns) and new DNS configured."
        DnsNotFound     = "[-] DNS servers could not be reached."

        RestartPrompt   = "Would you like to restart your computer now?"
        Restarting      = "System is restarting in 10 seconds..."
    }
}

if (-not $i18n.ContainsKey($SysCulture)) { $SysCulture = "en" }
$L = $i18n[$SysCulture]

# --- YÖNETİCİ YETKİSİ KONTROLÜ VE OTOMATIK UAC ÇAĞRISI ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n$($L.AdminWarn)" -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# --- RENKLI CIKTI FONKSIYONLARI ---
function Baslik  { param($m) Write-Host "`n===========================================" -ForegroundColor Cyan
                              Write-Host "  $m" -ForegroundColor White
                              Write-Host "===========================================" -ForegroundColor Cyan }
function Tamam   { param($m) Write-Host "  [OK] $m" -ForegroundColor Green }
function Bilgi   { param($m) Write-Host "  [i] $m" -ForegroundColor Yellow }
function Hata    { param($m) Write-Host "  [X] $m" -ForegroundColor Red }
function Log     { param($m,$renk="Gray") Write-Host "      $m" -ForegroundColor $renk }

function Prompt-YesNo ($Message) {
    while ($true) {
        $FormattedMsg = $L.PromptYesNo -f $Message
        $Response = Read-Host $FormattedMsg
        if ($Response -match $L.YesMatch) { return $true }
        if ($Response -match $L.NoMatch) { return $false }
    }
}

# --- BASLANGIC EKRANI ---
Clear-Host
Write-Host @"
==============================================================
   $($L.Title)
                         $($L.Author): @muksoftware
==============================================================
"@ -ForegroundColor Cyan

Write-Host "`n  $($L.PressEnter)" -ForegroundColor Yellow
Read-Host

# --- YARDIMCI FONKSIYONLAR ---
function Set-Reg {
    param($Yol, $Ad, $Deger, $Tur = "DWord")
    try {
        If (!(Test-Path $Yol)) { New-Item -Path $Yol -Force -ErrorAction SilentlyContinue | Out-Null }
        Set-ItemProperty -Path $Yol -Name $Ad -Value $Deger -Type $Tur -Force -ErrorAction Stop
        Tamam "$Ad = $Deger [$Yol]"
    } catch { Hata "Hata: $Ad -> $_" }
}

function Disable-CustomService {
    param($Ad)
    try {
        $s = Get-Service -Name $Ad -ErrorAction Stop
        If ($s.Status -ne "Stopped") { Stop-Service -Name $Ad -Force -ErrorAction SilentlyContinue }
        Set-Service -Name $Ad -StartupType Disabled -ErrorAction SilentlyContinue
        Tamam "Servis devre disi: $Ad"
    } catch { Bilgi "Servis bulunamadi (zaten yok): $Ad" }
}

Set-Alias -Name Servis-Durdur -Value Disable-CustomService

function Remove-CustomScheduledTask {
    param($Yol, $Ad)
    try {
        Unregister-ScheduledTask -TaskPath $Yol -TaskName $Ad -Confirm:$false -ErrorAction Stop
        Tamam "Gorev silindi: $Yol$Ad"
    } catch { Bilgi "Gorev zaten yok: $Yol$Ad" }
}

Set-Alias -Name Gorev-Sil -Value Remove-CustomScheduledTask

function New-CustomFirewallRule {
    param($Ad, $Hedef)
    try {
        Remove-NetFirewallRule -DisplayName $Ad -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName $Ad `
            -Direction Outbound -Action Block `
            -RemoteAddress $Hedef -Protocol Any `
            -Profile Any -ErrorAction Stop | Out-Null
        Tamam "Guvenlik duvari kurali eklendi: $Ad"
    } catch { Hata "Kural eklenemedi: $Ad -> $_" }
}

Set-Alias -Name FW-Engelle -Value New-CustomFirewallRule

# ================================================================
# EKLENEN BÖLÜM: DNS TESTİ & BENCHMARK
# ================================================================
Baslik $L.DnsTitle
if (Prompt-YesNo $L.DnsPrompt) {
    Write-Host $L.DnsTesting -ForegroundColor Yellow
    $DNSServers = @{
        "Cloudflare" = "1.1.1.1"
        "Google"     = "8.8.8.8"
        "Quad9"      = "9.9.9.9"
        "NextDNS"    = "45.90.28.0"
        "AdGuard"    = "94.140.14.14"
        "OpenDNS"    = "208.67.222.222"
    }
    $BestDNSName = ""
    $BestDNSIP = ""
    $LowestPing = 9999

    foreach ($DNS in $DNSServers.GetEnumerator()) {
        $msgServer = $L.DnsTestServer -f $DNS.Name, $DNS.Value
        Write-Host $msgServer -ForegroundColor DarkGray
        
        $PingResult = Test-Connection -ComputerName $DNS.Value -Count 3 -ErrorAction SilentlyContinue
        if ($PingResult) {
            $AvgPing = ($PingResult | Measure-Object ResponseTime -Average).Average
            $AvgPing = [math]::Round($AvgPing)
            
            $msgRes = $L.DnsResult -f $AvgPing
            Write-Host $msgRes -ForegroundColor Gray
            
            if ($AvgPing -lt $LowestPing -and $AvgPing -gt 0) {
                $LowestPing = $AvgPing
                $BestDNSName = $DNS.Name
                $BestDNSIP = $DNS.Value
            }
        } else {
            Write-Host $L.DnsTimeout -ForegroundColor Red
        }
    }
    Write-Host ""
    if ($LowestPing -ne 9999) {
        $msgBest = $L.DnsBestFound -f $BestDNSName, $BestDNSIP, $LowestPing
        Write-Host $msgBest -ForegroundColor Green
        
        $msgApplyPrompt = $L.DnsApplyPrompt -f $BestDNSName
        if (Prompt-YesNo $msgApplyPrompt) {
            $NetworkInterfaces = Get-NetAdapter | Where-Object Status -eq "Up"
            foreach ($Adapter in $NetworkInterfaces) {
                Set-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex -ServerAddresses $BestDNSIP
                $msgSet = $L.DnsAdapterSet -f $Adapter.Name, $BestDNSIP
                Write-Host $msgSet -ForegroundColor Green
            }
            Clear-DnsClientCache
            ipconfig /flushdns | Out-Null
            Write-Host $L.DnsFlushed -ForegroundColor Green
        }
    } else {
        Write-Host $L.DnsNotFound -ForegroundColor Red
    }
}

# ================================================================
# BOLUM 1: TELEMETRI SERVISLERI
# ================================================================
Baslik "BOLUM 1: TELEMETRI SERVISLERI DEVRE DISI"

$telemetriServisleri = @(
    "DiagTrack", "dmwappushservice", "diagnosticshub.standardcollector.service",
    "WerSvc", "wercplsupport", "PcaSvc", "MapsBroker", "lfsvc", "SharedAccess",
    "TrkWks", "WMPNetworkSvc", "WSearch", "XblAuthManager", "XblGameSave",
    "XboxNetApiSvc", "XboxGipSvc", "RetailDemo", "RemoteRegistry", "Fax",
    "TabletInputService", "WbioSrvc", "wisvc", "Wecsvc"
)

foreach ($servis in $telemetriServisleri) {
    Servis-Durdur $servis
}

# ================================================================
# BOLUM 2: KAYIT DEFTERI - TELEMETRI GIZLILIK AYARLARI
# ================================================================
Baslik "BOLUM 2: KAYIT DEFTERI GIZLILIK AYARLARI"

Log "Telemetri seviyesi sifira indiriliyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" 0
Set-Reg "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" 0

Log "Windows Hata Raporlama devre disi..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" "Disabled" 1
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" "Disabled" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\PCHealth\ErrorReporting" "DoReport" 0

Log "CEIP kapatiliyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" "CEIPEnable" 0
Set-Reg "HKLM:\SOFTWARE\Microsoft\SQMClient\Windows" "CEIPEnable" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\SQMClient\Windows" "CEIPEnable" 0

Log "Tanilama ve geri bildirim kapatiliyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DoNotShowFeedbackNotifications" 1
Set-Reg "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" "PeriodInNanoSeconds" 0

Log "Reklam ID devre disi birakiliyor..." Yellow
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" "DisabledByGroupPolicy" 1

Log "Cortana ve Bing arama kapatiliyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowSearchToUseLocation" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "ConnectedSearchUseWeb" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "CortanaConsent" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "DeviceHistoryEnabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "HistoryViewEnabled" 0

Log "Konum takibi kapatiliyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" "DisableLocation" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" "DisableLocationScripting" 1
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "Deny" "String"
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" "Value" "Deny" "String"

Log "Uygulama kamera/mikrofon erisimi kisitlaniyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessCamera" 2
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessMicrophone" 2
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessLocation" 2
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessContacts" 2
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessCalendar" 2
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessCallHistory" 2
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessEmail" 2
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessMessaging" 2
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessPhone" 2
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessAccountInfo" 2
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsSyncWithDevices" 2
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessTasks" 2
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsAccessNotifications" 2
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsRunInBackground" 2

Log "Timeline ve aktivite gecmisi kapatiliyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities" 0

Log "Windows Update telemetrisi azaltiliyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" "DisableOSUpgrade" 1

Log "Connected User Experience kapatiliyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DisableOneSettingsDownloads" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "LimitDiagnosticLogCollection" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "LimitDumpCollection" 1

Set-Reg "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" 0

Log "WiFi Sense ve ag paylasimi kapatiliyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" "AutoConnectAllowedOEM" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" "fMinimizeConnections" 1

Log "OneDrive telemetri kapatiliyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1

Log "Pano senkronizasyonu kapatiliyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowClipboardHistory" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCrossDeviceClipboard" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Clipboard" "EnableClipboardHistory" 0

Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey" "EnableEventTranscript" 0

Log "Start Menu takibi kapatiliyor..." Yellow
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackProgs" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSyncProviderNotifications" 0

Log "Windows Ink Workspace telemetrisi kapatiliyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" "AllowWindowsInkWorkspace" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" "AllowSuggestedAppsInWindowsInkWorkspace" 0

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps" "AutoDownloadAndUpdateMapData" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Maps" "AllowUntriggeredNetworkTrafficOnSettingsPage" 0

Log "Uzak Yardim kapatiliyor..." Yellow
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" "fAllowToGetHelp" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowUnsolicited" 0

Log "Edge telemetrisi kapatiliyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "MetricsReportingEnabled" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "SendSiteInfoToImproveServices" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "DiagnosticData" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "PersonalizationReportingEnabled" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "SearchSuggestEnabled" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "SpotlightExperiencesAndRecommendationsEnabled" 0

Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SoftLandingEnabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "RotatingLockScreenEnabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-310093Enabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338388Enabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338389Enabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338393Enabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-353694Enabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-353696Enabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SystemPaneSuggestionsEnabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "PreInstalledAppsEnabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "OemPreInstalledAppsEnabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SilentInstalledAppsEnabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "ContentDeliveryAllowed" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "FeatureManagementEnabled" 0

Log "Windows Hello biyometrik veri paylasimi kapatiliyor..." Yellow
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics" "Enabled" 0

# ================================================================
# BOLUM 3: ZAMANLANMIS GOREVLER (Scheduled Tasks)
# ================================================================
Baslik "BOLUM 3: TELEMETRI ZAMANLANMIS GOREVLERI SILINIYOR"

$telemetriGorevler = @(
    @{ Yol="\Microsoft\Windows\Application Experience\"; Ad="Microsoft Compatibility Appraiser" },
    @{ Yol="\Microsoft\Windows\Application Experience\"; Ad="ProgramDataUpdater" },
    @{ Yol="\Microsoft\Windows\Application Experience\"; Ad="StartupAppTask" },
    @{ Yol="\Microsoft\Windows\Autochk\"; Ad="Proxy" },
    @{ Yol="\Microsoft\Windows\Customer Experience Improvement Program\"; Ad="Consolidator" },
    @{ Yol="\Microsoft\Windows\Customer Experience Improvement Program\"; Ad="KernelCeipTask" },
    @{ Yol="\Microsoft\Windows\Customer Experience Improvement Program\"; Ad="UsbCeip" },
    @{ Yol="\Microsoft\Windows\Customer Experience Improvement Program\"; Ad="Uploader" },
    @{ Yol="\Microsoft\Windows\Customer Experience Improvement Program\"; Ad="BthSQM" },
    @{ Yol="\Microsoft\Windows\DiskDiagnostic\"; Ad="Microsoft-Windows-DiskDiagnosticDataCollector" },
    @{ Yol="\Microsoft\Windows\DiskDiagnostic\"; Ad="Microsoft-Windows-DiskDiagnosticResolver" },
    @{ Yol="\Microsoft\Windows\Feedback\Siuf\"; Ad="DmClient" },
    @{ Yol="\Microsoft\Windows\Feedback\Siuf\"; Ad="DmClientOnScenarioDownload" },
    @{ Yol="\Microsoft\Windows\Maps\"; Ad="MapsToastTask" },
    @{ Yol="\Microsoft\Windows\Maps\"; Ad="MapsUpdateTask" },
    @{ Yol="\Microsoft\Windows\NetTrace\"; Ad="GatherNetworkInfo" },
    @{ Yol="\Microsoft\Windows\PI\"; Ad="Sqm-Tasks" },
    @{ Yol="\Microsoft\Windows\Power Efficiency Diagnostics\"; Ad="AnalyzeSystem" },
    @{ Yol="\Microsoft\Windows\Shell\"; Ad="FamilySafetyMonitor" },
    @{ Yol="\Microsoft\Windows\Shell\"; Ad="FamilySafetyRefreshTask" },
    @{ Yol="\Microsoft\Windows\Shell\"; Ad="FamilySafetyUpload" },
    @{ Yol="\Microsoft\Windows\Windows Error Reporting\"; Ad="QueueReporting" },
    @{ Yol="\Microsoft\Windows\WaaSMedic\"; Ad="PerformRemediation" },
    @{ Yol="\Microsoft\Windows\WindowsUpdate\"; Ad="Scheduled Start" },
    @{ Yol="\Microsoft\Windows\License Manager\"; Ad="TempSignedLicenseExchange" },
    @{ Yol="\Microsoft\Windows\Clip\"; Ad="License Validation" },
    @{ Yol="\Microsoft\Windows\CloudExperienceHost\"; Ad="CreateObjectTask" },
    @{ Yol="\Microsoft\Windows\Setup\"; Ad="SetupCleanupTask" },
    @{ Yol="\Microsoft\XblGameSave\"; Ad="XblGameSaveTask" },
    @{ Yol="\Microsoft\XblGameSave\"; Ad="XblGameSaveTaskLogon" },
    @{ Yol="\Microsoft\Windows\Device Information\"; Ad="Device" },
    @{ Yol="\Microsoft\Windows\Device Information\"; Ad="Device User" }
)

foreach ($gorev in $telemetriGorevler) {
    Gorev-Sil $gorev.Yol $gorev.Ad
}

$devreDisiGorevler = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
)
foreach ($gPath in $devreDisiGorevler) {
    try {
        Disable-ScheduledTask -TaskPath (Split-Path $gPath -Parent) -TaskName (Split-Path $gPath -Leaf) -ErrorAction SilentlyContinue | Out-Null
    } catch {}
}

# ================================================================
# BOLUM 4: HOSTS DOSYASI - TELEMETRI SUNUCULARINI ENGELLE
# ================================================================
Baslik "BOLUM 4: HOSTS DOSYASI ILE TELEMETRI SUNUCULARI ENGELLENIYOR"

$hostsYolu = "$env:windir\System32\drivers\etc\hosts"
$engellenenSunucular = @"

# ======================================================
# MICROSOFT TELEMETRI SUNUCULARI - ENGELLENDI
# ======================================================
0.0.0.0 vortex.data.microsoft.com
0.0.0.0 vortex-win.data.microsoft.com
0.0.0.0 telecommand.telemetry.microsoft.com
0.0.0.0 telecommand.telemetry.microsoft.com.nsatc.net
0.0.0.0 oca.telemetry.microsoft.com
0.0.0.0 oca.telemetry.microsoft.com.nsatc.net
0.0.0.0 sqm.telemetry.microsoft.com
0.0.0.0 sqm.telemetry.microsoft.com.nsatc.net
0.0.0.0 watson.telemetry.microsoft.com
0.0.0.0 watson.telemetry.microsoft.com.nsatc.net
0.0.0.0 redir.metaservices.microsoft.com
0.0.0.0 choice.microsoft.com
0.0.0.0 choice.microsoft.com.nsatc.net
0.0.0.0 df.telemetry.microsoft.com
0.0.0.0 reports.wes.df.telemetry.microsoft.com
0.0.0.0 wes.df.telemetry.microsoft.com
0.0.0.0 services.wes.df.telemetry.microsoft.com
0.0.0.0 sqm.df.telemetry.microsoft.com
0.0.0.0 telemetry.microsoft.com
0.0.0.0 watson.ppe.telemetry.microsoft.com
0.0.0.0 telemetry.appex.bing.net
0.0.0.0 telemetry.urs.microsoft.com
0.0.0.0 telemetry.appex.bing.net:443
0.0.0.0 settings-sandbox.data.microsoft.com
0.0.0.0 vortex-sandbox.data.microsoft.com
0.0.0.0 survey.watson.microsoft.com
0.0.0.0 watson.live.com
0.0.0.0 watson.microsoft.com
0.0.0.0 statsfe2.ws.microsoft.com
0.0.0.0 corpext.msitadfs.glbdns2.microsoft.com
0.0.0.0 compatexchange.cloudapp.net
0.0.0.0 cs1.wpc.v0cdn.net
0.0.0.0 a-0001.a-msedge.net
0.0.0.0 statsfe2.update.microsoft.com.akadns.net
0.0.0.0 sls.update.microsoft.com.akadns.net
0.0.0.0 fe2.update.microsoft.com.akadns.net
0.0.0.0 65.52.108.33
0.0.0.0 65.39.117.230
0.0.0.0 23.218.212.69
0.0.0.0 134.170.30.202
0.0.0.0 137.116.81.24
0.0.0.0 diagnostics.support.microsoft.com
0.0.0.0 corp.sts.microsoft.com
0.0.0.0 statsfe1.ws.microsoft.com
0.0.0.0 pre.footprintpredict.com
0.0.0.0 i1.services.social.microsoft.com
0.0.0.0 i1.services.social.microsoft.com.nsatc.net
0.0.0.0 feedback.windows.com
0.0.0.0 feedback.microsoft-hohm.com
0.0.0.0 feedback.search.microsoft.com
# ======================================================
"@

$mevcutIcerik = Get-Content $hostsYolu -Raw -ErrorAction SilentlyContinue
If ($mevcutIcerik -notlike "*MICROSOFT TELEMETRI SUNUCULARI*") {
    try {
        Add-Content -Path $hostsYolu -Value $engellenenSunucular -Encoding UTF8 -ErrorAction Stop
        Tamam "Hosts dosyasina telemetri sunuculari eklendi."
    } catch { Hata "Hosts dosyasi guncellenemedi: $_" }
} else {
    Bilgi "Telemetri sunuculari hosts dosyasinda zaten mevcut."
}

ipconfig /flushdns | Out-Null
Tamam "DNS onbellegi temizlendi."

# ================================================================
# BOLUM 5: GUVENLIK DUVARI KURALLARI
# ================================================================
Baslik "BOLUM 5: GUVENLIK DUVARI ILE TELEMETRI ENGELLENIYOR"

$fwKurallari = @(
    @{ Ad="Block Telemetry vortex.data.microsoft.com";       IP="65.52.100.7,13.69.239.84"   },
    @{ Ad="Block Telemetry telecommand.telemetry.ms";        IP="65.55.29.238,65.52.108.33"  },
    @{ Ad="Block Telemetry sqm.telemetry.microsoft.com";     IP="65.52.100.91,65.52.100.93"  },
    @{ Ad="Block Telemetry watson.telemetry.microsoft.com";  IP="65.52.108.29"               },
    @{ Ad="Block DiagTrack oca.telemetry.microsoft.com";     IP="65.55.201.114"              },
    @{ Ad="Block Telemetry statsfe1";                        IP="65.52.100.7"                },
    @{ Ad="Block Telemetry statsfe2";                        IP="65.52.100.11"               }
)

foreach ($kural in $fwKurallari) {
    FW-Engelle $kural.Ad $kural.IP
}

try {
    Remove-NetFirewallRule -DisplayName "Block DiagTrack Process" -ErrorAction SilentlyContinue
    New-NetFirewallRule -DisplayName "Block DiagTrack Process" `
        -Direction Outbound -Action Block `
        -Program "$env:SystemRoot\System32\CompatTelRunner.exe" `
        -Profile Any -ErrorAction Stop | Out-Null
    Tamam "CompatTelRunner.exe guvenlik duvarinda engellendi."
} catch { Bilgi "CompatTelRunner.exe guvenlik duvari kurali: $_" }

# ================================================================
# BOLUM 6: BLOATWARE UYGULAMALARI KALDIRMA
# ================================================================
Baslik "BOLUM 6: BLOATWARE UYGULAMALARI KALDIRILIYOR"

$kaldirilacakApps = @(
    "Microsoft.3DBuilder", "Microsoft.BingFinance", "Microsoft.BingFoodAndDrink",
    "Microsoft.BingHealthAndFitness", "Microsoft.BingMaps", "Microsoft.BingNews",
    "Microsoft.BingSearch", "Microsoft.BingSports", "Microsoft.BingTranslator",
    "Microsoft.BingTravel", "Microsoft.BingWeather", "Microsoft.Copilot",
    "Microsoft.GamingApp", "Microsoft.GetHelp", "Microsoft.Getstarted",
    "Microsoft.Messaging", "Microsoft.Microsoft3DViewer", "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection", "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MixedReality.Portal", "Microsoft.NetworkSpeedTest", "Microsoft.News",
    "Microsoft.Office.OneNote", "Microsoft.OneConnect", "Microsoft.OutlookForWindows",
    "Microsoft.Paint3D", "Microsoft.People", "Microsoft.PowerAutomateDesktop",
    "Microsoft.SkypeApp", "Microsoft.Teams", "Microsoft.Todos", "Microsoft.Wallet",
    "Microsoft.Whiteboard", "Microsoft.WindowsAlarms", "Microsoft.WindowsFeedback",
    "Microsoft.WindowsFeedbackHub", "Microsoft.WindowsMaps", "Microsoft.WindowsSoundRecorder",
    "Microsoft.Xbox.TCUI", "Microsoft.XboxApp", "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay", "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay", "Microsoft.YourPhone", "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo", "MicrosoftTeams", "Microsoft.549981C3F5F10",
    "Microsoft.WindowsCommunicationsApps", "Microsoft.windowsphone"
)

foreach ($app in $kaldirilacakApps) {
    try {
        $paket = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
        if ($paket) {
            Remove-AppxPackage -Package $paket.PackageFullName -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
                Where-Object { $_.PackageName -like "*$app*" } |
                ForEach-Object { Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null }
            Tamam "Kaldirildi: $app"
        } else {
            Bilgi "Zaten yok: $app"
        }
    } catch { Hata "Kaldirilamadi: $app -> $_" }
}

# ================================================================
# BOLUM 7: WINDOWS SEARCH BING ENTEGRASYONU
# ================================================================
Baslik "BOLUM 7: WINDOWS ARAMA BING ENTEGRASYONU KAPATILIYOR"

Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "AllowSearchToUseLocation" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "CortanaConsent" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "DeviceHistoryEnabled" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowSearchToUseLocation" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "ConnectedSearchUseWeb" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "ConnectedSearchPrivacy" 3

# ================================================================
# BOLUM 8: WINDOWS UPDATE GIZLILIK AYARLARI
# ================================================================
Baslik "BOLUM 8: WINDOWS UPDATE TELEMETRISI"

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 0
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" "DownloadMode" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" 0

# ================================================================
# BOLUM 9: MICROSOFT OFFICE TELEMETRISI
# ================================================================
Baslik "BOLUM 9: OFFICE TELEMETRI KAPATILIYOR"

$officeYol = "HKCU:\SOFTWARE\Microsoft\Office\Common\ClientTelemetry"
Set-Reg $officeYol "DisableTelemetry" 1
Set-Reg $officeYol "VerboseLogging" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\ClientTelemetry" "DisableTelemetry" 1
Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Office\16.0\osm" "Enablelogging" 0
Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Office\16.0\osm" "EnableUpload" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\osm" "EnableLogging" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\osm" "EnableUpload" 0

# ================================================================
# BOLUM 10: SVC HOST VE DIGER TELEMETRI ARACLARI
# ================================================================
Baslik "BOLUM 10: EK TELEMETRI ARACLARI DEVRE DISI"

$compatTelRunner = "$env:SystemRoot\System32\CompatTelRunner.exe"
If (Test-Path $compatTelRunner) {
    try {
        $acl = Get-Acl $compatTelRunner
        $adminSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($adminSid, "FullControl", "Allow")
        $acl.SetAccessRule($rule)
        Set-Acl -Path $compatTelRunner -AclObject $acl -ErrorAction SilentlyContinue
        Rename-Item $compatTelRunner "$compatTelRunner.disabled" -Force -ErrorAction SilentlyContinue
        Tamam "CompatTelRunner.exe devre disi birakildi."
    } catch { Bilgi "CompatTelRunner.exe: Yonetici yetkisi yetersiz (normal)" }
}

$diagTrackLog = "$env:ProgramData\Microsoft\Diagnosis\ETLLogs"
If (Test-Path $diagTrackLog) {
    try {
        Get-ChildItem -Path $diagTrackLog -Recurse -Force -ErrorAction SilentlyContinue |
            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Tamam "DiagTrack log dosyalari temizlendi."
    } catch { Bilgi "DiagTrack loglari temizlenirken hata: $_" }
}

$werDizinler = @(
    "$env:LOCALAPPDATA\CrashDumps",
    "$env:ProgramData\Microsoft\Windows\WER\ReportQueue",
    "$env:ProgramData\Microsoft\Windows\WER\ReportArchive",
    "$env:TEMP\WER"
)
foreach ($dizin in $werDizinler) {
    If (Test-Path $dizin) {
        try {
            Remove-Item -Path "$dizin\*" -Force -Recurse -ErrorAction SilentlyContinue
            Tamam "Temizlendi: $dizin"
        } catch { Bilgi "Temizlenemedi: $dizin" }
    }
}

# ================================================================
# BOLUM 11: GECICI VE ONBELLEK TEMIZLIGI
# ================================================================
Baslik "BOLUM 11: GECICI DOSYALAR TEMIZLENIYOR"

$temizlenecekler = @(
    "$env:TEMP",
    "$env:SystemRoot\Temp",
    "$env:LOCALAPPDATA\Temp",
    "$env:SystemRoot\Prefetch"
)

foreach ($yer in $temizlenecekler) {
    try {
        Get-ChildItem -Path $yer -Force -ErrorAction SilentlyContinue |
            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Tamam "Temizlendi: $yer"
    } catch { Bilgi "Kismen temizlendi: $yer" }
}

# ================================================================
# BOLUM 12: WINDOWS 11 OZEL AYARLARI
# ================================================================
Baslik "BOLUM 12: WINDOWS 11 GIZLILIK AYARLARI"

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests" 0
Set-Reg "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" "value" 0

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableMicrosoftAccountOptionalModernAuthWebUI" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsSpotlightWindowsWelcomeExperience" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsSpotlightOnActionCenter" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsSpotlightOnSettings" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableSoftLanding" 1

Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 0
Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" "ChatIcon" 3

# ================================================================
# TAMAMLANDI
# ================================================================
Write-Host "`n" -NoNewline
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "         TUM TELEMETRI AYARLARI BASARIYLA UYGULANDI!         " -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "  [OK] Telemetri servisleri devre disi                        " -ForegroundColor Green
Write-Host "  [OK] Kayit defteri gizlilik ayarlari uygulandi              " -ForegroundColor Green
Write-Host "  [OK] Zamanlanmis telemetri gorevleri silindi                " -ForegroundColor Green
Write-Host "  [OK] Hosts dosyasina engellemeler eklendi                   " -ForegroundColor Green
Write-Host "  [OK] Guvenlik duvari kurallari olusturuldu                  " -ForegroundColor Green
Write-Host "  [OK] Bloatware uygulamalari kaldirildi                      " -ForegroundColor Green
Write-Host "  [OK] Office telemetrisi kapatildi                           " -ForegroundColor Green
Write-Host "  [OK] Gecici dosyalar temizlendi                             " -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Yellow
Write-Host "  [!] Degisikliklerin tam etkisi icin sisteminizi yeniden     " -ForegroundColor Yellow
Write-Host "      baslatin!                                               " -ForegroundColor Yellow
Write-Host "==============================================================" -ForegroundColor Green

if (Prompt-YesNo $L.RestartPrompt) {
    Write-Host "  $($L.Restarting)" -ForegroundColor Cyan
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}