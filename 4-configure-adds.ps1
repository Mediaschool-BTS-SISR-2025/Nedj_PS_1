Clear-Host
Write-Host "=== Configuration d'Active Directory (AD DS) ===" -ForegroundColor Cyan

# Journal
$logFile = ".\adds_config.log"

# Vérification IP statique
Write-Host "`nVérification de la configuration IP..." -ForegroundColor Yellow
$activeInterface = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
$ipConfig = Get-NetIPAddress -InterfaceIndex $activeInterface.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue

if ($ipConfig.PrefixOrigin -ne 'Manual') {
    Write-Host "❌ L'adresse IP de l'interface '$($activeInterface.Name)' n'est pas statique. Veuillez la configurer avant de continuer." -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Échec : IP non statique sur $($activeInterface.Name)"
    return
} else {
    Write-Host "✅ Adresse IP statique détectée sur l'interface '$($activeInterface.Name)'." -ForegroundColor Green
}

# Vérification si le rôle AD DS est déjà installé
$adFeature = Get-WindowsFeature -Name AD-Domain-Services
if (-not $adFeature.Installed) {
    Write-Host "`nInstallation du rôle AD DS..." -ForegroundColor Yellow
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    Write-Host "Rôle AD DS installé." -ForegroundColor Green
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Rôle AD DS installé"
} else {
    Write-Host "`nLe rôle AD DS est déjà installé." -ForegroundColor Yellow
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Rôle AD DS déjà présent"
}

# Nom de domaine
$domainName = Read-Host "`nEntrez le nom du domaine (ex: entreprise.local)"

# Mot de passe DSRM
$securePassword = Read-Host "Entrez le mot de passe DSRM (restauration)" -AsSecureString

# Configuration AD DS
Write-Host "`nConfiguration du contrôleur de domaine en cours..." -ForegroundColor Cyan

try {
    Install-ADDSForest `
        -DomainName $domainName `
        -SafeModeAdministratorPassword $securePassword `
        -InstallDNS `
        -Force `
        -NoRebootOnCompletion:$true

    Write-Host "`n✅ Contrôleur de domaine configuré avec succès." -ForegroundColor Green
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Domaine '$domainName' configuré avec succès"

    # Demander confirmation pour redémarrer
    $restartConfirm = Read-Host "`nSouhaitez-vous redémarrer maintenant ? (O/N)"
    if ($restartConfirm -match '^[Oo]$') {
        Write-Host "Redémarrage en cours..." -ForegroundColor Cyan
        Restart-Computer
    } else {
        Write-Host "Redémarrage annulé. Vous pouvez redémarrer manuellement plus tard." -ForegroundColor Yellow
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Redémarrage annulé par l'utilisateur"
    }
}
catch {
    Write-Host "❌ Erreur lors de la configuration AD : $_" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur : $_"
}
