$ouName = Read-Host "Nom de l'OU"
            $ouPath = Read-Host "Chemin de l'OU (ex: 'DC=mondomaine,DC=local')"
            New-ADOrganizationalUnit -Name $ouName -Path $ouPath