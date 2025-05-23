Clear-Host
Write-Host "=== Renommer le PC ===" -ForegroundColor Cyan

# Demande du nouveau nom
$newName = Read-Host "Entrez le nouveau nom du PC"

# Vérification
if ([string]::IsNullOrWhiteSpace($newName)) {
    Write-Host "Nom invalide. Opération annulée." -ForegroundColor Red
    return
}

# Affichage du nom actuel
$currentName = $env:COMPUTERNAME
Write-Host "Nom actuel du PC : $currentName"
Write-Host "Nouveau nom proposé : $newName"

# Confirmation utilisateur
$confirmation = Read-Host "Confirmez-vous le changement ? (O/N)"
if ($confirmation -ne 'O' -and $confirmation -ne 'o') {
    Write-Host "Opération annulée par l'utilisateur." -ForegroundColor Yellow
    return
}

# Renommage + redémarrage
try {
    Rename-Computer -NewName $newName -Force
    Write-Host "Le PC a été renommé avec succès en '$newName'." -ForegroundColor Green

    $restart = Read-Host "Voulez-vous redémarrer maintenant ? (O/N)"
    if ($restart -eq 'O' -or $restart -eq 'o') {
        Restart-Computer
    } else {
        Write-Host "Redémarrage annulé. Le changement sera effectif après redémarrage." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Erreur lors du renommage : $_" -ForegroundColor Red
}
