Clear-Host
Write-Host "=== Creation d'un utilisateur Active Directory ===" -ForegroundColor Cyan

$logFile = ".\add_user.log"
$domainPath = "DC=entreprise,DC=local"  # ⚠️ À adapter selon ton domaine
$ouOptions = @("Eleves", "Professeurs", "Administratif")

# Importer le module Active Directory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "✅ Module ActiveDirectory charge." -ForegroundColor Green
}
catch {
    Write-Host "❌ Le module ActiveDirectory n'est pas disponible." -ForegroundColor Red
    return
}

# Choix OU cible
Write-Host "Selectionnez l'OU dans laquelle creer l'utilisateur :"
for ($i = 0; $i -lt $ouOptions.Count; $i++) {
    Write-Host "$($i + 1). $($ouOptions[$i])"
}
do {
    $selection = Read-Host "Entrez le numero de l'OU (1 à 3)"
} while (-not ($selection -match '^[1-3]$'))

$selectedOU = $ouOptions[$selection - 1]
$ouPath = "OU=$selectedOU,$domainPath"

# Fonction de génération de logonHours
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

# Saisie des infos utilisateur
$firstName = Read-Host "Entrez le prenom"
$lastName = Read-Host "Entrez le nom"
$samAccountName = Read-Host "Entrez le nom d'utilisateur (samAccountName)"
$password = Read-Host "Entrez le mot de passe initial" -AsSecureString

# Vérifier l'existence
$existingUser = Get-ADUser -Filter "SamAccountName -eq '$samAccountName'" -ErrorAction SilentlyContinue
if ($existingUser) {
    Write-Host "⚠️ L'utilisateur '$samAccountName' existe deja." -ForegroundColor Yellow
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Utilisateur '$samAccountName' deja existant"
    return
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

    Write-Host "✅ Utilisateur '$samAccountName' cree dans $selectedOU." -ForegroundColor Green
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Utilisateur '$samAccountName' cree dans $ouPath"

    # Appliquer logonHours en fonction de l'OU
    switch ($selectedOU) {
        "Eleves"        { $logonHours = Get-LogonHours 9 17 }
        "Professeurs"   { $logonHours = Get-LogonHours 8 18 }
        "Administratif" { $logonHours = Get-LogonHours 6 20 }
    }

    Set-ADUser $samAccountName -LogonHours $logonHours
    Write-Host "🕘 Heures de connexion appliquees à $samAccountName." -ForegroundColor Cyan
}
catch {
    Write-Host "❌ Erreur lors de la creation de l'utilisateur : $_" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur creation utilisateur '$samAccountName' : $_"
}
