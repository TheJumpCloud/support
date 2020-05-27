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

# Install Pester
Install-Module -Name:('Pester') -Force -SkipPublisherCheck
Import-Module -Name:('Pester')
Write-Host "Getting Installed Modules:"
Get-InstalledModule
Write-Host "Getting Imported Modules"
Get-Module

Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
#Setup COMMANDS

$CommandResultCount = 10
$CommandResultsExist = Get-JCCommandResult
# If no command results currently exist
If ([System.String]::IsNullOrEmpty($CommandResultsExist) -or $CommandResultsExist.Count -lt $CommandResultCount)
{
    $testCmd = Get-JCCommand | Where-Object { $_.trigger -eq 'GetJCAgentLog' }
    $TriggeredCommand = For ($i = 1; $i -le $CommandResultCount; $i++)
    {
        Invoke-JCCommand -trigger:($testCmd.name)
    }
    While ((Get-JCCommandResult | Where-Object { $_.Name -eq $testCmd.name }).Count -ge $CommandResultCount)
    {
        Start-Sleep -Seconds:(1)
    }
}

#New-JCCommand -name 'Invoke - Pester One Variable' -commandType linux -command 'echo $One' -launchType trigger -timeout 0 -trigger 'onetrigger'
#New-JCCommand -name 'Invoke - Pester Two Variable' -commandType linux -command 'echo $Two' -launchType trigger -timeout 0 -trigger 'twotrigger'
#New-JCCommand -name 'Invoke - Pester Three Variable' -commandType linux -command 'echo $Three' -launchType trigger -timeout 0 -trigger 'threetrigger'
#New-JCCommand -name 'GetJCAgentLog' -commandType linux -command 'cat /opt/jc/*.log' -launchType trigger -timeout 120 -trigger 'GetJCAgentLog'

#create cmd with trigger same as name
#associate

#create PesterTest_SystemGroup
#associate group to cmd
#associate system to cmd

#LINUX pester3 STEPS
#added win system
#added mac system
#added linux system
#New-JCUser -firstname 'pester' -lastname 'tester' -username 'pester.tester' -email 'pester.tester@pester3.jumpcloud.com'
#New-JCSystemGroup -GroupName 'PesterTest_SystemGroup'
#New-JCCommand -name 'GetJCAgentLog' -commandType linux -command 'cat /opt/jc/*.log' -launchType trigger -timeout 120 -trigger 'GetJCAgentLog'
#added radius server named 'PesterTest_RadiusServer'
#New-JCCommand -name 'Invoke JCDeployment Test' -commandType linux -command 'echo $One echo $Two' -launchType manual -timeout 0
#New-JCCommand -name 'Pester - Set-JCCommand' -commandType linux -command 'Not updated command' -launchType trigger -timeout 0 -trigger 'pesterTrigger'
#assign policy to system
#
