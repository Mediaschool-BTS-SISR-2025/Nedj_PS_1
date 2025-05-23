Clear-Host
Write-Host "=== Configuration du rôle DNS ===" -ForegroundColor Cyan

$logFile = ".\dns_config.log"

# Vérifier l'installation du rôle DNS
$dnsFeature = Get-WindowsFeature -Name DNS

if (-not $dnsFeature.Installed) {
    Write-Host "`nInstallation du rôle DNS..." -ForegroundColor Yellow
    Install-WindowsFeature -Name DNS -IncludeManagementTools
    Write-Host "Rôle DNS installé." -ForegroundColor Green
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Rôle DNS installé"
} else {
    Write-Host "`nLe rôle DNS est déjà installé." -ForegroundColor Yellow
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Rôle DNS déjà présent"
}

# Demander le nom de la zone DNS principale (ex: entreprise.local)
$zoneName = Read-Host "`nEntrez le nom de la zone DNS principale (ex: entreprise.local)"

# Créer la zone DNS principale (si elle n'existe pas)
try {
    $zone = Get-DnsServerPrimaryZone -Name $zoneName -ErrorAction SilentlyContinue
    if (-not $zone) {
        Write-Host "Création de la zone DNS primaire '$zoneName'..." -ForegroundColor Cyan
        Add-DnsServerPrimaryZone -Name $zoneName -ZoneFile "$zoneName.dns"
        Write-Host "Zone DNS primaire créée." -ForegroundColor Green
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Zone DNS primaire '$zoneName' créée"
    } else {
        Write-Host "La zone DNS '$zoneName' existe déjà." -ForegroundColor Yellow
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Zone DNS '$zoneName' déjà existante"
    }
}
catch {
    Write-Host "Erreur lors de la création de la zone DNS : $_" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur zone DNS : $_"
}

# Configurer les forwarders DNS
$forwarders = Read-Host "`nEntrez les adresses IP des forwarders DNS séparées par une virgule (ex: 8.8.8.8,1.1.1.1)"

try {
    $forwarderIPs = $forwarders -split ',' | ForEach-Object { $_.Trim() }
    Set-DnsServerForwarder -IPAddress $forwarderIPs -PassThru
    Write-Host "Forwarders DNS configurés." -ForegroundColor Green
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Forwarders DNS configurés : $forwarders"
}
catch {
    Write-Host "Erreur lors de la configuration des forwarders DNS : $_" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur forwarders DNS : $_"
}
