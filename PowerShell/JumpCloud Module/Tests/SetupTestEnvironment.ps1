#COMMANDS

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