Function Get-JCHash()
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Url,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][string]$Method,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)][ValidateNotNullOrEmpty()][string]$Key,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3, ParameterSetName = 'ReturnSpecificFields')][ValidateNotNullOrEmpty()][array]$Values,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 4)][ValidateNotNullOrEmpty()][int]$Limit,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 5)][ValidateNotNullOrEmpty()][string]$Body
    )
    Begin
    {
        Write-Verbose ('Parameter Set: ' + $PSCmdlet.ParameterSetName)
    }
    Process
    {

        $FunctionParameters = [ordered]@{}
        # Get function parameters and filter out unnecessary parameters
        $PSBoundParameters.GetEnumerator() | ForEach-Object {
            If ($_.Key -notin ('SearchBy', 'SearchByValue', 'Type'))
            {
                $FunctionParameters.Add($_.Key, $_.Value) | Out-Null
            }
        }
        ## Remove PowerShell CommonParameters
        # @($FunctionParameters.Keys)| ForEach-Object {If ($_ -in @([System.Management.Automation.PSCmdlet]::CommonParameters)) {$FunctionParameters.Remove($_) | Out-Null}};
        # Add Key value to the Values array
        If ($FunctionParameters.Contains('Values')) {$FunctionParameters['Values'] += $Key}
        # Remove parameters in the FunctionParameters hashtable
        $FunctionParameters.Remove('Key') | Out-Null
        # Rename parameters in the FunctionParameters hashtable
        If ($FunctionParameters.Contains('Values'))
        {
            $FunctionParameters.Add('Fields', $FunctionParameters['Values']) | Out-Null
            $FunctionParameters.Remove('Values') | Out-Null
        }
        # Add parameters from the script to the FunctionParameters hashtable
        $FunctionParameters.Add('Paginate', $true) | Out-Null
        # Run command
        Write-Verbose ('Invoke-JCApi ' + ($FunctionParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','") + "')"}).Replace("'True'", '$True').Replace("'False'", '$False'))
        $DataSet = Invoke-JCApi @FunctionParameters
        #Convert $DataSet from Object to Hashtable with Object data as Values to make searchable
        $Hashtable = New-Object System.Collections.Hashtable
        ForEach ($Item In $DataSet)
        {
            $Hashtable.Add($Item.$Key, $Item)
        }
    }
    End
    {
        # Return Hashtable
        Return $Hashtable
    }
}