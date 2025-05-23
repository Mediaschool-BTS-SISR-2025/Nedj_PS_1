 $domainName = Read-Host "Nom du domaine à créer"
            Install-ADDSForest -DomainName $domainName -InstallDNS -Force