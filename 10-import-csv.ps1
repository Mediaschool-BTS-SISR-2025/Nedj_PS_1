Clear-Host
Write-Host "=== Importation d'utilisateurs depuis un fichier CSV avec horaires de connexion ===" -ForegroundColor Cyan

$logFile = ".\import_csv.log"

# Importer le module Active Directory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "✅ Module ActiveDirectory chargé." -ForegroundColor Green
}
catch {
    Write-Host "❌ Erreur : le module ActiveDirectory n'est pas installé ou accessible." -ForegroundColor Red
    return
}

# Chemin du fichier CSV à importer
$csvPath = Read-Host "Entrez le chemin complet du fichier CSV (ex: C:\Users\import.csv)"

if (-not (Test-Path $csvPath)) {
    Write-Host "❌ Le fichier CSV n'existe pas : $csvPath" -ForegroundColor Red
    return
}

# Fonction pour générer les logonHours
function Get-LogonHours {
    param ([int]$StartHour, [int]$EndHour)
    $hours = @(0) * 168
    for ($day = 0; $day -lt 7; $day++) {
        for ($hour = $StartHour; $hour -lt $EndHour; $hour++) {
            $hours[($day * 24) + $hour] = 1
        }
    }
    return ,$hours
}

# Lire les données du CSV
try {
    $users = Import-Csv -Path $csvPath

    foreach ($user in $users) {
        $firstName = $user.FirstName
        $lastName = $user.LastName
        $samAccountName = $user.SamAccountName
        $passwordPlain = $user.Password
        $ouPath = $user.OUPath

        # Convertir le mot de passe en SecureString
        $password = ConvertTo-SecureString $passwordPlain -AsPlainText -Force

        # Vérifier si l'utilisateur existe déjà
        $existingUser = Get-ADUser -Filter "SamAccountName -eq '$samAccountName'" -ErrorAction SilentlyContinue

        if ($existingUser) {
            Write-Host "⚠️ Utilisateur '$samAccountName' déjà existant. Ignoré." -ForegroundColor Yellow
            Add-Content $logFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Utilisateur '$samAccountName' déjà existant"
            continue
        }

        try {
            # Créer l'utilisateur
            New-ADUser -Name "$firstName $lastName" `
                       -GivenName $firstName `
                       -Surname $lastName `
                       -SamAccountName $samAccountName `
                       -AccountPassword $password `
                       -Enabled $true `
                       -ChangePasswordAtLogon $true `
                       -Path $ouPath

            Write-Host "✅ Utilisateur '$samAccountName' créé dans $ouPath." -ForegroundColor Green
            Add-Content $logFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Utilisateur '$samAccountName' créé dans $ouPath"

            # Appliquer les horaires selon l’OU
            switch -Wildcard ($ouPath) {
                "*OU=Eleves*"        { $logonHours = Get-LogonHours 9 17 }
                "*OU=Professeurs*"   { $logonHours = Get-LogonHours 8 18 }
                "*OU=Administratif*" { $logonHours = Get-LogonHours 6 20 }
                default              { $logonHours = $null }
            }

            if ($logonHours) {
                Set-ADUser $samAccountName -LogonHours $logonHours
                Write-Host "🕘 Heures de connexion appliquées à '$samAccountName'." -ForegroundColor Cyan
            } else {
                Write-Host "❗ Aucune restriction horaire appliquée à '$samAccountName' (OU non reconnue)." -ForegroundColor Yellow
            }

        }
        catch {
            Write-Host "❌ Erreur lors de la création de l'utilisateur '$samAccountName' : $_" -ForegroundColor Red
            Add-Content $logFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur utilisateur '$samAccountName' : $_"
        }
    }
}
catch {
    Write-Host "❌ Erreur lors de l'importation du fichier CSV : $_" -ForegroundColor Red
    Add-Content $logFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur globale d'import CSV : $_"
}
