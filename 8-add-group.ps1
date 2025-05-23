Clear-Host
Write-Host "=== Création d'un groupe Active Directory ===" -ForegroundColor Cyan

$logFile = ".\add_group.log"

# Importer le module Active Directory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "Module ActiveDirectory chargé." -ForegroundColor Green
}
catch {
    Write-Host "Erreur : le module ActiveDirectory n'est pas installé ou accessible." -ForegroundColor Red
    return
}

# Saisie des paramètres du groupe
$groupName = Read-Host "Entrez le nom du groupe (ex: 'ITAdmins')"

do {
    $groupScope = Read-Host "Entrez la portée du groupe (DomainLocal, Global, Universal)"
} while ($groupScope -notin @("DomainLocal", "Global", "Universal"))

do {
    $groupTypeInput = Read-Host "Entrez le type du groupe (Security ou Distribution)"
} while ($groupTypeInput -notin @("Security", "Distribution"))

# Convertir le type en booléen requis par New-ADGroup (-GroupScope est string, -GroupCategory attend "Security" ou "Distribution")
$groupCategory = $groupTypeInput

$parentPath = Read-Host "Entrez le chemin LDAP où créer le groupe (ex: 'OU=IT,DC=entreprise,DC=local')"

try {
    # Vérifier si le groupe existe déjà
    $existingGroup = Get-ADGroup -Filter "Name -eq '$groupName'" -SearchBase $parentPath -ErrorAction SilentlyContinue
    if ($existingGroup) {
        Write-Host "Le groupe '$groupName' existe déjà dans $parentPath." -ForegroundColor Yellow
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Groupe '$groupName' déjà existant dans $parentPath"
    }
    else {
        # Créer le groupe
        New-ADGroup -Name $groupName -GroupScope $groupScope -GroupCategory $groupCategory -Path $parentPath
        Write-Host "Groupe '$groupName' créé avec succès dans $parentPath." -ForegroundColor Green
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Groupe '$groupName' créé dans $parentPath"
    }
}
catch {
    Write-Host "Erreur lors de la création du groupe : $_" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur création groupe : $_"
}
