Connect-JCOnline -JumpCloudApiKey:($TestOrgAPIKey) -force | Out-Null
#Setup COMMANDS

$CommandResultCount = 10
$CommandResultsExist = Get-JCCommandResult
# If no command results currently exist
If ([System.String]::IsNullOrEmpty($CommandResultsExist) -or $CommandResultsExist.Count -lt $CommandResultCount)
{
    $testCmd = Get-JCCommand | Select-Object -First 1
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
