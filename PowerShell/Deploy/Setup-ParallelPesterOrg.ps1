Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKey
    , [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$JumpCloudApiKeyMsp
    , [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 2)][ValidateNotNullOrEmpty()][System.String]$RequiredModulesRepo = "PSGallery"

)
# Load Get-Config.ps1
. "$PSScriptRoot/Get-Config.ps1" -RequiredModulesRepo $RequiredModulesRepo
# Load Private Functions
Get-ChildItem -Path:("$PSScriptRoot/../JumpCloud Module/Private/*.ps1") -Recurse | ForEach-Object { . $_.FullName }
# Load Helper Functions
. "$PSScriptRoot/../JumpCloud Module/Tests/HelperFunctions.ps1"
# Setup Org
. "$PSScriptRoot/../JumpCloud Module/Tests/DefineEnvironment.ps1" -JumpCloudApiKey $JumpCloudApiKey -JumpCloudApiKeyMsp $JumpCloudApiKeyMsp -RequiredModulesRepo $RequiredModulesRepo
. "$PSScriptRoot/../JumpCloud Module/Tests/SetupOrg.ps1" -JumpCloudApiKey $JumpCloudApiKey -JumpCloudApiKeyMsp $JumpCloudApiKeyMsp
# Export Variables for pester tests
Get-Variable -Name "PesterParams*" | ConvertTo-Json -Depth 99 | Out-File -Path "$PSScriptRoot/../JumpCloud Module/Tests/$($PesterParams_Org.displayName.Replace(' ', '')).cache.json"
Write-Host "Sucessfully Setup $($PesterParams_Org.displayName.Replace(' ', '')) Org"

$items = Get-Variable -Name "Pester*"
$list = @()
$hashList = @()
foreach ($item in $items) {
    if ($item.Value) {
        if ($item.Value.GetType().Name -eq [Hashtable]) {
            $hashList += ($item)
        }
        if ($item.Value.GetType().Name -eq [PSCustomObject]) {
            $list += ($item)

        } else {
            $list += ($item)
        }
    }
}
$hashList | ConvertTo-Json -Depth 99 | Out-File -Path "$PSScriptRoot/../JumpCloud Module/Tests/$($PesterParams_Org.displayName.Replace(' ', ''))_hash.cache.json"
$list | ConvertTo-Json -Depth 99 | Out-File -Path "$PSScriptRoot/../JumpCloud Module/Tests/$($PesterParams_Org.displayName.Replace(' ', '')).cache.json"
