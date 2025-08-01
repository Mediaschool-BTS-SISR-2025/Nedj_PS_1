Clear-Host
Write-Host "=== Configuration du role DHCP ===" -ForegroundColor Cyan

$logFile = ".\dhcp_config.log"

# Vérifier si le rôle DHCP est installé
$dhcpFeature = Get-WindowsFeature -Name DHCP

if (-not $dhcpFeature.Installed) {
    Write-Host "`nInstallation du role DHCP..." -ForegroundColor Yellow
    Install-WindowsFeature -Name DHCP -IncludeManagementTools
    Write-Host "Role DHCP installe." -ForegroundColor Green
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Role DHCP installe"
} else {
    Write-Host "`nLe role DHCP est deja installe." -ForegroundColor Yellow
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Role DHCP deja present"
}

# Importer le module DHCPServer
Import-Module DHCPServer

# Paramètres étendue DHCP
$scopeName = Read-Host "`nEntrez le nom de l'etendue DHCP (ex: Scope1)"
$startRange = Read-Host "Entrez l'adresse IP de debut (ex: 192.168.1.100)"
$endRange = Read-Host "Entrez l'adresse IP de fin (ex: 192.168.1.200)"
$subnetMask = Read-Host "Entrez le masque de sous-reseau (ex: 255.255.255.0)"
$gateway = Read-Host "Entrez la passerelle par defaut (ex: 192.168.1.1)"
$dnsServers = Read-Host "Entrez les serveurs DNS separes par une virgule (ex: 8.8.8.8,1.1.1.1)"

try {
    # Vérifier si l'étendue existe déjà
    $existingScope = Get-DhcpServerv4Scope -ScopeId $startRange -ErrorAction SilentlyContinue
    if ($existingScope) {
        Write-Host "L'etendue DHCP avec l'adresse de debut $startRange existe deja." -ForegroundColor Yellow
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Etendue DHCP existante : $scopeName"
    } else {
        # Créer l'étendue DHCP
        Add-DhcpServerv4Scope -Name $scopeName -StartRange $startRange -EndRange $endRange -SubnetMask $subnetMask -State Active
        Write-Host "Etendue DHCP '$scopeName' creee et activee." -ForegroundColor Green
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Etendue DHCP creee : $scopeName"

        # Configurer la passerelle (router)
        Set-DhcpServerv4OptionValue -ScopeId $startRange -Router $gateway

        # Configurer les serveurs DNS
        $dnsArray = $dnsServers -split ',' | ForEach-Object { $_.Trim() }
        Set-DhcpServerv4OptionValue -ScopeId $startRange -DnsServer $dnsArray

        Write-Host "Passerelle et DNS configures pour l'etendue." -ForegroundColor Green
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Passerelle et DNS configures pour l'etendue $scopeName"
    }
}
catch {
    Write-Host "Erreur lors de la configuration DHCP : $_" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur DHCP : $_"
}
