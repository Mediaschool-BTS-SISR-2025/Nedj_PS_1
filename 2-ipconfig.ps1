$interfaceAlias = Read-Host "Entrez l'alias de l'interface réseau (ex: Ethernet)"
$ipAddress = Read-Host "Entrez l'adresse IP fixe"
$subnetMask = Read-Host "Entrez le préfixe de sous-réseau (ex: 24)"
$gateway = Read-Host "Entrez la passerelle"
$dns1 = Read-Host "Entrez le DNS primaire"
$dns2 = Read-Host "Entrez le DNS secondaire"

New-NetIPAddress -InterfaceAlias $interfaceAlias -IPAddress $ipAddress -PrefixLength $subnetMask -DefaultGateway $gateway
Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias -ServerAddresses ($dns1, $dns2)
