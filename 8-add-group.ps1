Clear-Host
Write-Host "=== Création d'un groupe Active Directory dans une OU cible ===" -ForegroundColor Cyan

$logFile = ".\add_group.log"
$parentDomain = "DC=entreprise,DC=local"  # ⚠️ À adapter

# Importer le module Active Directory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "✅ Module ActiveDirectory chargé." -ForegroundColor Green
}
catch {
    Write-Host "❌ Erreur : le module ActiveDirectory n'est pas disponible." -ForegroundColor Red
    return
}

# Choix OU cible parmi les 3 créées
$ouOptions = @("Eleves", "Professeurs", "Administratif")
Write-Host "Sélectionnez l'OU dans laquelle créer le groupe :"
for ($i = 0; $i -lt $ouOptions.Count; $i++) {
    Write-Host "$($i + 1). $($ouOptions[$i])"
}
do {
    $selection = Read-Host "Entrez le numéro de l'OU (1 à 3)"
} while (-not ($selection -match '^[1-3]$'))

$selectedOU = $ouOptions[$selection - 1]
$ouPath = "OU=$selectedOU,$parentDomain"

# Saisie des infos groupe
$groupName = Read-Host "Entrez le nom du groupe (ex: 'Groupe-$selectedOU')"

do {
    $groupScope = Read-Host "Entrez la portée du groupe (DomainLocal, Global, Universal)"
} while ($groupScope -notin @("DomainLocal", "Global", "Universal"))

do {
    $groupTypeInput = Read-Host "Entrez le type du groupe (Security ou Distribution)"
} while ($groupTypeInput -notin @("Security", "Distribution"))

try {
    # Vérifier existence
    $existingGroup = Get-ADGroup -Filter "Name -eq '$groupName'" -SearchBase $ouPath -ErrorAction SilentlyContinue
    if ($existingGroup) {
        Write-Host "⚠️ Le groupe '$groupName' existe déjà dans $selectedOU." -ForegroundColor Yellow
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Groupe '$groupName' déjà existant dans $ouPath"
    } else {
        # Créer le groupe
        New-ADGroup -Name $groupName -GroupScope $groupScope -GroupCategory $groupTypeInput -Path $ouPath
        Write-Host "✅ Groupe '$groupName' créé avec succès dans $selectedOU." -ForegroundColor Green
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Groupe '$groupName' créé dans $ouPath"
    }
}
catch {
    Write-Host "❌ Erreur lors de la création du groupe : $_" -ForegroundColor Red
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Erreur création groupe '$groupName' : $_"
}
