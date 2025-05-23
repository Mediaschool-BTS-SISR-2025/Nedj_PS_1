$newName = Read-Host "Entrez le nouveau nom du PC"
Rename-Computer -NewName $newName -Force -Restart
