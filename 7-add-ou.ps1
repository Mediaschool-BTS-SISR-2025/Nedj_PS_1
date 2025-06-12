Clear-Host
Write-Host "=== Création automatique des Unités d'Organisation ===" -ForegroundColor Cyan

$logFile = ".\add_ou.log"
$ouList = @("Eleves", "Professeurs", "Administratif")
$parentPath = "DC=entreprise,DC=local"  # ⚠️ À adapter à ton domaine

# Importer le module Active Directory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "✅ Module ActiveDirectory chargé." -ForegroundColor Green
}
catch {
    Write-Host "❌ Erreur : le module ActiveDirectory n'est pas installé ou accessible." -ForegroundColor Red
    return
}

foreach ($ouName in $ouList) {
    $fullOUPath = "OU=$ouName,$parentPath"
    try {
        $existingOU = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'" -SearchBase $parentPath -ErrorAction SilentlyContinue
        if ($existingOU) {
            Write-Host "⚠️ L'OU '$ouName' existe déjà." -ForegroundColor Yellow
            Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - OU '$ouName' déjà existante."
        }
        else {
            New-ADOrganizationalUnit -Name $ouName -Path $parentPath -ProtectedFromAccidentalDeletion $true
            Write-Host "✅ OU '$ouName' créée avec succès." -ForegroundColor Green
            Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - OU '$ouName' créée."
        }
    }
    catch {
        Write-Host "❌ Erreur création OU '$ouName' : $_" -ForegroundColor Red
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur création OU '$ouName' : $_"
    }
}

Write-Host "`n🎯 Création des OU terminée." -ForegroundColor Cyan
