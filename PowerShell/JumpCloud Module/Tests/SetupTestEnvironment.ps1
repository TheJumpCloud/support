Param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][System.String]$TestOrgAPIKey,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][System.String]$MultiTenantAPIKey
)
$ModuleManifestName = 'JumpCloud.psd1'
$ModuleManifestPath = "$PSScriptRoot/../$ModuleManifestName"
$RequiredModules = (Import-LocalizedData -BaseDirectory:("$PSScriptRoot/..") -FileName:($ModuleManifestName)).RequiredModules
If ($RequiredModules)
{
    $RequiredModules | ForEach-Object {
        If ([System.String]::IsNullOrEmpty((Get-InstalledModule).Where( { $_.Name -eq $_ })))
        {
            Write-Host ('Installing: ' + $_)
            Install-Module -Name:($_) -Force
        }
        If (!(Get-Module -Name:($_)))
        {
            Write-Host ('Importing: ' + $_)
            Import-Module -Name:($_) -Force
        }
    }
}
Import-Module -Name:($ModuleManifestPath) -Force
# Load config and helper files
. ($PSScriptRoot + '/HelperFunctions.ps1')
. ($PSScriptRoot + '/TestEnvironmentVariables.ps1')

Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
#Setup COMMANDS

#Clear previous pester objects
Get-JCUser | Set-JCUser -externally_managed $false
Get-JCUser -lastname Test | Remove-JCUser -force

$removeGroups = Get-JCGroup | Where-Object { @("one", "two", "three", "four", "five", "six", "PesterTest_UserGroup", "PesterTest_SystemGroup") -notcontains $_.name }

 foreach ($group in $removeGroups) {
     if ($group.type -eq "system_group") {
         Remove-JCSystemGroup -GroupName $group.name -force
    } elseif ($group.type -eq "user_group") {
         Remove-JCUserGroup -GroupName $group.name -force
    }
}

$CommandResultCount = 10
$CommandResultsExist = Get-JCCommandResult
# If no command results currently exist
If ([System.String]::IsNullOrEmpty($CommandResultsExist) -or $CommandResultsExist.Count -lt $CommandResultCount)
{
    $testCmd = Get-JCCommand | Where-Object { $_.trigger -eq 'GetJCAgentLog' }
    Add-JCCommandTarget -CommandID $testCmd.id -SystemID $PesterParams.SystemID
    $TriggeredCommand = For ($i = 1; $i -le $CommandResultCount; $i++)
    {
        Invoke-JCCommand -trigger:($testCmd.name)
    }
    While ((Get-JCCommandResult | Where-Object { $_.Name -eq $testCmd.name }).Count -ge $CommandResultCount)
    {
        Start-Sleep -Seconds:(1)
    }
    Remove-JCCommandTarget -CommandID $testCmd.id -SystemID $PesterParams.SystemID
}
