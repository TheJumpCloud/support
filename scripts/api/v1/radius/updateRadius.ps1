#################################################################################
#                                                                               #
# updateRadius.ps1 - This script will use ipecho.net to compare your public     #
# IP address with the IP address currently configured for your JumpCloud RADIUS #
# server. If the IP address has changed, it will be updated.                    #
#                                                                               #
# Fill out the <API_KEY> and <RADIUS_ID> parameters with your information.      #
#                                                                               #
# This can be scheduled to run automatically in Windows Task Scheduler.         #
#                                                                               #
# Author: Nate Crimmel                                                          #
#                                                                               #
#################################################################################


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ErrorActionPreference = 'Stop'

# Enter the API Key below. This is found in the JumpCloud console by clicking your email address on the top-right and then "API Settings".
$headers = @{
    'Accept'       = 'application/json'
    'Content-Type' = 'application/json'
    'x-api-key'    = '<API_KEY>'
}

function Get-CurrentIp {
    Invoke-WebRequest -Uri $uri -UseBasicParsing -Method Get -Headers $headers | Select-Object -Expand Content
}

# Enter the RADIUS_ID below. This is found in the URL bar of your web browser when viewing the RADIUS server settings.
$radiusId = "<RADIUS_ID>"
$uri = "https://console.jumpcloud.com/api/radiusservers/$radiusId"
$newIp = Invoke-WebRequest -Uri "http://ipecho.net/plain" -UseBasicParsing | Select-Object -Expand Content
$currentIp = (Get-CurrentIp | ConvertFrom-Json).networkSourceIp

$body = @{
    networkSourceIp = "$newIp"
}

$bodyNewIp = $body | ConvertTo-Json

function Update-NewIp {
    Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body $bodyNewIp
}

# Bail if we can't get the current IP address.
If (!$newIp) {
    'Your IP address could not be determined.'
    Exit
}

# Update IP if it has changed.
If ($currentIp -ne $newIp) {
    Update-NewIp
    'Your IP address has been updated.'
    Exit
}

# Show a message if the IP address didn't change.
If ($currentIp -eq $newIp) {
    'Your IP address has not changed, have a nice day!'
    Exit
}