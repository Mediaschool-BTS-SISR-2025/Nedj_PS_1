Clear-Host
Write-Host "=== Installation des roles Windows Server ===" -ForegroundColor Cyan

# Emplacement du journal
$logPath = ".\installation_roles.log"

# Liste des rôles disponibles
$roles = @{
    '1' = @{ Name = "AD-Domain-Services"; Display = "Services de domaine Active Directory" }
    '2' = @{ Name = "DNS"; Display = "Serveur DNS" }
    '3' = @{ Name = "DHCP"; Display = "Serveur DHCP" }
    '4' = @{ Name = "File-Services"; Display = "Services de fichiers" }
    '5' = @{ Name = "Web-Server"; Display = "Serveur Web (IIS)" }
    '6' = @{ Name = "Exit"; Display = "Retour au menu principal" }
}

# Affichage des rôles disponibles
Write-Host "`nRoles disponibles :"
foreach ($key in $roles.Keys) {
    Write-Host "$key. $($roles[$key].Display)"
}

# Choix de l'utilisateur
$choix = Read-Host "`nEntrez le numero du role a installer (ou 6 pour quitter)"

if ($roles.ContainsKey($choix) -and $roles[$choix].Name -ne "Exit") {
    $roleName = $roles[$choix].Name
    $roleDisplay = $roles[$choix].Display

    # Vérification si le rôle est déjà installé
    $feature = Get-WindowsFeature -Name $roleName
    if ($feature.Installed) {
        Write-Host "`nLe role '$roleDisplay' est deja installe." -ForegroundColor Yellow
    }
    else {
        Write-Host "`nInstallation de : $roleDisplay..." -ForegroundColor Cyan

        try {
            Install-WindowsFeature -Name $roleName -IncludeManagementTools -Verbose

            # Écriture dans le journal
            $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Role installe : $roleDisplay ($roleName)"
            Add-Content -Path $logPath -Value $logEntry

            Write-Host "`nRole '$roleDisplay' installe avec succes !" -ForegroundColor Green
        }
        catch {
            Write-Host "Erreur lors de l'installation du role : $_" -ForegroundColor Red
        }
    }
}
elseif ($choix -eq '6') {
    Write-Host "`nRetour au menu principal..." -ForegroundColor Cyan
}
else {
    Write-Host "`nOption invalide." -ForegroundColor Red
}
