Function Set-JCRadiusServer {
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Bypass user prompts and dynamic ValidateSet.')][ValidateNotNullOrEmpty()][Switch]$Force
    )
    DynamicParam {
        $Action = 'set'
        $Type = 'radius_server'
        $RuntimeParameterDictionary = If ($Type) {
            Get-DynamicParamRadiusServer -Action:($Action) -Force:($Force) -Type:($Type)
        } Else {
            Get-DynamicParamRadiusServer -Action:($Action) -Force:($Force)
        }
        Return $RuntimeParameterDictionary
    }
    Begin {
        Connect-JCOnline -force | Out-Null
        # Debug message for parameter call
        $PSBoundParameters | Out-DebugParameter | Write-Debug
        $Results = @()
    }
    Process {
        # Write-Host "CUSTOM"
        # Write-Host $RuntimeParameterDictionary
        # Write-Host $ScriptBlock_DefaultDynamicParamProcess
        # Write-Host $PsBoundParameters
        # Write-Host $PSCmdlet

        # # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        # Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        # # Create hash table to store variables
        # $FunctionParameters = [ordered]@{ }
        # # Add input parameters from function in to hash table and filter out unnecessary parameters
        # $PSBoundParameters.GetEnumerator() | Where-Object { -not [System.String]::IsNullOrEmpty($_.Value) } | ForEach-Object { $FunctionParameters.Add($_.Key, $_.Value) | Out-Null }
        # # Add hardcoded parameters
        # ($FunctionParameters).Add('Action', 'get') | Out-Null
        # ($FunctionParameters).Add('Type', $Type) | Out-Null
        # # Run the command
        # Write-Host $FunctionParameters.keys
        # Write-Host $FunctionParameters.values
        # $Results += Invoke-JCRadiusServer @FunctionParameters
        # Write-Host "#$#####"
        # $Results
        # Write-Host "#$#####"

        # For DynamicParam with a default value set that value and then convert the DynamicParam inputs into new variables for the script to use
        Invoke-Command -ScriptBlock:($ScriptBlock_DefaultDynamicParamProcess) -ArgumentList:($PsBoundParameters, $PSCmdlet, $RuntimeParameterDictionary) -NoNewScope
        # Create hash table to store variables
        $FunctionParameters = [ordered]@{ }
        # Add input parameters from function in to hash table and filter out unnecessary parameters
        $PSBoundParameters.GetEnumerator() | Where-Object { -not [System.String]::IsNullOrEmpty($_.Value) } | ForEach-Object { $FunctionParameters.Add($_.Key, $_.Value) | Out-Null }
        # Add hardcoded parameters
        ($FunctionParameters).Add('Action', $Action) | Out-Null
        ($FunctionParameters).Add('Type', $Type) | Out-Null
        # Run the command
        Write-Host $FunctionParameters.keys
        Write-Host $FunctionParameters.values
        $Results += Invoke-JCRadiusServer @FunctionParameters
    }
    End {
        Return $Results
    }
}
# Import-Module "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/JumpCloud.psd1" -force
# . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Public/Authentication/Connect-JCOnline.ps1"
# . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/NestedFunctions/Get-JCType.ps1"
# . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/NestedFunctions/Out-DebugParameter.ps1"
# . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/NestedFunctions/Get-JCColorConfig.ps1"
# . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/RadiusServer/Invoke-JCRadiusServer.ps1"
# . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/DynamicParameters/Get-JCCommonParameters.ps1"
# . "/Users/jworkman/Documents/GitHub/support/PowerShell/Deploy/Functions/New-DynamicParameter.ps1"
# . "/Users/jworkman/Documents/GitHub/support/PowerShell/JumpCloud Module/Private/RadiusServer/Get-DynamicParamRadiusServer.ps1"
# Set-JCRadiusServer -Id 6359d1751a0a64a598bbf6b5 -networkSourceIp 118.88.96.249 -force