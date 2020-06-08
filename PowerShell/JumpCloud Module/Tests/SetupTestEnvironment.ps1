# Param(
#     [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$TestOrgAPIKey
# )
# Setup COMMANDS
Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
# Clear previous pester objects
Get-JCUser -lastname:($PesterParams_UserLastName) | Set-JCUser -externally_managed $false
Get-JCUser -lastname:($PesterParams_UserLastName) | Remove-JCUser -force
# Remove all groups
Get-JCSystemGroup | Remove-JCSystemGroup -force
Get-JCUserGroup | Remove-JCUserGroup -force
# Add back groups
# $PesterParams_Groups | ForEach-Object {
#     New-JCSystemGroup -GroupName:($_)
#     New-JCUserGroup -GroupName:($_)
# }
New-JCSystemGroup -GroupName:($PesterParams_SystemGroupName)
New-JCUserGroup -GroupName:($PesterParams_UserGroupName)
# If no command results currently exist
If ([System.String]::IsNullOrEmpty($PesterParams_CommandResultsExist) -or $PesterParams_CommandResultsExist.Count -lt $PesterParams_CommandResultCount)
{
    $testCmd = Get-JCCommand | Where-Object { $_.trigger -eq $PesterParams_CommandTrigger }
    Add-JCCommandTarget -CommandID $testCmd.id -SystemID $PesterParams_SystemID
    $TriggeredCommand = For ($i = 1; $i -le $PesterParams_CommandResultCount; $i++)
    {
        Invoke-JCCommand -trigger:($testCmd.name)
    }
    While ((Get-JCCommandResult | Where-Object { $_.Name -eq $testCmd.name }).Count -ge $PesterParams_CommandResultCount)
    {
        Start-Sleep -Seconds:(1)
    }
    Remove-JCCommandTarget -CommandID $testCmd.id -SystemID $PesterParams_SystemID
}
