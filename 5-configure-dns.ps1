Clear-Host
Write-Host "=== Configuration du role DNS ===" -ForegroundColor Cyan

$logFile = ".\dns_config.log"

# Vérifier l'installation du rôle DNS
$dnsFeature = Get-WindowsFeature -Name DNS

if (-not $dnsFeature.Installed) {
    Write-Host "`nInstallation du role DNS..." -ForegroundColor Yellow
    Install-WindowsFeature -Name DNS -IncludeManagementTools
    Write-Host "Role DNS installe." -ForegroundColor Green
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Role DNS installe"
} else {
    Write-Host "`nLe role DNS est déjà installé." -ForegroundColor Yellow
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Role DNS deja present"
}

# Demander le nom de la zone DNS principale (ex: entreprise.local)
$zoneName = Read-Host "`nEntrez le nom de la zone DNS principale (ex: entreprise.local)"

# Créer la zone DNS principale (si elle n'existe pas)
try {
    $zone = Get-DnsServerPrimaryZone -Name $zoneName -ErrorAction SilentlyContinue
    if (-not $zone) {
        Write-Host "Creation de la zone DNS primaire '$zoneName'..." -ForegroundColor Cyan
        Add-DnsServerPrimaryZone -Name $zoneName -ZoneFile "$zoneName.dns"
        Write-Host "Zone DNS primaire creee." -ForegroundColor Green
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Zone DNS primaire '$zoneName' creee"
    } else {
        Write-Host "La zone DNS '$zoneName' existe deja." -ForegroundColor Yellow
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Zone DNS '$zoneName' deja existante"
    }
}
catch {
    Write-Host "Erreur lors de la creation de la zone DNS : $_" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur zone DNS : $_"
}

# Configurer les forwarders DNS
$forwarders = Read-Host "`nEntrez les adresses IP des forwarders DNS separees par une virgule (ex: 8.8.8.8,1.1.1.1)"

try {
    $forwarderIPs = $forwarders -split ',' | ForEach-Object { $_.Trim() }
    Set-DnsServerForwarder -IPAddress $forwarderIPs -PassThru
    Write-Host "Forwarders DNS configures." -ForegroundColor Green
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Forwarders DNS configures : $forwarders"
}
catch {
    Write-Host "Erreur lors de la configuration des forwarders DNS : $_" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur forwarders DNS : $_"
}
