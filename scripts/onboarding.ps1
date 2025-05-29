param(
    [string]$prenom,
    [string]$nom,
    [string]$groupe,
    [string]$ticketId = "inconnu"
)

$clientId   = "468bd68d-47d4-4a85-9553-25fb350163c4"
$tenantId   = "0def6469-2a08-49f2-bd42-74fb2e00f140"
$thumbprint = "2D201E658BE693C7AEDC1833E3FCBC127BCCD56E"

try {
    Connect-MgGraph -ClientId $clientId -TenantId $tenantId -CertificateThumbprint $thumbprint -NoWelcome
    Write-Host "Connexion réussie à Microsoft Graph via certificat."
} catch {
    Write-Warning "Erreur de connexion à Microsoft Graph : $_"
    exit
}

$email = "$prenom.$nom@bohouimarcusoutlook.onmicrosoft.com".ToLower()

try {
    $userParams = @{
        AccountEnabled    = $true
        DisplayName       = "$prenom $nom"
        MailNickname      = "$prenom$nom"
        UserPrincipalName = $email
        PasswordProfile   = @{
            Password = "Motdepasse123!"
            ForceChangePasswordNextSignIn = $true
        }
    }
    New-MgUser @userParams | Out-Null
    Write-Host "Utilisateur créé : $email"
} catch {
    Write-Warning "Erreur lors de la création de l’utilisateur : $_"
    Disconnect-MgGraph | Out-Null
    exit
}

try {
    $group = Get-MgGroup -Filter "displayName eq '$groupe'" | Select-Object -First 1
    $user = Get-MgUser -UserId $email

    if ($group -and $user) {
        New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id
        Write-Host "Ajouté au groupe : $groupe"
    } else {
        Write-Warning "Groupe ou utilisateur non trouvé."
    }
} catch {
    Write-Warning "Erreur lors de l’ajout au groupe : $_"
}

Disconnect-MgGraph | Out-Null
Write-Host "Déconnexion de Microsoft Graph."

$logEntry = "$(Get-Date -Format 'MM/dd/yyyy HH:mm:ss') - [Onboarding] Ticket ID $ticketId : $email traité (résolu)"
Add-Content -Path "C:\\scripts\\log.txt" -Value $logEntry
