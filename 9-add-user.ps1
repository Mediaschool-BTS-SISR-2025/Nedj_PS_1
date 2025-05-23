$userName = Read-Host "Nom de l'utilisateur"
            $userPassword = Read-Host "Mot de passe" -AsSecureString
            $ouPath = Read-Host "Chemin de l'OU (ex: 'OU=Utilisateurs,DC=mondomaine,DC=local')"
            New-ADUser -Name $userName -AccountPassword $userPassword -Path $ouPath -Enabled $true
        