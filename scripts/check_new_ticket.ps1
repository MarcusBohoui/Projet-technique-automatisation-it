$glpiUrl   = "http://localhost/glpi/apirest.php"
$appToken  = "jbh47BlQsXhmYFT3jo82lSxUEB3evwbhavDxcvy3"
$userToken = "w4NTCrEW62MyYm7WEwBMWavs79mDeYy0VsZKtshg"

try {
    $session = Invoke-RestMethod -Method GET -Uri "$glpiUrl/initSession" -Headers @{
        "App-Token"     = $appToken
        "Authorization" = "user_token $userToken"
    }
    $sessionToken = $session.session_token
    Write-Host "Connexion réussie à GLPI."
} catch {
    Write-Error "Erreur de connexion à GLPI : $_"
    exit
}

$tickets = Invoke-RestMethod -Method GET -Uri "$glpiUrl/Ticket" -Headers @{
    "App-Token"     = $appToken
    "Session-Token" = $sessionToken
} -Body (@{
    criteria = @(
        @{ field = "status"; searchtype = "in"; value = "1,2" }
    ) | ConvertTo-Json -Compress
    forcedisplay = @("id", "name", "content", "status") | ConvertTo-Json -Compress
    range = "0-50"
})

Add-Type -AssemblyName System.Web

$logFile = "C:\scripts\log.txt"

foreach ($ticket in $tickets) {
    if ($ticket.status -in 5,6) {
        continue
    }

    if (Test-Path $logFile -and (Select-String -Path $logFile -Pattern "Ticket ID $($ticket.id)")) {
        continue
    }

    $decodedContent = [System.Web.HttpUtility]::HtmlDecode($ticket.content) -replace '<br\s*/?>', "`n" -replace '<[^>]+>', ''
    $lines = $decodedContent -split "`n"

    $data = @{ Titre = ""; Prénom = ""; Nom = ""; Groupe = ""; Email = "" }

    foreach ($line in $lines) {
        $clean = $line.Trim()
        foreach ($key in $data.Keys) {
            if ($clean -match "^$key\s*:\s*(.+)$") {
                $data[$key] = $matches[1].Trim()
            }
        }
    }

    $scriptCalled = $false
    $typeTraitement = ""

    if ($data.Titre -eq "Onboarding" -and $data.Prénom -and $data.Nom -and $data.Groupe) {
        & "C:\scripts\onboarding.ps1" -prenom $data.Prénom -nom $data.Nom -groupe $data.Groupe -ticketId $ticket.id
        $scriptCalled = $true
        $typeTraitement = "Onboarding"
    } elseif ($data.Titre -eq "Offboarding" -and $data.Email) {
        & "C:\scripts\offboarding.ps1" -email $data.Email -ticketId $ticket.id
        $scriptCalled = $true
        $typeTraitement = "Offboarding"
    }

    if ($scriptCalled) {
        $body = @{ input = @{ status = 5 } } | ConvertTo-Json -Depth 10 -Compress
        Invoke-RestMethod -Method PUT -Uri "$glpiUrl/Ticket/$($ticket.id)" -Headers @{
            "App-Token"     = $appToken
            "Session-Token" = $sessionToken
            "Content-Type"  = "application/json"
        } -Body $body

        $info = if ($typeTraitement -eq "Onboarding") {
            "$($data.Prénom).$($data.Nom)@bohouimarcusoutlook.onmicrosoft.com"
        } else {
            $data.Email
        }

        $logEntry = "$(Get-Date -Format 'MM/dd/yyyy HH:mm:ss') - [$typeTraitement] Ticket ID $($ticket.id) : $info traité (résolu)"
        Add-Content -Path $logFile -Value $logEntry
    }
}

Invoke-RestMethod -Method GET -Uri "$glpiUrl/killSession" -Headers @{
    "App-Token"     = $appToken
    "Session-Token" = $sessionToken
}
