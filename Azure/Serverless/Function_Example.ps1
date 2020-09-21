using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Interact with query parameters or the body of the request.
$command = $Request.Query.$command
if (-not $command) {
    $command = $Request.Body.Command
}

connect-jconline -jumpcloudapikey $env:JumpCloudApiKey -force
$result = Invoke-Expression $command
$body = "This HTTP triggered function executed successfully. Pass a Powershell command in the query string or in the response header body."

if ($command) {
    $body = $result
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
