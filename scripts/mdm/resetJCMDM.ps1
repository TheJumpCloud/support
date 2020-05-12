# BEWARE any MDM enrollment profiles installed on JumpCloud systems will become invaid after deleting the MDM configuration
# System will need to have the invalid enrollment profiles removed prior to installing a new MDM enrollment profile

# To run unattended pass in the parameter -JumpCloudAPIKey in when calling the resetJCMDM.ps1
# Example ./resetJCMDM.ps1 -JumpCloudAPIKey "56b403784365r6o2n311cosr218u1762le4y9e9a"
# Your JumpCloudAPIKey can be found on the drop down list under admin email in the top right corner of the admin console


param (
    $JumpCloudAPIKey
)
$URI = "https://console.jumpcloud.com/api/v2/applemdms"
$hdrs = @{"X-API-KEY" = "$JumpCloudAPIKey" }
$AppleMDM = Invoke-RestMethod -Method Get -Uri $URI -Headers $hdrs

$CurrentMDMSettingURI = "https://console.jumpcloud.com/api/v2/applemdms/$($AppleMDM.id)"

Invoke-RestMethod -Method Delete -Uri $CurrentMDMSettingURI -Headers $hdrs




