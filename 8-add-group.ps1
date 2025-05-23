 $groupName = Read-Host "Nom du groupe"
            $ouPath = Read-Host "Chemin de l'OU (ex: 'OU=Utilisateurs,DC=mondomaine,DC=local')"
            New-ADGroup -Name $groupName -Path $ouPath -GroupScope Global -GroupCategory Security
        