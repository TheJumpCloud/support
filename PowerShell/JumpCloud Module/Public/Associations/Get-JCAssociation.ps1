Function Get-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][ValidateSet('active_directory', 'command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][Alias('TypeNameSingular')][string]$Type
    )
    DynamicParam
    {
        $Action = 'get'
        # Build dynamic parameters
        Return (& $ScriptBlock_AssociationDynamicParam -Action:($Action) -Type:($Type))
    }
    Begin
    {
        # Debug message for parameter call
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { ('-' + $_.Key + ":('" + ($_.Value -join "','") + "')").Replace("'True'", '$True').Replace("'False'", '$False')}) )
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}
        $Results = @()
    }
    Process
    {
        # For parameters with a default value set that value
        $NewParams.Values | Where-Object {$_.IsSet -and $_.Attributes.ParameterSetName -eq $PSCmdlet.ParameterSetName} | ForEach-Object {$PSBoundParameters[$_.Name] = $_.Value}
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object { Set-Variable -Name:($_.Key) -Value:($_.Value) -Force}
        # Create hash table to store variables
        $FunctionParameters = [ordered]@{}
        # Add input parameters from function in to hash table and filter out unnecessary parameters
        $PSBoundParameters.GetEnumerator() | ForEach-Object {$FunctionParameters.Add($_.Key, $_.Value) | Out-Null}
        # Add parameters from the script to the FunctionParameters hashtable
        $FunctionParameters.Add('Action', $Action) | Out-Null
        # Run the command
        $Results += Invoke-JCAssociation @FunctionParameters
    }
    End
    {
        Return $Results
    }
}