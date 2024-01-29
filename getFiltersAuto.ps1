# Settings
$apiKey = "API KEY"
$categoriesApiUriTemplate = "" # See playbook
$mediaExpertUrlTemplate = "" # See playbook

# Retrieving a list of open alerts containing "FiltersGQL.getFilters" in the name
$alertsUri = "https://api.opsgenie.com/v2/alerts?query=FiltersGQL.getFilters&status=open"

$headers = @{
    "Authorization" = "GenieKey $apiKey"
}

$response = Invoke-RestMethod -Uri $alertsUri -Headers $headers -Method Get

if ($response.data.Count -eq 0) {
    Write-Host "No open alerts with .getFilters in the name."
} else {
    # Initializing an empty list of open IDs
    $openedIds = @()

    for ($i = 0; $i -lt $response.data.Count; $i++) {
        $alert = $response.data[$i]
        # Retrieving the alert ID
        $alertId = $alert.id

        # URI to retrieve notes from the alert
        $notesUri = "https://api.opsgenie.com/v2/alerts/$alertId/notes?limit=100"

        # Retrieving notes from the alert
        $notesResponse = Invoke-RestMethod -Uri $notesUri -Headers $headers -Method Get

        # Displaying notes from the alert
        if ($notesResponse.data.Count -eq 0) {
            Write-Host "No notes in alert $alertId."
        } else {
            for ($j = 0; $j -lt $notesResponse.data.Count; $j++) {
                $note = $notesResponse.data[$j]
                # Retrieving the content of the note
                $noteContent = $note.note

                # Checking if the note contains the old pattern
                $notePattern = "\[Category - (\d+)\]"
                if ($noteContent -match $notePattern) {
                    $categoryId = $Matches[1]

                    # Open URL in the browser
                    $id = $categoryId
                    $headers = @{
                        'Accept' = '' # See playbook
                        'Authorization' = '' # See playbook
                        'Content-Website' = '4'
                    }
                    $uri = $categoriesApiUriTemplate -f $id
                    $response = Invoke-WebRequest -Uri $uri -Headers $headers -ContentType 'application/json'
                    $responseString = $response.Content
                    $pattern = '"base_url":"(.+?)"'
                    $match = [regex]::Match($responseString, $pattern)

                    if ($match.Success) {
                        $fragmentWithBackslashes = $match.Groups[1].Value
                        $fragment = $fragmentWithBackslashes -replace '\\'
                        $url = $mediaExpertUrlTemplate -f $fragment
                        Write-Host "$categoryId Link: $url"
                        Start-Process $url
                    } else {
                        Write-Host "Unable to find URL with the given ID."
                    }
                }
            }
        }
    }
}

# Command to stop the terminal
Read-Host -Prompt "Press Enter to continue..."
