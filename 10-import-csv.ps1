Clear-Host
Write-Host "=== Importation CSV + création OU + horaires AD corrects ===" -ForegroundColor Cyan

$logFile = ".\import_csv.log"

# Charger module Active Directory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "✅ Module ActiveDirectory chargé." -ForegroundColor Green
}
catch {
    Write-Host "❌ Module Active Directory introuvable." -ForegroundColor Red
    return
}

# Demander le CSV
$csvPath = Read-Host "Entrez le chemin complet du fichier CSV (ex: C:\Users\import.csv)"

if (-not (Test-Path $csvPath)) {
    Write-Host "❌ Le fichier CSV n'existe pas : $csvPath" -ForegroundColor Red
    return
}

# Créer OU si manquante
function Create-OU {
    param ([string]$OUPath)
    try {
        if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OUPath'" -ErrorAction SilentlyContinue)) {
            New-ADOrganizationalUnit -Name ($OUPath -split ",")[0].Substring(3) -Path ($OUPath -replace "^OU=[^,]+,", "") -ErrorAction Stop
            Write-Host "✅ OU créée : $OUPath" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "❌ Erreur création OU '$OUPath' : $_" -ForegroundColor Red
    }
}

# Générer les logonHours (21 octets, dimanche = 0)
function Get-LogonHours {
    param (
        [int]$StartHour,
        [int]$EndHour,
        [int[]]$Days  # Microsoft: 0 = dimanche, 1 = lundi...
    )

    $hours = @(0) * 168

    foreach ($day in $Days) {
        for ($hour = $StartHour; $hour -lt $EndHour; $hour++) {
            $index = ($day * 24) + $hour
            if ($index -lt 168) {
                $hours[$index] = 1
            }
        }
    }

    [byte[]]$logonBytes = @(0) * 21
    for ($i = 0; $i -lt 21; $i++) {
        $byteVal = 0
        for ($bit = 0; $bit -lt 8; $bit++) {
            $bitIndex = ($i * 8) + $bit
            if ($bitIndex -lt 168 -and $hours[$bitIndex] -eq 1) {
                $byteVal += 1 -shl (7 - $bit)
            }
        }
        $logonBytes[$i] = [byte]$byteVal
    }

    return $logonBytes
}

# Lecture du CSV
try {
    $users = Import-Csv -Path $csvPath

    foreach ($user in $users) {
        $firstName = $user.FirstName
        $lastName = $user.LastName
        $samAccountName = $user.SamAccountName
        $passwordPlain = $user.Password
        $ouPath = $user.OUPath

        Create-OU -OUPath $ouPath
        $password = ConvertTo-SecureString $passwordPlain -AsPlainText -Force
        $existingUser = Get-ADUser -Filter "SamAccountName -eq '$samAccountName'" -ErrorAction SilentlyContinue

        if ($existingUser) {
            Write-Host "⚠️ Utilisateur '$samAccountName' existant. Mise à jour des horaires." -ForegroundColor Yellow
            Add-Content $logFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - '$samAccountName' déjà existant."
        } else {
            $domainSuffix = (($ouPath -split ",") | Where-Object { $_ -like "DC=*" } | ForEach-Object { $_ -replace "DC=", "" }) -join "."
            $upn = "$samAccountName@$domainSuffix"

            try {
                New-ADUser -Name "$firstName $lastName" `
                           -GivenName $firstName `
                           -Surname $lastName `
                           -SamAccountName $samAccountName `
                           -UserPrincipalName $upn `
                           -AccountPassword $password `
                           -Enabled $true `
                           -ChangePasswordAtLogon $false `
                           -PasswordNeverExpires $true `
                           -Path $ouPath `
                           -CannotChangePassword $false `
                           -PassThru | Out-Null

                Write-Host "✅ Créé : $samAccountName dans $ouPath" -ForegroundColor Green
                Add-Content $logFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Créé '$samAccountName' dans $ouPath"
            }
            catch {
                Write-Host "❌ Erreur création '$samAccountName' : $_" -ForegroundColor Red
                Add-Content $logFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur '$samAccountName' : $_"
                continue
            }
        }

        # Appliquer les horaires
        $logonHours = $null
        switch -Wildcard ($ouPath) {
            "*OU=Eleves*" {
                $logonHours = Get-LogonHours -StartHour 9 -EndHour 17 -Days @(1,2,3,4,5)
            }
            "*OU=Professeurs*" {
                $logonHours = Get-LogonHours -StartHour 8 -EndHour 18 -Days @(1,2,3,4,5)
            }
            "*OU=Administratif*" {
                $logonHours = Get-LogonHours -StartHour 6 -EndHour 20 -Days @(1,2,3,4,5)
            }
        }

        if ($logonHours) {
            try {
                Set-ADUser -Identity $samAccountName -Replace @{logonHours = $logonHours}
                Write-Host "🕒 Horaires appliqués à '$samAccountName'" -ForegroundColor Cyan
                Add-Content $logFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Horaires appliqués à '$samAccountName'"
            }
            catch {
                Write-Host "❌ Erreur horaires '$samAccountName' : $_" -ForegroundColor Red
                Add-Content $logFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur horaire '$samAccountName' : $_"
            }
        } else {
            Write-Host "❗ Aucun horaire appliqué à '$samAccountName' (OU non reconnue)" -ForegroundColor Yellow
        }
    }
}
catch {
    Write-Host "❌ Erreur lecture CSV : $_" -ForegroundColor Red
    Add-Content $logFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur globale d'import : $_"
}
