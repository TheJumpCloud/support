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
        $Results += Invoke-JCRadiusServer @FunctionParameters
    }
    End {
        Return $Results
    }
}