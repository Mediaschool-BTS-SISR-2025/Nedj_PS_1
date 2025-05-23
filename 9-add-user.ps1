Clear-Host
Write-Host "=== Création d'un utilisateur Active Directory ===" -ForegroundColor Cyan

$logFile = ".\add_user.log"

# Importer le module Active Directory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "Module ActiveDirectory chargé." -ForegroundColor Green
}
catch {
    Write-Host "Erreur : le module ActiveDirectory n'est pas installé ou accessible." -ForegroundColor Red
    return
}

# Saisie des informations utilisateur
$firstName = Read-Host "Entrez le prénom"
$lastName = Read-Host "Entrez le nom"
$samAccountName = Read-Host "Entrez le nom d'utilisateur (samAccountName)"
$password = Read-Host "Entrez le mot de passe initial" -AsSecureString
$ouPath = Read-Host "Entrez le chemin LDAP où créer l'utilisateur (ex: 'OU=Utilisateurs,DC=entreprise,DC=local')"

try {
    # Vérifier si l'utilisateur existe déjà
    $existingUser = Get-ADUser -Filter "SamAccountName -eq '$samAccountName'" -ErrorAction SilentlyContinue
    if ($existingUser) {
        Write-Host "L'utilisateur '$samAccountName' existe déjà." -ForegroundColor Yellow
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Utilisateur '$samAccountName' déjà existant"
    }
    else {
        # Créer l'utilisateur
        New-ADUser -Name "$firstName $lastName" `
                   -GivenName $firstName `
                   -Surname $lastName `
                   -SamAccountName $samAccountName `
                   -AccountPassword $password `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true `
                   -Path $ouPath

        Write-Host "Utilisateur '$samAccountName' créé avec succès dans $ouPath." -ForegroundColor Green
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Utilisateur '$samAccountName' créé dans $ouPath"
    }
}
catch {
    Write-Host "Erreur lors de la création de l'utilisateur : $_" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur création utilisateur : $_"
}
