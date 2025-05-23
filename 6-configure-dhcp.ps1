Clear-Host
Write-Host "=== Configuration du rôle DHCP ===" -ForegroundColor Cyan

$logFile = ".\dhcp_config.log"

# Vérifier si le rôle DHCP est installé
$dhcpFeature = Get-WindowsFeature -Name DHCP

if (-not $dhcpFeature.Installed) {
    Write-Host "`nInstallation du rôle DHCP..." -ForegroundColor Yellow
    Install-WindowsFeature -Name DHCP -IncludeManagementTools
    Write-Host "Rôle DHCP installé." -ForegroundColor Green
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Rôle DHCP installé"
} else {
    Write-Host "`nLe rôle DHCP est déjà installé." -ForegroundColor Yellow
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Rôle DHCP déjà présent"
}

# Importer le module DHCPServer
Import-Module DHCPServer

# Paramètres étendue DHCP
$scopeName = Read-Host "`nEntrez le nom de l'étendue DHCP (ex: Scope1)"
$startRange = Read-Host "Entrez l'adresse IP de début (ex: 192.168.1.100)"
$endRange = Read-Host "Entrez l'adresse IP de fin (ex: 192.168.1.200)"
$subnetMask = Read-Host "Entrez le masque de sous-réseau (ex: 255.255.255.0)"
$gateway = Read-Host "Entrez la passerelle par défaut (ex: 192.168.1.1)"
$dnsServers = Read-Host "Entrez les serveurs DNS séparés par une virgule (ex: 8.8.8.8,1.1.1.1)"

try {
    # Vérifier si l'étendue existe déjà
    $existingScope = Get-DhcpServerv4Scope -ScopeId $startRange -ErrorAction SilentlyContinue
    if ($existingScope) {
        Write-Host "L'étendue DHCP avec l'adresse de début $startRange existe déjà." -ForegroundColor Yellow
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Étendue DHCP existante : $scopeName"
    } else {
        # Créer l'étendue DHCP
        Add-DhcpServerv4Scope -Name $scopeName -StartRange $startRange -EndRange $endRange -SubnetMask $subnetMask -State Active
        Write-Host "Étendue DHCP '$scopeName' créée et activée." -ForegroundColor Green
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Étendue DHCP créée : $scopeName"

        # Configurer la passerelle (router)
        Set-DhcpServerv4OptionValue -ScopeId $startRange -Router $gateway

        # Configurer les serveurs DNS
        $dnsArray = $dnsServers -split ',' | ForEach-Object { $_.Trim() }
        Set-DhcpServerv4OptionValue -ScopeId $startRange -DnsServer $dnsArray

        Write-Host "Passerelle et DNS configurés pour l'étendue." -ForegroundColor Green
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Passerelle et DNS configurés pour l'étendue $scopeName"
    }
}
catch {
    Write-Host "Erreur lors de la configuration DHCP : $_" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur DHCP : $_"
}
