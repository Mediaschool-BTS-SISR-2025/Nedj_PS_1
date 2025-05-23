Clear-Host
Write-Host "=== Configuration d'une adresse IP fixe ===" -ForegroundColor Cyan

# Lister les interfaces réseau disponibles
Write-Host "`nInterfaces réseau détectées :" -ForegroundColor Yellow
Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | ForEach-Object {
    Write-Host "- $($_.Name) (MAC: $($_.MacAddress))"
}

# Saisie de l'interface
$interfaceAlias = Read-Host "Entrez l'alias de l'interface réseau (ex: Ethernet)"
if (-not (Get-NetAdapter -Name $interfaceAlias -ErrorAction SilentlyContinue)) {
    Write-Host "`nInterface introuvable. Vérifiez le nom." -ForegroundColor Red
    return
}

# Paramètres IP
$ipAddress = Read-Host "Entrez l'adresse IP fixe (ex: 192.168.1.10)"
$subnetMask = Read-Host "Entrez le préfixe de sous-réseau (ex: 24)"
$gateway = Read-Host "Entrez la passerelle (ex: 192.168.1.1)"
$dns1 = Read-Host "Entrez le DNS primaire (ex: 1.1.1.1)"
$dns2 = Read-Host "Entrez le DNS secondaire (optionnel, ex: 8.8.8.8)"

# Application de la configuration
try {
    # Supprimer les IP existantes
    Get-NetIPAddress -InterfaceAlias $interfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue | Remove-NetIPAddress -Confirm:$false

    # Ajouter la nouvelle IP
    New-NetIPAddress -InterfaceAlias $interfaceAlias -IPAddress $ipAddress -PrefixLength $subnetMask -DefaultGateway $gateway

    # Appliquer DNS
    $dnsServers = @($dns1)
    if ($dns2 -ne "") { $dnsServers += $dns2 }
    Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias -ServerAddresses $dnsServers

    Write-Host "`nConfiguration IP appliquée avec succès !" -ForegroundColor Green
}
catch {
    Write-Host "Erreur lors de la configuration IP : $_" -ForegroundColor Red
}
