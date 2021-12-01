################################################################################
# This script will pull the managed Apple ID from the provided CSV along with
# the specified user account and set the user's managed Apple ID attribute.
################################################################################

# Starting Variables
$csvPath = './ManagedAppleDiscovery.csv'
if ([string]::IsNullOrEmpty($JCAPIKEY) -Or [string]::IsNullOrEmpty($JumpCloudApiKey)) {
    While ($JumpCloudApiKey.length -ne 40){
        $JumpCloudApiKey = Read-Host -Prompt "Enter your JumpCloud API Key:"
    }
}
if (-not (Get-InstalledModule -Name JumpCloud)) {
    Write-Host "Installing JumpCloud PowerShell Module"
    Install-Module JumpCloud -Force
}
Connect-JCOnline -force $JumpCloudApiKey
# TODO: if file exists, have a different note & ask if we want to regenerate.

# If the file does not exist
if (-not(Test-Path -Path $csvPath -PathType Leaf)) {
    Write-Host "################################################################################"
    Write-Host ""
    Write-Host "No file was located at $csvPath"
    Write-Host "Would you like to generate a CSV containing all users in your JumpCloud organization?"
    Write-Host "This will include Id, Email and a blank ManagedAppleId field"
    Write-Host ""
    Write-Host "################################################################################"
    Get-JCSdkUser | Select ID, Email, ManagedAppleId | Export-Csv -Path $csvPath -Confirm
}
else {
    Write-Host "################################################################################"
    Write-Host ""
    Write-Host "Existing file was located at $csvPath"
    Write-Host "Would you like to regenerate the CSV?"
    Write-Host "This will include Id, Email and a blank ManagedAppleId field"
    Write-Host ""
    Write-Host "################################################################################"
    Get-JCSdkUser | Select ID, Email, ManagedAppleId | Export-Csv -Path $csvPath -Confirm
}

Write-Host "################################################################################"
Write-Host ""
Write-Host "Importing CSV located at $csvPath, please ensure that data is correct/present"
Write-Host ""
Write-Host "################################################################################"
Read-Host -Prompt "Press any key to continue or CTRL+C to quit"

$managedAppleIdUsers = Import-CSV $csvPath
foreach ($user in $managedAppleIdUsers) {
    $emailRegex = "^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"
    $managedAppleId = $user.ManagedAppleId
    $jcUserEmail = $user.Email
    $jcUserId = $user.Id

    # Validate CSV information
    if ([String]::IsNullOrWhiteSpace($managedAppleId) -or [String]::IsNullOrWhiteSpace($jcUserEmail) -or [String]::IsNullOrWhiteSpace($jcUserId)) {
        Write-Host "Row $($managedAppleIdUsers.indexOf($user)+2) contains a null value or whitespace"
        continue
    }
    if (($managedAppleId -notmatch $emailRegex) -or ($jcUserEmail -notmatch $emailRegex)) {
        Write-Host "Row $($managedAppleIdUsers.indexOf($user)+2) contains an invalid email address"
        continue
    }

    $headers = @{
        Accept      = "application/json";
        'x-api-key' = $JumpCloudApiKey;
    }
    $body = @{
        'managedAppleId'   = "$managedAppleId"
    } | ConvertTo-Json

    try {
        $Response = Invoke-WebRequest -Method Put -Uri "https://console.jumpcloud.com/api/systemusers/$jcUserId" -Headers $headers -Body $body -ContentType 'application/json' -UseBasicParsing
        $StatusCode = $Response.StatusCode
        Write-Host "Assigning $jcUserEmail with the following Managed Apple ID: $managedAppleId"
    }
    catch {
        $StatusCode = $_.Exception.Response.StatusCode.value__
        Write-Error -Message "Encountered error with Row $($managedAppleIdUsers.indexOf($user)+2): $StatusCode"
    }
}
