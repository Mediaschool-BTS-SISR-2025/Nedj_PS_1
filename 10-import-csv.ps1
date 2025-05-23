Clear-Host
Write-Host "=== Importation d'utilisateurs depuis un fichier CSV ===" -ForegroundColor Cyan

$logFile = ".\import_csv.log"

# Importer le module Active Directory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "Module ActiveDirectory chargé." -ForegroundColor Green
}
catch {
    Write-Host "Erreur : le module ActiveDirectory n'est pas installé ou accessible." -ForegroundColor Red
    return
}

# Chemin du fichier CSV à importer
$csvPath = Read-Host "Entrez le chemin complet du fichier CSV (ex: C:\Users\import.csv)"

if (-not (Test-Path $csvPath)) {
    Write-Host "Le fichier CSV n'existe pas : $csvPath" -ForegroundColor Red
    return
}

try {
    $users = Import-Csv -Path $csvPath

    foreach ($user in $users) {
        # On suppose que le CSV contient au minimum ces colonnes : FirstName, LastName, SamAccountName, Password, OUPath
        $firstName = $user.FirstName
        $lastName = $user.LastName
        $samAccountName = $user.SamAccountName
        $passwordPlain = $user.Password
        $ouPath = $user.OUPath

        # Convertir mot de passe en SecureString
        $password = ConvertTo-SecureString $passwordPlain -AsPlainText -Force

        # Vérifier si l'utilisateur existe déjà
        $existingUser = Get-ADUser -Filter "SamAccountName -eq '$samAccountName'" -ErrorAction SilentlyContinue

        if ($existingUser) {
            Write-Host "Utilisateur '$samAccountName' existe déjà, skipping..." -ForegroundColor Yellow
            Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Utilisateur '$samAccountName' déjà existant, ignoré"
            continue
        }

        # Créer l'utilisateur
        try {
            New-ADUser -Name "$firstName $lastName" `
                       -GivenName $firstName `
                       -Surname $lastName `
                       -SamAccountName $samAccountName `
                       -AccountPassword $password `
                       -Enabled $true `
                       -ChangePasswordAtLogon $true `
                       -Path $ouPath

            Write-Host "Utilisateur '$samAccountName' créé avec succès." -ForegroundColor Green
            Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Utilisateur '$samAccountName' créé"
        }
        catch {
            Write-Host "Erreur lors de la création de l'utilisateur '$samAccountName' : $_" -ForegroundColor Red
            Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur création utilisateur '$samAccountName' : $_"
        }
    }
}
catch {
    Write-Host "Erreur lors de l'import du CSV : $_" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur import CSV : $_"
}
