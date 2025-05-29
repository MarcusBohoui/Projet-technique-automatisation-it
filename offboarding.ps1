param(
    [string]$email,
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

try {
    $user = Get-MgUser -UserId $email -ErrorAction Stop
    Write-Host "Utilisateur trouvé : $email"
} catch {
    Write-Warning "Utilisateur introuvable : $email"
    Disconnect-MgGraph | Out-Null
    exit
}

try {
    Remove-MgUser -UserId $email -ErrorAction Stop
    Write-Host "Utilisateur supprimé : $email"
} catch {
    Write-Warning "Erreur lors de la suppression de l'utilisateur : $_"
}

Disconnect-MgGraph | Out-Null
Write-Host "Déconnexion de Microsoft Graph."

$logEntry = "$(Get-Date -Format 'MM/dd/yyyy HH:mm:ss') - [Offboarding] Ticket ID $ticketId : $email traité (résolu)"
Add-Content -Path "C:\\scripts\\log.txt" -Value $logEntry
