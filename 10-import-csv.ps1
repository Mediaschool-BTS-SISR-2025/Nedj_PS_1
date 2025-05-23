$csvPath = Read-Host "Chemin du fichier CSV"
            Import-Csv $csvPath | ForEach-Object {
                New-ADUser -Name $_.Name -SamAccountName $_.SamAccountName -AccountPassword (ConvertTo-SecureString $_.Password -AsPlainText -Force) -Path $_.OU -Enabled $true
            }