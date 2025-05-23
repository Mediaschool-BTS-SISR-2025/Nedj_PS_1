$continue = $true

while ($continue) {
    Clear-Host
    Write-Host "=================================="
    Write-Host "      MENU CONFIGURATION"
    Write-Host "=================================="
    Write-Host "1. Renommer le PC"
    Write-Host "2. Configurer une adresse IP fixe"
    Write-Host "3. Installer ADDS, DHCP et DNS"
    Write-Host "----------------------------------"
    Write-Host "4. Configurer ADDS"
    Write-Host "5. Configurer DNS"
    Write-Host "6. Configurer DHCP"
    Write-Host "----------------------------------"
    Write-Host "7. Ajouter une Unité d'Organisation (OU)"
    Write-Host "8. Ajouter un groupe d’utilisateurs"
    Write-Host "9. Ajouter un utilisateur"
    Write-Host "10. Importer des utilisateurs depuis un CSV"
    Write-Host "=================================="
    Write-Host "11. Quitter"
    
    $choix = Read-Host "Sélectionnez une option"

   switch ($choix) {
    '1' { . .\1-rename.ps1 }
    '2' { . .\2-ipconfig.ps1 }
    '3' { . .\3-install-roles.ps1 }
    '4' { . .\4-configure-adds.ps1 }
    '5' { . .\5-configure-dns.ps1 }
    '6' { . .\6-configure-dhcp.ps1 }
    '7' { . .\7-add-ou.ps1 }
    '8' { . .\8-add-group.ps1 }
    '9' { . .\9-add-user.ps1 }
    '10' { . .\10-import-csv.ps1 }
    '11' {
        Write-Host "Fermeture du menu. À bientôt !" -ForegroundColor Cyan
        $continue = $false
    }
    default {
        Write-Host "Option invalide. Veuillez réessayer." -ForegroundColor Red
        }
    }

    if ($continue) {
    Pause
    }
}