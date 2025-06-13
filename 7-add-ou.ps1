Clear-Host
Write-Host "=== Creation automatique des Unites d'Organisation ===" -ForegroundColor Cyan

$logFile = ".\add_ou.log"
$ouList = @("Eleves", "Professeurs", "Administratif")
$parentPath = "DC=entreprise,DC=local"  # ⚠️ À adapter à ton domaine

# Importer le module Active Directory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "✅ Module ActiveDirectory charge." -ForegroundColor Green
}
catch {
    Write-Host "❌ Erreur : le module ActiveDirectory n'est pas installe ou accessible." -ForegroundColor Red
    return
}

foreach ($ouName in $ouList) {
    try {
        $existingOU = Get-ADOrganizationalUnit -Filter "Name -eq '$ouName'" -SearchBase $parentPath -ErrorAction SilentlyContinue
        if ($existingOU) {
            Write-Host "⚠️ L'OU '$ouName' existe deja." -ForegroundColor Yellow
            Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - OU '$ouName' deja existante."
        }
        else {
            New-ADOrganizationalUnit -Name $ouName -Path $parentPath -ProtectedFromAccidentalDeletion $true
            Write-Host "✅ OU '$ouName' creee avec succes." -ForegroundColor Green
            Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - OU '$ouName' creee."
        }
    }
    catch {
        Write-Host "❌ Erreur creation OU '$ouName' : $_" -ForegroundColor Red
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur creation OU '$ouName' : $_"
    }
}

Write-Host "`n🎯 Creation des OU terminee." -ForegroundColor Cyan
