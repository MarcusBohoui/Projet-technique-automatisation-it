# Projet technique – Automatisation IT

Projet réalisé en autonomie dans le cadre de mon alternance au sein de l’entreprise Globe Groupe.

🎯 Objectifs

- Automatiser les procédures IT récurrentes (onboarding, offboarding)
- Standardiser le déploiement d’applications Via Intune.
- Intégrer les scripts à une plateforme ITSM (GLPI)

# 🛠️ Technologies utilisées

- Microsoft Intune
- Microsoft 365 Admin Center
- Microsoft Entra ID (Azure AD)
- Microsoft Graph API
- PowerShell
- GLPI

# ⚙️ Fonctionnalités principales

- Script d’onboarding (création utilisateur, ajout au groupe, attribution de licence)
- Script d’offboarding (suppression de groupes, archivage, suppression du compte)
- Déploiement d’applications via Intune (avec détection personnalisée)
- Blocage des installations utilisateurs
- Intégration des scripts via API dans GLPI

# 📁 Structure du dépôt

- `/scripts` : Contient les scripts PowerShell principaux (check_new_ticket.ps1, offboarding.ps1, onboarding.ps1).
- `/rapport-technique` : rapport PDF détaillé du projet réalisé en entreprise (en cour).
