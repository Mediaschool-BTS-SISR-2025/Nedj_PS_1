Clear-Host
Write-Host "=== Ajout d'une Unité d'Organisation (OU) ===" -ForegroundColor Cyan

$logFile = ".\add_ou.log"

# Importer le module Active Directory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "Module ActiveDirectory chargé." -ForegroundColor Green
}
catch {
    Write-Host "Erreur : le module ActiveDirectory n'est pas installé ou accessible." -ForegroundColor Red
    return
}

# Demander le nom de la OU à créer
$ouName = Read-Host "Entrez le nom de la nouvelle OU (ex: 'RH')"

# Demander le chemin LDAP où créer la OU
$parentPath = Read-Host "Entrez le chemin LDAP du conteneur parent (ex: 'DC=entreprise,DC=local')"

$fullOUPath = "OU=$ouName,$parentPath"

try {
    # Vérifier si l'OU existe déjà
    $existingOU = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'" -SearchBase $parentPath -ErrorAction SilentlyContinue
    if ($existingOU) {
        Write-Host "L'OU '$ouName' existe déjà dans $parentPath." -ForegroundColor Yellow
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - OU '$ouName' déjà existante dans $parentPath"
    }
    else {
        # Créer l'OU avec protection contre suppression accidentelle
        New-ADOrganizationalUnit -Name $ouName -Path $parentPath -ProtectedFromAccidentalDeletion $true
        Write-Host "OU '$ouName' créée avec succès dans $parentPath." -ForegroundColor Green
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - OU '$ouName' créée dans $parentPath"
    }
}
catch {
    Write-Host "Erreur lors de la création de l'OU : $_" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur création OU : $_"
}
