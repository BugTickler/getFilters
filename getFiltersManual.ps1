$id = Read-Host "Enter ID"
$linkTemplate = "" #See playbook

$headers = @{
    'Accept' = 'application'  #See playbook
    'Authorization' = 'Bearer ' #See playbook
    'Content-Website' = '4'
}

$uri = "https://" 

$response = Invoke-WebRequest -Uri $uri -Headers $headers -ContentType 'application/json'

$responseString = $response.Content

$pattern = '"base_url":"(.+?)"'
$match = [regex]::Match($responseString, $pattern)

if ($match.Success) {
    $fragmentWithBackslashes = $match.Groups[1].Value
    $fragment = $fragmentWithBackslashes -replace '\\'
    $url = "$linkTemplate -f $fragment"

    Write-Host "Link: $url"


    Start-Process $url
} else {
    Write-Host "Nie można znaleźć URL z podajego ID."
}
