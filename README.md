# 🖥️ Configuration d'un menu PowerShell pour Windows Server 2022

## 📋 Présentation

Ce projet propose un menu interactif en PowerShell destiné à simplifier la configuration de services essentiels sur Windows Server 2022. Il permet d'automatiser des tâches courantes telles que :

- Renommage du serveur
- Configuration de l'adresse IP
- Installation des rôles AD DS, DNS et DHCP
- Configuration d'Active Directory
- Création d'unités organisationnelles (OU), de groupes et d'utilisateurs
- Importation d'utilisateurs depuis un fichier CSV

Ce menu est particulièrement utile pour les étudiants en apprentissage et les entreprises souhaitant déployer rapidement un environnement serveur fonctionnel.

## 🎯 Objectifs

- **Automatisation** : Réduire le temps de configuration manuelle
- **Simplicité** : Offrir une interface conviviale pour les administrateurs
- **Pédagogie** : Servir de support d'apprentissage pour les étudiants en BTS SIO SISR

## 🛠️ Technologies utilisées

- **Système d'exploitation** : Windows Server 2022 (dans une VM VirtualBox)
- **Langage de script** : PowerShell
- **Éditeur de code** : Visual Studio Code
- **Transfert de fichiers** : Partage de dossiers VirtualBox

## 🗂️ Structure du projet

Nedj_PS_1/
├── main.ps1
├── 1-rename.ps1
├── 2-ipconfig.ps1
├── 3-install-roles.ps1
├── 4-configure-adds.ps1
├── 5-configure-dns.ps1
├── 6-configure-dhcp.ps1
├── 7-add-ou.ps1
├── 8-add-group.ps1
├── 9-add-user.ps1
├── 10-import-csv.ps1
├── 11-exit.ps1
└── README.md


## 🚀 Installation et utilisation

1. **Préparation de l'environnement** :
   - Installer Windows Server 2022 dans une VM VirtualBox
   - Activer le partage de dossiers pour transférer les scripts

2. **Transfert des scripts** :
   - Copier les fichiers `.ps1` dans un dossier partagé accessible depuis la VM

3. **Exécution du menu principal** :
   - Ouvrir PowerShell en tant qu'administrateur
   - Naviguer jusqu'au dossier contenant les scripts
   - Exécuter la commande suivante :
     ```powershell
     .\main.ps1
     ```

4. **Navigation dans le menu** :
   - Utiliser les options proposées pour configurer le serveur selon les besoins

## 📸 Captures d'écran

![image](https://github.com/user-attachments/assets/5c9a62a7-9891-45b2-95c0-1f946c3ba4c1)

## 👥 Auteur

- **Nom** : Nedj
- **Formation** : BTS SIO SISR – Promotion 2025
- **Établissement** : Mediaschool Nice


